To recreate the databases for iBiz (FROM SCRATCH) you need to do the following:

1. Open a terminal window

2. I'm hiding the databases as PNG files so they're not as easily findable to people browsing the .app file
    cd "/Users/salontech/PSA Development/iBiz/Images"

3. Open the dynamic user data database
    sqlite3 btnRegisterBackground.png
4. Load the current schema into the new database
    .read ../sqlDynamicUserData.sql
5. Close this database
	.exit
	
6. Open the credit card tables database
	sqlite3 btnMenuBackground.png
7. Load the table structure and target color inserts
    .read ../sqlTablesForVersion2.sql
8. Close
    .exit

9. Make sure that XCode sees these databases as "File Type: file" (not image.png), check this in "Get Info" for the files.
