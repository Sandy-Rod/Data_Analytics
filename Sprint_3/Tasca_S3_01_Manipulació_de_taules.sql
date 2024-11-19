use transactionsIT;
############################################################ NIVEL 1 ################################################################

#Exercici 1 : La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi detalls crucials sobre les targetes de crèdit. 
#La nova taula ha de ser capaç d'identificar de manera única cada targeta i establir una relació adequada amb les altres dues taules ("transaction" i "company"). 
#Després de crear la taula serà necessari que ingressis la informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i 
#realitzar una breu descripció d'aquest.

CREATE TABLE IF NOT EXISTS credit_card (
        id VARCHAR(9) PRIMARY KEY UNIQUE,
        iban VARCHAR(100),
        pan VARCHAR(30),
        pin VARCHAR(4),
        cvv VARCHAR(3),
        expiring_date VARCHAR(8)
    );

    
ALTER TABLE transaction
ADD CONSTRAINT FK_Transaction_CreditCard
FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);     
			



#Exercici 2: El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. 
#La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

select * from credit_card WHERE id='CcU-2938';

#cambio el iban TR301950312213576817638661 por R323456312213576817699999

UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938'; 

SELECT * 
	FROM credit_card 
    WHERE id='CcU-2938';



# Exercici3: En la taula "transaction" ingressa un nou usuari 

	# Si creo un registro en la tabla transaction da error porque no existe la compañia b-9999 y en la tabla credit_car no existe el registro CcU-9999

	#primero creo el registro en la tabla company
INSERT INTO company (id, company_name, phone, email, country, website) 
			VALUES ('b-9999', 'Sprint_2', '99 99 99 99 99', 'sprint_2@yahoo.net', 'Spain', 'https://sprint2.com/site');
	
    
    #ahora creo el registro en la tabla credit_card 
INSERT INTO credit_card (id, iban, pin, cvv, expiring_date) 
			VALUES ('CcU-9999', 'TR999999999999999999999999', '9999', '999', '09/09/99');
            
	
    # continuo con la creación de un usuario
INSERT INTO user (id, name, surname, phone, email, birth_date, country, city, postal_code, address) 
			VALUES ("9999", "Sprint", "Sprint_3", "9-999-999-9999", "sprint_3@protonmail.edu", "Nov 17, 1985",  "Spain", "Lowell", "99999", "348-7818 Sagittis St.");

            
	#ahora que tengo creado los registros, puedo hacer un insert en la tabla transaction
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
			VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);


# Compruebo con un select la creación del registro
SELECT *
	FROM transaction
    WHERE id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';




#Exercici4: Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.
SELECT * FROM credit_card;


ALTER TABLE credit_card
DROP COLUMN pan;



############################################################ NIVEL 2 ################################################################

#Exercici 1: Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.

DELETE FROM transaction 
WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';





#Exercici 2: La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
#S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada 
#VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte. 
#País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

CREATE OR REPLACE VIEW VistaMarketing AS
SELECT c.company_name AS Nom_Companyia
	, c.phone AS Telefon_Companyia
    , c.country AS Pais_Companyia
    , t.company_id AS Id_Companyia
	, ROUND(AVG(t.amount), 2) AS Media_Total
	FROM transaction t
    INNER JOIN company c
			ON t.company_id = c.id
	WHERE declined = 0
	GROUP BY t.company_id;
    
    
# Compruebo la vista creada
SELECT *
	FROM vistamarketing
    ORDER BY Media_Total DESC;





#Exercici 3: Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"

SELECT * 
	FROM vistamarketing 
    WHERE Pais_Companyia = 'Germany';
    

    
    
    
    
    

############################################################ NIVEL 3 ################################################################

#Exercici 1: La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, 
#però no recorda com les va realitzar. 

	#cargo el fichero estructura_datos_user.sql
	#cargo el fichero datos_introducir_user (1).sql


##### TABLA COMPANY

ALTER TABLE company
DROP COLUMN website;

SELECT * FROM company;





##### TABLA USER

ALTER TABLE user
RENAME data_user;

SELECT * FROM data_user;




## Cambio el nombre de la columna email por el nombre de personal_email

ALTER TABLE data_user
RENAME COLUMN email to personal_email;


SELECT *
	FROM data_user;





##### TABLA CREDIT_CARD

ALTER TABLE credit_card
ADD COLUMN fecha_actual DATE DEFAULT (CURDATE());







#Exercici 2 : L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
    #ID de la transacció
    #Nom de l'usuari/ària
    #Cognom de l'usuari/ària
    #IBAN de la targeta de crèdit usada.
    #Nom de la companyia de la transacció realitzada.
    #Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.

CREATE OR REPLACE VIEW InformeTecnico AS
SELECT t.id as ID_Transacció
	, u.name as Nom_Usuari
    , u.surname as Cognom_Usuari
	, cc.iban as IBAN_Targeta_Credit
    , co.company_name as Nom_Companyia
    , co.country as Pais_Companyia
    ,IF (declined = 0, "No", "Si") as Pagament_Rebutjat
	FROM transaction t
    INNER JOIN transactionsIT.data_user u
			ON t.user_id = u.id
	INNER JOIN credit_card cc
			ON cc.id = t.credit_card_id
	INNER JOIN company co
			ON co.id = t.company_id;







#Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.

SELECT * 
	FROM informetecnico
    ORDER BY ID_Transacció DESC;







