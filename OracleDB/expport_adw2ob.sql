

select count(*) from ssb_lineorder;

select sum(bytes)/(1024*1024*1024) GB from dba_segments where owner='ADMIN' and segment_name='SSB_LINEORDER';

BEGIN
DBMS_CLOUD.EXPORT_DATA(
credential_name =>'OBJ_STORE_CRED',
file_uri_list =>'https://objectstorage.ap-seoul-1.oraclecloud.com/n/ocichina001/b/bucket-AD/o/adw_export/export_ssb100_lineorder_csv.txt',
format => json_object('type' value 'csv'),
query => 'SELECT * FROM ssb_lineorder'
);
END;
/

BEGIN
DBMS_CLOUD.EXPORT_DATA(
credential_name =>'OBJ_STORE_CRED',
file_uri_list =>'https://objectstorage.ap-seoul-1.oraclecloud.com/n/ocichina001/b/bucket-AD/o/adw_export_gz/export_ssb100_lineorder_csv.txt',
format => JSON_OBJECT('type' value 'csv', 'compression' value 'gzip') ,
query => 'SELECT * FROM ssb_lineorder'
);
END;
/


