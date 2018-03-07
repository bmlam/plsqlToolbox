# plsqlToolbox
Various tricks and solution patterns in PLSQL

pkg_ext_table_debug: can save your day when trying to debug an external table, e.g. the text file simply won't load into the the table due to data type or field length issue.

qwhat_is tells what is actually behind an object name you see in a piece of SQL code. Return value is CLOB

google is a pl/sql function that returns the database objects in your schema which name matches a search pattern specified. Return value is CLOB. The name is chosen in honour of the famous internet search engine :-) and because it is so self-explanatory 

pkg_ext_table_debug is a PLSQL package which has proved to be very helpful to debug external tables. Suppose an external table has been defined to have date and number type columns which require that the backing file content to adhere strictly to the field specification. But very often or at least during launch phase this is not so and many records cannot be loaded. Common reasons for load errors may be unexpected characters for a number field, bad value for a date field etc. The traditional way to debug is looking up the bad and log files but this is a really tedious process. You have to log onto the server, locate the files and pull them up. It is much _easier_ to create a more fault-tolerant version of the external table so that you can load all the records from the file into the table and find out what is wrong in the fields. The main function is this package does exactly that: it generates a DDL script for such an external table.
