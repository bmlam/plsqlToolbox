set serverout on
DECLARE
  v_input_code VARCHAR2(32000) := 
  q'[
 --
var local__kn_kra_akte NUMBER  
var local__kn_kra_aktenhuelse NUMBER 
var vbs_catalog__false_value VARCHAR2(100) 
var vbs_catalog__true_value VARCHAR2(100) 
var vbs_catalog__vorgang_status__bearbeitet VARCHAR2(100) 
var vbs_catalog__vorgang_status__erledigt VARCHAR2(100) 
var vbs_catalog__vorgang_status__erstellt VARCHAR2(100) 
var vbs_catalog__vorgang_status__fehlgeschlagen VARCHAR2(100) 
var vbs_catalog__vorgang_status__geloescht VARCHAR2(100) 
var vbs_catalog__vorgang_status__gesendet VARCHAR2(100) 
var vbs_catalog__vorgang_status__neu VARCHAR2(100) 
var vbs_catalog__vorgang_status__zugeordnet VARCHAR2(100) 
var vbs_catalog__zuweisungsart__absender VARCHAR2(100) 
var vbs_catalog__zuweisungsart__ausgang VARCHAR2(100) 
var vbs_catalog__zuweisungsart__eingang VARCHAR2(100) 
var vbs_catalog__zuweisungsart__empfaenger VARCHAR2(100) 
var vbs_catalog__zuweisungsart__mitzeichner VARCHAR2(100) 
var vbs_datenkonsistenzkontrolle__kc_timestamp_format VARCHAR2(100)
var vbs_domain__entity__auftrag   VARCHAR2(100) 
var vbs_domain__entity__container VARCHAR2(100) 
var vbs_domain__entity__dokument  VARCHAR2(100) 
var vbs_domain__entity__fahndung  VARCHAR2(100) 
var vbs_domain__entity__geld      VARCHAR2(100) 
var vbs_domain__entity__industrielle_ausruestungen VARCHAR2(100) 
var vbs_domain__entity__institution VARCHAR2(100) 
var vbs_domain__entity__konto        VARCHAR2(100) 
var vbs_domain__entity__kriminalakte VARCHAR2(100) 
var vbs_domain__entity__kraftfahrzeug VARCHAR2(100) 
var vbs_domain__entity__luftfahrzeug VARCHAR2(100) 
var vbs_domain__entity__nachricht VARCHAR2(100) 
var vbs_domain__entity__objekt   VARCHAR2(100) 
var vbs_domain__entity__person     VARCHAR2(100) 
var vbs_domain__entity__personalie VARCHAR2(100) 
var vbs_domain__entity__sache      VARCHAR2(100) 
var vbs_domain__entity__sonstige_sache      VARCHAR2(100) 
var vbs_domain__entity__telekommunikation      VARCHAR2(100) 
var vbs_domain__entity__urkunde VARCHAR2(100) 
var vbs_domain__entity__vorgang VARCHAR2(100) 
var vbs_domain__entity__vorgangsdaten VARCHAR2(100) 
var vbs_domain__entity__waffe         VARCHAR2(100) 
var vbs_domain__entity__wasserfahrzeug VARCHAR2(100) 
var vbs_domain__entity__zahlungskarte VARCHAR2(100) 
--
VAR lpr_gzw_denormalisiert__kn_kriminalakte_vgd_id NUMBER 
VAR lpr_gzw_denormalisiert__kn_ber_id_ffsb NUMBER 
VAR lpr_gzw_denormalisiert__kn_ber_id_sb NUMBER 
--
BEGIN   
  :local__kn_kra_akte:= -465; 
  :local__kn_kra_aktenhuelse:= -464; 
  :vbs_catalog__false_value:= '0'; 
  :vbs_catalog__true_value:=  '1'; 
  -- 
  :vbs_catalog__vorgang_status__bearbeitet:= 'BEA'; 
  :vbs_catalog__vorgang_status__erledigt:= 'ERL'; 
  :vbs_catalog__vorgang_status__erstellt:= 'ERS'; 
  :vbs_catalog__vorgang_status__fehlgeschlagen:= 'ERR'; 
  :vbs_catalog__vorgang_status__geloescht:= 'LOE'; 
  :vbs_catalog__vorgang_status__gesendet:= 'SEN'; 
  :vbs_catalog__vorgang_status__neu:= 'NEU'; 
  :vbs_catalog__vorgang_status__zugeordnet:= 'ZURG'; 
  --
  :vbs_catalog__zuweisungsart__empfaenger:= 'EMP'; 
  :vbs_catalog__zuweisungsart__absender:= 'ABS'; 
  :vbs_catalog__zuweisungsart__ausgang:= 'AUS'; 
  :vbs_catalog__zuweisungsart__eingang:= 'EIN'; 
  :vbs_catalog__zuweisungsart__mitzeichner:= 'MIT'; 
  -- 
  :vbs_datenkonsistenzkontrolle__kc_timestamp_format :=  'DD.MM.YYYY HH24:MI:SS.FF';
  -- 
  :vbs_domain__entity__auftrag    := 'ATR'; 
  :vbs_domain__entity__container    := 'CTR'; 
  :vbs_domain__entity__dokument    := 'DOK'; 
  :vbs_domain__entity__geld        := 'GLD'; 
  :vbs_domain__entity__industrielle_ausruestungen        := 'INA'; 
  :vbs_domain__entity__fahndung    := 'FHD'; 
  :vbs_domain__entity__institution := 'INS'; 
  :vbs_domain__entity__konto       := 'KON'; 
  :vbs_domain__entity__kraftfahrzeug := 'KFZ'; 
  :vbs_domain__entity__kriminalakte:= 'KRA'; 
  :vbs_domain__entity__luftfahrzeug:= 'LFZ'; 
  :vbs_domain__entity__nachricht := 'NAR'; 
  :vbs_domain__entity__objekt:= 'OBJ'; 
  :vbs_domain__entity__person    := 'PRS'; 
  :vbs_domain__entity__personalie:= 'PSN'; 
  :vbs_domain__entity__sache     := 'SAC'; 
  :vbs_domain__entity__sonstige_sache    := 'SAC'; 
  :vbs_domain__entity__telekommunikation := 'TKM'; 
  :vbs_domain__entity__urkunde    := 'URK'; 
  :vbs_domain__entity__vorgang:= 'VRG'; 
  :vbs_domain__entity__vorgangsdaten:= 'VGD'; 
  :vbs_domain__entity__waffe    := 'WFZ'; 
  :vbs_domain__entity__wasserfahrzeug   := 'WAF'; 
  :vbs_domain__entity__zahlungskarte:= 'ZLK'; 
  -- 
  :lpr_gzw_denormalisiert__kn_kriminalakte_vgd_id :=  -23; 
  :lpr_gzw_denormalisiert__kn_ber_id_ffsb :=  -52;
  :lpr_gzw_denormalisiert__kn_ber_id_sb :=  -51;
