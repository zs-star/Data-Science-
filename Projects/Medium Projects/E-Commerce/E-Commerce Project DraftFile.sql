

--DAwSQL Session -8 

--E-Commerce Project Solution



--1. Join all the tables and create a new table called combined_table. (market_fact, cust_dimen, orders_dimen, prod_dimen, shipping_dimen)

SELECT A.* ,C.*,D.*,E.*,B.Sales,B.Discount,B.Order_Quantity,B.Product_Base_Margin INTO combined_table
FROM cust_dimen A
INNER JOIN market_fact B
ON A.Cust_id=B.Cust_id
INNER JOIN orders_dimen C
ON B.Ord_id=C.Ord_id
INNER JOIN prod_dimen D
ON D.Prod_id=B.Prod_id
INNER JOIN shipping_dimen E
ON E.Ship_id=B.Ship_id


----Teacher solution


select * from combined_table

--///////////////////////
--Owen-lnstructor  3:24 PM
SELECT *
INTO
combined_table
FROM
(
SELECT
cd.Cust_id, cd.Customer_Name, cd.Province, cd.Region, cd.Customer_Segment,
mf.Ord_id, mf.Prod_id, mf.Sales, mf.Discount, mf.Order_Quantity, mf.Product_Base_Margin,
od.Order_Date, od.Order_Priority,
pd.Product_Category, pd.Product_Sub_Category,
sd.Ship_id, sd.Ship_Mode, sd.Ship_Date
FROM market_fact mf
INNER JOIN cust_dimen cd ON mf.Cust_id = cd.Cust_id
INNER JOIN orders_dimen od ON od.Ord_id = mf.Ord_id
INNER JOIN prod_dimen pd ON pd.Prod_id = mf.Prod_id
INNER JOIN shipping_dimen sd ON sd.Ship_id = mf.Ship_id
) A;

--2. Find the top 3 customers who have the maximum count of orders.
SELECT TOP 3 Cust_id,COUNT(Ord_id)
FROM combined_table
GROUP BY Cust_id
ORDER BY COUNT(Ord_id) DESC
--
--//////Owen-lnstructor  3:28 PM
SELECT	TOP(3)cust_id, COUNT (Ord_id) total_ord
FROM	combined_table
GROUP BY Cust_id
ORDER BY total_ord desc



--/////////////////////////////////



//////////////////////

--3.Create a new column at combined_table as DaysTakenForDelivery that contains the date difference of Order_Date and Ship_Date.
--Use "ALTER TABLE", "UPDATE" etc.

ALTER TABLE combined_table 
ADD DaysTakenForDelivery  INT
UPDATE combined_table SET DaysTakenForDelivery= DATEDIFF(DAY,Order_Date,Ship_Date)


SELECT Order_Date,Ship_Date,DaysTakenForDelivery

FROM combined_table


--////////////////////////////////////


--4. Find the customer whose order took the maximum time to get delivered.
--Use "MAX" or "TOP"

SELECT top 1 Customer_Name,Cust_id,DaysTakenForDelivery
FROM combined_table
order by DaysTakenForDelivery desc
---


--////////////////////////////////



--5. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011
--You can use such date functions and subqueries


---
SELECT COUNT(DISTINCT Cust_id)
FROM combined_table
WHERE MONTH(Order_Date)=01 AND YEAR(Order_Date)=2011

----
SELECT DISTINCT MONTH(Order_Date)
FROM combined_table
WHERE YEAR(Order_Date)=2011
---
WITH CUST_JAN AS(
SELECT DISTINCT Cust_id
FROM combined_table
WHERE MONTH(Order_Date)=01 AND YEAR(Order_Date)=2011)

