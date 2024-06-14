create database e_commerce_business;
use e_commerce_business;
select count(*) from customers;
select count(*) from products;
select count(*) from orders;
select count(*) from orderdetails;

/* Problem statement
Identify the top 3 cities with the highest number of customers to determine key markets
 for targeted marketing and logistic optimization. */
 
select location, count(customer_id) number_of_customers
from Customers
Group by 1 Order by 2 desc limit 3;

/* Problem statement
Determine the distribution of customers by the number of orders placed. This insight will help in
 segmenting customers into one-time buyers, occasional shoppers, and regular customers for tailored marketing strategies. */
 
 With CTE as (select customer_id, count(order_id) NumberOfOrders
from Orders
Group by 1 Order by 2 asc)
select NumberOfOrders, count(customer_id) as CustomerCount
from CTE
Group By 1 Order by 1 asc;

/* Problem statement
Identify products where the average purchase quantity per order is 2 but with a high total revenue, 
suggesting premium product trends. */

select Product_id, avg(quantity) AvgQuantity, sum(price_per_unit * quantity) TotalRevenue
from OrderDetails
Group by 1 Having avg(quantity) = 2 Order by 3 desc;

/* Problem statement
For each product category, calculate the unique number of customers purchasing from it. 
This will help understand which categories have wider appeal across the customer base. */

select p.category category, count(distinct(o.customer_id)) unique_customers
from Products p INNER JOIN OrderDetails od using(product_id)
INNER JOIN orders o using(order_id)
Group by 1 Order by 2 desc;

/* Problem statement
Analyze the month-on-month percentage change in total sales to identify growth trends. */

with CTE as (select date_format(order_date, "%Y-%m") Month, sum(total_amount) TotalSales
from Orders Group by 1)
select *, 
round(((TotalSales - lag(TotalSales) over(order by Month))/lag(TotalSales) over(order by Month))*100,2) PercentChange
from CTE;

/* Problem statement
Examine how the average order value changes month-on-month. Insights can guide pricing and promotional strategies
to enhance order value. */

with CTE as (select date_format(order_date, "%Y-%m") Month, avg(total_amount) AvgOrderValue
from Orders Group by 1)
select Month, AvgOrderValue,
round((AvgOrderValue - lag(AvgOrderValue) over(order by Month)),2) ChangeInValue
from CTE Order by 3 desc;

/* Problem statement
Based on sales data, identify products with the fastest turnover rates, suggesting 
high demand and the need for frequent restocking. */

select product_id, count(quantity) SalesFrequency
from OrderDetails
Group by 1 Order by 2 desc limit 5;

/* Problem statement
List products purchased by less than 40% of the customer base, indicating potential
 mismatches between inventory and customer interest. */
 
with CTE as (select count(distinct(customer_id)) TotalCustomer
from Customers ),
CTE2 as (select p.Product_id, count(distinct(o.customer_id)) UniqueCustomerCount
from Products p INNER JOIN OrderDetails od using(product_id)
INNER JOIN Orders o using(order_id) INNER JOIN customers c using(customer_id)
Group by 1)
Select CTE2.Product_id, P.Name, CTE2.UniqueCustomerCount
from CTE JOIN CTE2 on 1=1 JOIN products p on CTE2.Product_id = p.product_id
where (CTE2.UniqueCustomerCount/ CTE.TotalCustomer) < 0.40;

/* Problem statement
Evaluate the month-on-month growth rate in the customer base to understand the effectiveness
of marketing campaigns and market expansion efforts. */

with CTE as (select customer_id, min(order_date) first_date from Orders
Group by customer_id)
select date_format(first_date, "%Y-%m") FirstPurchaseMonth,
count(distinct customer_id) TotalNewCustomers
from CTE Group by 1 Order by 1;

/* Problem statement
Identify the months with the highest sales volume, aiding in planning for stock levels, 
marketing efforts, and staffing in anticipation of peak demand periods. */

select date_format(order_date, "%Y-%m") Month, sum(total_amount) TotalSales
from Orders
Group by 1 Order by 2 desc limit 3;
