# Bellabeat Data Analysis Project

## Table of Contents
* [Methods Used](https://github.com/davidebrock/Bellabeat-project#methods-used)
* [Business Task](https://github.com/davidebrock/Bellabeat-project#business-task)
* [Datasource](https://github.com/davidebrock/Bellabeat-project#datasource)
* [Data Processing, Cleaning, and Analysis](https://github.com/davidebrock/Bellabeat-project#data-processing-cleaning-and-analysis)
* [Summary of Analysis](https://github.com/davidebrock/Bellabeat-project#summary-of-analysis)
* [Data Limitations](https://github.com/davidebrock/Bellabeat-project#data-limitations)
* [Tableau Dashboard/Visualization](https://github.com/davidebrock/Bellabeat-project#tableau-dashboardvisualization)
* [Recommendations](https://github.com/davidebrock/Bellabeat-project#recommendations)
* [Areas Requiring Further Data](https://github.com/davidebrock/Bellabeat-project#areas-requiring-further-data)

## Methods Used
* SQL
* Tableau

## Business Task
Determine how non-Bellabeat users utilize their smart devices to determine what trends can be applied to Bellabeat customers and increase usage and customer base.

## Datasource
The data used in this project was made available through [Mobius](https://www.kaggle.com/arashnic) and utilized public [FitBit Fitness Tracker Data](https://www.kaggle.com/datasets/arashnic/fitbit) under a *CC0: Public Domain* license.

## Data Processing, Cleaning, and Analysis
All data processing, cleaning, and analysis were completed using SQL and can be found in the *bellabeat-SQL-script.sql* script provided in this repository, along with comments throughout detailed thought processes and findings.

## Summary of Analysis
1. **Limited Heart Rate Tracking**: Only 30% of the participants tracked their heart rates during workouts and those who did tend to burn more calories and engage in higher activity levels. This suggests that heart rate tracking could be associated with more intense physical activity.

2. **Afternoons are Most Active**: On average, afternoons are the most active times of the day for participants, except on Thursdays. The peak workout times during the week are between 17:00 and 19:00 (5-7 PM) on most days and between 11:00 and 14:00 (11 AM - 2 PM) on Saturdays.

3. **Sleep Duration and Activity**: Participants who slept between 5-7 hours per night burned the most calories, closely followed by those who slept for the recommended 7-9 hours. Oversleeping appeared to have the largest negative impact on daily activity.

4. **Step Tracking**: Only 7 out of 33 participants achieved an average of 10,000 steps per day. Those who did tend to move for a minimum of 7.5 miles daily. 

Overall, my analysis suggests that tracking factors like heart rate, sleep duration, and step count can have an impact on physical activity and overall wellness. However, these conclusions are based on a limited dataset, and a larger and more comprehensive dataset would be needed for more robust and generalizable findings.

## Data Limitations
I would like to further evaluate weight trends through sleep, calories burned, and activity minutes. However, the dataset provided does not provide an adequate amount of weight data to provide an accurate analysis. After viewing the weight_log dataset, there were not enough unique users who tracked their weight in the timeframe of the dataset, which spanned one month. If there is a desire to understand how users utilize fitness trackers for weight management, more data would be needed both in the time span of the data and in addition to more users participating in providing weight data consistently throughout the study.

The sleep data may only provide part of the story relating to total calories burned and does not communicate any other effects that sleep difference may have had on users, such as energy levels throughout the day, alertness, or other benefits of sleep.

Lastly, there were only 33 participants who tracked information over the course of one month. Both factors provide extreme limitations in determining trends in each area of usage that is tracked. In addition to needing a larger dataset, it would be beneficial to have some other information, such as sex, health/fitness goals, and height. Knowing the sex of the participants would allow me to filter the dataset to align with Bellabeat's target demographic. Knowing the participant's health and fitness goals will allow me to explore if the goals are being met or worked toward. Knowing height will allow for a deeper understanding when exploring steps and distance totals, as individuals of different heights will have varying stride lengths and can cause a skew in the data if there is a skew in the height of the participants.

## Tableau Dashboard/Visualization
The dashboard designed for this project was laid out in a way that emulates Bellabeat's design language found on their **[website](https://www.bellabeat.com/)** at the time of design. This is to provide cohesiveness for the organization's visualization and meet their standard for quality. This dashboard's purpose is to make it easy to understand how participants in the dataset used their Fitbit devices and will also provide the elements for the presentation that will be used with the executive team.

**[View the Bellabeat Tableau Dashboard here.](https://public.tableau.com/app/profile/david.brock2641/viz/Bellabeat_16968184231570/Dashboard12)**

## Recommendations

1. **Leverage Influencer Marketing**:Exploit the power of influencer marketing to highlight Bellabeat Ivy Health Tracker's unique capability to identify self-care gaps and offer solutions. Collaborate with a diverse group of female influencers across various niches, such as fitness, working moms, and stay-at-home moms, to customize your message for women from all walks of life. Utilize a variety of social media platforms, including but  not limited to TikTok, Instagram, Facebook, and Pinterest, to maximize your reach.

2. **Craft an Engaging Ad Campaign**: Create a captivating ad campaign that underscores how users who monitor their heart rate and weight develop healthier lifestyle habits, resulting in increased calorie burn and daily activity. Develop a compelling tagline that resonates with the modern woman, emphasizing how the Ivy Health Tracker empowers women to be prepared for the demands of their unique lifestyles.

3. **Introduce Health Goal Competitions**: Foster user engagement by organizing monthly health goal competitions for both new and existing Ivy Health Tracker users. Provide enticing prizes, such as a free year of Bellabeat's membership program, and allow participants to select their competition categories. This not only nurtures a supportive community among Bellabeat users but also promotes physical and mental well-being which are two key metrics of the Ivy Health Tracker. Utilize the Ivy Health Tracker to help participants track their progress and improvements throughout the competition via the Bellabeat app.

### Areas Requiring Further Data

Unfortunately, due to the limited dataset, generating comprehensive analyses and conclusive recommendations in certain areas is challenging. To address this and gain a deeper understanding of Bellabeat's user base, consider the following strategies for enhancing data quality and exploring key areas of interest:

1. **Collect Data Internally**: Explore the option of gathering additional data from Bellabeat's existing lineup of health trackers and the Bellabeat app. This internal data collection can provide a more reliable and accessible source of information.

2. **Potential Partnerships and Surveys**: If supplementary external data is necessary beyond Bellabeat's internal sources, consider establishing partnerships with other data sources or conducting surveys. This collaborative approach can focus on the key metrics required for a more comprehensive analysis.

By implementing these steps, Bellabeat can overcome data limitations, gain insights into user behavior, and establish a stronger foundation for future analyses and recommendations. When more data becomes available, the following hypotheses can be explored:

1. **Health Goal Success Rate**: Evaluate the success rates of fitness tracker users in setting and achieving their health goals, such as steps, weight management, and stress reduction.

2. **Effect of Comprehensive Tracking**: Investigate whether there is a correlation between achieving health goals and the depth of data collection. The hypothesis to test is whether users who track all available metrics provided by the tracker, including activity, heart rate, stress, and weight, achieve their health goals more effectively than those who track only a single or limited set of metrics.

3. **Gender Differences**: Address the limitation of not knowing the users' gender in the dataset. It is valuable to understand how both females and males utilize their trackers uniquely and similarly to allow the Bellabeat Ivy tracker to better cater to female users.
