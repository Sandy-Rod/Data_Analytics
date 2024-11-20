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
    id 				VARCHAR(20) PRIMARY KEY,
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
	id				VARCHAR(100) PRIMARY KEY,
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


SELECT name_user
	, surname
    , country
	FROM users
    WHERE id IN ( SELECT user_id
						FROM  transactions
                        GROUP BY user_id
						HAVING (COUNT(user_id) >30)
                        );





#	Exercici 2
# Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.
#con subquery

SELECT ROUND(AVG(amount),2) AS Media
	FROM transactions
    WHERE business_id IN ( SELECT id
							FROM companies c
                            WHERE company_name = 'Donec Ltd');




############################################################ NIVEL 2 ################################################################

## Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions 
#van ser declinades i genera la següent consulta:

	#OBTENGO LAS TARGETAS EN ORDEN DESC DE FECHAS, LA COLUMNA DECLINES Y LA EL ID, AGRUPADAS POR CARD_ID

DROP TABLE IF EXISTS estado_tarjetas;
CREATE TABLE estado_tarjetas AS
	WITH ranking_transaction AS (
		SELECT card_id
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
		, IF (SUM(declined)>=3, "No", "Si") AS Activas
		FROM ranking_transaction
		WHERE ranking <=3
		GROUP BY card_id
		ORDER BY card_id DESC;

#Creacion 
ALTER TABLE estado_tarjetas
ADD CONSTRAINT FK_CreditCard_Estado
FOREIGN KEY (card_id)
REFERENCES credit_card (id);



#	Exercici 1

#Quantes targetes estan actives?
SELECT COUNT(*) AS Estan_Activas
	FROM estado_tarjetas
    WHERE Activas = 'Si';



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





	# Separo los ids de productos, los trato como un registro por fila. Obtengo el id de transacción y un id de producto por cada fila
INSERT INTO transaction_products (transaction_id, product_id)
	SELECT id AS transaction_id
			, CAST(product_list.product_id AS UNSIGNED) AS product_id
		FROM transactions
		JOIN 
			JSON_TABLE(
				CONCAT('["', REPLACE(product_ids, ',', '","'), '"]'), "$[*]" COLUMNS(product_id INT PATH "$")
			) AS product_list;

		

#	Exercici 1

# Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
	#tengo en cuenta la columna declined, porque se necesita saber las ventas. 
SELECT product_name
	, COUNT(product_id) AS total_producto
	FROM transaction_products tp
    INNER JOIN transactions t
			ON tp.transaction_id = t.id
	INNER JOIN products p
			ON tp.product_id = p.id
	WHERE t.declined = 0
    GROUP BY product_id
    ORDER BY total_producto;
    
    



