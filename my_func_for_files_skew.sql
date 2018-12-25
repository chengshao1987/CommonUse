CREATE OR REPLACE FUNCTION my_func_for_files_skew()

--如果大家对Greenplum数据库熟悉的话，就会发现上面工具的一个问题，即表膨胀。
--当我们对表执行DML操作时，对于删除的空间并没有立马释放给操作系统，所以我们的计算结果可能会包含这部分大小。
--个人建议在执行这个查看表文件倾斜之前，对需要统计的表进行Vacuum回收空间，或使用CTAS方式进行表重建。
--另外补充一点，如果你想对单个表进行统计倾斜度时，可以修改函数，添加一个参数，用来传入表名或表的oid即可。

 
RETURNS void AS 
 
$$
 
DECLARE 
 
    v_function_name text := 'my_create_func_for_files_skew';
 
    v_location_id int;
 
    v_sql text;
 
    v_db_oid text;
 
    v_number_segments numeric;
 
    v_skew_amount numeric;
 
BEGIN
 
    --定义代码的位置，方便用来定位问题--               
 
    v_location_id := 1000;
 
    
 
    --获取当前数据库的oid--        
 
    SELECT oid INTO v_db_oid 
 
    FROM pg_database 
 
    WHERE datname = current_database();
 
 
 
    --文件倾斜的视图并创建该视图--      
 
    v_location_id := 2000;
 
    v_sql := 'DROP VIEW IF EXISTS my_file_skew_view';
      
    v_location_id := 2100;
    EXECUTE v_sql;
    
    --保存db文件的外部表并创建该外部表--     
    v_location_id := 2200;
    v_sql := 'DROP EXTERNAL TABLE IF EXISTS my_db_files_web_tbl';
 
    v_location_id := 2300;
    EXECUTE v_sql;
 
    --获取 segment_id,relfilenode,filename,size 信息--     
    v_location_id := 3000;
    v_sql := 'CREATE EXTERNAL WEB TABLE my_db_files_web_tbl ' ||
            '(segment_id int, relfilenode text, filename text, size numeric) ' ||
            'execute E''ls -l $GP_SEG_DATADIR/base/' || v_db_oid || 
            ' | grep gpadmin | ' ||
            E'awk {''''print ENVIRON["GP_SEGMENT_ID"] "\\t" $9 "\\t" ' ||
            'ENVIRON["GP_SEG_DATADIR"] "/' || v_db_oid || 
            E'/" $9 "\\t" $5''''}'' on all ' || 'format ''text''';
 
    v_location_id := 3100;
    EXECUTE v_sql;
 
    --获取所有primary segment的个数--     
    v_location_id := 4000;
    SELECT count(*) INTO v_number_segments 
    FROM gp_segment_configuration 
    WHERE preferred_role = 'p' 
    AND content >= 0;
 
    --如果primary segment总数为40个，那么此处v_skew_amount=1.2*0.025=0.03--    
    v_location_id := 4100;
    v_skew_amount := 1.2*(1/v_number_segments);
    
    --创建记录文件倾斜的视图--    
    v_location_id := 4200;
    v_sql := 'CREATE OR REPLACE VIEW my_file_skew_view AS ' ||
             'SELECT schema_name, ' ||
             'table_name, ' ||
             'max(size)/sum(size) as largest_segment_percentage, ' ||
             'sum(size) as total_size ' ||
             'FROM    ( ' ||
             'SELECT n.nspname AS schema_name, ' ||
             '      c.relname AS table_name, ' ||
             '      sum(db.size) as size ' ||
             '      FROM my_db_files_web_tbl db ' ||
             '      JOIN pg_class c ON ' ||
             '      split_part(db.relfilenode, ''.'', 1) = c.relfilenode ' ||
             '      JOIN pg_namespace n ON c.relnamespace = n.oid ' ||
             '      WHERE c.relkind = ''r'' ' ||
             '      GROUP BY n.nspname, c.relname, db.segment_id ' ||
             ') as sub ' ||
             'GROUP BY schema_name, table_name ' ||
             'HAVING sum(size) > 0 and max(size)/sum(size) > ' ||  --只记录大于合适的才输出---
             v_skew_amount::text || ' ' || 
             'ORDER BY largest_segment_percentage DESC, schema_name, ' ||
             'table_name';
 
    v_location_id := 4300;
    EXECUTE v_sql; 
 
    EXCEPTION
        WHEN OTHERS THEN
            RAISE EXCEPTION '(%:%:%)', v_function_name, v_location_id, sqlerrm;
END;
$$ language plpgsql;
