
-------------------------------------------------------------------------------------------------------------
--	NAILS
--
BEGIN;
-- Default Service Group
INSERT OR REPLACE INTO iBiz_group VALUES ( 1, 'Manicure' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 2, 'Acrylic Nails' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 3, 'Gel Nails' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 4, 'Pedicure' );

COMMIT;

BEGIN;
-- Columns from above for reference:
-- serviceID, groupID, serviceName, price, cost, taxable, isActive, duration, samplePhoto (NULL), color, isFlatRate, setupFee
INSERT OR REPLACE INTO iBiz_services VALUES ( 1, 1, 'Regular Manicure', 0, 0, 0, 1, 3600, NULL, '1::.67::.81', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 2, 1, 'French Manicure', 0, 0, 0, 1, 3600, NULL, '.4::.8::1', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 3, 1, 'Buff & Polish', 0, 0, 0, 1, 1800, NULL, '.4::.8::1', 1, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 4, 2, 'Tips & Acrylic Overlay', 0, 0, 0, 1, 1800, NULL, '1::.44::.81', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 5, 2, 'French Acrylic Tips', 0, 0, 0, 1, 1800, NULL, '1::0::0', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 6, 2, 'Acrylic Fill', 0, 0, 0, 1, 1800, NULL, '1::0::0', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 7, 2, 'Acrylic Repair', 0, 0, 0, 1, 1800, NULL, '1::0::0', 1, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 8, 3, 'Gel Full Set Tips', 0, 0, 0, 1, 3600, NULL, '1::.8::.4', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 9, 3, 'Gel Fill', 0, 0, 0, 1, 3600, NULL, '.78::.64::.78', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 10, 3, 'Gel Repair', 0, 0, 0, 1, 1800, NULL, '.8::1::.4', 1, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 11, 4, 'Spa Pedicure', 0, 0, 0, 1, 3600, NULL, '0::1::1', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 12, 4, 'Buff & Polish', 0, 0, 0, 1, 1800, NULL, '.4::.8::1', 1, 0 );
--
COMMIT;



