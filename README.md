Start:
```shell script
docker-compose up
```

Create customers & orders dbs:
```shell script
docker-compose exec postgres bash -c 'psql -U postgres-user -f /usr/initialize.sql'
```

```shell script
# Start SINK connector
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @jdbc-sink.json

# Start SOURCE connector
curl -i -X POST -H "Accept:application/json" -H  "Content-Type:application/json" http://localhost:8083/connectors/ -d @source.json
```

Check contents of the SOURCE database:
```shell
docker-compose exec postgres bash -c 'psql -U postgres-user customers -c "select * from customers"'
 id | name | age
----+------+-----
  1 | fred |  34
  2 | sue  |  25
  3 | bill |  51
(3 rows)
```

Verify that the SINK database has the same content:
```shell
docker-compose exec postgres bash -c 'psql -U postgres-user orders -c "select * from customers"'
  name | id | age
 ------+----+-----
  fred |  1 |  34
  sue  |  2 |  25
  bill |  3 |  51
 (3 rows)
```

Insert a new row in SOURCE db:
```shell script
docker-compose exec postgres psql -U postgres-user customers -c "INSERT INTO customers (id, name, age) VALUES (4, 'New Customer', 35);"
```

Check contents of the SOURCE database:
```shell
docker-compose exec postgres bash -c 'psql -U postgres-user customers -c "select * from customers"'
  id |     name     | age
 ----+--------------+-----
   1 | fred         |  34
   2 | sue          |  25
   3 | bill         |  51
   4 | New Customer |  35
 (4 rows)
```

Verify that the SINK database has the same content:
```shell
docker-compose exec postgres bash -c 'psql -U postgres-user orders -c "select * from customers"'
     name     | id | age
--------------+----+-----
 fred         |  1 |  34
 sue          |  2 |  25
 bill         |  3 |  51
 New Customer |  4 |  35
(4 rows)
```

Update a row in SOURCE db:
```shell script
docker-compose exec postgres psql -U postgres-user customers -c "UPDATE customers SET name='Not fred' WHERE id = 1;"
```

Check contents of the SOURCE database:
```shell
docker-compose exec postgres bash -c 'psql -U postgres-user customers -c "select * from customers"'
 id |     name     | age
----+--------------+-----
  2 | sue          |  25
  3 | bill         |  51
  4 | New Customer |  35
  1 | Not fred     |  34
(4 rows)
```

Verify that the SINK database has the same content:
```shell
docker-compose exec postgres bash -c 'psql -U postgres-user orders -c "select * from customers"'
     name     | id | age
--------------+----+-----
 sue          |  2 |  25
 bill         |  3 |  51
 New Customer |  4 |  35
 Not fred     |  1 |  34
(4 rows)
```

Delete a row in SOURCE db:
```shell script
docker-compose exec postgres psql -U postgres-user customers -c "DELETE FROM customers WHERE id = 2;"
```

Check contents of the SOURCE database:
```shell
docker-compose exec postgres bash -c 'psql -U postgres-user customers -c "select * from customers"'
 id |     name     | age
----+--------------+-----
  3 | bill         |  51
  4 | New Customer |  35
  1 | Not fred     |  34
(3 rows)
```

Verify that the SINK database has the same content:
```shell
docker-compose exec postgres bash -c 'psql -U postgres-user orders -c "select * from customers"'
     name     | id | age
--------------+----+-----
 bill         |  3 |  51
 New Customer |  4 |  35
 Not fred     |  1 |  34
(3 rows)
```

Create a foreign key dependency on SINK database:
```shell script
docker-compose exec postgres bash -c 'psql -U postgres-user -f /usr/foreign-key-dependency.sql'
```

Verify that the SINK database has orders:
```shell
docker-compose exec postgres bash -c 'psql -U postgres-user orders -c "select * from orders"'
 id |  name   | customer_id
----+---------+-------------
  1 | order 1 |           1
  2 | order 2 |           1
  3 | order 3 |           3
(3 rows)
```

Delete row id 1 in SOURCE db:
```shell script
docker-compose exec postgres psql -U postgres-user customers -c "DELETE FROM customers WHERE id = 1;"
```

Verify that the SINK database does not have orders for customer 1:
```shell
docker-compose exec postgres bash -c 'psql -U postgres-user orders -c "select * from orders"'
 id |  name   | customer_id
----+---------+-------------
  3 | order 3 |           3
(1 row)
```
