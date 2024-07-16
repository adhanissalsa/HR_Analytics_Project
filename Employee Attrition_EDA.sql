SELECT *
FROM employee_attrition;

CREATE TABLE employee_attrition_staging
LIKE employee_attrition;

INSERT employee_attrition_staging
SELECT *
FROM employee_attrition;

SELECT *
FROM employee_attrition_staging;

-- 1. Which 3 departments had the highest and lowest satisfaction scores?

SELECT dept, AVG(satisfaction_level) AVG_STF
FROM employee_attrition_staging
GROUP BY dept
ORDER BY AVG_STF;

-- Departments ranking based on Average Satisfaction Level
WITH STF_DEPT (dept, AVG_STF) AS
(SELECT dept, ROUND(AVG(satisfaction_level),4) AVG_STF
FROM employee_attrition_staging
GROUP BY dept
ORDER BY AVG_STF
), STF_RANK AS
(SELECT *,
DENSE_RANK() OVER (ORDER BY AVG_STF DESC) AS Ranking
FROM STF_DEPT
WHERE dept IS NOT NULL
)
SELECT *
FROM STF_RANK;

-- Top 3 Departments with Highest Satisfaction Level
WITH STF_DEPT (dept, AVG_STF) AS
(SELECT dept, ROUND(AVG(satisfaction_level),4) AVG_STF
FROM employee_attrition_staging
GROUP BY dept
ORDER BY AVG_STF
), STF_RANK AS
(SELECT *,
DENSE_RANK() OVER (ORDER BY AVG_STF DESC) AS Ranking
FROM STF_DEPT
WHERE dept IS NOT NULL
)
SELECT *
FROM STF_RANK
WHERE Ranking <= 3;

-- Top 3 Departments with Lowest Satisfaction Level
WITH STF_DEPT (dept, AVG_STF) AS
(SELECT dept, ROUND(AVG(satisfaction_level),3) AVG_STF
FROM employee_attrition_staging
GROUP BY dept
ORDER BY AVG_STF
), STF_RANK AS
(SELECT *,
DENSE_RANK() OVER (ORDER BY AVG_STF ASC) AS Ranking
FROM STF_DEPT
WHERE dept IS NOT NULL
)
SELECT *
FROM STF_RANK
WHERE Ranking <= 3;

-- 2. What is the relationship between salary and satisfaction score?
SELECT *
FROM employee_attrition_staging;

SELECT DISTINCT salary
FROM employee_attrition_staging;

SELECT salary, ROUND(AVG(satisfaction_level),2) AVG_STF
FROM employee_attrition_staging
GROUP BY 1
ORDER BY 2;

-- The higher the salary, the higher employee satisfaction

ALTER TABLE employee_attrition_staging
RENAME COLUMN average_montly_hours TO avg_monthly_hours;

SELECT MIN(avg_monthly_hours) min_amh, MAX(avg_monthly_hours) max_amh
FROM employee_attrition_staging;

-- Low: 96 to 167
-- Medium: 168 to 238
-- High: 239 to 310

ALTER TABLE employee_attrition_staging
ADD COLUMN avg_mwh varchar(10);

UPDATE employee_attrition_staging
SET avg_mwh = 
	CASE
    WHEN avg_monthly_hours < 168 THEN 'LOW'
    WHEN avg_monthly_hours BETWEEN 168 AND 238 THEN 'MEDIUM'
    WHEN avg_monthly_hours > 238 THEN 'HIGH'
END;

ALTER TABLE employee_attrition_staging
RENAME COLUMN time_spend_company TO tenure;

-- 3. How did the depts in the top and bottom 2 satisfaction level perform in following areas:
-- top 3: 'management' , 'RandD', 'product_mng' top_dept
-- bottom 3: 'accounting' , 'hr' , 'technical' bottom_dept

SELECT
	CASE
    WHEN dept in ('management', 'RandD', 'product_mng') THEN 'top_dept'
	WHEN dept in ('accounting', 'hr', 'technical') THEN 'bottom_dept'
    END AS STF_RANK,
COUNT('Emp ID') num_empl,
round(avg(last_evaluation),3) avg_last_eval,
round(avg(number_project),2) avg_projects,
round(avg(avg_monthly_hours),2) hours_worked,
round(avg(tenure), 2) avg_tenure,
round(avg(work_accident), 2) avg_accident,
round(avg(promotion_last_5years), 2) avg_num_prom
FROM employee_attrition_staging
WHERE dept in ('management', 'RandD', 'product_mng', 'accounting', 'hr', 'technical')
GROUP BY 1;