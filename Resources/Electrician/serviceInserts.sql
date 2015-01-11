
-------------------------------------------------------------------------------------------------------------
--	ELECTRICIAN
--
BEGIN;
-- Default Service Group
INSERT OR REPLACE INTO iBiz_group VALUES ( 1, 'Residential' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 2, 'Commercial' );
--
COMMIT;

BEGIN;
-- Columns from above for reference:
-- serviceID, groupID, serviceName, price, cost, taxable, isActive, duration, samplePhoto (NULL), color, isFlatRate, setupFee
INSERT OR REPLACE INTO iBiz_services VALUES ( 1, 1, 'Service Upgrades', 0, 0, 0, 1, 3600, NULL, '1::.8::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 2, 1, 'Whole House Surge Protection', 0, 0, 0, 1, 3600, NULL, '1::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 3, 1, 'Lightning Strikes', 0, 0, 0, 1, 3600, NULL, '.6::.4::.2', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 4, 1, 'Hot Tubs', 0, 0, 0, 1, 3600, NULL, '1::.67::.81', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 5, 1, 'Light Fixtures', 0, 0, 0, 1, 3600, NULL, '1::.44::.81', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 6, 1, 'Switch Repair', 0, 0, 0, 1, 3600, NULL, '1::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 7, 1, 'Outlets', 0, 0, 0, 1, 3600, NULL, '1::0::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 8, 1, 'Outdoor Lighting', 0, 0, 0, 1, 3600, NULL, '.78::.64::.78', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 9, 1, 'Appliance Installation', 0, 0, 0, 1, 3600, NULL, '.5::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 10, 1, 'Low Voltage', 0, 0, 0, 1, 3600, NULL, '.4::.8::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 11, 1, 'Basement Wiring', 0, 0, 0, 1, 3600, NULL, '0::1::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 12, 1, 'Add Circuits', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 13, 1, 'Stove/Oven Wiring', 0, 0, 0, 1, 3600, NULL, '0::.25::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 14, 1, 'Aluminum Wiring', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 15, 1, 'Electric Meters', 0, 0, 0, 1, 3600, NULL, '.8::1::.4', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 16, 2, 'Service Upgrades', 0, 0, 0, 1, 3600, NULL, '.5::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 17, 2, 'Building Surge Protection', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 18, 2, 'Lightning Strikes', 0, 0, 0, 1, 3600, NULL, '0::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 19, 2, 'Light Fixtures', 0, 0, 0, 1, 3600, NULL, '1::1::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 20, 2, 'Switch Repair', 0, 0, 0, 1, 3600, NULL, '1::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 21, 2, 'Outlets', 0, 0, 0, 1, 3600, NULL, '.5::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 22, 2, 'Outdoor Lighting', 0, 0, 0, 1, 3600, NULL, '.9::.9::.9', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 23, 2, 'Low Voltage', 0, 0, 0, 1, 3600, NULL, '.8::.8::.8', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 24, 2, 'Add Circuits', 0, 0, 0, 1, 3600, NULL, '.7::.7::.7', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 25, 2, 'Aluminum Wiring', 0, 0, 0, 1, 3600, NULL, '.6::.6::.6', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 26, 2, 'Electric Meters', 0, 0, 0, 1, 3600, NULL, '0::0::0', 0, 0 );
--
COMMIT;
