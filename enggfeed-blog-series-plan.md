# EnggFeed 4-part blog series

## Context

The user wants a new blog post on the portfolio's Engineering feed, based on a "how to make a backend project stand out" checklist: (1) show DB schema evolution via migrations and why, (2) a demo video on the README, (3) a Postman test collection, (4) documented challenges and how they were resolved, closing on the idea that engineering maturity shows through tradeoffs, not "it depends."

The project in question is `enggsystemfeed` (an engineering-blog RSS aggregator with LLM summaries/tags), which already has almost all of this material sitting in its docs and migration history — it just isn't written up. A companion talk, `RSS_Meets_LLMs_Talk.pptx` (in `doerstalks`), was given today, 2026-08-28, covering much of the same ground.

Through discussion, the single post idea got split into a 4-part series: schema evolution and challenges are each too dense to share a post, and the Postman collection (checklist item 3) earned its own part rather than a footnote, since it's a real artifact to be built in the `enggsystemfeed` repo, not just described. The demo video (item 2) stays deferred — the user will add it to Part 1 later.

**Everything factual in these posts must trace back to something actually verified in this session** — real migration files, real current controller/handler code (not the stale `docs/api_contracts.md`, which still describes deleted `/auth/*` routes), real `problems_solved.md` write-ups, the real deck content, and the real 11th Circuit case law found via web search for the copyright constraint. No invented metrics, quotes, or endpoints.

## Series structure & cross-linking

Four posts in `src/content/blog/`, using the existing collection schema as-is (`title`, `date`, `description` — no changes to `src/content/config.ts` needed, no changes to `[slug].astro`/`index.astro` needed, since tables/blockquotes/`.video-embed`/mermaid are already styled there).

Series linking is a **hand-written nav line** near the top of each post's body (consistent with how `humaracart-under-the-hood.md` hand-writes its talk-attribution `<div>` — no schema/frontmatter changes for "series" metadata), e.g.:

> Part 2 of 4 in a series on EnggFeed. [Part 1](/blog/enggfeed-how-its-built) · [Part 3](/blog/enggfeed-challenges-and-tradeoffs) · [Part 4](/blog/enggfeed-testing-the-api)

Files (slugs = filename minus `.md`):
- `src/content/blog/enggfeed-how-its-built.md` — date `2026-08-28`
- `src/content/blog/enggfeed-schema-evolution.md` — date `2026-08-31`
- `src/content/blog/enggfeed-challenges-and-tradeoffs.md` — date `2026-09-03`
- `src/content/blog/enggfeed-testing-the-api.md` — date `2026-09-06`

Also bump the "Updated [date]" stamp in `src/pages/now.astro` to 2026-08-28, per the project's CLAUDE.md rule that any website edit bumps that stamp.

## Part 1 — "How EnggFeed Is Built" (`enggfeed-how-its-built.md`)

