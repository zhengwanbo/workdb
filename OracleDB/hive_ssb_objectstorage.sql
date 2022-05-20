
drop table ssb_customer_txt_obj;
create external table ssb_customer_txt_obj(
    c_custkey bigint, 
    c_name string,
    c_address string,
    c_city string,
    c_nation string,
    c_region string ,
    c_phone string,
    c_mktsegment string
)
row format delimited
fields terminated by '|'
stored as textfile
location 'oci://bigdata@ocichina001/ssb100_data/customer';

drop table ssb_date_txt_obj;
create external table ssb_date_txt_obj(
    d_datekey date, 
    d_date string,
    d_dayofweek string,
    d_month string,
    d_year bigint,
    d_yearmonthnum bigint,
    d_yearmonth string, 
    d_daynuminweek bigint, 
    d_daynuminmonth bigint, 
    d_daynuminyear bigint, 
    d_monthnuminyear bigint, 
    d_weeknuminyear bigint, 
    d_sellingseason string, 
    d_lastdayinweekfl string, 
    d_lastdayinmonthfl string, 
    d_holidayfl string, 
    d_weekdayfl string
)
row format delimited
fields terminated by '|'
stored as textfile
location 'oci://bigdata@ocichina001/ssb100_data/dwdate';


create external table ssb_lineorder_txt_obj(
    lo_orderkey bigint, 
    lo_linenumber bigint, 
    lo_custkey bigint, 
    lo_partkey bigint, 
    lo_suppkey bigint, 
    lo_orderdate date, 
    lo_orderpriority string , 
    lo_shippriority string , 
    lo_quantity bigint, 
    lo_extendedprice bigint, 
    lo_ordtotalprice bigint, 
    lo_discount bigint, 
    lo_revenue bigint, 
    lo_supplycost bigint, 
    lo_tax bigint, 
    lo_commitdate string, 
    lo_shipmode string
) 
row format delimited
fields terminated by '|'
stored as textfile
location 'oci://bigdata@ocichina001/ssb100_data/lineorder';

create external table ssb_part_txt_obj(
    p_partkey bigint, 
    p_name string , 
    p_mfgr string , 
    p_category string , 
    p_brand string , 
    p_color string , 
    p_type string , 
    p_size bigint, 
    p_container string
) 
row format delimited
fields terminated by '|'
stored as textfile
location 'oci://bigdata@ocichina001/ssb100_data/part';

create external table ssb_supplier_txt_obj(
    s_suppkey bigint, 
    s_name string , 
    s_address string , 
    s_city string , 
    s_nation string , 
    s_region string , 
    s_phone string
) 
row format delimited
fields terminated by '|'
stored as textfile
location 'oci://bigdata@ocichina001/ssb100_data/supplier';

create table ssb_lineorder_flat_txt_obj (
  lo_orderkey bigint ,
  lo_orderdate date ,
  lo_linenumber bigint ,
  lo_custkey bigint ,
  lo_partkey bigint ,
  lo_suppkey bigint ,
  lo_orderpriority string ,
  lo_shippriority string ,
  lo_quantity bigint ,
  lo_extendedprice bigint ,
  lo_ordtotalprice bigint ,
  lo_discount bigint ,
  lo_revenue bigint ,
  lo_supplycost bigint ,
  lo_tax bigint,
  lo_commitdate string ,
  lo_shipmode string ,
  c_name string ,
  c_address string ,
  c_city string ,
  c_nation string ,
  c_region string ,
  c_phone string ,
  c_mktsegment string ,
  s_name string ,
  s_address string ,
  s_city string ,
  s_nation string ,
  s_region string ,
  s_phone string ,
  p_name string ,
  p_mfgr string ,
  p_category string ,
  p_brand string ,
  p_color string ,
  p_type string ,
  p_size bigint ,
  p_container string 
) 
stored as orc
location 'oci://bigdata@ocichina001/ssb100_data/ssb_lineorder_flat';


set timing on;

select count(*) from ssb_customer_txt_obj;
select count(*) from ssb_date_txt_obj;
select count(*) from ssb_lineorder_txt_obj;
select count(*) from ssb_part_txt_obj;
select count(*) from ssb_supplier_txt_obj;


