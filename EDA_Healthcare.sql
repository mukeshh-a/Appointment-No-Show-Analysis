-- Performing EDA on Healthcare Dataset

-- Lets look at the data to start with.
SELECT * FROM Healthcare

-- Lets see how big our dataset is.
SELECT COUNT (*) FROM Healthcare

SELECT COUNT(*) AS row_count, COUNT(*) AS col_count FROM healthcare;


-- Get the data type of each column

SELECT COLUMN_NAME, DATA_TYPE FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'healthcare';

-- Change the names of columns which are misspelled and not in sync with other name formats
EXEC sp_rename 'Healthcare.Hipertension', 'Hypertension', 'COLUMN';
EXEC sp_rename 'Healthcare.Handcap', 'Handicap', 'COLUMN';
EXEC sp_rename 'Healthcare.SMS_received', 'SMSReceived', 'COLUMN';
EXEC sp_rename 'Healthcare.No-show', 'NoShow', 'COLUMN';

SELECT * FROM Healthcare

-- Standardizing the date format

SELECT AppointmentDay, CONVERT(date, AppointmentDay) AS AppointmentDate
FROM Healthcare

update Healthcare
set AppointmentDay = CONVERT(date, AppointmentDay)

SELECT ScheduledDay, CONVERT(date, ScheduledDay) AS ScheduledDate
FROM Healthcare

update Healthcare
set ScheduledDay = CONVERT(date, ScheduledDay)

SELECT * FROM Healthcare

-- Changine the column names with more logical names

EXEC sp_rename 'Healthcare.ScheduledDay', 'ScheduledDate', 'COLUMN';
EXEC sp_rename 'Healthcare.AppointmentDay', 'AppointmentDate', 'COLUMN';

SELECT * FROM Healthcare

-- Summary statistics for the Age column
SELECT  MIN(Age) AS min_age, 
		MAX(Age) AS max_age, 
		AVG(Age) AS avg_age, 
		STDEV(Age) AS std_age 
FROM healthcare;

-- Median age of Patients

SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Age) OVER () as median_age
FROM healthcare;

-- Patience with age 0

SELECT COUNT(*) as count
FROM healthcare
WHERE Age = 0;


-- Get the Null values

SELECT *
FROM Healthcare
WHERE PatientId IS NULL
or AppointmentID IS NULL
or [ScheduledDate] IS NULL
or [AppointmentDate] IS NULL
or [Age]  IS NULL
or [Neighbourhood] IS NULL
or [Scholarship] IS NULL
or [Hypertension] IS NULL
or [Diabetes] IS NULL
or [Alcoholism]  IS NULL
or [Handicap] IS NULL
or [SMSReceived] IS NULL
or [NoShow] IS NULL
or [Appointmentday] IS NULL
or [Scheduledday] IS NULL

-- Getting weekday from Appointment Date
ALTER TABLE Healthcare ADD AppointmentDay VARCHAR(10);

UPDATE [dbo].[healthcare]
SET AppointmentDay = 
    CASE DATEPART(weekday, [AppointmentDate])
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END;

SELECT * FROM Healthcare  

-- Getting weekday from Scheduled Date

ALTER TABLE Healthcare ADD Scheduledday VARCHAR(10);

UPDATE Healthcare
SET Scheduledday = 
    CASE DATEPART(weekday, ScheduledDate)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END;

SELECT * FROM Healthcare

-- Number of Appointments on each day

SELECT Appointmentday, COUNT(*) AS appointments_on_the_day
FROM Healthcare
GROUP BY Appointmentday
ORDER BY Appointmentday DESC

-- Which day has the most Appointments?

SELECT TOP 1 Appointmentday, COUNT(*) AS appointments_on_the_day 
FROM Healthcare 
GROUP BY Appointmentday 
ORDER BY Appointmentday DESC;

-- percentage of appointments by day of the week
SELECT AppointmentDay, 
COUNT(*)*100.0/SUM(COUNT(*)) OVER() AS percentage 
FROM healthcare 
GROUP BY AppointmentDay 
ORDER BY AppointmentDay;

-- Gender-wise appointment 

