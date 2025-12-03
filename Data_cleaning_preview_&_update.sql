-- *************************************************
-- PART 1 — DATA CLEANING PREVIEW (SAFE SELECT)
-- *************************************************

SELECT
Name
from messy_hr_data_2
WHERE Name IS NOT NULL;

SELECT age,
    CASE
        WHEN LOWER(Age) = 'nan' THEN NULL
        WHEN LOWER(Age) = 'thirty' THEN 30
        WHEN LOWER(Age) = 'twenty-five' THEN 25
        WHEN Age REGEXP '^[0-9]+$' THEN CAST(Age AS UNSIGNED)
        ELSE NULL
    END AS CleanAge
FROM messy_hr_data_2;

SELECT
    Salary AS OriginalSalary,
    CASE
        WHEN LOWER(Salary) LIKE '%nan%' THEN NULL
        WHEN UPPER(Salary) = 'SIXTY THOUSAND' THEN 60000
        WHEN Salary REGEXP '^[0-9]+$' THEN CAST(Salary AS UNSIGNED)
        ELSE NULL
    END AS CleanSalary
FROM messy_hr_data_2;

SELECT 
	CASE 
		WHEN LOWER(Gender) like 'm%' then 'Male'
		WHEN LOWER(Gender) like 'f%' then 'Famale'
		ELSE NULL 
END as genderclean
from messy_hr_data_2;

SELECT *
FROM messy_hr_data_2;

SELECT
    `Joining Date` AS OriginalDate,
    COALESCE(
        STR_TO_DATE(`Joining Date`, '%M %e, %Y'),  
        STR_TO_DATE(`Joining Date`, '%m/%d/%Y'),   
        STR_TO_DATE(`Joining Date`, '%Y/%m/%d'),   
        STR_TO_DATE(`Joining Date`, '%m-%d-%Y'),   
        STR_TO_DATE(`Joining Date`, '%Y.%m.%d')    
    ) AS CleanDate
FROM messy_hr_data_2;

SELECT Email as old_email,
case 
when Lower(Email) like 'nan%' then Null
else Email
end as new_email
from messy_hr_data_2;

SELECT
    `Phone Number` AS OriginalPhone,
    CASE
        WHEN TRIM(LOWER(`Phone Number`)) = 'nan' OR TRIM(`Phone Number`) = '' THEN NULL
        ELSE `Phone Number`
    END AS CleanPhone
FROM messy_hr_data_2;

SELECT *
from messy_hr_data_2;


-- *************************************************
-- PART 2 — APPLY CLEANING (UPDATE SQL)
-- *************************************************

-- Clean Name
UPDATE messy_hr_data_2
SET Name = CONCAT(
    UPPER(SUBSTRING(TRIM(Name), 1, 1)),
    LOWER(SUBSTRING(TRIM(Name), 2))
)
WHERE Name IS NOT NULL;

-- Clean Age
    UPDATE messy_hr_data_2
SET Age = CASE
        WHEN LOWER(Age) LIKE '%nan%' THEN NULL                 
        WHEN LOWER(Age) LIKE '%thirty%' THEN 30               
        WHEN LOWER(Age) LIKE '%twenty-five%' THEN 25          
        WHEN Age REGEXP '^[0-9]+$' THEN CAST(Age AS UNSIGNED) 
        ELSE NULL                                           
    END;
   
-- Clean Salary
UPDATE messy_hr_data_2
SET Salary = CASE
        WHEN LOWER(Salary) LIKE '%nan%' THEN NULL
        WHEN UPPER(Salary) = 'SIXTY THOUSAND' THEN 60000
        WHEN Salary REGEXP '^[0-9]+$' THEN CAST(Salary AS UNSIGNED)
        ELSE NULL
    END;

-- Clean Gender
UPDATE messy_hr_data_2
SET Gender = CASE 
		WHEN LOWER(Gender) like 'm%' then 'Male'
		WHEN LOWER(Gender) like 'f%' then 'Famale'
		ELSE NULL
	END;

-- Clean Dates
-- April 5, 2018 style
UPDATE messy_hr_data_2
SET `Joining Date` = STR_TO_DATE(`Joining Date`, '%M %e, %Y')
WHERE `Joining Date` REGEXP '^[A-Za-z]+ [0-9]{1,2}, [0-9]{4}$';

-- 01/15/2020 style
UPDATE messy_hr_data_2
SET `Joining Date` = STR_TO_DATE(`Joining Date`, '%m/%d/%Y')
WHERE `Joining Date` REGEXP '^[0-9]{2}/[0-9]{2}/[0-9]{4}$';

-- 2020/02/20 style
UPDATE messy_hr_data_2
SET `Joining Date` = STR_TO_DATE(`Joining Date`, '%Y/%m/%d')
WHERE `Joining Date` REGEXP '^[0-9]{4}/[0-9]{2}/[0-9]{2}$';

-- 03-25-2019 style
UPDATE messy_hr_data_2
SET `Joining Date` = STR_TO_DATE(`Joining Date`, '%m-%d-%Y')
WHERE `Joining Date` REGEXP '^[0-9]{2}-[0-9]{2}-[0-9]{4}$';

-- 2019.12.01 style
UPDATE messy_hr_data_2
SET `Joining Date` = STR_TO_DATE(`Joining Date`, '%Y.%m.%d')
WHERE `Joining Date` REGEXP '^[0-9]{4}\\.[0-9]{2}\\.[0-9]{2}$';

-- Clean Email 
UPDATE messy_hr_data_2
SET Email = case 
WHEN Lower(Email) like 'nan%' then Null
ELSE Email
END;

-- Clean Phone Number
UPDATE messy_hr_data_2
SET `Phone Number` = CASE
        WHEN TRIM(LOWER(`Phone Number`)) = 'nan' OR TRIM(`Phone Number`) = '' THEN NULL
        ELSE `Phone Number`
    END;

-- Altering Data Type
ALTER TABLE messy_hr_data_2
MODIFY Name VARCHAR(100);

ALTER TABLE messy_hr_data_2
MODIFY `Age` INT;

ALTER TABLE messy_hr_data_2
MODIFY `Salary` INT;

ALTER TABLE messy_hr_data_2
MODIFY Gender VARCHAR(100);

ALTER TABLE messy_hr_data_2
MODIFY Department VARCHAR(100);

ALTER TABLE messy_hr_data_2
MODIFY `Position` VARCHAR(100);

ALTER TABLE messy_hr_data_2
MODIFY `Joining Date` DATE;

ALTER TABLE messy_hr_data_2
MODIFY `Performance Score` VARCHAR(100);

ALTER TABLE messy_hr_data_2
MODIFY Email VARCHAR(100);

ALTER TABLE messy_hr_data_2
MODIFY `Phone Number` VARCHAR(100);

-- Checking and Removing Duplicates
with messy_data_cte as
	(
    select *, row_number() over(
    partition by `Name`, Age, Salary, Department, `Position`, `Joining Date`, `Performance Score`, Email, `Phone Number`) as row_num
    from messy_hr_data_2
    )
SELECT *
from messy_data_cte
where row_num > 1;


-- Original Data is "messy_hr_data"
-- Duplicate Data is "messy_hr_data_2"


