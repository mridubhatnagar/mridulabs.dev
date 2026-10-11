---
name: write-technical-blog
description: Turn a talk deck (.pptx) into a technical blog post in src/content/blog, following the structure of the existing posts. Use when the user wants to write a blog post from a talk.
---

Write a blog post from a talk deck. Keep replies short. Do not commit.

## 1. Ask first (one message, all questions together)

Talk decks live in `/home/mridu/personal/doerstalks`. List the `.pptx` files there (and any `*_diagrams` folders or `.excalidraw` files) and ask which one to use. Do not read or write anything else until the user answers.

Ask in the same message:

- Date the talk was given.
- YouTube link for a video, if there is one.
- Slides or topics to skip.
- Real examples from their own work for each concept. Say which concepts have none.
- Where the diagrams or content came from (own work, or redrawn from a source), so it can be credited.
- One post or a series.

## 2. Read

- Extract slide text and speaker notes with python-pptx. If diagrams are .excalidraw, pull out the embedded images and look at them.
- Read the two most recent posts in `src/content/blog` to match format and voice.
- If an example refers to the user's own project, check the code or docs before stating details.

## 3. Propose an outline and wait for approval

List the sections, which diagram goes where, and which real example goes where. Do not draft until the user approves.

## 4. Draft `src/content/blog/<slug>.md`

Use the same structure as the older posts:

1. Frontmatter: `title`, `date` (today), `description`, `tags`, `toc: true`.
2. A blockquote that references the talk, e.g. `> This post expands on a talk I gave on <Month D, YYYY>, on <topic>.` One sentence, nothing more.
3. Intro paragraph, first person, with real numbers only if the user gave them.
4. `<!-- toc -->`
5. Video embed if there is a link, after the toc:
   `<div class="video-embed">` / `<iframe src="https://www.youtube.com/embed/<id>" title="..." allowfullscreen></iframe>` / `</div>`
6. `##` sections with `###` per concept. Each diagram goes right under its concept as `![alt text](/blog/<topic>-<name>.png)`, with files copied to `public/blog/`.
7. A short takeaway section if it fits.
8. If a follow-up post is planned, a closing blockquote: `> **Coming up next:** ...`
9. `## Resources` with links. Credit any source the diagrams or concepts came from, and say so plainly (e.g. "all of the diagrams in this post are redrawn from it").

## Rules

- Use only facts the user supplied or that you verified in code or docs. Never invent examples, numbers or causes. If a concept has no real example, give a plain explanation.
- Do not use em-dashes anywhere.
- A bullet must not restart with the same word as its section heading.
- Say when something is rough or from memory (e.g. response times).
- Do not name employers or internal apps for work examples.
- Redrawn diagrams are still derivative work. Flag the copyright risk once and suggest asking permission or redrawing.

## 5. Finish

- Bump the "Updated" date in `src/pages/now.astro` to today.
- Run `npx astro build` and confirm it succeeds.
- Check the post has no em-dashes.
- Report what changed in a few lines. Do not commit; the user pushes.
