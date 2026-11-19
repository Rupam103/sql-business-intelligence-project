# Northwind SQL Business Analytics Project

## 1. Project Overview

This project uses SQL to analyze business operations using the Northwind database. It focuses on sales performance, customer value, product performance, market contribution, and supplier concentration.

The objective is to transform raw transactional data into meaningful business insights using MySQL and advanced SQL techniques.

## 2. Business Objectives

- Analyze monthly sales performance and month-over-month changes.
- Identify countries with an established customer base.
- Rank high-value customers within each country.
- Identify leading products within each category.
- Evaluate supplier concentration across product categories.
- Create reusable SQL views for consistent business calculations.

## 3. SQL Concepts Used

| SQL Concept | Application |
|---|---|
| INNER JOIN | Combining related tables |
| CREATE VIEW | Creating reusable analytical views |
| Aggregate Functions | SUM(), AVG(), COUNT() |
| GROUP BY | Summarizing business data |
| HAVING | Filtering aggregated results |
| CTEs | Organizing complex queries |
| Window Functions | Ranking and comparing records |
| DENSE_RANK() | Ranking customers, products, and suppliers |
| LAG() | Comparing monthly performance |
| CROSS JOIN | Comparing market values with overall value |
| CASE WHEN | Classifying supplier concentration |
| NULLIF() | Preventing division-by-zero errors |

## 4. Business Analysis

### A. Order-Level Analysis
Created reusable views to combine order, customer, employee, shipper, product, category, and supplier information.

- `vw_northwind_order_lines`
- `vw_northwind_order_summary`

### B. Monthly Sales Performance
Analyzed monthly order activity, ordering customers, estimated sales value, average order value, and month-over-month growth.

### C. Market Analysis
Identified countries with at least 5 distinct ordering customers and 10 orders. Calculated each qualifying country's contribution to overall estimated sales value.

### D. Customer Analysis
Ranked customers within each country based on their estimated order value and calculated their contribution to the country's total value.

### E. Product Analysis
Ranked the top 5 products within each category based on estimated sales value. Also analyzed order count, purchasing customers, and recorded quantity.

### F. Supplier Concentration
Identified the leading supplier in each product category and calculated its share of the category's estimated sales value.

## 5. Database and Tools

- **Database:** Northwind
- **SQL Language:** MySQL
- **Environment:** MySQL Workbench

## 6. How to Run the Project

1. Install MySQL Server and MySQL Workbench.
2. Import or set up the Northwind database.
3. Ensure the database is named `northwind_db`, or modify the `USE northwind_db;` statement in the SQL script.
4. Open `sql-business-intelligence-project.sql` in MySQL Workbench.
5. Execute the script using a MySQL 8.0-compatible server.

**Note:** The SQL script assumes that the Northwind tables already exist. The database itself is not included in this repository.

## 7. Important Calculation Note

The project calculates estimated sales value using:

`Product Price × Order Quantity`

This is an estimated gross line value, not necessarily actual invoiced revenue. The calculation does not account for discounts or other adjustments.

## 8. Project Structure

```text
sql-business-intelligence-project/
│
├── README.md
│
└── sql-business-intelligence-project.sql
```

## 9. Learning Outcomes

Through this project, I applied SQL concepts to practical business problems, developed reusable analytical views, and used CTEs and window functions to perform customer, product, market, and supplier analysis.

---

Author: Rupam Maiti  
Project: Northwind SQL Business Analytics
