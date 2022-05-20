
CREATE TABLE interval_t1
       ( id int,
         time_id date default to_date('1900-01-01','yyyy-mm-dd')
      ) 
    PARTITION BY RANGE (time_id) 
    INTERVAL(NUMTODSINTERVAL(1, 'day'))
      ( PARTITION p14 VALUES LESS THAN (TO_DATE('15-5-2022', 'DD-MM-YYYY')),
        PARTITION p15 VALUES LESS THAN (TO_DATE('16-5-2022', 'DD-MM-YYYY')),
        PARTITION p16 VALUES LESS THAN (TO_DATE('17-5-2022', 'DD-MM-YYYY')),
        PARTITION p17 VALUES LESS THAN (TO_DATE('18-5-2022', 'DD-MM-YYYY')));

SQL> insert into interval_t1 values(1,TO_DATE('20-5-2022:10:20:10', 'DD-MM-YYYY:HH24:MI:SS'));

1 row created.

SQL> select PARTITION_NAME,HIGH_VALUE from dba_tab_partitions  where table_name='INTERVAL_T1';

PARTITION_NAME
--------------------------------------------------------------------------------
HIGH_VALUE
--------------------------------------------------------------------------------
P14
TO_DATE(' 2022-05-15 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

P15
TO_DATE(' 2022-05-16 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

P16
TO_DATE(' 2022-05-17 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA


PARTITION_NAME
--------------------------------------------------------------------------------
HIGH_VALUE
--------------------------------------------------------------------------------
P17
TO_DATE(' 2022-05-18 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

SYS_P493
TO_DATE(' 2022-05-21 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

SQL> alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';

Session altered.

SQL>  select * from INTERVAL_T1 partition(SYS_P493);

        ID TIME_ID
---------- -------------------
         1 2022-05-20 10:20:10

SQL> insert into interval_t1 values(1,TO_DATE('19-5-2022:10:20:10', 'DD-MM-YYYY:HH24:MI:SS'));

1 row created.

SQL> select PARTITION_NAME,HIGH_VALUE from dba_tab_partitions  where table_name='INTERVAL_T1';

PARTITION_NAME
--------------------------------------------------------------------------------
HIGH_VALUE
--------------------------------------------------------------------------------
P14
TO_DATE(' 2022-05-15 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

P15
TO_DATE(' 2022-05-16 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

P16
TO_DATE(' 2022-05-17 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA


PARTITION_NAME
--------------------------------------------------------------------------------
HIGH_VALUE
--------------------------------------------------------------------------------
P17
TO_DATE(' 2022-05-18 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

SYS_P493
TO_DATE(' 2022-05-21 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA

SYS_P494
TO_DATE(' 2022-05-20 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA


6 rows selected.

SQL> 
SQL> select * from INTERVAL_T1 partition(SYS_P494);

        ID TIME_ID
---------- -------------------
         1 2022-05-19 10:20:10


SQL> insert into interval_t1 values(1,NULL);
insert into interval_t1 values(1,NULL)
            *
ERROR at line 1:
ORA-14300: partitioning key maps to a partition outside maximum permitted
number of partitions

SQL> insert into interval_t1(id) values(1);

SQL> select PARTITION_NAME,HIGH_VALUE from dba_tab_partitions  where table_name='INTERVAL_T1';

PARTITION_NAME
--------------------------------------------------------------------------------
HIGH_VALUE
--------------------------------------------------------------------------------
P17
TO_DATE(' 2022-05-18 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIA


7 rows selected.

SQL> select * from INTERVAL_T1 partition(p14);

	ID TIME_ID
---------- ------------------
	 1 01-JAN-00
	 1 10-MAY-22

default的意思是说你不指定该字段的时候才使用，你这里指定了，就以指定的值为准，并不是说NULL的时候用default。
是，所以，这个分区字段在这里实际设default 意义不大了，因为客户代码中这个分区字段一定会写在insert 里，所以，判断为空的动作要他们去做，并且真为空则要替换为 1900 ，
现在看如果是分区字段设置default没用，只能设置 not null。所有写入的都得改。
这里有两个做法，一个是 对分区字段，insert时， nvl 判断，要么insert 前，先判断分区字段为空的话， 在insert 里别出现分区字段让default生效， 但显然前面nvl这个可能更符合实际情况