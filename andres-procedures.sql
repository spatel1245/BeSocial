-------------------------------------------------------------------------------------------------------------
-- 17.rankUsers
-- This task should produce a ranked list of users based on the number of friends they have along
-- with their number of friends.
-- Note the number of friends of a user includes those who are members of the groups user belongs
-- to.



-- JUST NEEDS TO COUNT OTHER GROUP MEMBERS AS FRIENDS!

DROP FUNCTION IF EXISTS rank_profiles();
CREATE OR REPLACE FUNCTION rank_profiles()
RETURNS TABLE (
    userID INTEGER,
    num_friends BIGINT --BECAUSE COUNT IS OF TYPE BIGINT
) AS $$
BEGIN
    RETURN QUERY
        SELECT profile.userID, COUNT(friend.userID1) AS num_friends
        FROM profile
        LEFT JOIN friend ON friend.userID1 = profile.userID OR friend.userID2 = profile.userID
        GROUP BY profile.userID
        ORDER BY num_friends DESC;
END;
$$ LANGUAGE plpgsql;

select * from rank_profiles();




-- -------------------------------------------------------------------------------------------------------------
