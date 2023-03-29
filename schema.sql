DROP TABLE IF EXISTS profile CASCADE;
DROP TABLE IF EXISTS friend CASCADE;
DROP TABLE IF EXISTS pendingFriend CASCADE;
DROP TABLE IF EXISTS groupInfo CASCADE;
DROP TABLE IF EXISTS groupMember CASCADE;
DROP TABLE IF EXISTS pendingGroupMember CASCADE;
DROP TABLE IF EXISTS message CASCADE;
DROP TABLE IF EXISTS messageRecipient CASCADE;




CREATE TABLE profile
(
    userID INTEGER NOT NULL,
    name VARCHAR(50),
    email VARCHAR(50) not null,
    password VARCHAR(50),
    date_of_birth DATE,
    lastLogin TIMESTAMP,

    CONSTRAINT PK_PROFILE
    PRIMARY KEY (userID)
);

CREATE TABLE friend
(
    userID1 INTEGER NOT NULL,
    userID2 INTEGER NOT NULL,
    JDate DATE,
    requestText VARCHAR(200),

    CONSTRAINT PK_FRIEND
        PRIMARY KEY(userID1,userID2)
);

CREATE TABLE pendingFriend
(
    userID1 INTEGER NOT NULL,
    userID2 INTEGER NOT NULL,
    requestText VARCHAR(200),

CONSTRAINT PK_pendingFriend PRIMARY KEY (userId1,userID2)
);

CREATE TABLE groupInfo
(
    gID INTEGER NOT NULL,
    name VARCHAR(50),
    size INTEGER,
    description VARCHAR(200),

    CONSTRAINT PK_groupInfo PRIMARY KEY (gID)

);

CREATE TABLE groupMember
(
    gID INTEGER NOT NULL,
    userID1 INTEGER NOT NULL,
    role VARCHAR(20),
    lastConfirmed TIMESTAMP,
    CONSTRAINT PK_groupMember PRIMARY KEY (gID, userID1),
    CONSTRAINT FK_GroupMember FOREIGN KEY (userID1) REFERENCES PROFILE(UserID),
    CONSTRAINT FK_GroupMember1 FOREIGN KEY (gID) REFERENCES GroupInfo(GID)

);

CREATE TABLE pendingGroupMember
(
    gID INTEGER NOT NULL,
    userID INTEGER NOT NULL,
    requestText VARCHAR(200),
    requestTime TIMESTAMP,

CONSTRAINT PK_pendingGroupMember PRIMARY KEY (gID, UserID),
CONSTRAINT FK_pendingGroupMember FOREIGN KEY (userID) REFERENCES PROFILE(UserID),
CONSTRAINT FK_pendingGroupMember1 FOREIGN KEY (gID) REFERENCES GroupInfo(GID)
);

CREATE TABLE message
(
    msgID INTEGER NOT NULL,
    fromID INTEGER NOT NULL,
    messageBody VARCHAR(200),
    toUserID INTEGER NOT NULL,
    toGroupID INTEGER,
    timeSent TIMESTAMP NOT NULL,

    CONSTRAINT PK_message PRIMARY KEY (msgID)


);

CREATE TABLE messageRecipient
(
    msgID INTEGER NOT NULL,
    userID INTEGER NOT NULL,

    CONSTRAINT PK_messageRecipient PRIMARY KEY  (msgId, userID),
    CONSTRAINT FK_messageRecipient FOREIGN KEY (msgID) REFERENCES message(msgID),
    CONSTRAINT FK_messageRecipient1 FOREIGN KEY (userID) REFERENCES profile(userID)

);

CREATE TABLE clock
(
    pseudo_time TIMESTAMP,
    CONSTRAINT PK_Clock PRIMARY KEY (pseudo_time)
)