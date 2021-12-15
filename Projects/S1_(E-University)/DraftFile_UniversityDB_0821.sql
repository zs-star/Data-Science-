

--DBMD LECTURE
--UNIVERSITY DATABASE PROJECT 



--CREATE DATABASE
CREATE DATABASE University;
Use University
--//////////////////////////////


--CREATE TABLES 


--Make sure you add the necessary constraints.
--You can define some check constraints while creating the table, but some you must define later with the help of a scalar-valued function you'll write.
--Check whether the constraints you defined work or not.
--Import Values (Use the Data provided in the Github repo). 
--You must create the tables as they should be and define the constraints as they should be. 
--You will be expected to get errors in some points. If everything is not as it should be, you will not get the expected results or errors.
--Read the errors you will get and try to understand the cause of the errors.

---Primary key and foreign key constraints

--Primary Keys

ALTER TABLE Student ADD CONSTRAINT pk_student PRIMARY KEY (StudentID)

ALTER TABLE Region ADD CONSTRAINT pk_region PRIMARY KEY (RegionID)

ALTER TABLE Staff ADD CONSTRAINT pk_staff PRIMARY KEY (StaffID)

ALTER TABLE Course ADD CONSTRAINT pk_course PRIMARY KEY (CourseID)


---Foreign Key constraints
---
ALTER TABLE Student ADD CONSTRAINT FK1_Student FOREIGN KEY (RegionID) REFERENCES Region (RegionID)
--ALTER TABLE Student DROP CONSTRAINT FK2_Student;
ALTER TABLE Student ADD CONSTRAINT FK2_Student FOREIGN KEY (StaffID) REFERENCES Staff (StaffID)
ON UPDATE NO ACTION
ON DELETE NO ACTION

---
ALTER TABLE Staff ADD CONSTRAINT FK_staff FOREIGN KEY (RegionID) REFERENCES Region (RegionID)

----
---Composite keys for ralational table enrollment and StaffCourse
ALTER TABLE Enrollment ADD CONSTRAINT pk_enrollment PRIMARY KEY (StudentID,CourseID)
ALTER TABLE Enrollment ADD CONSTRAINT FK1_enrollment FOREIGN KEY (StudentID) REFERENCES Student (StudentID)
ALTER TABLE Enrollment ADD CONSTRAINT FK2_enrollment FOREIGN KEY (CourseID) REFERENCES Course (CourseID)

-----
--ALTER TABLE StaffCourse ADD CONSTRAINT pk_staffcourse PRIMARY KEY (StaffID,CourseID)
ALTER TABLE StaffCourse ADD CONSTRAINT FK1_staffcourse FOREIGN KEY (StaffID) REFERENCES Staff (StaffID)
ALTER TABLE StaffCourse ADD CONSTRAINT FK2_staffcourse FOREIGN KEY (CourseID) REFERENCES Course (CourseID)


--////////////////////


--CONSTRAINTS

--1. Students are constrained in the number of courses they can be enrolled in at any one time. 
--	 They may not take courses simultaneously if their combined points total exceeds 180 points.
CREATE FUNCTION id_checkfunc (@ID INT)
RETURNS Varchar(5)
AS
BEGIN
if exists (
select SUM(Credit)
from Course A , Enrollment B
where A.CourseID=B.CourseID
AND B.StudentID=@ID
Group by B.StudentID
having SUM(Credit)<=180
)
  return 'True'
return 'False'
END

--
----Check Constraint to enrollment table
Alter table Enrollment add constraint FK_credit_check Check ([dbo].[id_checkfunc](StudentID) = 'True')



--------///////////////////


--2. The student's region and the counselor's region must be the same.

CREATE FUNCTION region_check (@RegionID INT,@StaffID INT)
RETURNS Varchar(5)
AS
BEGIN
if @StaffID in (
select A.StaffID
from Staff A, Student B
where A.StaffID=B.StaffID
and A.RegionID=@RegionID
)
 return 'True'
return 'False'
END

----Check Region Constraint to student  table
--ALTER TABLE Student DROP CONSTRAINT FK_region_check;
Alter table Student add constraint FK_region_check Check ([dbo].[region_check](RegionID,StaffID) = 'True')

--




--///////////////////////////////



------ADDITIONALLY TASKS



--1. Test the credit limit constraint.

insert Enrollment values (1,3),(1,4),(1,5),(1,6)
select * from Enrollment where StudentID=1
insert Enrollment values (1,7)  --- hatayý aldým bunu da eklesem 180 olacaktý




--//////////////////////////////////

--2. Test that you have correctly defined the constraint for the student counsel's region. 


--delete from Student where StudentID=7
insert Student values (7,'Ali','ATIL','5/12/2020',3,8)--error because od check constraint



--/////////////////////////


--3. Try to set the credits of the History course to 20. (You should get an error.)

insert Course (CourseID,Title,Credit) values(7,'History',20) 



--/////////////////////////////

--4. Try to set the credits of the Fine Arts course to 30.(You should get an error.)

insert Course (CourseID,Title,Credit) values(1,'Fine Arts',30) 



--////////////////////////////////////

--5. Debbie Orange wants to enroll in Chemistry instead of German. (You should get an error.)

--insert Enrollment values (6,3) 
--delete Enrollment where StudentID=6

????????????



--//////////////////////////


--6. Try to set Tom Garden as counsel of Alec Hunter (You should get an error.)

update Student set StaffID=6
where StudentID=1



--/////////////////////////

--7. Swap counselors of Ursula Douglas and Bronwin Blueberry.

??????????????




--///////////////////


--8. Remove a staff member from the staff table.
--	 If you get an error, read the error and update the reference rules for the relevant foreign key.


delete from Staff where StaffID=7

???????????????
 



















