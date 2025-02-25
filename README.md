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


