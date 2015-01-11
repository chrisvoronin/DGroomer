
-------------------------------------------------------------------------------------------------------------
--	CONTRACTOR
--
BEGIN;
-- Default Service Group
INSERT OR REPLACE INTO iBiz_group VALUES ( 2, 'Residential' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 1, 'Commercial' );
INSERT OR REPLACE INTO iBiz_group VALUES ( 3, 'Other' );
COMMIT;

BEGIN;
-- Columns from above for reference:
-- serviceID, groupID, serviceName, price, cost, taxable, isActive, duration, samplePhoto (NULL), color, isFlatRate, setupFee
INSERT OR REPLACE INTO iBiz_services VALUES ( 1, 1, 'Air Conditioning', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 2, 1, 'Appliance Install & Repair', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 4, 1, 'Bathroom Remodeling', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 5, 1, 'Cabinets', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 6, 1, 'Carpentry', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 7, 1, 'Cleaning', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 8, 1, 'Closets & Storage', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 9, 1, 'Concrete', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 13, 1, 'Demolition & Disposal', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 14, 1, 'Doors', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 15, 1, 'Drywall & Plastering', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 16, 1, 'Electrical', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 17, 1, 'Excavation', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 18, 1, 'Fans & Ventilation', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 19, 1, 'Fencing', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 20, 1, 'Fireplace', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 21, 1, 'Flooring', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 22, 1, 'Foundations', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 23, 1, 'Framing Systems', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 24, 1, 'Garages & Outbuildings', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 25, 1, 'Glass & Screens', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 26, 1, 'Gutters', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 27, 1, 'Heating', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 29, 1, 'Insulation', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 31, 1, 'Masonry & Stucco', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 32, 1, 'Mold Remediation', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 33, 1, 'Painting & Wallcovering', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 34, 1, 'Paving', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 35, 1, 'Plumbing', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 36, 1, 'Room Additions', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 37, 1, 'Roofing', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 38, 1, 'Siding', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 40, 1, 'Tile & Stone', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 41, 1, 'Waterproofing', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 42, 1, 'Windows', 0, 0, 0, 1, 3600, NULL, '0::0::1', 0, 0 );

INSERT OR REPLACE INTO iBiz_services VALUES ( 43, 2, 'Air Conditioning', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 44, 2, 'Appliance Install & Repair', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 45, 2, 'Basements', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 46, 2, 'Bathroom Remodeling', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 47, 2, 'Cabinets', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 48, 2, 'Carpentry', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 49, 2, 'Cleaning', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 50, 2, 'Closets & Storage', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 51, 2, 'Concrete', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 52, 2, 'Countertops', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 53, 2, 'Custom Home Building', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 54, 2, 'Decks', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 55, 2, 'Demolition & Disposal', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 56, 2, 'Doors', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 57, 2, 'Drywall & Plastering', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 58, 2, 'Electrical', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 59, 2, 'Excavation', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 60, 2, 'Fans & Ventilation', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 61, 2, 'Fencing', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 62, 2, 'Fireplace', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 63, 2, 'Flooring', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 64, 2, 'Foundations', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 65, 2, 'Framing Systems', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 66, 2, 'Garages & Outbuildings', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 67, 2, 'Glass & Screens', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 68, 2, 'Gutters', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 69, 2, 'Heating', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 70, 2, 'Hot Tubs', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 71, 2, 'Insulation', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 72, 2, 'Kitchen Remodeling', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 73, 2, 'Masonry & Stucco', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 74, 2, 'Mold Remediation', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 75, 2, 'Painting & Wallcovering', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 76, 2, 'Paving', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 77, 2, 'Plumbing', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 78, 2, 'Room Additions', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 79, 2, 'Roofing', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 80, 2, 'Siding', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 81, 2, 'Sunroom', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 82, 2, 'Tile & Stone', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 83, 2, 'Waterproofing', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
INSERT OR REPLACE INTO iBiz_services VALUES ( 84, 2, 'Windows', 0, 0, 0, 1, 3600, NULL, '0::0::.5', 0, 0 );
--
COMMIT;








