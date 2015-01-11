
-------------------------------------------------------------------------------------------------------------
--	LOCKSMITH
--
BEGIN;
-- Default Service Group
INSERT OR REPLACE INTO iBiz_group VALUES ( 1, 'Residential' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 2, 'Commercial' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 3, 'Automotive' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 4, 'Emergency' );
--
COMMIT;
--
BEGIN;
-- Columns from above for reference:
-- serviceID, groupID, serviceName, price, cost, taxable, isActive, duration, samplePhoto (NULL), color, isFlatRate, setupFee
INSERT OR REPLACE INTO iBiz_services VALUES ( 0, 1, 'Door Unlocking', 0, 0, 0, 1, 1800, NULL, '1::.8::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 1, 2, 'Door Unlocking', 0, 0, 0, 1, 1800, NULL, '1::.8::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 2, 3, 'Door Unlocking', 0, 0, 0, 1, 1800, NULL, '1::.8::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 3, 4, 'Door Unlocking', 0, 0, 0, 1, 1800, NULL, '1::.8::.4', 0, 0 );

INSERT OR REPLACE INTO iBiz_services VALUES ( 4, 1, 'Key Making', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 5, 2, 'Key Making', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 6, 3, 'Key Making', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 7, 4, 'Key Making', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );

INSERT OR REPLACE INTO iBiz_services VALUES ( 8, 1, 'Lock Install/Repair', 0, 0, 0, 1, 3600, NULL, '.4::.8::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 9, 2, 'Lock Install/Repair', 0, 0, 0, 1, 3600, NULL, '.4::.8::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 10, 3, 'Lock Install/Repair', 0, 0, 0, 1, 3600, NULL, '.4::.8::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 11, 4, 'Lock Install/Repair', 0, 0, 0, 1, 3600, NULL, '.4::.8::1', 0, 0 );

INSERT OR REPLACE INTO iBiz_services VALUES ( 12, 1, 'Lock Re-key', 0, 0, 0, 1, 3600, NULL, '1::0::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 13, 2, 'Lock Re-key', 0, 0, 0, 1, 3600, NULL, '1::0::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 14, 3, 'Lock Re-key', 0, 0, 0, 1, 3600, NULL, '1::0::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 15, 4, 'Lock Re-key', 0, 0, 0, 1, 3600, NULL, '1::0::0', 0, 0 );
--
COMMIT;