SELECT DISTINCT [MONTH],COUNT(AA.Cust_id) OVER(PARTITION BY[MONTH]) 
FROM
(SELECT DISTINCT B.Cust_id,MONTH(B.Order_Date) AS [MONTH]
FROM CUST_JAN A
LEFT JOIN combined_table B
ON A.Cust_id=B.Cust_id
AND YEAR(B.Order_Date)='2011')AA
--Raife ----
select datename(Month,order_date) as month_name,Month(order_date) as month_number,  COUNT(distinct cust_id) as come_back 
from combined_table
where year(order_date ) = 2011 and 
cust_id in (
	select distinct Cust_id
	from combined_table
	where MONTH(Order_Date ) = 1
	and year(order_date ) = 2011)
group by datename(Month,order_date),Month(order_date)
order by Month(order_date)

-----
---------------Owen-lnstructor  4:01 PM
SELECT MONTH(order_date) [MONTH], COUNT(DISTINCT cust_id) MONTHLY_NUM_OF_CUST
FROM	Combined_table A
WHERE
EXISTS
(
SELECT  Cust_id
FROM	combined_table B
WHERE	YEAR(Order_Date) = 2011
AND		MONTH (Order_Date) = 1
AND		A.Cust_id = B.Cust_id
)
AND	YEAR (Order_Date) = 2011
GROUP BY
MONTH(order_date)


--////////////////////////////////////////////


--6. write a query to return for each user the time elapsed between the first purchasing and the third purchasing, 
--in ascending order by Customer ID
--Use "MIN" with Window Functions
-----////////////
---Doðru çözüm/////////////////
SELECT DISTINCT
		cust_id,
		order_date,
		dense_number,
		FIRST_ORDER_DATE,
		DATEDIFF(day, FIRST_ORDER_DATE, order_date) DAYS_ELAPSED
FROM	
		(
		SELECT	Cust_id, ord_id, order_DATE,
				MIN (Order_Date) OVER (PARTITION BY cust_id) FIRST_ORDER_DATE,
				DENSE_RANK () OVER (PARTITION BY cust_id ORDER BY Order_date) dense_number
		FROM	combined_table
		) A
WHERE	dense_number = 3



------When there are repeating row dense_rank is confident
----Give wrong output
select AA.Cust_id,AA.Customer_Name,AA.first_purc,AA.third_purc,DATEDIFF(day,AA.first_purc,AA.third_purc) time_elapsed
from
(SELECT Cust_id,Customer_Name, Order_Date as first_purc,
lead(Order_Date,2)over(partition by Cust_id order by Order_Date ASC) third_purc,
row_number() over(partition by Cust_id order by Order_Date ASC) row_each_cust
FROM combined_table)AA
where AA.row_each_cust='1'and AA.third_purc is not null and AA.first_purc is not null


---EDÝTED WÝTH CHANGE LEAD AND MIN
select distinct AA.Cust_id,AA.Customer_Name,AA.Order_Date as third_purch,AA.first_purch,DATEDIFF(day,AA.first_purch,AA.Order_Date) time_elapsed
from
(SELECT Cust_id,Customer_Name,Order_Date,
min(Order_Date)over(partition by Cust_id order by Order_Date ASC) first_purch,
dense_rank() over(partition by Cust_id order by Order_Date ASC) row_each_cust
FROM combined_table)AA
where AA.row_each_cust='3'and AA.Order_Date is not null and AA.first_purch is not null




---------//////Second solutýon

--custumers and their orders
SELECT Customer_Name,Order_Date,
row_number() over(partition by Customer_Name order by Order_Date ASC) row_each_cust
FROM combined_table
ORDER BY Customer_Name
---- output
WITH AA AS (
SELECT Customer_Name,Cust_id,Order_Date,
dense_rank() over(partition by Cust_id order by Order_Date ASC) row_each_cust
FROM combined_table)
--ORDER BY Customer_Name)
--
SELECT Distinct AA.Customer_Name,AA.Cust_id,AA.Order_Date AS Order_Date_First,A.Order_Date_Third,DATEDIFF(DAY,AA.Order_Date,A.Order_Date_Third) AS Time_elapsed
FROM AA
INNER JOIN (SELECT Cust_id,Order_Date AS Order_Date_Third
FROM AA
WHERE row_each_cust=3
)A
ON AA.Cust_id=A.Cust_id
WHERE row_each_cust=1
ORDER BY AA.Cust_id

