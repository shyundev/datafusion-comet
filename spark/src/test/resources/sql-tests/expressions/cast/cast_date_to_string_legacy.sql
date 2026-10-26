-- Licensed to the Apache Software Foundation (ASF) under one
-- or more contributor license agreements.  See the NOTICE file
-- distributed with this work for additional information
-- regarding copyright ownership.  The ASF licenses this file
-- to you under the Apache License, Version 2.0 (the
-- "License"); you may not use this file except in compliance
-- with the License.  You may obtain a copy of the License at
--
--   http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing,
-- software distributed under the License is distributed on an
-- "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
-- KIND, either express or implied.  See the License for the
-- specific language governing permissions and limitations
-- under the License.

-- Under the LEGACY time parser policy Spark formats dates with java.text.SimpleDateFormat, which
-- uses the hybrid Julian/Gregorian calendar and prints the year of era without a sign. Dates in
-- the 1582 cutover gap, before year 1 and after year 9999 format differently from the default
-- formatter.

-- Config: spark.sql.legacy.timeParserPolicy=LEGACY

statement
CREATE TABLE test_cast_date_to_string_legacy(d date) USING parquet

statement
INSERT INTO test_cast_date_to_string_legacy VALUES (DATE'2024-01-31'), (DATE'1582-10-10'), (make_date(10000, 1, 1)), (make_date(0, 1, 1)), (make_date(-5, 3, 1)), (NULL)

query
SELECT CAST(d AS STRING) FROM test_cast_date_to_string_legacy

query
SELECT CAST(array(d) AS STRING), CAST(named_struct('d', d) AS STRING) FROM test_cast_date_to_string_legacy
