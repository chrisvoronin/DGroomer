
-------------------------------------------------------------------------------------------------------------
--	PHOTOGRAPHER
--
BEGIN;
-- Default Service Group
INSERT OR REPLACE INTO iBiz_group VALUES ( 1, 'Weddings' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 2, 'Family' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 3, 'Professional' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 4, 'Restoration' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 5, 'Events' );
--
COMMIT;

BEGIN;
-- Columns from above for reference:
-- serviceID, groupID, serviceName, price, cost, taxable, isActive, duration, samplePhoto (NULL), color, isFlatRate, setupFee
INSERT OR REPLACE INTO iBiz_services VALUES ( 1, 1, 'Engagement Photography', 0, 0, 0, 1, 3600, NULL, '1::.8::.4', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 2, 1, 'Wedding Photography', 0, 0, 0, 1, 3600, NULL, '1::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 3, 1, 'Wedding Video', 0, 0, 0, 1, 3600, NULL, '.6::.4::.2', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 4, 2, 'Child Portraits', 0, 0, 0, 1, 3600, NULL, '1::.67::.81', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 11, 2, 'Senior Portraits', 0, 0, 0, 1, 3600, NULL, '1::.44::.81', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 5, 2, 'Family Portraits', 0, 0, 0, 1, 3600, NULL, '1::0::1', 1, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 12, 3, 'Product Galleries', 0, 0, 0, 1, 3600, NULL, '1::0::0', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 6, 3, 'Professional Headshots', 0, 0, 0, 1, 3600, NULL, '.78::.64::.78', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 10, 3, 'Professional Portraits', 0, 0, 0, 1, 3600, NULL, '.5::0::.5', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 7, 3, 'Passport Photo', 0, 0, 0, 1, 1800, NULL, '.4::.8::1', 1, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 8, 4, 'Film to DVD', 0, 0, 0, 1, 3600, NULL, '1::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 9, 4, 'Picture Restoration', 0, 0, 0, 1, 3600, NULL, '1::1::.4', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 13, 5, 'Social Events', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 14, 5, 'Special Events', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 15, 5, 'Group/Team Photos', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 16, 5, 'Sports Photography', 0, 0, 0, 1, 3600, NULL, '0::.5::0', 0, 0 );
--
COMMIT;
