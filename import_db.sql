PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS users;

CREATE TABLE users(
  id INTEGER PRIMARY KEY,
  fname VARCHAR(20) NOT NULL,
  lname VARCHAR(20) NOT NULL,
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title VARCHAR(20) NOT NULL,
  body VARCHAR(20) NOT NULL,
  author_id INTEGER NOT NULL, 
  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS questions_follows;

CREATE TABLE questions_follows(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  body VARCHAR(200) NOT NULL,
  reply_id INTEGER REFERENCES replies(id),
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE questions_likes(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  
  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
);


INSERT INTO
  users (fname, lname)
VALUES
  ('Tyler', 'Johnson'),
  ('Jerry', 'Wang');

INSERT INTO
  questions (title, body, author_id)
VALUES
  ('What is SQL?', 'SQL is a programming language', (SELECT id FROM users WHERE fname = 'Jerry'))
  ('What is Oracle?', 'Oracle uses SQL', (SELECT id FROM users WHERE fname = 'Tyler'))

INSERT INTO
  questions_follows (question_id, user_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'What is SQL?'), (SELECT id FROM users WHERE fname = 'Tyler'))
  ((SELECT id FROM questions WHERE title = 'What is Oracle?'), (SELECT id FROM users WHERE fname = 'Jerry'))
  
