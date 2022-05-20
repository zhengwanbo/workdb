


cls_run /data/presto-server-0.251/bin/launcher stop
cls_run "source ~/.bash_profile && /data/presto-server-0.251/bin/launcher start"
cls_run "source ~/.bash_profile && /data/presto-server-0.251/bin/launcher status"

presto-cli --server bigdata-hadoop-1:8089 --catalog hive --schema ssb100_poc


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
select sum(lo_revenue) as lo_revenue, d_year, p_brand1
from ssb_lineorder_txt_obj
inner join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_part_txt_obj on lo_partkey = p_partkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
where p_category = 'mfgr#12' and s_region = 'america'
group by d_year, p_brand1
order by d_year, p_brand1;

--q2.2
select sum(lo_revenue) as lo_revenue, d_year, p_brand1
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_part_txt_obj on lo_partkey = p_partkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
where p_brand1 between 'mfgr#2221' and 'mfgr#2228' and s_region = 'asia'
group by d_year, p_brand1
order by d_year, p_brand1;

--q2.3
select sum(lo_revenue) as lo_revenue, d_year, p_brand1
from ssb_lineorder_txt_obj
join ssb_date_txt_obj on lo_orderdate = d_datekey
join ssb_part_txt_obj on lo_partkey = p_partkey
join ssb_supplier_txt_obj on lo_suppkey = s_suppkey
where p_brand1 = 'mfgr#2239' and s_region = 'europe'
group by d_year, p_brand1
order by d_year, p_brand1;


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