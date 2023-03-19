CREATE TABLE "user"
(
    userID INTEGER NOT NULL,
    name VARCHAR(50),
    email VARCHAR(50),
    password VARCHAR(50),
    date_of_birth DATE,
    lastLogin TIMESTAMP
);

CREATE TABLE friend
(
    userID1 INTEGER NOT NULL,
    userID2 INTEGER NOT NULL,
    JDate DATE,
    requestText VARCHAR(200)
);

CREATE TABLE pendingFriend
(
    userID1 INTEGER NOT NULL,
    userID2 INTEGER NOT NULL,
    requestText VARCHAR(200)
);

CREATE TABLE groupInfo
(
    gID INTEGER NOT NULL,
    name VARCHAR(50),
    size INTEGER,
    description VARCHAR(200)
);

CREATE TABLE groupMember
(
    gID INTEGER NOT NULL,
    userID1 INTEGER NOT NULL,
    role VARCHAR(20),
    lastConfirmed TIMESTAMP
);

CREATE TABLE pendingGroupMember
(
    gID INTEGER NOT NULL,
    userID INTEGER NOT NULL,
    requestText VARCHAR(200),
    requestTime TIMESTAMP
);

CREATE TABLE message
(
    msgID INTEGER NOT NULL,
    fromID INTEGER NOT NULL,
    messageBody VARCHAR(200),
    toUserID INTEGER NOT NULL,
    toGroupID INTEGER,
    timeSent TIMESTAMP NOT NULL
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