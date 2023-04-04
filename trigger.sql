--1. addMessageRecipient which adds a corresponding entry into the messageRecipient relation upon adding a new message to the message relation

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

--2. If a user accepts a friend request (a friendship is made between users), then the request is no longer pending. Add to friend relation & delete from pending friend relation.
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

--updateGroup which moves a pending accepted request in the pendingGroupMember relation to the group Memberrelation when a member leaves the group.
