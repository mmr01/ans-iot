SELECT 
    t.name AS TableName,
    p.rows AS RowCounts,
    SUM(a.total_pages) AS TotalSpace, 
    SUM(a.used_pages) AS UsedSpace,
	SUM(a.data_pages) AS DataPages
FROM 
    sys.tables t
INNER JOIN      
    sys.indexes i ON t.object_id = i.object_id
INNER JOIN 
    sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN 
    sys.allocation_units a ON p.partition_id = a.container_id
--WHERE t.Name = 't_readouts_raw'
GROUP BY 
    t.Name, p.Rows
ORDER BY 
    t.Name

/*
SELECT * FROM sys.tables
SELECT * FROM sys.partitions

SELECT * FROM sys.allocation_units
*/

