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


--4.-- drop user trigger
  --  1. the system should use a trigger to delete the user from the groups they are a member of.
CREATE OR REPLACE FUNCTION removeFromAllGroups()
RETURNS TRIGGER
 AS $$

--Should we assume that he was already excepted
 BEGIN

    DELETE FROM groupmember WHERE old.userID=userid;

    return old;
END


 $$ LANGUAGE plpgsql;


drop trigger if exists removeFromAllGroups on profile;
 CREATE TRIGGER removeFromAllGroups
 BEFORE DELETE ON profile
 FOR EACH ROW
 EXECUTE FUNCTION removeFromAllGroups();

-- CREATE OR REPLACE FUNCTION delete_received_messages()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     DELETE FROM messageRecipient
--     WHERE userID = OLD.userID;
--     RETURN OLD;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- CREATE TRIGGER delete_received_messages_trigger
-- AFTER DELETE ON profile
-- FOR EACH ROW
-- EXECUTE FUNCTION delete_received_messages();
 --********* JUST NEEDS TO DELETE FROM MESSAGE RELATION
-- CREATE OR REPLACE FUNCTION delete_user()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     DELETE FROM messagerecipient WHERE userid = OLD.userid;
--     RETURN OLD;
-- END;
-- $$ LANGUAGE plpgsql;
--
-- CREATE TRIGGER delete_user_trigger
-- BEFORE DELETE ON profile
-- FOR EACH ROW
-- EXECUTE FUNCTION delete_user();



CREATE OR REPLACE FUNCTION delete_message_recipient()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM messagerecipient WHERE userid = OLD.userid;
    DELETE FROM message WHERE fromid = OLD.userid OR touserid = OLD.userid;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_user_trigger
BEFORE DELETE ON profile
FOR EACH ROW
EXECUTE FUNCTION delete_message_recipient();



-- CREATE OR REPLACE FUNCTION delete_received_messages()
-- RETURNS TRIGGER AS $$
-- BEGIN
--     DELETE FROM messagerecipient WHERE userid = OLD.userid;
--     DELETE FROM message WHERE fromid = OLD.userid AND NOT EXISTS (
--         SELECT 1 FROM messagerecipient mr
--         WHERE mr.msgid = message.msgid AND mr.userid <> OLD.userid
--     );
--     RETURN OLD;
-- END;
-- $$ LANGUAGE plpgsql;
--
--DROP TRIGGER IF EXISTS delete_user_trigger ON profile;
-- CREATE TRIGGER delete_user_trigger
-- BEFORE DELETE ON profile
-- FOR EACH ROW
-- EXECUTE FUNCTION delete_received_messages();

