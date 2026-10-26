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

-- On Spark 4.x, to_json keeps the input schema it was resolved against. When the optimizer pushes
-- it through a UNION ALL whose branches name struct fields differently in case, every branch
-- writes the field names of the union's output, which are the first branch's.
-- MinSparkVersion: 4.0
-- Config: spark.sql.caseSensitive=false
-- ConfigMatrix: spark.comet.expression.StructsToJson.allowIncompatible=false,true

statement
CREATE TABLE test_to_json_union_a(id int, s struct<userId: int, Name: string>) USING parquet

statement
CREATE TABLE test_to_json_union_b(id int, s struct<userid: int, name: string>) USING parquet

statement
INSERT INTO test_to_json_union_a VALUES (1, named_struct('userId', 1, 'Name', 'a')), (2, NULL)

statement
INSERT INTO test_to_json_union_b VALUES
  (3, named_struct('userid', 3, 'name', 'b')), (4, named_struct('userid', NULL, 'name', NULL))

query
SELECT id, to_json(s) FROM (
  SELECT id, s FROM test_to_json_union_a UNION ALL SELECT id, s FROM test_to_json_union_b)

-- A filter on to_json is pushed through the union too, and must keep the rows of both branches
query
SELECT id FROM (
  SELECT id, s FROM test_to_json_union_a UNION ALL SELECT id, s FROM test_to_json_union_b)
WHERE to_json(s) LIKE '%"userId"%'

-- The union's struct nested in another struct
query
SELECT id, to_json(named_struct('k', id, 'v', s)) FROM (
  SELECT id, s FROM test_to_json_union_a UNION ALL SELECT id, s FROM test_to_json_union_b)
