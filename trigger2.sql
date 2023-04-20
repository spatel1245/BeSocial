----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                                        --TRIGGERS
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------
-- TRIGGER 1 ADD_MESSAGE_RECIPIENT
-- adds a corresponding entry into the messageRecipient relation
-- upon adding a new message to the message relation
-----------------------------------------------------------------
DROP TRIGGER if EXISTS add_message_recipient on message;
CREATE TRIGGER add_message_recipient
    AFTER INSERT ON message
    FOR EACH ROW
EXECUTE FUNCTION add_message_recipient();

CREATE OR REPLACE FUNCTION add_message_recipient()
    RETURNS TRIGGER
AS $$
DECLARE
    _userid Integer;
BEGIN
    IF(NEW.touserid IS NOT NULL)
    THEN
        INSERT INTO messagerecipient (msgID, userID) VALUES (NEW.msgID, NEW.touserid);
        return new;
    ELSE
        FOR _userid IN (SELECT g.userid FROM groupmember g WHERE g.gid = NEW.toGroupId) LOOP
                INSERT INTO messagerecipient (msgID, userID) VALUES (new.msgid, _userid);
        END LOOP;
        return new;
    END IF;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER if EXISTS add_message_recipient on message;
CREATE TRIGGER add_message_recipient
    AFTER INSERT ON message
    FOR EACH ROW
EXECUTE FUNCTION add_message_recipient();

------------------------------------------------------------
--END TRIGGER 1
-----------------------------------------------------------

-----------------------------------------------------------------
-- TRIGGER 2 updateGroup
-- which moves a pending accepted request in the pendingGroupMember relation to
-- the groupMember relation when a member leaves the group.
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION updateGroup()
    RETURNS TRIGGER
AS $$
BEGIN

    DECLARE
        rec_updateGroup RECORD;

        sizelimit integer;
        curSize integer;
        curTime timestamp;
    BEGIN
        SELECT INTO curTime pseudo_time FROM clock LIMIT 1;
        SELECT COUNT(gid) FROM groupinfo WHERE old.gid=groupinfo.gid INTO curSize;
        FOR rec_updateGroup IN SELECT userId,gid FROM pendinggroupmember WHERE pendinggroupmember.gid=old.gid ORDER BY pendinggroupmember.requesttime
            LOOP
                SELECT size FROM groupinfo WHERE old.gid=groupinfo.gid INTO sizelimit;

                if(curSize<sizelimit) THEN
                    INSERT INTO groupmember (gID, userid, role,lastconfirmed) values (rec_updateGroup.gid, rec_updateGroup.userID, 'member', old.lastconfirmed);
                    DELETE FROM pendinggroupmember WHERE rec_updateGroup.userid=pendinggroupmember.userid AND rec_updateGroup.gid=pendinggroupmember.gid;
                    SELECT COUNT(gid) FROM groupinfo WHERE old.gid=groupinfo.gid INTO curSize;
                    SELECT size FROM groupinfo WHERE old.gid=groupinfo.gid INTO sizelimit;
                end if;
            end loop;

        Return old;
    end;--
END
$$ LANGUAGE plpgsql;

DROP TRIGGER if EXISTS updateGroup on groupmember;
CREATE TRIGGER updateGroup
    AFTER DELETE ON groupmember
    FOR EACH ROW
EXECUTE FUNCTION updateGroup();

-----------------------------------------------------------------
--END TRIGGER 2  updateGroup
-----------------------------------------------------------------

-----------------------------------------------------------------
--TRIGGER 3 delete_pending_friendRequest
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION delete_pending_friendRequest()
    RETURNS TRIGGER
AS $$
BEGIN
    DELETE FROM pendingfriend WHERE pendingFriend.userID1= NEW.userID1 AND
            pendingFriend.userID2= New.userID2;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER if EXISTS delete_pending_friendRequest on friend;
CREATE TRIGGER delete_pending_friendRequest
    AFTER INSERT ON friend
    FOR EACH ROW
