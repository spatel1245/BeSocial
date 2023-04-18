--1. addMessageRecipient which adds a corresponding entry into the messageRecipient relation upon adding a new message to the message relation


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


--2. updateGroup which moves a pending accepted request in the pendingGroupMember relation to the group Member relation when a member leaves the group.
CREATE OR REPLACE FUNCTION updateGroup()
RETURNS TRIGGER
 AS $$

--Should we assume that he was already excepted
 BEGIN
     DECLARE
        report  TEXT DEFAULT '';
        rec_updateGroup RECORD;
        cur_updateGroup CURSOR
            FOR SELECT gID, userID, requesttext, requesttime FROM pendinggroupmember ORDER BY requesttime ASC;
        rec_groupSelected RECORD;
        sizeGroup integer;
    BEGIN
    SELECT size INTO sizeGroup FROM groupinfo WHERE old.gid = gid;
        IF(sizeGroup<32) THEN
        OPEN cur_updateGroup;
        fetch cur_updateGroup into rec_updateGroup;
        INSERT INTO groupmember (gID, userid, role,lastconfirmed) values (rec_updateGroup.gid, rec_updateGroup.userID, 'member', old.lastconfirmed);
        DELETE FROM pendinggroupmember WHERE rec_updateGroup.userid=pendinggroupmember.userid AND rec_updateGroup.gid=pendinggroupmember.gid;
        CLOSE cur_updateGroup;
         end if;

        return new;
    END;
    END


 $$ LANGUAGE plpgsql;


 DROP TRIGGER if EXISTS updateGroup on groupmember;

 CREATE TRIGGER updateGroup
 AFTER DELETE ON groupmember
 FOR EACH ROW
 EXECUTE FUNCTION updateGroup();

--3. If a user accepts a friend request (a friendship is made between users), then the request is no longer pending. Add to friend relation & delete from pending friend relation.
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


--4.
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


-- --5
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
--

 DROP TRIGGER if EXISTS removeDeletedUserMessages on profile;
 CREATE TRIGGER removeDeletedUserMessages
 BEFORE DELETE ON profile
 FOR EACH ROW
 EXECUTE FUNCTION removeDeletedUserMessages();

--6. Procedure
DROP PROCEDURE if EXISTS createGroup(name varchar(50), size int, description varchar(200), userid int);
CREATE OR REPLACE PROCEDURE createGroup (name varchar(50),size int,description varchar(200),userid int)
AS $$
BEGIN
    INSERT INTO groupinfo VALUES (DEFAULT, name, size, description);
    INSERT INTO groupmember VALUES (1, userid, 'manager', now());

END;
$$ LANGUAGE plpgsql;


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