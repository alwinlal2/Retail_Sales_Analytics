# Retail Sales Analytics

End-to-end retail sales analytics project using **Excel, MySQL, and Power BI**. The project covers data cleaning, SQL analysis, and interactive dashboard development to generate business insights from customer, product, order, and salesperson data. 

## Project Workflow

### 1. Excel Data Cleaning
- Cleaned the customer table and removed an impossible age value.
- Added missing headers to the product table.
- Cleaned the salespersons table.
- Cleaned the orders table by removing invalid customer IDs, negative quantities, incorrect sales calculations, and inconsistent discount values.
- Handled missing payment modes using customer history where possible, and marked the remaining uncertain values as `Unknown`. 

### 2. MySQL Analysis
The SQL workflow was divided into structured phases:
- Phase 0: Data preparation
- Phase 1: Data understanding
- Phase 2: Data quality checks
- Phase 3: Overall sales summary
- Phase 4: Product analysis
- Phase 5: Customer analysis
- Phase 6: Salesperson analysis
- Phase 7: Time analysis
- Phase 8: Payment analysis
- Phase 9: Multi-table join analysis
- Phase 10: Advanced SQL analysis

### 3. Power BI Dashboard
Built two interactive report pages:
- **Executive Overview**
- **Customer & Product Insights**

The dashboards include KPI cards, trend visuals, top-performing customers and products, payment analysis, and interactive slicers for dynamic filtering. 

## Key SQL Concepts Used
- Aggregate functions
- `GROUP BY` and `HAVING`
- `INNER JOIN` and `LEFT JOIN`
- Common Table Expressions (CTEs)
- Window functions (`RANK()`, `LAG()`)
- Date and time functions
- `CASE` statements

## Dashboard Screenshots
<img width="1148" height="656" alt="Screenshot 2026-07-08 184600" src="https://github.com/user-attachments/assets/a9e0dbb2-6ad0-4318-9eb4-37aa0b58c8e3" />
<img width="1148" height="656" alt="Screenshot 2026-07-08 184600" src="https://github.com/user-attachments/assets/8c6e182e-f119-4d5b-94b9-fcbc2013ba26" />


## Tools Used
- Microsoft Excel
- MySQL
- Power BI
