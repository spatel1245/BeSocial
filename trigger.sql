--TRIGGERS

--------------------------------------------------------------------
--TRIGGER 1 ADD MESSAGE RECIPIENT
-----------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_message_recipient()
    RETURNS TRIGGER
AS $$
BEGIN
    IF(NEW.toGroupID is null)
    THEN
        INSERT INTO messageRecipient (msgID, userID) VALUES (NEW.msgID, NEW.toUserID);
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
--         INSERT INTO messagerecipient VALUES (sizelimit, cursize);
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
            --write the code that will insert into friends all current_userID & userID_list
            INSERT INTO friend VALUES(userid1,userID_list[i],DEFAULT,DEFAULT);
        END LOOP;

    DELETE FROM pendingfriend WHERE pendingfriend.userid2=current_userID;
    --add code to remove all entires in pendingFriend relation where ID2 == current_userID
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END PROCEDURE 2 add_select_friend_reqs
-----------------------------------------------------------------

--
-- CREATE OR REPLACE PROCEDURE add_select_friend_reqs(current_userID integer, userID_list integer[])
-- AS $$
-- DECLARE
--     i integer;
-- BEGIN
--     FOR i IN 1..array_length(userID_list, 1) LOOP
--             INSERT INTO friend (userID1, userID2, JDate) VALUES (current_userID, userID_list[i], NOW());
--     END LOOP;
--     DELETE FROM pendingfriend WHERE userID2 = current_userID;
--
-- END;
-- $$ LANGUAGE plpgsql;




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
--Begin PROCEDURE 5 leaveGroup
-----------------------------------------------------------------
CREATE OR REPLACE PROCEDURE leaveGroup(group_id integer,user_id integer)
AS $$
DECLARE
BEGIN
    DELETE FROM groupmember

    WHERE gid=group_id AND user_id=userid;
END;
$$ LANGUAGE plpgsql;

-----------------------------------------------------------------
--END PROCEDURE 5 confirmGroupMembers
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

--
-- DROP VIEW IF EXISTS searched;
--
-- CREATE OR REPLACE VIEW searched AS
--              SELECT name
--              FROM profile
--              WHERE profile.name = ' || p_name ||';
--
--
--
-- CREATE OR REPLACE FUNCTION searchProfiles(p_name varchar(50), email varchar(50))
--     RETURNS SETOF profile AS $$
-- BEGIN
--     EXECUTE 'CREATE OR REPLACE VIEW searched AS
--              SELECT name
--              FROM profile
--              WHERE profile.name = ' || p_name ||';';
--     RETURN QUERY SELECT * FROM searched;
-- END;
-- $$ LANGUAGE plpgsql;


-----------------------------------------------------------------
--END FUNCTION 2 SEARCH PROFILES
-----------------------------------------------------------------