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
    columns: (auto, auto, auto, auto),
    column-gutter: 1.2cm,
    align: center,
    [ #fa-icon("globe", font: "Font Awesome 6 Free Solid") #link("https://mridulabs.dev")[mridulabs.dev] ],
    [ #fa-icon("envelope", font: "Font Awesome 6 Free Solid") #link("mailto:mridubhatnagar4@gmail.com")[mridubhatnagar4\@gmail.com] ],
    [ #fa-icon("github", font: "Font Awesome 6 Brands") #link("https://github.com/mridubhatnagar")[github.com/mridubhatnagar] ],
    [ #fa-icon("linkedin", font: "Font Awesome 6 Brands") #link("https://www.linkedin.com/in/mridu-bhatnagar-17703a92/")[linkedin/mridu-bhatnagar] ],
  )
]

#line(length: 100%, stroke: accent)

#v(-0.4em)
I am a Python Backend Developer with 7+ years of experience. I apply spec-driven development to AI systems and leverage contemporary agentic coding tools to amplify output. Looking forward to working at the intersection of product, engineering, and AI.
#v(-0.4em)

#line(length: 100%, stroke: accent)
#v(-0.5em)

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
      ("B.Tech, Computer Science and Engineering",),
    )

    #line(stroke: (dash: "dashed", paint: accent), length: 90%)

    = #upper("Skills")

    #skill-category("Languages", ("Python", "JavaScript"))
    #skill-category("Frameworks", ("Flask", "FastAPI"))
    #skill-category("Databases", ("PostgreSQL", "MySQL", "Google Datastore", "Redis", "Weaviate"))
    #skill-category("Cloud / Deployment", ("AWS EC2", "Google Cloud Pub/Sub", "Digital Ocean", "GitHub Actions"))
    #skill-category("Tools", ("Git", "Docker", "Celery", "Claude Code", "Gemini CLI"))
    #skill-category("API Integrations", ("OpenAI", "Claude API", "Slack", "Razorpay", "WebEngage", "Gmail"))
    #skill-category("AI Engineering", ("LLM Applications", "Agents", "RAG Systems", "LangGraph"))

    #line(stroke: (dash: "dashed", paint: accent), length: 90%)

    = #upper("Projects")

    #project-entry(
      "Prepit",
      "https://www.linkedin.com/posts/mridu-bhatnagar-17703a92_i-built-a-rag-based-tool-prepit-for-solving-ugcPost-7441717523613523968-iqYY/?utm_source=share&utm_medium=member_desktop&rcm=ACoAABOVF2sB-8Qo07SL6ZD79cHZv1ttYAcOOsQ",
      [RAG-based knowledge base for interview prep. #link("https://github.com/mridubhatnagar/prepwise")[GitHub ↗]],
    )

    #project-entry(
      "HumaraCart",
      "https://www.youtube.com/watch?v=I2IFtHbkLng",
      [Shared household cart agent on WhatsApp for Swiggy Instamart, built for Swiggy Builders Club. #link("https://github.com/mridubhatnagar/humaraCart")[GitHub ↗]],
    )

    #line(stroke: (dash: "dashed", paint: accent), length: 90%)

    = #upper("Courses")
    #v(0.3em)

    - Authored a LinkedIn Learning course on Python Sets and Frozen Sets, later expanded with in-depth, hands-on exercises, reaching 6,799+ learners.

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
        [Built a JSON-based custom CMS replacing WordPress, delivering ~50% improvement in page creation speed.],
        [Built a Query & Booking Management system reducing per-booking processing time by 75%.],
      ),
    )

    #experience(
      "Goibibo",
      "Software Engineer",
      "Gurugram",
      "Aug 2018 – Jan 2020",
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

    #v(-0.3em)
    #line(length: 100%, stroke: accent)
    #v(-0.3em)

    = #upper("Conference Talks")
    #v(0.3em)

    #set list(spacing: 0.4em)
    - "#link("https://www.youtube.com/watch?v=Gb6sN7VYKog")[Building a Bot for WhatsApp using Python and Flask]" at Women Who Code (Virtual), 2020 (5.3k+ views).
    - "#link("https://www.youtube.com/watch?v=g5LNWqZw-yg")[Rest API Integration with Python]" at Women Who Code (Virtual), 2020 (4.2k+ views).
    - "#link("https://www.youtube.com/watch?v=1hy6YwsVZaU")[Automating Data Pipeline using Apache Airflow]" at PyData Delhi 2019 (2.8k+ views).
    - "#link("https://www.youtube.com/watch?v=UkUY6cVxlLY")[Object Internals in Python]" at EuroPython Conference (Virtual), 2020 (international conference).
    - "#link("https://www.youtube.com/watch?v=c295s11XCVo&t=4080s")[Memory address in Python]" at Remote Python Pizza Conference (Berlin), 2021 (international conference).
    - 4 additional talks at international Python community meetups.

  ],
)
