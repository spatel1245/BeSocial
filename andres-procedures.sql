--11.sendMessageToUser
-- With this the user can send a message to one friend given the friend’s userID. The application
-- should display the name of the recipient and the user should be prompted to enter the body
-- of the message, which could be multi-lined. Once entered, the application should “send” the
-- message to the receiving user by adding an appropriate entry into the message relation (msgIDs
-- should be auto-generated and timeSent should be set to the current time of the Clocktable)
-- and use a trigger to add a corresponding entry into the messageRecipient relation. The user
-- should lastly be shown success or failure feedback.

-- SEE BEN'S ADDITIONAL FILE FOR THIS FUNCTION FIXED
DROP FUNCTION IF EXISTS send_message_to_friend(integer, integer, text);

CREATE OR REPLACE FUNCTION send_message_to_friend(user_id INTEGER, friend_id INTEGER, message_body TEXT)
    RETURNS BOOLEAN
AS $$
BEGIN
    -- Insert the new message into the message table
    INSERT INTO message VALUES (default, user_id, friend_id, NULL, NOW(), message_body); -- will implicitly call add_message_recipient()
    RETURN true;
EXCEPTION
    WHEN others THEN
        RETURN false;
END;
$$ LANGUAGE plpgsql;



-- 12.sendMessageToGroup
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

--------

-- SEE BEN'S ADDITIONAL FILE FOR THIS FUNCTION

-------------

-- 13.displayMessages
-- When the user selects this option, the entire contents
-- of every message sent to the user (including group messages)
-- should be displayed in a nicely formatted way.


DROP FUNCTION IF EXISTS display_messages(integer);
CREATE OR REPLACE FUNCTION display_messages(user_id INTEGER)
RETURNS TABLE ( -- return a table displaying the contents of all of a user's messages
    msgID INTEGER,
    messageBody varchar(200),
    fromID INTEGER,
    timeSent TIMESTAMP
)
AS $$

BEGIN
    RETURN QUERY -- allows for the returned table to "communicate" with the tables we have
    SELECT
        message.msgID,
        message.messageBody,
        message.fromID,
        message.timeSent
    FROM
        message JOIN messageRecipient ON message.msgID = messageRecipient.msgID
    WHERE
        messageRecipient.userID = user_id
    ORDER BY
        timeSent DESC;
END;
$$ LANGUAGE plpgsql;

-- 14.displayNewMessages
-- This should display messages in the same fashion as the previous task except that only those
-- messages sent since the last time the user logged into the system should be displayed (including
-- group messages).

DROP FUNCTION IF EXISTS display_new_messages(integer);
CREATE OR REPLACE FUNCTION display_new_messages(user_id INTEGER)
RETURNS TABLE (
    msgID INTEGER,
    messageBody varchar(200),
    fromID INTEGER,
    timeSent TIMESTAMP
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        message.msgID,
        message.messageBody,
        message.fromID,
        message.timeSent
    FROM
        message
        JOIN messageRecipient ON message.msgID = messageRecipient.msgID
        JOIN profile ON message.fromID = profile.userID
    WHERE
        messageRecipient.userID = user_id
        AND message.timeSent > (SELECT lastLogin FROM profile WHERE userID = user_id)
    ORDER BY
        timeSent DESC;
END;
$$ LANGUAGE plpgsql;

---------------------------------------------------------------
--** THROWAWAY FOR ABOVE TWO FUNCTIONS
-- DROP FUNCTION IF EXISTS display_messages(integer);
-- CREATE OR REPLACE FUNCTION display_messages(user_id INTEGER)
-- RETURNS TABLE (
--     msgID INTEGER,
--     timeSent TIMESTAMP,
--     messageBody varchar(200),
--     fromID INTEGER
-- )
-- AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT
--         message.msgID,
--         message.timeSent,
--         message.messageBody
--
--     FROM
--         message
--         JOIN messageRecipient ON message.msgID = messageRecipient.msgID
--         JOIN profile ON message.fromID = profile.userID
--     WHERE
--         messageRecipient.userID = user_id
--     ORDER BY
--         timeSent DESC;
-- END;
-- $$ LANGUAGE plpgsql;


-- DROP FUNCTION IF EXISTS display_new_messages(integer);
-- CREATE OR REPLACE FUNCTION display_new_messages(user_id INTEGER)
-- RETURNS TABLE (
--     msgID INTEGER,
--     messageBody varchar(200),
--     fromID INTEGER,
--     timeSent TIMESTAMP
-- )
-- AS $$
-- DECLARE
--     last_login TIMESTAMP;
-- BEGIN
--     SELECT
--         login_time
--     INTO
--         last_login
--     FROM
--         profile
--     WHERE
--         user_id = display_new_messages.user_id;
--
--     RETURN QUERY
--     SELECT
--         message.msgID,
--         message.messageBody,
--         message.fromID,
--         message.timeSent
--     FROM
--         message
--         JOIN messageRecipient ON message.msgID = messageRecipient.msgID
--     WHERE
--         messageRecipient.userID = user_id
--         AND message.timeSent > last_login
--     ORDER BY
--         timeSent DESC;
-- END;
-- $$ LANGUAGE plpgsql;
--------------------------------------



