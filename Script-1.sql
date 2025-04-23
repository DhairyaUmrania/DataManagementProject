-- Drop database if it exists and create a new one
DROP DATABASE IF EXISTS dblab;

CREATE DATABASE dblab;

USE dblab;

-- Create customers table
CREATE TABLE customers(
    customer_id INT PRIMARY KEY auto_increment,
    user_id VARCHAR(20) NOT NULL,
    password VARCHAR(130) NOT NULL,
    email VARCHAR(100)
);

-- Create customer_accounts table
CREATE TABLE customer_accounts(
    customer_account_id INT PRIMARY KEY auto_increment,
    bank_account_number VARCHAR(20) NOT NULL,
    bank_name VARCHAR(20) NOT NULL,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Create customer_orders table
CREATE TABLE customer_orders(
    customer_order_id INT PRIMARY KEY auto_increment,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    total_price DECIMAL(10,2) NOT NULL,
    customer_account_id INT,
    FOREIGN KEY (customer_account_id) REFERENCES customer_accounts(customer_account_id)
);

-- Create items table
CREATE TABLE items(
    item_id INT PRIMARY KEY auto_increment,
    name VARCHAR(50) NOT NULL
);

-- Create class table
CREATE TABLE class(
    class_id INT PRIMARY KEY auto_increment,
    item_id INT,
    FOREIGN KEY (item_id) REFERENCES items(item_id),
    max_price DECIMAL(10,2) NOT NULL,
    class_type ENUM('A', 'B', 'C')
);

-- Create suppliers table
CREATE TABLE suppliers(
    supplier_id INT PRIMARY KEY auto_increment,
    name VARCHAR(50) NOT NULL
);

-- Create order_items table
CREATE TABLE order_items(
    order_item_id INT PRIMARY KEY auto_increment,
    customer_order_id INT,
    FOREIGN KEY (customer_order_id) REFERENCES customer_orders(customer_order_id),
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    class_id INT,
    FOREIGN KEY (class_id) REFERENCES class(class_id),
    item_id INT,
    FOREIGN KEY (item_id) REFERENCES items(item_id)
);

-- Create supplier_items table
CREATE TABLE supplier_items(
    supplier_item_id INT PRIMARY KEY auto_increment,
    supplier_id INT,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id),
    commission INT NOT NULL,
    class_id INT,
    FOREIGN KEY (class_id) REFERENCES class(class_id),
    discount INT,
    stock INT DEFAULT 0,
    review DECIMAL(10, 4),
    number_reviews INT DEFAULT 0,
    item_id INT,
    FOREIGN KEY (item_id) REFERENCES items(item_id)
); 

-- Create preference_index table
CREATE TABLE preference_index(
    preference_index_id INT PRIMARY KEY auto_increment,
    supplier_item_id INT,
    FOREIGN KEY (supplier_item_id) REFERENCES supplier_items(supplier_item_id),
    index_val DECIMAL(10,5)
);

-- Create function for calculating preference index
DELIMITER $$
 
CREATE FUNCTION Calculate_preference_index(commission INT, review DECIMAL(10, 4), discount INT) RETURNS DECIMAL(10,2)
    DETERMINISTIC
BEGIN
    RETURN 1 / (1 + EXP((-1 * 1.0 * commission) + (-1 * 1.0 * review) + (-1 * discount)));
END
$$

-- Create trigger for updating preference index when supplier items change
CREATE TRIGGER update_commission
AFTER UPDATE ON supplier_items FOR EACH ROW
BEGIN       
    UPDATE preference_index
    SET index_val = Calculate_preference_index(NEW.commission, NEW.review, NEW.discount)
    WHERE supplier_item_id = NEW.supplier_item_id;       
END
$$
DELIMITER ;

