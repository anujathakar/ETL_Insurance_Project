----Create tables----------
create table insurer_dim(
insurer_id int primary key,
insurer_name varchar(100) not null
)

create table complainant_dim(
complainant_id int primary key,
complainant_relation varchar(100) not null,
complainant_type varchar(100) not null
)

create table reason_dim(
reason_id int primary key,
reason_type varchar(500) not null
)

create table resolution_dim(
resolution_id int primary key,
resolution_type varchar(100) not null
)


create table complaint_dim(
complaint_id int primary key,
complaint_type varchar(100) not null
)

create table respondent_dim(
respondent_id int primary key,
respondent_role varchar(100) not null,
respondent_type varchar(100) not null
)

create table coverage_dim(
coverage_id int primary key,
coverage_type varchar(100) not null
)

create table complaint_fact(
complaint_fact_id varchar(50) primary key,
received_date varchar(50) not null,
close_date varchar(50) not null,
keywords varchar(500) not null,
insurer_id integer references insurer_dim(insurer_id),
complainant_id integer references complainant_dim(complainant_id),
reason_id integer references reason_dim(reason_id),
complaint_id integer references complaint_dim(complaint_id),
resolution_id integer references resolution_dim(resolution_id),
coverage_id integer references coverage_dim(coverage_id),
respondent_id integer references respondent_dim(respondent_id),
complaint_number int not null,
relation varchar(100) not null,
customer_painpoint varchar(500) not null,
type_of_complaint varchar(500) not null,
confirmation_status varchar(10) not null,
resolution_desc varchar(500) not null,
type_of_insurance varchar(500) not null,
level_of_insurance varchar(500) not null,
others_involved varchar(500) not null,
res_emp_id integer not null,
res_emp_desg varchar(500) not null,
res_emp_type varchar(500) not null,
description varchar(500) not null
)



---------------------------------------------------------------------------------------------------------------------------------
--Update queries to handle inconsistent data for each table--
----------------------------------------------------------------------------------------------------------------------------------

update complainant_dim
set complainant_relation = 'Other'
where complainant_relation = 'None' or complainant_relation is null;

update complaint_dim
set complaint_type = 'Other'
where complaint_type = 'None ';

update coverage_dim
set coverage_type = 'Other'
where coverage_type = 'None';

update insurer_dim
set insurer_name = 'Other'
where insurer_name = 'NONE';

update reason_dim
set reason_type = 'Other'
where reason_type = 'None '

update resolution_dim
set resolution_type = 'Other'
where resolution_type = 'None ';

update respondent_dim
set respondent_role = 'Other'
where respondent_role = 'None ';

update complaint_fact
set keywords = 'Other'
where keywords = 'None' or keywords is null;


update complaint_fact
set type_of_complaint = 'Other'
where type_of_complaint = 'None' or type_of_complaint is null;

update complaint_fact
set resolution_desc = 'Other'
where resolution_desc = 'None' or resolution_desc is null;

update complaint_fact
set res_emp_desg = 'Other'
where res_emp_desg = 'None' or res_emp_desg is null;

update complaint_fact
set description = 'Other'
where description = 'None' or description is null;

update complaint_fact
set received_date = to_char(to_date(received_date, 'YYYY-MM-DD'), 'MM-DD-YYYY'),
    close_date = to_char(to_date(close_date, 'YYYY-MM-DD'), 'MM-DD-YYYY');


------ Changed dates columns to datetime from varchar for calculating the average days--------
ALTER TABLE complaint_fact
ALTER COLUMN received_date TYPE TIMESTAMP USING TO_TIMESTAMP(received_date, 'MM-DD-YYYY');

ALTER TABLE complaint_fact
ALTER COLUMN close_date TYPE TIMESTAMP USING TO_TIMESTAMP(close_date, 'MM-DD-YYYY');


--------------------------------------------------------------------------------------------------------------------------------------------------
---Select queries----------------
--------------------------------------------------------------------------------------------------------------------------------------------------

----- Average resolution time taken for different coverage types----------------

SELECT coverage_dim.coverage_type, AVG(close_date - received_date) AS average_resolution_time
FROM complaint_fact
JOIN coverage_dim ON complaint_fact.coverage_id = coverage_dim.coverage_id
GROUP BY coverage_dim.coverage_type;

----- Average resolution time taken to resolve all the complaints-----------------------

SELECT AVG(close_date - received_date) AS average_resolution_time
FROM complaint_fact;

---Highest total number of complaints registered against reason type----

SELECT reason_dim.reason_type, COUNT(*) AS total_complaints
FROM complaint_fact
JOIN reason_dim ON complaint_fact.reason_id = reason_dim.reason_id
WHERE reason_dim.reason_type LIKE '%Access to care%'
   OR reason_dim.reason_type LIKE '%Agent handling%'
   OR reason_dim.reason_type LIKE '%Assignment of benefits%'
   OR reason_dim.reason_type LIKE '%Balance billing%'
   OR reason_dim.reason_type LIKE '%Cancellation%'
   OR reason_dim.reason_type LIKE '%Cash value%'
   OR reason_dim.reason_type LIKE '%Delays%'
   OR reason_dim.reason_type LIKE '%Denial of Claim%'
   OR reason_dim.reason_type LIKE '%Duplication of coverage%'
GROUP BY reason_dim.reason_type
Order by total_complaints desc
Limit 3s


----- Complaints registered due to claim handling delays-----

SELECT reason_dim.reason_type, COUNT(*) AS total_complaints
FROM complaint_fact
JOIN reason_dim ON complaint_fact.reason_id = reason_dim.reason_id
WHERE reason_dim.reason_type LIKE 'Delays%'
GROUP BY reason_dim.reason_type;

--- How many complaints are registered by complainant relation 'Agent'

SELECT complainant_relation, COUNT(*) AS total_complaints
FROM complaint_fact
JOIN complainant_dim ON complaint_fact.complainant_id = complainant_dim.complainant_id
WHERE complainant_dim.complainant_relation = 'Agent'
Group by complainant_relation;


------ How many complaints are registered by complainant_relation that are not Beneficiary

SELECT complainant_relation, COUNT(*) AS total_complaints
FROM complaint_fact
JOIN complainant_dim ON complaint_fact.complainant_id = complainant_dim.complainant_id
WHERE complainant_dim.complainant_relation Not like 'Beneficiary'
Group by complainant_relation;


---- Which insurance company has the highest number of complaints registered----

SELECT insurer_dim.insurer_name, COUNT(*) AS total_complaints
FROM complaint_fact
JOIN insurer_dim ON complaint_fact.insurer_id = insurer_dim.insurer_id
GROUP BY insurer_dim.insurer_name
order by total_complaints Desc
Limit 1;


--- Highest total number of complaints registered against coverage type----

SELECT coverage_dim.coverage_type, COUNT(*) AS total_complaints
FROM complaint_fact
JOIN coverage_dim ON complaint_fact.coverage_id = coverage_dim.coverage_id
WHERE coverage_dim.coverage_type LIKE '%Accident and Health%'
   OR coverage_dim.coverage_type LIKE '%Automobile%'
   OR coverage_dim.coverage_type LIKE '%Fire%'
   OR coverage_dim.coverage_type LIKE '%Homeowners%'
   OR coverage_dim.coverage_type LIKE '%Liability%'
   OR coverage_dim.coverage_type LIKE '%Life & Annuity%'
   OR coverage_dim.coverage_type LIKE '%Miscellaneous%'
GROUP BY coverage_dim.coverage_type
Order by total_complaints desc
Limit 3;
