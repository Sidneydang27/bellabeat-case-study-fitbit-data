-- ASK
-- - Business Task: "Analyze  public Fitbit smart device data to uncover patterns in how users track activity, sleep, and overall wellness.
-- - Use these insights to make actionable recommendations for one Bellabeat product - aimed at shaping a data-driven marketing strategy
-- - that increases engagement and helps Bellabeat grow its presence in the smart wellness space."
-- - Ultimate Goal: To help Bellabeat become a leading global wellness technology brand by aligning its product offerings and marketing strategy
-- - with real user behavior - making its devices more relevant, engaging, and valuable to its target audience.

-- PREPARE & PROCESS

SHOW GLOBAL VARIABLES LIKE 'local_infile';

CREATE DATABASE IF NOT EXISTS bellabeat_fitbit;

USE bellabeat_fitbit;

CREATE TABLE fitbit_daily_activity (
  user_id BIGINT,
  activity_date DATE,
  total_steps INT,
  total_distance FLOAT,
  tracker_distance FLOAT,
  logged_activities_distance FLOAT,
  very_active_distance FLOAT,
  moderately_active_distance FLOAT,
  lightly_active_distance FLOAT,
  sedentary_active_distance FLOAT,
  very_active_minutes INT,
  fairly_active_minutes INT,
  lightly_active_minutes INT,
  sedentary_minutes INT,
  calories INT
);


CREATE TABLE fitbit_hourly_calories (
  user_id BIGINT,
  activity_hour DATETIME,
  calories FLOAT
);

CREATE TABLE fitbit_hourly_intensities (
  user_id BIGINT,
  activity_hour DATETIME,
  total_intensity FLOAT,
  average_intensity FLOAT
);

CREATE TABLE fitbit_hourly_steps (
  user_id BIGINT,
  activity_hour DATETIME,
  steps INT
);

-- Load daily activity
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fitbit_daily_activity.csv'
INTO TABLE fitbit_daily_activity
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM fitbit_daily_activity LIMIT 20;

-- Load hourly calories

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fitbit_hourly_calories.csv'
INTO TABLE fitbit_hourly_calories
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM fitbit_hourly_calories LIMIT 10;

-- Load hourly intensities
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fitbit_hourly_intensities.csv'
INTO TABLE fitbit_hourly_intensities
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM fitbit_hourly_intensities LIMIT 25;

-- Load hourly steps
LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fitbit_hourly_steps.csv'
INTO TABLE fitbit_hourly_steps
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SELECT * FROM fitbit_hourly_steps LIMIT 15;

-- ANALYZE

-- What hours of the day are users most active?
SELECT 
  HOUR(activity_hour) AS hour_of_day,
  ROUND(AVG(steps), 0) AS avg_steps
FROM fitbit_hourly_steps
GROUP BY HOUR(activity_hour)
ORDER BY avg_steps DESC;

-- What times correlate with peak energy expenditure?
SELECT 
  HOUR(activity_hour) AS hour_of_day,
  ROUND(AVG(calories), 2) AS avg_calories
FROM fitbit_hourly_calories
GROUP BY HOUR(activity_hour)
ORDER BY avg_calories DESC;

--  When do users push hardest during the day?
SELECT 
  HOUR(activity_hour) AS hour_of_day,
  ROUND(AVG(total_intensity), 2) AS avg_total_intensity,
  ROUND(AVG(average_intensity), 2) AS avg_average_intensity
FROM fitbit_hourly_intensities
GROUP BY HOUR(activity_hour)
ORDER BY avg_total_intensity DESC;

-- How closely do movement and calorie burn align?
SELECT 
  hs.activity_hour,
  SUM(hs.steps) AS daily_steps,
  ROUND(SUM(hc.calories), 2) AS daily_calories
FROM fitbit_hourly_steps hs
JOIN fitbit_hourly_calories hc 
  ON hs.user_id = hc.user_id AND hs.activity_hour = hc.activity_hour
GROUP BY hs.activity_hour
ORDER BY daily_steps DESC;

-- Which hours show low movement despite high calories?
SELECT 
  hs.activity_hour,
  hs.steps,
  hc.calories,
  hi.total_intensity
FROM fitbit_hourly_steps hs
JOIN fitbit_hourly_calories hc 
  ON hs.user_id = hc.user_id AND hs.activity_hour = hc.activity_hour
JOIN fitbit_hourly_intensities hi 
  ON hs.user_id = hi.user_id AND hs.activity_hour = hi.activity_hour
WHERE hs.steps < 50 AND hc.calories > 50
ORDER BY hc.calories DESC;


-- Which days have most consistent activity patterns?
SELECT 
  hs.activity_hour,
  ROUND(STDDEV(steps), 0) AS step_variability,
  ROUND(STDDEV(calories), 2) AS calorie_variability,
  ROUND(STDDEV(total_intensity), 2) AS intensity_variability
FROM fitbit_hourly_steps hs
JOIN fitbit_hourly_calories hc 
  ON hs.user_id = hc.user_id AND hs.activity_hour = hc.activity_hour
JOIN fitbit_hourly_intensities hi 
  ON hs.user_id = hi.user_id AND hs.activity_hour = hi.activity_hour
GROUP BY hs.activity_hour
ORDER BY step_variability ASC, calorie_variability ASC, intensity_variability ASC;

