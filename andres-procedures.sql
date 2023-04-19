--11.sendMessageToUser
-- With this the user can send a message to one friend given the friend’s userID. The application
-- should display the name of the recipient and the user should be prompted to enter the body
-- of the message, which could be multi-lined. Once entered, the application should “send” the
-- message to the receiving user by adding an appropriate entry into the message relation (msgIDs
-- should be auto-generated and timeSent should be set to the current time of the Clocktable)
-- and use a trigger to add a corresponding entry into the messageRecipient relation. The user
-- should lastly be shown success or failure feedback.
DROP FUNCTION IF EXISTS send_message_to_friend(integer, integer, text);

CREATE OR REPLACE FUNCTION send_message_to_friend(user_id INTEGER, friend_id INTEGER, message_body TEXT)
    RETURNS BOOLEAN
AS $$
BEGIN
    -- Insert the new message into the message table
    INSERT INTO message VALUES (default, user_id, friend_id, ); -- will implicitly call add_message_recipient()
    RETURN true;
EXCEPTION
    WHEN others THEN
        RETURN false;
END;
$$ LANGUAGE plpgsql;


