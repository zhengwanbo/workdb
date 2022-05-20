CREATE TABLE `customer` (
  `c_custkey` int NOT NULL,
  `c_name` varchar(26) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `c_address` varchar(41) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `c_city` varchar(11) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `c_nation` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `c_region` varchar(13) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `c_phone` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `c_mktsegment` varchar(11) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  PRIMARY KEY (`c_custkey`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin SECONDARY_ENGINE=RAPID;

CREATE TABLE `dates` (
  `d_datekey` int NOT NULL,
  `d_date` varchar(20) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `d_dayofweek` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `d_month` varchar(11) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `d_year` int NOT NULL,
  `d_yearmonthnum` int NOT NULL,
  `d_yearmonth` varchar(9) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `d_daynuminweek` int NOT NULL,
  `d_daynuminmonth` int NOT NULL,
  `d_daynuminyear` int NOT NULL,
  `d_monthnuminyear` int NOT NULL,
  `d_weeknuminyear` int NOT NULL,
  `d_sellingseason` varchar(14) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `d_lastdayinweekfl` int NOT NULL,
  `d_lastdayinmonthfl` int NOT NULL,
  `d_holidayfl` int NOT NULL,
  `d_weekdayfl` int NOT NULL,
  PRIMARY KEY (`d_datekey`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin SECONDARY_ENGINE=RAPID;

 CREATE TABLE `lineorder` (
  `lo_orderkey` bigint NOT NULL,
  `lo_linenumber` int NOT NULL,
  `lo_custkey` int NOT NULL,
  `lo_partkey` int NOT NULL,
  `lo_suppkey` int NOT NULL,
  `lo_orderdate` int NOT NULL,
  `lo_orderpriority` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `lo_shippriority` int NOT NULL,
  `lo_quantity` int NOT NULL,
  `lo_extendedprice` int NOT NULL,
  `lo_ordtotalprice` int NOT NULL,
  `lo_discount` int NOT NULL,
  `lo_revenue` int NOT NULL,
  `lo_supplycost` int NOT NULL,
  `lo_tax` int NOT NULL,
  `lo_commitdate` int NOT NULL,
  `lo_shipmode` varchar(11) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  PRIMARY KEY (`lo_orderkey`,`lo_linenumber`),
  CONSTRAINT `lineorder_ibfk_1` FOREIGN KEY (`lo_custkey`) REFERENCES `customer` (`c_custkey`),
  CONSTRAINT `lineorder_ibfk_2` FOREIGN KEY (`lo_orderdate`) REFERENCES `dates` (`d_datekey`),
  CONSTRAINT `lineorder_ibfk_3` FOREIGN KEY (`lo_suppkey`) REFERENCES `supplier` (`s_suppkey`),
  CONSTRAINT `lineorder_ibfk_4` FOREIGN KEY (`lo_partkey`) REFERENCES `part` (`p_partkey`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin SECONDARY_ENGINE=RAPID;

CREATE TABLE `part` (
  `p_partkey` int NOT NULL,
  `p_name` varchar(23) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `p_mfgr` varchar(7) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `p_category` varchar(8) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `p_brand` varchar(10) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `p_color` varchar(12) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `p_type` varchar(26) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `p_size` int NOT NULL,
  `p_container` varchar(11) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  PRIMARY KEY (`p_partkey`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin SECONDARY_ENGINE=RAPID;

CREATE TABLE `supplier` (
  `s_suppkey` int NOT NULL,
  `s_name` varchar(26) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `s_address` varchar(26) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `s_city` varchar(11) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `s_nation` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `s_region` varchar(13) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  `s_phone` varchar(16) CHARACTER SET ascii COLLATE ascii_bin NOT NULL COMMENT ' RAPID_COLUMN_AUTODB=ENCODING=SORTED RAPID_COLUMN=ENCODING=SORTED ',
  PRIMARY KEY (`s_suppkey`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin SECONDARY_ENGINE=RAPID;