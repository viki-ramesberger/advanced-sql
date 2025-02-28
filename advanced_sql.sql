-- First Part of the Project --

/* Task 1. Find the number of questions that have gained more than 300 points or have been added to "Bookmarks" at least 100 times. */

SELECT COUNT(id)
FROM stackoverflow.posts
WHERE post_type_id = 1
AND (score > 300 OR favorites_count >= 100);

/* Task 2. How many questions were asked per day on average from November 1 to November 18, 2008 (inclusive)? 
Round the result to the nearest whole number.*/

SELECT ROUND(AVG(q.count), 0)
FROM (
      SELECT COUNT(id) AS count,
             creation_date::date
      FROM stackoverflow.posts
      WHERE post_type_id = 1
      GROUP BY creation_date::date
      HAVING creation_date::date BETWEEN '2008-11-01' AND '2008-11-18'
) AS q;

/* Task 3. How many users received badges on the same day they registered? Display the count of unique users.*/

SELECT COUNT(DISTINCT b.user_id)
FROM stackoverflow.badges AS b
JOIN stackoverflow.users AS u ON u.id = b.user_id
WHERE u.creation_date::date = b.creation_date::date;

/* Task 4. How many unique posts by the user named Joel Coehoorn have received at least one vote?*/

SELECT COUNT(DISTINCT p.id)
FROM stackoverflow.users AS u
JOIN stackoverflow.posts AS p ON p.user_id = u.id
JOIN stackoverflow.votes AS v ON p.id = v.post_id
WHERE u.display_name = 'Joel Coehoorn';

/* Task 5. Retrieve all fields from the vote_types table. Add a new field rank, which assigns row numbers in reverse order. 
The table should be sorted by the id field.*/

SELECT *,
      ROW_NUMBER() OVER (ORDER BY id DESC) AS rank
FROM stackoverflow.vote_types
ORDER BY id;

/* Task 6. Select the top 10 users who cast the most Close votes. Display a table with two fields: the user ID and the number of votes. 
Sort the data first by the number of votes in descending order, then by user ID in descending order.*/

SELECT *
FROM (
      SELECT v.user_id,
             COUNT(vt.id) AS v_cnt
      FROM stackoverflow.votes AS v
      JOIN stackoverflow.vote_types AS vt ON vt.id = v.vote_type_id
      WHERE vt.name = 'Close'
      GROUP BY v.user_id
      ORDER BY v_cnt DESC
      LIMIT 10
) AS au
ORDER BY au.v_cnt DESC, au.user_id DESC;

/* Task 7. Select the top 10 users based on the number of badges received between November 15 and December 15, 2008 (inclusive).
Display the following fields:
- User ID
- Number of badges
- Ranking position (Users with more badges should have a higher rank.)
Users with the same number of badges should have the same rank. 
Sort the records by the number of badges in descending order, then by user ID in ascending order.*/

SELECT *,
       DENSE_RANK() OVER (ORDER BY b.b_cnt DESC) AS rating
FROM (
      SELECT user_id,
             COUNT(id) AS b_cnt
      FROM stackoverflow.badges
      WHERE creation_date::date BETWEEN '2008-11-15' AND '2008-12-15' 
      GROUP BY user_id
      ORDER BY b_cnt DESC, user_id
      LIMIT 10
) AS b;

/* Task 8. What is the average score for posts created by each user?
Create a table with the following fields:
- Post title
- User ID
- Post score
- User's average score per post (rounded to the nearest whole number)
Exclude posts with no title and those that have a score of zero.*/

WITH sc AS (
    SELECT ROUND(AVG(score)) AS avg_score,
           user_id
    FROM stackoverflow.posts
    WHERE title IS NOT NULL AND score <> 0
    GROUP BY user_id
)
SELECT p.title,
       sc.user_id,
       p.score,
       sc.avg_score
FROM sc
JOIN stackoverflow.posts AS p ON sc.user_id = p.user_id
WHERE p.title IS NOT NULL AND p.score <> 0;

/* Task 9. Display the titles of posts written by users who have received more than 1,000 badges. 
Posts without titles should not be included in the list.*/

SELECT title
FROM stackoverflow.posts
WHERE user_id IN (
    SELECT user_id
    FROM stackoverflow.badges
    GROUP BY user_id
    HAVING COUNT(id) > 1000
) 
AND title IS NOT NULL;