- Frontmatter + `<div style="border-left...">` blockquote: "Given as a talk ... August 28, 2026" (mirror the exact styling used in `humaracart-under-the-hood.md`)
- Where the video goes: an HTML comment placeholder (`<!-- video: swap in .video-embed iframe once recorded -->`), not a visible "coming soon" line — keeps the public page clean until the user drops the real embed in
- Video content (~2 min target, user recording it themselves, final beat-by-beat check happens right before recording): (1) ~10s cold open, what EnggFeed is; (2) ~25s feed + filter, multi-select narrowing live; (3) ~20s Summary on one FULL-tier article; (4) ~15s ELI5/Simplify, same article; (5) ~30s prerequisite modal, primer → deep dive — most differentiated feature, gets the most room; (6) ~20s tier gating, a LIMITED card next to a FULL card side by side. **Not included:** Cloudflare Web Analytics (real, verified live — the beacon script with a real token is in `templates/index.html`/`summary.html`/`simplify.html` — but traffic is currently too low for a dashboard shot to read as "proof of usage" rather than the opposite; stays a text-only mention in the post, not a video beat) and LLM cost tracking / Arize Phoenix traces (dev-only observability, already covered narratively in Part 2's `add_llm_usage` migration)
- Series nav line: "Part 1 of 4." Since Parts 2-4 are written and published later (staggered dates below, per the user's instruction that only Part 1 is being done now), Part 1 cannot link forward to pages that don't exist yet without producing dead links. Write Part 1's nav line with no forward links today, then come back and add each link (Part 2, then Part 3, then Part 4) as that specific part is actually written and published — never link to a page before it exists
- `## ELI5: What's an RSS Feed?` — content from deck slide 2 (feed / item / reader definitions)
- `## Constraints` — deck slide 3, four points: no full-content storage, short/rolling feed windows, LLM calls cost money, content tiers gate features by available word count. The "no full-content storage" point states the reasoning in prose (courts have rejected the idea that RSS availability implies a license to republish) without inline links — points down to Resources
- Content tiers get their own short subsection under Constraints: the table (LIMITED < 150 words → Full Read only; PARTIAL 150-300 → + Summary/Tags; FULL 300+ → everything including ELI5/Simplify, from `product_decisions.md`/`constants.py`), plus the *logic* — since scraping the full article is ruled out and RSS feeds vary wildly in how much text they include, features scale with how much real content actually came through the feed (a summary of an 80-word excerpt would be mostly hallucination). State the exact 150/300 cutoffs as "the thresholds the app uses today," not as something rigorously derived — no documented rationale for those specific numbers exists in the repo, and none should be invented
- This point can cite a live-verified fact rather than just a docs claim: fetching the real Cloudflare feed (`blog.cloudflare.com/rss/`) in this session showed `<description>` as a 26-word teaser vs. `<content:encoded>` holding the full 2,371-word article on the same item; fetching Discord's feed (`discord.com/blog/rss.xml`) showed no `<content:encoded>` tag at all, only the short teaser — confirming feeds genuinely differ in how much real content they expose, which is the actual justification for tiering
- `## Architecture` — deck slide 4's two flows (read path: cache → Postgres, no LLM ever; ingest path: daily cron → LLM + embeddings → Postgres). Simple description, optionally a small mermaid diagram since the site already supports mermaid rendering in posts
- `## Resources` (closing section) — all 5 links from the copyright/RSS research, listed as a real citations section:
  - 11th Circuit: No Implied License for RSS Scraping (Plagiarism Today)
  - Subscription to RSS Feed Doesn't Trigger Implied-License Defense (Lexology)
  - Subscription to RSS Feed Doesn't Trigger Implied-License Defense (IP Update)
  - Implied Copyright Licenses in the Digital World (Mondaq)
  - Are RSS Feeds Copyrighted? (Aaron Hall, Attorney)

## Part 2 — "Schema Evolution" (`enggfeed-schema-evolution.md`)

Series nav line (Part 2 of 4) — link back to Part 1 (already published by then), no forward link to Part 3 until Part 3 actually exists (same rule as Part 1's nav, above). Short 1-2 line intro tying back to Part 1.

Walk the 7 real Alembic migrations **as a narrative**, in order, each with what changed and why (source: migration files + `docs/v1.1_features.md`, `docs/v1.2_features.md`, `docs/decided_next_steps.md`):
1. `initial` — starting schema, included a `blog_chunk` table for vector search
2. `drop_blog_chunk` — search removed entirely; tag/company filtering covered discovery better (cut a feature that seemed useful but wasn't)
3. `add_feedback_table` — user-reported content corrections
4. `drop_allowed_users_table` — opened signup from a manual allowlist to any Google account
5. `drop_auth` (the centerpiece) — deleted the entire `user` table and OAuth flow. Real reasoning: Google OAuth was stuck in Google Cloud Console's "Testing" publishing status, capped at 1 manually-added test user, and sign-in was never actually functioning as a cost/rate-limit gate (LLM calls were keyed to ingest-bounded entities like `blog_id`/`topic_name`, not arbitrary user input) — so a login flow nobody but the developer could use came out cleanly, migration included
6. `add_feedback_name_email` — feedback became anonymous once `user` was gone; rate limiting re-keyed to client IP
7. `add_llm_usage` — added per-call LLM cost tracking, after an untracked credit-burn incident

Mention, briefly, that this schema shape (UUID `blog.id` vs external `guid` used only for dedup) is also what fixed a real production bug — full story deferred to Part 3, with a link forward to it.

**Before writing:** verify current schema state directly from the model files (`blog/models.py`, `feedback/models.py`, `ingest/models.py`, etc. — not `docs/schema.md`, which is confirmed stale on `auth`/`user`) so the "current" side of the narrative is accurate, not just the "before" side from migrations.

**Schema diagram**: DBML for dbdiagram.io, 11 tables total (the `initial` migration's full set), grouped by concern (Ingest: `blog_source`, `blog` · LLM-generated content: `summary`, `simplify`, `prerequisite`, `blog_prerequisite`, `tag`, `blog_tag` · Supporting: `feedback`, `llm_usage`), with `user`, `allowed_users`, and `blog_chunk` shown as a distinct dropped group rather than omitted, so the diagram carries the "started broad, cut down" story visually. Per-table `Note`s do the "what is this" explaining so the video doesn't have to. Columns verified against the actual model files (`blog/models.py`, `feedback/models.py`, `ingest/models.py`, `prerequisites/models.py`, `simplify/models.py`, `summary/models.py`, `tags/models.py`), current live schema is 10 tables (11 minus the 3 dropped).

**Video (~2 min)**: narrates *relationships*, not a table-by-table read-through — why `blog_source` is separate from `blog`, why `tag`/`prerequisite` are many-to-many via join tables (and why `prerequisite.topic_name` is unique — generate once, reuse everywhere), why `summary`/`simplify` are separate rows instead of always-empty columns on `blog`, and the `feedback.user_id` relationship that existed then got severed. Drops (`user`, `allowed_users`, `blog_chunk`) are called out verbally during the walkthrough, not baked into a separate diagram state: `user`/`allowed_users` because auth was cut, `blog_chunk` for the separate reason that vector search was cut (tags/prerequisites covered discovery instead) — these are different reasons and shouldn't be conflated in the narration.

## Part 3 — "Challenges & Tradeoffs" (`enggfeed-challenges-and-tradeoffs.md`)

Series nav line (Part 3 of 4) — links back to Part 1 and Part 2 (both already published by then), same no-dead-links rule.

Four challenge write-ups, each as Symptom → Root cause → Fix → Lesson (condensed/adapted from `docs/problems_solved.md` into blog voice, not copy-pasted verbatim):
1. Tags silently empty for signed-in users — `blog.id` was the RSS `guid`, format varied by feed, broke the join. Cross-links back to Part 2's schema section.
2. RSS rolling-window 502s — summary/simplify fetched article content on-demand from the *live* feed, which only holds a rolling window; articles aged out and became permanently unreachable. Fixed by generating eagerly at ingest instead.
3. GitHub Actions reporting `504` while ingest had actually succeeded — synchronous endpoint colliding with the reverse-proxy timeout; decoupled via FastAPI `BackgroundTasks`, with the tradeoff that Actions' pass/fail no longer reflects real success (Sentry is now the source of truth).
4. "One topic, many labels" — LLM tag/prerequisite extraction never named the same concept the same way twice. Fixed via embedding + cosine-similarity normalization (0.88 threshold), tuned by hand-labeling real candidate pairs through an eval — moved agreement from 66% to 80% (deck slides 6-7).

Closing `## TL;DR: Tradeoffs`, framed as "no it depends" answers:
- Pay-per-read vs. pay-at-ingest for LLM calls (real numbers from deck slide 8 / `decided_next_steps.md` #1)
- pgvector vs. Qdrant for the vector store (`docs/tech_decisions.md`)
- FastAPI `BackgroundTasks` vs. a Celery/RQ queue for async ingest
- Removing auth entirely, reframed as a tradeoff (one fewer moving part vs. no per-user anything)
- Staying on GitHub Actions cron vs. AWS EventBridge Scheduler (`decided_next_steps.md` #6)

Series nav line at the end pointing forward to Part 4.

## Part 4 — "Testing the API" (`enggfeed-testing-the-api.md`)

Series nav line (Part 4 of 4, links back to Parts 1-3).

**This part requires building a real artifact first**, in the `enggsystemfeed` repo (not the portfolio repo): a Postman collection under a new `enggsystemfeed/postman/` directory, built directly against the current controller/handler code verified in this session (not the stale `docs/api_contracts.md`):

- `postman/EnggFeed.postman_collection.json` — folders for Blog Feed (list/paginate/filter, including the "unknown tag → empty result" edge case), Reference Data (sources, tags — asserting the documented count-descending order), Content (summary/simplify/prerequisite, chained off a real `blog_id` captured from the list call, covering tier-gating 403s and "not yet available" 404s), Feedback (valid submission, min-length 422, and the honeypot field from `decided_next_steps.md` #5 asserting silent-success), and Admin (`/api/v1/ingest` and `/api/v1/cost` — the 401 unauthorized cases safe to run freely, the real authenticated ingest call clearly flagged as costing real LLM money, not wired to auto-run)
- `postman/EnggFeed.postman_environment.json` — `base_url`, `ingest_secret`, `swagger_username`, `swagger_password` as empty placeholders, never committed with real values (same spirit as `.env.local`)
- A short new section in `enggsystemfeed/README.md` linking to the `postman/` folder, since the checklist item explicitly asks for this to be discoverable from the README

The blog post itself then walks through *why* it's built this way, not just that it exists — the chaining approach (why hardcoded UUIDs would be fragile against re-ingested/reset data), the honeypot test as a deliberate anti-spam assertion rather than an oversight, and the decision to flag-not-wire the paid ingest endpoint. Closes the series by tying back to the opening checklist: schema (Part 2), challenges (Part 3), and now verifiable behavior (Part 4) — the video (Part 1) is the one item still pending.

## Style rules (apply across all 4 files)

- No em-dashes anywhere in the prose (project convention)
- Don't open a bullet by repeating the section heading's word — let it continue the thought
- Match existing post conventions exactly: frontmatter shape, the talk-blockquote `<div>` markup, `.video-embed` class name (once the real video is added), tables for comparisons, `## ELI5: ...` heading style (as used in `humaracart-under-the-hood.md`)
- Every technical claim must be traceable to something read/verified in this session — if a docs file is known-stale (e.g. `api_contracts.md` on auth), don't source from it

## Status (2026-08-28)

Plan approved. Nothing written yet — user is drafting Part 1's text and recording its video themselves; my role is to edit/correct their draft once shared, not author it from scratch. Build **Part 1 only** to begin with; Parts 2-4 remain planned but untouched until each is separately greenlit.

## Verification

- `npm run dev` (or the project's actual dev script — confirm in `package.json`) and visually check all 4 posts render: series nav links resolve to the right slugs, tables/blockquote/mermaid (if used) render correctly in both light/dark theme, blog index (`/blog`) lists all 4 sorted by date with the staggered dates showing correctly
- Run the project's build/typecheck command to confirm no Astro content-collection schema errors
- For the Postman collection (Part 4): validate the JSON is well-formed, import it into Postman (or run via `newman` if available) against a locally running `enggsystemfeed` (`docker compose up -d`) to confirm every request and `pm.test` assertion actually passes against the real API — not just that the file parses
- Proofread pass for em-dashes and any claim not sourced from a verified file in this session