-- Insert sample data
-- Customers
INSERT INTO customers VALUES(1,'U1','PWD1','user1@example.com');
INSERT INTO customers VALUES(2,'U2','PWD2','user2@example.com');
INSERT INTO customers VALUES(3,'U3','PWD3','user3@example.com');
INSERT INTO customers VALUES(4,'U4','PWD4','user4@example.com');
INSERT INTO customers VALUES(5,'U5','PWD5','user5@example.com');
INSERT INTO customers VALUES(6,'U6','PWD6','user6@example.com');

-- Customer accounts
INSERT INTO customer_accounts VALUES(1,'BA1','BN1',1);
INSERT INTO customer_accounts VALUES(2,'BA2','BN2',2);
INSERT INTO customer_accounts VALUES(3,'BA3','BN3',3);
INSERT INTO customer_accounts VALUES(4,'BA4','BN4',4);
INSERT INTO customer_accounts VALUES(5,'BA5','BN5',5);
INSERT INTO customer_accounts VALUES(6,'BA6','BN6',6);

-- Customer orders
INSERT INTO customer_orders VALUES(1,1,100.00,1);
INSERT INTO customer_orders VALUES(2,2,200.00,2);
INSERT INTO customer_orders VALUES(3,3,300.00,3);
INSERT INTO customer_orders VALUES(4,4,400.00,4);
INSERT INTO customer_orders VALUES(5,5,500.00,5);
INSERT INTO customer_orders VALUES(6,6,600.00,6);

-- Items
INSERT INTO items VALUES(1,'Smartphone');
INSERT INTO items VALUES(2,'Laptop');
INSERT INTO items VALUES(3,'Tablet');
INSERT INTO items VALUES(4,'Headphones');
INSERT INTO items VALUES(5,'Monitor');
INSERT INTO items VALUES(6,'Keyboard');

-- Classes
INSERT INTO class VALUES(1,1,1000.00,'A');
INSERT INTO class VALUES(2,2,2000.00,'A');
INSERT INTO class VALUES(3,3,500.00,'B');
INSERT INTO class VALUES(4,4,200.00,'A');
INSERT INTO class VALUES(5,5,350.00,'C');
INSERT INTO class VALUES(6,6,100.00,'C');

-- Suppliers
INSERT INTO suppliers VALUES(1,'TechCorp');
INSERT INTO suppliers VALUES(2,'ElectroSupply');
INSERT INTO suppliers VALUES(3,'GadgetWorld');
INSERT INTO suppliers VALUES(4,'DigitalSellers');
INSERT INTO suppliers VALUES(5,'TechSource');
INSERT INTO suppliers VALUES(6,'ComputerDepot');

-- Order items
INSERT INTO order_items VALUES(1,1,1,80.00,1,1,1);
INSERT INTO order_items VALUES(2,2,2,180.00,2,2,2);
INSERT INTO order_items VALUES(3,3,1,280.00,3,3,3);
INSERT INTO order_items VALUES(4,4,2,90.00,4,4,4);
INSERT INTO order_items VALUES(5,5,1,320.00,5,5,1);
INSERT INTO order_items VALUES(6,6,3,95.00,6,6,2);

-- Supplier items
INSERT INTO supplier_items VALUES(1,1,5,1,10,100,4.5,25,1);
INSERT INTO supplier_items VALUES(2,2,4,2,5,80,4.2,18,2);
INSERT INTO supplier_items VALUES(3,3,6,3,15,50,4.7,32,3);
INSERT INTO supplier_items VALUES(4,4,3,4,8,65,4.0,12,4);
INSERT INTO supplier_items VALUES(5,5,7,5,12,45,4.3,15,5);
INSERT INTO supplier_items VALUES(6,6,5,6,10,70,4.1,20,6);

-- Preference index
INSERT INTO preference_index VALUES(1,1,0.9);
INSERT INTO preference_index VALUES(2,2,0.8);
INSERT INTO preference_index VALUES(3,3,0.95);
INSERT INTO preference_index VALUES(4,4,0.75);
INSERT INTO preference_index VALUES(5,5,0.85);
INSERT INTO preference_index VALUES(6,6,0.82);

