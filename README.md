# plsqlToolbox
Various tricks and solution patterns in PLSQL

pkg_ext_table_debug is written in PL/SQL and is meant to help to troubleshoot the file of an external tables in an Oracle database. My personal strategy to load external table files is to define all columns as VARCHAR2(4000) so that it is resilient against almost all kinds of hiccup in the file data. Doing so most of the times will allow you to browse the column values with SQL and you do not have to examine the file with a text editor, which is no fun - believe me! Transformation to the table target layout (i.e field lengths and data types)  can be achieved with a view or other means. At many sites however people do carve the target table layout into external table definition. When hiccups do exist in the file, what then? The package provided here aims to facilitate the troubleshooting process by generating a "debugging" version of the original external table script: the column names and most the access parameters are preserved, only all columns are defined as VARCHAR2(4000). Execute this debugging version to create another external table and you can confortably spot where the problems are, of course with hints from the log file of the original external table. Make sure that you try to catch as many errors as possible in the troubleshooting process!

The function qwhat_is attempts to give a an in-depth picture of what is really behind an object name you find in a piece of SQL statement. Assuming we talk about a name which appears after the FROM clause. In the simplest case, it would be a table in the same schema where the SQL is supposed to be executed. But there many, many (almost infinitely) more possibilites:

1. A view
2. A synonym pointing to another view or table in the same schema 
3. A synonym pointing to another view or table in another schema 

qwhat_is currently goes as far as tackling the third case.

ToDo: if the name points to a view, the function should determine if the view is dependent on only one object and recursivle find out what that object is.