EXECUTE FUNCTION delete_pending_friendRequest();

-----------------------------------------------------------------
--END TRIGGER 3 delete_pending_friendRequest
-----------------------------------------------------------------

-----------------------------------------------------------------
--TRIGGER 4 removeFromAllGroups
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION removeFromAllGroups()
    RETURNS TRIGGER
AS $$

--Should we assume that he was already excepted
BEGIN

    DELETE FROM groupmember WHERE old.userID=userid;

    return old;
END


$$ LANGUAGE plpgsql;

DROP TRIGGER if EXISTS removeFromAllGroups on profile;

CREATE TRIGGER removeFromAllGroups
    BEFORE DELETE ON profile
    FOR EACH ROW
EXECUTE FUNCTION removeFromAllGroups();

-----------------------------------------------------------------
--END TRIGGER 4 removeFromALLGROUP
-----------------------------------------------------------------

-----------------------------------------------------------------

-- TRIGGER 5 removeDeletedUserMessages
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION removeDeletedUserMessages()
    RETURNS TRIGGER
AS $$

--Should we assume that he was already excepted
BEGIN

    DECLARE
        rec_deletedUsers RECORD;
        prof_count1 int;
        prof_count2 int;

    BEGIN
        FOR rec_deletedUsers IN SELECT touserid,msgID,fromID FROM message WHERE old.userID=touserid OR old.userID=fromID
            LOOP
                SELECT COUNT(userid=rec_deletedUsers.touserid) FROM profile INTO prof_count1;
                SELECT COUNT(userid=rec_deletedUsers.fromid) FROM profile INTO prof_count2;

                IF (prof_count1>1) AND (prof_count2>1) THEN

--         DELETE FROM message WHERE message.msgID=rec_deletedUsers.msgID;
                END IF;


            end loop;
        return old;
    END;
END

    --
--  $$ LANGUAGE plpgsql;


DROP TRIGGER if EXISTS removeDeletedUserMessages on profile;
CREATE TRIGGER removeDeletedUserMessages
    BEFORE DELETE ON profile
    FOR EACH ROW
EXECUTE FUNCTION removeDeletedUserMessages();

-----------------------------------------------------------------
--END TRIGGER 5 removeDeletedUserMessages
-----------------------------------------------------------------





----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                                    --FUNCTIONS AND PROCEDURES
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------



--1. createProfile
-- Given a name, email address, password and date of birth, add a new user to the system by
-- inserting a new entry into the profile relation. userIDs should be auto-generated.
-----------------------------------------------------------------

-- 2. dropProfile
-- This functions prompts for a user email and removes the profile along with all of their informa-
-- tion from the system. When a profile is removed, the system should use a trigger to delete
-- the user from the groups they are a member of. The system should also use a trigger to
-- delete any message whose sender and all receivers are deleted. Attention should be paid to
-- handling integrity constraints.
-----------------------------------------------------------------

-- 3. login
-- Given email and password, login as the user in the system when an appropriate match is found.
-----------------------------------------------------------------

-- 4. initiateFriendship
-- Create a pending friendship from the logged-in user profile to another user profile based on
-- userID. The application should display the name of the person that will be sent a friend request
-- and the user should be prompted to enter the text to be sent along with the request. A last
-- confirmation should be requested of the user before an entry is inserted into the pendingFriend
-- relation, and success or failure feedback is displayed for the user.
-----------------------------------------------------------------

-- 5. confirmFriendRequests (PROCEDURE NAMED add_select_friend_reqs)
-- This task should first display a formatted, numbered list of all the outstanding friend requests
-- with the associated request text. Then the user should be prompted for a number of the request
-- they would like to confirm, one at a time, or given the option to confirm them all.
-- The application should move the selected request(s) from the pendingFriend relation to the
-- friend relation with JDate set to the current date of the Clock table.
-- The remaining requests which were not selected are declined and removed from the pend-
-- ingFriend relation.
-- In the event that the user has no pending friend requests, a message “No Pending Friend
-- Requests” should be displayed to the user.
-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE add_select_friend_reqs(current_userID integer, userID_list integer[])
AS $$
DECLARE
    i integer;
    curTime timestamp;
