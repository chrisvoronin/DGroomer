DROP TABLE IF EXISTS iBiz_appointments;
CREATE TABLE iBiz_appointments (
	appointmentID  			INTEGER PRIMARY KEY AUTOINCREMENT,
	startDateTime 			REAL, -- timeIntervalSinceReferenceDate:
	clientID 				INTEGER,
	type					INTEGER,
	typeID	 				INTEGER,
	notes 					TEXT,
	duration	 			INTEGER, 
	standingAppointmentID	INTEGER
);

DROP TABLE IF EXISTS iBiz_appointmentTypes;
CREATE TABLE iBiz_appointmentTypes (
	appointmentTypeID	INTEGER PRIMARY KEY,
	type				TEXT
);

DROP TABLE IF EXISTS iBiz_standingAppointment;
CREATE TABLE iBiz_standingAppointment (
	standingAppointmentID 	INTEGER PRIMARY KEY AUTOINCREMENT,
	repeatType				INTEGER DEFAULT 0,	-- Never, Daily, Weekly, Monthly, Yearly, Every 2 Weeks, Every 3 weeks, Every 4 weeks.
	repeatCustom			TEXT, 				-- Special repeats
	repeatUntil				TEXT	 -- The date on which to stop repeating
);


DROP TABLE IF EXISTS iBiz_client;
CREATE TABLE iBiz_client (
	clientID  		INTEGER PRIMARY KEY AUTOINCREMENT,
	notes 			TEXT,
	ABPersonRefID	INTEGER UNIQUE,
	isActive		INTEGER DEFAULT 1,
	firstName		TEXT,
	lastName		TEXT
);


DROP TABLE IF EXISTS iBiz_closeout;
CREATE TABLE iBiz_closeout (
	closeoutID  		INTEGER PRIMARY KEY AUTOINCREMENT,
	closeoutDate		REAL	-- timeIntervalSinceReferenceDate
);

DROP TABLE IF EXISTS iBiz_closeout_payment;
CREATE TABLE iBiz_closeout_payment (
	closeoutPaymentID	INTEGER PRIMARY KEY AUTOINCREMENT,
	closeoutID  		INTEGER,
	paymentID			INTEGER
);

DROP TABLE IF EXISTS iBiz_closeout_transaction;
CREATE TABLE iBiz_closeout_transaction (
	closeoutTransactionID	INTEGER PRIMARY KEY AUTOINCREMENT,
	closeoutID  			INTEGER,
	transactionID			INTEGER
);


DROP TABLE IF EXISTS iBiz_company;
CREATE TABLE iBiz_company (
	companyID  				INTEGER PRIMARY KEY,
	companyName 			TEXT, 
	salesTax 				REAL, 
	companyAddress1 		TEXT, 
	companyAddress2 		TEXT, 
	companyCity 			TEXT, 
	stateID 				TEXT,
	companyZipCode 			INTEGER, 
	companyEmail 			TEXT,
	companyPhone 			TEXT, 
	companyFax 				TEXT, 
	MonthsOldAppointments 	INTEGER, 
	OwnerName 				TEXT,
	commissionRate 			REAL,
	logo					TEXT	-- Location of image saved to local app directory
);

DROP TABLE IF EXISTS iBiz_email;
CREATE TABLE iBiz_email (
	emailID			INTEGER PRIMARY KEY AUTOINCREMENT,
	bccSelf			INTEGER,
	subject			TEXT,
	message			TEXT,
	type			INTEGER	-- This should probably reference a DB enum table, but the types are known in code for now...
);

--
--	For future implementation of mass mailing, storage for clients to send to...
--
DROP TABLE IF EXISTS iBiz_email_recipients;
CREATE TABLE iBiz_email_recipients (
	emailRecipientID	INTEGER PRIMARY KEY AUTOINCREMENT,
	emailID				INTEGER,
	clientID			INTEGER
);

DROP TABLE IF EXISTS iBiz_giftCertificate;
CREATE TABLE iBiz_giftCertificate ( 
	giftCertificateID 		INTEGER PRIMARY KEY AUTOINCREMENT,	-- This will probably be printed on the certificate
	purchaser 				INTEGER,				-- Client ID
	recipientFirst 			TEXT,
	recipientLast			TEXT,
	purchaseDate 			REAL,					-- timeIntervalSinceReferenceDate
	expiration	 			REAL, 					-- timeInterval...	
	amountUsed	 			REAL,
	amountPurchased			REAL,
	message 				TEXT,
	notes				 	TEXT
);

