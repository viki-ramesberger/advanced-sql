# Advanced SQL
The project is carried out in an interactive simulator on the Yandex Praktikum platform.  It consists of two parts with 20 tasks on composing queries to a database (PostgreSQL) from StackOverflow.

Database ER diagram:
![Image (2)](https://github.com/user-attachments/assets/93c3ce26-1151-401d-bd00-7633869c79c4)

### Таблица `badges`
Хранит информацию о значках, которые присуждаются за разные достижения. Например, пользователь, правильно ответивший на большое количество вопросов про PostgreSQL, может получить значок `postgresql`.

| Поле           | Описание                                                       |
|----------------|---------------------------------------------------------------|
| `id`           | Идентификатор значка, первичный ключ таблицы                  |
| `name`         | Название значка                                               |
| `user_id`      | Идентификатор пользователя, которому присвоили значок, внешний ключ, отсылающий к таблице `users` |
| `creation_date`| Дата присвоения значка                                        |

### Таблица `post_types`
Содержит информацию о типе постов. Их может быть два:
- `Question` — пост с вопросом
- `Answer` — пост с ответом

| Поле           | Описание                                                   |
|----------------|-----------------------------------------------------------|
| `id`           | Идентификатор поста, первичный ключ таблицы              |
| `type`         | Тип поста                                                |

