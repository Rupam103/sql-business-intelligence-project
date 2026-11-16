-- selecting database
use northwind_db;

-- order line view
-- management needs one consistent source for every value calculation
create view vw_northwind_order_lines as
select
	od.orderdetailid as order_detail_id,
    o.orderid as order_id,
    o.orderdate as order_date,
    c.customerid as customer_id,
    c.customername as customer_name,
    c.country as customer_country,
    e.employeeid as employee_id,
    concat(e.firstname, ' ', e.lastname) as employee_name,
    s.shipperid as shipper_id,
    s.shippername as shipper_name,
    p.productid as product_id,
    p.productname as product_name,
    p.categoryid as category_id,
    ca.categoryname as category_name,
    su.supplierid as supplier_id,
    su.suppliername as supplier_name,
    p.price,
    od.quantity,
    p.price * od.quantity as estimated_line_value
from orderdetails as od
join orders as o on od.orderid = o.orderid
join customers as c on o.customerid = c.customerid
join employees as e on o.employeeid = e.employeeid
join shippers as s on o.shipperid = s.shipperid
join products as p on od.productid = p.productid
join categories as ca on p.categoryid = ca.categoryid
join suppliers as su on p.supplierid = su.supplierid;

-- order summary view
-- account managers need order values without duplicating orders across products
create view vw_northwind_order_summary as
select
	order_id,
    order_date,
    customer_id,
    customer_name,
    customer_country,
    employee_id,
    employee_name,
    shipper_id,
    shipper_name,
    sum(estimated_line_value) as estimated_order_value,
    count(*) as order_line_count,
    count(distinct product_id) as distinct_product_count
from vw_northwind_order_lines
group by
	order_id,
    customer_id,
    employee_id,
    shipper_id;

-- monthly sales momentum
-- management wants to know whether sales activity strengthened over the completed months
with monthly_sales as
(
	select
		date_format(order_date, '%Y-%m-%01') as month_start,
		count(*) as order_count,
		count(distinct customer_id) as ordering_customers,
		sum(estimated_order_value) as estimated_value,
		avg(estimated_order_value) as average_order_value
	from vw_northwind_order_summary
	group by date_format(order_date, '%Y-%m-%01')
),
monthly_comparison as
(
	select 
		*,
		lag(estimated_value) over(order by month_start) as previous_month_value
	from monthly_sales
)
select
	month_start,
    order_count,
    ordering_customers,
    round(estimated_value, 2) as estimated_value,
    round(average_order_value, 2) as average_order_value,
    round(100 * (estimated_value - previous_month_value) / nullif(previous_month_value, 0), 2) as mom_value_change_pct
from monthly_comparison
order by month_start;

-- markets (countries) with an established customer base
-- management needs markets supported by multiple purchasing customers rather than a single large account
with all_value as
(
	select 
		sum(estimated_order_value) as total_value
	from vw_northwind_order_summary
),
qualifying_markets as
(
	select
		customer_country,
		count(distinct customer_id) as ordering_customers,
		count(*) as order_count,
		sum(estimated_order_value) as estimated_value,
		avg(estimated_order_value) as average_order_value
	from vw_northwind_order_summary
	group by customer_country
	having
		count(distinct customer_id) >= 5
		and count(*) >= 10
)
select
	q.customer_country,
    q.ordering_customers,
    q.order_count,
    round(q.estimated_value, 2) as estimated_value,
    round(q.average_order_value, 2) as average_order_value,
    round(100 * q.estimated_value / a.total_value, 2)as share_of_all_value_pct
from qualifying_markets as q
cross join all_value as a
order by
	round(q.estimated_value, 2) desc,
    q.customer_country;

-- rank valueable customers within each country
with customer_value as
(
	select
		customer_country as country,
		customer_id,
		customer_name,
		sum(estimated_order_value) as estimated_value
	from vw_northwind_order_summary
	group by
		customer_country,
		customer_id
),
country_ranks as
(
	select 
		*,
        dense_rank() over(partition by country order by estimated_value desc) as country_value_rank,
        sum(estimated_value) over(partition by country) as country_value
	from customer_value
)
select
	country,
    customer_id,
    customer_name, 
    round(estimated_value, 2) as estimated_value,
    country_value_rank,
    round(100 * estimated_value / country_value, 2) as share_of_country_value_pct
from country_ranks
where country_value_rank <= 5
order by
	country,
    country_value_rank,
    customer_id;

-- leading products within each category
with product_values as
(
	select
		category_id,
		category_name,
		product_id,
		product_name,
		count(distinct order_id) as order_count,
		count(distinct customer_id) as purchasing_customers,
		sum(quantity) as recorded_quantity,
		sum(estimated_line_value) as estimated_value
	from vw_northwind_order_lines
	group by
		category_id,
		product_id
),
product_ranks as
(
	select
		*,
        dense_rank() over(partition by category_id order by estimated_value desc) as category_value_rank,
        sum(estimated_value) over(partition by category_id) as category_value
	from product_values
)
select
	category_id,
    category_name,
    product_id,
    product_name,
    order_count,
    purchasing_customers,
    recorded_quantity,
    round(estimated_value, 2) as estimated_value,
    category_value_rank,
    round(100 * estimated_value / category_value, 2) as category_value_pct
from product_ranks
where category_value_rank <= 5
order by
	category_id,
    category_value_rank,
    product_id;
    
-- supplier concentration within categories
with supplier_values as
(
	select
		category_id,
		category_name,
		supplier_id,
		supplier_name,
		count(distinct product_id) as sold_product_count,
		sum(estimated_line_value) as estimated_value
	from vw_northwind_order_lines
	group by
		category_id,
		supplier_id
),
supplier_rank as
(
	select
		*,
        dense_rank() over(partition by category_id order by estimated_value desc) as supplier_rank,
        sum(estimated_value) over(partition by category_id) as category_value
	from supplier_values
)
select
	category_id,
    category_name,
    supplier_id,
    supplier_name,
    sold_product_count,
    round(estimated_value, 2) as estimated_value,
    supplier_rank,
    round(100 * estimated_value / category_value, 2) as supplier_category_share_pct,
    case
		when estimated_value >= 0.5 * category_value then 'Concentrated'
        else 'Distributed'
	end as conentration_flag
from supplier_rank
where supplier_rank = 1
order by
	category_id,
    supplier_rank

























