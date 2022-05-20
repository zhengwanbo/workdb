

DECLARE
  l_TABLE_NAME        DBMS_QUOTED_ID :='ssb_lineorder2';
  l_CREDENTIAL_NAME   DBMS_QUOTED_ID := 'OBJ_STORE_CRED';
  l_FILE_URI_LIST     CLOB :=
    q'['https://objectstorage.ap-seoul-1.oraclecloud.com/n/ocichina001/b/bucket-AD/o/ssb100_data_parquet/lineorder.tbl.*.parquet']';
  l_FIELD_LIST        CLOB := null;
  l_FORMAT            CLOB := '{"schema":"first","type":"parquet"}';
  l_OPERATION_ID      NUMBER ; /* OUT */
BEGIN
  "C##CLOUD$SERVICE"."DBMS_CLOUD"."COPY_DATA"
  ( TABLE_NAME        => l_TABLE_NAME
   ,CREDENTIAL_NAME   => l_CREDENTIAL_NAME
   ,FILE_URI_LIST     => l_FILE_URI_LIST
   ,FIELD_LIST        => l_FIELD_LIST
   ,FORMAT            => l_FORMAT
   ,OPERATION_ID      => l_OPERATION_ID
  );
END;
/

drop table ssb_lineorder_ext_parquet_snappy;

BEGIN
   DBMS_CLOUD.CREATE_EXTERNAL_TABLE(
    table_name =>'ssb_lineorder_ext_parquet_snappy',
    credential_name =>'OBJ_STORE_CRED',
    file_uri_list =>'
https://objectstorage.ap-seoul-1.oraclecloud.com/n/ocichina001/b/bucket-AD/o/ssb100_data_parquet/lineorder.tbl.*.parquet',
    format =>  '{"type":"parquet", "schema": "first"}'
 );
END;
/

desc ssb_lineorder_ext_parquet_snappy;
select count(*) from ssb_lineorder_ext_parquet_snappy;

set timing on;
drop TABLE ssb_lineorder;
truncate table ssb_lineorder;

-- 3OCPU
create table ssb_lineorder as select * from ssb_lineorder_ext_parquet where 1=0;
insert into ssb_lineorder select * from ssb_lineorder_ext_parquet;
--600037902 rows created.
--Elapsed: 00:12:11.70

truncate table ssb_lineorder;
insert into ssb_lineorder select /*+ parallel(a,16) */  * from ssb_lineorder_ext_parquet a;
--600037902 rows created.
--Elapsed: 00:12:15.61

truncate table ssb_lineorder;
insert /*+ parallel(a,8) */  into ssb_lineorder a select * from ssb_lineorder_ext_parquet;
--600037902 rows created.
--Elapsed: 00:12:16.03

drop table ssb_lineorder_ext_parquet_gz;

BEGIN
   DBMS_CLOUD.CREATE_EXTERNAL_TABLE(
    table_name =>'ssb_lineorder_ext_parquet_gz',
    credential_name =>'OBJ_STORE_CRED',
    file_uri_list =>'
https://objectstorage.ap-seoul-1.oraclecloud.com/n/ocichina001/b/bucket-AD/o/ssb100_data_parquet_gz/lineorder.tbl.*.parquet',
    format =>  '{"type":"parquet", "schema": "first"}'
 );
END;
/

desc ssb_lineorder_ext_parquet_gz;
select count(*) from ssb_lineorder_ext_parquet_gz;

set timing on;
drop TABLE ssb_lineorder_2;

create table ssb_lineorder_2 as select * from ssb_lineorder_ext_parquet_gz where 1=0;
insert into ssb_lineorder_2 select * from ssb_lineorder_ext_parquet_gz;
--600037902 rows created.
--Elapsed: 00:12:41.99

truncate table ssb_lineorder_2;
insert /*+ parallel(a,8) */  into ssb_lineorder_2 a select * from ssb_lineorder_ext_parquet_gz;
--600037902 rows created.
--Elapsed: 00:12:15

truncate table ssb_lineorder_2;
insert /*+ APPEND */ into ssb_lineorder_2 select /*+ parallel(a,8) */ * from ssb_lineorder_ext_parquet_gz a;
--600037902 rows created.
--Elapsed: 00:12:17.67

--1.读和写都指定并行模式
ALTER SESSION ENABLE PARALLEL DML;
INSERT /*+ PARALLEL (target, 8) */ INTO ssb_lineorder_2 target
SELECT /*+ PARALLEL (source, 8) */ * FROM ssb_lineorder_ext_parquet_gz source;
--600037902 rows created.
--Elapsed: 00:12:11.21

--2.使用直接路径INSERT
INSERT /*+ APPEND */ INTO ssb_lineorder_2
SELECT * FROM ssb_lineorder_ext_parquet_gz;

--3.加载中禁用收集统计信息，加载表后再收集统计信息
 DBMS_STATS.gather_table_stats
(ownname => 'DWH',tabname => 'T1' ,no_invalidate => FALSE);

select sum(bytes)/(1024*1024*1024) GB from dba_segments where owner='ADMIN' and segment_name='SSB_LINEORDER';

select table_name,compression,compress_for from user_tables;


drop table ssb_lineorder_csv_ext;

BEGIN
   DBMS_CLOUD.CREATE_EXTERNAL_TABLE(
    table_name =>'ssb_lineorder_csv_ext',
    credential_name =>'OBJ_STORE_CRED',
    file_uri_list =>'
https://objectstorage.ap-seoul-1.oraclecloud.com/n/ocichina001/b/bucket-AD/o/ssb100_data_csv/lineorder.tbl.*',
 format => json_object('delimiter' value '|', 'quote' value '\"', 'rejectlimit' value '0', 'trimspaces' value 'rtrim', 'ignoreblanklines' value 'false', 'ignoremissingcolumns' value 'true'),
   column_list => ' 
    LO_ORDERKEY            NUMBER(19),
    LO_LINE                VARCHAR2(4000),
    LO_CUSTKEY             NUMBER(10),
    LO_PARTKEY             NUMBER(10),
    LO_SUPPKEY             NUMBER(10),
    LO_ORDERDATE           NUMBER(10),
    LO_ORDERPRIORITY       VARCHAR2(4000),
    LO_SHIPPRIORITY        NUMBER(10),
    LO_QUANTITY            NUMBER(10),
    LO_EXTENDEDPRICE       BINARY_FLOAT,
    LO_ORDTOTALPRICE       BINARY_FLOAT ,
    LO_DISCOUNT            BINARY_FLOAT,
    LO_REVENUE             BINARY_FLOAT,
    LO_SUPPLYCOST          BINARY_FLOAT,
    LO_TAX                 BINARY_FLOAT,
    LO_COMMITDATE          NUMBER(10),
    LO_SHIPMODE            VARCHAR2(4000) 
 '
 );
end;
/

desc ssb_lineorder_csv_ext;
select count(*) from ssb_lineorder_csv_ext;

set timing on;
drop TABLE ssb_lineorder_3;

create table ssb_lineorder_3 as select * from ssb_lineorder_csv_ext where 1=0;
insert into ssb_lineorder_3 select * from ssb_lineorder_csv_ext;
--600037902 rows created.
--Elapsed: 00:13:24.48

select sum(bytes)/(1024*1024*1024) GB from dba_segments where owner='ADMIN' and segment_name='SSB_LINEORDER_3';

truncate table ssb_lineorder_3;
insert into ssb_lineorder_3 select * from ssb_lineorder_csv_ext;
