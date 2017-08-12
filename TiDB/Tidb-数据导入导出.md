---

title: 数据导入导出
category:  tools

---

# Tidb 数据导入导出
=======================================

## MySQL 导入到 TiDB

### 工具

在这个数据迁移过程中，我们会用到下面四个工具:


 * checker 检查 schema 能否被 TiDB 兼容
 * mydumper 从 MySQL 导出数据
 * loader 导入数据到 TiDB
 * syncer 增量同步 MySQL 数据到 TiDB

两种迁移场景

+ 第一种场景：只全量导入历史数据 （需要 checker + mydumper + loader）；
+ 第二种场景：全量导入历史数据后，通过增量的方式同步新的数据 （需要 checker + mydumper + loader + syncer）。该场景需要提前开启 binlog 且格式必须为 ROW, 并flush log; 


```
# MySQL 开启 master 的 binlog 功能;

# Binlog 格式必须使用 ROW format，这也是 MySQL 5.7 之后推荐的 binlog 格式，可以使用如下语句打开:

mysql> SET GLOBAL binlog_format = ROW;
mysql> select flush logs;

```

#### checker 

```
# 使用 checker 检查 test database 里面所有的 table
./bin/checker -host 127.0.0.1 -port 3306 -user root test

#使用 checker 检查 test database 里面某一个 table
./bin/checker -host 127.0.0.1 -port 3306 -user root test t1

```

### mydumper

使用 mydumper/loader 全量导入数据

我们使用 mydumper 从 MySQL 导出数据，然后用 loader 将其导入到 TiDB 里面。

+ mydumper/loader 全量导入数据最佳实践

```
为了快速的迁移数据 (特别是数据量巨大的库), 可以参考下面建议
* 使用 mydumper 导出来的数据文件尽可能的小, 最好不要超过 64M, 可以设置参数 -F 64
* loader的 -t 参数可以根据 tikv 的实例个数以及负载进行评估调整，例如 3个 tikv 的场景， 此值可以设为 3 *（1 ～ n)；当 tikv 负载过高，loader 以及 tidb 日志中出现大量 backoffer.maxSleep 15000ms is exceeded 可以适当调小该值，当 tikv 负载不是太高的时候，可以适当调大该值。

```

+ 从 MySQL 导出数据

我们使用 mydumper 从 MySQL 导出数据，如下:

```
./bin/mydumper -h 127.0.0.1 -P 3306 -u root -t 16 -F 64 -B test -T t1,t2 --skip-tz-utc -o ./var/test
```
上面，我们使用 -B test 表明是对 test 这个 database 操作，然后用 -T t1,t2 表明只导出 t1，t2 两张表。

-t 16 表明使用 16 个线程去导出数据。-F 64 是将实际的 table 切分成多大的 chunk，这里就是 64MB 一个 chunk。

--skip-tz-utc 添加这个参数忽略掉 MySQL 与导数据的机器之间时区设置不一致的情况，禁止自动转换。

** 注意：在阿里云等一些需要 super privilege 的云上面，mydumper 需要加上 --no-locks 参数，否则会提示没有权限操作。

+ 向 TiDB 导入数据

我们使用 loader 将之前导出的数据导入到 TiDB。Loader 的下载和具体的使用方法见 Loader 使用文档

```
./bin/loader -h 127.0.0.1 -u root -P 4000 -t 32 -d ./var/test
```
+ 使用 syncer 增量导入数据

TiDB 提供 syncer 工具能方便的将 MySQL 的数据增量的导入到 TiDB 里面。syncer 属于 TiDB 企业版工具集。

【启动 syncer】

syncer 的配置文件 config.toml:

