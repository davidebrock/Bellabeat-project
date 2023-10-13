-- Declaring and Setting Variables that will be used later in the analysis

DECLARE MORNING, AFTERNOON, EVENING, NIGHT INT64;
SET MORNING = 6;
SET AFTERNOON = 12;
SET EVENING = 18;
SET NIGHT = 21;

--------------------------------------
-- Cleaning and Processing the Data --
--------------------------------------

-- Some of the data imported from CSV has a known datatype syntax error that prevented it from being imported as datetime. The two methods that I can use to convert the string containing the datetime information into datetime would be creating a temp table or creating a function to call when the needed data will be used. I chose to use the function method to prevent too many lines of code from being needed in addition to saving space on the database.

CREATE OR REPLACE FUNCTION `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(datetimeString STRING) AS (
  CAST(PARSE_DATETIME('%m/%d/%Y %I:%M:%S %p', datetimeString) AS DATETIME)
);


-- After becoming familiar with the datasets, I want to first confirm that the ID for each dataset is the same type.

SELECT
  table_name,
  column_name,
  data_type
FROM
  `wellness-bellabeat.fitbit_data.INFORMATION_SCHEMA.COLUMNS`
WHERE
  column_name = "Id";

-- It is important to note which of the tables have the Id data_type as NUMERIC while others have it as INT64.

-- Next, I want to confirm that my function is working properly for when I need to utilize the datetime of any table.

SELECT 
  Id,
  `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(Time) AS ParsedActivityMinute,
  Value
FROM `wellness-bellabeat.fitbit_data.heartrate`;

-- I can confirm the function works for when it needs to be referenced. I will now confirm that two tables can be joined using the function.

SELECT
  da.Id,
  da.ActivityDate,
  da.TotalSteps,
  da.Calories,
  AVG(CAST(heartrate.Value AS NUMERIC)) AS AverageHeartrate
FROM
  `wellness-bellabeat.fitbit_data.daily_activity` AS da
JOIN
  `wellness-bellabeat.fitbit_data.heartrate` AS heartrate
ON
  da.Id = CAST(heartrate.Id AS INT64)
  AND DATE(da.ActivityDate) = `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(heartrate.Time)
GROUP BY
  da.Id,
  da.ActivityDate,
  da.TotalSteps,
  da.Calories
ORDER BY
  1, 2;



----------------------
-- Analysis of Data --
----------------------

-- Counting how many users tracked activity and how many also tracked heartrate and comparing their calories burned and intensities

WITH ActivityHeartrate AS (
  SELECT
    da.Id,
    da.ActivityDate,
    da.TotalSteps,
    da.Calories,
    AVG(CAST(heartrate.Value AS NUMERIC)) AS AverageHeartrate
  FROM
    `wellness-bellabeat.fitbit_data.daily_activity` AS da
  LEFT JOIN
    `wellness-bellabeat.fitbit_data.heartrate` AS heartrate
  ON
    da.Id = CAST(heartrate.Id AS INT64)
    AND DATE(da.ActivityDate) = `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(heartrate.Time)
  GROUP BY
    da.Id,
    da.ActivityDate,
    da.TotalSteps,
    da.Calories
)

SELECT
  COUNT(DISTINCT Id) AS TotalUniqueIds,
  COUNT(DISTINCT CASE WHEN AverageHeartrate IS NOT NULL THEN Id END) AS UniqueIdsWithHeartRate,
  COUNT(DISTINCT CASE WHEN AverageHeartrate IS NOT NULL THEN Id END)/COUNT(DISTINCT Id)*100 AS PercentWithHeartrate
FROM
  ActivityHeartrate;
-- This table will be exported for visualization.


