
-------------------------------------------------------------------------------------------------------------
--	LANDSCAPING
--
BEGIN;
-- Default Service Group
INSERT OR REPLACE INTO iBiz_group VALUES ( 1, 'Fountains & Waterfalls' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 2, 'Landscaping' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 3, 'Lawn Maintenance' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 4, 'Tree & Bushes' );
--
COMMIT;

BEGIN;
-- Columns from above for reference:
-- serviceID, groupID, serviceName, price, cost, taxable, isActive, duration, samplePhoto (NULL), color, isFlatRate, setupFee
INSERT OR REPLACE INTO iBiz_services VALUES ( 1, 1, 'Fountain Installation', 0, 0, 0, 1, 3600, NULL, '.8::1::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 2, 1, 'Waterfall Installation', 0, 0, 0, 1, 3600, NULL, '.8::1::.4', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 3, 2, 'Flower & Bulb Planting', 0, 0, 0, 1, 3600, NULL, '.5::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 4, 2, 'Irrigation', 0, 0, 0, 1, 3600, NULL, '.5::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 5, 2, 'Landscape Renovation', 0, 0, 0, 1, 3600, NULL, '.5::1::0', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 6, 3, 'Lawn Fertilization & Weed Control', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 7, 3, 'Mowing', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 8, 3, 'Seeding & Lawn Renovation', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 9, 4, 'Cabling & Bracing', 0, 0, 0, 1, 3600, NULL, '0::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 10, 4, 'Insect & Disease Mgmt', 0, 0, 0, 1, 3600, NULL, '0::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 11, 4, 'Tree & Shrub Fertilization', 0, 0, 0, 1, 3600, NULL, '0::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 12, 4, 'Tree & Shrub Planting', 0, 0, 0, 1, 3600, NULL, '0::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 13, 4, 'Tree Pruning Large', 0, 0, 0, 1, 3600, NULL, '0::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 14, 4, 'Tree Pruning Medium', 0, 0, 0, 1, 3600, NULL, '0::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 15, 4, 'Tree Pruning Small', 0, 0, 0, 1, 3600, NULL, '0::.5::0', 0, 0 );
--
COMMIT;
