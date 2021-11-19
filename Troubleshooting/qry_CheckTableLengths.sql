--change <customer>
--change <tablename>

SELECT O.NAME as TlbName,C.column_id,C.name AS ColName,C.max_length
FROM <customer>_IM.SYS.OBJECTS AS O
	INNER JOIN <customer>_IM.SYS.COLUMNS AS C ON O.object_id=C.object_id
WHERE O.NAME='<tablename>'