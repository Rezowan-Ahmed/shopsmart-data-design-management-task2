# ShopSmart Online Ltd — Task 2 SQL Appendix

This repository contains the PostgreSQL SQL scripts developed for Task 2 of the Data Design Management assessment, using fictional, synthetic e-commerce data. No real customer information is included.

## Files

- **ShopSmart_Task2_Complete.sql** — Complete SQL script containing nine table definitions, synthetic-data insertion statements, database integrity constraints, five business-analysis queries, two materialized-view transformations and validation queries.
- **ShopSmart_Task2_Verification_Checks.sql** — Additional SQL queries for checking database records, relationships, transactions and analytical outputs.

## Requirements

- PostgreSQL 18
- pgAdmin 4 or another PostgreSQL-compatible SQL client

## How to Run (pgAdmin 4)

1. Create a new, empty PostgreSQL database, for example `shopsmart_task2_github_test`.
2. Right-click the new database and select **Query Tool**.
3. Execute `SELECT current_database();` to confirm that the correct database is selected.
4. Open `ShopSmart_Task2_Complete.sql` in the Query Tool.
5. Execute the complete SQL script using **F5**.
6. Check the **Messages** and **Data Output** panels for execution results.
7. Open `ShopSmart_Task2_Verification_Checks.sql` in a separate Query Tool tab and execute the verification queries.
8. Refresh **Schemas → public → Tables** and **Materialized Views** to inspect the database objects.

The complete SQL script should be executed in a fresh database to avoid conflicts with existing records or materialized views.

## Expected Database Records

| Table | Records |
|---|---:|
| Customers | 30 |
| Categories | 30 |
| Suppliers | 30 |
| Employees | 30 |
| Products | 60 |
| Inventory | 60 |
| Orders | 120 |
| Order Items | 300 |
| Payments | 120 |
| **Total** | **780** |

## SQL Verification Results

The following results were verified using PostgreSQL 18 and pgAdmin 4:

- 120 orders with no missing order items or payments.
- Zero payment amount mismatches.
- 60 active products with corresponding inventory records.
- 30 suppliers, each assigned two products.
- 24 products below their reorder thresholds, representing 40% of active products.
- Zero products completely out of stock.
- The inventory category materialized view reports 24 reorder alerts, matching the original inventory table.

The inventory and supplier results agree with the figures presented in Task 2, Slides 15 and 16.

## Testing and Reproducibility

The complete SQL script was successfully executed in a fresh PostgreSQL 18 database using pgAdmin 4 without reported execution errors.

The repository provides the SQL source code and verification queries so that the assessment marker can reproduce the database structure, synthetic records, analytical queries and transformations independently.

## Limitations

The database contains fictional synthetic records created for academic demonstration. The results illustrate database design, SQL analysis and data transformation techniques and should not be interpreted as actual business performance.

Materialized views store aggregated results and require refreshing if the underlying data is subsequently changed.
