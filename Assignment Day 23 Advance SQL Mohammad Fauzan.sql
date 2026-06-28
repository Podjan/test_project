select * from employees_td et;
select * from order_details_td odt;
select * from orders_td ot;
select * from products_td pt;

--nomor 1
alter table orders_td  alter column order_date type date
using to_date(order_date, 'YYYY-MM-DD');

alter table orders_td  alter column shipped_date type date 
using to_date(shipped_date, 'YYYY-MM-DD');

select avg(selisih) as avg_selisih from
(select ot.shipped_date, ot.order_date, (shipped_date - order_date) as selisih
from orders_td ot) as t1;

select avg(selisih) as average_durasi
from (select (shipped_date - order_date)::integer as selisih
from orders_td) as t1;

select avg(shipped_date  - order_date)
from orders_td;

-- udah coba 2 cara tapi hasilnya minus

select avg(freight_cost)
from orders_td;

--padahal enggak minus kalau coba pakai kolom lain

--nomor 2
select order_date, count(*) as jumlah_order
from orders_td 
group by order_date
order by jumlah_order desc
limit 1;

--nomor 3
select 
	shipper_name,
	sum (freight_cost / (unit_price * quantity - discount)) as rasio_ongkos
from orders_td ot
join order_details_td odt on ot.order_id = odt.order_id
group by shipper_name
order by rasio_ongkos desc;

--nomor 4
select 
	product_name,
	sum (unit_price * quantity - discount) as penjualan
from order_details_td odt
join products_td pt on odt.product_id = pt.product_id 
group by product_name
order by penjualan desc
limit 5;


select 
	product_name,
	sum (unit_price * quantity - discount) as penjualan
from order_details_td odt
join products_td pt on odt.product_id = pt.product_id 
group by product_name
order by penjualan
limit 5;

--nomor 5
select 
    to_char(order_date, 'YYYY-MM') as bulan,
    count(distinct odt.order_id) as total_pesanan,
    sum(unit_price * quantity) as penjualan_kotor,
    sum(unit_price * quantity - discount) as penjualan_bersih
from orders_td ot 
join order_details_td odt on ot.order_id = odt.order_id
group by bulan
order by bulan;

--nomor 6
with t1 as(
	select 
		extract(year from order_date) as tahun,
		sum (unit_price * quantity) as penjualan_kotor
	from orders_td ot 
	join order_details_td odt on ot.order_id = odt.order_id
	group by extract(year from order_date)
)
select 	tahun, 
		penjualan_kotor,
		lag(penjualan_kotor) over (order by tahun) as penjualan_tahun_sebelumnya,
  		round(((penjualan_kotor - lag(penjualan_kotor) over (order by tahun))
  		/ lag(penjualan_kotor) over (order by tahun) * 100)::numeric, 2) as growth
from t1 
order by tahun;

--nomor 7

select 
    employee_name,
    sum(unit_price * quantity - discount) as penjualan
from employees_td et 
join orders_td ot  on ot.employee_id = et.employee_id
join order_details_td odt on odt.order_id = ot.order_id
group by ot.employee_id, employee_name
order by penjualan desc;

--nomor8

select  
    extract(year from order_date) as tahun,
    category_name,
    sum(unit_price * quantity - discount) as penjualan
from orders_td ot
join order_details_td odt on ot.order_id = odt.order_id
join products_td pt on odt.product_id = pt.product_id
group by extract(year from order_date), pt.category_name
order by tahun asc, penjualan desc;