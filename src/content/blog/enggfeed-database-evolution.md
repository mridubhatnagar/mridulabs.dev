---
title: "RSS Meets LLM: Reviving Engineering Feed (Part 2)"
date: 2026-09-02
description: "Database Migrations done over the course of building EnggFeed"
tags: ["Postgres", "Database Design", "Migrations", "EnggFeed"]
---

> Part 2 of a 4-part series on how EnggFeed, an RSS + LLM engineering blog aggregator, is built. [Part 1](/blog/enggfeed-how-its-built) covered how it's built.

<div class="video-embed">
<iframe src="https://www.loom.com/embed/32201bf5a1ca4a348ad16acfc257be8f" title="EnggFeed database schema overview" allowfullscreen></iframe>
</div>

*Note: the video above shows all 13 tables together, the 10 live ones plus the 3 that were dropped along the way (`user`, `allowed_users`, `blog_chunk`). This isn't the schema at any single point in time, it's the full picture. Later migrations changed things from there, walked through below.*

While I was ideating on building enggfeed, the core premise was to build an engineering systems blog aggregator that runs on top
of RSS feeds. However, as the core involved making direct LLM calls, I decided to have a sign up with Google feature. Without Sign Up,
one can only browse the feed, filter by company. Once logged in, they can access pre-requisites, tags, summary, explain like I am 5 for each blog, and user feedback.

This led to the decision of having `user`, `allowed_users` tables. As this was Google sign up, I further wanted to make the users invite only, just to ensure no misuse. If a user's email is already present in the allowed_users email list, then the user gets added to the `user` table. 

All the blogs on the platform are parsed from RSS feeds of individual tech companies. Due to this, it was required to store the RSS feed links of each source. Added `blog_source` table for the same. It has `rss_feed_link`, `source`. For each item in the feed, we extract `guid`, `published_at`, `link`, `word_count`, `title`, `created_at`, `blog_source_id`, `thumbnail`. All these fields are stored in the `blog` table. `blog_source_id` is a foreign key referencing `blog_source.id`, tying each blog back to the source it was ingested from. In the initial design, I had added a `search` feature. For the same reason, the `blog_chunk` table was added with fields `blog_id`, `chunk_text`, `embedding`. 

Each blog will further have summary, simplify, prerequisites. So, `summary`, `simplify`, `prerequisite`, `tag`, `blog_tag`, `blog_prerequisite` were also part of the initial commit. 

The `blog` table to `summary` table has a 1:1 relationship. There can only be one summary associated with one blog. `summary` has the following fields `id`, `blog_id`, `content`, `created_at`, `updated_at`. `blog_id` is a foreign key referencing `blog.id`. The `blog` table to `simplify` table has a 1:1 relationship. Corresponding to each blog, there will be only one simplify, and `simplify.blog_id` is likewise a foreign key referencing `blog.id`. 

Each blog can have multiple prerequisites, each prerequisite can be present on multiple blogs. This resulted in a many-to-many relationship between `blog` and `prerequisite`. The `prerequisite` table has `id`, `created_at`, `updated_at`, `content`, `embedding`, `topic_name`.
Whenever there is a many-to-many relationship between 2 tables, as per database design fundamentals, there needs to be an intermediary table.
`blog_prerequisite` was created. `blog_prerequisite` stores `blog_id`, `prerequisite_id`, both foreign keys, referencing `blog.id` and `prerequisite.id` respectively, together forming the composite primary key. 

