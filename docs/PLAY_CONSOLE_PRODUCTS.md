# Google Play Console – in-app products

Everything to create in **Play Console › your app › Monetize with Play › Products**.
The **Product IDs must match exactly** (they are in `lib/app/constants/iap_config.dart`) and
**can never be changed or reused** once created.

> Before products can be created, upload at least one signed app bundle (Internal testing is fine).

## Prices: set in USD, let Play convert

For every product, enter the **USD price**, then use **"Set prices" › apply to all countries/regions**.
Play converts with current exchange rates and rounds to local price conventions (e.g. ₹, €, £ endings).
Afterwards, review a few big markets (India, Brazil, Indonesia, Türkiye, EU) and lower any that look
high for the local market. Consumer prices on Play include tax in most countries.

| Product ID | Type | USD price |
|---|---|---|
| `remove_ads` | One-time product | **$3.99** |
| `starter_pack` | One-time product | **$4.99** |
| `hints_10` | One-time product (consumable in app) | **$0.99** |
| `hints_50` | One-time product (consumable in app) | **$2.99** |
| `hints_150` | One-time product (consumable in app) | **$6.99** |
| `vip_weekly` | Subscription | **$1.99 / week** |
| `vip_monthly` | Subscription | **$4.99 / month** |
| `vip_yearly` | Subscription + 3-day free trial | **$19.99 / year** |

Why these prices: they are the standard price points for casual puzzle games ($0.99 entry pack,
$2.99 "popular" pack, Remove Ads at $3.99), and the yearly VIP ($0.38/week) is ~80% cheaper than
weekly so it is clearly the best value.

---

## 1. One-time products (5)

**Monetize with Play › Products › One-time products › Create one-time product**

For each product:
1. **Product ID** – from the table below.
2. **Name** and **Description** – shown on the Google Play purchase sheet.
3. **Purchase option** – create one *Buy* option (any ID, e.g. `buy`), **auto-renewing: no**.
4. **Price** – enter the USD price › apply to all countries.
5. **Tax / compliance category** – *Digital content / in-game items* (default is fine).
6. **Save** › **Activate**.

| Product ID | Name (max 55 chars) | Description (max 200 chars) |
|---|---|---|
| `remove_ads` | Remove Ads | Remove all banner, pop-up and app-open ads forever. Optional reward videos stay available for free hints. |
| `starter_pack` | Starter Pack | Remove all ads forever and get 30 hints. Limited one-time offer. |
| `hints_10` | 10 Hints | 10 hints. Each hint places one correct number on the board. |
| `hints_50` | 50 Hints | 50 hints. Each hint places one correct number on the board. |
| `hints_150` | 150 Hints | 150 hints — best value. Each hint places one correct number on the board. |

> Hint packs are *consumable*: the app consumes them after crediting the hints, so they can be
> bought again. In Play Console they are ordinary one-time products — nothing extra to set.

## 2. Subscriptions (3)

**Monetize with Play › Products › Subscriptions › Create subscription**

Each VIP plan is its **own subscription with one base plan**.

### Subscription details (same for all three, except ID/name)

| Field | `vip_weekly` | `vip_monthly` | `vip_yearly` |
|---|---|---|---|
| Product ID | `vip_weekly` | `vip_monthly` | `vip_yearly` |
| Name | CrossMath VIP · Weekly | CrossMath VIP · Monthly | CrossMath VIP · Yearly |

**Benefits** (add up to 4, shown in Play's subscription center):
- No ads, ever
- Unlimited hints
- Master mode & every past daily challenge
- Exclusive board themes

**Description:** `VIP: no ads, unlimited hints, Master mode, all past daily challenges, free second chances and exclusive themes.`

### Base plan (one per subscription) › *Add base plan*

| Field | `vip_weekly` | `vip_monthly` | `vip_yearly` |
|---|---|---|---|
| Base plan ID | `weekly` | `monthly` | `yearly` |
| Type | Auto-renewing | Auto-renewing | Auto-renewing |
| Billing period | 1 week | 1 month | 1 year |
| Price (USD) | $1.99 | $4.99 | $19.99 |
| Grace period | 3 days | 7 days | 14 days |
| Account hold | On (default) | On (default) | On (default) |
| Resubscribe | Allow | Allow | Allow |
| Upgrades / downgrades | Charge on next billing date | Charge on next billing date | Charge on next billing date |

Then **Activate** each base plan.

### Free-trial offer (yearly only) › `vip_yearly` › base plan `yearly` › *Add offer*

| Field | Value |
|---|---|
| Offer ID | `trial-3d` |
| Eligibility | **New customer acquisition** › *Never had this subscription* |
| Phase 1 | **Free trial**, duration **3 days** |
| Tags | (optional) `trial` |

**Activate** the offer. Google only offers it to eligible users; the app automatically shows
"Start 3-day free trial" for them and the normal yearly price for everyone else.

## 3. Licence testing (test purchases without being charged)

1. **Settings › License testing** (Play Console home, not the app) › add the Gmail accounts of your testers ›
   *License response: RESPOND_NORMALLY*.
2. **Testing › Internal testing** › *Testers* › add the same accounts › copy the **opt-in link**.
3. On the phone (signed in with a tester account): open the opt-in link › *Become a tester* ›
   install from the Play Store. Purchases only work for installs from Play.
4. Test cards appear on the purchase sheet ("Test card, always approves / declines / slow").
   Use *slow* to test the "Payment pending" screen.
5. Test subscriptions renew fast: weekly → every 5 min, monthly → 5 min, yearly → 30 min;
   the free trial lasts 3 min. They auto-cancel after 6 renewals.

## 4. Checklist

- [ ] Signed `.aab` uploaded to Internal testing (same package: `sp.math.puzzle.games.crossmathpuzzle.play`)
- [ ] 5 one-time products created and **Active**
- [ ] 3 subscriptions, each with an **Active** base plan
- [ ] `trial-3d` offer on `vip_yearly` **Active**
- [ ] Testers added to License testing + Internal testing
- [ ] Store opens in the app with real local prices (if it shows "—"/fallback prices, the products
      are not active yet or the app was not installed from Play — changes can take a few hours to appear)