--Comparing Data of users with heartrate tracking and without heartrate tracking
WITH ActivityHeartrate2 AS (
  SELECT
    da.Id,
    da.ActivityDate AS ActivityDate,
    da.TotalSteps AS TotalSteps,
    da.Calories AS Calories,
    da.TotalDistance AS TotalDistance,
    da.TrackerDistance AS TrackerDistance,
    da.LoggedActivitiesDistance AS LoggedActivitiesDistance,
    da.VeryActiveDistance AS VeryActiveDistance,
    da.ModeratelyActiveDistance AS ModeratelyActiveDistance,
    da.LightActiveDistance AS LightActiveDistance,
    da.SedentaryActiveDistance AS SedentaryActiveDistance,
    da.VeryActiveMinutes AS VeryActiveMinutes,
    da.FairlyActiveMinutes AS FairlyActiveMinutes,
    da.LightlyActiveMinutes AS LightlyActiveMinutes,
    da.SedentaryMinutes AS SedentaryMinutes,
    AVG(CAST(heartrate.Value AS NUMERIC)) AS AverageHeartrate
  FROM
    `wellness-bellabeat.fitbit_data.daily_activity` AS da
  LEFT JOIN
    `wellness-bellabeat.fitbit_data.heartrate` AS heartrate
  ON
    da.Id = CAST(heartrate.Id AS INT64)
    AND DATE(da.ActivityDate) = `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(heartrate.Time)
  GROUP BY
    da.Id,
    da.ActivityDate,
    da.TotalSteps,
    da.Calories,
    da.TotalDistance,
    da.TrackerDistance,
    da.LoggedActivitiesDistance,
    da.VeryActiveDistance,
    da.ModeratelyActiveDistance,
    da.LightActiveDistance,
    da.SedentaryActiveDistance,
    da.VeryActiveMinutes,
    da.FairlyActiveMinutes,
    da.LightlyActiveMinutes,
    da.SedentaryMinutes
)

SELECT 'With Heartrate' AS Category,
       COUNT(CASE WHEN AverageHeartrate IS NOT NULL THEN Id END) AS TotalUniqueIds,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN Calories END) AS AvgCalories,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN TotalDistance END) AS AvgTotalDistance,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN TrackerDistance END) AS AvgTrackerDistance,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN LoggedActivitiesDistance END) AS AvgLoggedActivitiesDistance,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN VeryActiveDistance END) AS AvgVeryActiveDistance,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN ModeratelyActiveDistance END) AS AvgModeratelyActiveDistance,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN LightActiveDistance END) AS AvgLightActiveDistance,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN SedentaryActiveDistance END) AS AvgSedentaryActiveDistance,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN VeryActiveMinutes END) AS AvgVeryActiveMinutes,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN FairlyActiveMinutes END) AS AvgFairlyActiveMinutes,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN LightlyActiveMinutes END) AS AvgLightlyActiveMinutes,
       AVG(CASE WHEN AverageHeartrate IS NOT NULL THEN SedentaryMinutes END) AS AvgSedentaryMinutes
FROM ActivityHeartrate2
UNION ALL
SELECT 'Without Heartrate' AS Category,
       COUNT(CASE WHEN AverageHeartrate IS NULL THEN Id END) AS TotalUniqueIds,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN Calories END) AS AvgCalories,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN TotalDistance END) AS AvgTotalDistance,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN TrackerDistance END) AS AvgTrackerDistance,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN LoggedActivitiesDistance END) AS AvgLoggedActivitiesDistance,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN VeryActiveDistance END) AS AvgVeryActiveDistance,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN ModeratelyActiveDistance END) AS AvgModeratelyActiveDistance,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN LightActiveDistance END) AS AvgLightActiveDistance,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN SedentaryActiveDistance END) AS AvgSedentaryActiveDistance,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN VeryActiveMinutes END) AS AvgVeryActiveMinutes,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN FairlyActiveMinutes END) AS AvgFairlyActiveMinutes,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN LightlyActiveMinutes END) AS AvgLightlyActiveMinutes,
       AVG(CASE WHEN AverageHeartrate IS NULL THEN SedentaryMinutes END) AS AvgSedentaryMinutes
FROM ActivityHeartrate2;
-- This table will be exported for visualization.


-- Only 30% of unique users tracked heartrate during workouts.
-- On Average on days that a heartrate tracker was used, users burned 124 more calories, had a higher total distance by 0.4 miles, and were more active per day with being sedentary for nearly 5 hours less than on days a heartrate tracker was not worn.
-- Wearing a heartrate tracker appears to increase activity and calories burned in users.


--  Next let's look at the days of the week and hours throughout the day to see when the most workouts take place.


-- ANALYZING ACTIVITY BY DAY OF WEEK AND TIME OF DAY

SELECT
--  Id,
  FORMAT_TIMESTAMP("%A", `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(ActivityHour)) AS day_of_week,
  FORMAT_TIMESTAMP("%H", `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(ActivityHour)) AS hour_of_day,
  SUM(TotalIntensity) AS total_intensity,
  SUM(AverageIntensity) AS total_average_intensity,
  AVG(AverageIntensity) AS average_intensity,
  MAX(AverageIntensity) AS max_intensity,
  MIN(AverageIntensity) AS min_intensity,
  FORMAT_TIMESTAMP("%w", `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(ActivityHour)) AS dow_number
