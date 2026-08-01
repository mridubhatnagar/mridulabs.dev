#import "@preview/basic-resume:0.2.9": *
#import "@preview/fontawesome:0.6.0": *

#let name = "Mridu Bhatnagar"
#let location = "Remote, India"
#let email = "mridubhatnagar4@gmail.com"
#let phone = "+91 8562851868"

#show: resume.with(
  author: name,
  location: location,
  email: email,
  phone: phone,
  accent-color: "#002366",
  font: "New Computer Modern",
  paper: "a4",
  author-position: left,
  personal-info-position: left,
  font-size: 9pt,
)

#v(-0.6em)
#fa-icon("github", font: "Font Awesome 6 Brands")
#link("https://github.com/mridubhatnagar")[mridubhatnagar]
#h(0.8em)
#fa-icon("linkedin", font: "Font Awesome 6 Brands")
#link("https://www.linkedin.com/in/mridu-bhatnagar-17703a92/")[mridu-bhatnagar]
#h(0.8em)
#fa-icon("globe", font: "Font Awesome 6 Free Solid")
#link("https://mridulabs.dev")[mridulabs.dev]
#v(-0.4em)

== Summary

Python Backend Developer with 7+ years of experience. I apply spec-driven development to AI systems and leverage contemporary agentic coding tools to amplify output. Looking forward to working at the intersection of product, engineering, and AI.

== Skills

- *Languages:* Python, JavaScript
- *Frameworks:* Flask, FastAPI
- *Databases:* PostgreSQL, MySQL, Google Datastore, Redis, Weaviate
- *Cloud / Deployment:* AWS EC2, Google Cloud Pub/Sub, Digital Ocean, GitHub Actions
- *Tools:* Git, Docker, Celery, Claude Code, Gemini CLI
- *API Integrations:* OpenAI, Claude API, Slack, Razorpay, WebEngage, Gmail
- *AI Engineering:* LLM Applications, Agents, Retrieval-Augmented Generation (RAG), LangGraph

== Work Experience

#work(
  title: "Senior Software Engineer",
  location: "Remote",
  company: "IIT Madras",
  dates: dates-helper(start-date: "Jul 2024", end-date: "Present"),
)
- Built student marks batch upsert via Google Pub/Sub to process 70,000–80,000 weekly score uploads in parallel.
- Built exam city preference module with validation and payment handling, serving 37,000+ students across 3 programs.
- Built JWT-based source verification (ES256) for cross-app access control, serving 40,000+ students.
- Refactored application form into a configurable multi-institute product; launched for IIMU with 1,000+ students.
- Migrated credentials to Secret Manager and Parameter Manager across multiple projects.

#work(
  title: "Senior Software Engineer",
  location: "Remote",
  company: "Peppo Technologies",
  dates: dates-helper(start-date: "Aug 2021", end-date: "Apr 2024"),
)
- Owned end-to-end development and maintenance of the settlement service, serving 76,000+ unique customers.
- Drove settlement success rate to 100% by reducing merchant escalations to zero.
- Added Celery-based async processing, handling peak loads of 8,000+ customers.
- Automated GST reporting and monthly invoice generation, reducing manual effort by 50%.

#work(
  title: "Independent Consultant",
  location: "Remote",
  company: "Team4Adventure",
  dates: dates-helper(start-date: "Jan 2020", end-date: "Jul 2021"),
)
- Built a JSON-based custom CMS replacing WordPress, delivering ~50% improvement in page creation speed.
- Built a Query & Booking Management system reducing per-booking processing time by 75%.

#work(
  title: "Software Engineer",
  location: "Gurugram",
  company: "Goibibo",
  dates: dates-helper(start-date: "Aug 2018", end-date: "Jan 2020"),
)
- Built and maintained API integrations for partners including Criteo and WebEngage.
- Automated data pipelines to generate daily reports, reducing manual effort.

#work(
  title: "Data Engineer",
  location: "Bangalore",
  company: "KreditBee",
  dates: dates-helper(start-date: "Dec 2017", end-date: "Aug 2018"),
)
- Designed APIs and core business logic for the product's rule engine.
- Integrated multiple external fintech partner APIs for data exchange.

#work(
  title: "Software Engineer",
  location: "Bangalore",
  company: "Reckonsys Tech Labs",
  dates: dates-helper(start-date: "Aug 2017", end-date: "Dec 2017"),
)
- Built backend features for Kredily using Django REST Framework.

== Projects

#project(
  name: link("https://prepit.mridulabs.dev")[Prepit],
  dates: "2026",
)
- RAG-based knowledge base for interview prep.

#project(
  name: link("https://github.com/mridubhatnagar/humaraCart")[HumaraCart],
  dates: "2026",
)
- Shared household cart agent on WhatsApp for Swiggy Instamart, built for Swiggy Builders Club.

== Education

#edu(
  institution: "NIIT University",
  location: "Neemrana, India",
  dates: dates-helper(start-date: "2013", end-date: "2017"),
  degree: "B.Tech, Computer Science and Engineering",
)

== Speaking & Content

Courses on LinkedIn Learning · Tutorials on Twilio blog and egghead.io · Talks at PyData, EuroPython, PyLadies.
