--1. addMessageRecipient which adds a corresponding entry into themessageRecipient relation upon adding a new message to the message relation

CREATE OR REPLACE FUNCTION add_message_recipient()
RETURNS TRIGGER
AS $$
BEGIN
    INSERT INTO messageRecipient (msgID, userID) VALUES (NEW.msgID, NEW.toUserID); --might need changed
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER if EXISTS add_message_recipient on message;
CREATE TRIGGER add_message_recipient
AFTER INSERT ON message
FOR EACH ROW
EXECUTE FUNCTION add_message_recipient();

-- 2.updateGroup which moves a pending accepted request in the pendingGroupMember relation to thegroupMemberrelation when a member leaves the group.


