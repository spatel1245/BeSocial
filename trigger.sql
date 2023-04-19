--TRIGGERS

--------------------------------------------------------------------
--TRIGGER 1 ADD MESSAGE RECIPIENT
-----------------------------------------------------------------
DROP TRIGGER if EXISTS add_message_recipient on message;
CREATE TRIGGER add_message_recipient
    AFTER INSERT ON message
    FOR EACH ROW
EXECUTE FUNCTION add_message_recipient();

-- CREATE OR REPLACE PROCEDURE send_message_to_group(user_id INTEGER, group_id INTEGER, message_body varchar(200))
-- AS $$
-- DECLARE
--     group_id integer;
-- BEGIN
--     -- Insert the new message into the message table
--     INSERT INTO message VALUES (default, user_id, message_body, NULL, group_id, NOW()); -- will implicitly call add_message_recipient()
-- END;
-- $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION add_message_recipient()
    RETURNS TRIGGER
AS $$
BEGIN
    IF(NEW.toGroupID is null)
    THEN
        INSERT INTO messageRecipient (msgID, userID) VALUES (NEW.msgID, NEW.touserid);
        Return new;
    ELSE

        DECLARE
            report  TEXT DEFAULT '';
            rec_group RECORD;
        BEGIN
            FOR rec_group IN SELECT userId,gid FROM groupmember WHERE groupmember.gid=new.togroupid
                LOOP

                    if(new.togroupid=rec_group.gid)
                    THEN
                        INSERT INTO messageRecipient (msgID, userID) VALUES (new.msgid, rec_group.userID);
                    end if;

                end loop;

            Return new;
        end;--
    END IF;
END
$$ LANGUAGE plpgsql;


DROP TRIGGER if EXISTS add_message_recipient on message;
CREATE TRIGGER add_message_recipient
    AFTER INSERT ON message
    FOR EACH ROW
EXECUTE FUNCTION add_message_recipient();

------------------------------------------------------------
--END of TRIGGER 1
-----------------------------------------------------------


-----------------------------------------------------------------
--TRIGGER 2 updateGroup
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION updateGroup()
    RETURNS TRIGGER
AS $$
BEGIN

    DECLARE
        rec_updateGroup RECORD;
        rec_groupSelected RECORD;
        sizelimit integer;
        curSize integer;

    BEGIN
        SELECT COUNT(gid) FROM groupinfo WHERE old.gid=groupinfo.gid INTO curSize;

        FOR rec_updateGroup IN SELECT userId,gid FROM pendinggroupmember WHERE pendinggroupmember.gid=old.gid
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
--TRIGGER 2  END updateGroup
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
--TRIGGER 4 remove From ALL GROUP
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
--END TRIGGER 4 remove From ALL GROUP
-----------------------------------------------------------------


-----------------------------------------------------------------
--BEGIN TRIGGER 5 removeDeletedUserMessages
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION removeDeletedUserMessages()
    RETURNS TRIGGER
AS $$

--Should we assume that he was already excepted
BEGIN

    DECLARE
        report  TEXT DEFAULT '';
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



-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------

------------------------PROCEDURES-----------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------




-----------------------------------------------------------------
--BEGIN PROCEDURE 1 createGROUP
-----------------------------------------------------------------
DROP PROCEDURE if EXISTS createGroup(name varchar(50), size int, description varchar(200), userid int);
CREATE OR REPLACE PROCEDURE createGroup (name varchar(50),size int,description varchar(200),userid int)
AS $$
DECLARE
    group_id integer;