SELECT Gender, COUNT(*) as count
FROM healthcare
GROUP BY Gender;

-- Check the number of appointments by neighbourhood

SELECT Neighbourhood, COUNT(*) AS count 
FROM healthcare 
GROUP BY Neighbourhood 
ORDER BY count DESC;

-- Number of appointments by Scholarship status

SELECT Scholarship, COUNT(*) AS count 
FROM healthcare 
GROUP BY Scholarship;

-- number of appointments by Hypertension status

SELECT Hypertension, COUNT(*) AS count 
FROM healthcare 
GROUP BY Hypertension;

-- number of appointments by Diabetes status

SELECT Diabetes, COUNT(*) AS count 
FROM healthcare 
GROUP BY Diabetes;

-- number of appointments by Alcoholism status

SELECT Alcoholism, COUNT(*) AS count 
FROM healthcare 
GROUP BY Alcoholism;

-- number of appointments by Handicap status

SELECT Handicap, COUNT(*) AS count 
FROM healthcare 
GROUP BY Handicap
ORDER BY Handicap;

-- Number of appointments by age group

SELECT age_group, COUNT(*) AS count
FROM (
    SELECT CASE
        WHEN Age < 18 THEN '0-17'
        WHEN Age < 35 THEN '18-34'
        WHEN Age < 50 THEN '35-49'
        WHEN Age < 65 THEN '50-64'
        ELSE '65+'
        END AS age_group, Age
    FROM healthcare
) subquery
GROUP BY age_group
ORDER BY age_group;

-- average age of patients by gender

SELECT Gender, AVG(Age) AS avg_age 
FROM healthcare 
GROUP BY Gender;

-- average age of patients by neighbourhood

SELECT Neighbourhood, AVG(Age) AS avg_age 
FROM healthcare 
GROUP BY Neighbourhood 
ORDER BY avg_age DESC;

-- Getting the NoShow count

SELECT [NoShow], COUNT(*) AS Count
FROM Healthcare
GROUP BY NoShow

-- Percentage of missed appointments

SELECT COUNT(CASE 
				WHEN NoShow = 'Yes' THEN 1 
				ELSE NULL 
				END)*100.0/COUNT(*) AS percentage
FROM healthcare;

-- Percentage of missed appointments by scholarship status

SELECT Scholarship, COUNT(CASE WHEN NoShow = 'Yes' THEN 1 ELSE NULL END)*100.0/COUNT(*) AS percentage
FROM healthcare
GROUP BY Scholarship;

-- average age of patients who showed up and who did not show up

SELECT 
CASE WHEN NoShow = 'No' THEN 'Showed up' 
ELSE 'Did not show up' END AS appointment_status, 
AVG(Age) AS avg_age 
FROM healthcare 
GROUP BY NoShow;

-- Number of appointments per patient

SELECT PatientId, COUNT(*) AS num_appointments 
FROM healthcare 
GROUP BY PatientId 
ORDER BY num_appointments DESC;

-- Percentage of appointments where the patient received an SMS notification and showed up

SELECT SMSReceived, COUNT(CASE WHEN NoShow = 'No' THEN 1 ELSE NULL END)*100.0/COUNT(*) AS percentage
FROM healthcare
GROUP BY SMSReceived;

-- Proportion of appointments where the patient showed up and had a scholarship by neighbourhood

SELECT Neighbourhood, COUNT(*) AS num_appointments, 
       SUM(CASE WHEN NoShow = 'No' AND Scholarship = 1 THEN 1 
	   ELSE 0 
	   END)*100.0/COUNT(*) AS percentage
FROM healthcare 
GROUP BY Neighbourhood 
ORDER BY percentage DESC;

-- Proportion of appointments where the patient showed up and had diabetes by gender 

SELECT Gender, COUNT(*) AS num_appointments, 
       SUM(CASE 
	   WHEN NoShow = 'No' AND Diabetes = 1 THEN 1 
	   ELSE 0 
	   END)*100.0/COUNT(*) AS percentage
FROM healthcare 
GROUP BY Gender 
ORDER BY percentage DESC;

-- proportion of appointments where the patient showed up and had hypertension