-- Example queries

-- 1. Find all suppliers that sell a specific item of a specific class
SELECT s.name 
FROM suppliers s
JOIN supplier_items si ON s.supplier_id = si.supplier_id
WHERE si.class_id = 1 AND si.item_id = 1;

-- 2. Get order details for a specific customer order
SELECT c.user_id, ca.bank_account_number, co.total_price
FROM customer_orders co
JOIN customers c ON c.customer_id = co.customer_id
JOIN customer_accounts ca ON ca.customer_account_id = co.customer_account_id
WHERE co.customer_order_id = 1;

-- 3. View items in an order with supplier and class information
SELECT i.name, cl.class_type, oi.price, s.name as supplier_name
FROM order_items oi
JOIN items i ON oi.item_id = i.item_id
JOIN class cl ON oi.class_id = cl.class_id
JOIN suppliers s ON oi.supplier_id = s.supplier_id
WHERE oi.customer_order_id = 1;

-- 4. Get all items with their stock information by supplier
SELECT i.name, cl.class_type, si.stock, s.name as supplier_name
FROM supplier_items si
JOIN items i ON si.item_id = i.item_id
JOIN class cl ON si.class_id = cl.class_id
JOIN suppliers s ON si.supplier_id = s.supplier_id
ORDER BY i.name, s.name;

-- 5. Find suppliers with the highest preference index for each item
SELECT i.name, s.name as supplier_name, pi.index_val
FROM preference_index pi
JOIN supplier_items si ON pi.supplier_item_id = si.supplier_item_id
JOIN suppliers s ON si.supplier_id = s.supplier_id
JOIN items i ON si.item_id = i.item_id
ORDER BY pi.index_val DESC;

-- Inserting new user in DB:
-- SQL procedure to add a new user with validation
DELIMITER //

CREATE PROCEDURE add_new_user(
    IN p_user_id VARCHAR(20),
    IN p_password VARCHAR(130),
    IN p_email VARCHAR(100),
    IN p_bank_account_number VARCHAR(20),
    IN p_bank_name VARCHAR(20)
)
BEGIN
    DECLARE user_exists INT DEFAULT 0;
    DECLARE new_customer_id INT;
    
    -- Check if user already exists
    SELECT COUNT(*) INTO user_exists FROM customers WHERE user_id = p_user_id;
    
    IF user_exists > 0 THEN
        -- Case 2: User already exists
        SELECT 'Error: User ID already exists' AS message;
    ELSE
        -- Case 1: New User - Proceed with insertion
        -- Validate inputs
        IF p_user_id IS NULL OR p_password IS NULL OR p_bank_account_number IS NULL OR p_bank_name IS NULL THEN
            SELECT 'Error: Required fields cannot be null' AS message;
        ELSE
            -- Insert into customers table
            INSERT INTO customers(user_id, password, email)
            VALUES(p_user_id, p_password, p_email);
            
            -- Get the newly created customer_id
            SET new_customer_id = LAST_INSERT_ID();
            
            -- Insert into customer_accounts table
            INSERT INTO customer_accounts(bank_account_number, bank_name, customer_id)
            VALUES(p_bank_account_number, p_bank_name, new_customer_id);
            
            SELECT 'User successfully added' AS message, new_customer_id AS customer_id;
        END IF;
    END IF;
END //

DELIMITER ;
-- Check if the procedure exists
SHOW PROCEDURE STATUS WHERE Db = 'dblab' AND Name = 'add_new_user';

-- Case 1: Adding a new user successfully
CALL add_new_user('U7', 'PWD7', 'user7@example.com', 'BA7', 'BN7');

-- Case 2: Trying to add a user that already exists
CALL add_new_user('U1', 'PWD1', 'user1@example.com', 'BA1', 'BN1');

-- Case 3: Invalid constraints (missing required field)
CALL add_new_user('U8', NULL, 'user8@example.com', 'BA8', 'BN8');