BEGIN
    SELECT INTO curTime pseudo_time FROM clock LIMIT 1;
    FOR i IN 1..array_length(userID_list, 1) LOOP
            INSERT INTO friend (userID1, userID2, JDate) VALUES (current_userID, userID_list[i], curTime);
        END LOOP;

    DELETE FROM pendingfriend WHERE pendingfriend.userid2=current_userID;

END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END PROCEDURE 5 confirmFriendRequests
-----------------------------------------------------------------

-- 6. createGroup
-- Given a name, description, and membership limit (i.e., size), add a new group to the system,
-- add the current user as its first member with the role manager. gIDs should be auto-generated.
-----------------------------------------------------------------
DROP PROCEDURE if EXISTS createGroup(name varchar(50), size int, description varchar(200), userid int);
CREATE OR REPLACE PROCEDURE createGroup (_name varchar(50),_size int,_description varchar(200),_userid int)
AS $$
DECLARE
    group_id integer;
    curTime timestamp;
BEGIN
    SELECT INTO curTime pseudo_time FROM clock LIMIT 1;
    INSERT INTO groupinfo VALUES (DEFAULT, _name, _size, _description);
    SELECT last_value(gid)
           OVER (ORDER BY gid
               RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
    INTO group_id
    FROM groupinfo;

    INSERT INTO groupmember VALUES (group_id, _userid, 'manager', curTime);

END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END PROCEDURE 6 createGroup
-----------------------------------------------------------------

-- 7. initiateAddingGroup (PROCEDURE NAMED createPendingGroupMember)
-- Given a group ID and the request’s text, create a pending request of adding the logged-in user
-- to the group by inserting a new entry into the pendingGroupMember relation.
-----------------------------------------------------------------
DROP PROCEDURE IF EXISTS createPendingGroupMember(group_id integer, user_id integer, _requesttext varchar(200));
CREATE OR REPLACE PROCEDURE createPendingGroupMember(group_id integer,user_id integer, _requesttext varchar(200))
AS $$
DECLARE
    curTime timestamp;
BEGIN
    SELECT INTO curTime pseudo_time FROM clock LIMIT 1;
    INSERT INTO pendinggroupmember VALUES (group_id,user_id, _requesttext, curTime);
END;
$$ LANGUAGE plpgsql;
-----------------------------------------------------------------
--END PROCEDURE 7 confirmFriendRequests
-----------------------------------------------------------------

-- 8. confirmGroupMembership (PROCEDURE NAMED confirmGroupMembers)
-- This task should first display a formatted, numbered list of all the pending group membership
-- requests with the associated request text for any groups where the user is a group manager.
-- Then, the user should be prompted for a number of the request they would like to confirm, one
-- at a time, or given the option to confirm them all.
-- The application should move the selected request(s) from the pendingGroupMember relation
-- to the groupMember relation using the current time in Clock for the lastConfirmed timestamp.
-- If accepting a pending group membership request would exceed the group’s size, the accepted
-- request should remain in pendingGroupMember.
-- The remaining requests which were not selected are declined and removed from the pending-
-- GroupMember relation.
-- In the event that there are no pending group membership requests for any groups that the user
-- is a manager of, a message “No Pending Group Membership Requests” should be displayed to
-- the user. Furthermore, a message “No groups are currently managed” should be displayed if
-- the user is not a manager of any groups.
-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE confirmGroupMembers(group_id integer, pendingMember_list integer[])
AS $$
DECLARE
    i integer;
    curGroupSize integer;
    sizeLimit integer;
    curtime timestamp;
BEGIN
    SELECT INTO curTime pseudo_time FROM clock LIMIT 1;
    SELECT COUNT(userID) FROM groupmember WHERE groupmember.gID=group_id INTO curGroupSize;
    SELECT size FROM groupinfo WHERE groupinfo.gID=group_id INTO sizelimit;
    FOR i IN 1..array_length(pendingMember_list, 1) LOOP
            if(curGroupSize<sizeLimit) then
                INSERT INTO groupmember VALUES (group_id,pendingMember_list[i],'member',curtime);
                SELECT COUNT(userID) FROM groupmember WHERE groupmember.gID=group_id INTO curGroupSize;
                SELECT size FROM groupinfo WHERE groupinfo.gID=group_id INTO sizelimit;
            else
                return;
            end if;
        END LOOP;

    DELETE FROM pendinggroupmember WHERE pendinggroupmember.gid=group_id;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END PROCEDURE 8 confirmGroupMembers
-----------------------------------------------------------------

-- 9. leaveGroup
-- This task should first prompt the user for the gID of the group they would like to leave.
-- The application should remove the user from the group in the groupMember relation. Upon
-- removing the user from the group, you should use a trigger to check if there are pending
-- group membership requests in pendingGroupMember that were previously accepted, but could
-- not be added due exceeding the group’s size, and move the earliest such request from the pend-
-- ingGroupMember relation to the groupMember relation without changing the lastConfirmed
-- timestamp.
-- In the event that the user is not a member of the specified group, a message “Not a Member
-- of any Groups” should be displayed to the user.
-----------------------------------------------------------------

-- 10. searchForProfile (FUNCTION NAMED search_user_profiles)
-- Given a string on which to match any user profile in the system, any item in this string must be
-- matched against the “name” and “email” fields of a user’s profile. That is if the user searches
-- for “xyz abc”, the results should be the set of all user profiles that have “xyz” in their “name”
-- or “email” union the set of all user profiles that have “abc” in their “name” or “email”.
-----------------------------------------------------------------
DROP FUNCTION IF EXISTS search_user_profiles(search_strings TEXT[]);

CREATE OR REPLACE FUNCTION search_user_profiles(substringList TEXT[])
RETURNS TABLE (userID INTEGER, name VARCHAR(50)) AS $$

DECLARE
    combinedSearchQuery TEXT;
    i INTEGER;
BEGIN
    combinedSearchQuery := 'SELECT userID, name FROM profile WHERE';
    FOR i IN 1..array_length(substringList, 1) LOOP
            combinedSearchQuery := combinedSearchQuery || ' profile.name LIKE ''%' || substringList[i] ||
                                   '%'' OR profile.email LIKE ''%' || substringList[i] || '%''';
            IF i <> array_length(substringList, 1) THEN
                combinedSearchQuery := combinedSearchQuery || ' OR';
            END IF;
    END LOOP;
    RETURN QUERY EXECUTE combinedSearchQuery;
END;
$$ LANGUAGE plpgsql;
-----------------------------------------------------------------
--END FUNCTION 10 searchForProfile
-----------------------------------------------------------------


-- 11. sendMessageToUser (PROCEDURE NAMED send_message_to_friend)
-- With this the user can send a message to one friend given the friend’s userID. The application
-- should display the name of the recipient and the user should be prompted to enter the body
-- of the message, which could be multi-lined. Once entered, the application should “send” the
-- message to the receiving user by adding an appropriate entry into the message relation (msgIDs
-- should be auto-generated and timeSent should be set to the current time of the Clock table)
-- and use a trigger to add a corresponding entry into the messageRecipient relation. The user
-- should lastly be shown success or failure feedback.
-----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE send_message_to_friend(user_id INTEGER, friend_id INTEGER, message_body varchar(200))
AS $$
DECLARE
    curTime timestamp;
BEGIN
    SELECT INTO curTime pseudo_time FROM clock LIMIT 1;
    INSERT INTO message VALUES (default, user_id, message_body, friend_id, NULL, curTime); -- will implicitly call add_message_recipient()
END;
$$ LANGUAGE plpgsql;
-----------------------------------------------------------------
--END PROCEDURE 11 sendMessageToUser
-----------------------------------------------------------------

-- 12. sendMessageToGroup (PROCEDURE NAMED send_message_to_group)
-- With this the user can send a message to a recipient group given the group ID, if the user is
-- within the group. Every member of this group should receive the message. The user should be
-- prompted to enter the body of the message, which could be multi-lined. Then the application
-- should “send” the message to the group by adding an appropriate entry into the message
-- relation (msgIDs should be auto-generated and timeSent should be set to the current time of
-- the Clock table) and use a trigger to add corresponding entries into the messageRecipient
-- relation. The user should lastly be shown success or failure feedback.
-- Note that if the user sends a message to one friend, you only need to put the friend’s userID
-- to ToUserID in the table of message. If the user wants to send a message to a group, you need
-- to put the group ID to ToGroupID in the table of message and use a trigger to populate
-- the messageRecipient table with proper user ID information as defined by the groupMember
-- relation.
-----------------------------------------------------------------
DROP PROCEDURE IF EXISTS send_message_to_group;
CREATE OR REPLACE PROCEDURE send_message_to_group(user_id INTEGER, group_id INTEGER, message_body varchar(200))
AS $$
DECLARE
    curTime timestamp;
BEGIN
    SELECT INTO curTime pseudo_time FROM clock LIMIT 1;
    -- Insert the new message into the message table
    INSERT INTO message VALUES (default, user_id, message_body, NULL, group_id, curTime); -- will implicitly call add_message_recipient()
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END PROCEDURE 12 sendMessageToGroup
-----------------------------------------------------------------

-- 13. displayMessages (FUNCTION NAMED display_messages)
-- When the user selects this option, the entire contents of every message sent to the user (in-
-- cluding group messages) should be displayed in a nicely formatted way.
-----------------------------------------------------------------
DROP FUNCTION IF EXISTS display_messages;
CREATE OR REPLACE FUNCTION display_messages(user_id INTEGER)
    RETURNS SETOF message
AS $$
BEGIN
    RETURN QUERY -- allows for the returned table to "communicate" with the tables we have
        SELECT
            m.msgid, m.fromid, m.messagebody, m.touserid, m.togroupid, m.timesent
        FROM
            message m JOIN messageRecipient r ON m.msgID = r.msgID
        WHERE
                r.userID = user_id
        ORDER BY
            timeSent DESC;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 13 displayMessages
-----------------------------------------------------------------

-- 14. displayNewMessages (FUNCTION NAMED display_new_messages)
-- This should display messages in the same fashion as the previous task except that only those
-- messages sent since the last time the user logged into the system should be displayed (including
-- group messages).
-----------------------------------------------------------------
DROP FUNCTION IF EXISTS display_new_messages(integer);
CREATE OR REPLACE FUNCTION display_new_messages(user_id INTEGER)
    RETURNS SETOF message
AS $$
BEGIN
    RETURN QUERY
        SELECT
            m.msgid, m.fromid, m.messagebody, m.touserid, m.togroupid, m.timesent
        FROM
            message m
                JOIN messageRecipient r ON m.msgID = r.msgID
                JOIN profile p ON m.fromID = p.userID
        WHERE
                r.userID = user_id
          AND m.timeSent > (SELECT lastLogin FROM profile p WHERE p.userID = user_id)
        ORDER BY
            timeSent DESC;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 14 displayNewMessages
-----------------------------------------------------------------

-- 15. displayFriends (FUNCTION CALLED display_friends)
-- This task supports the browsing of the logged-in user’s friends’ profiles. It first displays each
-- of the user’s friends’ names and userIDs. Then it allows the user to either retrieve a friend’s
-- entire profile by entering the appropriate userID or exit browsing and return to the main menu
-- by entering 0 as a userID. When selected, a friend’s profile should be displayed in a nicely
-- formatted way, after which the user should be prompted to either select to retrieve another
-- friend’s profile or return to the main menu.
-----------------------------------------------------------------


-- THIS IS A FUNCTION THAT RETURNS A TABLE TO BE USED BY THE display_friends() FUNCTION
DROP FUNCTION IF EXISTS list_of_friend_IDs(_userID integer);

CREATE OR REPLACE FUNCTION list_of_friend_IDs(_userID integer)
    RETURNS TABLE (userID integer) AS $$
BEGIN
    RETURN QUERY
        SELECT f.userid2 FROM friend f WHERE f.userID1 = _userID
        UNION
        SELECT f.userid1 FROM friend f WHERE f.userID2 = _userID;
END;
$$ LANGUAGE plpgsql;

------------------------ displayFriends FUNCTION---------------------
DROP FUNCTION IF EXISTS display_friends();

CREATE OR REPLACE FUNCTION display_friends(_userID integer)
    RETURNS SETOF profile AS $$
DECLARE
    friendIDs INTEGER[];
BEGIN
    SELECT ARRAY_AGG(userID) INTO friendIDs FROM list_of_friend_IDs(_userID);
    RETURN QUERY
        SELECT * FROM profile WHERE profile.userID = ANY(friendIDs);
END;
$$ LANGUAGE plpgsql;

-- ADDITIONAL CORRESPONDING FUNCTION ---------------------------
CREATE OR REPLACE FUNCTION displayDetailFriend(user_id integer)
    RETURNS SETOF profile AS $$
BEGIN

    RETURN QUERY SELECT * FROM profile Where user_id=profile.userid;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 15 displayFriends
-----------------------------------------------------------------

-- 16. rankGroups (FUNCTION CALLED group_size_ranked)
-- This task should produce a ranked list of groups based on their number of members.
-- In the event that there are no groups in the system, a message “No Groups to Rank” should
-- be displayed to the user.
-----------------------------------------------------------------
DROP FUNCTION IF EXISTS group_size_ranked();
CREATE OR REPLACE FUNCTION group_size_ranked()
    RETURNS TABLE (group_id integer, total integer) AS $$
BEGIN
     RETURN QUERY
        SELECT groupinfo.gid, COUNT(userID)::integer
        FROM groupmember
            JOIN  groupinfo ON groupinfo.gid=groupmember.gid
            GROUP BY groupinfo.gid
            ORDER BY COUNT(userID) DESC;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 16 rankGroups
-----------------------------------------------------------------

-- 17. rankProfiles (FUNCTION NAMED rank_profiles)
-- This task should produce a ranked list of user profiles based on the number of friends they
-- have along with their number of friends.
-- Note the number of friends of a profile includes those who are members of the groups the user
-- profile belongs to.
-----------------------------------------------------------------
DROP FUNCTION IF EXISTS rank_profiles();
CREATE OR REPLACE FUNCTION rank_profiles()
RETURNS TABLE (
    userID INTEGER,
    num_friends BIGINT
) AS $$
BEGIN
    DECLARE
    rec_temporaryAdd RECORD;

BEGIN
    DROP TABLE IF EXISTS t1;
    CREATE TEMPORARY TABLE t1(userid1 integer, userid2 integer);
FOR rec_temporaryAdd IN SELECT
        g1.gid, g1.userid AS userid1, g2.userid AS userid2
    FROM
        groupmember g1
    LEFT JOIN groupmember g2 on g1.gid=g2.gid
    WHERE g2.userid != g1.userid AND g1.userid<g2.userid
    ORDER BY
        g1.gid
LOOP
    INSERT INTO t1 VALUES(rec_temporaryAdd.userid1,rec_temporaryAdd.userid2);


    end loop;

FOR rec_temporaryAdd IN SELECT
        friend.userid1 AS u1, friend.userid2 AS u2
    FROM
        friend
LOOP
    INSERT INTO t1 VALUES(rec_temporaryAdd.u1,rec_temporaryAdd.u2);
 end loop;


    RETURN QUERY
        -- distinct_friends is a common table expression that only exists for as long as the query lasts
        WITH distinct_friends AS (
            --distinct eliminates duplicate pairs and the least and greatest orders pairs so reversed pairs considered same
            SELECT DISTINCT LEAST(userID1, userID2) AS userID1, GREATEST(userID1, userID2) AS userID2
            FROM t1
        )
        SELECT profile.userID, COUNT(distinct_friends.userID1) AS num_friends
        FROM profile
        LEFT JOIN distinct_friends ON distinct_friends.userID1 = profile.userID OR distinct_friends.userID2 = profile.userID
        GROUP BY profile.userID
        ORDER BY num_friends DESC;
END;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 17 rankProfiles
-----------------------------------------------------------------

-- 18. topMessages (FUNCTION NAMED top_messages)
-- Display the top k users with respect to the number of messages sent to the logged-in user plus
-- the number of messages received from the logged-in user in the past x months. x and k are
-- input parameters to this function. 1 month is defined as 30 days counting back starting from
-- the current date of the Clock table. Group messages do not need to be considered in this
-- function.
-----------------------------------------------------------------
DROP FUNCTION IF EXISTS top_messages(integer, integer, integer);
CREATE OR REPLACE FUNCTION top_messages(user_ID INTEGER, x INTEGER, k INTEGER)
RETURNS TABLE (
    userID INTEGER,
    num_messages INTEGER -- change the return type to BIGINT
)
AS $$
DECLARE
    curTime timestamp;
    month interval;
BEGIN
    month:=interval '30 days';
    SELECT INTO curTime pseudo_time FROM clock LIMIT 1;
    RETURN QUERY
    SELECT profile.userID, SUM(
        CASE
            WHEN message.touserid = user_ID THEN 1
            ELSE 0
        END
    )::INTEGER AS messages
    FROM profile
    JOIN message ON profile.userID = message.fromID
--     JOIN clock ON 1 = 1
    WHERE profile.userID != user_ID
      AND message.touserid = user_ID
      AND (message.timesent) >= ((curTime) - (x * month))
    AND message.timesent <= curTime
    GROUP BY profile.userID
    ORDER BY messages DESC
    LIMIT k;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 18 topMessages
-----------------------------------------------------------------

-- 19. threeDegrees
-- Given a userID, find a path, if one exists, between the logged-in user and that user profile with
-- at most 3 hops between them. A hop is defined as a friendship between any two users.
-- This query should be written using plpgsql and should only use java for interfacing.
-----------------------------------------------------------------
DROP FUNCTION IF EXISTS threeDegrees(loggedInUserID INTEGER, targetUserID INTEGER);
CREATE OR REPLACE FUNCTION threeDegrees(loggedInUserID INTEGER, targetUserID INTEGER)
    RETURNS INTEGER[] AS $$
DECLARE
    path INTEGER[] := ARRAY[loggedInUserID];
    visited INTEGER[] := ARRAY[loggedInUserID];
    distance INTEGER := 0;
    nextVisited INTEGER[];
    id INTEGER;
    friendID INTEGER;
    tempIDList INTEGER[];
BEGIN
    IF loggedInUserID = targetUserID THEN
        RETURN path;
    END IF;

    WHILE distance < 3 AND path <> '{}' LOOP
            nextVisited := '{}';
            FOREACH id IN ARRAY visited LOOP
                    tempIDList := array_agg(userID) FROM list_of_friend_IDs(id) WHERE userID IS NOT NULL;
                    IF tempIDList<>'{}' THEN
                        FOREACH friendID IN ARRAY tempIDList LOOP
                            IF friendID = targetUserID THEN
                                RETURN path || friendID;
                            END IF;
                            IF NOT friendID = ANY(visited) THEN
                                nextVisited := nextVisited || friendID;
                            END IF;
                        END LOOP;
                    END IF;
            END LOOP;
            distance := distance + 1;
            IF array_length(nextVisited, 1) > 0 THEN
                path := path || ARRAY[nextVisited[array_upper(nextVisited, 1)]];
                visited := visited || ARRAY[nextVisited[array_upper(nextVisited, 1)]];
            END IF;
    END LOOP;
    RETURN '{}';

end $$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 19 threeDegrees
-----------------------------------------------------------------

-- 20. logout (PROCEDURE NAMED update_last_login)
-- The function should return the user to the top level of the UI after marking the time of the
-- user’s logout in the user’s “lastlogin” field of the user relation from the Clock table.
-----------------------------------------------------------------
DROP PROCEDURE IF EXISTS update_last_login(user_ID int);
CREATE OR REPLACE PROCEDURE update_last_login(user_ID INTEGER)

AS $$
DECLARE
    curTime timestamp;
BEGIN
    SELECT INTO curTime pseudo_time FROM clock LIMIT 1;
    UPDATE profile SET lastLogin = curTime WHERE userID = user_ID;
END;
$$ LANGUAGE plpgsql;
-----------------------------------------------------------------
--END PROCEDURE 20 update_last_login
-----------------------------------------------------------------

-- 21. exit
-- This option should cleanly shut down and exit the program.
-----------------------------------------------------------------



----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------

                                                                        --ADDITIONAL FUNCTIONS AND VIEWS
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------


-----------------------------------------------------------------
-- VIEW 1 group_reqs_to_accept
-----------------------------------------------------------------

DROP VIEW IF EXISTS group_reqs_to_accept;

CREATE VIEW group_reqs_to_accept AS
SELECT p.*
FROM pendingGroupMember p
         JOIN groupMember g ON p.gID = g.gID
WHERE p.userID = 0 AND g.role = 'manager';
-----------------------------------------------------------------
-- END VIEW 1 group_reqs_to_accept
-----------------------------------------------------------------

-----------------------------------------------------------------
-- ADDITIONAL FUNCTION 1 get_pending_members
-----------------------------------------------------------------
DROP FUNCTION IF EXISTS get_pending_members(user_id INTEGER);

CREATE OR REPLACE FUNCTION get_pending_members(p_user_id INTEGER)
    RETURNS SETOF pendingGroupMember AS $$
BEGIN
    EXECUTE 'CREATE OR REPLACE VIEW group_reqs_to_accept AS
             SELECT p.*
             FROM pendingGroupMember p
             JOIN groupMember g ON p.gID = g.gID
             WHERE g.userID = ' || p_user_id || ' AND g.role = ''manager'';';
    RETURN QUERY SELECT * FROM group_reqs_to_accept;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
-- END ADDITIONAL FUNCTION 1 get_pending_members
-----------------------------------------------------------------


-----------------------------------------------------------------
-- ADDITIONAL FUNCTION 2 checkFriendshipExists
-----------------------------------------------------------------
-- CHECK FOR IF USERS ARE FRIENDS:
DROP FUNCTION IF EXISTS checkFriendshipExists(integer, integer);

CREATE OR REPLACE FUNCTION checkFriendshipExists(userID1 INTEGER, userID2 INTEGER)
    RETURNS integer AS $$
BEGIN
    IF EXISTS (SELECT * FROM friend WHERE (friend.userID1 = $1 AND friend.userID2 = $2) OR (friend.userID1 = $2 AND friend.userID2 = $1)) THEN
        RETURN 1;
    ELSE
        RETURN -1;
    END IF;
END;
$$ LANGUAGE plpgsql;


-----------------------------------------------------------------
-- End ADDITIONAL FUNCTION 2 checkFriendshipExists
-----------------------------------------------------------------

-----------------------------------------------------------------
-- ADDITIONAL FUNCTION 3 checkGroupMemberExists
-----------------------------------------------------------------
DROP FUNCTION IF EXISTS checkGroupMemberExists;

CREATE OR REPLACE FUNCTION checkGroupMemberExists(userID INTEGER, gID INTEGER)
    RETURNS integer AS $$
BEGIN
    IF EXISTS (SELECT * FROM groupmember WHERE (groupmember.userid = $1 AND groupmember.gid = $2)) THEN
        RETURN 1;
    ELSE
        RETURN -1;
    END IF;
END;
$$ LANGUAGE plpgsql;
-----------------------------------------------------------------
-- END ADDITIONAL FUNCTION 3 checkGroupMemberExists
-----------------------------------------------------------------
