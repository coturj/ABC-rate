
WITH ProductSales AS
(
SELECT
	YEAR(A.ModifiedDate) AS OrderYear,
	C.Name,
	SUM(A.TotalDue) AS Sales
FROM Sales.SalesOrderHeader A
LEFT JOIN Sales.SalesOrderDetail B ON A.SalesOrderID=B.SalesOrderID
LEFT JOIN Production.Product C ON B.ProductID=C.ProductID
GROUP BY C.Name, YEAR(A.ModifiedDate)
)
SELECT 
	OrderYear,
	Name,
	Sales,
	SUM(Sales) OVER (PARTITION BY OrderYear ORDER BY Sales DESC) AS CumulativeSales,
	SUM(Sales) OVER (PARTITION BY OrderYear) AS TotalSales,
    SUM(Sales) OVER (PARTITION BY OrderYear ORDER BY Sales DESC)
        / SUM(Sales) OVER (PARTITION BY OrderYear) AS CumulativePercentage,
   CASE 
        WHEN SUM(Sales) OVER (PARTITION BY OrderYear ORDER BY Sales DESC) 
                / SUM(Sales) OVER (PARTITION BY OrderYear) < 0.7 
            THEN 'A'
        WHEN SUM(Sales) OVER (PARTITION BY OrderYear ORDER BY Sales DESC) 
                / SUM(Sales) OVER (PARTITION BY OrderYear)  BETWEEN 0.7 AND 0.9 
            THEN 'B'
        ELSE 'C'
    END AS Class
FROM  ProductSales
GROUP BY 
    OrderYear,
    Name,    
    Sales
ORDER BY 
    OrderYear ASC, Sales DESC;
