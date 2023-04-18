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
    return new;
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
 BEGIN
    DELETE FROM pendinggroupmember where pendinggroupmember.userid = new.userId;
    RETURN NEW;
 END;
 $$ LANGUAGE plpgsql;

--  DROP TRIGGER if EXISTS updateGroup on groupinfo;
--  CREATE TRIGGER updateGroup
--  AFTER INSERT ON pendinggroupmember
--  FOR EACH ROW
--  EXECUTE FUNCTION updateGroup();
--
-- --3. If a user accepts a friend request (a friendship is made between users), then the request is no longer pending. Add to friend relation & delete from pending friend relation.
-- CREATE OR REPLACE FUNCTION delete_pending_friendRequest()
-- RETURNS TRIGGER
--  AS $$
--  BEGIN
--     DELETE FROM pendingfriend WHERE pendingFriend.userID1= NEW.userID1 AND
--                                     pendingFriend.userID2= New.userID2;
--     RETURN NEW;
--  END;
--  $$ LANGUAGE plpgsql;
--
--  DROP TRIGGER if EXISTS delete_pending_friendRequest on friend;
--  CREATE TRIGGER delete_pending_friendRequest
--  AFTER INSERT ON friend
--  FOR EACH ROW
--  EXECUTE FUNCTION delete_pending_friendRequest();
--
