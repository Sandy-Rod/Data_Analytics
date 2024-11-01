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

CREATE INDEX Index_Credit_Card ON transaction(credit_card_id);       

CREATE INDEX Index_Id ON credit_card(id);
    
ALTER TABLE credit_card
ADD CONSTRAINT FK_Transaction
FOREIGN KEY (id) REFERENCES transaction(credit_card_id);     
			



#Exercici 2: El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari amb ID CcU-2938. 
#La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. Recorda mostrar que el canvi es va realitzar.

select * from credit_card WHERE id='CcU-2938';

#cambio el iban TR301950312213576817638661 por R323456312213576817699999

UPDATE credit_card
SET iban = 'R323456312213576817699999'
WHERE id = 'CcU-2938'; 

select * from credit_card WHERE id='CcU-2938';




# Exercici3: En la taula "transaction" ingressa un nou usuari 
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
				VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999', 9999, 829.999, -117.999, 111.11, 0);

#Da error porque la compañía ‘b-9999’ no existe, en la tabla credit_card no existe el registro ‘CcU-9999’.



#Exercici4: Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_*card. Recorda mostrar el canvi realitzat.
SELECT * FROM credit_card;


ALTER TABLE credit_card
DROP COLUMN pan;



############################################################ NIVEL 2 ################################################################

#Exercici 1: Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 de la base de dades.

SELECT ＊ FROM transaction WHERE id='82C6281E-099A-1859-84EE-880298603802';

# desactivamos a opción de verificar las restricciones de clave foranea para Las tablas
SET foreign_key_checks = 0;

#ahora si puedo elininar el registro
DELETE FROM transaction WHERE id='82C6281E-099A-1859-84EE-880298603802';

#compruebo que ya no existe el registro
SELECT ＊ FROM transaction WHERE id='82C6201E-0991-1859-84EE-8802986D3882';

#activo la opcion de verificar als resticciones de clave foranea para Las tabLas
SET foreign_key_checks = 1;





#Exercici 2: La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi i estratègies efectives. 
#S'ha sol·licitat crear una vista que proporcioni detalls clau sobre les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada 
#VistaMarketing que contingui la següent informació: Nom de la companyia. Telèfon de contacte. 
#País de residència. Mitjana de compra realitzat per cada companyia. Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

CREATE VIEW VistaMarketing AS
SELECT company_name
	, phone
    , country
    , AVG(t.amount) AS Mitjana
FROM company c
INNER JOIN transaction t
		ON c.id = t. company_id
GROUP BY c.id
ORDER BY Mitjana DESC;
        
        


#Exercici 3: Filtra la vista VistaMarketing per a mostrar només les companyies que tenen el seu país de residència en "Germany"




############################################################ NIVEL 3 ################################################################

#Exercici 1: La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. Un company del teu equip va realitzar modificacions en la base de dades, 
#però no recorda com les va realitzar. 

#cargo el fichero estructura_datos_user.sql
#cargo el fichero datos_introducir_user (1).sql



#Exercici 2 : L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui la següent informació:
    #ID de la transacció
    #Nom de l'usuari/ària
    #Cognom de l'usuari/ària
    #IBAN de la targeta de crèdit usada.
    #Nom de la companyia de la transacció realitzada.
    #Assegura't d'incloure informació rellevant de totes dues taules i utilitza àlies per a canviar de nom columnes segons sigui necessari.


CREATE VIEW InformeTecnico AS
SELECT t.id as ID_Transacció
	, u.name as Nom_Usuari
    , u.surname as Cognom_Usuari
	, cc.iban as IBAN_Targeta_Credit
    , co.company_name as Nom_Companyia
    , co.country as Pais_Companyia
	FROM transaction t
    INNER JOIN transactionsIT.user u
			ON t.user_id = u.id
	INNER JOIN credit_card cc
			ON cc.id = t.credit_card_id
	INNER JOIN company co
			ON co.id = t.company_id;


#Mostra els resultats de la vista, ordena els resultats de manera descendent en funció de la variable ID de transaction.

SELECT * 
	FROM informetecnico
    ORDER BY ID_Transacció DESC;