----///




--//////////////////////////////////////

--7. Write a query that returns customers who purchased both product 11 and product 14, 
--as well as the ratio of these products to the total number of products purchased by the customer.
--Use CASE Expression, CTE, CAST AND such Aggregate Functions

SELECT * FROM 
(SELECT Cust_id,
SUM(CASE WHEN Prod_id='Prod_11' THEN Order_Quantity ELSE 0 END) AS PROD_11,
SUM(CASE WHEN Prod_id='Prod_14' THEN Order_Quantity ELSE 0 END) AS PROD_14,
SUM(Order_Quantity) TOTAL_PRODUCT,
CAST(SUM(CASE WHEN Prod_id='Prod_11' THEN Order_Quantity ELSE 0 END)/SUM(Order_Quantity)AS DECIMAL(8,2)) AS R_PROD_11,
SUM(CASE WHEN Prod_id='Prod_14' THEN Order_Quantity ELSE 0 END)/SUM(Order_Quantity) AS R_PROD_14
FROM combined_table
GROUP BY Cust_id)AA
WHERE AA.PROD_11>0 AND AA.PROD_14>0



with Cust_11_14 as (
select Customer_Name
from combined_table
where Prod_id='Prod_11'
intersect 
select Customer_Name
from combined_table
where Prod_id='Prod_14'),

Total_11_14 as (
select Customer_Name,count(prod_11_14) as total_11_14 from
		(select Customer_Name,Cust_id,
									case
									when Prod_id='Prod_11' then 'Prod_11'
									when Prod_id='Prod_14' then 'Prod_14'
									else null
									end as prod_11_14
		from combined_table)A
where A.prod_11_14 is not null
and Customer_Name in
					 (select * from Cust_11_14)
group by Customer_Name),
Total_product as(
select Customer_Name,count(Prod_id) as Total_product 
from combined_table
where Customer_Name in (select * from Cust_11_14)
group by Customer_Name)
select AA.Customer_Name,AB.total_11_14,AA.Total_product, cast(round((AB.total_11_14*1.0)/(AA.Total_product*1.0),3) as decimal(8,3)) as ratio
from Total_product AA,Total_11_14 AB
where AA.Customer_Name=AB.Customer_Name


----seperated prod_11 and prod_14 ratio/////////////
with Cust_11_14 as (
select Customer_Name
from combined_table
where Prod_id='Prod_11'
intersect 
select Customer_Name
from combined_table
where Prod_id='Prod_14'),

Total_11_14 as (
select Customer_Name,count(prod_11) as total_11,count(prod_14) as total_14 
from
		(select Customer_Name,Cust_id,
									case when Prod_id='Prod_11' then 'Prod_11' else null end as prod_11,
									case when Prod_id='Prod_14' then 'Prod_14' else null end as prod_14
		from combined_table)A
where A.prod_11 is not null
or A.prod_14 is not null
and Customer_Name in
					 (select * from Cust_11_14)
group by Customer_Name),
Total_product as(
select Customer_Name,count(Prod_id) as Total_product 
from combined_table
where Customer_Name in (select * from Cust_11_14)
group by Customer_Name)
select AA.Customer_Name,AB.total_11,AB.total_14,AA.Total_product, cast(round((AB.total_11*1.0)/(AA.Total_product*1.0),3) as decimal(8,3)) as ratio_11,
cast(round((AB.total_14*1.0)/(AA.Total_product*1.0),3) as decimal(8,3)) as ratio_14
from Total_product AA,Total_11_14 AB
where AA.Customer_Name=AB.Customer_Name

