--configure smtp mailing
--
--
-- view existing network ACLs:
column acl format a30
column host format a20
column principal format a20
column privilege format a10
column is_grant format a8
set lines 120 pages 80

select acl , host , lower_port , upper_port from DBA_NETWORK_ACLS;

-- if necessary, drop ACLs:
begin
  DBMS_NETWORK_ACL_ADMIN.DROP_ACL(c_acl);
end;
/


-- create network ACLs part 1:
DECLARE 
  c_acl CONSTANT VARCHAR2(100) := 'OFFICE365_ACL';
BEGIN
   DBMS_NETWORK_ACL_ADMIN.CREATE_ACL (
    acl          => c_acl,
    description  => 'Permissions to access SMTP Server',
    principal    => 'IMEXTADMIN',
    is_grant     => TRUE,
    privilege    => 'connect');

  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (
    acl          => c_acl,
    principal    => 'IMEXTADMIN',
    is_grant     => TRUE, 
    privilege    => 'resolve',
    position     => null);

  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL (
    acl          => c_acl,
    host         => 'smtp.generic.com',
    lower_port    => 1,
    upper_port    => 1024);
   COMMIT;
END;
/

-- create network ACLs part 2:
DECLARE 
  c_acl CONSTANT VARCHAR2(100) := 'GENERIC_ACL';
BEGIN
   DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE (
    acl          => c_acl,
    principal    => 'IMEXTADMIN',
    is_grant     => TRUE, 
    privilege    => 'use-client-certificates');

  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(
    acl          => c_acl,
    principal   => 'IMEXTADMIN',
    is_grant    => TRUE,
    privilege   => 'use-passwords');
  COMMIT;
END;
/