```
log-level = "info"

server-id = 101

# meta 文件地址
meta = "./syncer.meta"
worker-count = 1
batch = 1

# pprof 调试地址, Prometheus 也可以通过该地址拉取 syncer metrics
status-addr = ":10081"

skip-sqls = ["ALTER USER", "CREATE USER"]

# 支持白名单过滤, 指定只同步的某些库和某些表, 例如:

# 指定同步 db1 和 db2 下的所有表
replicate-do-db = ["db1","db2"]

# 指定同步 db1.table1
[[replicate-do-table]]
db-name ="db1"
tbl-name = "table1"

# 指定同步 db3.table2
[[replicate-do-table]]
db-name ="db3"
tbl-name = "table2"
# 支持正则，以~开头表示使用正则
# 同步所有以 test 开头的库
replicate-do-db = ["~^test.*"]

# sharding 同步规则，采用 wildcharacter
# 1. 星号字符 (*) 可以匹配零个或者多个字符,
#    例子, doc* 匹配 doc 和 document, 但是和 dodo 不匹配;
#    星号只能放在 pattern 结尾，并且一个 pattern 中只能有一个
# 2. 问号字符 (?) 匹配任一一个字符
[[route-rules]]
pattern-schema = "route_*"
pattern-table = "abc_*"
target-schema = "route"
target-table = "abc"

[[route-rules]]
pattern-schema = "route_*"
pattern-table = "xyz_*"
target-schema = "route"
target-table = "xyz"

[from]
host = "127.0.0.1"
user = "root"
password = ""
port = 3306

[to]
host = "127.0.0.1"
user = "root"
password = ""
port = 4000
启动 syncer:

```

```
./bin/syncer -config config.toml
2016/10/27 15:22:01 binlogsyncer.go:226: [info] begin to sync binlog from position (mysql-bin.000003, 1280)
2016/10/27 15:22:01 binlogsyncer.go:130: [info] register slave for master server 127.0.0.1:3306
2016/10/27 15:22:01 binlogsyncer.go:552: [info] rotate to (mysql-bin.000003, 1280)
2016/10/27 15:22:01 syncer.go:549: [info] rotate binlog to (mysql-bin.000003, 1280)
```

syncer 每隔 30s 会输出当前的同步统计，如下

```
2017/06/08 01:18:51 syncer.go:934: [info] [syncer]total events = 15, total tps = 130, recent tps = 4,
master-binlog = (ON.000001, 11992), master-binlog-gtid=53ea0ed1-9bf8-11e6-8bea-64006a897c73:1-74,
syncer-binlog = (ON.000001, 2504), syncer-binlog-gtid = 53ea0ed1-9bf8-11e6-8bea-64006a897c73:1-17
2017/06/08 01:19:21 syncer.go:934: [info] [syncer]total events = 15, total tps = 191, recent tps = 2,
master-binlog = (ON.000001, 11992), master-binlog-gtid=53ea0ed1-9bf8-11e6-8bea-64006a897c73:1-74,
syncer-binlog = (ON.000001, 2504), syncer-binlog-gtid = 53ea0ed1-9bf8-11e6-8bea-64006a897c73:1-35
```
可以看到，使用 syncer，我们就能自动的将 MySQL 的更新同步到 TiDB。

【syncer sharding 同步支持】

>根据上面的 route-rules 可以支持将分库分表的数据导入到同一个库同一个表中，但是在开始前需要检查分库分表规则
>
>是否可以利用 route-rule 的语义规则表示
分表中是否包含唯一递增主键，或者合并后数据上有冲突的唯一索引或者主键
```
[[route-rules]]
pattern-schema = "example_db"
pattern-table = "table_*"
target-schema = "example_db"
target-table = "table"
```
## MySQL 同步到 MySQL

### 工具 syncer 

syncer 架构

