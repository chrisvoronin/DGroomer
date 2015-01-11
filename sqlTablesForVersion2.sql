-- This table tracks the closing of the invoice's items... payments are recorded in iBiz_closeout_payments
DROP TABLE IF EXISTS iBiz_closeout_invoice;
CREATE TABLE iBiz_closeout_invoice (
	closeoutTransactionID	INTEGER PRIMARY KEY AUTOINCREMENT,
	closeoutID  			INTEGER,
	invoiceID				INTEGER
);

DROP TABLE IF EXISTS iBiz_creditCardPayment;
CREATE TABLE iBiz_creditCardPayment (
	creditCardPaymentID		INTEGER PRIMARY KEY AUTOINCREMENT,
	amount					REAL,
	tip						REAL,
	ccNumber				TEXT,		-- Only store the last four digits!
	-- Response
	authCode				TEXT,
	gatewayTransID			TEXT,
	transHash				TEXT,
	-- Dates
	datePaid				REAL,
	dateRefunded			REAL,	-- either voided or refunded, not both
	dateVoided				REAL,	-- either voided or refunded, not both
	--
	clientID				INTEGER,
	currencyCode			TEXT,	-- country of currency being paid
	--
	firstName				TEXT,
	middleName				TEXT,
	lastName				TEXT,
	email					TEXT,
	phone					TEXT,
	notes					TEXT,
	addressStreet			TEXT,
	addressCity				TEXT,
	addressState			TEXT,
	addressZip				TEXT
);

DROP TABLE IF EXISTS iBiz_creditSettings;
CREATE TABLE iBiz_creditSettings (
	creditSettingsID	INTEGER PRIMARY KEY AUTOINCREMENT,  -- probably only 1 record
	emailGatewayReceipt	INTEGER,							-- whether or not to have Authorize send a receipt
	currencyCode		TEXT,								-- country of currency being paid
	processingType		INTEGER	DEFAULT 1					-- CP/CnP/other?
);

INSERT OR REPLACE INTO iBiz_creditSettings VALUES ( 0, 0, 'USD', 1 );