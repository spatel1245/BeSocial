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
