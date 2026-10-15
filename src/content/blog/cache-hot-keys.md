---
title: "Hot Keys: When One Cache Key Overloads One Node"
date: 2026-10-15
description: "What happens when one very popular key lands on one cache node, shown with an animation, and three ways to fix it: replicate the key, keep it in app memory, or cap the reads."
tags: ["Caching", "Hot Keys", "System Design", "Redis", "Backend"]
toc: true
---

> This post goes with an [interactive animation](/animations/cache-hot-keys). Step through it while you read, or open each scene from the links below.

[Caching 101](/blog/caching-101) covered where a cache lives and how to read and write through it. [The stampede post](/blog/cache-stampede-and-request-coalescing) covered one way a healthy cache goes wrong when a key expires. This post covers another: the cache is healthy, every read is a hit, and one node still falls over because of a single key.

<!-- toc -->

## The Problem: One Key, One Node

A large cache is split across several nodes. Assume each node is a separate server, with its own memory and its own network connection, so the nodes do not share capacity. Each key lives on one node, chosen by its hash, so that a normal day spreads requests out roughly evenly.

The animation below shows this. Three nodes, nine normal keys, and requests going to all of them. It loops through the scenes by itself.

<div class="animation-embed">
<iframe src="/animations/cache-hot-keys.html?embed#problem" title="Hot keys animation: the problem" loading="lazy"></iframe>
</div>
<p class="animation-caption"><a href="/animations/cache-hot-keys#problem">Open this part of the animation on its own page</a></p>

Now a post goes viral. In the animation it is `post:42`, and it lives on Node 2. Most of the reads are now for that one key, and a key lives on only one node, so most of the reads go to that one node. The other two nodes are mostly idle.

The numbers in the animation are in arbitrary units, not measurements. Each node can serve 8 reads per second and the app sends 14 reads per second in total. On a normal day that is fine, since each node sees a few reads per second. With 80% of the reads on the viral post, Node 2 is asked for about 11 reads per second, more than it can serve, and it is marked overloaded. The slider in the animation lets you change that share from 50% to 95%.

### The Other Keys Suffer Too

The overloaded node does not only slow down the viral key. It also holds `post:4`, `post:5` and `post:6`, and reads for those now wait behind the viral reads. In the animation they turn amber.

This is what makes a hot key awkward. The cluster has spare capacity, just not on this node. Adding more nodes does not help, because the hot key still lives on one of them.

## Fix 1: Replicate the Hot Key

Keep a copy of the hot key on every node and read a random copy. The same traffic now spreads across all three nodes, and none of them is overloaded. In the animation the copies appear as `post:42#0`, `post:42#1` and `post:42#2`.

<div class="animation-embed">
<iframe src="/animations/cache-hot-keys.html?embed#fix" title="Hot keys animation: replicate the key" loading="lazy"></iframe>
</div>
<p class="animation-caption"><a href="/animations/cache-hot-keys#fix">Open this part of the animation on its own page</a></p>

**The cost:** writes must reach every copy. If an update is written to only one copy, readers see different values depending on which copy they were sent to. In the animation, a write fans out to all three nodes. A write is now three operations instead of one, and the copies can disagree for a moment while those writes are in flight.

This works best for a key that is read far more often than it is written, and for a key you can identify. Someone, or something, has to decide which keys get copies.

## Fix 2: Keep It in the App's Memory

The second fix puts a small cache in front of the shared one. Each app server holds the hot value in its own memory for a short time. Most reads are answered there and never reach the cache node at all. This is the local fallback cache, or in-process cache, from Caching 101.

<div class="animation-embed">
<iframe src="/animations/cache-hot-keys.html?embed#local" title="Hot keys animation: keep it in app memory" loading="lazy"></iframe>
</div>
<p class="animation-caption"><a href="/animations/cache-hot-keys#local">Open this part of the animation on its own page</a></p>

The animation shows the share of reads answered in app memory, and the expiry bar on the value shows when the next read will go to the node again.

**The cost:** the value can be old. Each server refreshes on its own schedule. After an edit, one server can show the new value while another still shows the old one, until each runs out its timer.

The animation shows this in a second scene with two app servers and one cache node. When the post is edited, the node has the new version straight away, but each server keeps serving its own copy until its timer runs out. For a moment the two servers give different answers. The timer length is the trade-off: a longer one takes more load off the node and allows older values, a shorter one does the reverse.

## Fix 3: Cap the Reads for the Key

The third fix does not make the key cheaper to serve. It limits how many reads per second for that key are allowed to reach the node. In the animation the limit for `post:42` is 4 reads per second, and a gate sits in front of the node.

<div class="animation-embed">
<iframe src="/animations/cache-hot-keys.html?embed#limit" title="Hot keys animation: cap the reads" loading="lazy"></iframe>
</div>
<p class="animation-caption"><a href="/animations/cache-hot-keys#limit">Open this part of the animation on its own page</a></p>

**The cost:** reads over the limit are held back, and what they get is a design choice. A read over the limit could be:

- rejected with an error
- answered with a slightly old value from somewhere else
- answered with a default, such as an empty list
- made to wait

The animation just drops them and shows the percentage of reads that were over the limit. That is the point of this fix: the node survives, and you decide in advance which users get a worse answer.

## The Three Fixes Side by Side

| Fix | What it does | Trade-off |
|---|---|---|
| Replicate the key | Spreads the reads across the nodes | Copies can disagree for a moment |
| Keep it in app memory | Answers most reads in the app, so they never reach the node | The value can be a second or two old |
| Cap the reads for the key | Limits how many reads per second reach the node | Reads over the limit are held back, and what they get is a design choice |

None of them is free. Replication costs writes and consistency. App memory costs freshness. A cap costs some users a worse answer. The right one depends on what your data can tolerate: a view counter can be a second old without anyone noticing, while a price or a permission usually cannot.

They can also be combined, and often are. A small in-app cache takes most of the load, and a cap stops the rest from ever overwhelming the node.

## When to Apply Which

You don't need all three on day one, and you shouldn't wait to be hurt blind either.

**Do early, because it's cheap:**

- **Measure.** Track the load on each cache node and the reads per key. A hot key shows up as one node far busier than the others. Without this you find out from your users.
- **Handle the keys you can predict.** Some keys are hot by design, such as a homepage payload, a feature flag or a config value read on every request. Keeping those in app memory from the start costs a few lines.

**Wait for evidence, because it's costly:** replication and caps. Replication adds write fan-out and consistency questions, and a cap forces you to decide what a rejected read gets. You also can't predict which post goes viral, so building them for keys that never get hot is wasted work.

When you do see a node skewed, choose by what the value can tolerate:

- A value that can be a second or two old: keep it in app memory.
- A value that must stay fresh and is read far more than it is written: replicate it.
- A node that has to survive while you decide: cap the reads.

## Hot Keys and Stampedes

These two problems are related but not the same. A stampede happens at one moment, when a key expires and many requests miss it together. A hot key is a steady state: the key is always present, always hit, and always on one node. A hot key can also cause a stampede if it expires, and the fixes from the [stampede post](/blog/cache-stampede-and-request-coalescing) apply there too.

The animation is an illustration. It is not a benchmark, and the numbers in it were chosen to make the pattern visible.

## Resources

- [Hot keys animation](/animations/cache-hot-keys): the interactive version of this post
- [Caching 101: Where It Lives, How It Works, and Eviction Policies](/blog/caching-101): where a cache lives and the read and write patterns
- [Cache Stampede and Request Coalescing](/blog/cache-stampede-and-request-coalescing): what happens when a popular key expires
