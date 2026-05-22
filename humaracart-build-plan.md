# HumaraCart Build Plan

Working build plan for HumaraCart V1. References `src/pages/swiggy-builders-club-application.md` as the source of truth for product scope; this file captures implementation decisions made during design.

## V1 definition of done

- Account holder links Instamart via OAuth and creates a household over Twilio Sandbox WhatsApp.
- Up to 3 helpers can join via the invite link and message the bot.
- Add / remove / change / show list / freeze cart / ready to order commands work end-to-end. Brand is silently picked from a hardcoded defaults map (overridable via `change`); quantity defaults to 1 (overridable via `change`). No multi-turn disambiguation in V1.
- On freeze, the backend calls Instamart `update_cart` once, and the account holder receives a confirmation message with the cart summary.
- All commands are parsed by LangChain structured-output intent classification (not regex), so natural-language variants like *"milk please"* or *"drop the detergent"* work.
- A 60-90 second demo video can be recorded following the script in `humaracart-demo-plan.md`.

## Tech stack (updated from application file)

| Layer | Choice |
|-------|--------|
| Backend | Python, FastAPI |
| Intent classification | LangChain (`with_structured_output` + Pydantic) |
| Agent orchestration | LangGraph |
| MCP client | Swiggy Instamart MCP (sandbox first, production later) |
| Messaging | Twilio Sandbox for WhatsApp (V1); WhatsApp Business API (V2) |
| LLM | Claude Sonnet 4.6 (via `ChatAnthropic`) |
| Cache | Redis |
| Database | PostgreSQL |
| Observability | LangSmith |
| Hosting | Local for V1 (laptop + ngrok or cloudflared tunnelling the Twilio webhook); DigitalOcean for V2+ |

Change from the application file: **LangChain added as a distinct row alongside LangGraph.** The application currently only names LangGraph in the stack table.

## Intent schema

Single Pydantic model covers all V1 commands. The LLM parses every inbound message into this shape.

```python
from typing import Literal
from pydantic import BaseModel

class Intent(BaseModel):
    action: Literal[
        "add_item",
        "remove_item",
        "change_item",
        "show_list",
        "freeze_cart",
        "ready_to_order",
        "unknown",
    ]
    item: str | None = None
    qty: int | None = None                                           # for change_item: new qty
    brand: str | None = None                                         # for change_item: new brand
    item_category: Literal["packaged", "fresh", "unknown"] | None = None  # drives brand-resolution branch
    raw_message: str
```

If the message classifies as `unknown`, the bot replies with a short help message rather than guessing.

## State schema (LangGraph)

```python
from typing import TypedDict

class HumaraCartState(TypedDict):
    household_id: str
    member_id: str
    inbound_message: str
    parsed_intent: Intent | None
    cart: list[CartItem]
    brand_defaults: dict[str, str]  # item -> brand, loaded from brand_preferences
    outbound_messages: list[OutboundMessage]
    cart_frozen: bool
```

`cart`, `cart_frozen`, and `brand_defaults` are loaded from Redis at the start of every turn and persisted at the end. No cross-turn pending state in V1 (brands and quantities are decided silently or via explicit `change`).

## LangGraph topology

Nodes:

1. `load_context` - fetch household, member, cart state, and brand defaults from Redis (cold-start from Postgres if cache miss).
2. `classify_intent` - LangChain call producing an `Intent`.
3. `router` (conditional edge) - branches on `intent.action`.
4. `handle_add` - branch on `item_category`: if `packaged`, run brand-resolution (state.brand_defaults[item] → hardcoded defaults map → Instamart top-ranked deliverable SKU); if `fresh` or `unknown`, skip brand and pick top deliverable SKU directly. Default qty to 1; MCP `search_products`; append to cart; reply confirming what was added (with brand name and variant for transparency).
5. `handle_remove` - remove item from cart; reply confirming.
6. `handle_change` - update brand or qty for an existing cart item; if brand changed, persist new preference to `brand_preferences` for future adds.
7. `handle_show` - format and broadcast the list to opted-in members.
8. `handle_freeze` - lock cart, MCP `update_cart`, broadcast frozen notification.
9. `handle_ready_to_order` - nudge account holder.
10. `persist` - write cart, frozen flag, and any brand preference updates back to Redis + Postgres.
11. `send_outbound` - dispatch outbound messages to Twilio.

