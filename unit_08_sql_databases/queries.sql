/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/

The username for the platform is "student", and the password
is "learn_sql@springboard".

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "bookings" table,
    ii) the "facilities" table, and
    iii) the "members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */
/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT *
FROM   facilities
WHERE  membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */
SELECT Count(*)
FROM   facilities
WHERE  membercost = 0;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid,
       NAME,
       membercost,
       monthlymaintenance
FROM   facilities
WHERE  membercost > 0
       AND ( membercost < monthlymaintenance / 5.0 );

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT *
FROM   facilities
WHERE  facid IN ( 1, 5 );

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT NAME,
       CASE
         WHEN monthlymaintenance > 100 THEN 'expensive'
         ELSE 'cheap'
       END AS "cost"
FROM   facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname,
       surname,
       joindate
FROM   members
WHERE  joindate = (SELECT Max(joindate)
                   FROM   members);

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT DISTINCT firstname
                || ' '
                || surname AS member,
                NAME       AS facility
FROM   members
       INNER JOIN bookings
               ON members.memid = bookings.memid
       INNER JOIN facilities
               ON bookings.facid = facilities.facid
WHERE  NAME LIKE '%Tennis Court%'
ORDER  BY member;

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT firstname
       || ' '
       || surname AS member,
       NAME       AS facility,
       CASE
         WHEN firstname = 'GUEST' THEN guestcost * slots
         ELSE membercost * slots
       END        AS cost
FROM   members
       INNER JOIN bookings
               ON members.memid = bookings.memid
       INNER JOIN facilities
               ON bookings.facid = facilities.facid
WHERE  starttime >= '2012-09-14'
       AND starttime < '2012-09-15'
       AND CASE
             WHEN firstname = 'GUEST' THEN guestcost * slots
             ELSE membercost * slots
           END > 30
ORDER  BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
SELECT firstname
       || ' '
       || surname AS member,
       NAME       AS facility,
       cost
FROM   (SELECT firstname,
               surname,
               NAME,
               CASE
                 WHEN firstname = 'GUEST' THEN guestcost * slots
                 ELSE membercost * slots
               END AS cost,
               starttime
        FROM   members
               INNER JOIN bookings
                       ON members.memid = bookings.memid
               INNER JOIN facilities
                       ON bookings.facid = facilities.facid) AS inner_table
WHERE  starttime >= '2012-09-14'
       AND starttime < '2012-09-15'
       AND cost > 30
ORDER  BY cost DESC;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT NAME,
       revenue
FROM   (SELECT NAME,
               Sum(CASE
                     WHEN memid = 0 THEN guestcost * slots
                     ELSE membercost * slots
                   END) AS revenue
        FROM   cd.bookings
               INNER JOIN cd.facilities
                       ON cd.bookings.facid = cd.facilities.facid
        GROUP  BY NAME) AS inner_table
WHERE  revenue < 1000
ORDER  BY revenue;

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT Concat(m.firstname, ' ', m.surname)       AS Recommended_By,
       Concat(rcmd.firstname, ' ', rcmd.surname) AS Member
FROM   members m
       INNER JOIN members rcmd
               ON rcmd.recommendedby = m.memid
WHERE  m.memid > 0
ORDER  BY m.surname,
          m.firstname,
          rcmd.surname,
          rcmd.surname

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT f.NAME,
       Concat(m.firstname, ' ', m.surname) AS Member,,
Count(f.NAME)                       AS bookings
FROM   members m
       INNER JOIN bookings bk
               ON bk.memid = m.memid
       INNER JOIN facilities f
               ON f.facid = bk.facid
WHERE  m.memid > 0
GROUP  BY f.NAME,
          Concat(m.firstname, ' ', m.surname)
ORDER  BY f.NAME,
          m.surname,
          m.firstname

/* Q13: Find the facilities usage by month, but not guests */
SELECT f.NAME,
       Concat(m.firstname, ' ', m.surname) AS Member,
       Count(f.NAME)                       AS bookings,
       Sum(CASE
             WHEN Month(starttime) = 1 THEN 1
             ELSE 0
           END)                            AS Jan,
       Sum(CASE
             WHEN Month(starttime) = 2 THEN 1
             ELSE 0
           END)                            AS Feb,
       Sum(CASE
             WHEN Month(starttime) = 3 THEN 1
             ELSE 0
           END)                            AS Mar,
       Sum(CASE
             WHEN Month(starttime) = 4 THEN 1
             ELSE 0
           END)                            AS Apr,
       Sum(CASE
             WHEN Month(starttime) = 5 THEN 1
             ELSE 0
           END)                            AS May,
       Sum(CASE
             WHEN Month(starttime) = 6 THEN 1
             ELSE 0
           END)                            AS Jun,
       Sum(CASE
             WHEN Month(starttime) = 7 THEN 1
             ELSE 0
           END)                            AS Jul,
       Sum(CASE
             WHEN Month(starttime) = 8 THEN 1
             ELSE 0
           END)                            AS Aug,
       Sum(CASE
             WHEN Month(starttime) = 9 THEN 1
             ELSE 0
           END)                            AS Sep,
       Sum(CASE
             WHEN Month(starttime) = 10 THEN 1
             ELSE 0
           END)                            AS Oct,
       Sum(CASE
             WHEN Month(starttime) = 11 THEN 1
             ELSE 0
           END)                            AS Nov,
       Sum(CASE
             WHEN Month(starttime) = 12 THEN 1
             ELSE 0
           END)                            AS Decm
FROM   members m
       INNER JOIN bookings bk
               ON bk.memid = m.memid
       INNER JOIN facilities f
               ON f.facid = bk.facid
WHERE  m.memid > 0
       AND Year(starttime) = 2012
GROUP  BY f.NAME,
          Concat(m.firstname, ' ', m.surname)
ORDER  BY f.NAME,
          m.surname,
          m.firstname
