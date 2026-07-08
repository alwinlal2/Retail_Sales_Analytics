create database da_project;

-- -----------------------------------------------
--          Phase 0 : Preliminary Changes
-- -----------------------------------------------
set sql_safe_updates = 0 ;
rename table `order` to `orders`;
rename table `saless_persons` to `sales_persons`;
alter table customer rename column  ï»¿Customer_ID to customer_id ;
alter table orders rename column ï»¿Order_ID to order_id ;
alter table product rename column ï»¿product_id to product_id ;
alter table sales_persons rename column ï»¿Salesperson_ID to sales_persons_id;
update orders
set Order_Date = str_to_date(Order_Date, '%d-%m-%Y')
where Order_Date like '__-__-____';
alter table orders change Order_Date order_date Date ;
update orders
set Ship_Date = str_to_date(Ship_Date, '%d-%m-%Y') 
where Ship_Date like  '__-__-____';
alter table orders change Ship_Date ship_date Date;

alter table orders change Sales sales decimal(12,2);


-- ----------------------------------------------
--      Phase 1: Data Understanding
-- ----------------------------------------------

-- How many rows are in each table?

select count(*) from customer;
select count(*) from orders ;
select count(*) from product;
select count(*) from sales_persons;

-- How many columns are in each table?

select count(*) as column_count from information_schema.columns 
where table_schema = 'da_project' and table_name = 'customer' ;
select count(*) as column_count from information_schema.columns 
where table_schema = 'da_project' and table_name = 'orders' ;
select count(*) as column_count from information_schema.columns 
where table_schema = 'da_project' and table_name = 'product' ;
select count(*) as column_count from information_schema.columns 
where table_schema = 'da_project' and table_name = 'sales_persons' ;

-- What is the date range of the Orders table?

select min(order_date) , max(order_date) from orders;

-- How many unique customers are there?

select count(distinct customer_id) from customer;

-- How many unique products are there?

select count(distinct product_id) from product; 

-- How many unique salespersons are there?

select count(distinct sales_persons_id) from sales_persons;

-- Which product categories are present?

select distinct category from product ;

-- Which cities are present?

select distinct City from customer;

-- Which payment modes are present?

select distinct Payment_mode from orders ;

-- ---------------------------------------------
--      Phase 2: Data Quality Checks
-- ---------------------------------------------

-- Are there duplicate Customer IDs?

select customer_id, count(*) as c from customer 
group by customer_id having c >1 ;

-- Are there duplicate Product IDs?

select product_id, count(*)  as c from product
group by product_id having c >1 ;

-- Are there duplicate Order IDs?

select order_id, count(*)  as c from orders
group by order_id having c >1 ;

-- Are there any missing values in key columns?

select * from customer
where customer_id is null or trim(customer_id) = ''
 or customer_name is null or trim(customer_name) = ''
 or email is null or trim(email) = '';
 
 select * from orders 
 where order_id is null or trim(order_id) = ''
 or Customer_ID is null or trim(Customer_ID) = ''
 or Salesperson_ID is null or trim(Salesperson_ID) = '';
 
 select * from product
 where product_id is null or trim(product_id) = ''
 or unit_price is null or trim(unit_price) = ''
 or category is null or trim(unit_price) = '' ;
 
-- Are there any negative quantities?

select * from orders where  Quantity<0;

-- Are there any negative sales values?

select * from orders where sales<0;

-- Are there any invalid unit prices?

select * from orders where Unit_Price < 0;

-- Does every order have a valid customer reference?

select o.order_id , o.Customer_ID from orders o left join customer c
on o.Customer_ID = c.customer_id where c.customer_id is null;

delete from orders where Customer_ID = 'C0025';

-- Does every order have a valid product reference?

select o.order_id , o.Product_ID from orders o left join product p 
on o.Product_ID = p.product_id 
where p.product_id is null ;

-- Does every order have a valid salesperson reference?

select o.order_id, o.Salesperson_ID from orders o left join 
sales_persons s on o.Salesperson_ID = s.sales_persons_id
where s.sales_persons_id is null ;