/* Task 10. Write a query to retrieve data on users from Canada. Categorize them into three groups based on the number of profile views:
- Users with 350 or more views → Group 1
- Users with between 100 and 349 views → Group 2
- Users with less than 100 views → Group 3
Display the user ID, profile view count, and group. Users with zero views should be excluded from the result.*/

SELECT DISTINCT id AS user_id, views AS vi,
       CASE
           WHEN views >= 350 THEN 1
           WHEN views < 100 THEN 3
           ELSE 2
       END AS rate
FROM stackoverflow.users
WHERE location LIKE '%Canada%' AND views > 0;

/* Task 11. Extend the previous query. Display the top user in each group — the user with the highest number of views in their respective group.
Show the following fields:
- User ID
- Group
- Number of views
Sort the table by views in descending order, then by user ID in ascending order.*/

WITH UserGroups AS (
    SELECT
        id AS user_id,
        views,
        CASE
            WHEN views >= 350 THEN 1
            WHEN views >= 100 THEN 2
            ELSE 3
        END AS group_number
    FROM stackoverflow.users
    WHERE location LIKE '%Canada%' AND views > 0
),
MaxViews AS (
    SELECT
        group_number,
        MAX(views) AS max_views
    FROM UserGroups
    GROUP BY group_number
)
SELECT
    u.user_id,
    u.views,
    u.group_number
FROM UserGroups u
JOIN MaxViews m ON u.group_number = m.group_number AND u.views = m.max_views
ORDER BY u.views DESC, u.user_id;

/* Task 12. Calculate the daily increase in new users in November 2008.
Create a table with the following fields:
- Day number
- Number of users who registered on that day
- Cumulative total of registered users*/

WITH x AS (
    SELECT EXTRACT(DAY FROM creation_date) AS day_reg,
           COUNT(id) AS count_id
    FROM stackoverflow.users
    WHERE CAST(DATE_TRUNC('month', creation_date) AS date) BETWEEN '2008-11-01' AND '2008-11-30'
    GROUP BY day_reg
)
SELECT *,
       SUM(count_id) OVER (ORDER BY day_reg)
FROM x
ORDER BY day_reg;

/* Task 13. For each user who has written at least one post, find the time interval between their registration and the creation of their first post.
Display:
- User ID
- Time difference between registration and first post*/

WITH b AS (
    SELECT user_id AS users_p,
           FIRST_VALUE(creation_date) OVER (PARTITION BY user_id ORDER BY creation_date) AS first_post
    FROM stackoverflow.posts
)
SELECT DISTINCT users_p,
       first_post - u.creation_date AS dif
FROM b
INNER JOIN stackoverflow.users AS u ON u.id = users_p;

-- Second Part of the Project --

/* Task 1. Monthly Post Views in 2008:
- Calculate the total number of post views for each month in 2008. 
If data for any month is missing, exclude that month from the results.
- Sort the results in descending order of total views.*/

SELECT DATE_TRUNC('month', creation_date)::date AS month_date,
       SUM(views_count) AS total_views
FROM stackoverflow.posts
WHERE creation_date BETWEEN '2008-01-01' AND '2008-12-31'
GROUP BY month_date
ORDER BY total_views DESC;

/* Task 2. Most Active Users in the First Month:
- Identify users who, in the first month after registration (including the registration day), have provided more than 100 answers.
- Do not consider questions asked by users.
- For each user's name, display the count of unique user_id values.
- Sort the results lexicographically by the user's name.*/

WITH user_activity AS (
    SELECT
        u.id AS user_id,
        u.display_name,
        COUNT(p.id) AS answer_count,
        MIN(u.creation_date) AS registration_date
    FROM
        stackoverflow.users u
    JOIN
        stackoverflow.posts p ON u.id = p.user_id
    WHERE
        p.post_type_id = 2 -- Ответы
    GROUP BY
        u.id, u.display_name
)
SELECT
    display_name,
    COUNT(DISTINCT user_id) AS unique_user_count
FROM
    user_activity
WHERE
    answer_count > 100
    AND registration_date BETWEEN '2008-11-01' AND '2008-11-30'
GROUP BY
    display_name
ORDER BY
    display_name;

/* Task 3.Monthly Post Counts for September and December 2008:
- Calculate the number of posts for each month in 2008.
- Filter posts from users who registered in September 2008 and made at least one post in December of the same year.
- Sort the table by the month in descending order.*/

