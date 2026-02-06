---
title: "Cost Basis Pitfall: Sold Above Cost, Still Lost Money"
date: 2026-02-04T09:00:00+08:00
lastmod: 2026-02-04T09:00:00+08:00
author: Huba
avatar: /img/avatar.jpeg
categories:
  - Personal Finance
tags:
  - Investing
  - ETF
  - Cost Basis
  - Trading
  - Beginner
draft: false
description: "The cost shown on your holdings page can be a diluted scorecard. The profit or loss on your next sell is determined by the true, moving cost basis after each add." 
aiSummary: "The cost shown on your holdings page can be a diluted scorecard. The profit or loss on your next sell is determined by the true, moving cost basis after each add."
aiKeyPoints:
  - "1. Confusion: sold higher, why did I lose money?"
  - "2. Truth: a chase-buy lifted the true cost basis"
  - "3. Lesson: separate the display cost from the trading cost"
faq:
  - q: "What is this article about?"
    a: "The cost shown on your holdings page can be a diluted scorecard. The profit or loss on your next sell is determined by the true, moving cost basis after each add."
  - q: "Who is this for?"
    a: "For beginners who want to avoid cost-basis mistakes when trading ETFs."
---

A real trade, an unexpected loss, and a hard lesson on cost basis.

On Feb 3, 2026, I sold part of a position I had held for months in an "xxx Gas ETF". The cost shown on my holdings page was about RMB 0.84, while the market price was around RMB 0.933. It looked like the price was clearly above cost, so I assumed any sale would be a profit.

But after selling 1,800 shares at RMB 0.932, the trade record showed a loss.

This post records the full path from "that makes no sense" to "I understand the cost basis" so you do not repeat the same mistake.

<!--more-->

## 1. Confusion: sold higher, why did I lose money?

My first reaction was: is the app wrong? Was the fill price wrong? Did I miss some math?

Later I realized the issue was not the price. It was that I used the wrong cost basis.

## 2. Truth: a chase-buy lifted the true cost basis

To understand what happened, I pulled every trade and rebuilt the timeline. Each step changed my true cost basis:

1. **Build at lows (Nov-Dec 2025):** bought 9,100 shares in the RMB 0.911-0.925 range. Average cost was about **RMB 0.921**.
2. **Sell for profit (late Jan 2026):** sold most of the position at RMB 0.998 and RMB 1.076 for a gain.
3. **Chase-buy (Jan 30, 2026):** worried about missing out, I bought back **3,100 shares at RMB 0.994**.
4. **Sell (Feb 3, 2026):** sold **1,800 shares at RMB 0.932** and got a loss.

The key is steps 2 and 3:

- Step 2 profit can make the holdings page show a very low, nice-looking "cost" (a diluted scorecard).
- Step 3 is real money paid at a high price. It immediately lifts the true average cost of the current position.

In my case, after the chase-buy, the true average cost of the remaining shares rose to about **RMB 0.962**. So selling at RMB 0.932 meant I was selling **below the true cost**:

```text
Loss per share ~= 0.962 - 0.932 = RMB 0.030
Total loss ~= 0.030 x 1800 = RMB 54 (fees not included)
```

The loss shown in the app can differ slightly due to **fees and transaction charges** (so you may see a number near RMB 54, but not exactly the same).

## 3. Lesson: separate the two "costs"

This mistake taught me that two "cost" concepts in investment apps are used for different purposes.

### 1) Diluted cost (often shown on the holdings page)

This is more like an **overall scorecard**. The system may spread realized profits across remaining shares, making the "cost" look lower and safer.

That number is useful, but the problem is: **it should not be used to judge the profit or loss of your next trade**.

### 2) Moving average cost / true cost basis (decides your trade PnL)

This is the **trading compass**. Every new buy (especially a chase-buy) changes this line.

Your broker calculates PnL based on a specific cost-basis method plus fees. **The exact method depends on the broker**, but the key is this: use the wrong cost basis, and losses are likely.

## 4. Cheat sheet: 3 rules that save real money

1. **Do not use the nice-looking cost on the holdings page as your trade basis.** It is a scorecard, not a compass.
2. **After each buy, calculate your true average cost:** `total invested / current shares`. Write it down and only use that number in trades.
3. **Before adding, estimate the new average cost:** if it sits too close to the market price, the profit buffer is thin and you can easily give back earlier gains.

PS: You do not need to do the math manually. You can give the trade history to AI. Just remember to include **fees and charges** so the result matches reality.

## 5. Closing: cost is dynamic, and clarity is basic skill

This experience etched in a simple but important lesson:

> Cost is never a fixed number. It moves with every buy and every add.

For beginners, understanding your own cost basis matters more than predicting the market. **Know your true cost basis** so each trade is made with clear numbers.

Investing involves risks. Be cautious.