-- -----------------------------------------------------
--          Phase 3: Overall Sales Summary
-- ------------------------------------------------------

-- What is the total revenue?

select round(sum(sales),2) as total_revenue from orders ;

-- What is the total quantity sold?
select sum(Quantity) as total_quantity from orders ;

-- What is the total number of orders?

select count(*) as total_orders from orders ;

-- What is the average order value?

select round(avg(sales),2) as avg_order_value from orders ;

-- What is the average quantity per order?

select round(avg(Quantity),2) as avg_quantity_per_order from orders ;

-- What is the average unit price?

select round(avg(Unit_Price),2) as avg_unit_price from orders ;

-- What is the highest order value?

select max(sales) as highest_ov from orders ;

-- What is the lowest order value?

select min(sales) as lowest_ov from orders;

-- -----------------------------------------------------
--          Phase 4: Product Analysis
-- ------------------------------------------------------

-- Which product generated the highest revenue?

select o.Product_ID, p.product_name , sum(o.sales) as revenue 
from orders o join product p 
on o.Product_ID = p.product_id
group by  o.Product_ID, p.product_name
order by revenue desc limit 1;

-- Which product sold the highest quantity?

select o.Product_ID, p.product_name , sum(o.Quantity) as quantity
from orders o join product p 
on o.Product_ID = p.product_id
group by  o.Product_ID, p.product_name
order by quantity desc limit 1;

-- Which category has the most products?

select category , count(product_id) as total_product
from product group by category
order by total_product desc limit 1  ;

-- Which category generated the highest quantity sold?

select p.category, sum(o.Quantity) as total_quantity
from orders o join product p
on o.Product_ID = p.product_id
group by p.category
order by total_quantity desc limit 1 ;

-- Which product has the highest unit price?

select product_name , unit_price from product 
order by unit_price desc limit 1 ;

-- Which category has the highest average unit price?

select category , round(avg(unit_price),2) as unit_price from product 
group by category
order by unit_price desc limit 1 ;

-- Which products were sold only once?

select p.product_name, count(o.order_id) as cnt 
from orders o join product p 
on o.Product_ID = p.product_id 
group by p.product_name
having cnt= 1;

-- What percentage of total revenue comes from each category?

with percentage as (
	select p.category, sum(sales) as revenue from orders o join product p 
	on o.Product_ID = p.product_id 
	group by p.category)
select category , round( revenue * 100 / sum(revenue) over(), 2)
as percent_of_total_revenue
from percentage
group by category ;

-- -----------------------------------------------------
--          Phase 5: Customer Analysis
-- ------------------------------------------------------

-- Which customer generated the highest revenue?

select Customer_ID , sum(sales) as revenue from orders 
group by Customer_ID
order by revenue desc limit 1;

-- Which customer placed the most orders?

select Customer_ID , count(order_id) as cnt 
from orders
group by Customer_ID 
order by cnt desc limit 1;

-- Which customer purchased the highest quantity?

select Customer_ID , sum(Quantity) as qnt
from orders
group by Customer_ID 
order by qnt desc limit 1;

-- Which customer has the highest average order value?

select Customer_ID , round(avg(sales),2) as avg_ov
from orders
group by Customer_ID 
order by avg_ov desc limit 1;

-- Which city has the highest number of customers?

select city , count(customer_id) as cnt from customer
group by city order by cnt desc limit 1;

-- Which city generated the highest revenue?

select c.city, sum(sales) as revenue from orders o join customer c
on o.Customer_ID = c.customer_id 
group by c.city 
order by revenue desc limit 1;

-- Which customers made only one purchase?

select Customer_ID, count(order_id) as cnt
from orders 
group by Customer_ID
having cnt = 1;

-- What percentage of total revenue comes from each city?

with percent as (select c.city , sum(o.sales) as revenue from orders o join customer c 
	on o.Customer_ID = c.customer_id
	group by c.city)
select city , round(revenue *100 / sum(revenue) over (), 2) as percent_of_revenue
from percent ;


-- -----------------------------------------------------
-- Phase 6: Salesperson Analysis 
-- -----------------------------------------------------

-- Which salesperson generated the highest revenue?

