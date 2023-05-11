#1.how many rolls where orderd

select count(roll_id) from customer_orders;
select sum(roll_id) from customer_orders; #it's wrong becouse calaculate roll id
#how many unique customer orderd

select count(distinct(customer_id)) from customer_orders;

#3.how many successful orders where driver delivered;

select driver_id, count( order_id) from driver_order where cancellation not in
('cancellation','customer cancellation') group by driver_id;

select driver_id, count(distinct order_id) from driver_order where cancellation not in
('cancellation','customer cancellation') group by driver_id;

#4 how many of each type of rolls deliverde;

select roll_id,count(roll_id) from  customer_orders1 where order_id in
(select order_id from
(select *,case when cancellation in ('cancellation','customer cancellation') then 'c' else 'nc' end as cancellation_detiels
from driver_order) as a where cancellation_detiels = 'nc') group by roll_id;

#5 how many non-veg and veg roll where ordered by each customer
select a.*,b.roll_name from 
(select customer_id,roll_id,count(roll_id) cnt from customer_orders1 group by customer_id,roll_id) as a
inner join rolls as b on a.roll_id = b.roll_id;

#6 what was the max number of rolls delivered in single order;

select * from
(select *, rank() over(order by cnt desc) as rnk from 
(select order_id,count(roll_id) as cnt from
(select * from customer_orders1 where order_id in
(select order_id from
(select *,case when cancellation in ('cancellation','customer cancellation') then 'c' else 'nc' end as cancellation_detiels
from driver_order) as a  where cancellation_detiels = 'nc')) as b group by order_id) as c) as d where rnk = 1;

#7 for each customer, how many delivered rols at lest 1 change and how many no charges;

with temp_customer_order (order_id, customer_id, roll_id, not_include_items, extra_items_included, order_date) as
(
select order_id, customer_id, roll_id,
case when not_include_items is null or not_include_items = ' ' then '0' else not_include_items end
as new_not_include_items,
case when extra_items_included  is null or extra_items_included = ' ' or extra_items_included = 'NaN' 
or extra_items_included = 'NULL' then '0' else extra_items_included end as new_extra_items_included,
order_date
from customer_orders1
),
temp_driver_order (order_id, driver_id, pickup_time, distance, duration,new_cancelation) as
(
select order_id, driver_id, pickup_time, distance, duration,
case when cancellation in ('Cancellation','customer_Cancellation') then '0' else '1' end
as new_cancelation from driver_order)

select customer_id,chg_or_nochg,count(order_id) from 
(select * ,case when not_include_items = '0' and extra_items_included = '0' then 'no change' else 'change' end as chg_or_nochg
from temp_customer_order where order_id in(
select order_id from temp_driver_order where new_cancelation != '0')) as a
group by customer_id,chg_or_nochg;

#8

with temp_customer_order (order_id, customer_id, roll_id, not_include_items, extra_items_included, order_date) as
(
select order_id, customer_id, roll_id,
case when not_include_items is null or not_include_items = ' ' then '0' else not_include_items end
as new_not_include_items,
case when extra_items_included  is null or extra_items_included = ' ' or extra_items_included = 'NaN' 
or extra_items_included = 'NULL' then '0' else extra_items_included end as new_extra_items_included,
order_date
from customer_orders1
),
temp_driver_order (order_id, driver_id, pickup_time, distance, duration,new_cancelation) as
(
select order_id, driver_id, pickup_time, distance, duration,
case when cancellation in ('Cancellation','customer_Cancellation') then '0' else '1' end
as new_cancelation from driver_order)

select chg_or_nochg,count(chg_or_nochg) from 
(select * ,case when not_include_items != '0' and extra_items_included != '0' 
then 'both is exc' else 'either 1 inc or exc'end as chg_or_nochg
from temp_customer_order where order_id in(
select order_id from temp_driver_order where new_cancelation != '0')) as a
group by chg_or_nochg;

#9 what was the total number of rolls orders for each hours of the day?


select hours_bucket,count(hours_bucket) from
(SELECT *, CONCAT(HOUR(order_date), '-', HOUR(order_date) + 1) AS hours_bucket FROM customer_orders1)
as a group by hours_bucket;


#what was the number of order for each day of the week?


SELECT dow, COUNT(DISTINCT order_id) FROM
(SELECT *, dayname(order_date) AS dow FROM customer_orders) a
GROUP BY dow;




