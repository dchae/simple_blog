CREATE TABLE users (
  id serial PRIMARY KEY,
  username varchar(32) UNIQUE NOT NULL,
  pw_hash text NOT NULL,
  join_date timestamp DEFAULT NOW()
);

CREATE TABLE posts (
  id serial PRIMARY KEY,
  title text NOT NULL,
  user_id int NOT NULL REFERENCES users(id),
  post_date timestamp DEFAULT NOW(),
  content text NOT NULL
)