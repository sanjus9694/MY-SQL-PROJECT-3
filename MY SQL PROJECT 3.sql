## Provide the list of markets in which customer "Atliq Exclusive" operates its business in the APAC region
select distinct(market) as "market" from dim_customer where customer= "atliq exclusive" AND region= "APAC";




## Provide a report with all the unique product counts for each segment and sort them in descending order of product counts
SELECT distinct(COUNT(PRODUCT)) as "product_count", segment from dim_product group by segment order by count(product) desc;




## Generate a report which contains the top 5 customers who received an average high pre_invoice_discount_pct for the fiscal year 2021 and in the Indian market. 
with ct as(
select d.customer_code as "customer_code", d.customer as "customer", avg(f.pre_invoice_discount_pct)*100 as "average_discount_percentage", dense_rank() over(order by avg(f.pre_invoice_discount_pct)) as "rank" from dim_customer d inner join fact_pre_invoice_deductions f
on d.customer_code = f.customer_code
where f.fiscal_year= 2021 AND market= "India"
group by d.customer_code, d.customer)

select ct.customer_code, ct.customer, ct.average_discount_percentage from ct 
where ct.rank <= 5;





## Get the complete report of the Gross sales amount for the customer “Atliq Exclusive” for each month
select month(s.date) as "month", year(s.date) as "year", p.gross_price*s.sold_quantity AS "Gross sales amount" from fact_gross_price p  inner join fact_sales_monthly s
on p.product_code = s.product_code
inner join dim_customer c
on c.customer_code= s.customer_code
where customer= "Atliq exclusive";




## In which quarter of 2020, got the maximum total_sold_quantity? 
select quarter(date), sum(sold_quantity) from fact_sales_monthly
where year(date)= 2020
group by quarter(date)
order by sum(sold_quantity) desc;





## Which channel helped to bring more gross sales in the fiscal year 2021 and the percentage of contribution?
with ct as
(select c.channel as "channel", sum(p.gross_price*s.sold_quantity) as "grosssales" from fact_gross_price p inner join fact_sales_monthly s
on p.product_code = s.product_code
inner join dim_customer c
on c.customer_code = s.customer_code
group by c.channel)
select ct.channel, ct.grosssales, ct.grosssales/sum(grosssales) OVER ()*100 AS "Percent" from ct
group by ct.channel;




##Get the Top 3 products in each division that have a high total_sold_quantity in the fiscal_year 2021?
with ct as(
select d.division as "division", d.product_code as "code", d.product as "product", sum(f.sold_quantity) AS "total_sold_quantity", dense_rank() over(partition by d.division order by sum(f.sold_quantity) desc) as "rank_order" from fact_sales_monthly f  inner join dim_product d
on f.product_code = d.product_code
group by d.division, d.product_code, d.product)
select ct.division, ct.code, ct.product, ct.total_sold_quantity, ct.rank_order from ct where rank_order<=3;

