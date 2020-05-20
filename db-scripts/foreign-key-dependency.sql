\c orders;
CREATE TABLE orders (
    id INT PRIMARY KEY,
    name TEXT,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers("id") ON DELETE CASCADE
);
INSERT INTO orders (id, name, customer_id) VALUES (1, 'order 1', 1);
INSERT INTO orders (id, name, customer_id) VALUES (2, 'order 2', 1);
INSERT INTO orders (id, name, customer_id) VALUES (3, 'order 3', 3);
