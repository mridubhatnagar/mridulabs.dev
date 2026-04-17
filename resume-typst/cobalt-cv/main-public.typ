#import "@preview/fontawesome:0.6.0": *

// ─── Configuration ────────────────────────────────────────────────────────────
#let name         = "Mridu Bhatnagar"
#let accent       = rgb("#002366")
#let sidebar-fill = rgb("#eef0f5")
#let sans-font    = "Noto Sans"
#let serif-font   = "Noto Serif"
#let col-ratio    = (3fr, 7fr)
// ──────────────────────────────────────────────────────────────────────────────

#set document(title: [#name])
#set text(size: 9.5pt)
#show heading.where(level: 1): set text(font: sans-font, tracking: 0.1em, weight: 500, fill: accent)
#show heading.where(level: 2): set text(size: 11pt)

#set page(margin: (
  top: 0.8cm,
  left: 0.8cm,
  right: 0.8cm,
  bottom: 0.8cm,
))

// ─── Helper functions ─────────────────────────────────────────────────────────

#let resume-title() = text(
  font: serif-font,
  tracking: 0.1em,
  weight: 500,
  size: 26pt,
  fill: accent,
)[#name]

#let experience(
  company,
  role,
  location,
  dates,
  bullets,
) = [
  == #text(fill: accent)[#company]

  #grid(
    columns: (1fr, 1fr),
    align: (left, right),
    [ #emph[#role] ], [ #emph[#location | #dates] ],
  )

  #for bullet in bullets {
    [- #bullet]
  }
]

#let education(
  institution,
  location,
  dates,
  degrees,
) = [
  == #institution

  #location | #dates \
  #for degree in degrees {
    [ #text(weight: "bold")[#degree] \ ]
  }
]

#let skill-category(category, items) = [
  == #category

  #items.join(" | ")
]

#let project-entry(title, url, desc) = [
  == #link(url)[#title]

  #desc
]

// ─── Header ───────────────────────────────────────────────────────────────────

#align(center)[
  #resume-title()
  #set text(size: 9.5pt)
  #grid(
    columns: (1fr, 1fr, 1fr),
    align: center,
    [ #fa-icon("envelope", font: "Font Awesome 6 Free Solid") #link("mailto:mridubhatnagar4@gmail.com")[mridubhatnagar4\@gmail.com] ],
    [ #fa-icon("github", font: "Font Awesome 6 Brands") #link("https://github.com/mridubhatnagar")[github.com/mridubhatnagar] ],
    [ #fa-icon("linkedin", font: "Font Awesome 6 Brands") #link("https://www.linkedin.com/in/mridu-bhatnagar-17703a92/")[linkedin/mridu-bhatnagar] ],
  )
]

#line(length: 100%, stroke: accent)

I am a Python Backend Developer with 7+ years of experience. Beyond traditional backend engineering, I follow spec-driven development and am conversant with contemporary AI agentic coding tools. Looking forward to working at the intersection of product, engineering, and AI. Personal portfolio site at: #link("https://mridulabs.dev")[mridulabs.dev]

#line(length: 100%, stroke: accent)

// ─── Body ─────────────────────────────────────────────────────────────────────

#grid(
  columns: col-ratio,
  rows: auto,
  fill: (sidebar-fill, none),
  inset: 5pt,
  column-gutter: 0.5cm,
  [
    // ── Sidebar ──────────────────────────────────────────────────────────────

    = #upper("Education")

    #education(
      "NIIT University",
      "Neemrana, India",
      "2013 – 2017",
      ("B.Tech, Computer Science",),
    )

    #line(stroke: (dash: "dashed", paint: accent), length: 90%)

    = #upper("Skills")

    #skill-category("Languages", ("Python", "JavaScript"))
    #skill-category("Frameworks", ("Flask", "FastAPI"))
    #skill-category("Databases", ("PostgreSQL", "MySQL", "Redis", "Vector DBs"))
    #skill-category("Cloud", ("AWS EC2", "GCP Pub/Sub", "Digital Ocean", "GitHub Actions"))
    #skill-category("Tools", ("Git", "Docker", "Celery"))
    #skill-category("AI Engineering", ("LLM Apps", "Agents", "RAG Systems", "LangGraph", "OpenAI API", "Claude API"))

    #line(stroke: (dash: "dashed", paint: accent), length: 90%)

    = #upper("Projects")

    #project-entry(
      "Prepit",
      "https://prepit.mridulabs.dev",
      [RAG-based knowledge base for interview prep. #link("https://github.com/mridubhatnagar/prepwise")[GitHub ↗]],
    )

    #project-entry(
      "SystemsFeed",
      "https://enggfeed.mridulabs.dev",
      [Curated engineering content to keep you sharp. #link("https://github.com/mridubhatnagar/enggfeed")[GitHub ↗]],
    )

    #line(stroke: (dash: "dashed", paint: accent), length: 90%)

    = #upper("Speaking & Content")

    - Python courses on LinkedIn Learning
    - API tutorials for Twilio developer blog
    - Lessons on egghead.io
    - Spoke at PyData Delhi, EuroPython, PyLadies meetups

  ],
  [
    // ── Main content ─────────────────────────────────────────────────────────

    = #upper("Work Experience")

    #experience(
      "IIT Madras",
      "Senior Software Engineer",
      "Remote",
      "Jul 2024 – Present",
      (
        [Built student marks batch upsert via Google Pub/Sub to process 70,000–80,000 weekly score uploads in parallel.],
        [Built exam city preference module with validation and payment handling, serving 37,000+ students across 3 programs.],
        [Built JWT-based source verification (ES256) for cross-app access control, serving 40,000+ students.],
        [Refactored application form into a configurable multi-institute product; launched for IIMU with 1,000+ students.],
        [Migrated credentials to Secret Manager and Parameter Manager across multiple projects.],
      ),
    )

    #experience(
      "Peppo Technologies",
      "Senior Software Engineer",
      "Remote",
      "Aug 2021 – Apr 2024",
      (
        [Owned end-to-end development and maintenance of the settlement service, serving 76,000+ unique customers.],
        [Drove settlement success rate to 100% by reducing merchant escalations to zero.],
        [Added Celery-based async processing, handling peak loads of 8,000+ customers.],
        [Automated GST reporting and monthly invoice generation, reducing manual effort by 50%.],
      ),
    )

    #experience(
      "Team4Adventure",
      "Independent Consultant",
      "Remote",
      "Jan 2020 – Jul 2021",
      (
        [Built a JSON-based custom CRM replacing WordPress, delivering ~50% improvement in page creation speed.],
        [Built a Query & Booking Management system reducing per-booking processing time by 75%.],
      ),
    )

    #experience(
      "Goibibo",
      "Software Engineer",
      "Gurugram",
      "2018 – 2020",
      (
        [Built and maintained API integrations for partners including Criteo and WebEngage.],
        [Automated data pipelines to generate daily reports, reducing manual effort.],
      ),
    )

    #experience(
      "KreditBee",
      "Data Engineer",
      "Bangalore",
      "Dec 2017 – Aug 2018",
      (
        [Designed APIs and core business logic for the product's rule engine.],
        [Integrated multiple external fintech partner APIs for data exchange.],
      ),
    )

    #experience(
      "Reckonsys Tech Labs",
      "Software Engineer",
      "Bangalore",
      "Aug – Dec 2017",
      (
        [Built backend features for Kredily using Django REST Framework.],
      ),
    )

  ],
)

#line(length: 100%, stroke: accent)
