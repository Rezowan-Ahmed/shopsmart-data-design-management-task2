# ShopSmart Online Ltd — Task 2 SQL appendix

This repository contains SQL for an academic exercise using fictional, synthetic e-commerce data. No real customer information is included.

## Files

- `ShopSmart_Task2_Complete.sql` — original nine-table SQL setup and 780-row synthetic seed, integrity checks, transaction reconciliation, five business queries and two materialized-view transformations. The original statements are preserved; only the introductory header was adjusted to describe clean replay.
- `ShopSmart_Task2_Verification_Checks.sql` — additional read-only post-run verification queries (not part of the original presentation).

## Requirements

- PostgreSQL 18 (the version used for coursework); pgAdmin 4 or a PostgreSQL SQL client.

## How to run (pgAdmin 4)

1. Create a **brand-new empty** database, e.g. `shopsmart_task2_github_test`. Do not use a populated database.
2. Right-click that new database > Query Tool. Run `SELECT current_database();` and confirm the correct name.
3. Open `ShopSmart_Task2_Complete.sql` through the Query Tool folder icon. Make sure no SQL is selected, then press **F5** once to execute the whole file. Avoid rerunning on the same database.
4. Check the **Messages** tab for errors. A successful query run alone is not proof of matching results.
5. In a separate Query Tool tab connected to the same database, open `ShopSmart_Task2_Verification_Checks.sql` and run each verification query separately, or execute the file and review each result.
6. Inspect `Schemas > public > Tables` for nine tables and `Schemas > public > Materialized Views` for `shopsmart_monthly_sales` and `shopsmart_inventory_category_summary`.

## Expected base-data record counts (fresh database)

`customers` 30; `categories` 30; `suppliers` 30; `employees` 30; `products` 60; `inventory` 60; `orders` 120; `order_items` 300; `payments` 120; **total 780**.

Payment reconciliation is expected to check 120 orders with zero orders missing lines, missing payments or mismatched amounts.

## Verification note / known discrepancy to check

The original inventory seed uses a formula to set stock quantities. A static calculation of those exact rules indicates **24** active products with stock at or below the reorder level. Some earlier slide-based descriptions state **17**. We have **not** executed this package on a live PostgreSQL server here, so the PostgreSQL output is authoritative. If the clean run returns 24, reconcile Slides 15–18 before claiming a match. Do not alter the historical source silently.

## Limitations

This package has been checked for file composition and source preservation, not yet certified by a full live PostgreSQL clean-run in this environment. Queries using materialized views create objects and require database write privileges. This script does not create the database itself.