DROP TABLE IF EXISTS iBiz_group;
CREATE TABLE iBiz_group ( 
	groupID 			INTEGER PRIMARY KEY AUTOINCREMENT,
	groupDescription 	TEXT
);


DROP TABLE IF EXISTS iBiz_productAdjustmentType;
CREATE TABLE iBiz_productAdjustmentType (
	adjustmentTypeID 	INTEGER PRIMARY KEY AUTOINCREMENT,
	adjustmentType 		TEXT
);

DROP TABLE IF EXISTS iBiz_productAdjustment;
CREATE TABLE iBiz_productAdjustment (
	productAdjustmentID INTEGER PRIMARY KEY AUTOINCREMENT,
	productID 			INTEGER,
	adjustmentTypeID 	INTEGER,
	adjustmentDate 		REAL, 
	adjustmentQuantity 	INTEGER
);

DROP TABLE IF EXISTS iBiz_productType;
CREATE TABLE iBiz_productType (
	productTypeID 		INTEGER PRIMARY KEY AUTOINCREMENT,
	productDescription 	TEXT
);

DROP TABLE IF EXISTS iBiz_products;
CREATE TABLE iBiz_products (
	productID  		INTEGER PRIMARY KEY AUTOINCREMENT,
	productNumber 	INTEGER, 
	productName 	TEXT, 
	cost 			REAL,
	price 			REAL, 
	productMin 		INTEGER, 
	productMax 		INTEGER, 
	onHand  		INTEGER, 
	vendorID 		INTEGER,
	productTypeID 	INTEGER,
	taxable 		INTEGER,
	isActive 		INTEGER DEFAULT 1
);

DROP TABLE IF EXISTS iBiz_services;
CREATE TABLE iBiz_services (
	serviceID  	INTEGER PRIMARY KEY AUTOINCREMENT,
	groupID 	INTEGER,
	serviceName TEXT, 
	price 		REAL,
	cost 		REAL, 
	taxable 	INTEGER, 
	isActive 	INTEGER DEFAULT 1, 
	duration 	INTEGER,
	samplePhoto TEXT, -- Path to image file
	color		TEXT,
	isFlatRate	INTEGER,
	setupFee	REAL
);

DROP TABLE IF EXISTS iBiz_settings;
CREATE TABLE iBiz_settings (
	settingsID 				INTEGER PRIMARY KEY,
	mondayStart 			TEXT,
	mondayFinish 			TEXT,
	tuesdayStart 			TEXT,
	tuesdayFinish 			TEXT,
	wednesdayStart 			TEXT, 
	wednesdayFinish 		TEXT,
	thursdayStart 			TEXT,
	thursdayFinish 			TEXT,
	fridayStart 			TEXT,
	fridayFinish 			TEXT,
	saturdayStart 			TEXT, 
	saturdayFinish 			TEXT,
	sundayStart 			TEXT,
	sundayFinish 			TEXT,
	isMondayOff				INTEGER DEFAULT 0,
	isTuesdayOff			INTEGER DEFAULT 0,
	isWednesdayOff			INTEGER DEFAULT 0,
	isThursdayOff			INTEGER DEFAULT 0,
	isFridayOff				INTEGER DEFAULT 0,
	isSaturdayOff			INTEGER DEFAULT 0,
	isSundayOff				INTEGER DEFAULT 0,
	is15MinuteIntervals		INTEGER	DEFAULT 0,
	clientNameSort			INTEGER DEFAULT 0,	-- 4.1 -- 0 = Last, First; 1 = First Last;
	clientNameView			INTEGER DEFAULT 0	-- 4.1 -- 0 = Last, First; 1 = First Last;
);


DROP TABLE IF EXISTS iBiz_transaction;
CREATE TABLE iBiz_transaction (
	transactionID		INTEGER PRIMARY KEY AUTOINCREMENT,
	appointmentID		INTEGER,		-- If there is an associated appointment, not required
	clientID 			INTEGER NOT NULL,
	taxPercent			REAL DEFAULT 0,	-- Amount of tax for this transaction (can be 0)
	tip					REAL DEFAULT 0,
	totalForTable		REAL,
	dateOpened			REAL,
	dateClosed			REAL DEFAULT 0,
	dateVoided			REAL DEFAULT 0,
	dateRefunded		REAL DEFAULT 0,
	commissionPercent	REAL			-- new to iBiz
);