SELECT COUNT(*) AS num_appointments, 
       SUM(CASE WHEN NoShow = 'No' AND Hypertension = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*) AS percentage
FROM healthcare;

-- proportion of appointments where the patient showed up and had alcoholism by neighbourhood

SELECT Neighbourhood, COUNT(*) AS num_appointments, 
       SUM(CASE WHEN NoShow = 'No' AND Alcoholism = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*) AS percentage
FROM healthcare 
GROUP BY Neighbourhood 
ORDER BY percentage DESC;

-- Count of appointments where the patient showed up and had alcoholism, hypertension, disability and diabetes

SELECT COUNT(*) AS num_appointments, 
       COUNT(CASE WHEN NoShow = 'No' AND Alcoholism = 1 THEN 1 ELSE NULL END) AS num_alcoholism,
       COUNT(CASE WHEN NoShow = 'No' AND Hypertension = 1 THEN 1 ELSE NULL END) AS num_hypertension,
       COUNT(CASE WHEN NoShow = 'No' AND Handicap > 0 THEN 1 ELSE NULL END) AS num_disability,
       COUNT(CASE WHEN NoShow = 'No' AND Diabetes = 1 THEN 1 ELSE NULL END) AS num_diabetes
FROM healthcare;

-- Count of appointments where the patient showed up and had alcoholism, hypertension, disability and diabetes on every weekday

SELECT AppointmentDay, 
       COUNT(CASE WHEN NoShow = 'No' AND Alcoholism = 1 THEN 1 ELSE NULL END) AS num_alcoholism, 
       COUNT(CASE WHEN NoShow = 'No' AND Hypertension = 1 THEN 1 ELSE NULL END) AS num_hypertension, 
       COUNT(CASE WHEN NoShow = 'No' AND Handicap > 0 THEN 1 ELSE NULL END) AS num_disability, 
       COUNT(CASE WHEN NoShow = 'No' AND Diabetes = 1 THEN 1 ELSE NULL END) AS num_diabetes
FROM healthcare
WHERE NoShow = 'No'
GROUP BY AppointmentDay;

-- Percentage of appointments where the patient showed up and had each condition

SELECT 
    COUNT(CASE WHEN NoShow = 'No' AND Hypertension = 1 THEN 1 ELSE NULL END)*100.0/COUNT(*) as percentage_hypertension,
    COUNT(CASE WHEN NoShow = 'No' AND Diabetes = 1 THEN 1 ELSE NULL END)*100.0/COUNT(*) as percentage_diabetes,
    COUNT(CASE WHEN NoShow = 'No' AND Alcoholism = 1 THEN 1 ELSE NULL END)*100.0/COUNT(*) as percentage_alcoholism,
    COUNT(CASE WHEN NoShow = 'No' AND Handicap > 0 THEN 1 ELSE NULL END)*100.0/COUNT(*) as percentage_disability
FROM healthcare;

-- Number of patient with or without each condition

SELECT 
    COUNT(CASE WHEN Hypertension = 1 THEN 1 ELSE NULL END) as num_hypertension,
    COUNT(CASE WHEN Diabetes = 1 THEN 1 ELSE NULL END) as num_diabetes,
    COUNT(CASE WHEN Alcoholism = 1 THEN 1 ELSE NULL END) as num_alcoholism,
    COUNT(CASE WHEN Handicap > 0 THEN 1 ELSE NULL END) as num_disability,
    COUNT(CASE WHEN Scholarship = 1 THEN 1 ELSE NULL END) as num_scholarship,
    COUNT(*) as total_count
FROM healthcare;

-- Number of appointments by day of the week and whether the scheduled date was after the appointment date

SELECT AppointmentDay,
       CASE WHEN ScheduledDate > AppointmentDate THEN 'Scheduled after' 
	   ELSE 'Scheduled before' END AS scheduled_status,
       COUNT(*) AS num_appointments
FROM healthcare
GROUP BY AppointmentDay, 
CASE WHEN ScheduledDate > AppointmentDate THEN 'Scheduled after' 
ELSE 'Scheduled before' END
ORDER BY AppointmentDay;