Similarly, one blog can have multiple tags, and a tag can be present on multiple blogs. This is a many-to-many relationship. Created an intermediary table, `blog_tag`. `blog_tag` stores `blog_id`, `tag_id`, both foreign keys, referencing `blog.id` and `tag.tag_id` respectively, together forming the composite primary key. [Initial migration](https://github.com/mridubhatnagar/enggfeed/blob/develop/alembic/versions/9770442d8622_initial.py) contained all these core tables. The `tag` table has
`tag_id`, `created_at`, `tag`, `embedding`.

On thinking and iterating further from a user's point of view, I realized that once blogs are aggregated on a platform, it is no longer a search problem. Given blogs from many companies, no one knows the blog titles beforehand, so what would they even type into a search box? It is a discovery problem instead. Due to this, in the [next migration](https://github.com/mridubhatnagar/enggfeed/blob/develop/alembic/versions/a1b2c3d4e5f6_drop_blog_chunk.py) `blog_chunk` table was dropped. 

As summary, simplify, tags, prerequisite, prerequisite_content are all LLM-dependent, there is always a likelihood of hallucination. To get human review on the AI generation, I decided to provide a feedback form. Later, this can also help improve the quality further. Due to this, the `feedback` table was added in the [next migration](https://github.com/mridubhatnagar/enggfeed/blob/develop/alembic/versions/bb8590add1d0_add_feedback_table.py). `Feedback` has `id`, `blog_id`, `user_id`, `type`, `content`, `created_at`. `blog_id` is a foreign key referencing `blog.id`, and at this point `user_id` was also a foreign key referencing `user.user_id`. Possible values of `type` are `tag`, `prerequisite`, `summary`, `simplify`. `type` is an enum.

I did the initial run locally. Things looked fine from a product point of view. I went ahead with deployment. I reached out to some of my friends, took their email ID. Added them as `allowed_users`. Only to find out later. They may have just browsed and dropped off. As money was at stake. I was still hesitant to remove auth fully, so to begin with I decided to [drop `allowed_users` table](https://github.com/mridubhatnagar/enggfeed/blob/develop/alembic/versions/9da7f10dbd4f_drop_allowed_users_table.py). This meant any user having a Gmail account can sign up.

Continued to run the project for some months. Only to realize that sign up is only adding friction. No sign ups. Took the call to drop the guards. [Remove `auth`](https://github.com/mridubhatnagar/enggfeed/blob/develop/alembic/versions/c2d9a4e1f3b7_drop_auth.py) from the platform. This led to dropping the `user` table and dropping `feedback.user_id`. Since there were no real sign-ups, there was no actual user data to worry about, so this was a clean break rather than a migration needing careful rollback or data-preservation handling.


The `user` table was helping in tracking who the feedback was by. As a workaround, added optional `name`, `email` fields in the [feedback table](https://github.com/mridubhatnagar/enggfeed/blob/develop/alembic/versions/d4e5f6a7b8c9_add_feedback_name_email.py) and form.
 

As features relying on the LLM were no longer gated, and articles were also aging out of the RSS feed's rolling window before an on-demand fetch could reach them, all LLM calls were moved to ingest time. Added the [`llm_usage` table](https://github.com/mridubhatnagar/enggfeed/blob/develop/alembic/versions/e5f6a7b8c9d0_add_llm_usage.py) for detailed cost analysis per blog, with fields `id`, `blog_id`, `call_type`, `provider`, `model`, `input_tokens`, `output_tokens`, `total_tokens`, `cost_usd`, `created_at`. `blog_id` is a foreign key referencing `blog.id`. Possible values of `call_type` are `tag_prerequisite_extraction`, `summary`, `simplify`, `tag_embedding`, `prerequisite_embedding`, `prerequisite_content`.

Seven migrations in: the `initial` migration created 11 tables covering auth, search, and every feature I could think of on day one. `user`, `allowed_users`, and `blog_chunk` were dropped along the way, and `feedback` and `llm_usage` were added later, landing at 10 tables today, all of them there because something is actually being used. Across the whole history, that's 13 distinct tables total, the 10 live ones plus the 3 dropped. Here's the current schema:

<a href="/blog/enggfeed-schema-diagram.svg" target="_blank" rel="noopener noreferrer">
  <img src="/blog/enggfeed-schema-diagram.svg" alt="EnggFeed database schema, showing the 10 live tables" />
</a>
<p style="text-align: center; font-size: 13px; color: var(--fg-faint); margin-top: -8px;">Click to view full size · <a href="https://github.com/mridubhatnagar/enggfeed/tree/develop/alembic/versions" target="_blank" rel="noopener noreferrer">browse all migrations on GitHub</a></p>

One design choice from the very first migration, keeping `blog.id` as an internal UUID separate from the RSS `guid`, ended up mattering more than expected. More on that in Part 3.

> **Coming up in Part 3:** the real bugs this schema ran into in production, and the tradeoffs (LLM cost, vector store choice, async ingest) that came out of fixing them.

## Resources

- [One-to-Many Relationship in Databases: A Complete Guide](https://www.datacamp.com/tutorial/one-to-many) (DataCamp)
- [Many to Many Relationships: A Guide to Database Design](https://www.datacamp.com/blog/many-to-many-relationship) (DataCamp)
- [SQL Foreign Key: Keep Your Database Relationships in Check](https://www.datacamp.com/tutorial/foreign-key) (DataCamp)
