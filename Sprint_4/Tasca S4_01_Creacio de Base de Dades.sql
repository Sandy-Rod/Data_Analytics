#Creación base de datos
CREATE DATABASE IF NOT EXISTS transactions2;
use transactions2;

CREATE TABLE IF NOT EXISTS companies (
	id 				VARCHAR(255) PRIMARY KEY,
    company_name 	VARCHAR(255),
    phone			VARCHAR(15),
    email			VARCHAR(150),
    country			VARCHAR(100),
    website			VARCHAR(255)
);


CREATE TABLE IF NOT EXISTS users (
	id 				INT PRIMARY KEY,
	name_user 		VARCHAR(100),
	surname 		VARCHAR(100),
	phone 			VARCHAR(150),
	email 			VARCHAR(255),
	birth_date 		VARCHAR(100),
	country 		VARCHAR(100),
	city 			VARCHAR(150),
	postal_code 	VARCHAR(100),
	address 		VARCHAR(255)
);


CREATE TABLE IF NOT EXISTS credit_card (
    id 				VARCHAR(20) PRIMARY KEY UNIQUE,
    user_id 		INT,
    iban 			VARCHAR(100),
    pan 			VARCHAR(30),
    pin 			VARCHAR(4),
    cvv 			VARCHAR(3),
    track1 			VARCHAR(100),
    track2 			VARCHAR(100),
    expiring_date 	VARCHAR(8)
);
    


CREATE TABLE IF NOT EXISTS transactions (
	id				VARCHAR(100) PRIMARY KEY UNIQUE,
    card_id			VARCHAR(20),
    business_id		VARCHAR(255),
    timestamp		TIMESTAMP,
    amount			DECIMAL(10, 2),
    declined		BOOLEAN,
    product_ids		VARCHAR(255),
    user_id			INT,
    lat				FLOAT,
    longitude		FLOAT,
    FOREIGN KEY (card_id) 		REFERENCES credit_card(id),
    FOREIGN KEY (business_id) 	REFERENCES companies(id),
	FOREIGN KEY (user_id) 		REFERENCES users(id)
    
);



############################################################ NIVEL 1 ################################################################
#	Exercici 1
# Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.

SELECT u.name_user
	, u.surname
    , u.country
	,COUNT(t.user_id) AS total_transacciones
	FROM transactions t
    INNER JOIN users u
			ON t.user_id = u.id
	GROUP BY t.user_id
    HAVING total_transacciones > 30
    ORDER BY total_transacciones DESC;




#	Exercici 2
# Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.



SELECT c.company_name AS Company_Name
	, ROUND(AVG(t.amount),2) AS Media
	FROM companies c
    INNER JOIN transactions t
			ON c.id = t.business_id
    INNER JOIN credit_card cc
			ON cc.id = t.card_id
	WHERE c.company_name = "Donec Ltd"
    GROUP BY cc.iban;
	




############################################################ NIVEL 2 ################################################################

## Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:


#OBTENGO LAS TARGETAS EN ORDEN DESC DE FECHAS, LA COLUMNA DECLINES Y LA EL ID, AGRUPADAS POR CARD_ID

CREATE TABLE estado_tarjetas AS
	WITH ranking_transaction AS (
		SELECT card_id
				, credit_card.expiring_date
				, declined
				, timestamp
				,  ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS ranking
			FROM transactions 
			INNER JOIN credit_card
			ON transactions.card_id = credit_card.id
			GROUP BY card_id, timestamp, declined
			ORDER BY card_id , timestamp DESC
	)

	# FILTRO SI ALGUNA DE LAS ULTIMAS 3 TRANSACCIONES HA SIDO RECHAZADA
	SELECT card_id
		, expiring_date
		, IF (SUM(declined)>0, "Si", "No") AS Declinada
		FROM ranking_transaction
		WHERE ranking <=3
		GROUP BY card_id
		ORDER BY card_id DESC;



#	Exercici 1
#Quantes targetes estan actives?

		### primero paso el formato de fecha actual a DATE (YYYY-MM-DD) con la función SRT_TO_DATE, pasa de string a DATE
		### obtengo todas los campos mayor a CURRENT_DATE, que es la fecha actual

SELECT COUNT(*) AS Tarjetas_Activas
	FROM estado_tarjetas
    WHERE STR_TO_DATE(expiring_date, '%d/%m/%y') > CURRENT_DATE();





############################################################ NIVEL 3 ################################################################

#Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids.

CREATE TABLE IF NOT EXISTS products (
	id				INT PRIMARY KEY,
    product_name	VARCHAR(200),
    price			VARCHAR(10),
    colour			VARCHAR(7),
    weight			DECIMAL(5,2),
    warehouse_id	VARCHAR(10)
);

#La relación entre la tabla transactions y products es N:M, creo otra tabla intermedia para cada producto y transactions.
#Tengo en cuenta que en la tabla transactions hay un campo con más de un id de producto 



	# creo la tabla intermedia, la tabla que se crea de la relación N:M
CREATE TABLE IF NOT EXISTS transaction_products (
    transaction_id VARCHAR(100),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);





	# Sepero los ids de productos, los trato como un registro por fila. Obtengo el id de transacción y un id de producto por cada fila
INSERT INTO transaction_products (transaction_id, product_id)
	SELECT id AS transaction_id
			, CAST(product_list.product_id AS UNSIGNED) AS product_id
		FROM transactions
		JOIN 
			JSON_TABLE(
				CONCAT('["', REPLACE(product_ids, ',', '","'), '"]'), "$[*]" COLUMNS(product_id INT PATH "$")
			) AS product_list;



























SELECT * FROM credit_card;
SELECT * FROM transactions;
SELECT * FROM companies;
SELECT * FROM products;
SELECT * FROM users;




