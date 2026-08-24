---
title: "HumaraCart: Under the Hood"
date: 2026-08-24
description: "Coordination over WhatsApp, and how it actually talks to Instamart: the messaging layer, MCP, and the agent loop behind HumaraCart V2."
---

<div style="border-left: 2px solid var(--border-link); padding-left: 14px; margin: 0 0 24px; font-size: 13px; font-style: italic; color: var(--fg-faint);">
Given as a <a href="https://docs.google.com/presentation/d/1eCxIlt8fITcELrhaQE3mrJfm080p1cv7/edit?usp=sharing&ouid=101927937821898304665&rtpof=true&sd=true" target="_blank" rel="noopener noreferrer">talk</a> at a weekly virtual tech meetup, August 24, 2026.
</div>

HumaraCart is a WhatsApp bot that lets a household share one Instamart cart. Anyone in the house can say "add milk" and it lands in a cart the account holder eventually checks out. I've written about <a href="/swiggy-builders-club-application" target="_blank" rel="noopener noreferrer">the idea and V1</a> before. This talk was about the parts V1 didn't cover: how the messaging layer actually works around a WhatsApp limitation, and how the agent talks to Instamart underneath.

## WhatsApp Doesn't Support Group Bots

What you'd expect: one WhatsApp group, everyone in it, talking to one bot together.

What we built instead: N separate 1:1 threads with the bot. The backend maps each thread to a single household ID, so every member is really writing into one shared cart, they just can't see each other doing it in a group window.

The WhatsApp Business API terms forbid group bots, so "household" only exists as a backend concept. WhatsApp itself has no idea these threads are related.

## Roles & Permissions

| | Member | Account Holder |
|---|---|---|
| Add items to the cart | ✓ | ✓ |
| Remove items from the cart | ✓ | ✓ |
| Nudge the holder to check out | ✓ | |
| Set the delivery address | | ✓ |
| Confirm checkout & choose payment method | | ✓ |

Checkout stays a single-person action on purpose. Anyone can fill the cart; only one person commits it.

## ELI5: What Is MCP?

**<a href="https://modelcontextprotocol.io" target="_blank" rel="noopener noreferrer">MCP</a>** is an open standard that lets an AI agent call external tools in a consistent way, regardless of who built them.

**Tool** is a single callable function a server exposes, with defined inputs and outputs, e.g. `search_products`.

**MCP Client** is the agent side. It discovers what tools are available and calls them. This is HumaraCart's role, and it's the same role Claude, ChatGPT, and Claude Code play when they connect out to an MCP server.

**MCP Server** is the provider side. It exposes a set of tools over the protocol. This is what Instamart runs, alongside other MCP servers like Swiggy's and Cleartrip's.

## Where HumaraCart Sits

```mermaid
flowchart LR
    HC["HumaraCart<br/>Agent: the MCP Client"]:::node --> MCP((MCP)):::mcp
    MCP --> Inst["Instamart<br/>Backend: the MCP Server"]:::node
    Inst --> MCP
    MCP --> HC

    classDef node fill:var(--border),stroke:var(--border-link),color:var(--fg-strong)
    classDef mcp fill:transparent,stroke:var(--border-link),color:var(--fg-strong)
    click MCP "https://mcp.swiggy.com/builders/docs/reference/instamart" "Swiggy Instamart MCP reference" _blank
```

HumaraCart is the agent, playing MCP Client. Instamart's backend is the MCP Server. HumaraCart never talks to Instamart directly: every call and every result crosses that one standard interface.

## The Agentic Part: LangGraph + Human-in-the-Loop

The agent runs as a small graph:

```mermaid
flowchart LR
    START(["START"]):::endpoint --> agent["agent<br/>calls the LLM, decides next step"]:::node
    agent --> tools["tools<br/>calls Instamart MCP"]:::node
    tools --> agent
    tools --> ask_human["ask_human<br/>pauses the graph for a person"]:::human
    ask_human -. "checkout confirmed" .-> tools
    ask_human --> agent
    agent --> END(["END"]):::endpoint

    classDef node fill:var(--border),stroke:var(--border-link),color:var(--fg-strong)
    classDef human fill:var(--fg-strong),stroke:var(--fg-strong),color:var(--bg)
    classDef endpoint fill:transparent,stroke:var(--border-link),color:var(--fg-strong)
```

- **agent** node calls the LLM and decides the next step.
- **tools** node calls the Instamart MCP server.
- **ask_human** node pauses the graph for a person.

Each household has one LangGraph `thread_id`. `thread_id` is an internal LangGraph concept, and it's what saves and loads the graph's saved state. After each interrupt, once the user gives a response, the graph resumes from that same node.

`tools` is what actually triggers a pause, for exactly two things: picking a variant when a search returns more than one match (returns to `agent` once picked), and confirming a checkout (returns to `tools`, dashed, once confirmed). The first checkout call only previews what would be ordered; the real order is placed by that second, code-issued call back into `tools`, not by the LLM deciding on its own to commit money.

## What HumaraCart Actually Calls

The Instamart MCP toolbox HumaraCart uses, grouped by what it's for:

- **Discover:** `get_addresses`, `search_products`
- **Cart:** `update_cart`, `get_cart`, `clear_cart`
- **Payment:** `get_payment_options`
- **Order:** `checkout`
- **Track:** `get_orders`

The full reference lives at <a href="https://mcp.swiggy.com/builders/docs/reference/instamart" target="_blank" rel="noopener noreferrer">mcp.swiggy.com/builders/docs/reference/instamart</a>.

## What Was Hard

A few things that were genuinely hard to get right, most of them only showing up once real concurrent usage started:

**Wrong person could answer a pending question.** A race in who a paused `ask_human` question was actually addressed to, since multiple members can be typing into the same household at once.

**Concurrent messages could race on the same session.** Two messages for one household hitting the agent at the same time, both trying to mutate the same cart state.

**Sync vs. async for the background handler.** Every message triggers a slow LLM call and an MCP round-trip, so whether the handler should be sync or async was a real, open question.

**Interrupt as its own node, or folded into `tools`?** Whether `ask_human` should be a separate node the graph routes through, or just logic inside the `tools` node that pauses partway through a call.

## Glossary

**Node:** a single step in the graph. The `agent` node calls the LLM, the `tools` node calls Instamart's MCP tools, the `ask_human` node pauses for a person.

**Edge:** the connection that decides what runs next after a node finishes. Most of HumaraCart's edges are conditional, not fixed: the agent's own decision, or whether a tool call needs a human, determines which node fires next.

**Interrupt:** LangGraph's mechanism for pausing a run mid-graph and waiting on something outside the graph, in this case a person. `ask_human` is built on an interrupt: the graph's state is saved, control returns to the caller, and the graph resumes from that exact point once an answer comes back.

**thread_id:** the key LangGraph uses to save and load a graph's state. Each household has exactly one, so its cart-building conversation always resumes from where it paused, no matter which member's message triggers the next run.

