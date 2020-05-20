Start:
```shell script
docker-compose up
```

Create customers & orders dbs:
```shell script
docker exec -it postgres psql -U postgres-user

create database customers;
create database orders;
\c customers;
CREATE TABLE customers (id TEXT PRIMARY KEY, name TEXT, age INT);
```

Create customer data:
```sql
INSERT INTO customers (id, name, age) VALUES ('5', 'fred', 34);
INSERT INTO customers (id, name, age) VALUES ('7', 'sue', 25);
INSERT INTO customers (id, name, age) VALUES ('2', 'bill', 51);
```

Start postgres & mongo debezium source connnectors:
```shell script
docker exec -it ksqldb-cli ksql http://ksqldb-server:8088
SET 'auto.offset.reset' = 'earliest';
```

```sql
CREATE SOURCE CONNECTOR customers_reader WITH (
    'connector.class' = 'io.debezium.connector.postgresql.PostgresConnector',
    'database.hostname' = 'postgres',
    'database.port' = '5432',
    'database.user' = 'postgres-user',
    'database.password' = 'postgres-pw',
    'database.dbname' = 'customers',
    'database.server.name' = 'customers',
    'table.whitelist' = 'public.customers',
    'transforms' = 'unwrap',
    'transforms.unwrap.type' = 'io.debezium.transforms.ExtractNewRecordState',
    'transforms.unwrap.drop.tombstones' = 'false',
    'transforms.unwrap.delete.handling.mode' = 'rewrite'
);

CREATE STREAM customers WITH (
    kafka_topic = 'customers.public.customers',
    value_format = 'avro'
);

CREATE STREAM t_customers WITH (
    kafka_topic = 't_customers'
)   AS
    SELECT  c.id,
            c.name,
            c.age
    FROM customers c
    EMIT CHANGES;
```

Create sink connector:
```sql
CREATE SINK CONNECTOR customers_writer WITH (
    'connector.class' = 'io.confluent.connect.jdbc.JdbcSinkConnector',
    'topics' = 't_customers',
    'connection.url' = 'jdbc:postgresql://postgres:5432/orders',
    'connection.user' = 'postgres-user',
    'connection.password' = 'postgres-pw',
    'dialect.name' = 'PostgreSqlDatabaseDialect',
    'insert.mode' = 'upsert',
    'delete.enabled' = 'true',
    'pk.mode' = 'record_key',
    'pk.fields' = 'id',
    'auto.create' = 'true',
    'auto.evolve' = 'true'
);
```
