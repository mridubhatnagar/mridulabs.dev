---
layout: "../layouts/ReadmeLayout.astro"
title: "Cook or Order · Swiggy Builders Club Brief"
---

# Cook or Order
### A one-screen clarifier for the most repeated decision in an Indian household

*Draft · 16 May, 2026*

---

## The Decision

Every evening, in every household, the same question repeats: *should I cook this tonight, or just order it?* Today this is a fuzzy, gut-feel decision. People underestimate cooking effort, overestimate ordering speed, and rarely see the two options laid side by side. The information needed to decide is split across two apps, Instamart (ingredients) and Food (prepared), and never reconciled.

Swiggy is the only platform where both signals (ingredient cost and prepared cost for the same dish at the same pincode) live behind one OAuth token.

---

## The Principle: Clarity, Not Verdict

The agent does not pick a side. No *"save ₹105 by cooking"*, no winning column, no recommendation language. It surfaces both options as honest artifacts (the cook panel shows *what you'd need*, the order panel shows *who you'd order from*) and lets the user's own intuition finish the decision.

Often the deciding moment is just *seeing* the ingredient list (*"actually, I have most of this"*) or *seeing* the restaurant list (*"oh, Punjab Grill is open tonight"*). The product's job is to make those artifacts legible, fast. The user is the judge.

---

## The Idea

User types or speaks a dish into WhatsApp. The bot replies with a deep link. Tap → a single card opens:

```
🍛 Paneer Butter Masala
─────────────────────────
COOK    ₹35  · 30 min
        Ingredients: paneer 200g · cream 100ml · kasuri methi
        Assumes: [onion ✓] [oil ✓] [tomato ✓] [garam masala ✓]
        ▶ Recipe short (0:58)
        [Add to Instamart →]
─────────────────────────
ORDER   [Fastest] [Cheapest] [Best Rated]
        Punjab Grill          ₹165  · 4.4★  · 30 min
        Saravana Bhavan       ₹140  · 4.2★  · 25 min
        Local Dhaba           ₹95   · 4.0★  · 22 min
        [Order on Food →]
─────────────────────────
(Friday, feel like going out? Spots on Dineout →)
```

Tap a pantry chip off → cook price updates. Tap the recipe short → embedded YouTube plays inline. Tap a sort tab on the order side → outlets re-rank by what matters in this moment (hungry now → Fastest, month-end → Cheapest, anniversary → Best Rated). Tap a restaurant → opens Food with that outlet's cart populated. The agent's job ends at the handoff.

Both panels are lightly interactive in symmetric ways: the cook side lets the user express *what they have*, the order side lets them express *what they care about right now*. Neither asks the user to read a verdict.

---

## Why Not a Chatbot

The output is comparative: two panels of structured information with multiple tappable affordances. That collapses badly in a chat thread; you cannot toggle pantry chips inside a WhatsApp bubble. So chat is used only for *capture* (the trigger), and the *answer* is a PWA card. Doorway, not canvas.

---

## Pantry Without a Pantry Tracker

Pricing the cook side honestly requires knowing what's already in the kitchen. But asking users to maintain a pantry list is its own friction trap.

The workaround: **assume a default Indian kitchen** (oil, salt, common spices, onion, garlic, ginger, tomato, atta) and surface the assumption transparently as chips. One tap removes a chip; the price updates. No persistent profile, no cold start.

V2 path is concrete: Instamart MCP exposes `your_go_to_items`, the user's actual frequent purchases. That replaces the heuristic with real history once the user has ordered through us a few times.

---

## The Weekend Nudge

The cook-vs-order binary is the product. But on Friday, Saturday, or Sunday, a small contextual nudge appears below the card: *"Weekend, feel like going out? Spots on Dineout →"*.