DROP TABLE IF EXISTS iBiz_transactionItem;
CREATE TABLE iBiz_transactionItem (
	transactionItemID		INTEGER PRIMARY KEY AUTOINCREMENT,
	transactionID			INTEGER,			-- "Foreign key" references the transaction
	itemID 					INTEGER,			-- "Foreign key" references product/service/certificate ID
	itemTypeID				INTEGER,			-- The type of item
	discountAmount			REAL 	DEFAULT 0,
	isPercentDiscount		INTEGER DEFAULT 1,
	productAdjustmentID		INTEGER,
	itemPrice				REAL,
	cost					REAL,		-- new
	setupFee				REAL,		-- new
	taxed					INTEGER		-- new
);

DROP TABLE IF EXISTS iBiz_transactionItemType;
CREATE TABLE iBiz_transactionItemType (
	transactionItemTypeID 	INTEGER PRIMARY KEY AUTOINCREMENT,
    transactionItemType 	TEXT
);


DROP TABLE IF EXISTS iBiz_transactionPayment;
CREATE TABLE iBiz_transactionPayment (
	transactionPaymentID 		INTEGER PRIMARY KEY AUTOINCREMENT,
	transactionID 				INTEGER DEFAULT -1,	-- either transactionID or
	invoiceID					INTEGER DEFAULT -1,	-- invoiceID, probably not both
	transactionPaymentTypeID	INTEGER,
	amount						REAL,
	extraInfo					TEXT,		-- A place for check #, coupon #, certificateID, etc.
	datePaid					REAL
);

DROP TABLE IF EXISTS iBiz_transactionPaymentType;
CREATE TABLE iBiz_transactionPaymentType (
	transactionPaymentTypeID 	INTEGER PRIMARY KEY AUTOINCREMENT,
    transactionPaymentType 		TEXT
);


DROP TABLE IF EXISTS iBiz_vendor;
CREATE TABLE iBiz_vendor (
	vendorID 		INTEGER PRIMARY KEY AUTOINCREMENT,
	vendorName 		TEXT, 
	contact 		TEXT, 
	address1 		TEXT, 
	address2 		TEXT, 
	city 			TEXT, 
	stateID 		TEXT,
	zipCode 		INTEGER, 
	telephoneNumber TEXT, 
	email 			TEXT, 
	faxNumber 		TEXT
);


--
--	PROJECT TABLES
--
DROP TABLE IF EXISTS iBiz_projects;
CREATE TABLE iBiz_projects (
	projectID		INTEGER PRIMARY KEY AUTOINCREMENT,
	clientID		INTEGER,
	name			TEXT,
	notes			TEXT,
	dateCreated		REAL DEFAULT 0,
	dateCompleted	REAL DEFAULT 0,
	dateDue			REAL DEFAULT 0,
	dateModified	REAL DEFAULT 0,
	totalForTable	REAL
);

DROP TABLE IF EXISTS iBiz_project_invoice;
CREATE TABLE iBiz_project_invoice (
	projectInvoiceID	INTEGER PRIMARY KEY AUTOINCREMENT,
	projectID			INTEGER,
	type				INTEGER,
	name				TEXT,
	dateDue				REAL,
	dateOpened			REAL,
	datePaid			REAL,
	commissionPercent	REAL,
	taxPercent			REAL,
	totalForTable		REAL,
	notes				TEXT
);

DROP TABLE IF EXISTS iBiz_project_products;
CREATE TABLE iBiz_project_products (
	projectProductID	INTEGER PRIMARY KEY AUTOINCREMENT,
	productID			INTEGER,
	projectID			INTEGER,
	price				REAL,
	discountAmount		REAL 	DEFAULT 0,
	isPercentDiscount	INTEGER DEFAULT 1,
	taxed				INTEGER DEFAULT 1,
	cost				REAL,
	productAdjustmentID	INTEGER
);

DROP TABLE IF EXISTS iBiz_project_services;
CREATE TABLE iBiz_project_services (
	projectServiceID	INTEGER PRIMARY KEY AUTOINCREMENT,
	projectID			INTEGER,
	serviceID			INTEGER,
	price				REAL,
	setupFee			REAL,
	secondsEstimated	INTEGER,
	secondsWorked		INTEGER,
	discountAmount		REAL,
	isFlatRate			INTEGER DEFAULT 0,
	isPercentDiscount	INTEGER DEFAULT 1,
	isTimed				INTEGER DEFAULT 1,
	taxed				INTEGER DEFAULT 0,
	dateTimerStarted	REAL DEFAULT 0,
	isTiming			INTEGER DEFAULT 0,
	cost				REAL
);


