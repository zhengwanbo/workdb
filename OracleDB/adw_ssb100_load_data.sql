

set define off
begin
  DBMS_CLOUD.create_credential(
    credential_name => 'OBJ_STORE_CRED',
    username => 'oracleidentitycloudservice/bigdata.admin01',
    password => 'ddddd'
  );
end;
/
set define on

drop table SSB_CUSTOMER_EXT;

begin
 dbms_cloud.create_external_table(
    table_name =>'SSB_CUSTOMER_EXT',
    credential_name =>'OBJ_STORE_CRED',
    file_uri_list =>'https://objectstorage.ap-tokyo-1.oraclecloud.com/n/ocichina001/b/bigdata/o/ssb100_data/customer.tbl',
    format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true','delimiter' value '|',
        'dateformat' value 'YYYY-MM-DD', 'rejectlimit' value '0', 'trimspaces' value 'rtrim', 
        'ignoreblanklines' value 'false'),
    column_list => 'C_CUSTKEY NUMBER, 
    C_NAME VARCHAR2(25 BYTE),
    C_ADDRESS VARCHAR2(25 BYTE),
    C_CITY CHAR(10 BYTE),
    C_NATION CHAR(15 BYTE),
    C_REGION CHAR(12 BYTE) ,
    C_PHONE CHAR(15 BYTE),
    C_MKTSEGMENT CHAR(10 BYTE)'
 );
end;
/

select count(*) from ssb_customer_ext;

drop table ssb_customer;
create table ssb_customer as select * from ssb_customer_ext;
select count(*) from ssb_customer;


drop table SSB_DWDATE_EXT;

begin
 dbms_cloud.create_external_table(
    table_name =>'SSB_DWDATE_EXT',
    credential_name =>'OBJ_STORE_CRED',
    file_uri_list =>'https://objectstorage.ap-tokyo-1.oraclecloud.com/n/ocichina001/b/bigdata/o/ssb100_data/dates.tbl',
    format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true','delimiter' value '|',
        'dateformat' value 'YYYY-MM-DD', 'rejectlimit' value '0', 'trimspaces' value 'rtrim', 
        'ignoreblanklines' value 'false'),
    column_list => 'D_DATEKEY DATE, 
    D_DATE CHAR(18 BYTE),
    D_DAYOFWEEK CHAR(9 BYTE),
    D_MONTH CHAR(9 BYTE),
    D_YEAR NUMBER,
    D_YEARMONTHNUM NUMBER,
    D_YEARMONTH CHAR(7 BYTE), 
	D_DAYNUMINWEEK NUMBER, 
	D_DAYNUMINMONTH NUMBER, 
	D_DAYNUMINYEAR NUMBER, 
	D_MONTHNUMINYEAR NUMBER, 
	D_WEEKNUMINYEAR NUMBER, 
	D_SELLINGSEASON CHAR(12 BYTE), 
	D_LASTDAYINWEEKFL CHAR(1 BYTE), 
	D_LASTDAYINMONTHFL CHAR(1 BYTE), 
	D_HOLIDAYFL CHAR(1 BYTE), 
	D_WEEKDAYFL CHAR(1 BYTE)'
 );
end;
/


select count(*) from SSB_DWDATE_EXT;

drop table SSB_DWDATE;
create table SSB_DWDATE as select * from SSB_DWDATE_EXT;
select count(*) from SSB_DWDATE;


drop table SSB_LINEORDER_EXT;