Conditional branching gives LangGraph its work: the router fans to seven handler subgraphs, each composes its own MCP and persistence steps. Cart state is mutated across nodes and persisted via the write-through store. No cross-turn pending state is needed in V1 since brand and quantity are decided silently or via explicit `change`.

## MCP tool wiring

Wrap Instamart MCP calls as LangChain `@tool` functions so they are usable inside any LangGraph node and traced cleanly by LangSmith:

- `search_products(query) -> list[Product]`
- `update_cart(items) -> CartConfirmation`
- `get_cart() -> Cart`
- `track_order(order_id) -> OrderStatus` (V2)
- `get_orders() -> list[Order]` (V2)

V1 only needs `search_products`, `update_cart`, `get_cart`.

## Storage layout

**Redis (hot path):**
- `household:{id}:cart` → JSON list of items
- `household:{id}:frozen` → boolean
- `household:{id}:pending:{member_id}` → JSON of pending disambiguation

**Postgres (durable):**
- `households (id, account_holder_id, address, created_at, oauth_token_encrypted)`
- `members (id, household_id, phone, joined_at)`
- `cart_history (id, household_id, items_json, frozen_at, instamart_cart_id)`
- `brand_preferences (id, household_id, item, brand)` - pre-seeded at household creation with a hardcoded common-Indian defaults map (milk → Amul, atta → Aashirvaad, oil → Fortune, etc.); updated whenever a member issues `change_item` with a new brand.

Write-through: every cart mutation hits both stores. Redis serves reads; Postgres is the source of truth on cold start.

## Build phases

1. **Skeleton** (1 weekend): FastAPI + Twilio Sandbox webhook + Redis + Postgres scaffolding. One hardcoded command (`add milk`) wired end-to-end to prove the loop.
2. **Intent classifier** (1 day): LangChain `with_structured_output` against the schema. Test with 20-30 message variants per intent.
3. **LangGraph topology** (1 weekend): all nodes wired, conditional routing across seven handler subgraphs, brand-default resolution and `change_item` override flow working in isolation.
4. **MCP integration** (1 weekend): Swiggy Instamart sandbox connected, `search_products` resolving real items, `update_cart` succeeding at freeze.
5. **Household + invite flow** (1 day): JWT invite tokens, OAuth setup, member joining.
6. **Polish + edge cases** (1-2 days): frozen-cart rejections, error messages, broadcast logic for opted-in members, OAuth token refresh.
7. **Demo recording** (half day): execute the demo plan with scrcpy + Loom.
8. **Video submission** (half day): light edit if needed, package and submit alongside the existing brief.

Realistic timeline: 3-4 weekends to a shippable V1, assuming evenings for the smaller steps.

## What is explicitly NOT in V1

- WhatsApp Business API production setup (Meta verification, BSP contract). → V2.
- Member removal. → V2.
- Order history learning / reorder reminders. → V2.
- Auto-restock / `checkout` triggered by agent. → V3.
- Proactive brand-preference nudges (V1 stores preferences but does not surface them unprompted). → V2.
- DigitalOcean deployment. → V2. V1 runs entirely on the developer's laptop; the Twilio Sandbox webhook is exposed via ngrok or cloudflared during demo recording and shut down after.

**V2 itself is conditional on Swiggy granting production MCP credentials.** Without production access, V1 is the terminal state: the sandbox-based bot ships, the demo video supports the Builders Club submission, and nothing further is built. No DigitalOcean, no production WhatsApp Business setup, no daily personal use. The submission is judged on V1; V2 only exists if Swiggy says yes.

## Edge cases (V1)

