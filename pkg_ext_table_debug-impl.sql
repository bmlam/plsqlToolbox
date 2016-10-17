create or replace package body pkg_ext_table_debug 
as
   /**
    * $Author:$
    * $Date:$
    * $Revision:$
    * $Id:$
    * $HeadURL:$
    */
	c_nl  constant varchar2(10) := chr(10);

	type access_param_record is record (
		parameter_name varchar2(100)
		,pattern varchar2(100)
	);
	
	type access_param_vector is table of access_param_record index by binary_integer;

	gc_param_baddir constant varchar2(100) 		:= upper('BADDIR');
	gc_param_badfile constant varchar2(100) 	:= upper('BADFILE');
	gc_param_charset constant varchar2(100) 	:= upper('CHARACTERSET');
	gc_param_flddelim constant varchar2(100) 	:= upper('FIELD DELIMITER');
	gc_param_logdir constant varchar2(100) 		:= upper('LOGDIR');
	gc_param_logfile constant varchar2(100) 	:= upper('LOGFILE');
	gc_param_optenclos constant varchar2(100) 	:= upper('OPTIONAL ENCLOSER');
	gc_param_recdelim constant varchar2(100) 	:= upper('RECORD DELIMITER');
	
	g_access_parameters access_param_vector;

function get_pattern ( p_parameter_name varchar2 )	
return varchar2
as
begin
	for i in 1 .. g_access_parameters.count loop
		if p_parameter_name = g_access_parameters(i).parameter_name then
			return g_access_parameters(i).pattern;
		end if;
	end loop;
end get_pattern;

