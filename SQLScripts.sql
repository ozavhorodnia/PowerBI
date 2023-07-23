/***************Retrieve the last no empty price by ProductId*************/
;WITH PriceData AS
(
	SELECT t.ProductId, t.PriceDate, t.Price
	FROM
	(
		VALUES
		(1111, '20230701', 120),
		(1111, '20230702', 110),
		(1111, '20230703', 155),
		(1111, '20230704', NULL),
		(1112, '20230701', 121),
		(1112, '20230702', 134),
		(1112, '20230703', 156),
		(1112, '20230704', 145),
		(1113, '20230701', 123),
		(1113, '20230703', 127),
		(1113, '20230704', NULL),
		(1114, '20230701', 78),
		(1114, '20230702', 79),
		(1114, '20230703', 83),
		(1114, '20230704', 77)
	) t(ProductId, PriceDate, Price)
)
,Price AS
(
SELECT ProductId,
ROW_NUMBER() OVER(PARTITION BY ProductId ORDER BY PriceDate DESC) Rn,
FIRST_VALUE(Price) OVER(PARTITION BY ProductId ORDER BY CASE WHEN Price IS NULL THEN 0 ELSE 1 END DESC, PriceDate DESC) AS LastPrice
FROM PriceData
) 
SELECT ProductId,
LastPrice
FROM Price
WHERE Rn = 1

/**************RunningTotal, Spend, Ratio by Product***********************/
;WITH Data AS
(
	SELECT t.ProductId, CONVERT(DATE,t.InvoiceDate) AS InvoiceDate, t.Spend
	FROM
	(
		VALUES
		(1111, '20230701', 120.0),
		(1111, '20230702', 110),
		(1111, '20230703', 155),
		(1111, '20230704', 136),
		(1112, '20230701', 121),
		(1112, '20230702', 134),
		(1112, '20230703', 156),
		(1112, '20230704', 145),
		(1113, '20230701', 123),
		(1113, '20230703', 127),
		(1113, '20230704', 135),
		(1114, '20230701', 78),
		(1114, '20230702', 79),
		(1114, '20230703', 83),
		(1114, '20230704', 77),
		(1115, '20230701', 0)
	) t(ProductId, InvoiceDate, Spend)
)
SELECT ProductId,
InvoiceDate,
Spend,
SUM(Spend) OVER(PARTITION BY ProductId) AS SpendByProduct,
CONVERT(DECIMAL(38,4), COALESCE(Spend/NULLIF(SUM(Spend) OVER(PARTITION BY ProductId), 0), 0)) AS SpendRatio,
SUM(Spend) OVER(PARTITION BY ProductId ORDER BY InvoiceDate) AS RunningTotal
FROM Data
ORDER BY ProductId, InvoiceDate

/*************Find the nth highest salary from the Employee table***********************/
DECLARE @N INT = 2;

;WITH Employee AS
(
	SELECT t.EmployeeId, t.DepartmentId, t.Salary
	FROM
	(
		VALUES
		(1, 1,250),
		(2, 1, 345),
		(3, 1, 565),
		(4, 1, 230),
		(5, 2, 300),
		(6, 2, 250),
		(7, 2, 260),
		(8, 2, 300)
	) t(EmployeeId, DepartmentId, Salary)
)
SELECT DepartmentId, Salary
FROM (
		SELECT DepartmentId, DENSE_RANK() OVER (PARTITION BY DepartmentId ORDER BY Salary DESC) AS rn,
		Salary
		FROM Employee
		) t
WHERE rn = @N
