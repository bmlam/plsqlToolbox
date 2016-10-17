create or replace package pkg_ext_table_debug 
authid current_user
as
   /**
    * $Author:$
    * $Date:$
    * $Revision:$
    * $Id:$
    * $HeadURL: $
    */
	function get_debug_table_ddl (
		p_origin_table varchar2
		,p_origin_owner varchar2 default user
		,p_column_witdh integer default 4000
		,p_use_optional_enclosure boolean default false
		,p_table_new    varchar2 default null
	) return clob
	;
	function get_access_parameter (
		p_parameter_name varchar2
		,p_table varchar2
		,p_owner varchar2 default user
	) return varchar2
	;
	function queryable_parameters return varchar2
	;
end;
/

show errors