# Portfolio Project Notes

## Resume Setup

There are two resume files under `resume-typst/cobalt-cv/`:

- `main.typ` — includes phone number, used for direct job applications
- `main-public.typ` — no phone number, used for the public download on the website

When updating resume content, **keep both files in sync manually**.

Also keep these in sync with the web versions:
- `src/pages/resume.astro` — web resume page
- `src/pages/index.astro` — homepage skills section

## Compile Commands

```bash
# Job application version (with phone)
typst compile resume-typst/cobalt-cv/main.typ resume-typst/cobalt-cv/mridu-cobalt-cv.pdf

# Public website version (no phone)
typst compile resume-typst/cobalt-cv/main-public.typ public/mridu-bhatnagar-resume.pdf
```

## Future Ideas

- `resume-single-source.md` — plan for a single YAML source of truth that feeds both the website and PDF resume
