-- 以下脚本是Greenplum批量赋权脚本(内核PostgreSQL 9.0以前)
-- 在PostgreSQL 9.0之后，可以使用类似GRANT ALL ON ALL TABLES IN SCHEMA {schemaname} TO {username}完成批量赋权和回收权限功能。
create or replace function grant_on_all_tables(schema text, usr text) 
returns setof text as $$ 
declare 
   r record ; 
   revoke_schema text;
   grant_schema text;
   grant_table text; 
   revoke_table text;
begin 
	 revoke_table='revoke all on schema '||schema||' from ' || usr || ''; 
     EXECUTE revoke_table; 
     return next revoke_table; 

     grant_table = 'GRANT USAGE ON schema '|| schema ||' to ' || usr || ''; 
     EXECUTE grant_table; 
     return next grant_table; 

   for r in select * from pg_class c, pg_namespace nsp 
       where c.relnamespace = nsp.oid AND c.relkind='r' AND nspname = schema 
   loop 

     revoke_table='revoke all on TABLE '||schema||'.'|| quote_ident(r.relname) || ' from ' || usr || ''; 
     EXECUTE revoke_table; 
     return next revoke_table; 

     grant_table = 'GRANT SELECT ON TABLE '|| schema || '.' || quote_ident(r.relname) || ' to ' || usr || ''; 
     EXECUTE grant_table; 
     return next grant_table; 
   end loop; 
end; 
$$ language plpgsql; 