begin
 dbms_cloud.create_external_table(
    table_name =>'SSB_LINEORDER_EXT',
    credential_name =>'OBJ_STORE_CRED',
    file_uri_list =>'https://objectstorage.ap-tokyo-1.oraclecloud.com/n/ocichina001/b/bigdata/o/ssb100_data/lineorder.tbl.*',
    format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true','delimiter' value '|',
        'dateformat' value 'YYYY-MM-DD', 'rejectlimit' value '0', 'trimspaces' value 'rtrim', 
        'ignoreblanklines' value 'false'),
    column_list => 'LO_ORDERKEY NUMBER, 
	LO_LINENUMBER NUMBER, 
	LO_CUSTKEY NUMBER, 
	LO_PARTKEY NUMBER, 
	LO_SUPPKEY NUMBER, 
	LO_ORDERDATE DATE, 
	LO_ORDERPRIORITY CHAR(15 BYTE) , 
	LO_SHIPPRIORITY CHAR(1 BYTE) , 
	LO_QUANTITY NUMBER, 
	LO_EXTENDEDPRICE NUMBER, 
	LO_ORDTOTALPRICE NUMBER, 
	LO_DISCOUNT NUMBER, 
	LO_REVENUE NUMBER, 
	LO_SUPPLYCOST NUMBER, 
	LO_TAX NUMBER, 
	LO_COMMITDATE NUMBER, 
	LO_SHIPMODE CHAR(10 BYTE)'
 );
end;
/


select count(*) from SSB_LINEORDER_EXT;

drop table SSB_LINEORDER;
create table SSB_LINEORDER as select * from SSB_LINEORDER_EXT;
select count(*) from SSB_LINEORDER;


drop table SSB_PART_EXT;

begin
 dbms_cloud.create_external_table(
    table_name =>'SSB_PART_EXT',
    credential_name =>'OBJ_STORE_CRED',
    file_uri_list =>'https://objectstorage.ap-tokyo-1.oraclecloud.com/n/ocichina001/b/bigdata/o/ssb100_data/part.tbl',
    format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true','delimiter' value '|',
        'dateformat' value 'YYYY-MM-DD', 'rejectlimit' value '0', 'trimspaces' value 'rtrim', 
        'ignoreblanklines' value 'false'),
    column_list => 'P_PARTKEY NUMBER, 
	P_NAME VARCHAR2(22 BYTE) , 
	P_MFGR CHAR(6 BYTE) , 
	P_CATEGORY CHAR(7 BYTE) , 
	P_BRAND1 CHAR(9 BYTE) , 
	P_COLOR VARCHAR2(11 BYTE) , 
	P_TYPE VARCHAR2(25 BYTE) , 
	P_SIZE NUMBER, 
	P_CONTAINER CHAR(10 BYTE)'
 );
end;
/




select count(*) from SSB_PART_EXT;

drop table SSB_PART;
create table SSB_PART as select * from SSB_PART_EXT;
select count(*) from SSB_PART;


drop table SSB_SUPPLIER_EXT;

begin
 dbms_cloud.create_external_table(
    table_name =>'SSB_SUPPLIER_EXT',
    credential_name =>'OBJ_STORE_CRED',
    file_uri_list =>'https://objectstorage.ap-tokyo-1.oraclecloud.com/n/ocichina001/b/bigdata/o/ssb100_data/supplier.tbl',
    format => json_object('ignoremissingcolumns' value 'true', 'removequotes' value 'true','delimiter' value '|',
        'dateformat' value 'YYYY-MM-DD', 'rejectlimit' value '0', 'trimspaces' value 'rtrim', 
        'ignoreblanklines' value 'false'),
    column_list => 'S_SUPPKEY NUMBER, 
	S_NAME CHAR(25 BYTE) , 
	S_ADDRESS VARCHAR2(25 BYTE) , 
	S_CITY CHAR(10 BYTE) , 
	S_NATION CHAR(15 BYTE) , 
	S_REGION CHAR(12 BYTE) , 
	S_PHONE CHAR(15 BYTE)'
 );
end;
/


select count(*) from SSB_SUPPLIER_EXT;

drop table SSB_SUPPLIER;
create table SSB_SUPPLIER as select * from SSB_SUPPLIER_EXT;
select count(*) from SSB_SUPPLIER;


