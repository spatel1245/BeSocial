CREATE TABLE profile
(
    userID INTEGER NOT NULL,
    name VARCHAR(50),
    email VARCHAR(50) not null,
    password VARCHAR(50),
    date_of_birth DATE,
    lastLogin TIMESTAMP

    CONSTRAINT PK_PROFILE PRIMARY KEY (planId)
);

CREATE TABLE friend
(
    userID1 INTEGER NOT NULL,
    userID2 INTEGER NOT NULL,
    JDate DATE,
    requestText VARCHAR(200)

    CONSTRAINT PK_friend PRIMARY KEY (userId1,userID2)
);

CREATE TABLE pendingFriend
(
    userID1 INTEGER NOT NULL,
    userID2 INTEGER NOT NULL,
    requestText VARCHAR(200)

CONSTRAINT PK_pendingFriend PRIMARY KEY (userId1,userID2)
);

CREATE TABLE groupInfo
(
    gID INTEGER NOT NULL,
    name VARCHAR(50),
    size INTEGER,
    description VARCHAR(200)

    CONSTRAINT PK_groupInfo PRIMARY KEY (gID)

);

CREATE TABLE groupMember
(
    gID INTEGER NOT NULL,
    userID1 INTEGER NOT NULL,
    role VARCHAR(20),
    lastConfirmed TIMESTAMP
    CONSTRAINT PK_groupMember PRIMARY KEY (gID, UserID)
    CONSTRAINT FK_GroupMember FOREIGN KEY userID1 REFERENCES PROFILE(UserID)
    CONSTRAINT FK_GroupMember1 FOREIGN KEY gID REFERENCES GroupInfo(GID)
);

CREATE TABLE pendingGroupMember
(
    gID INTEGER NOT NULL,
    userID INTEGER NOT NULL,
    requestText VARCHAR(200),
    requestTime TIMESTAMP

CONSTRAINT PK_groupMember PRIMARY KEY (gID, UserID)
CONSTRAINT FK_GroupMember FOREIGN KEY userID1 REFERENCES PROFILE(UserID)
CONSTRAINT FK_GroupMember1 FOREIGN KEY gID REFERENCES GroupInfo(GID)
);

CREATE TABLE message
(
    msgID INTEGER NOT NULL,
    fromID INTEGER NOT NULL,
    messageBody VARCHAR(200),
    toUserID INTEGER NOT NULL,
    toGroupID INTEGER,
    timeSent TIMESTAMP NOT NULL
    CONSTRAINT PK_groupMember PRIMARY KEY (gID, UserID)
    CONSTRAINT FK_GroupMember FOREIGN KEY userID1 REFERENCES PROFILE(UserID)
    CONSTRAINT FK_GroupMember1 FOREIGN KEY gID REFERENCES GroupInfo(GID)

);

CREATE TABLE messageRecipient
(
    msgID INTEGER NOT NULL,
    userID INTEGER NOT NULL
);

CREATE TABLE clock
(
    pseudo_time TIMESTAMP,
    CONSTRAINT PK_Clock PRIMARY KEY (pseudo_time)
)