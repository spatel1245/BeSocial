-------------------------------------------------------------------------------------------------------------
-- 17.rankUsers
-- This task should produce a ranked list of users based on the number of friends they have along
-- with their number of friends.
-- Note the number of friends of a user includes those who are members of the groups user belongs
-- to.



-- JUST NEEDS TO COUNT OTHER GROUP MEMBERS AS FRIENDS!

-- DROP FUNCTION IF EXISTS rank_profiles();
-- CREATE OR REPLACE FUNCTION rank_profiles()
-- RETURNS TABLE (
--     userID INTEGER,
--     num_friends BIGINT --BECAUSE COUNT IS OF TYPE BIGINT
-- ) AS $$
-- BEGIN
--     RETURN QUERY
--         SELECT profile.userID, COUNT(friend.userID1) AS num_friends
--         FROM profile
--         LEFT JOIN friend ON friend.userID1 = profile.userID OR friend.userID2 = profile.userID
--         GROUP BY profile.userID
--         ORDER BY num_friends DESC;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- select * from rank_profiles();

--------------------------------------------------------------------------
-- SAME AS ABOVE BUT HANDLES DUPE ENTRIES IN THE FRIEND TABLE SO FRIENDSHIPS ONLY COUNTED ONCE
DROP FUNCTION IF EXISTS rank_profiles();
CREATE OR REPLACE FUNCTION rank_profiles()
RETURNS TABLE (
    userID INTEGER,
    num_friends BIGINT
) AS $$
BEGIN
    RETURN QUERY
        -- distinct_friends is a common table expression that only exists for as long as the query lasts
        WITH distinct_friends AS (
            --distinct eliminates duplicate pairs and the least and greatest orders pairs so reversed pairs considered same
            SELECT DISTINCT LEAST(userID1, userID2) AS userID1, GREATEST(userID1, userID2) AS userID2
            FROM friend
        )
        SELECT profile.userID, COUNT(distinct_friends.userID1) AS num_friends
        FROM profile
        LEFT JOIN distinct_friends ON distinct_friends.userID1 = profile.userID OR distinct_friends.userID2 = profile.userID
        GROUP BY profile.userID
        ORDER BY num_friends DESC;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rank_profiles();



-- -------------------------------------------------------------------------------------------------------------
-- 18. topMessages
-- Display the top k users with respect to the number of messages sent to the logged-in user plus
-- the number of messages received from the logged-in user in the past x months. x and k are
-- input parameters to this function. 1 month is defined as 30 days counting back starting from
-- the current date of the Clocktable. Group messages do not need to be considered in this
-- function.
-- CREATE OR REPLACE FUNCTION top_messages(user_ID INTEGER, x INTEGER, k INTEGER)
-- RETURNS TABLE (
--     userID INTEGER,
--     messages BIGINT
-- )
-- AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT p.userID, SUM(
--         CASE
--             WHEN message.fromid = user_ID THEN 1
--             WHEN message.touserid = user_ID THEN 1
--             ELSE 0
--         END
--     ) AS messages
--     FROM profile p
--     JOIN message ON p.userID = message.fromID OR p.userID = message.touserid
--     WHERE p.userID != user_ID
--         AND (message.timesent AT TIME ZONE 'UTC') > (CURRENT_DATE - (x * INTERVAL '1 month'))
--     GROUP BY p.userID, p.name
--     ORDER BY messages DESC
--     LIMIT k;
-- END;
-- $$ LANGUAGE plpgsql;

-- DROP FUNCTION IF EXISTS top_messages(integer, integer, integer);
-- CREATE OR REPLACE FUNCTION top_messages(user_ID INTEGER, x INTEGER, k INTEGER)
-- RETURNS TABLE (
--     userID INTEGER,
--     num_messages INTEGER -- change the return type to BIGINT
-- )
-- AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT profile.userID, SUM(
--         CASE
--             WHEN message.touserid = user_ID THEN 1
--             ELSE 0
--         END
--     )::INTEGER AS messages
--     FROM profile
--     JOIN message ON profile.userID = message.fromID
--     WHERE profile.userID != user_ID
--         AND message.touserid = user_ID
--         AND (message.timesent AT TIME ZONE 'UTC') > (CURRENT_DATE - (x * INTERVAL '1 month')) -- PRE UTILIZATION OF CLOCK TABLE
--     GROUP BY profile.userID, profile.name
--     ORDER BY messages DESC
--     LIMIT k;
-- END;
-- $$ LANGUAGE plpgsql;