![ syncer ](https://github.com/pingcap/docs-cn/raw/master/media/syncer_architecture.png?raw=true)

```
# MySQL 开启 master 的 binlog 功能;

# Binlog 格式必须使用 ROW format，这也是 MySQL 5.7 之后推荐的 binlog 格式，可以使用如下语句打开:

mysql> SET GLOBAL binlog_format = ROW;
mysql> select flush logs;

```

【syncer 增量导入数据示例】

```
设置同步开始的 position

设置 syncer 的 meta 文件, 这里假设 meta 文件是 syncer.meta:

# cat syncer.meta
binlog-name = "mysql-bin.000003"
binlog-pos = 930143241
binlog-gtid = "2bfabd22-fff7-11e6-97f7-f02fa73bcb01:1-23,61ccbb5d-c82d-11e6-ac2e-487b6bd31bf7:1-4"
```
注意： syncer.meta 只需要第一次使用的时候配置，后续 syncer 同步新的 binlog 之后会自动将其更新到最新的 position
注意： 如果使用 binlog position 同步则只需要配置 binlog-name binlog-pos; 使用 gtid 同步则只需要设置 gtid

【启动 syncer】

```
syncer 的配置文件 config.toml:

log-level = "info"

server-id = 101

# meta 文件地址
meta = "./syncer.meta"
worker-count = 1
batch = 1

# pprof 调试地址, Prometheus 也可以通过该地址拉取 syncer metrics
status-addr = ":10081"

skip-sqls = ["ALTER USER", "CREATE USER"]

# 支持白名单过滤, 指定只同步的某些库和某些表, 例如:

# 指定同步 db1 和 db2 下的所有表
replicate-do-db = ["db1","db2"]

# 指定同步 db1.table1
[[replicate-do-table]]
db-name ="db1"
tbl-name = "table1"

# 指定同步 db3.table2
[[replicate-do-table]]
db-name ="db3"
tbl-name = "table2"
# 支持正则，以~开头表示使用正则
# 同步所有以 test 开头的库
replicate-do-db = ["~^test.*"]

# sharding 同步规则，采用 wildcharacter
# 1. 星号字符 (*) 可以匹配零个或者多个字符,
#    例子, doc* 匹配 doc 和 document, 但是和 dodo 不匹配;
#    星号只能放在 pattern 结尾，并且一个 pattern 中只能有一个
# 2. 问号字符 (?) 匹配任一一个字符
[[route-rules]]
pattern-schema = "route_*"
pattern-table = "abc_*"
target-schema = "route"
target-table = "abc"

[[route-rules]]
pattern-schema = "route_*"
pattern-table = "xyz_*"
target-schema = "route"
target-table = "xyz"

[from]
host = "127.0.0.1"
user = "root"
password = ""
port = 3306

[to]
host = "127.0.0.1"
user = "root"
password = ""
port = 4000

+ 启动 syncer:

./bin/syncer -config config.toml
2016/10/27 15:22:01 binlogsyncer.go:226: [info] begin to sync binlog from position (mysql-bin.000003, 1280)
2016/10/27 15:22:01 binlogsyncer.go:130: [info] register slave for master server 127.0.0.1:3306
2016/10/27 15:22:01 binlogsyncer.go:552: [info] rotate to (mysql-bin.000003, 1280)
2016/10/27 15:22:01 syncer.go:549: [info] rotate binlog to (mysql-bin.000003, 1280)

```

## TiDB 同步到 MySQL



## TiDB 同步到 TiDB 

### TiDB-Binlog 简介

TiDB-Binlog 用于收集 TiDB 的 Binlog，并提供实时备份和同步功能的商业工具。

TiDB-Binlog 支持以下功能场景:

数据同步: 同步 TiDB 集群数据到其他数据库
实时备份和恢复: 备份 TiDB 集群数据，同时可以用于 TiDB 集群故障时恢复


### TiDB-Binlog 架构

首先介绍 TiDB-Binlog 的整体架构。

![ TiDB-Binlog ](https://github.com/pingcap/docs-cn/raw/master/media/architecture.jpeg?raw=true)

TiDB-Binlog 集群主要分为两个组件：

+ Pump

Pump 是一个守护进程，在每个 TiDB 的主机上后台运行。他的主要功能是实时记录 TiDB 产生的 Binlog 并顺序写入磁盘文件

+ Drainer

Drainer 从各个 Pump 节点收集 Binlog，并按照在 TiDB 中事务的提交顺序转化为指定数据库兼容的 SQL 语句，最后同步到目的数据库或者写到顺序文件

### pump

需要为一个 TiDB 集群中的每台 TiDB server 部署一个 pump，目前 TiDB server 只支持以 unix socket 方式的输出 binlog。

我们设置 TiDB 启动参数 binlog-socket 为对应的 pump 的参数 socket 所指定的 unix socket 文件路径，最终部署结构如下图所示：

![ pump ](https://github.com/pingcap/docs-cn/raw/master/media/tidb_pump_deployment.jpeg?raw=true)


Pump 启动参数：

```
示例

./bin/pump -config pump.toml

```

```
参数解释

Usage of pump:
-L string
    日志输出信息等级设置: debug, info, warn, error, fatal (默认 "info")
-V
    打印版本信息
-addr string
    pump 提供服务的 rpc 地址(默认 "127.0.0.1:8250")
-advertise-addr string
    pump 对外提供服务的 rpc 地址(默认 "127.0.0.1:8250")
-config string
    配置文件路径,如果你指定了配置文件，pump 会首先读取配置文件的配置
    如果对应的配置在命令行参数里面也存在，pump 就会使用命令行参数的配置来覆盖配置文件里面的
-data-dir string
    pump 数据存储位置路径
-gc int
    日志最大保留天数 (默认 7)， 设置为 0 可永久保存
-heartbeat-interval uint
    pump 向 pd 发送心跳间隔 (单位 秒)
-log-file string
    log 文件路径
-log-rotate string
    log 文件切换频率, hour/day
-metrics-addr string
   prometheus pushgataway 地址，不设置则禁止上报监控信息
-metrics-interval int
   监控信息上报频率 (默认 15，单位 秒)
-pd-urls string
    pd 集群节点的地址 (默认 "http://127.0.0.1:2379")
-socket string
    unix socket 模式服务监听地址 (默认 unix:///tmp/pump.sock)
```
配置文件

```
# pump Configuration.

# pump 提供服务的 rpc 地址(默认 "127.0.0.1:8250")
addr = "127.0.0.1:8250"

# pump 对外提供服务的 rpc 地址(默认 "127.0.0.1:8250")
advertise-addr = ""

# binlog 最大保留天数 (默认 7)， 设置为 0 可永久保存
gc = 7

#  pump 数据存储位置路径
data-dir = "data.pump"

# pump 向 pd 发送心跳间隔 (单位 秒)
heartbeat-interval = 3

# pd 集群节点的地址 (默认 "http://127.0.0.1:2379")
pd-urls = "http://127.0.0.1:2379"

# unix socket 模式服务监听地址 (默认 unix:///tmp/pump.sock)
socket = "unix:///tmp/pump.sock"
```

```
exec bin/pump \
    --gc="3" \
    --addr="0.0.0.0:8250" \
    --advertise-addr="172.16.10.77:8250" \
    --pd-urls="http://172.16.10.77:2379" \
    --data-dir="/home/pingcap/deploy/data.pump" \
    --socket="/home/pingcap/deploy/status/pump.sock" \
    --log-file="/home/pingcap/deploy/log/pump.log" \
    --metrics-addr="172.16.10.77:9091" --metrics-interval=2
    
```

### drainer

TiDB 到 TiDB 的导入流程：
1. 在 master 上启动 pump，开始进行 binlog 输出；
2. 在 pump 运行 10 分钟左右后按顺序进行下面的操作：
3. 以 gen-savepoint model 运行 drainer 生成 drainer savepint 文件，bin/drainer -gen-savepoint --data-dir= ${drainer_savepoint_dir} --pd-urls=${pd_urls}
4. 全量备份，例如 mydumper 备份 tidb
5. 全量导入备份到目标系统
6. 设置 drainer 的 savepoint 文件路径，然后启动 drainer
    bin/drainer --config=conf/drainer.toml --data-dir=${drainer_savepoint_dir}
7. 观察 drainer 是否正常，检查数据是否同步成功。


Drainer

```
示例

./bin/drainer -config drainer.toml

```
```
参数解释

Usage of drainer:
-L string
    日志输出信息等级设置: debug, info, warn, error, fatal (默认 "info")
-V
    打印版本信息
-addr string
    drainer 提供服务的地址(默认 "127.0.0.1:8249")
-c int
    同步下游的并发数，该值设置越高同步的吞吐性能越好 (default 1)
-config string
   配置文件路径, drainer 会首先读取配置文件的配置
   如果对应的配置在命令行参数里面也存在，drainer 就会使用命令行参数的配置来覆盖配置文件里面的
-data-dir string
   drainer 数据存储位置路径 (默认 "data.drainer")
-dest-db-type string
    drainer 下游服务类型 (默认为 mysql)
-detect-interval int
    向 pd 查询在线 pump 的时间间隔 (默认 10，单位 秒)
-disable-dispatch
    是否禁用拆分单个 binlog 的 sqls 的功能，如果设置为 true，则按照每个 binlog   
    顺序依次还原成单个事务进行同步( 下游服务类型为 mysql, 该项设置为 False )
-gen-savepoint
    如果设置为 true, 则只生成 drainer 的 savepoint meta 文件, 可以配合 mydumper 使用
-ignore-schemas string
    db 过滤列表 (默认 "INFORMATION_SCHEMA,PERFORMANCE_SCHEMA,mysql,test"),   
    不支持对 ignore schemas 的 table 进行 rename DDL 操作
-log-file string
    log 文件路径
-log-rotate string
    log 文件切换频率, hour/day
-metrics-addr string
   prometheus pushgataway 地址，不设置则禁止上报监控信息
-metrics-interval int
   监控信息上报频率 (默认 15，单位 秒)
-pd-urls string
   pd 集群节点的地址 (默认 "http://127.0.0.1:2379")
-txn-batch int
   输出到下游数据库一个事务的 sql 数量 (default 1)
```
配置文件

```
# drainer Configuration.

# drainer 提供服务的地址(默认 "127.0.0.1:8249")
addr = "127.0.0.1:8249"

# 向 pd 查询在线 pump 的时间间隔 (默认 10，单位 秒)
detect-interval = 10

# drainer 数据存储位置路径 (默认 "data.drainer")
data-dir = "data.drainer"

# pd 集群节点的地址 (默认 "http://127.0.0.1:2379")
pd-urls = "http://127.0.0.1:2379"

# log 文件路径
log-file = "drainer.log"

# syncer Configuration.
[syncer]

## db 过滤列表 (默认 "INFORMATION_SCHEMA,PERFORMANCE_SCHEMA,mysql,test"),   
## 不支持对 ignore schemas 的 table 进行 rename DDL 操作
ignore-schemas = "INFORMATION_SCHEMA,PERFORMANCE_SCHEMA,mysql"

# 输出到下游数据库一个事务的 sql 数量 (default 1)
txn-batch = 1

# 同步下游的并发数，该值设置越高同步的吞吐性能越好 (default 1)
worker-count = 1

# 是否禁用拆分单个 binlog 的 sqls 的功能，如果设置为 true，则按照每个 binlog   
# 顺序依次还原成单个事务进行同步( 下游服务类型为 mysql, 该项设置为 False )
disable-dispatch = false

# drainer 下游服务类型 (默认为 mysql)
# 参数有效值为 "mysql", "pb"
db-type = "mysql"

# replicate-do-db priority over replicate-do-table if have same db name
# and we support regex expression , 
# 以 '~' 开始声明使用正则表达式
#
#replicate-do-db = ["~^b.*","s1"]
#[[replicate-do-table]]
#db-name ="test"
#tbl-name = "log"

#[[replicate-do-table]]
#db-name ="test"
#tbl-name = "~^a.*"

# db-type 设置为 mysql 时，下游数据库服务器参数
[syncer.to]
host = "127.0.0.1"
user = "root"
password = ""
port = 3306

# db-type 设置为 pb 时,存放 binlog 文件的目录
# [syncer.to]
# dir = "data.drainer"

```
## TiDB binlog to Protobuffer (pb)

drainer 输出的 Protobuffer, 需要在配置文件设置下面的参数

[syncer]
db-type = "pb"
disable-dispatch = true

[syncer.to]
dir = "/path/pb-dir"

** TiDB 提供工具读取 Protobuffer ，转换成文本，可以写入 ES 或其他下游系统。
