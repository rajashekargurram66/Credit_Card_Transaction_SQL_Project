
---- 1. write a query to print top 5 cities with highest spends and their 
 --      percentage contribution of total credit card spends????

with cte1 as(select city, sum(amount) as total_spend
from
credit_card_transations
group by city)
,total_spend as (select sum(cast (amount as bigint)) as total_amount from credit_card_transations)
select top 5 cte1.*, round(total_spend*1.0/total_amount * 100,2) as total_contribution
from cte1 inner join total_spend on 1=1
order by total_spend desc;


----- 2. write a query to print highest spend month and amount spent in that month for each card type

with cte as (select card_type,DATEPART(Year, transaction_date) as yt,
datepart(month,transaction_date) mn,sum(amount) as Total_amount 
from credit_card_transations
group by card_type, DATEPART(Year, transaction_date),datepart(month,transaction_date))
select * from (select *,
rank() over(partition by card_type order by Total_amount desc) as rn
from cte)a where  rn=1

---- 3. write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of  1,000,000 total spends(We should have 4 rows in the o/p one for each card type)

with cte as (select *,sum(amount) over(partition by card_type order by transaction_date,city) as total_spend from 
credit_card_transations)
select * from(select *, rank() over(partition by card_type order by total_spend, amount)as rn from cte 
where total_spend>=1000000)q where rn=1;

---- 4. write a query to find city which had lowest percentage spend for gold card type

with cte as (select city, card_type ,sum(amount) as amount, sum(case when card_type='Gold' then amount end) as Gold_amount from
credit_card_transations
group by card_type, city)
select top 1 city, sum(amount)*1.0/sum(Gold_amount) as gold_ratio
from cte
group by city 
having sum(Gold_amount) is not null
order by gold_ratio

select distinct exp_type from credit_card_transations;


---- 5.write a query to print 3 columns: city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)

with cte as (select city, exp_type, sum(amount) as total_amount 
from 
credit_card_transations
group by city, exp_type
)
select
city, min(case when rn_desc=1 then exp_type end) as highest_expense_type
, max(case when rn_asc=1 then exp_type end ) as lowest_expense_type 
from
(select *
,rank() over(partition by city order by total_amount desc) as rn_desc
,rank() over(partition by city order by total_amount asc) as rn_asc
from cte) a
group by city;


---- 6. write a query to find percentage contribution of spends by females for each expense type

select exp_type,
round(sum(case when gender='F' then amount else 0 end)*0.1/sum(amount), 4) as total_female_contribution
from 
credit_card_transations
group by exp_type
order by total_female_contribution desc


---- 7. which card and expense type combination saw highest month over month growth in Jan-2014


with cte as(select card_type, exp_type, sum(amount) as amount, 
datepart(year, transaction_date) as yt, datepart(month,transaction_date ) as mt
from 
credit_card_transations
group by card_type,exp_type,datepart(year, transaction_date), datepart(month,transaction_date))
select top 1*, round((amount-prev_month_spent)*1.0/prev_month_spent,2) as month_growth from(select *,
lag(amount) over(partition by card_type, exp_type order by yt,mt) as prev_month_spent
from cte) A
where prev_month_spent is not null and yt=2014 and mt=1
order by month_growth desc


---- 8. during weekends which city has highest total spend to total no of transcations ratio 

select city, sum(amount)*10.0/count(*) as amount
from credit_card_transations
where datepart(WEEKDAY, transaction_date) in (1,7)
group by city
order by amount desc

---- 9. which city took least number of days to reach its
---     500th transaction after the first transaction in that city?

with cte as (select * ,
row_number() over(partition by city order by transaction_date) as rn
from credit_card_transations)
select city, datediff(day, min(transaction_date), max(transaction_date)) as date_diff
from cte
where rn = 1 or rn = 500 
group by city
having count(*)= 2
order by date_diff




select * from credit_card_transations































