WITH september_users AS (
    SELECT
        id AS user_id
    FROM
        stackoverflow.users
    WHERE
        EXTRACT(MONTH FROM creation_date) = 9
        AND EXTRACT(YEAR FROM creation_date) = 2008
),
december_posts AS (
    SELECT
        user_id,
        EXTRACT(MONTH FROM creation_date) AS month,
        COUNT(id) AS post_count
    FROM
        stackoverflow.posts
    WHERE
        EXTRACT(MONTH FROM creation_date) = 12
        AND EXTRACT(YEAR FROM creation_date) = 2008
    GROUP BY
        user_id, month
)
SELECT
    dp.month,
    SUM(dp.post_count) AS total_posts
FROM
    december_posts dp
JOIN
    september_users su ON dp.user_id = su.user_id
GROUP BY
    dp.month
ORDER BY
    dp.month DESC;

/* Task 4.User Post Details with Cumulative Views:
- Using post data, display the following fields:
  - User ID of the post author.
  - Post creation date.
  - Number of views for the current post.
  - Cumulative sum of views for the author's posts.
- Sort the data by ascending user IDs, and for each user, by ascending post creation dates.*/

WITH post_views AS (
    SELECT
        p.user_id,
        p.creation_date,
        p.views,
        SUM(p.views) OVER (PARTITION BY p.user_id ORDER BY p.creation_date) AS cumulative_views
    FROM
        stackoverflow.posts p
)
SELECT
    pv.user_id,
    pv.creation_date,
    pv.views,
    pv.cumulative_views
FROM
    post_views pv
ORDER BY
    pv.user_id ASC,
    pv.creation_date ASC;

/* Task 5.Average Daily Posts in August 2008:
- Calculate the average number of posts per day for users in August 2008.
- Filter data for users who published more than 120 posts in August.
- Exclude days without publications.
- Sort the results by ascending average number of posts.
- Do not round the values.*/

WITH august_posts AS (
    SELECT
        user_id,
        COUNT(id) AS post_count
    FROM
        stackoverflow.posts
    WHERE
        EXTRACT(MONTH FROM creation_date) = 8
        AND EXTRACT(YEAR FROM creation_date) = 2008
    GROUP BY
        user_id
)
SELECT
    user_id,
    post_count / 31.0 AS avg_posts_per_day
FROM
    august_posts
WHERE
    post_count > 120
ORDER BY
    avg_posts_per_day ASC;

/* Task 6.Average Active Days from December 1 to 7, 2008:
- Calculate the average number of days users interacted with the platform between December 1 and 7, 2008.
- For each user, consider days when they published at least one post.
- Provide a single integer result.
- Round the result appropriately.*/

WITH user_activity AS (
    SELECT
        user_id,
        COUNT(DISTINCT DATE(creation_date)) AS active_days
    FROM
        stackoverflow.posts
    WHERE
        creation_date BETWEEN '2008-12-01' AND '2008-12-07'
    GROUP BY
        user_id
)
SELECT
    ROUND(AVG(active_days)) AS avg_active_days
FROM
    user_activity;

/* Task 7. User Activity History with Second-Last Post Month:
- Display each user's activity history in the following format:
  - User ID.
  - Post publication date.
- Sort the output by ascending user IDs, and for each user, by ascending post publication dates.
- Add a new field to the table: for each post, indicate the month of the user's second-last publication relative to the current post. 
If such a publication does not exist, indicate NULL.
- Note: Python will automatically convert NULL to None, but no additional conversion is necessary.
- Carefully observe the sample table: for the first two posts, there is no second-last publication, so the new field will be NULL. 
Starting from the third post, the field will contain the appropriate month. 
For the next user, the first two entries will also have NULL in the new field.*/

WITH user_posts AS (
    SELECT
        user_id,
        creation_date,
        LEAD(EXTRACT(MONTH FROM creation_date)) OVER (PARTITION BY user_id ORDER BY creation_date DESC) AS second_last_month
    FROM
        stackoverflow.posts
)
SELECT
    user_id,
    creation_date,
    CASE
        WHEN second_last_month IS NULL THEN NULL
        ELSE TO_CHAR(TO_DATE(second_last_month::text, 'MM'), 'Month')
    END AS second_last_month
FROM
    user_posts
ORDER BY
    user_id ASC,
    creation_date ASC;


