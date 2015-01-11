







DROP TABLE IF EXISTS psa_currencies;
CREATE TABLE psa_currencies (
	currencyID		INTEGER PRIMARY KEY,
	country			TEXT,
	currency		TEXT,
	code			TEXT,
	symbol			TEXT,
	decimalPlaces	REAL
);


DROP TABLE IF EXISTS psa_currencies;
CREATE TABLE psa_currencies (
	currencyID		INTEGER PRIMARY KEY,
	country			TEXT,
	currency		TEXT,
	code			TEXT,
	symbol			TEXT,
	decimalPlaces	REAL
);



BEGIN;
INSERT INTO psa_currencies VALUES ( 0, 'Afghanistan', 'Afghani', 'AFA', '', 0 );

COMMIT;









DROP TABLE IF EXISTS psa_reportConsolidated;
CREATE TABLE psa_reportConsolidated (
	reportConsolidatedID 	INTEGER PRIMARY KEY,
	serviceQuantity 		INTEGER, 
	serviceAmount 			REAL, 
	retailQuantity 			INTEGER, 
	retailAmount 			REAL, 
	productUsageQuantity 	INTEGER, 
	productUsageAmount 		REAL, 
	retailUsageQuantity 	INTEGER, 
	retailUsageAmount 		REAL, 
	feesQuantity 			INTEGER, 
	feesAmount 				REAL
);



DROP TABLE IF EXISTS state;
CREATE TABLE state (
	stateID  			INTEGER PRIMARY KEY,
	stateAbbreviation 	VARCHAR(5), 
	stateName 			VARCHAR(50), 
	sortOrder 			INTEGER
);





BEGIN;
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '1', 'AL','Alabama','1');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '2', 'AK','Alaska','2');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '3', 'AZ','Arizona','3');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '4', 'AR','Arkansas','4');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '5', 'CA','California','5');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '6', 'CO','Colorado','6');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '7', 'CT','Connecticut','7');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '8', 'DE','Delaware','8');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '9', 'DC','District of Columbia','9');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '10', 'FL','Florida','10');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '11', 'GA','Georgia','11');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '12', 'HI','Hawaii','12');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '13', 'ID','Idaho','13');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '14', 'IL','Illinois','14');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '15', 'IN','Indiana','15');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '16', 'IA','Iowa','16');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '17', 'KS','Kansas','17');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '18', 'KY','Kentucky','18');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '19', 'LA','Louisiana','19');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '20', 'ME','Maine','20');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '21', 'MD','Maryland','21');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '22', 'MA','Massachusetts','22');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '23', 'MI','Michigan','23');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '24', 'MN','Minnesota','24');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '25', 'MS','Mississippi','25');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '26', 'MO','Missouri','26');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '27', 'MT','Montana','27');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '28', 'NE','Nebraska','28');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '29', 'NV','Nevada','29');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '30', 'NH','New Hampshire','30');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '31', 'NJ','New Jersey','31');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '32', 'NM','New Mexico','32');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '33', 'NY','New York','33');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '34', 'NC','North Carolina','34');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '35', 'ND','North Dakota','35');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '36', 'OH','Ohio','36');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '37', 'OK','Oklahoma','37');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '38', 'OR','Oregon','38');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '39', 'PA','Pennsylvania','39');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '40', 'RI','Rhode island','40');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '41', 'SC','South carolina','41');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '42', 'SD','South dakota','42');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '43', 'TN','Tennessee','43');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '44', 'TX','Texas','44');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '45', 'UT','Utah','45');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '46', 'VT','Vermont','46');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '47', 'VA','Virginia','47');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '48', 'WA','Washington','48');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '49', 'WV','West virginia','49');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '50', 'WI','Wisconsin','50');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '51', 'WY','Wyoming','51');
INSERT INTO state(stateID, stateAbbreviation, stateName, sortOrder) VALUES( '52', 'ZZ','Other','52');
COMMIT;