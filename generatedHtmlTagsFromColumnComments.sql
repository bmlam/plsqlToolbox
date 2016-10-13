-- generated a td element with the columns COLUMN_NAME, DATA_TYPE, NULLABLE, COMMENTS

with magic as ( 
  select '<td>' as startt
  , '</td>'||chr(10) as endt 
  from dual
)
select '<tr>'
||m.startt||tc.column_name||m.endt
||m.startt||data_type||m.endt
||m.startt||nullable||m.endt
||m.startt||comments||m.endt
||'</tr>'
as htm
from user_tab_columns tc
join user_col_comments cc
on ( tc.table_name = cc.table_name 
  and tc.column_name = cc.column_name
  )
cross join magic  m
where 1=1  
  and tc.table_name = 'EMPLOYEE'
  order by tc.column_id
  ;