----DOÐRU ÇÖZÜM

WITH T1 AS
(
SELECT	Cust_id,
		SUM (CASE WHEN Prod_id = 'Prod_11' THEN Order_Quantity ELSE 0 END) P11,
		SUM (CASE WHEN Prod_id = 'Prod_14' THEN Order_Quantity ELSE 0 END) P14,
		SUM (Order_Quantity) TOTAL_PROD
FROM	combined_table
GROUP BY Cust_id
HAVING
		SUM (CASE WHEN Prod_id = 'Prod_11' THEN Order_Quantity ELSE 0 END) >= 1 AND
		SUM (CASE WHEN Prod_id = 'Prod_14' THEN Order_Quantity ELSE 0 END) >= 1
)
SELECT	Cust_id, P11, P14, TOTAL_PROD,
		CAST (1.0*P11/TOTAL_PROD AS NUMERIC (3,2)) AS RATIO_P11,
		CAST (1.0*P14/TOTAL_PROD AS NUMERIC (3,2)) AS RATIO_P14
FROM T1

SELECT *
FROM combined_table
WHERE Prod_id='Prod_14'AND Cust_id='Cust_1538'

--CAST(ROUND(D.Cancel_rate, 1) AS DECIMAL(8,1))
--/////////////////



--CUSTOMER RETENTION ANALYSIS



--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.
CREATE VIEW Visit_log AS
select distinct Customer_Name,Cust_id,year(Order_Date) as year, month(Order_Date) as month
from combined_table
--
select * from Visit_log
order by Customer_Name, month;
--//////////////////////////////////


--2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)
--Don't forget to call up columns you might need later.


select [month],count(Cust_id) as num_of_cust 
from Visit_log
group by [month]
order by [month]

-----////////by windows func
CREATE VIEW Monthly_visit_num AS
select distinct [month],count(Cust_id)over(partition by [month] ) as num_of_cust 
from Visit_log


select * from Monthly_visit_num
order by [month];
---------------------
--Owen-lnstructor  4:42 PM
--1. Create a view that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
--Use such date functions. Don't forget to call up columns you might need later.
CREATE VIEW customer_logs AS
SELECT	cust_id,
		YEAR (ORDER_DATE) [YEAR],
		MONTH (ORDER_DATE) [MONTH]
FROM	combined_table
ORDER BY 1,2,3
--//////////////////////////////////
--2. Create a view that keeps the number of monthly visits by users. (Separately for all months from the business beginning)
--Don't forget to call up columns you might need later.
CREATE VIEW NUMBER_OF_VISITS AS
SELECT	Cust_id, [YEAR], [MONTH], COUNT(*) NUM_OF_LOG
FROM	customer_logs
GROUP BY Cust_id, [YEAR], [MONTH]

--//////////////////////////////////


--3. For each visit of customers, create the next month of the visit as a separate column.
--You can number the months with "DENSE_RANK" function.
--then create a new column for each month showing the next month using the numbering you have made. (use "LEAD" function.)
--Don't forget to call up columns you might need later.
select Cust_id,Order_Date,MONTH(Order_Date) [month],
ROW_NUMBER () OVER (PARTITION BY Cust_id ORDER BY Order_Date) ROW_NUM,
DENSE_RANK () OVER (PARTITION BY Cust_id ORDER BY Order_Date) DENSE_RANK_NUM,
LEAD(order_date,1) OVER (PARTITION BY Cust_id ORDER BY Order_Date) Next_Ord_date
from combined_table
order by Cust_id


--/////////////////////////////////



