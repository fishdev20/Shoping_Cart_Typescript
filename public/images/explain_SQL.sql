
-- INITIAL DATABASE LEAD_OPPORTUNITY

create database LEAD_OPPORTUNITY; 
-- query: tạo database tên LEAD_OPPORTUNITY

use LEAD_OPPORTUNITY;
-- query: sử dụng database LEAD_OPPORTUNITY

-- CREATE TABLE LEAD_DATA

create table LEAD_DATA (
lead_id VARCHAR(255) NOT NULL PRIMARY KEY, 
lead_createddate DATE,
sales_qualified_lead_date DATE null,
lead_source VARCHAR(50), 
is_converted VARCHAR(30), 
converted_opportunity_id VARCHAR(255) NOT NULL
);
-- query: lệnh này tạo ra 1 table là lead_data có các cột:
-- 1. lead_id dạng VARCHAR(255) không null là khóa chính,
-- 2. lead_createddate dạng DATE,
-- 3. sales_qualified_lead_date  dạng DATE ko null,
-- 4. lead_source VARCHAR(50) dạng, 
-- 5. is_converted VARCHAR(30) dạng, 
-- 6. converted_opportunity_id VARCHAR(255) NOT NULL

-- CREATE TABLE OPPORTUNITY_DATA
create table OPPORTUNITY_DATA (
opportunity_id VARCHAR(255) NOT NULL PRIMARY KEY, 
opportunity_amount bigint, 
opportunity_type VARCHAR(30),
opportunity_created_date DATE,
moved_to_qualified_stage DATE,
opportunity_close_date DATE,
iswon VARCHAR(30),
isclosed VARCHAR(30),
opportunity_stage_name VARCHAR(30),
is_deleted VARCHAR(30)
);
-- query: lệnh này tạo ra 1 table là OPPORTUNITY_DATA có các cột:
-- 1. opportunity_id VARCHAR(255) không NULL là khóa chính, 
-- 2. opportunity_amount bigint, 
-- 3. opportunity_type VARCHAR(30),
-- 4. opportunity_created_date DATE,
-- 5. moved_to_qualified_stage DATE,
-- 6. opportunity_close_date DATE,
-- 7. iswon VARCHAR(30),
-- 8. isclosed VARCHAR(30),
-- 9. opportunity_stage_name VARCHAR(30),
-- 10. 	is_deleted VARCHAR(30)

-- IMPORT DATA TO TABLE
LOAD DATA LOCAL INFILE  'F:/Power BI Mastery/Case study/Opportunity vs Lead/leaddata_2022-8-12_1353.csv'
INTO TABLE LEAD_DATA
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- query: import data từ file leaddata_2022-8-12_1353.csv vào table LEAD_DATA

LOAD DATA LOCAL INFILE  'F:/Power BI Mastery/Case study/Opportunity vs Lead/opportunitydata_2022-8-12_1307.csv'
INTO TABLE OPPORTUNITY_DATA
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- query: import data từ file opportunitydata_2022-8-12_1307.csv vào table OPPORTUNITY_DATA

select * from LEAD_DATA;
-- query: lấy dữ liệu tất cả các cột bảng LEAD_DATA
select * from OPPORTUNITY_DATA;
-- query: lấy dữ liệu tất cả các cột bảng OPPORTUNITY_DATA


