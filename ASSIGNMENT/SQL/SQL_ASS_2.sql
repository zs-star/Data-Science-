Create Table #user 
(
User_id int,
Action varchar(20),
date date
)
INSERT #user VALUES 
(1, 'Start','1-1-20'),
(1, 'Cancel','1-2-20'),
(2, 'Start','1-3-20'),
(2, 'Publish','1-4-20'),
(3, 'Start','1-5-20'),
(3, 'Cancel','1-6-20'),
(1, 'Start','1-7-20'),
(1, 'Publish','1-8-20')
----

--select * from #user
---Desired output --------
With start_no as 
(select User_id,count(Action)as start_number
from #user
where Action='Start'
group by User_id),
publish_no as
(select User_id,count(Action)as publish_number
from #user
where Action='Publish'
group by User_id),
cancel_no as
(select User_id,count(Action)as cancel_number
from #user
where Action='Cancel'
group by User_id)
--convert(DOUBLE PRECISION, ROUND(D.publish_rate, 2)) gives 1 not 1.0 and 0 not 0.0
select User_id,CAST(ROUND(D.publish_rate, 1) AS DECIMAL(8,1)) as publish_rate, CAST(ROUND(D.Cancel_rate, 1) AS DECIMAL(8,1)) as Cancel_rate                      
from
(select A.User_id,isnull(B.publish_number,0)*1.0/A.start_number as Publish_rate ,isnull(C.cancel_number,0)*1.0/A.start_number as Cancel_rate
 from start_no A
 left join publish_no B
 on A.User_id=B.User_id
 left join cancel_no C
 on A.User_id=C.User_id)D
