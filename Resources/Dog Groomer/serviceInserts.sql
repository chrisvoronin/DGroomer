
-------------------------------------------------------------------------------------------------------------
--	DOG GROOMER
--
BEGIN;
-- Default Service Group
INSERT OR REPLACE INTO iBiz_group VALUES ( 1, 'Teeth' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 2, 'Flea & Tick Treatments' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 3, 'Nails' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 4, 'Shampoo & Conditioner' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 5, 'Grooming Packages' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 6, 'Misc' );
COMMIT;

BEGIN;
-- Columns from above for reference:
-- serviceID, groupID, serviceName, price, cost, taxable, isActive, duration, samplePhoto (NULL), color, isFlatRate, setupFee
INSERT OR REPLACE INTO iBiz_services VALUES ( 1, 1, 'Teeth Cleaning Minor', 0, 0, 0, 1, 1800, NULL, '1::.67::.81', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 2, 1, 'Teeth Cleaning Major', 0, 0, 0, 1, 1800, NULL, '.4::.8::1', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 3, 2, 'Flea & Tick Bath', 0, 0, 0, 1, 1800, NULL, '1::.44::.81', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 4, 2, 'Flea & Tick Powder', 0, 0, 0, 1, 1800, NULL, '1::0::0', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 5, 3, 'Nail Trim', 0, 0, 0, 1, 3600, NULL, '1::.8::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 6, 3, 'Nail Grinding', 0, 0, 0, 1, 3600, NULL, '.78::.64::.78', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 7, 3, 'Nail Polish', 0, 0, 0, 1, 1800, NULL, '.8::1::.4', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 8, 4, 'Itchy Skin', 0, 0, 0, 1, 1800, NULL, '0::1::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 9, 4, 'Fur Brightening', 0, 0, 0, 1, 1800, NULL, '.4::.8::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 10, 4, 'Low-Shedding', 0, 0, 0, 1, 5400, NULL, '.6::.4::.2', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 11, 4, 'Exfoliating Scrub', 0, 0, 0, 1, 1800, NULL, '.8::1::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 12, 4, 'Hypoallergenic', 0, 0, 0, 1, 3600, NULL, '.8::1::.4', 0, 0 );


INSERT OR REPLACE INTO iBiz_services VALUES ( 13, 5, 'Full Service Groom', 0, 0, 0, 1, 3600, NULL, '1::1::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 14, 5, 'Premium Groom', 0, 0, 0, 1, 3600, NULL, '1::1::.4', 0, 0 );
COMMIT;