procedure graceful_extract ( /* must be graceful because if the  pattern did not match, the complete input string is
	  returned and it is likely to be too big for the target variable
	*/
		p_input in out varchar2 /* in out due to performance consideration so we save a copy operation */
		, p_pattern varchar2
		, p_back_ref integer default 2 
		, p_target_var out varchar2 
	) as
		l_output long;
		l_input_len integer := length( p_input);
	begin
		l_output := regexp_replace( p_input, p_pattern, '\'||p_back_ref, 1, 1, 'i' );
		--dbms_output.put_line( 'Line '||$$plsql_line||': '||substr(l_output, 1, 90 )||'..' );
		--dbms_output.put_line( 'Line '||$$plsql_line||': input len'|| l_input_len);
		--dbms_output.put_line( 'Line '||$$plsql_line||': last 20 chars'||substr(p_input, l_input_len-20 ) );
		--dbms_output.put_line( 'Line '||$$plsql_line||': last char code '||ascii( substr( p_input, length(p_input), 1) ) );
		if length(l_output) < length(p_input) then /* match found */
			p_target_var := l_output;
		end if;
		
	end graceful_extract;
	
/****************************************************************************/	
function get_debug_table_ddl (
	p_origin_table varchar2
	,p_origin_owner varchar2 default user
	,p_column_witdh integer default 4000
	,p_use_optional_enclosure boolean default false
	,p_table_new    varchar2 default null
) return clob
/****************************************************************************/	
	as
		l_return clob;
		l_new_table varchar2(30);
		-- replaceables:
		l_char_set_str varchar2(30);
		l_log_dir varchar2(30);
		l_bad_dir varchar2(30);
		l_in_dir       varchar2(30);
		l_in_file     varchar2(1000);
		l_bad_file_str    varchar2(1000);
		l_log_file_str    varchar2(1000);
		l_record_delim_name   varchar2(30);
		l_field_delim_string   varchar2(30);
		l_optional_encloser_str varchar2(30);
		-- 
		l_access_parameters clob;
		l_access_parameters_new long;
		l_column_list long;
		l_clob_chunk long;
		l_clob_chunk_size integer;
		
	begin
		begin 
			select t.access_parameters 
				, l.directory_name
				, l.location
			into   l_access_parameters 
			       , l_in_dir
			       , l_in_file
			from all_external_tables  t
			join all_external_locations l
			on ( l.owner = t.owner and l.table_name = t.table_name)
			where t.owner = p_origin_owner
			  and t.table_name = p_origin_table
			  ;
		exception 
			when no_data_found then
				raise_application_error( -20001, 'External table not found in data dictionary!' );
		end get_clob;
		if dbms_Lob.getlength( l_access_parameters) > 32767 then
			raise_application_error(-20001, 'The retrieved access parameter CLOB is over 32k. This function currently does not support that!');
		end if;
		--
		l_new_table := case when p_table_new is null then 'TEST'||substr( p_origin_table, 1, 26) else substr(p_table_new ,1,30) end;
		--
		l_clob_chunk := replace ( dbms_lob.substr( l_access_parameters, 32767, 1 ), chr(10), ' ');
		l_clob_chunk_size := length ( l_clob_chunk );

		dbms_output.put_line( 'l_in_dir = '||l_in_dir); 
		dbms_output.put_line( 'l_in_file = '||l_in_file); 
		
		--
		graceful_extract ( l_clob_chunk, p_pattern => get_pattern(gc_param_charset), p_target_var => l_char_set_str);
		dbms_output.put_line( 'l_char_set_str = '||l_char_set_str); 
		--
		graceful_extract ( l_clob_chunk, p_pattern => get_pattern(gc_param_recdelim), p_target_var => l_record_delim_name);
		dbms_output.put_line( 'l_record_delim_name = '||l_record_delim_name); 
		--
		graceful_extract ( l_clob_chunk, p_pattern => get_pattern(gc_param_flddelim), p_target_var => l_field_delim_string );
		dbms_output.put_line( 'l_field_delim_string = '||l_field_delim_string); 
		--
		graceful_extract ( l_clob_chunk, p_pattern => get_pattern(gc_param_optenclos), p_target_var => l_optional_encloser_str );
		dbms_output.put_line( 'l_optional_encloser_str = '||l_optional_encloser_str); 
		--
		graceful_extract ( l_clob_chunk, p_pattern => get_pattern(gc_param_logdir)	, p_target_var => l_log_dir );
		dbms_output.put_line( 'l_log_dir = '||l_log_dir); 
		--
		graceful_extract ( l_clob_chunk, p_pattern => get_pattern(gc_param_logfile), p_target_var => l_log_file_str );
		l_log_file_str := substr(l_log_file_str, 1, 1) ||'DEBUG'||substr(l_log_file_str, 2); -- insert DEBUG into filename 
		dbms_output.put_line( 'l_log_file_str= '||l_log_file_str); 
		--
		graceful_extract ( l_clob_chunk, p_pattern => get_pattern(gc_param_baddir), p_target_var => l_bad_dir );
		dbms_output.put_line( 'l_bad_dir = '||l_bad_dir); 
		--
		graceful_extract ( l_clob_chunk, p_pattern => get_pattern(gc_param_badfile), p_target_var => l_bad_file_str );
		l_bad_file_str := substr(l_bad_file_str, 1, 1) ||'DEBUG'||substr(l_bad_file_str, 2); -- insert DEBUG into filename 
		dbms_output.put_line( 'l_bad_file_str= '||l_bad_file_str); 
		-- construct column list
		select listagg( column_name||' varchar2('||p_column_witdh||')', ','||c_nl )
			within group (order by column_id)
		into l_column_list
		from all_tab_columns  t
		where t.owner = p_origin_owner
		  and t.table_name = p_origin_table
		;
		-- construct access parameters
		l_access_parameters_new := 
			'Records delimited by '||l_record_delim_name||c_Nl
			||'characterset '||l_char_set_str ||c_nl
			||'badfile '||case when l_bad_dir is not null then l_bad_dir||':' end ||l_bad_file_str ||c_nl
			||'logfile '||case when l_log_dir is not null then l_log_dir||':' end ||l_log_file_str ||c_nl
			||'fields terminated by '||l_field_delim_string
			||  case when l_optional_encloser_str is not null and p_use_optional_enclosure then ' optionally enclosed by ' || l_optional_encloser_str end||c_nl
			||' missing field values are null'||c_nl
		;
		--
		l_return := 'create table '||l_new_table||c_nl
			||'('||c_nl||l_column_list
			||')'||c_nl
			||'ORGANIZATION EXTERNAL ('||c_nl
			||'   TYPE oracle_loader'||c_nl
			||' DEFAULT DIRECTORY '||l_in_dir||c_nl
			||' ACCESS PARAMETERS ('||c_nl
			||  l_access_parameters_new
			||')'/*close ACCESS PARAMETERS */||c_nl
			||' LOCATION ( '||l_in_dir||': '''|| l_in_file||''' )'||c_nl
			||')'/*close ORGANIZATION EXTERNAL */||c_nl
			||'reject limit 0'
			||';'
			;
		return l_return;
	end get_debug_table_ddl;
	
/****************************************************************************/	
function get_access_parameter (
	p_parameter_name varchar2
	,p_table varchar2
	,p_owner varchar2 default user
) return varchar2
/****************************************************************************/	
as
	lc_trunc_name_after_pos constant integer := 30;
	l_return long;
	l_clob_chunk long;
	l_pattern varchar2(1000);
	l_access_parameters clob;
	l_found integer;
begin	
	begin 
		select t.access_parameters 
		into   l_access_parameters 
		from all_external_tables  t
		where t.owner = p_owner
		  and t.table_name = p_table
		  ;
	exception 
		when no_data_found then
			raise_application_error( -20001, 'External table not found in data dictionary!' );
	end get_clob;
	if dbms_Lob.getlength( l_access_parameters) > 32767 then
		raise_application_error(-20001, 'The retrieved access parameter CLOB is over 32k. This function currently does not support that!');
	end if;
	l_clob_chunk := replace ( dbms_lob.substr( l_access_parameters, 32767, 1 ), chr(10), ' ');
	--
	for i in 1 .. g_access_parameters.count loop
		if upper( p_parameter_name ) = g_access_parameters(i).parameter_name then
			l_found := i;
			exit;
		end if;
	end loop; 
	if l_found is null then
		raise_application_error(-20001, 'The parameter name ' || substr(p_parameter_name, 1, lc_trunc_name_after_pos)
				||' is not supported by this function. Note that properties like DEFAULT_DIRECTORY_NAME, REJECT_LIMIT, LOCATION (input file) can be extracted directly from data dictionary.');
	else 
		l_pattern := g_access_parameters(l_found).pattern;
		dbms_output.put_line ( 'Line '||$$plsql_line||' l_pattern: '||l_pattern);
	end if;
	graceful_extract ( p_input => l_clob_chunk, p_pattern => l_pattern, p_target_var => l_return );
	return l_return;
end get_access_parameter;
	
/****************************************************************************/	
function queryable_parameters return varchar2
/****************************************************************************/	
as
	l_return long;
begin	
	for i in 1 .. g_access_parameters.count loop
		l_return := 
			case when i = 1 then 'Currently the following parameters can be queried:' else l_return end
			||chr(10)||' '||g_access_parameters(i).parameter_name
		;
	end loop; 
	return l_return;
end queryable_parameters;
	
begin 
	declare l_rec access_param_record;
	begin
		l_rec.parameter_name := gc_param_baddir; 	l_rec.pattern := '(^.*badfile\s+)([[:alnum:]_]+)(.*$)' ; 							g_access_parameters( g_access_parameters.count + 1) := l_rec;
		l_rec.parameter_name := gc_param_badfile; 	l_rec.pattern := '(^.*badfile\s+[[:alnum:]_]+\s?:\s?)(''[[:alnum:]_]+\.[[:alnum:]_]+'')(.*$)' ; g_access_parameters( g_access_parameters.count + 1) := l_rec;
		l_rec.parameter_name := gc_param_charset; 	l_rec.pattern := '(^.*\s+characterset\s+)(''[[:alnum:]_]+'')(.*$)'/*non-greedy*/; 	g_access_parameters( g_access_parameters.count + 1) := l_rec;
		l_rec.parameter_name := gc_param_flddelim; 	l_rec.pattern := '(^.*fields\s+terminated\s+by\s+)([''""].+?[''""])(.*$)'; 			g_access_parameters( g_access_parameters.count + 1) := l_rec;
		l_rec.parameter_name := gc_param_logdir; 	l_rec.pattern := '(^.*logfile\s+)([[:alnum:]_]+)(.*$)'; 							g_access_parameters( g_access_parameters.count + 1) := l_rec;
		l_rec.parameter_name := gc_param_logfile; 	l_rec.pattern := '(^.*logfile\s+[[:alnum:]_]+\s?:\s?)(''[[:alnum:]_]+\.[[:alnum:]_]+'')(.*$)' ;	g_access_parameters( g_access_parameters.count + 1) := l_rec;
		l_rec.parameter_name := gc_param_optenclos; l_rec.pattern := '(^.*optionally\s+enclosed\s+by\s+)([''""].+?[''""])(.*$)'; 		g_access_parameters( g_access_parameters.count + 1) := l_rec;
		l_rec.parameter_name := gc_param_recdelim; 	l_rec.pattern := '(^.*records\s+delimited\s+by\s+)([a-z]+)(.*$)'; 					g_access_parameters( g_access_parameters.count + 1) := l_rec;
	end;
end;
/


show errors