END;
  ]'
  ; -- Replace with your PL/SQL code
TYPE identifier_table_type
IS
  TABLE OF iNTEGER INDEX BY VARCHAR2(100);
  v_identifiers identifier_table_type;
  v_identifier VARCHAR2(100);
BEGIN
  -- Remove unwanted characters from the input code
  v_input_code := REGEXP_REPLACE(v_input_code, '[[:punct:]&&[^_] ]+', ' ');
  v_input_code := REPLACE(v_input_code,chr(10), ' ');
  --dbms_output.put_line ( 'Ln'||$$plsql_line||' v_input_code len: ' ||length(v_input_code) ||' first 100 chars: ' ||substr( v_input_code, 1, 100) );
  --dbms_output.put_line ( 'Ln'||$$plsql_line||' xx: ' ||xx );
  -- Split the input code into tokens based on spaces
  FOR i IN 1..LENGTH(v_input_code)
  LOOP
    IF (SUBSTR(v_input_code, i, 1) = ' ') THEN
      --dbms_output.put_line ( 'Ln'||$$plsql_line||' v_identifier: ' ||v_identifier );
      IF substr(v_identifier, 1, 1 ) = ':' THEN -- special handing for bind variarables
        v_identifier := substr( v_identifier, 2 );
      END IF;
      IF substr(v_identifier, -2 ) = ':=' THEN -- special handing for assignment operator 
        v_identifier := substr( v_identifier, 1, length( v_identifier) -2  );
      END IF;
      IF (v_identifier            IS NOT NULL) THEN
        -- Check if the identifier already exists in the collection
        IF v_identifiers.EXISTS(v_identifier) THEN
      ----dbms_output.put_line ( 'Ln'||$$plsql_line||' v_identifier: ' ||v_identifier );
          -- If identifier exists, increment its count
          v_identifiers(v_identifier) := v_identifiers(v_identifier) + 1;
        ELSE
      --dbms_output.put_line ( 'Ln'||$$plsql_line||' v_identifier: ' ||v_identifier );
          -- If identifier doesn't exist, initialize its count
          v_identifiers(v_identifier) := 1;
        END IF;
      END IF;
      v_identifier := NULL;
    ELSE
      --dbms_output.put_line ( 'Ln'||$$plsql_line||' v_identifier: ' ||v_identifier );
      -- Build the identifier character by character
      v_identifier := v_identifier||SUBSTR(v_input_code, i, 1);
    END IF;
  END LOOP;
  -- Print the identifiers and their occurrence counts
  v_identifier := v_identifiers.first;
  WHILE v_identifier IS NOT NULL 
  LOOP
      --dbms_output.put_line ( 'Ln'||$$plsql_line||' v_identifier: ' ||v_identifier );
    DBMS_OUTPUT.PUT_LINE( rpad( 'Identifier: ' || v_identifier , 100, ' ') || ' Count: ' || v_identifiers( v_identifier ) );
    v_identifier := v_identifiers.next( v_identifier );
  END LOOP;
END;
/