FROM
  `wellness-bellabeat.fitbit_data.hourly_intensities`
GROUP BY
--  Id,
  dow_number,
  day_of_week,
  hour_of_day
ORDER BY
  dow_number,
  hour_of_day;
-- This table will be exported for visualization.

-- Declaring and setting variables for time of day/ day of week analyses to break time into four common segments of Morning, Afternoon, Evening, Night

SELECT
--  Id,
  FORMAT_TIMESTAMP("%A", `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(ActivityHour)) AS day_of_week,
  CASE
     WHEN TIME(`wellness-bellabeat.fitbit_data.ParseCustomDateTime`(ActivityHour)) BETWEEN TIME(MORNING, 0, 0) AND TIME(AFTERNOON, 0, 0) THEN "Morning"
     WHEN TIME(`wellness-bellabeat.fitbit_data.ParseCustomDateTime`(ActivityHour)) BETWEEN TIME(AFTERNOON, 0, 0) AND TIME(EVENING, 0, 0) THEN "Afternoon"
     WHEN TIME(`wellness-bellabeat.fitbit_data.ParseCustomDateTime`(ActivityHour)) BETWEEN TIME(EVENING, 0, 0) AND TIME(NIGHT, 0, 0) THEN "Evening"
     WHEN TIME(`wellness-bellabeat.fitbit_data.ParseCustomDateTime`(ActivityHour)) >= TIME(NIGHT, 0, 0) OR TIME(TIMESTAMP_TRUNC(`wellness-bellabeat.fitbit_data.ParseCustomDateTime`(ActivityHour), MINUTE)) <= TIME(MORNING, 0, 0) THEN "Night"
   ELSE
   "ERROR"
 END
   AS time_of_day,
  SUM(TotalIntensity) AS total_intensity,
  SUM(AverageIntensity) AS total_average_intensity,
  AVG(AverageIntensity) AS average_intensity,
  MAX(AverageIntensity) AS max_intensity,
  MIN(AverageIntensity) AS min_intensity,
  FORMAT_TIMESTAMP("%w", `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(ActivityHour)) AS dow_number
FROM
  `wellness-bellabeat.fitbit_data.hourly_intensities`
GROUP BY
--  Id,
  dow_number,
  day_of_week,
  time_of_day
ORDER BY
  dow_number,
  CASE
   WHEN time_of_day = "Morning" THEN 0
   WHEN time_of_day = "Afternoon" THEN 1
   WHEN time_of_day = "Evening" THEN 2
   WHEN time_of_day = "Night" THEN 3
  END;
-- This table will be exported for visualization.

-- The most active time of day on average is the afternoon of each day with the exception of thursday. However, the difference between morning and afternoon workouts is minimal when compared to the amount of workouts in the evening and night.
-- The peak workout times during the week are in the 17-19 hours Sun-Fri, and between the lunchtime hours of 11-14 on Saturday.

