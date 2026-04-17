# Idea: Single Source of Truth for Resume

## Problem
Currently resume content lives in three places:
- `src/pages/resume.astro` — web version
- `src/pages/index.astro` — homepage skills section
- `resume-typst/cobalt-cv/main.typ` — PDF version

Any update needs to be made in all three manually.

## Goal
One file to edit. One command to sync both the website and the PDF.

## Proposed Approach

### 1. Single data file
Create `resume.yaml` (or `resume.toml`) as the single source of truth.
Contains all resume content — experience, skills, education, projects, speaking.

### 2. Website
Update `resume.astro` and `index.astro` to read directly from `resume.yaml`
using Astro's built-in YAML import or a content collection.

### 3. PDF
Write a script (`generate-typst.js` or `generate-typst.py`) that reads `resume.yaml`
and outputs a valid `main.typ` file for cobalt-cv.
Run `typst compile` after to get the PDF.

### 4. Single command
Add an npm script or Makefile target:
```bash
make resume
# or
npm run resume
```
This runs the generator script + typst compile in one shot.

## Steps
1. Define the YAML schema for all resume sections
2. Update resume.astro to render from YAML
3. Update index.astro skills section to read from YAML
4. Write the Typst generator script
5. Wire up a single command
6. Test both outputs match

## Notes
- Trickiest part: generating valid Typst syntax from the script without breaking the cobalt-cv layout
- Astro supports YAML imports natively — no extra dependencies needed for the web side
- Generator script can be a simple Node.js or Python script
