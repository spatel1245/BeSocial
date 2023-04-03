Create TRIGGER addMessageRecipient
    After INSERT
    ON message
    BEGIN
        INSERT INTO messsageRecipient(msgID, toUserId)
        SELECT msgID, toUserID
        FROM INSERTED
    END;


