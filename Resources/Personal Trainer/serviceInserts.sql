
-------------------------------------------------------------------------------------------------------------
--	PERSONAL TRAINER
--
BEGIN;
-- Default Service Group
INSERT OR REPLACE INTO iBiz_group VALUES ( 1, 'Consulting' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 2, 'Training' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 3, 'Custom Services' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 4, 'Classes' );
--
COMMIT;

BEGIN;
-- Columns from above for reference:
-- serviceID, groupID, serviceName, price, cost, taxable, isActive, duration, samplePhoto (NULL), color, isFlatRate, setupFee
INSERT OR REPLACE INTO iBiz_services VALUES ( 1, 1, 'Fitness Consultation', 0, 0, 0, 1, 1800, NULL, '1::0::0', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 2, 1, 'Fitness Assessment', 0, 0, 0, 1, 1800, NULL, '1::1::0', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 3, 1, 'Nutritional Evaluation', 0, 0, 0, 1, 1800, NULL, '1::.8::.4', 1, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 4, 2, 'Strength Training', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 5, 2, 'Aerobic Training', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 6, 2, 'Sport Training', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 10, 2, 'Rehabilitation', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 11, 2, 'In-home Training', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 7, 3, '30 Minute Custom', 0, 0, 0, 1, 1800, NULL, '0::0::.5', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 8, 3, '45 Minute Custom', 0, 0, 0, 1, 2700, NULL, '0::0::.5', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 9, 3, '60 Minute Custom', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 1, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 12, 4, 'Zumba', 0, 0, 0, 1, 3600, NULL, '1::.67::.81', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 13, 4, 'Yoga', 0, 0, 0, 1, 3600, NULL, '.78::.64::.78', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 14, 4, 'Step', 0, 0, 0, 1, 3600, NULL, '.5::0::.5', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 15, 4, 'Spin', 0, 0, 0, 1, 3600, NULL, '1::1::0', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 16, 4, 'Kickboxing', 0, 0, 0, 1, 3600, NULL, '0::0::1', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 17, 4, 'Pilates', 0, 0, 0, 1, 3600, NULL, '.9::.9::.9', 1, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 18, 4, 'Dance', 0, 0, 0, 1, 3600, NULL, '.6::.6::.6', 1, 0 );
--
COMMIT;