DROP TABLE IF EXISTS iBiz_project_invoice_product;
CREATE TABLE iBiz_project_invoice_product (
	pipID				INTEGER PRIMARY KEY,
	projectProductID	INTEGER,
	projectInvoiceID	INTEGER
);

DROP TABLE IF EXISTS iBiz_project_invoice_service;
CREATE TABLE iBiz_project_invoice_service (
	pisID				INTEGER PRIMARY KEY,
	projectServiceID	INTEGER,
	projectInvoiceID	INTEGER
);

DROP TABLE IF EXISTS iBiz_project_transaction;
CREATE TABLE iBiz_project_transaction (
	projectTransactionID	INTEGER PRIMARY KEY AUTOINCREMENT,
	projectID				INTEGER,
	transactionID			INTEGER
);



--
-- Data Values
--
BEGIN;
INSERT INTO iBiz_appointmentTypes VALUES ( 0, 'Block' );
INSERT INTO iBiz_appointmentTypes VALUES ( 1, 'Project' );
INSERT INTO iBiz_appointmentTypes VALUES ( 2, 'Single Service' );
COMMIT;

BEGIN;
-- Insert the Guest client
INSERT INTO iBiz_client VALUES ( 0, '', -1, 1, '(null)', '(null)' );
COMMIT;

BEGIN;
-- Default Product Type
INSERT INTO iBiz_productType VALUES ( 0, 'Untyped' );
COMMIT;

BEGIN;
-- Default Service Group
INSERT INTO iBiz_group VALUES ( 0, 'Ungrouped' );
COMMIT;

BEGIN;
-- Insert the one (and only?) company record
INSERT INTO iBiz_company VALUES ( 0, '', 8.00, '', '', '', '', 0, '', '', '', 0, '', 10.00, '' );
COMMIT;

BEGIN;
-- Insert the default settings values
INSERT INTO iBiz_settings VALUES ( 0, '8:00 AM', '5:00 PM', '8:00 AM', '5:00 PM', '8:00 AM', '5:00 PM', '8:00 AM', '5:00 PM', '8:00 AM', '5:00 PM', '8:00 AM', '5:00 PM', '8:00 AM', '5:00 PM', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
COMMIT;

BEGIN;
INSERT INTO iBiz_productAdjustmentType VALUES('0', 'Add to Inventory');
INSERT INTO iBiz_productAdjustmentType VALUES('1', 'Professional');
INSERT INTO iBiz_productAdjustmentType VALUES('2', 'Retail');
COMMIT;

BEGIN;
INSERT INTO iBiz_transactionItemType VALUES ('1', 'Gift Certificate');
INSERT INTO iBiz_transactionItemType VALUES ('2', 'Product');
INSERT INTO iBiz_transactionItemType VALUES ('3', 'Service');
COMMIT;

BEGIN;
INSERT INTO iBiz_transactionPaymentType VALUES ('0', 'Cash');
INSERT INTO iBiz_transactionPaymentType VALUES ('1', 'Check');
INSERT INTO iBiz_transactionPaymentType VALUES ('2', 'Coupon');
INSERT INTO iBiz_transactionPaymentType VALUES ('3', 'Credit');
INSERT INTO iBiz_transactionPaymentType VALUES ('4', 'Gift Certificate');
INSERT INTO iBiz_transactionPaymentType VALUES ('5', 'Other');
COMMIT;

--
--	Inserts for email messages... these 3 shouldn't be allowed deletion
--
BEGIN;
INSERT INTO iBiz_email VALUES ( 0, 0, 'Happy Anniversary!', "Dear <<CLIENT>>,<<NEWLINE>>Wishing a happy anniversary to you and yours!<<NEWLINE>><<NEWLINE>>Sincerely,<<NEWLINE>>Your Favorite Business", 0 );
INSERT INTO iBiz_email VALUES ( 1, 0, 'Happy Birthday!', 'Dear <<CLIENT>>,<<NEWLINE>>Happy Birthday!<<NEWLINE>><<NEWLINE>>Sincerely,<<NEWLINE>>Your Favorite Business', 1 );
INSERT INTO iBiz_email VALUES ( 2, 0, 'Appointment Reminder', 'Dear <<CLIENT>>,<<NEWLINE>>A friendly reminder that you have an appointment coming up on <<APPT_DATE>> at <<APPT_TIME>>.<<NEWLINE>><<NEWLINE>>Sincerely,<<NEWLINE>>Your Favorite Business', 2 );
COMMIT;