-- Last, let's look at the sleep data and compare it to daily activity.

SELECT
  MIN(TotalMinutesAsleep) AS MinTotalMinutesAsleep,
  MAX(TotalMinutesAsleep) AS MaxTotalMinutesAsleep,
  AVG(TotalMinutesAsleep) AS AvgTotalMinutesAsleep
FROM
  `wellness-bellabeat.fitbit_data.sleep_day`;

-- The minimum time asleep is 58 minutes (Less than 1 hour)
-- The maximum time asleep is 796 minutes. (Over 13 hours)
-- The average time asleep is 419.46 minutes (Around 7 hours)
-- NIH says that adults should get between 7 and 9 hours of sleep per night.

-- Let's see how the sleep records compare to the reccomendations.
SELECT
  COUNT(CASE WHEN TotalMinutesAsleep >= 540 THEN TotalMinutesAsleep END) AS LongestSleeps, -- 9 hours of sleep or more 
  COUNT(CASE WHEN TotalMinutesAsleep >= 420 AND TotalMinutesAsleep <540 THEN TotalMinutesAsleep END) AS RecommendedSleeps, -- Between 7 and 9 hours of sleep 
  COUNT(CASE WHEN TotalMinutesAsleep < 420 THEN TotalMinutesAsleep END) AS ShortestSleeps, -- Less than 7 hours of sleep 
FROM
  `wellness-bellabeat.fitbit_data.sleep_day`;

-- The majority of users met the NIH recommended amount of sleep each. However, nearly the same amount of individuals also slept for less than recommended.
-- Let's see how the amount of sleep influences daily activity.
-- Comparing how sleep trends are influenced by activity
-- This section also showcases how to aggregate data similar to the heartrate table above but using the WHERE statement instead of including CASE in each statement per line.