select s.Salesperson , sum(sales) as revenue from orders o join sales_persons s 
on o.Salesperson_ID = s.sales_persons_id 
group by s.Salesperson 
order by revenue desc limit 1;

-- Which salesperson handled the most orders?

select s.Salesperson , count(o.order_id) as orderss from orders o join sales_persons s 
on o.Salesperson_ID = s.sales_persons_id 
group by s.Salesperson 
order by orderss desc limit 1;

-- Which salesperson sold the highest quantity?

select s.Salesperson , sum(Quantity) as qnt from orders o join sales_persons s 
on o.Salesperson_ID = s.sales_persons_id 
group by s.Salesperson 
order by qnt desc limit 1;

-- What percentage of total revenue comes from each salesperson?

with percent as (
	select s.Salesperson , sum(sales) as revenue from orders o join sales_persons s 
	on o.Salesperson_ID = s.sales_persons_id 
	group by s.Salesperson )
select Salesperson, round( revenue * 100 / sum(revenue) over (), 2) as percent_of_revenue 
from percent ;

-- Rank salespersons by revenue.

with percent as (
	select s.Salesperson , sum(sales) as revenue from orders o join sales_persons s 
	on o.Salesperson_ID = s.sales_persons_id 
	group by s.Salesperson )
select Salesperson, revenue , rank() over (order by revenue desc ) as rnk
from percent ;

-- -----------------------------------------------------
-- Phase 7: Time Analysis 
-- -----------------------------------------------------

-- Monthly revenue trend

select date_format(order_date, '%m-%Y') as month, 
sum(sales) as revenue from orders 
group by month order by month ;

-- Monthly quantity trend

select date_format(order_date, '%m-%Y') as month, 
sum(Quantity) as qnt from orders 
group by month order by month ;

-- Highest revenue month

select date_format(order_date, '%m-%Y') as month , sum(sales) as revenue
from orders group by month order by revenue desc limit 1;

-- Highest revenue quarter

select concat( year(order_date),' Q',quarter(order_date)) as quarter, 
sum(sales) as revenue from orders 
group by quarter order by revenue desc limit 1 ;

-- Highest quantity month

select date_format(order_date, '%m-%Y') as month ,
sum(Quantity) as qnt 
from orders 
group by month order by qnt desc limit 1 ;

-- Running total of revenue

with m_o_m as
	( select date_format(order_date, '%m-%Y') as month , sum(sales) as revenue
    from orders group by month order by month)
select month, revenue, sum(revenue) over (order by month) as running_total
from m_o_m;

-- Month-over-month revenue growth

with m_o_m as
	( select date_format(order_date, '%m-%Y') as month , sum(sales) as revenue
    from orders group by month order by month)
select month, revenue, revenue - lag(revenue) over (order by month) as growth
,round((revenue - lag(revenue) over (order by month)) * 100 / lag(revenue) over (order by month) ,2)
as growth_percent
from m_o_m ;


-- -----------------------------------------------------
-- Phase 8: Payment Analysis
-- -----------------------------------------------------


-- Which payment mode generated the highest revenue?

select Payment_mode , sum(sales) as revenue from orders
group by Payment_mode order by revenue desc limit 1 ;

-- Which payment mode processed the most orders?

select Payment_mode , count(*) as cnt from orders
group by Payment_mode order by cnt desc limit 1 ;


-- What percentage of revenue comes from each payment mode?

with percent as 
	(select Payment_mode , sum(sales) as revenue from orders
	group by Payment_mode order by Payment_mode)
select Payment_mode, revenue , round(revenue * 100 / sum(revenue) over (), 2)
as percentage_of_revenue
from percent ;

-- Which city uses each payment mode the most?

with city_mode_rank as
	(select c.City as city , o.Payment_mode as payment_mode , count(*) as cnt, rank() over 
	( partition by city order by count(*)  desc ) as rnk
	from orders o join customer c
	on o.Customer_ID = c.customer_id 
	group by city, payment_mode)
select city, payment_mode, cnt  from city_mode_rank
where rnk = 1;