BEGIN

    INSERT INTO groupinfo VALUES (DEFAULT, name, size, description);
    SELECT last_value(gid)
           OVER (ORDER BY gid ASC
               RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
    INTO group_id
    FROM groupinfo;

    INSERT INTO groupmember VALUES (group_id, userid, 'manager', now());

END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END PROCEDURE 1 createGROUP
-----------------------------------------------------------------


-----------------------------------------------------------------
--BEGIN PROCEDURE 2 add_select_friend_reqs
-----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE add_select_friend_reqs(current_userID integer, userID_list integer[])
AS $$
DECLARE
    i integer;
BEGIN
    FOR i IN 1..array_length(userID_list, 1) LOOP
            INSERT INTO friend (userID1, userID2, JDate) VALUES (current_userID, userID_list[i], NOW());
        END LOOP;

    DELETE FROM pendingfriend WHERE pendingfriend.userid2=current_userID;

END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END PROCEDURE 2 add_select_friend_reqs
-----------------------------------------------------------------



-----------------------------------------------------------------
--BEGIN PROCEDURE 3 createPendingGroupMembers
-----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE createPendingGroupMember(group_id integer,user_id integer, requestText varchar(200))
AS $$
DECLARE
BEGIN
    INSERT INTO pendinggroupmember VALUES (group_id,user_id, requesttext, now());
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END PROCEDURE 3 createPendingGroupMembers
-----------------------------------------------------------------


-----------------------------------------------------------------
--Begin PROCEDURE 4 confirmGroupMembers
-----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE confirmGroupMembers(group_id integer, pendingMember_list integer[])
AS $$
DECLARE
    i integer;
    curGroupSize integer;
    sizeLimit integer;
BEGIN
    SELECT COUNT(userID) FROM groupmember WHERE groupmember.gID=group_id INTO curGroupSize;
    SELECT size FROM groupinfo WHERE groupinfo.gID=group_id INTO sizelimit;
    FOR i IN 1..array_length(pendingMember_list, 1) LOOP
            if(curGroupSize<sizeLimit) then
                INSERT INTO groupmember VALUES (group_id,pendingMember_list[i],'member',clock_timestamp());
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
--END PROCEDURE 4 confirmGroupMembers
-----------------------------------------------------------------

-----------------------------------------------------------------
--Begin FUNCTION 5 leaveGroup
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION leaveGroup(group_id integer, user_id integer)
RETURNS integer AS $$
DECLARE
    match_found integer;
BEGIN
    DELETE FROM groupmember
    WHERE groupmember.gid = group_id AND groupmember.userid = user_id
    RETURNING 1 INTO match_found;

    IF FOUND THEN
        RETURN match_found;
    ELSE
        RETURN -1;
    END IF;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 5 confirmGroupMembers
-----------------------------------------------------------------

-----------------------------------------------------------------
--BEGIN PROCEDURE 6 update_last_login
-----------------------------------------------------------------

CREATE OR REPLACE PROCEDURE update_last_login(p_userID INTEGER)
    LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE profile SET lastLogin = NOW() WHERE userID = p_userID;
END;
$$;
-----------------------------------------------------------------
--END PROCEDURE 6 update_last_login
-----------------------------------------------------------------
-----------------------------------------------------------------
--BEGIN PROCEDURE 7 sendMessage
-----------------------------------------------------------------


-----------------------------------------------------------------
--END PROCEDURE 7 sendMessage
-----------------------------------------------------------------


-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------

------------------------FUNCTIONS-----------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------
-----------------------------------------------------------------





-----------------------------------------------------------------
--VIEW
-----------------------------------------------------------------
DROP VIEW IF EXISTS group_reqs_to_accept;

CREATE VIEW group_reqs_to_accept AS
SELECT p.*
FROM pendingGroupMember p
         JOIN groupMember g ON p.gID = g.gID
WHERE p.userID = 0 AND g.role = 'manager';


-----------------------------------------------------------------
--BEGIN FUNCTION 1 get_pending_members
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
--END FUNCTION 1 get_pending_members
-----------------------------------------------------------------

-----------------------------------------------------------------
--BEGIN FUNCTION 2 searchProfiles
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
--END FUNCTION 2 SEARCH PROFILES
-----------------------------------------------------------------

-----------------------------------------------------------------
--BEGIN FUNCTION 3 sendMessageToFriend
-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE send_message_to_friend(user_id INTEGER, friend_id INTEGER, message_body varchar(200))
AS $$
BEGIN
    INSERT INTO message VALUES (default, user_id, message_body, friend_id, NULL, NOW()); -- will implicitly call add_message_recipient()
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 3 SendMessageToFriend
-----------------------------------------------------------------

-----------------------------------------------------------------
--BEGIN FUNCTION 4 SendMessageToGroup
-----------------------------------------------------------------
DROP PROCEDURE send_message_to_group;
CREATE OR REPLACE PROCEDURE send_message_to_group(user_id INTEGER, group_id INTEGER, message_body varchar(200))
AS $$
DECLARE
    group_id integer;
BEGIN
    -- Insert the new message into the message table
    INSERT INTO message VALUES (default, user_id, message_body, NULL, group_id, NOW()); -- will implicitly call add_message_recipient()
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 4 SendMessageToGroup
-----------------------------------------------------------------


-- CREATE OR REPLACE VIEW friend_display
--     AS
--              SELECT userid2,
--             profile.name
--              FROM friend
--              INNER JOIN profile ON friend.userID2=profile.userID;

-- CREATE OR REPLACE FUNCTION displayFriends(userid integer)
--     RETURNS SETOF friend AS $$
-- BEGIN
--     EXECUTE 'CREATE OR REPLACE VIEW friend_display AS
--              SELECT userid2, profile.name
--              FROM friend
--              INNER JOIN profile ON friend.userID2=profile.userID
--             WHERE userid1 = ' || userid||';';
--     RETURN QUERY SELECT * FROM friend_display;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- CREATE OR REPLACE FUNCTION display_friends(userid integer)
--     RETURNS TABLE (name VARCHAR(50), userID INTEGER) AS $$
-- BEGIN
--     RETURN QUERY
--         SELECT userId2, name FROM profile
--         UNION
--         SELECT col1, col2 FROM table2;
-- END;
-- $$ LANGUAGE plpgsql;
-----------------------------------------------------------------
--BEGIN FUNCTION 5 listOfFriend IDS
-----------------------------------------------------------------



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

-----------------------------------------------------------------
--END FUNCTION 5 listOfFreind IDS
-----------------------------------------------------------------

-----------------------------------------------------------------
--BEGIN FUNCTION 6 Display_Friends
-----------------------------------------------------------------



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

-----------------------------------------------------------------
--END FUNCTION 6 DisplayFriends
-----------------------------------------------------------------

-----------------------------------------------------------------
--BEGIN FUNCTION 7 Detail_friend
-----------------------------------------------------------------

CREATE OR REPLACE FUNCTION displayDetailFriend(user_id integer)
    RETURNS SETOF profile AS $$
BEGIN

    RETURN QUERY SELECT * FROM profile Where user_id=profile.userid;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END FUNCTION 7 Detail_friend
-----------------------------------------------------------------

-----------------------------------------------------------------
--BEGIN FUNCTION 8 Return Ranked Groups
-----------------------------------------------------------------


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

SELECT * FROM group_size_Ranked();


-----------------------------------------------------------------
--END FUNCTION 8Return Ranked Groups
-----------------------------------------------------------------

-----------------------------------------------------------------
--START  FUNCTION 8 Return Ranked Friends
-----------------------------------------------------------------
-- CREATE OR REPLACE VIEW rank_friends
-- AS
-- select user, count(*) Total
-- from
-- (
--   select userid1 as user
--   from friend as
--   union all
--   select userid2 as user
--   from friend
-- )
-- group by user
-- order by total desc;
-- CREATE OR REPLACE FUNCTION rank_friends(user_id integer)
--     RETURNS SETOF groupinfo AS $$
-- BEGIN
--      EXECUTE 'CREATE OR REPLACE VIEW group_size_ranked AS
--             SELECT COUNT(userID), groupmember.gid
--             FROM groupmember
--             INNER JOIN groupinfo ON groupinfo.gid=groupmember.gid
--             GROUP BY gid
--             ORDER BY COUNT(groupmember.userID) DESC;';
--     RETURN QUERY SELECT * FROM groups_size_ranked LIMIT 1;
-- END;
-- $$ LANGUAGE plpgsql;
-- -----------------------------------------------------------------
--END FUNCTION 8 Return Ranked Friends
-----------------------------------------------------------------




-----------------------------------------------------------------
--START  FUNCTION 9 Display Messages
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
-- -----------------------------------------------------------------
--END FUNCTION 9 Display Messages
-----------------------------------------------------------------




-- -----------------------------------------------------------------
--END FUNCTION 10 Display NEW Messages
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

-- -----------------------------------------------------------------
--END FUNCTION 10 Display NEW Messages
-----------------------------------------------------------------





-- -----------------------------------------------------------------
--START FUNCTION 11 Check if Two Users are Friends
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

-- -----------------------------------------------------------------
--START FUNCTION 11 Rank Profile
-----------------------------------------------------------------
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

-- -----------------------------------------------------------------
--END FUNCTION 11 Rank Profile
-----------------------------------------------------------------


-- -----------------------------------------------------------------
--START FUNCTION 12 Check if Member is in Group
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
-- -----------------------------------------------------------------
--END FUNCTION 12 Check if Member is in Group
-----------------------------------------------------------------

-- -----------------------------------------------------------------
--START FUNCTION 14 Check if Member is in Group
-----------------------------------------------------------------