# TiDB sysbench 测试.

##instll sysbench
>1. 直接安装 sudo yum -y install sysbench；
>2. wget 源码编译
wget http://imysql.com/wp-content/uploads/2014/09/sysbench-0.4.12-1.1.tgz

```
sudo yum -y install automake
sudo yum -y install libtool

cd /tmp/sysbench-0.4.12-1.1
./autogen.sh
./configure && make

# 如果 make 没有报错，就会在 sysbench 目录下生成二进制命令行工具 sysbench
ls -l sysbench
-rwxr-xr-x 1 root root 3293186 Sep 21 16:24 sysbench

```

## TiDB Bench 脚本
copy tidb-bench-master.zip to test server.


## 运行测试
```
mysql -uroot -H127.0.0.1 -P4000

create database sbtest1;

cd ~/tidb-bench-master/sysbench

```
>修改 conf.sh

```
[pingcap@t001 sysbench]$ cat conf.sh 

host=127.0.0.1
port=4000
user=root
password=''
tcount=16
tsize=500000
threads=256
dbname=sbtest1

# report interval
interval=10

# max time in seconds
maxtime=600

# just large enough to fit maxtime
requests=2000000000

driver=mysql
```

>测试前准备

关于这几个参数的解释：
--test=tests/db/oltp.lua 表示调用 tests/db/oltp.lua 脚本进行 oltp 模式测试
--oltp_tables_count=16 表示会生成 10 个测试表
--oltp-table-size=500000 表示每个测试表填充数据量为 500000 
--rand-init=on 表示每个测试表都是用随机数据来填充的

如果在本机，也可以使用 –mysql-socket 指定 socket 文件来连接。加载测试数据时长视数据量而定，若过程比较久需要稍加耐心等待。
真实测试场景中，数据表建议不低于10个，单表数据量不低于500万行，当然了，要视服务器硬件配置而定。如果是配备了SSD或者PCIE SSD这种高IOPS设备的话，则建议单表数据量最少不低于1亿行。

```

./prepare.sh

```

执行完成后，生成16个表，每个表500000条数据。


> 测试 OLTP

几个选项稍微解释下
--num-threads=256 表示发起 256 个并发连接
--oltp-read-only=off 表示不要进行只读测试，也就是会采用读写混合模式测试
--report-interval=10 表示每10秒输出一次测试进度报告
--rand-type=uniform 表示随机类型为固定模式，其他几个可选随机模式：uniform(固定),gaussian(高斯),special(特定的),pareto(帕累托)
--max-time=600 表示最大执行时长为 600 秒
--max-requests=0 表示总请求数为 0，因为上面已经定义了总执行时长，所以总请求数可以设定为 0；也可以只设定总请求数，不设定最大执行时长
--percentile=95 表示设定采样比例，默认是 95%，即丢弃5%的长请求，在剩余的95%里取最大值

即：模拟 对256个表并发OLTP测试，每个表500000行记录，持续压测时间为 10 分钟。
真实测试场景中，建议持续压测时长不小于30分钟，否则测试数据可能不具参考意义。

```
./oltp.sh

+
+ sysbench --test=./lua-tests/db/oltp.lua --db-driver=mysql --mysql-host=127.0.0.1 --mysql-port=4000 --mysql-user=root --mysql-password= --mysql-db=sbtest1 --oltp-tables-count=16 --oltp-table-size=500000 --num-threads=256 --max-requests=2000000000 --oltp-read-only=off --report-interval=10 --rand-type=uniform --max-time=600 --percentile=95 run
+ 
```

测试结果解读如下：

```
sysbench 1.0.6 (using system LuaJIT 2.0.4)

Running the test with following options:
Number of threads: 256
Report intermediate results every 10 second(s)
Initializing random number generator from current time

-- 每10秒钟报告一次测试结果，tps、每秒读、每秒写、99%以上的响应时长统计

[ 580s ] thds: 256 tps: 721.70 qps: 14451.55 (r/w/o: 10116.46/2890.59/1444.49) lat (ms,95%): 404.61 err/s: 0.00 reconn/s: 0.00
[ 590s ] thds: 256 tps: 717.67 qps: 14343.25 (r/w/o: 10038.02/2869.89/1435.35) lat (ms,95%): 427.07 err/s: 0.00 reconn/s: 0.00
[ 600s ] thds: 256 tps: 731.61 qps: 14657.79 (r/w/o: 10265.53/2931.24/1461.02) lat (ms,95%): 404.61 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            5846120  -- 读总数
        write:                           1670320  -- 写总数
        other:                           835160   -- 其他操作总数(SELECT、INSERT、UPDATE、DELETE之外的操作，例如COMMIT等)
        total:                           8351600  -- 全部总数
    transactions:                        417580 (693.25 per sec.) -- 总事务数(每秒事务数)
    queries:                             8351600 (13864.98 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          602.3476s  -- 总耗时
    total number of events:              417580  -- 共发生多少事务数

Latency (ms):
         min:                                 25.62   -- 最小耗时
         avg:                                367.90   -- 平均耗时
         max:                               5886.23   -- 最长耗时
         95th percentile:                    442.73   
         sum:                            153628367.56

Threads fairness:
    events (avg/stddev):           1631.1719/8.33
    execution time (avg/stddev):   600.1108/0.15

```

