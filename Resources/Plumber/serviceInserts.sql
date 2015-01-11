
-------------------------------------------------------------------------------------------------------------
--	PLUMBER
--
BEGIN;
-- Default Service Group
INSERT OR REPLACE INTO iBiz_group VALUES ( 1, 'Residential' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 2, 'Commercial' );
COMMIT;

BEGIN;
-- Columns from above for reference:
-- serviceID, groupID, serviceName, price, cost, taxable, isActive, duration, samplePhoto (NULL), color, isFlatRate, setupFee
INSERT OR REPLACE INTO iBiz_services VALUES ( 1, 1, 'Sewers & Drains', 0, 0, 0, 1, 3600, NULL, '1::.8::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 2, 1, 'Faucets & Sinks', 0, 0, 0, 1, 3600, NULL, '1::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 3, 1, 'Toilets', 0, 0, 0, 1, 3600, NULL, '.6::.4::.2', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 4, 1, 'Showers & Tubs', 0, 0, 0, 1, 3600, NULL, '1::0::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 5, 1, 'Water Lines/Pipes', 0, 0, 0, 1, 3600, NULL, '.78::.64::.78', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 6, 1, 'Sewer Line Replacement', 0, 0, 0, 1, 3600, NULL, '.5::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 7, 1, 'Disposals', 0, 0, 0, 1, 3600, NULL, '.4::.8::.1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 8, 1, 'Dishwashers', 0, 0, 0, 1, 3600, NULL, '0::1::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 9, 1, 'Water Heaters', 0, 0, 0, 1, 3600, NULL, '.5::.5::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 10, 1, 'Septic Tanks', 0, 0, 0, 1, 3600, NULL, '0::.25::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 11, 1, 'Sump Pump', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 12, 1, 'Camera Line Inspection', 0, 0, 0, 1, 3600, NULL, '.8::1::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 13, 1, 'Walkthrough Consultation', 0, 0, 0, 1, 3600, NULL, '.9::.9::.9', 0, 0 );
--
INSERT OR REPLACE INTO iBiz_services VALUES ( 14, 2, 'Emergency Services', 0, 0, 0, 1, 3600, NULL, '1::0::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 15, 2, 'Camera Line Inspection', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 16, 2, 'General Plumbing', 0, 0, 0, 1, 3600, NULL, '0::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 17, 2, 'Water Jetting', 0, 0, 0, 1, 3600, NULL, '1::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 18, 2, 'Leak Detection', 0, 0, 0, 1, 3600, NULL, '.5::1::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 19, 2, 'Backflow Protection', 0, 0, 0, 1, 3600, NULL, '.8::.8::.8', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 20, 2, 'Sewer Line Replacement', 0, 0, 0, 1, 3600, NULL, '.6::.6::.6', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 21, 2, 'Grease/Waste Pumping/Hauling', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
--
COMMIT;
