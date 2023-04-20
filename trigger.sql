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