begin
    dbms_cloud.EXPORT_DATA(
    credential_name =>'OBJ_STORE_CRED',
    file_uri_list =>'https://objectstorage.ap-tokyo-1.oraclecloud.com/n/ocichina001/b/bigdata/o/ssb100_data/ssb_lineorder_flat',
    format => json_object(''type' value 'datapump'),
    query => 'SELECT * FROM ssb_lineorder_flat2;'
);
end;
/


ALTER TABLE "SSB_CUSTOMER" MODIFY ("C_CUSTKEY" NOT NULL ENABLE);
ALTER TABLE "SSB_CUSTOMER" ADD CONSTRAINT "CUSTOMER_PK" PRIMARY KEY ("C_CUSTKEY") RELY DISABLE;
GRANT READ ON "SSB_CUSTOMER" TO PUBLIC;


ALTER TABLE "SSB_DWDATE" MODIFY ("D_DATEKEY" NOT NULL ENABLE);
ALTER TABLE "SSB_DWDATE" ADD CONSTRAINT "DATE_DIM_PK" PRIMARY KEY ("D_DATEKEY") RELY DISABLE;
GRANT READ ON "SSB_DWDATE" TO PUBLIC;


ALTER TABLE "SSB_PART" MODIFY ("P_PARTKEY" NOT NULL ENABLE);
ALTER TABLE "SSB_PART" ADD CONSTRAINT "PART_PK" PRIMARY KEY ("P_PARTKEY") RELY DISABLE;
GRANT READ ON "SSB_PART" TO PUBLIC;


ALTER TABLE "SSB_SUPPLIER" MODIFY ("S_SUPPKEY" NOT NULL ENABLE);
ALTER TABLE "SSB_SUPPLIER" ADD CONSTRAINT "SUPPLIER_PK" PRIMARY KEY ("S_SUPPKEY") RELY DISABLE;
GRANT READ ON "SSB_SUPPLIER" TO PUBLIC;


ALTER TABLE "SSB_LINEORDER" MODIFY ("LO_ORDERKEY" NOT NULL ENABLE);
ALTER TABLE "SSB_LINEORDER" MODIFY ("LO_LINENUMBER" NOT NULL ENABLE);
ALTER TABLE "SSB_LINEORDER" MODIFY ("LO_CUSTKEY" NOT NULL ENABLE);
ALTER TABLE "SSB_LINEORDER" MODIFY ("LO_PARTKEY" NOT NULL ENABLE);
ALTER TABLE "SSB_LINEORDER" MODIFY ("LO_SUPPKEY" NOT NULL ENABLE);
ALTER TABLE "SSB_LINEORDER" MODIFY ("LO_ORDERDATE" NOT NULL ENABLE);
ALTER TABLE "SSB_LINEORDER" MODIFY ("LO_COMMITDATE" NOT NULL ENABLE);
GRANT READ ON "SSB_LINEORDER" TO PUBLIC;
ALTER TABLE "SSB_LINEORDER" ADD CONSTRAINT "LINEORDER_FK_SUPPKEY" FOREIGN KEY ("LO_SUPPKEY")
      REFERENCES "SSB_SUPPLIER" ("S_SUPPKEY") RELY DISABLE;
ALTER TABLE "SSB_LINEORDER" ADD CONSTRAINT "LINEORDER_FK_CUSTKEY" FOREIGN KEY ("LO_CUSTKEY")
      REFERENCES "SSB_CUSTOMER" ("C_CUSTKEY") RELY DISABLE;
ALTER TABLE "SSB_LINEORDER" ADD CONSTRAINT "LINEORDER_FK_ORDERDATE" FOREIGN KEY ("LO_ORDERDATE")
      REFERENCES "SSB_DWDATE" ("D_DATEKEY") RELY DISABLE;
ALTER TABLE "SSB_LINEORDER" ADD CONSTRAINT "LINEORDER_FK_PARTKEY" FOREIGN KEY ("LO_PARTKEY")
      REFERENCES "SSB_PART" ("P_PARTKEY") RELY DISABLE;
      