-- NOTE: TO TEST PROPERLY MUST INSERT INTO CLOCK TABLE WITH INSERTS BELOW

DROP FUNCTION IF EXISTS top_messages(integer, integer, integer);
CREATE OR REPLACE FUNCTION top_messages(user_ID INTEGER, x INTEGER, k INTEGER)
RETURNS TABLE (
    userID INTEGER,
    num_messages INTEGER -- change the return type to BIGINT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT profile.userID, SUM(
        CASE
            WHEN message.touserid = user_ID THEN 1
            ELSE 0
        END
    )::INTEGER AS messages
    FROM profile
    JOIN message ON profile.userID = message.fromID
    JOIN clock ON 1 = 1
    WHERE profile.userID != user_ID
        AND message.touserid = user_ID
        AND (message.timesent) >= ((SELECT clock.pseudo_time FROM clock) - (x * INTERVAL '30 days'))
    GROUP BY profile.userID, profile.name
    ORDER BY messages DESC
    LIMIT k;
END;
$$ LANGUAGE plpgsql;

-- TESTING TOPMESSAGES

INSERT INTO clock VALUES ('2022-01-01 00:00:00');

INSERT INTO profile VALUES (1, 'Lisa Robinson', 'kingkimberly@example.com', '_9QwOuHC', '1998-09-09', '2022-06-16T16:51:28');
INSERT INTO profile VALUES (2, 'Jessica Savage', 'stephen69@example.org', 'T#wv4ZPs', '1983-02-23', '2022-09-22T11:32:03');
INSERT INTO profile VALUES (3, 'Jack Moore MD', 'emeza@example.org', '^4H@6usa', '1962-06-04', '2022-06-15T22:44:41');
INSERT INTO profile VALUES (4, 'Ryan Vargas', 'cbarrett@example.net', 'I%7VHugz', '1959-05-06', '2022-09-15T11:37:42');
INSERT INTO profile VALUES (5, 'Kevin Horn', 'xmosley@example.net', 'Z$1ZV@$q', '1963-03-15', '2022-09-11T03:00:03');
INSERT INTO profile VALUES (6, 'Carrie Shaw', 'jodijohns@example.com', '!p5BtmJr', '1926-11-03', '2022-12-19T00:10:32');
INSERT INTO profile VALUES (7, 'Michael Pittman', 'butlerjennifer@example.org', '(!3E8war', '2007-06-08', '2022-08-29T05:35:51');
INSERT INTO profile VALUES (8, 'Felicia Ewing', 'megan43@example.net', ')I6FbWG4', '1978-09-16', '2022-06-26T00:26:20');
INSERT INTO profile VALUES (9, 'Ryan Wood', 'christophergomez@example.org', '^1l0$Wzu', '1989-01-21', '2022-11-27T23:34:42');
INSERT INTO profile VALUES (10, 'Rodney Brooks', 'maureen09@example.com', '+e2VYqO%', '1929-01-05', '2022-07-09T07:10:37');


-- Assume we are logged in as UserID=1
Insert into message values(1,2,'Hi!', 1, null, '2021-12-21');
Insert into message values(2,3,'Hi!', 1, null, '2021-12-21');
Insert into message values(3,4,'Hi!', 1, null, '2021-12-21');
Insert into message values(4,2,'Hi!', 1, null, '2021-12-21');
Insert into message values(5,4,'Hi!', 1, null, '2021-12-21');
Insert into message values(7,3,'Hi!', 1, null, now());
Insert into message values(8,4,'Hi!', 1, null, now());
Insert into message values(9,4,'Hi!', 1, null, '2021-10-01');


select * from top_messages(1,2, 10);

Insert into message values(10,1,'Hi!',2, null, now()); --SHOULD NOT CHANGE RESULTING TABLE AS THIS IS A MESSAGE USER 1 SENT
Insert into message values(11,2,'Hi!',1, null, now());
Insert into message values(12,2,'Hi!',1, null, '2023-01-01'); --FUTURE MESSAGE SHOULD NOT WORK AS IT DOESNT MAKE SENSE