> 测试 select

```

./select.sh

+ sysbench --test=./lua-tests/db/select.lua --db-driver=mysql --mysql-host=127.0.0.1 --mysql-port=4000 --mysql-user=root --mysql-password= --mysql-db=sbtest1 --oltp-tables-count=16 --oltp-table-size=500000 --num-threads=256 --report-interval=10 --max-requests=2000000000 --percentile=95 --max-time=600 run
+ 
```

```
测试结果：

[ 580s ] thds: 256 tps: 18082.21 qps: 18082.21 (r/w/o: 18082.21/0.00/0.00) lat (ms,95%): 26.68 err/s: 0.00 reconn/s: 0.00
[ 590s ] thds: 256 tps: 18571.33 qps: 18571.33 (r/w/o: 18571.33/0.00/0.00) lat (ms,95%): 26.20 err/s: 0.00 reconn/s: 0.00
[ 600s ] thds: 256 tps: 18757.37 qps: 18757.37 (r/w/o: 18757.37/0.00/0.00) lat (ms,95%): 26.20 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            11184297
        write:                           0
        other:                           0
        total:                           11184297
    transactions:                        11184297 (18639.46 per sec.)
    queries:                             11184297 (18639.46 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          600.0313s
    total number of events:              11184297

Latency (ms):
         min:                                  0.50
         avg:                                 13.73
         max:                                428.34
         95th percentile:                     26.20
         sum:                            153572975.40

Threads fairness:
    events (avg/stddev):           43688.6602/87.65
    execution time (avg/stddev):   599.8944/0.02
    
```

> 测试 insert

```

./insert.sh

+ sysbench --test=./lua-tests/db/insert.lua --db-driver=mysql --mysql-host=127.0.0.1 --mysql-port=4000 --mysql-user=root --mysql-password= --mysql-db=sbtest1 --oltp-tables-count=16 --oltp-table-size=500000 --num-threads=256 --report-interval=10 --max-requests=2000000000 --percentile=95 --max-time=600 run
+ 

```

```
测试结果：

[ 580s ] thds: 256 tps: 4890.78 qps: 4890.78 (r/w/o: 0.00/4890.78/0.00) lat (ms,95%): 51.94 err/s: 0.00 reconn/s: 0.00
[ 590s ] thds: 256 tps: 4495.78 qps: 4495.78 (r/w/o: 0.00/4495.78/0.00) lat (ms,95%): 69.29 err/s: 0.00 reconn/s: 0.00
[ 600s ] thds: 256 tps: 5896.58 qps: 5896.58 (r/w/o: 0.00/5896.58/0.00) lat (ms,95%): 55.82 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            0
        write:                           3652666
        other:                           0
        total:                           3652666
    transactions:                        3652666 (6060.57 per sec.)
    queries:                             3652666 (6060.57 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          602.6898s
    total number of events:              3652666

Latency (ms):
         min:                                  6.26
         avg:                                 42.23
         max:                               3934.62
         95th percentile:                     63.32
         sum:                            154256304.43

Threads fairness:
    events (avg/stddev):           14268.2266/38.14
    execution time (avg/stddev):   602.5637/0.06
    
```


> 测试 delete

```

./delete.sh

+ sysbench --test=./lua-tests/db/delete.lua --db-driver=mysql --mysql-host=127.0.0.1 --mysql-port=4000 --mysql-user=root --mysql-password= --mysql-db=sbtest1 --oltp-tables-count=16 --oltp-table-size=500000 --num-threads=256 --report-interval=10 --max-requests=2000000000 --max-time=600 --percentile=95 run

```

```
测试结果：

[ 580s ] thds: 256 tps: 12317.77 qps: 12317.77 (r/w/o: 0.00/1580.82/10736.95) lat (ms,95%): 45.79 err/s: 0.00 reconn/s: 0.00
[ 590s ] thds: 256 tps: 12238.98 qps: 12238.98 (r/w/o: 0.00/1530.11/10708.87) lat (ms,95%): 44.98 err/s: 0.00 reconn/s: 0.00
[ 600s ] thds: 256 tps: 12637.01 qps: 12637.01 (r/w/o: 0.00/1568.36/11068.64) lat (ms,95%): 44.17 err/s: 0.00 reconn/s: 0.00
SQL statistics:
    queries performed:
        read:                            0
        write:                           1258389
        other:                           5607338
        total:                           6865727
    transactions:                        6865727 (11441.80 per sec.)
    queries:                             6865727 (11441.80 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          600.0543s
    total number of events:              6865727

Latency (ms):
         min:                                  0.78
         avg:                                 22.37
         max:                               4867.29
         95th percentile:                     50.11
         sum:                            153577426.28

Threads fairness:
    events (avg/stddev):           26819.2461/97.51
    execution time (avg/stddev):   599.9118/0.03

```

