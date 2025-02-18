create database assessment;

use assessment;

--create employee master table

create table t_emp(
Emp_id int identity(1001,2) primary key,
Emp_Code varchar(30),
Emp_f_name varchar(30) not null,
Emp_m_name varchar(20),
Emp_l_name varchar(30),
Emp_DOB DATE,
Emp_DOJ date not null
);


ALTER TABLE t_emp
ADD CONSTRAINT chk_age CHECK (DATEDIFF(YEAR, Emp_DOB, GETDATE()) >= 18);


--insert values into employees table

insert into t_emp(Emp_Code,Emp_f_name,Emp_l_name,Emp_DOB,Emp_DOJ) VALUES('OPT20110105','Manmohan','Singh','1983-02-10','2010-05-25');
insert into t_emp(Emp_Code,Emp_f_name,Emp_m_name,Emp_l_name,Emp_DOB,Emp_DOJ) VALUES('OPT20110105','Alfred','Joseph','lawrence','1988-02-28','1988-02-12'),
('OPT20110108','Al','doe','lar','1989-02-28','1976-10-23'),('OPT20110158','Al','doe','lar','1987-02-28','1988-07-12'),('OPT102455','JOE','DOE','BNASAL','1898-10-23','1976-10-23');


select *from t_emp;
--create table activity

create table t_activity(
activity_id int primary key,
activity_description varchar(100));

INSERT INTO t_activity values(1,'Code analysis'),(2,'lunch'),(3,'Coding'),(4,'knowledge transition'),(5,'database');


select *from t_activity;

--create table attendance
create table t_atten_det(
Atten_id int identity(1001,1),
Emp_id int foreign key references t_emp(Emp_id),
Activity_id int foreign key references t_activity(activity_id),
atten_start_datetime datetime,
Atten_end_hrs int);

insert into t_atten_det(Emp_id,activity_id,atten_start_datetime,atten_end_hrs) values(1001,5,'2011-02-13 10:00:00',2),(1001,1,'2022-01-14 10:00:00',3),(1001,3,'2011-01-14 13:00:00',5),(1003,5,'2011-02-16 10:00:00',8),(1003,5,'2011-02-17 10:00:00',8),(1003,5,'2011-02-19 10:00:00',7);


select *from t_atten_det;

--create table salary


create table t_salary(
salary_id int identity(1001,1) primary key,
Emp_id int foreign key references t_emp(Emp_id),
changed_date date,
new_salary decimal(10,2)
);

insert into t_salary(Emp_id,changed_date,new_salary) values(1003,'2011-02-16',20000),(1003,'2011-05-01',25000),(1001,'2011-02-16',26000),(1001,'2011-03-12',30000);




--Q1 Display full name and dob of those employees whose birth date falls in the last day of any month.


select concat(Emp_f_name,' ',Emp_m_name,' ',Emp_l_name) as full_name,Emp_DOB
from t_emp
where day(Emp_DOB)=day(eomonth(Emp_DOB));



--Q2 

with sal_cte as(
select emp_id,new_salary,changed_date,dense_rank() over(partition by emp_id order by changed_date ) as rank
from t_salary),

cte_max as(
select emp_id,new_salary as current_sal from sal_cte where rank=any(select max(rank)
from sal_cte group by emp_id)),

cte_min as(
select emp_id,new_salary as previous_sal 
from sal_cte 
where rank=any(select max(rank)-1 from sal_cte group by emp_id)),

cte_combined as(
select c1.emp_id,c1.current_sal,c2.previous_sal 
from cte_max c1 
join cte_min c2 on c1.emp_id=c2.emp_id),

cte_name as(
select concat(e.emp_f_name,' ',e.emp_m_name,' ',e.emp_l_name) as fullname,ct.emp_id,ct.current_sal,ct.previous_sal 
from t_emp e 
join cte_combined ct on e.emp_id=ct.emp_id),

cte_curr_prev_sal as( 
select fullname,emp_id,current_sal,previous_sal,
case when(current_sal-previous_sal)>0 then 'yes' else 'no' end as 'isincrement' from cte_name),

cte_worked_hours as(select f.fullname,f.emp_id,f.current_sal,f.previous_sal,f.isincrement,a.activity_id,sum(a.atten_end_hrs) as total_worked_hours_in_specific_act
from cte_curr_prev_sal f
join t_atten_det a
on f.emp_id=a.emp_id
group by f.emp_id,f.fullname,f.current_sal,f.previous_sal,f.isincrement,a.activity_id),

final_cte as(
select fc.fullname,fc.emp_id,fc.current_sal,fc.previous_sal,fc.isincrement,fc.activity_id,fc.total_worked_hours_in_specific_act,act.activity_description

from cte_worked_hours fc
join t_activity act
on fc.Activity_id=act.activity_id) select *from final_cte;


