---
title: "Caching 101: Where It Lives, How It Works, and Eviction Policies"
date: 2026-10-04
description: "Where a cache can live and the patterns for reading and writing through it, with two real examples where caching cut response times from seconds to near zero."
tags: ["Caching", "System Design", "Redis", "EnggFeed", "Backend"]
toc: true
---

> This post expands on a talk I gave on September 30, 2026, on the basics: where a cache can live, and the patterns for using one.

I've run into caching twice, once on a side project and once at work. In [EnggFeed](https://enggfeed.mridulabs.dev), the first user to ask for an AI-generated summary waited about 10 seconds, and everyone after them waited about 2ms. On a Google App Engine app at work, some static files took 4000-5000ms to respond, and after we set a longer cache expiration they took about 0ms. Both numbers are rough, from memory. The gap between them is the whole reason caching exists.

<!-- toc -->

<div class="video-embed">
<iframe src="https://www.youtube.com/embed/m8WqOTslV2s" title="Caching 101 video" allowfullscreen></iframe>
</div>

## Where a Cache Lives

A cache is a faster place to keep a copy of something that's slow to get. The first decision is where that copy sits. There are four common places, ordered here from closest to the user to closest to the data.

### Client-Side

The cache sits inside the client, usually the browser. A cached response is reused without a network request at all, so there's nothing to wait for.

![Client-side caching: the cache sits inside the client, between the client and the application servers](/blog/caching-client-side.png)

This is what happened on App Engine. In `app.yaml`, static file handlers take an `expiration` setting that controls the `Cache-Control` and `Expires` headers sent with each file. We set a longer expiration on the static handlers only, not app-wide. App Engine also has a separate top-level `default_expiration` that applies to every static handler, and a handler's own `expiration` overrides it. Some of those files had taken 4000-5000ms. After the change, repeat requests dropped to about 0ms, because the browser no longer asked the server.

### CDN

A CDN keeps copies of content on servers spread around the world, so a client reads from the nearest one instead of from your origin server.

![CDN caching: a client in Australia reads from the closest CDN node instead of the origin server in the US](/blog/caching-cdn.png)

The win is distance. A client far from your server pays for that distance on every request. With a CDN, the request is served by the closest CDN node instead of travelling to the origin server each time, which cuts the response time. CDNs are mostly used for images and media, such as photos and video.

### In-Process

The cache lives in the application server's own memory, next to your code.

![In-process caching: the cache sits inside the application server](/blog/caching-in-process.png)

It's the fastest option, since there's no network hop, and the simplest, since it needs no extra service. The tradeoff is that each server instance has its own copy. Run three instances and you have three caches that can disagree, and every restart empties them.

### External

The cache is a separate service that all your application servers share, such as Redis.

![External caching: application servers check a shared cache first, then fall back to the database](/blog/caching-external.png)

Because it's shared, every server sees the same cached data, and a restart of one app server doesn't lose it. It costs a network hop, which is still far cheaper than a database query or an LLM call. EnggFeed uses Redis this way.

## How the Application Uses It

Once the cache is somewhere, there are different patterns for who talks to it and when data gets written.

### Cache-Aside

The application manages the cache itself. It checks the cache first, and on a miss it reads from the database and puts the result into the cache for next time.

![Cache-aside: the application checks the cache first, then reads from the database as a fallback](/blog/caching-cache-aside.png)

EnggFeed worked like this, with one more step on a double miss. The lookup order was cache, then database, then the LLM. The LLM-generated Summary and Simplify text was cached in full, so after the first request every user got it from Redis in about 2ms. The catch is in the name of the pattern: nothing is cached until someone asks. The first user after a miss pays for everything, which for EnggFeed meant a wait of about 10 seconds for a fresh LLM call. The fix is in the write-through section below.

### Read-Through

The application only ever talks to the cache. On a miss, the cache itself fetches from the database.

![Read-through: the application checks the cache, and the cache reads from the database on a miss](/blog/caching-read-through.png)

The difference from cache-aside is who does the fetching. With read-through, the logic for loading data lives in the cache layer, so application code stays simpler.

### Write-Through

Writes go to the cache first, and the cache writes to the database synchronously before the write is considered done.

![Write-through: the application writes to the cache, which synchronously writes to the database](/blog/caching-write-through.png)

The cache and the database stay in step, at the cost of slower writes, since each one waits for both.

In EnggFeed v2 I moved to this. After seeing the first-user wait with cache-aside, I started generating the summary and simplified text at ingest. The application writes the result to the database first and then to Redis, in the same step, so by the time a user opens an article the cached response is already there and every request is served from the cache. It's write-through done at the application level, since the application writes to both places and not the cache itself.

### Write-Behind

Writes go to the cache, and the cache flushes them to the database later, asynchronously.

![Write-behind: the application writes to the cache and reads from it, while the cache flushes to the database asynchronously](/blog/caching-write-behind.png)

Writes are fast because the application doesn't wait for the database. The risk is that data sitting in the cache but not yet flushed can be lost if the cache fails.

## Eviction Policies

A cache has limited space, and entries can get old. Eviction policies decide what leaves the cache when it is full, or when an entry gets too old.

- **LRU (Least Recently Used):** evicts the item that has gone unused the longest. It adapts well to typical workloads.
- **LFU (Least Frequently Used):** evicts the item used least often. It fits data that stays consistently popular.
- **FIFO (First In, First Out):** evicts the oldest entry, ignoring how it is used. It is rarely seen in production.
- **TTL (Time To Live):** expires an entry after a set age. It is often combined with LRU or LFU.

EnggFeed uses TTL only. In v1 it was 7 days. In v2 the generated summaries don't change once they are written, so they effectively never expire.

## The Takeaway

Where a cache lives decides what it can speed up: the browser for static files, a CDN for images and media, a shared cache like Redis for expensive results. How the application uses it decides what you trade away. Cache-aside is simple but leaves the first read slow. Read-through keeps the loading logic out of your code. Write-through keeps the cache and database in step at the cost of slower writes, and write-behind makes writes fast at the risk of losing data that hasn't been flushed.

> **Coming up next:** the common problems caching brings, from the cold start above to stampedes, stale data and hot keys, and how to fix each one.

## Resources

- [Caching for System Design Interviews, Hello Interview](https://www.hellointerview.com/learn/system-design/core-concepts/caching): the concepts in this post follow this article, and all of the diagrams in this post are redrawn from it
- [Storing and serving static files, Google App Engine docs](https://cloud.google.com/appengine/docs/standard/python3/serving-static-files)
