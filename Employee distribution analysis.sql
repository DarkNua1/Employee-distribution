CREATE DATABASE projects;

USE projects;

describe human_resources;

SELECT * FROM human_resources;

alter table human_resources
change column ï»¿id emp_id varchar(20) null;

set sql_safe_updates = 0;

UPDATE human_resources
SET birthdate = CASE
    WHEN birthdate LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN birthdate LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

select birthdate from human_resources;

ALTER TABLE human_resources
MODIFY COLUMN birthdate DATE;

UPDATE human_resources
SET hire_date = CASE
    WHEN hire_date LIKE '%/%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    WHEN hire_date LIKE '%-%' THEN DATE_FORMAT(STR_TO_DATE(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    ELSE NULL
END;

select hire_date from human_resources;

ALTER TABLE human_resources
MODIFY COLUMN hire_date DATE;

UPDATE human_resources
SET termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';

UPDATE human_resources
SET termdate = NULL
WHERE termdate = '';

ALTER TABLE human_resources
MODIFY COLUMN termdate DATE;

select termdate from human_resources;

ALTER TABLE human_resources
ADD COLUMN age INT;

UPDATE human_resources
SET age = timestampdiff(YEAR, birthdate, curdate());

select birthdate, age from human_resources;



#QUESTIONS WE WANT TO ANSWER

#1. What is the genter breakdown of employees in the company?

SELECT gender, count(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate IS NULL
GROUP BY gender;

#2. What is the race/ethnicity breakdown of employees in the company?

SELECT race, count(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate IS NULL
GROUP BY race
ORDER BY count(*) DESC;

#3. What is the age distribution of employees in the company?

SELECT min(age) AS youngest, max(age) AS oldest
FROM human_resources
WHERE age >= 18 AND termdate IS NULL;

SELECT
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+'
   END AS age_group,
   count(*) AS COUNT
FROM human_resources
WHERE age >= 18 AND termdate IS NULL
GROUP BY age_group
ORDER BY age_group;   

SELECT
  CASE 
    WHEN age >= 18 AND age <= 24 THEN '18-24'
    WHEN age >= 25 AND age <= 34 THEN '25-34'
    WHEN age >= 35 AND age <= 44 THEN '35-44'
    WHEN age >= 45 AND age <= 54 THEN '45-54'
    WHEN age >= 55 AND age <= 64 THEN '55-64'
    ELSE '65+'
   END AS age_group, gender,
   count(*) AS COUNT
FROM human_resources
WHERE age >= 18 AND termdate IS NULL
GROUP BY age_group, gender
ORDER BY age_group, gender;


#4. How many employees work at the headquarters versus remote location?
  
SELECT location, count(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate IS NULL
GROUP BY location;
   
#5. What is the average lenght of employment for employees who have been terminated?

SELECT
   round(avg(datediff(termdate, hire_date))/365,0) AS avg_lenght_employment
FROM human_resources
WHERE termdate <= curdate() AND termdate IS NOT NULL  AND age >= 18;

#6. How does gender distribution vary across departments and job titles?

SELECT department, gender, count(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate IS NULL
GROUP BY department, gender
ORDER BY department;

#7. What is the distribution of job titles across the company?

SELECT jobtitle, count(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate IS NULL
GROUP BY jobtitle
ORDER BY jobtitle DESC;

#8. What department has the highest turnover rate?

SELECT department,
       total_count, 
       terminated_count, 
       terminated_count/total_count AS termination_rate
FROM (
      SELECT department, count(*) AS total_count,
        SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
         FROM human_resources
          WHERE age >= 18 
          GROUP BY department) AS termination
ORDER BY termination_rate DESC;

#9. What is the distribution of employees across locations by city and state?

SELECT location_state, count(*) AS count
FROM human_resources
WHERE age >= 18 AND termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;

#10. How many company employees count changed over time based on term and hire dates?

SELECT year,
       hires, 
       terminated_count AS terminations, 
       hires - terminated_count AS net_change,
       round((hires - terminated_count)/hires * 100, 2) AS net_change_percent
FROM (
      SELECT year(hire_date) AS year, 
             count(*) AS hires,
             SUM(CASE WHEN termdate IS NOT NULL AND termdate <= curdate() THEN 1 ELSE 0 END) AS terminated_count
      FROM human_resources
      WHERE age >= 18 
      GROUP BY year(hire_date)
     ) AS subquery
ORDER BY year ASC;

#11. What is the tenure distribution for each department?

SELECT department, round(avg(datediff(termdate, hire_date)/ 365),0) AS avg_tenure
FROM human_resources
WHERE termdate <= curdate() AND termdate IS NOT NULL  AND age >= 18
GROUP BY department;