Create TRIGGER addMessageRecipient
    After INSERT
    ON message
    BEGIN
        INSERT INTO messageReciepient(123,123)
    END;
