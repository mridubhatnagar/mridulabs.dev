# HumaraCart vs. Swiggy Instamart MCP: Evaluation

*Evaluated: 1 May 2026*

---

## All 6 Planned Tools Exist

Every tool the project listed is present in the actual MCP:

| Project Tool | Status | Notes |
|---|---|---|
| `search_products` | ✅ | Present |
| `update_cart` | ✅ | Present, but see caveat below |
| `get_cart` | ✅ | Present |
| `checkout` | ✅ | Present (V3) |
| `track_order` | ✅ | Present |
| `get_orders` | ✅ | Present (V2) |

---

## One Critical Behaviour Difference

**`update_cart` replaces the entire cart, not incremental add/remove.**

The project frames it as "item added → call `update_cart`" as if it's additive. In reality, every `add milk` or `remove detergent` must send the full current cart state as a replacement. This doesn't break the design (PostgreSQL already stores cart state, so the backend computes the new state and pushes the full list), but it's a non-obvious implementation detail the current doc doesn't surface.

---

## Open Question Answered (Unfavorably)

The project asked: *"Does the MCP expose a shareable cart link?"*

**Answer: No.** There is no such tool. The fallback path in the doc ("Agent notifies the account holder: cart link unavailable, open Instamart") is now the confirmed only path, not a contingency.

---

## `search_products` Requires an `addressId`

The doc doesn't mention this. Every product search needs a delivery address selected first. The OAuth setup flow handles account linking, but the bot must also store or select the household's delivery address before it can search for any product. This is a gap in the setup flow description.

The MCP provides `get_addresses`, `create_address`, and `delete_address` tools (not in the project doc) that can handle this during onboarding.

---

## 4 Bonus Tools Not in the Project

| Tool | Relevance |
|---|---|
| `your_go_to_items` | Strong fit for V2 reorder reminders; complements `get_orders` |
| `get_addresses` / `create_address` / `delete_address` | Needed for address setup during onboarding |
| `get_order_details` | Could enrich delivery broadcast messages |
| `clear_cart` | Minor utility; `update_cart` with empty list likely covers it |

---

## Summary

The project design is largely sound. Core tools are all there. Two things need attention when building:

1. `update_cart` is a full-replace. The backend owns the source of truth, not Instamart.
2. Address selection is a prerequisite for search. The setup flow must include address handling, which the MCP supports but the current doc doesn't mention.

---

## Pending Actions

- [ ] Acknowledge `update_cart` full-replace behaviour and `addressId` requirement in the main application doc
- [ ] Email Swiggy regarding shareable cart link availability