create table detail_lead_opportunity as
select *  from  lead_data A left join opportunity_data B
on A.converted_opportunity_id = B.opportunity_id;
-- query: create new table is joined from 2 table ( lead_data left join opportunity_data theo cột converted_opportunity_id = opportunity_id
select * from lead_data;

-- QUESTION 2:
-- A1. how has the generation of created opportunities developed? 
select * from detail_lead_opportunity;
-- query: lấy dữ liệu tất cả các cột bảng detail_lead_opportunity
select distinct(opportunity_stage_name) from detail_lead_opportunity;
-- query: lấy ra các giá trị duy nhất cột opportunity_stage_name từ bảng detail_lead_opportunity


-- opportunities is create as following:
-- 1. Lead_id is created, if it is qualified (sales_qualified_lead_date has date value) then it is converted (is_converted = True)
-- and it has a converted_opportunity_id else converted_opportunity_id is null.
-- Once it has converted_opportunity_id, then related field to opportunites is activated (not null value)
-- an opportunities may won or lose (iswon = True mean won else lose) and close or not (isclose)
-- user can check the opportunites status at column "opportunity_stage_name"
-- there ares stages as: 
-- 	'POC / Negotiations'
-- 	'Closed Won'
-- 	'Closed Lost'
-- 	'Qualified'
-- 	'Pre-Pipeline'
-- 	'Solution'
-- 	'Proposal'
-- 	'Negotiations Completed'

-- A2. Are there difference between different opportunity sources?
select distinct(lead_source) from detail_lead_opportunity
where opportunity_id is not null;
-- query: lấy ra các giá trị duy nhất cột lead_source từ bảng detail_lead_opportunity với opportunity_id không null


-- above SQL query the opportinity that successful created and get the unique value of lead_source make the opportunith
-- as below:
-- 		'Marketing Site'
-- 		'Inbound'
-- 		'Field Marketing'
-- 		'Sales - Outbound'
-- 		'Event'
-- 		'Referral'
-- 		'Marketing'
-- 		'Trial'
-- so, we can see the opportinity is make from many sources

-- B. How much revenue did the opportunites created?
select sum(opportunity_amount) as Opportunity_Revenue, iswon from detail_lead_opportunity
group by iswon;
-- query: lấy ra tổng opportunity_amount (đặt tên là Opportunity_Revenue), cột iswwon từ bảng detail_lead_opportunity
-- được gom nhóm bởi cột iswwon


-- as may see from above query, for Opportunity won  = 93948, Oppportunity not won = 557110,
-- total is 651058

-- C. What can you say the performace of lead_source
select 
	A.lead_source, A.Opportunity_Revenue, A.Total_Revenue, A.Ratio_Success
from
	(select 
		lead_source,
		sum(opportunity_amount) as Opportunity_Revenue, iswon, 
		sum(sum(opportunity_amount)) OVER() as Total_Revenue,
		case when 
			sum(opportunity_amount) is not null then 
			CONCAT(sum(opportunity_amount)/sum(sum(opportunity_amount)) OVER()*100,'%')
		else 0 
		end as Ratio_Success
	from 
		detail_lead_opportunity
	group by 
		lead_source, iswon
	order by 
		sum(opportunity_amount)/sum(sum(opportunity_amount)) OVER()*100 DESC,lead_source) A
where
	A.iswon = 'true';

-- query: 
-- (select 
-- 		lead_source,
-- 		sum(opportunity_amount) as Opportunity_Revenue, iswon, 
-- 		sum(sum(opportunity_amount)) OVER() as Total_Revenue,
-- 		case when 
-- 			sum(opportunity_amount) is not null then 
-- 			CONCAT(sum(opportunity_amount)/sum(sum(opportunity_amount)) OVER()*100,'%')
-- 		else 0 
-- 		end as Ratio_Success
-- 	from 
-- 		detail_lead_opportunity
-- 	group by 
-- 		lead_source, iswon
-- 	order by 
-- 		sum(opportunity_amount)/sum(sum(opportunity_amount)) OVER()*100 DESC,lead_source) A


--    Querry: tạo 1 sub query (Bảng A) lấy ra các cột: lead_source, tổng opportunity_amount đặt tên là cột Opportunity_Revenue
--    cột Total_Revenue là window function lấy tổng tất cả  opportunity_amount của bảng detail_lead_opportunity
-- case when: nếu sum(opportunity_amount)  <> rỗng thì lấy tỷ lệ % (concat để ghép ký tự %) là = Opportunity_Revenue/Total_Revenue (đặt tên là cột Ratio_Success)
-- orderby: sắp xếp theo tỷ lệ % Ratio_Success tăng dần ............
-- từ subquery là bảng A lấy ra các cột : A.lead_source, A.Opportunity_Revenue, A.Total_Revenue, A.Ratio_Success
-- với điều kiện A.iswon = 'true';
    
-- for lead_source, the most contribute source is 'Event' with 54,789 equilvalent 8.4%
-- the following is 'Inbound', then 'Sales-Outbound', then 'Marketing Site' and final is 'Field Marketing' with 0.96%
-- this ratio is calculate by dividing with total_revenue = 651,058 (including iswon = True and iswon = False)
select 
	A.lead_source, A.iswon, A.Opportunity_Revenue, A.Total_Revenue, A.Ratio_Success
from
	(select 
		lead_source,
		sum(opportunity_amount) as Opportunity_Revenue, iswon, 
		sum(sum(opportunity_amount)) OVER() as Total_Revenue,
		case when 
			sum(opportunity_amount) is not null then 
			CONCAT(sum(opportunity_amount)/sum(sum(opportunity_amount)) OVER()*100,'%')
		else 0 
		end as Ratio_Success
	from 
		detail_lead_opportunity
	group by 
		lead_source, iswon
	order by 
		sum(opportunity_amount)/sum(sum(opportunity_amount)) OVER()*100 DESC,lead_source) A
where
	A.iswon = 'false';
-- Query: tương tự câu trên, thay   A.iswon  = false để tính tỷ lệ Fail

-- the most lost source is 'Sales_Outbound' with 170,060 equilvalent 26.2%
-- the least lost source is marketing with 0.53%

select 
	lead_source,
	sum(opportunity_amount) as Opportunity_Revenue
from 
	detail_lead_opportunity
group by 
	lead_source
having 
	sum(opportunity_amount) is null;
-- Query: lấy ra 2 cột lead_source, Opportunity_Revenue = tổng opportunity_amount
-- từ bảng detail_lead_opportunity, having nghĩa là sau khi group lại theo lead_source mà có sum(opportunity_amount) là null

-- Explain: for source 'conference' + 'Other' not contribute any revenue  (value Opportunity = 0)