--q1.1 
select sum(lo_revenue) as revenue
from ssb_lineorder_txt_obj join ssb_date_txt_obj on lo_orderdate = d_datekey
where d_year = 1993 and lo_discount between 1 and 3 and lo_quantity < 25;

--q1.2
select sum(lo_revenue) as revenue
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
where d_yearmonthnum = 199401
and lo_discount between 4 and 6
and lo_quantity between 26 and 35;

--q1.3
select sum(lo_revenue) as revenue
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
where d_weeknuminyear = 6 and d_year = 1994
and lo_discount between 5 and 7
and lo_quantity between 26 and 35;


--q2.1
select sum(lo_revenue) as lo_revenue, d_year, p_brand
from ssb_lineorder_txt_obj
inner join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_part_txt_obj on lo_partkey = p_partkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
where p_category = 'mfgr#12' and s_region = 'america'
group by d_year, p_brand
order by d_year, p_brand;

--q2.2
select sum(lo_revenue) as lo_revenue, d_year, p_brand
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_part_txt_obj on lo_partkey = p_partkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
where p_brand1 between 'mfgr#2221' and 'mfgr#2228' and s_region = 'asia'
group by d_year, p_brand
order by d_year, p_brand;

--q2.3
select sum(lo_revenue) as lo_revenue, d_year, p_brand
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_part_txt_obj on lo_partkey = p_partkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
where p_brand1 = 'mfgr#2239' and s_region = 'europe'
group by d_year, p_brand
order by d_year, p_brand;


--q3.1
select c_nation, s_nation, d_year, sum(lo_revenue) as lo_revenue
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_customer_txt_obj on lo_custkey = c_custkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
where c_region = 'asia' and s_region = 'asia'
and d_year >= 1992 and d_year <= 1997
group by c_nation, s_nation, d_year
order by d_year asc, lo_revenue desc;

--q3.2
select c_city, s_city, d_year, sum(lo_revenue) as lo_revenue
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_customer_txt_obj on lo_custkey = c_custkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
where c_nation = 'united states' and s_nation = 'united states'
and d_year >= 1992 and d_year <= 1997
group by c_city, s_city, d_year
order by d_year asc, lo_revenue desc;

--q3.3
select c_city, s_city, d_year, sum(lo_revenue) as lo_revenue
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_customer_txt_obj on lo_custkey = c_custkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
where (c_city='united ki1' or c_city='united ki5')
and (s_city='united ki1' or s_city='united ki5')
and d_year >= 1992 and d_year <= 1997
group by c_city, s_city, d_year
order by d_year asc, lo_revenue desc;

--q3.4
select c_city, s_city, d_year, sum(lo_revenue) as lo_revenue
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_customer_txt_obj on lo_custkey = c_custkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
where (c_city='united ki1' or c_city='united ki5') and (s_city='united ki1' or s_city='united ki5') and d_yearmonth
 = 'dec1997'
group by c_city, s_city, d_year
order by d_year asc, lo_revenue desc;


--q4.1
select d_year, c_nation, sum(lo_revenue) - sum(lo_supplycost) as profit
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_customer_txt_obj on lo_custkey = c_custkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
join ssb_part_txt_obj on lo_partkey = p_partkey
where c_region = 'america' and s_region = 'america' and (p_mfgr = 'mfgr#1' or p_mfgr = 'mfgr#2')
group by d_year, c_nation
order by d_year, c_nation;

--q4.2
select d_year, s_nation, p_category, sum(lo_revenue) - sum(lo_supplycost) as profit
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_customer_txt_obj on lo_custkey = c_custkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
join ssb_part_txt_obj on lo_partkey = p_partkey
where c_region = 'america'and s_region = 'america'
and (d_year = 1997 or d_year = 1998)
and (p_mfgr = 'mfgr#1' or p_mfgr = 'mfgr#2')
group by d_year, s_nation, p_category
order by d_year, s_nation, p_category;

--q4.3
select d_year, s_city, p_brand1, sum(lo_revenue) - sum(lo_supplycost) as profit
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_customer_txt_obj on lo_custkey = c_custkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
join ssb_part_txt_obj on lo_partkey = p_partkey
where c_region = 'america'and s_nation = 'united states'
and (d_year = 1997 or d_year = 1998)
and p_category = 'mfgr#14'
group by d_year, s_city, p_brand1
order by d_year, s_city, p_brand1;