Overarching principle: **the agent never blocks waiting for user input, and never fails silently.** Every unhappy path either succeeds with transparency, fails informatively in one message, or partial-succeeds. The user always knows what just happened (or what didn't, and why). No silent drops, no missing replies, no swallowed errors.

### Commodity vs packaged items

Classifier tags `item_category` on every add or change. `handle_add` branches early:
- `packaged` (milk, atta, oil, snacks, beverages, personal care, cleaning) → brand-resolution flow.
- `fresh` (vegetables, fruits, herbs) → skip brand; pick top deliverable SKU directly.
- `unknown` → default to `fresh` behaviour (safer than wrong brand guess).

Hardcoded defaults map covers only the ~20-30 most common packaged items. Fresh items don't need entries; commodity flow handles them by default.

### Brand default not available at pincode

Fallback chain inside `handle_add` brand-resolution flow:
1. Try saved preference for this household.
2. Try hardcoded default for the item.
3. Try Instamart's top-ranked deliverable SKU regardless of brand.
4. If still nothing, treat as item-unavailable.

Reply pattern: *"Added Mother Dairy milk 1L (Amul not deliverable at your location)."* The household's saved preference auto-updates to whatever worked, so next time *"add milk"* uses Mother Dairy silently.

### User override brand not available

`handle_change` does NOT silently fall back when the user explicitly named a brand. Reply pattern: *"Country Delight milk isn't deliverable at your location. Available here: Amul, Mother Dairy, Nestle. Say 'change milk to X' to switch."* Stateless: no `pending_question` stored; user re-issues `change` if they want one of the alternatives.

### Brand change attempted on a commodity item

Reply pattern: *"Tomatoes don't need a brand. Try 'change tomato qty to 2' to adjust quantity instead."* No state change.

### Item entirely unavailable

Reply pattern: *"Sorry, ginger isn't deliverable at your location."* Cart unchanged.

### Variant defaulting

When the brand-resolved search returns multiple variants of the same brand + item, pick the most common Indian household variant:
- Milk → toned, 1L
- Atta → 5kg
- Oil → 1L
- Fresh items → 500g

Reply names the variant explicitly: *"Added Amul toned milk 1L. Say 'change milk to full cream' to switch."*

### Partial stock

If the user requests qty 5 but only 2 are in stock, add what's available and tell them: *"Added 2 of 5 requested onions (only 2 in stock)."* Cart reflects actual quantity added.

### System errors and recovery

When something goes wrong outside the product's modelled flow (MCP unreachable, OAuth expired, internal error), the user still gets an honest reply. No silent dropped messages.

- **Transient MCP / network errors.** Bot retries once internally; if still failing, replies: *"Having trouble reaching Instamart right now. Try again in a moment."*
- **OAuth token expired or invalid (account holder).** Bot replies: *"Your Instamart connection needs refreshing. Tap this link to reconnect: <oauth_link>."* No cart operations attempted until reconnection succeeds.
- **System error (Redis or Postgres unreachable).** Bot replies: *"Sorry, I'm having a system issue. Try again in a moment."* Full error logged server-side with the message ID; the user gets the honest summary without internals.
- **Message from a non-member phone number.** Bot replies: *"Hi! You're not in any HumaraCart household yet. Ask the account holder to share the invite link."* Never silently ignored.
- **Webhook arrived twice (Twilio retry).** Backend deduplicates by message ID; processed once. The duplicate webhook is acknowledged to Twilio without a second user-facing reply (this isn't a user-visible event, so silence here is correct).
- **Classifier returned `unknown`.** Bot replies with help text: *"I didn't catch that. Try 'add milk', 'remove chips', 'change milk to Mother Dairy', 'show list', or 'freeze cart'."*
- **MCP returned an unexpected response shape.** Bot replies: *"Something went wrong on my end. The team has been notified."* Log everything; user is informed without technical details.

### Common thread across all edge cases

Single-turn, stateless responses. None re-introduce the cross-turn `pending_question` state we removed when adopting silent defaults. The agent's commitment, restated: *always have an answer, always be honest about what happened (or what couldn't), never wait for the user to clarify, never let a message fall on the floor.*

## Observability

LangSmith traced from day one. Every intent classification and every LangGraph state transition logged. Representative trace screenshots go into the demo video's optional technical-depth cut and into the project README.

## Open items still to decide

- **`langchain-mcp-adapters` vs hand-rolled clients.** The adapter bridges MCP tools into LangChain's `@tool` interface cleanly and gives LangSmith better visibility. Hand-rolling is simpler if the adapter is finicky. Default: try the adapter first, fall back if it bites.
- **Brand storage:** exact strings in Postgres (V1 default) vs a small Chroma vector store for semantic matching of brand mentions. Defer the vector store to V2 unless an obvious need surfaces during build.
- **Application brief alignment:** the submitted application says *"agent asks rather than assumes"* for brands and quantities. The build plan now flips this to *"agent picks defaults transparently; user overrides via `change`."* Worth updating the application brief to match before the demo video is recorded, so the written narrative and the demo agree.
