# plsqlToolbox
Various tricks and solution patterns in PLSQL

pkg_ext_table_debug: can save your day when trying to debug an external table, e.g. the text file simply won't load into the the table due to data type or field length issue.

qwhat_is tells what is actually behind an object name you see in a piece of SQL code. Return value is CLOB

google is a pl/sql function that returns the database objects in your schema which name matches a search pattern specified. Return value is CLOB. The name is chosen in honour of the famous internet search engine :-) and because it is so self-explanatory 