WITH SleepActivity AS
(
SELECT
  da.Id,
  da.ActivityDate,
  da.TotalSteps,
  da.TotalDistance,
  da.Calories,
  da.TrackerDistance,
  da.LoggedActivitiesDistance,
  da.VeryActiveDistance,
  da.ModeratelyActiveDistance,
  da.LightActiveDistance,
  da.SedentaryActiveDistance,
  da.VeryActiveMinutes,
  da.FairlyActiveMinutes,
  da.LightlyActiveMinutes,
  da.SedentaryMinutes,
  sd.TotalSleepRecords,
  sd.TotalMinutesAsleep,
  sd.TotalTimeInBed
FROM
  `wellness-bellabeat.fitbit_data.daily_activity` AS da
JOIN `wellness-bellabeat.fitbit_data.sleep_day` AS sd
  ON da.Id = sd.Id
    AND da.ActivityDate = `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(sd.SleepDay)
)

SELECT 'Under 7' AS HoursOfSleep,
  AVG(TotalSteps) AS AverageDailySteps,
  AVG(Calories) AS AverageCalories,
  AVG(TotalDistance) AS AverageDailyDistance,
  AVG(VeryActiveDistance) AS AverageVeryActiveDistance,
  AVG(ModeratelyActiveDistance) AS AverageModeratelyActiveDistance,
  AVG(LightActiveDistance) AS AverageLightActiveDistance,
  AVG(SedentaryActiveDistance) AS AverageSedentaryActiveDistance,
  AVG(VeryActiveMinutes) AS AverageVeryActiveMinutes,
  AVG(FairlyActiveMinutes) AS AverageFairlyActiveMinutes,
  AVG(LightlyActiveMinutes) AS AverageLightlyActiveMinutes,
  AVG(SedentaryMinutes) AS AverageSedentaryMinutes,
  AVG(TotalTimeInBed) AS AverageTotalTimeInBed
FROM SleepActivity
WHERE TotalMinutesAsleep < 420
UNION ALL
SELECT 'Between 7-9' AS HoursOfSleep,
  AVG(TotalSteps) AS AverageDailySteps,
  AVG(Calories) AS AverageCalories,
  AVG(TotalDistance) AS AverageDailyDistance,
  AVG(VeryActiveDistance) AS AverageVeryActiveDistance,
  AVG(ModeratelyActiveDistance) AS AverageModeratelyActiveDistance,
  AVG(LightActiveDistance) AS AverageLightActiveDistance,
  AVG(SedentaryActiveDistance) AS AverageSedentaryActiveDistance,
  AVG(VeryActiveMinutes) AS AverageVeryActiveMinutes,
  AVG(FairlyActiveMinutes) AS AverageFairlyActiveMinutes,
  AVG(LightlyActiveMinutes) AS AverageLightlyActiveMinutes,
  AVG(SedentaryMinutes) AS AverageSedentaryMinutes,
  AVG(TotalTimeInBed) AS AverageTotalTimeInBed
FROM SleepActivity
WHERE TotalMinutesAsleep >= 420 AND TotalMinutesAsleep < 540
UNION ALL
SELECT 'Above 9' AS HoursOfSleep,
  AVG(TotalSteps) AS AverageDailySteps,
  AVG(Calories) AS AverageCalories,
  AVG(TotalDistance) AS AverageDailyDistance,
  AVG(VeryActiveDistance) AS AverageVeryActiveDistance,
  AVG(ModeratelyActiveDistance) AS AverageModeratelyActiveDistance,
  AVG(LightActiveDistance) AS AverageLightActiveDistance,
  AVG(SedentaryActiveDistance) AS AverageSedentaryActiveDistance,
  AVG(VeryActiveMinutes) AS AverageVeryActiveMinutes,
  AVG(FairlyActiveMinutes) AS AverageFairlyActiveMinutes,
  AVG(LightlyActiveMinutes) AS AverageLightlyActiveMinutes,
  AVG(SedentaryMinutes) AS AverageSedentaryMinutes,
  AVG(TotalTimeInBed) AS AverageTotalTimeInBed
FROM SleepActivity
WHERE TotalMinutesAsleep >= 540
ORDER BY
  CASE
    WHEN HoursOfSleep = "Under 7" THEN 0
    WHEN HoursOfSleep = "Between 7-9" THEN 1
    WHEN HoursOfSleep = "Above 9" THEN 2
  END;

-- It appears that oversleeping has the largest negative impact on daily activity with every value relating to activity.
-- Under 7 hours of sleep appears to be the best for activity, however, this may be skewed by data that is close to 7 hours but not quite that amount. Let's re-run this but with the ideal sleep ranging between 6 and 9 hours of sleep instead of 7 to 9 hours.

WITH SleepActivity AS
(
SELECT
  da.Id,
  da.ActivityDate,
  da.TotalSteps,
  da.TotalDistance,
  da.Calories,
  da.TrackerDistance,
  da.LoggedActivitiesDistance,
  da.VeryActiveDistance,
  da.ModeratelyActiveDistance,
  da.LightActiveDistance,
  da.SedentaryActiveDistance,
  da.VeryActiveMinutes,
  da.FairlyActiveMinutes,
  da.LightlyActiveMinutes,
  da.SedentaryMinutes,
  sd.TotalSleepRecords,
  sd.TotalMinutesAsleep,
  sd.TotalTimeInBed
FROM
  `wellness-bellabeat.fitbit_data.daily_activity` AS da
JOIN `wellness-bellabeat.fitbit_data.sleep_day` AS sd
  ON da.Id = sd.Id
    AND da.ActivityDate = `wellness-bellabeat.fitbit_data.ParseCustomDateTime`(sd.SleepDay)
)

SELECT 'Under 5' AS HoursOfSleep,
  AVG(TotalSteps) AS AverageDailySteps,
  AVG(Calories) AS AverageCalories,
  AVG(TotalDistance) AS AverageDailyDistance,
  AVG(VeryActiveDistance) AS AverageVeryActiveDistance,
  AVG(ModeratelyActiveDistance) AS AverageModeratelyActiveDistance,
  AVG(LightActiveDistance) AS AverageLightActiveDistance,
  AVG(SedentaryActiveDistance) AS AverageSedentaryActiveDistance,
  AVG(VeryActiveMinutes) AS AverageVeryActiveMinutes,
  AVG(FairlyActiveMinutes) AS AverageFairlyActiveMinutes,
  AVG(LightlyActiveMinutes) AS AverageLightlyActiveMinutes,
  AVG(SedentaryMinutes) AS AverageSedentaryMinutes,
  AVG(TotalTimeInBed) AS AverageTotalTimeInBed
FROM SleepActivity
WHERE TotalMinutesAsleep < 300
UNION ALL
SELECT 'Between 5-7' AS HoursOfSleep,
  AVG(TotalSteps) AS AverageDailySteps,
  AVG(Calories) AS AverageCalories,
  AVG(TotalDistance) AS AverageDailyDistance,
  AVG(VeryActiveDistance) AS AverageVeryActiveDistance,
  AVG(ModeratelyActiveDistance) AS AverageModeratelyActiveDistance,
  AVG(LightActiveDistance) AS AverageLightActiveDistance,
  AVG(SedentaryActiveDistance) AS AverageSedentaryActiveDistance,
  AVG(VeryActiveMinutes) AS AverageVeryActiveMinutes,
  AVG(FairlyActiveMinutes) AS AverageFairlyActiveMinutes,
  AVG(LightlyActiveMinutes) AS AverageLightlyActiveMinutes,
  AVG(SedentaryMinutes) AS AverageSedentaryMinutes,
  AVG(TotalTimeInBed) AS AverageTotalTimeInBed
FROM SleepActivity
WHERE TotalMinutesAsleep >= 300 AND TotalMinutesAsleep <420
UNION ALL
SELECT 'Between 7-9' AS HoursOfSleep,
  AVG(TotalSteps) AS AverageDailySteps,
  AVG(Calories) AS AverageCalories,
  AVG(TotalDistance) AS AverageDailyDistance,
  AVG(VeryActiveDistance) AS AverageVeryActiveDistance,
  AVG(ModeratelyActiveDistance) AS AverageModeratelyActiveDistance,
  AVG(LightActiveDistance) AS AverageLightActiveDistance,
  AVG(SedentaryActiveDistance) AS AverageSedentaryActiveDistance,
  AVG(VeryActiveMinutes) AS AverageVeryActiveMinutes,
  AVG(FairlyActiveMinutes) AS AverageFairlyActiveMinutes,
  AVG(LightlyActiveMinutes) AS AverageLightlyActiveMinutes,
  AVG(SedentaryMinutes) AS AverageSedentaryMinutes,
  AVG(TotalTimeInBed) AS AverageTotalTimeInBed
FROM SleepActivity
WHERE TotalMinutesAsleep >= 420 AND TotalMinutesAsleep < 540
UNION ALL
SELECT 'Above 9' AS HoursOfSleep,
  AVG(TotalSteps) AS AverageDailySteps,
  AVG(Calories) AS AverageCalories,
  AVG(TotalDistance) AS AverageDailyDistance,
  AVG(VeryActiveDistance) AS AverageVeryActiveDistance,
  AVG(ModeratelyActiveDistance) AS AverageModeratelyActiveDistance,
  AVG(LightActiveDistance) AS AverageLightActiveDistance,
  AVG(SedentaryActiveDistance) AS AverageSedentaryActiveDistance,
  AVG(VeryActiveMinutes) AS AverageVeryActiveMinutes,
  AVG(FairlyActiveMinutes) AS AverageFairlyActiveMinutes,
  AVG(LightlyActiveMinutes) AS AverageLightlyActiveMinutes,
  AVG(SedentaryMinutes) AS AverageSedentaryMinutes,
  AVG(TotalTimeInBed) AS AverageTotalTimeInBed
FROM SleepActivity
WHERE TotalMinutesAsleep >= 540
ORDER BY
  CASE
    WHEN HoursOfSleep = "Under 5" THEN 0
    WHEN HoursOfSleep = "Between 5-7" THEN 1
    WHEN HoursOfSleep = "Between 7-9" THEN 2
    WHEN HoursOfSleep = "Above 9" THEN 3
  END;

-- This table will be exported for visualization.

-- It appears that on days when users slept between 5-7 hours per day, they burned the most calories, quickly followed by days when users slept for the recommended time of 7-9 hours.
-- However, this data may only provide part of the story relating to total calories burned and does not communicate any other effects that sleep difference may have had on users such as energy levels throughout the day, alertness, or other benefits of sleep.

-- The last area to explore is how users utilize the step function of their fitbit trackers. Health.gov does not have a recommended amount of steps per day but notes that the most popular given number is 10,000 steps per day and provides guidelines to reaching a step goal. If we use this popular goal as the benchmark for a healthy amount of steps, we can determine the average steps from the study's participants and create recommendations from their use. We will round the number of steps and confirm that all 33 participants tracked their steps.
-- https://health.gov/our-work/nutrition-physical-activity/physical-activity-guidelines/previous-guidelines/2008-physical-activity-guidelines

SELECT  
  Id,
  CAST(AVG(StepTotal) as INT64) as AvgStepTotal
FROM `wellness-bellabeat.fitbit_data.daily_steps` 
GROUP BY
  Id;

-- This table will be exported for visualization
-- Let's check to see how many participants had an average of 10,000 steps per day.

SELECT  
  Id,
  CAST(AVG(StepTotal) as INT64) as AvgStepTotal
FROM `wellness-bellabeat.fitbit_data.daily_steps` 
GROUP BY
  Id
HAVING
  CAST(AVG(StepTotal) as INT64) >= 10000;

-- It looks like there is only 7 of the 33 participants who have an average daily step total exceeding 10,000 steps per day.

-- Let's see what the average distance looks like compared to the average steps.

SELECT  
  Id,
  CAST(AVG(TotalSteps) as INT64) as AvgStepTotal,
  AVG(TotalDistance) as AvgDistance
FROM `wellness-bellabeat.fitbit_data.daily_activity`
GROUP BY Id
ORDER BY AvgStepTotal desc

-- This table will be saved for visualization.
-- It appears that the average participant who exceeded 10,000 steps regularly moved for a minimum of 7.5 miles. Without a larger dataset, it will be hard to determine any definitive trends from this information.

-- Data Limitations --

/* I would like to further evaluate weight trends both through sleep, calories burned, and activity minutes, however, the dataset provided does not provide an adequate amount of weight data to provide an accurate analysis. After viewing the weight_log dataset, there was no enough unique users who tracked their weight in the timeframe of the dataset which spanned one month. If there is a desire to understand how users utilize fitness trackers for weight management, more data would be needed both in the timespan of the data in addition to more users participating in providing weight data consistently throughout the study.

As stated previously, the sleep data may only provide part of the story relating to total calories burned and does not communicate any other effects that sleep difference may have had on users such as energy levels throughout the day, alertness, or other benefits of sleep.

Lastly, there is only 33 participants that tracked information over the course of one month. Both factors provide extreme limitations in determining trends in each area of usage that is tracked. In addition to needing an larger dataset, it would be beneficial to have some other information such as sex, health/fitness goals, and height. Knowing the sex of the participants would allow me to filter the dataset to align with Bellabeat's target demographic. Knowing the participants health and fitness goals will allow me to explore if the goals are being met or worked toward. Knowing height will allow for a deeper understanding when exploring steps and distance totals as individuals of different heights will have varying stride lengths and can cause a skew in the data if there is a skew in height of the participants.
*/