No price comparison, no offer claim (the MCPs don't expose live offers in a way we can rely on), no third column on the main card. Just a soft prompt sized to a different decision, only when the day suggests it might be wanted.

---

## Why Only on Swiggy

A generic GenAI builder cannot ship this. The product requires:

- Live prepared-dish pricing across nearby restaurants for the user's location → **Food MCP**
- Live ingredient pricing and 10-min deliverability for the same pincode → **Instamart MCP**
- One OAuth token across both
- Live Dineout availability for the weekend nudge → **Dineout MCP**

The cross-MCP shape is not rhetorical. It is load-bearing. Food and Instamart together carry the core card; Dineout adds the weekend layer.

---

## Surfaces

The same agent backend is exposed through two front doors.

**1. WhatsApp → PWA (the primary surface)**
User texts a dish to the bot. The bot replies with one line and a deep link. Tap → the PWA opens with the card rendered. WhatsApp solves discoverability (already in everyone's chat list, surfaces naturally after first use); the PWA owns the rich UI (pantry chips, tappable outlets, embedded recipe short). Chat is the doorway, not the canvas.

For the demo, the WhatsApp side uses **Twilio's sandbox**: no Meta Business verification, working number in minutes. Production graduates to a proper WhatsApp Business API provider; that is a V2 problem.

**2. Cook-or-Order as an MCP server**
AI-native users live inside Claude Desktop, ChatGPT, and Cursor. They will not install a PWA. So the same agent is also exposed as an MCP server, callable from any MCP-compatible client. One tool call (*"should I cook or order paneer tonight?"*) returns a structured markdown comparison with deep links to act on either side. We become a Swiggy-powered MCP that wraps Food + Instamart with a reasoning layer (dish parsing, pantry handling, cross-source comparison) on top.

This is a deliberately on-thesis move for the Builders Club: a product built on Swiggy MCPs that itself ships as an MCP. Same backend, two surfaces: visual for WhatsApp users, structured for agent users.

Tradeoff worth naming: the rich UI does not survive in chat. In MCP mode, pantry chips become *"I'll assume you have onion, oil, garam masala. Say if you don't"*; the recipe short becomes a link; outlet lists render as a markdown table. The PWA stays the demo-friendly artifact; the MCP stays the discoverability play.

---

## Swiggy MCP Usage

| MCP | Tool | Purpose |
|-----|------|---------|
| Food | `search_restaurants` | Find nearby outlets serving the dish |
| Food | `search_menu` | Pull dish-level pricing across those outlets |
| Food | `update_food_cart` | Populate the order cart on CTA tap |
| Instamart | `search_products` | Resolve ingredients to SKUs, get prices |
| Instamart | `update_cart` | Populate the cook cart on CTA tap |
| Instamart | `your_go_to_items` | V2: replace pantry defaults with user history |
| Dineout | `search_restaurants_dineout` | Weekend nudge: spots nearby on Fri/Sat/Sun |

**Outside Swiggy:** YouTube Data API for the recipe short. One search per cook query, embedded via standard iframe. No video hosting on our side.

---

## Tech Stack (Working)

| Layer | Choice |
|-------|--------|
| Backend | Python, FastAPI |
| Frontend | HTMX + Alpine.js (server-rendered fragments) |
| Agent Orchestration | LangGraph |
| MCP Client | Swiggy Food, Instamart, Dineout MCPs |
| MCP Server | FastMCP: exposes Cook-or-Order as a tool for Claude Desktop, ChatGPT, Cursor |
| Messaging | Twilio WhatsApp (sandbox for demo) |
| PWA shell | manifest.json + service worker |
| Cache | Redis (dish → ingredient mapping, dish → outlet results) |
| Hosting | DigitalOcean |

HTMX keeps the frontend lean: pantry chip toggles are a single fragment swap. The agent's flow is: dish parse → ingredient extraction → parallel MCP calls (Food outlets + Instamart SKUs) → render card. Single-turn, no multi-message conversation.

---

## What's Different from HumaraCart

HumaraCart was a household coordination layer over Instamart. This is a decision-support layer across Food + Instamart, narrowed to a binary the user actually faces every evening. The thesis shifts from *"shopping is a group activity"* to *"choosing what to eat is an information problem only Swiggy can solve."*

Both are valid. This one ships faster, has a sharper Swiggy-only moat, and demos in under 30 seconds.

---

## Open Questions

- Recipe → ingredient mapping: lean on an LLM with structured output, or precompute a corpus of common Indian dishes? LLM for V1; cache results in Redis to amortise.
- YouTube Short selection: top result by relevance, or filter by duration and channel quality? V1 takes top result.
- MCP-server auth: a Claude Desktop user has to authenticate with Swiggy through our server (we become an OAuth proxy). Doable with OAuth 2.1 PKCE, but adds a setup step worth designing carefully.
- Voice input: defer to V2. Text-only for the demo.
- Localisation: V1 is English; Hindi/regional voice is a V2 differentiator.

---

*Working draft. Not yet submitted.*