--4. Calculate the monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.
WITH TIME_GAP_MONTH AS(
SELECT AB.Cust_id,AB.Order_Date,AB.Next_Ord_date,DATEDIFF(MONTH,AB.Order_Date,AB.Next_Ord_date) AS Time_Gap_Monthly
FROM
	(select Cust_id,Order_Date,MONTH(Order_Date) [month],
	ROW_NUMBER () OVER (PARTITION BY Cust_id ORDER BY Order_Date) ROW_NUM,
	DENSE_RANK () OVER (PARTITION BY Cust_id ORDER BY Order_Date) DENSE_RANK_NUM,
	LEAD(order_date,1) OVER (PARTITION BY Cust_id ORDER BY Order_Date) Next_Ord_date
	from combined_table
	)AB
	)
SELECT *
FROM 	TIME_GAP_MONTH


--------------------------------Owen-lnstructor  5:12 PM
--3. For each visit of customers, create the next month of the visit as a separate column.
--You can number the months with "DENSE_RANK" function.
--then create a new column for each month showing the next month using the numbering you have made. (use "LEAD" function.)
--Don't forget to call up columns you might need later.
CREATE VIEW NEXT_VISIT AS
SELECT *,
		LEAD(CURRENT_MONTH, 1) OVER (PARTITION BY Cust_id ORDER BY CURRENT_MONTH) NEXT_VISIT_MONTH
FROM
(
SELECT  *,
		DENSE_RANK () OVER (ORDER BY [YEAR] , [MONTH]) CURRENT_MONTH
		
FROM	NUMBER_OF_VISITS
) A

SELECT * FROM NEXT_VISIT
--/////////////////////////////////
--4. Calculate the monthly time gap between two consecutive visits by each customer.
--Don't forget to call up columns you might need later.
CREATE VIEW time_gaps AS
SELECT *,
		NEXT_VISIT_MONTH - CURRENT_MONTH time_gaps
FROM	NEXT_VISIT




--/////////////////////////////////////////


--5.Categorise customers using time gaps. Choose the most fitted labeling model for you.
--  For example: 
--	Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
--	Labeled as regular if the customer has made a purchase every month.
--  Etc.


WITH TIME_GAP_MONTH AS(
SELECT AB.Cust_id,AB.Order_Date,AB.Next_Ord_date,DATEDIFF(MONTH,AB.Order_Date,AB.Next_Ord_date) AS Time_Gap_Monthly
FROM
	(select Cust_id,Order_Date,MONTH(Order_Date) [month],
	ROW_NUMBER () OVER (PARTITION BY Cust_id ORDER BY Order_Date) ROW_NUM,
	DENSE_RANK () OVER (PARTITION BY Cust_id ORDER BY Order_Date) DENSE_RANK_NUM,
	LEAD(order_date,1) OVER (PARTITION BY Cust_id ORDER BY Order_Date) Next_Ord_date
	from combined_table
	)AB
	)

SELECT AC.Cust_id,
CASE
when avg_time_gap is null then 'Churn'
when  avg_time_gap=1 THEN 'Regular'
when  avg_time_gap<5 and avg_time_gap>1 THEN 'Semi-Regular'
when  avg_time_gap<12 and avg_time_gap>5 THEN 'Semi-Yearly'
else 'Yearly'
END AS[Label]
FROM(
SELECT distinct Cust_id,avg(Time_Gap_Monthly)over(partition by Cust_id) avg_time_gap
FROM 	TIME_GAP_MONTH)AC
----------------------------------------Owen-lnstructor  5:24 PM
SELECT cust_id, avg_time_gap,
		CASE WHEN avg_time_gap = 1 THEN 'retained'
			WHEN avg_time_gap > 1 THEN 'irregular'
			WHEN avg_time_gap IS NULL THEN 'Churn'
			ELSE 'UNKNOWN DATA' END CUST_LABELS
FROM
		(
		SELECT Cust_id, AVG(time_gaps) avg_time_gap
		FROM	time_gaps
		GROUP BY Cust_id
		) A





--/////////////////////////////////////




--MONTH-WÝSE RETENTÝON RATE


--Find month-by-month customer retention rate  since the start of the business.


--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps

