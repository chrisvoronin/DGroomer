
-------------------------------------------------------------------------------------------------------------
--	MASSAGE
--
BEGIN;
-- Default Service Group
INSERT OR REPLACE INTO iBiz_group VALUES ( 1, 'Massages' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 2, 'Other' );

COMMIT;

BEGIN;
-- Columns from above for reference:
-- serviceID, groupID, serviceName, price, cost, taxable, isActive, duration, samplePhoto (NULL), color, isFlatRate, setupFee
INSERT OR REPLACE INTO iBiz_services VALUES ( 1, 1, 'Relaxation Massage', 0, 0, 0, 1, 3600, NULL, '1::.67::.81', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 2, 1, 'Deep Tissue Massage', 0, 0, 0, 1, 3600, NULL, '.4::.8::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 3, 1, 'Stress Massage', 0, 0, 0, 1, 3600, NULL, '1::.8::.4', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 4, 1, 'Swedish Massage', 0, 0, 0, 1, 3600, NULL, '1::.5::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 5, 1, 'Aromatherapy Massage', 0, 0, 0, 1, 3600, NULL, '1::.44::.81', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 6, 1, 'Hot Stone Massage', 0, 0, 0, 1, 3600, NULL, '1::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 9, 1, 'Pregnancy Massage', 0, 0, 0, 1, 3600, NULL, '1::0::0', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 10, 1, 'Foot Massage', 0, 0, 0, 1, 3600, NULL, '.5::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 11, 1, 'Shiatsu Massage', 0, 0, 0, 1, 3600, NULL, '0::1::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 12, 1, 'Reiki Massage', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 13, 1, 'Chair Massage', 0, 0, 0, 1, 3600, NULL, '.78::.64::.78', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 14, 1, 'Lomi Lomi Massage', 0, 0, 0, 1, 3600, NULL, '0::1::0', 0, 0 );

INSERT OR REPLACE INTO iBiz_services VALUES ( 7, 3, 'Neuromuscular Therapy', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 8, 3, 'Reflexology', 0, 0, 0, 1, 3600, NULL, '1::1::0', 0, 0 );

--
COMMIT;
