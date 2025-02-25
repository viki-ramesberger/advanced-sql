# Advanced SQL
The project is carried out in an interactive simulator on the Yandex Praktikum platform.  It consists of two parts with 20 tasks on composing queries to a database (PostgreSQL) from StackOverflow.

Database ER diagram:
![Image (2)](https://github.com/user-attachments/assets/93c3ce26-1151-401d-bd00-7633869c79c4)

## Badges Table
Stores information about badges awarded for various achievements. For example, a user who answers a large number of questions about PostgreSQL correctly might receive the "postgresql" badge.

| Field          | Description                                                                   |
|----------------|-------------------------------------------------------------------------------|
| `id`           | Badge identifier, primary key of the table                                    |
| `name`         | Name of the badge                                                             |
| `user_id`      | User identifier, foreign key referencing the `users` table                     |
| `creation_date`| Date when the badge was awarded                                               |

## Post Types Table
Contains information about the types of posts. There are two possible types:
- `Question` — a post with a question
- `Answer` — a post with an answer

| Field        | Description                                                               |
|--------------|---------------------------------------------------------------------------|
| `id`         | Post identifier, primary key of the table                                  |
| `type`       | Type of the post                                                          |

## Posts Table
Contains information about posts.

| Field               | Description                                                                  |
|---------------------|------------------------------------------------------------------------------|
| `id`                | Post identifier, primary key of the table                                    |
| `title`             | Title of the post                                                            |
| `creation_date`     | Date the post was created                                                    |
| `favorites_count`   | Number showing how many times the post was added to "Bookmarks"              |
| `last_activity_date`| Date of the last activity on the post, e.g., comment                         |
| `last_edit_date`    | Date the post was last edited                                                |
| `user_id`           | User identifier, foreign key referencing the `users` table                   |
| `parent_id`         | If the post is a reply to another post, this field contains the question post's ID |
| `post_type_id`      | Post type identifier, foreign key referencing the `post_types` table         |
| `score`             | Number of points the post has accumulated                                    |
| `views_count`       | Number of views the post has received                                        |

## Users Table
Contains information about users.

| Field               | Description                                                                  |
|---------------------|------------------------------------------------------------------------------|
| `id`                | User identifier, primary key of the table                                    |
| `creation_date`     | Date the user registered                                                      |
| `display_name`      | Username                                                                     |
| `last_access_date`  | Date of the last login                                                        |
| `location`          | Location of the user                                                          |
| `reputation`        | Reputation points received for good questions and helpful answers            |
| `views`             | Number of profile views                                                      |

## Vote Types Table
Contains information about the types of votes. A vote is a label that users assign to a post. There are several types:
- `UpMod` — A mark given to posts with questions or answers deemed relevant and helpful by users.
- `DownMod` — A mark given to posts that users found less useful.
- `Close` — A mark placed by experienced users when a question needs improvement or is not suitable for the platform.
- `Offensive` — A mark given if the answer is rude or insulting, such as calling the post author inexperienced.
- `Spam` — A mark indicating the post looks like blatant advertisement.

| Field        | Description                                                               |
|--------------|---------------------------------------------------------------------------|
| `id`         | Vote type identifier, primary key                                          |
| `name`       | Name of the vote type                                                     |

## Votes Table
Contains information about votes on posts.

| Field           | Description                                                                  |
|-----------------|------------------------------------------------------------------------------|
| `id`            | Vote identifier, primary key of the table                                    |
| `post_id`       | Post identifier, foreign key referencing the `posts` table                   |
| `user_id`       | User identifier, foreign key referencing the `users` table                   |
| `bounty_amount` | Amount of the bounty offered to attract attention to the post                |
| `vote_type_id`  | Vote type identifier, foreign key referencing the `vote_types` table         |
| `creation_date` | Date when the vote was cast                                                  |