SELECT DISTINCT MONTH(Order_Date)[MONTH],COUNT(Cust_id)OVER(PARTITION BY MONTH(Order_Date)) NUM_CUST
FROM combined_table
ORDER BY [MONTH]


--------------------------------------------------Owen-lnstructor  5:38 PM
--Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Next Nonth / Total Number of Customers in The Previous Month

--MONTH-WÝSE RETENTÝON RATE
--Find month-by-month customer retention rate  since the start of the business.
--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps
SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		time_gaps,
		COUNT (cust_id)	OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTITON_MONTH_WISE
FROM	time_gaps
where	time_gaps =1
ORDER BY cust_id, NEXT_VISIT_MONTH

--//////////////////////


--2. Calculate the month-wise retention rate.

--Basic formula: o	Month-Wise Retention Rate = 1.0 * Total Number of Customers in The Previous Month / Number of Customers Retained in The Next Nonth

--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View. 
--You can also use CTE or Subquery if you want.

--You should pay attention to the join type and join columns between your views or tables.


SELECT AD.[MONTH],AD.NUM_CUST,
CAST(ROUND((1.0*LAG(AD.NUM_CUST)OVER(ORDER BY AD.[MONTH]))/LEAD(AD.NUM_CUST)OVER(ORDER BY AD.[MONTH]),2) AS DECIMAL (8,2)) AS Month_Wise_Retention_Rate
FROM
(SELECT DISTINCT MONTH(Order_Date)[MONTH],COUNT(Cust_id)OVER(PARTITION BY MONTH(Order_Date)) NUM_CUST
FROM combined_table
)AD

---------------------------------------------Owen-lnstructor  5:38 PM
Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Next Nonth / Total Number of Customers in The Previous Month
white_check_mark
eyes
raised_hands






--MONTH-WÝSE RETENTÝON RATE
--Find month-by-month customer retention rate  since the start of the business.
--1. Find the number of customers retained month-wise. (You can use time gaps)
--Use Time Gaps
SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		time_gaps,
		COUNT (cust_id)	OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTITON_MONTH_WISE
FROM	time_gaps
where	time_gaps =1
ORDER BY cust_id, NEXT_VISIT_MONTH

--2. Calculate the month-wise retention rate.
--Basic formula: o	Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Next Nonth / Total Number of Customers in The Previous Month
--It is easier to divide the operations into parts rather than in a single ad-hoc query. It is recommended to use View.
--You can also use CTE or Subquery if you want.
--You should pay attention to the join type and join columns between your views or tables.
CREATE VIEW CURRENT_NUM_OF_CUST AS
SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		COUNT (cust_id)	OVER (PARTITION BY CURRENT_MONTH) RETENTITON_MONTH_WISE
FROM	time_gaps
SELECT *
FROM	CURRENT_NUM_OF_CUST
---
DROP VIEW NEXT_NUM_OF_CUST
CREATE VIEW NEXT_NUM_OF_CUST AS
SELECT	DISTINCT cust_id, [YEAR],
		[MONTH],
		CURRENT_MONTH,
		NEXT_VISIT_MONTH,
		COUNT (cust_id)	OVER (PARTITION BY NEXT_VISIT_MONTH) RETENTITON_MONTH_WISE
FROM	time_gaps
WHERE	time_gaps = 1
AND		CURRENT_MONTH > 1
SELECT DISTINCT
		B.[YEAR],
		B.[MONTH],
		B.CURRENT_MONTH,
		B.NEXT_VISIT_MONTH,
		1.0 * B.RETENTITON_MONTH_WISE / A.RETENTITON_MONTH_WISE RETENTION_RATE
FROM	CURRENT_NUM_OF_CUST A LEFT JOIN NEXT_NUM_OF_CUST B
ON		A.CURRENT_MONTH + 1 = B.NEXT_VISIT_MONTH

---///////////////////////////////////
--Good luck!