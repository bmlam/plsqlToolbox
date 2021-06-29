CREATE OR REPLACE FUNCTION get_text_file_content
( i_dir_name VARCHAR2
 ,i_file_name VARCHAR2
) RETURN CLOB
AS
	l_bfile BFile;
	l_file_text CLOB;
	l_dest_offset   INTEGER;
  	l_src_offset    INTEGER;
  	l_bfile_csid    NUMBER  := 0;
  	l_lang_context  INTEGER := 0;
  	l_warning       INTEGER := 0;
  	l_ins_cnt INTEGER := 0;
  	l_fileIsOpen BOOLEAN;
BEGIN 
	dbms_lob.createtemporary( l_file_text, TRUE);
	l_dest_offset := 1;
	l_src_offset  := 1;

	l_bfile := BFileName( i_dir_name, i_file_name );
	DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);
	l_fileIsOpen := TRUE;
	dbms_lob.loadClobFromFile
	( dest_lob => l_file_text
	, src_bfile => l_bfile
	, amount        => DBMS_LOB.lobmaxsize
	, dest_offset   => l_dest_offset
	, src_offset    => l_src_offset
	, bfile_csid    => l_bfile_csid 
	, lang_context  => l_lang_context
	, warning       => l_warning
	); 
	DBMS_LOB.fileclose(l_bfile);

	RETURN l_file_text;
END;
/
show errors
