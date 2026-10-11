---
title: "Cache Stampede and Request Coalescing: A Demo with 30 Users"
date: 2026-10-11
description: "What happens when a popular cache key expires under load, shown with a small demo: 30 identical database queries without a fix, one with request coalescing."
tags: ["Caching", "Cache Stampede", "System Design", "Redis", "Backend"]
toc: true
---

> This post expands on a talk I gave on October 7, 2026, on one caching problem, cache stampede, and one fix, request coalescing.

[Caching 101](/blog/caching-101) covered where a cache lives and how to read and write through it. This post looks at one way caching goes wrong and shows it happening. I built a small demo where a popular cache key expires while 30 users are hitting it, recorded what the database saw, and then ran the same load again with a fix in place. Only the fix changes between the two runs.

<!-- toc -->

## The Problem: A Key Goes Missing

While a key exists in the cache, every request is a hit and comes back in a few milliseconds. The trouble starts the moment the key expires. Every request that arrives before anyone has put a new value back misses, and with cache-aside each one decides on its own to go to the database and rebuild the same entry.

![Cache stampede: many clients miss the cache after the key expires, so N identical queries hit the database at once](/blog/stampede-problem.png)

The slower the query, the longer the window in which new requests keep arriving, and the bigger the pile. One query on its own takes about 0.3 seconds in this demo. Thirty of them at once are a different story, as the numbers below show.

## The Demo Setup

The setup is the same for both runs.

- **Data:** 1,000 posts and 5,000,000 view rows, one row per view, with no index. The data is synthetic. The point is the cost of recomputing, not the content.
- **Query:** the top 10 posts by views in the last 24 hours.
- **Cache:** Redis, outside the app, using cache-aside with a 20 second TTL.
- **Load:** Locust with 30 users, each sending about 1 request per second to a single `/trending` endpoint.

These are numbers from a laptop demo, not production figures. They are from October 2026 and will change with hardware, data size and software versions, so read them as an illustration of the pattern, not as benchmarks. The pattern itself, many requests missing one expired key at once, does not depend on these numbers.

## Without a Fix

In the first run the cache is warm and the log is a stream of cache hits. Then the key expires, and the log shows a block of cache misses followed by a block of database queries, one per user. After that come the responses, each with the seconds that user waited.

<div class="video-embed">
<iframe src="https://www.youtube.com/embed/Q3-VDIwWtfU" title="Cache stampede demo without a fix" allowfullscreen></iframe>
</div>

Here is what Locust recorded for this run, 8,035 requests with 0 failures.

![Locust statistics without a fix: median 5 ms, 99th percentile 8100 ms, max 9058 ms](/blog/stampede-locust-stats-no-fix.png)

The median is 5 ms, because most requests are hits. The 99th percentile is 8,100 ms and the slowest request took about 9 seconds. Those are the requests that landed on an expired key. I looked at the 99th percentile and the max instead of the 95th, because the 95th changes with the length of the run.

The charts show the same thing over time.

![Locust response times without a fix: the 95th percentile climbs to about 8,000 ms at each expiry, on an axis that goes to 10,000 ms](/blog/stampede-locust-charts-no-fix.png)

**Note the response-time axis: it goes up to 10,000 ms.** Requests per second dip while users are stuck waiting, and the 95th percentile line climbs at each expiry. The spike lags the log flood a little, because Locust records a request when it finishes, not when it starts. The user count stays flat at 30 throughout, so the dips come from the stampede and not from a change in load.

## The Fix: Request Coalescing

The idea is that the key only needs to be rebuilt once, not once for every person who asked.

![Request coalescing: one leader request recomputes the value while requests 2 to N wait on the same result, so the database sees one query](/blog/stampede-coalescing.png)

On a miss, the app checks an in-flight map, which holds the key and the query that is already running for it. A request either joins the running query or, if there isn't one, starts it and becomes the leader. The leader runs the query, fills the cache, removes its entry from the map and wakes the waiters. Everyone else gets the leader's result. This is also called single-flight.

The first request still has to hit the database, because someone has to rebuild the value. What changes is what the requests after it do. They see that a rebuild is already running, so they wait for it instead of starting their own query.

How do the later requests know the first one is already querying the database? They need something that says a rebuild is in progress. One way is a second key in the cache, next to the cached value. It holds no data. It is only a marker.

| Key | Holds | Purpose |
|---|---|---|
| `trending` | the top 10 posts | the cached value that users read |
| `trending:rebuilding` | a flag, say `1` | says someone is already querying the database for this |

After `trending` expires, it works like this:

1. The first request misses `trending`, sets `trending:rebuilding` and queries the database. It is the leader.
2. Requests 2 to N miss `trending` and check `trending:rebuilding`. They find it, so they wait instead of querying.
3. The leader writes `trending` and deletes `trending:rebuilding`.
4. The waiting requests read the new value stored under `trending`.

In the diagram above, the in-flight map plays the role of that marker.

## With Request Coalescing

The second run uses the same data, the same cache and the same load. After the key expires, the log shows one database query. The other users show as waiting and then receive a shared response.

<div class="video-embed">
<iframe src="https://www.youtube.com/embed/awJbbNWtDd4" title="Cache stampede demo with request coalescing" allowfullscreen></iframe>
</div>

![Locust statistics with coalescing: median 4 ms, 99th percentile 59 ms, max 307 ms](/blog/stampede-locust-stats-coalescing.png)

This run was 10,681 requests, again with 0 failures. The median is 4 ms, the 99th percentile is 59 ms and the max is 307 ms, down from about 9 seconds.

![Locust response times with coalescing: the 95th percentile stays between about 3 and 13 ms, on an axis that goes to 15 ms](/blog/stampede-locust-charts-coalescing.png)

**Check the axis again:** **this one goes up to 15 ms, not 10,000.** Requests per second stay flat at about 30 and the 95th percentile stays between about 3 and 13 ms. These charts are from a longer run of about 15 minutes, while the stampede charts above are from a shorter one, so the time axes differ.

## The Cause and the Takeaway

Counting the database queries at a single expiry makes the difference plain.

| | Without a fix | With coalescing |
|---|---|---|
| DB queries at one expiry (30 users) | 30 | 1 |

The key needs to be rebuilt once, not once for every person who asked.

One more thing to build in: waiters need a timeout in case the leader is slow. In the demo a waiter gives up after 60 seconds and runs the query itself.

> **Coming up next:** the other fixes for common caching problems, such as cache consistency and hot keys.

## Resources

- [Caching 101: Where It Lives, How It Works, and Eviction Policies](/blog/caching-101): the earlier post, covering where a cache lives and the read and write patterns
