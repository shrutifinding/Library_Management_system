mysql> CREATE database Library;
Query OK, 1 row affected (0.01 sec)
  
mysql> Use Library;
Database changed
mysql> CREATE TABLE Books (
    ->     BookID INT AUTO_INCREMENT PRIMARY KEY,
    ->     Title VARCHAR(100),
    ->     Author VARCHAR(100),
    ->     Genre VARCHAR(50),
    ->     PublicationYear INT,
    ->     Available BOOLEAN DEFAULT TRUE
    -> );
mysql> CREATE TABLE Users (
    ->     UserID INT AUTO_INCREMENT PRIMARY KEY,
    ->     UserName VARCHAR(100),
    ->     MembershipDate DATE
    -> );

mysql> CREATE TABLE BorrowHistory (
    ->     BorrowID INT AUTO_INCREMENT PRIMARY KEY,
    ->     UserID INT,
    ->     BookID INT,
    ->     BorrowDate DATE,
    ->     ReturnDate DATE,
    ->     FOREIGN KEY (UserID) REFERENCES Users(UserID),
    ->     FOREIGN KEY (BookID) REFERENCES Books(BookID)

    -> );

mysql> INSERT INTO Books (Title, Author, Genre, PublicationYear)
    -> VALUES ('The Great Gatsby', 'F. Scott Fitzgerald', 'Fiction', 1925),
    -> ('To Kill a Mockingbird', 'Harper Lee', 'Fiction', 1960),
    -> ('A Brief History of Time', 'Stephen Hawking', 'Science', 1988),
    -> ('George Orwell', 'Dystopian', 'Mystery',1949);

mysql> INSERT INTO Users (UserName, MembershipDate)
    -> VALUES ('Shekhar', '2024-06-01'),
    -> ('Sumit', '2024-07-10');

mysql> INSERT INTO BorrowHistory (UserID, BookID, BorrowDate, ReturnDate)
    -> VALUES (1, 1, '2024-06-01', '2024-07-01'),
    -> (2, 2, '2024-07-01', '2024-07-15');

//Retrieve Borrowed Books by a User:
mysql> SELECT b.Title, bh.BorrowDate, bh.ReturnDate
    -> FROM BorrowHistory bh
    -> JOIN Books b ON bh.BookID = b.BookID
    -> WHERE bh.UserID = 1;
+------------------+------------+------------+
| Title            | BorrowDate | ReturnDate |
+------------------+------------+------------+
| The Great Gatsby | 2024-06-01 | 2024-07-01 |
+------------------+------------+------------+

//List Available Books:
mysql> SELECT * FROM Books
    -> WHERE Available = TRUE;
+--------+-------------------------+---------------------+---------+-----------------+-----------+
| BookID | Title                   | Author              | Genre   | PublicationYear | Available |
+--------+-------------------------+---------------------+---------+-----------------+-----------+
|      1 | The Great Gatsby        | F. Scott Fitzgerald | Fiction |            1925 |         1 |
|      2 | To Kill a Mockingbird   | Harper Lee          | Fiction |            1960 |         1 |
|      3 | A Brief History of Time | Stephen Hawking     | Science |            1988 |         1 |
|      4 | George Orwell           | Dystopian           | Mystery |            1949 |         1 |
+--------+-------------------------+---------------------+---------+-----------------+-----------+
  
//Suggest books of the same genre that the user has borrowed before:

mysql> SELECT DISTINCT b.Title, b.Author
    -> FROM Books b
    -> JOIN BorrowHistory bh ON b.BookID = bh.BookID
    -> WHERE bh.UserID = 1 AND b.Genre IN (
    ->     SELECT Genre FROM Books b2
    ->     JOIN BorrowHistory bh2 ON b2.BookID = bh2.BookID
    ->     WHERE bh2.UserID = 1
    -> )
    -> AND b.BookID NOT IN (
    ->     SELECT BookID FROM BorrowHistory WHERE UserID = 1
    -> );

//Recommend the most popular books (most borrowed):
  
mysql> SELECT b.Title, COUNT(bh.BookID) AS BorrowCount
    -> FROM BorrowHistory bh
    -> JOIN Books b ON bh.BookID = b.BookID
    -> GROUP BY b.BookID
    -> ORDER BY BorrowCount DESC
    -> LIMIT 5;
+-----------------------+-------------+
| Title                 | BorrowCount |
+-----------------------+-------------+
| The Great Gatsby      |           1 |
| To Kill a Mockingbird |           1 |
+-----------------------+-------------+
  
//Overdue Book Detection: Find out which books are overdue based on the current date
  
mysql> SELECT u.UserName, b.Title, bh.BorrowDate, bh.ReturnDate
    -> FROM BorrowHistory bh
    -> JOIN Users u ON bh.UserID = u.UserID
    -> JOIN Books b ON bh.BookID = b.BookID
    -> WHERE bh.ReturnDate < CURDATE() AND bh.ReturnDate IS NOT NULL;
+----------+-----------------------+------------+------------+
| UserName | Title                 | BorrowDate | ReturnDate |
+----------+-----------------------+------------+------------+
| Shekhar  | The Great Gatsby      | 2024-06-01 | 2024-07-01 |
| Sumit    | To Kill a Mockingbird | 2024-07-01 | 2024-07-15 |
+----------+-----------------------+------------+------------+
