# Microsoft Buildathon Ideas

Working notes. Project ideas that exercise LangChain + LangGraph + MCP, aligned with Microsoft's ecosystem (Microsoft 365, Azure, GitHub, Power Platform). Goal: a build that doubles as a personal tool and a portfolio piece.

## Filters applied to every idea

- Cross-MCP composition (more than one source, with reasoning that adds value over plain tool-calling).
- LangGraph branching that earns its keep (real conditional flows, not a linear pipeline).
- Daily personal use plausible (you'd still run it after the Buildathon).
- Demoable in under 60 seconds.
- Scope tight enough to actually ship in Buildathon timebox.

---

## 1. Microsoft 365 Personal-Ops Agent

**Pitch:** "Triage my morning." Agent over Outlook + Teams + OneDrive that parses overnight email, cross-references calendar, and outputs a prioritised day-brief.

**What it does:**
- Pulls unread Outlook email since last login.
- Classifies by type (meeting request, FYI, action needed, follow-up) with structured output.
- For meeting requests, checks calendar for conflicts, drafts a response.
- For action mail referencing files, fetches from OneDrive/SharePoint and summarises inline.
- Outputs one brief: "3 to act on, 2 to confirm, 1 to read."

**Microsoft alignment:** Pure Microsoft 365 via Graph API. Custom MCP server wraps Graph endpoints; Claude/Copilot Studio consumes it.

**LangChain/LangGraph fit:**
- LangGraph routes email by classified type into different subgraphs.
- LangChain primitives: structured-output classifier, prompt templates, tool wrappers over Graph API.
- Optional memory: which senders are important, learned over time.

**Personal use:** Daily, first thing in the morning.

---

## 2. Azure DevOps + GitHub Triage Agent

**Pitch:** "Status across my work." Unified view across Azure DevOps work items, GitHub PRs/issues, and Teams threads. Answers "what's blocked, what's waiting on me, what shipped this week."

**What it does:**
- Fetches assigned work items (Azure DevOps MCP).
- Cross-references with open PRs and review requests (GitHub MCP).
- Scans Teams threads for unresolved @-mentions.
- Returns a board grouped by status: blocked, waiting-on-me, in-review, shipped.

**Microsoft alignment:** Azure DevOps is Microsoft-native; GitHub is Microsoft-owned. Both have or are getting MCPs.

**LangChain/LangGraph fit:**
- Parallel fan-out to all three sources.
- Conditional flow: if work item references a PR, fetch it; if PR is stalled, identify the blocker.
- Synthesis node groups by topic, not by source.

**Personal use:** Daily standup prep.

---

## 3. Teams Meeting Follow-Up Agent

**Pitch:** "What did I miss, what do I owe." Reads Teams meeting transcripts, extracts decisions and action items, drafts follow-ups in Outlook/Planner with human-in-the-loop confirmation before sending.

**What it does:**
- Pulls recent Teams meeting transcripts.
- Extracts decisions, action items, owners, deadlines.
- For each item, drafts a follow-up (Outlook email, Planner task, or calendar reminder).
- Shows the batch to user for confirmation before any external action.

**Microsoft alignment:** Teams + Outlook + Planner via Graph API. Heavily Microsoft-native.

**LangChain/LangGraph fit:**
- Structured-output extraction from transcripts.
- Real LangGraph `interrupt()` use case (human checkpoint before send).
- Branching by action type (email vs task vs calendar).

**Personal use:** Variable, depends on meeting load.

---

## 4. SharePoint Knowledge Agent (RAG flavour)

**Pitch:** "Ask my company's docs, with Outlook context." RAG over SharePoint, with recent Outlook threads as disambiguating context.

**What it does:**
- Indexes a SharePoint site/collection into a local vector store.
- On query, retrieves relevant docs and synthesises.
- Uses recent Outlook threads to resolve references ("when X mentioned the deployment plan, which doc?").

**Microsoft alignment:** SharePoint + Outlook + Graph API.

**LangChain/LangGraph fit:**
- Classic LangChain RAG stack: document loaders, embeddings, vector store, retriever. Fills the gap that the Swiggy project skipped.
- LangGraph for query routing (RAG vs Outlook lookup vs both).

**Personal use:** Depends on whether you have a SharePoint corpus you actually use.

---

## Filter check

| Idea | Cross-MCP | LangGraph earns | Daily personal use | Demo in 60s |
|------|-----------|------------------|---------------------|-------------|
| 1. M365 Personal-Ops | Outlook + Teams + OneDrive | Yes | Yes | Yes |
| 2. DevOps Triage | Azure DevOps + GitHub + Teams | Medium | Daily for devs | Yes |
| 3. Meeting Follow-Up | Teams + Outlook + Planner | Yes (interrupt) | Variable | Yes |
| 4. SharePoint Knowledge | SharePoint + Outlook | Lighter | Depends on corpus | Yes |

**Strongest candidate by filters:** Idea 1 (M365 Personal-Ops Agent). Idea 3 is the strongest LangGraph showcase if human-in-the-loop is judged favourably.

---

## Open questions before committing

- What's the Buildathon's stated theme or required stack? Some require Azure OpenAI, Copilot Studio, or Power Platform specifically; confirm before designing.
- Is a custom MCP server expected, or just MCP client usage from Copilot Studio / Claude Desktop?
- Submission format: code, video demo, written narrative, live presentation?
- Solo or team?
- Timebox: how many days from kickoff to submission?

These answers will narrow the four ideas to one quickly.
