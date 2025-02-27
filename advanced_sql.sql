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