-- -----------------------------------------------------
-- Phase 9: Multi-Table Joins 
-- -----------------------------------------------------

-- Show each order with customer name.

select o.order_id , c.Customer_Name from orders o join customer c 
on o.Customer_ID = c.customer_id 
 ;

-- Show each order with product name.

select o.order_id , p.product_name from orders o join product p 
on o.Product_ID = p.product_id
;

-- Show each order with salesperson name.

select o.order_id , s.Salesperson from orders o join sales_persons s
on o.Salesperson_ID = s.sales_persons_id ;

-- Show complete order details using all four tables.

select * from customer c join orders o on c.customer_id = o.Customer_ID
join product p on o.Product_ID = p.product_id join sales_persons s
on o.Salesperson_ID = s.sales_persons_id;

-- Find customers who never placed an order.

select c.customer_id , c.Customer_Name from customer c left join
orders o  on o.Customer_ID = c.customer_id 
where c.customer_id is null;

-- Find products that were never sold.

select p.product_id , p.product_name 
from product p  left join orders o
on o.Product_ID = p.product_id
where  p.product_id is null;

-- -----------------------------------------------------
-- Phase 10: Advanced SQL  
-- -----------------------------------------------------

-- Top 5 customers by revenue.

select o.Customer_ID , c.Customer_Name , sum(o.sales) as revenue
from orders o join customer c 
on o.Customer_ID = c.customer_id 
group by o.Customer_ID , c.Customer_Name
order by revenue desc limit 5;

-- Top 5 products by revenue.

select o.Product_ID , p.product_name, sum(o.sales) as revenue 
from orders o join product p 
on o.Product_ID = p.product_id
group by o.Product_ID , p.product_name
order by revenue desc limit 5 ;

-- Top 5 cities by revenue.

select c.City , sum(o.sales) as revenue 
from orders o join customer c 
on o.Customer_ID = c.customer_id 
group by c.City
order by revenue desc limit 5;

-- Rank customers using RANK().

select o.Customer_ID , c.Customer_Name , sum(o.sales) as revenue,
rank() over ( order by sum(o.sales) desc ) as rnk
from orders o join customer c 
on o.Customer_ID = c.customer_id 
group by o.Customer_ID , c.Customer_Name;


-- Rank products within each category.

select o.Product_ID , p.category , p.product_name, sum(o.sales) as revenue ,
rank () over ( partition by p.category order by sum(o.sales) desc ) as rnk
from orders o join product p 
on o.Product_ID = p.product_id
group by o.Product_ID , p.category , p.product_name ;


-- Calculate each customers revenue share.

with revenue_share as 
	(select o.Customer_ID , c.Customer_Name , sum(o.sales) as revenue
	from orders o join customer c 
	on o.Customer_ID = c.customer_id 
	group by o.Customer_ID , c.Customer_Name
    order by o.Customer_ID)
 select Customer_ID , Customer_Name , revenue , round(revenue *100 / sum(revenue) over (), 2)
 as revenue_share_percent
 from revenue_share;
 
-- Classify customers into Gold, Silver, Bronze using CASE.


with revenue_share as 
	(select o.Customer_ID , c.Customer_Name , sum(o.sales) as revenue
	from orders o join customer c 
	on o.Customer_ID = c.customer_id 
	group by o.Customer_ID , c.Customer_Name
    order by o.Customer_ID)
 select Customer_ID , Customer_Name , revenue ,
	case 
		WHEN revenue < 10000 then 'Bronze'
        when revenue < 100000 then 'Silver'
        else 'Gold'
	end as revenue_group
from revenue_share;

-- Calculate cumulative monthly revenue.

with cmr as 
	(select date_format(order_date, '%m-%Y') as month , sum(sales) as revenue
	from orders 
	group by month order by month)
select month, sum(revenue) over (order by month) as cumulative_monthly_revenue
from cmr;


-- Calculate month-over-month revenue growth.

with m_o_m as 
	(select date_format(order_date, '%m-%Y') as month , sum(sales) as revenue
	from orders 
	group by month order by month)
select month,  revenue, revenue - lag(revenue) over (order by month) as month_over_over_growth
from m_o_m;