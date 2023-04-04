DROP TABLE IF EXISTS profile CASCADE;
DROP TABLE IF EXISTS friend CASCADE;
DROP TABLE IF EXISTS pendingFriend CASCADE;
DROP TABLE IF EXISTS groupInfo CASCADE;
DROP TABLE IF EXISTS groupMember CASCADE;
DROP TABLE IF EXISTS pendingGroupMember CASCADE;
DROP TABLE IF EXISTS message CASCADE;
DROP TABLE IF EXISTS messageRecipient CASCADE;
DROP TABLE IF EXISTS clock CASCADE;




-- *NOTE: Assumptions + rationale on our selection of integrity constraints are commented next to the constraints in the relations

CREATE TABLE profile
(
    userID INTEGER NOT NULL,--Assume user ID is needed to identify user.
    name VARCHAR(50) not null,
    email VARCHAR(50) not null, --Assume emails must be unique since email is required to make an account.
    password VARCHAR(50) not null, --Password cannot be empty
    date_of_birth DATE not null, --Users cannot be born before the year 2010.
    lastLogin TIMESTAMP not null, --

    CONSTRAINT PK_PROFILE PRIMARY KEY (userID), -- userID is the primary key for the profile table as it is unique for each user and cannot be null as each profile must have an ID
    CONSTRAINT UQ_EMAIL UNIQUE (email)
);

CREATE TABLE friend
(
    userID1 INTEGER NOT NULL,
    userID2 INTEGER NOT NULL,
    JDate DATE NOT NULL       DEFAULT CURRENT_DATE,-- Assume that date cannot be before the application was released. January 1st 2015.
    requestText VARCHAR(200),

    CONSTRAINT PK_FRIEND PRIMARY KEY(userID1, userID2) --Both userID1 and userID2 are the primary key because to uniquely identify a friendship, both friends (userIDs) are necessary
);

CREATE TABLE pendingFriend
(
    userID1 INTEGER NOT NULL, --Assume that If friend tuple exists between user1 and 2 pendingFriend between users cannot exist.
    userID2 INTEGER NOT NULL,
    requestText VARCHAR(200),

CONSTRAINT PK_pendingFriend PRIMARY KEY (userId1, userID2) --similar to the friend relation, in order to uniquely identify a pending friendship, both users are necessary
);

CREATE TABLE groupInfo
(
    gID INTEGER NOT NULL, --Assume that groupId is necessary to identify group as a primary key.
    name VARCHAR(50) NOT NULL, --Assume that group name cannot be empty.
    size INTEGER NOT NULL, --Assume that the group size must be positive and less than 32 users.
    description VARCHAR(200) NOT NULL,

    CONSTRAINT PK_groupInfo PRIMARY KEY (gID) -- gID (GroupID) is the primary key as each group has its own unique ID, and this can never be null

);

CREATE TABLE groupMember
(
    gID INTEGER NOT NULL,--Assume that groupId is necessary to identify group as a primary key.
    userID INTEGER NOT NULL,--Assume that userID cannot be null to identify which profile is in the group.
    role VARCHAR(20) NOT NULL       DEFAULT 'member', --Assume that each member must be be a manager or a member to enable appropriate permissions
    lastConfirmed TIMESTAMP NOT NULL DEFAULT current_time,--Assume that this is the time that the user was accepted into the group.

    CONSTRAINT PK_groupMember PRIMARY KEY (gID, userID),-- gID and userID(1) are the primary key for this relation as a groupMember is a user(profile) that belongs to a group. Both are necessary to uniquely identify the group member.
    CONSTRAINT FK_GroupMember FOREIGN KEY (userID) REFERENCES profile(UserID), -- The UserID in this relation belongs to a user of the social media profile. This reference establishes a connection between their attributes and belonging to the group, as it allows for access to the user's attributes.
    CONSTRAINT FK_GroupMember1 FOREIGN KEY (gID) REFERENCES GroupInfo(gID)  -- The gID in this relation is a group in this social media platform. This reference allows for a connection between the member and the group's attributes that they belong to, as it allows for access to the group's attributes.

);

CREATE TABLE pendingGroupMember
(
    gID INTEGER NOT NULL,--Assume that gID is cannot be null to identify which group the profile is attempting to join.
    userID INTEGER NOT NULL,--Assume that userID cannot be null to identify which profile is attempting to join the group.
    requestText VARCHAR(200) NOT NULL DEFAULT 'I would like to join your group!',--
    requestTime TIMESTAMP NOT NULL DEFAULT current_time,-- Assume that request time cannot be null 

CONSTRAINT PK_pendingGroupMember PRIMARY KEY (gID, UserID), --similar to the groupMember relation, in order to uniquely identify a member's pending request to join a group, both the user that is requesting to join, and the group's ID are necessary.
CONSTRAINT FK_pendingGroupMember FOREIGN KEY (userID) REFERENCES profile(UserID), -- The UserID in this relation belongs to a user of the social media profile. This reference establishes a connection between the user's attributes and request to join the group, as it allows for access to the user's attributes.
CONSTRAINT FK_pendingGroupMember1 FOREIGN KEY (gID) REFERENCES GroupInfo(GID) -- The gID in this relation is a group in this social media platform. This reference allows for a connection between the member and the group's attributes that they are requesting to belong to, as it allows for access to the group's attributes.
);

CREATE TABLE message
(
    msgID INTEGER NOT NULL,
    fromID INTEGER NOT NULL,
    messageBody VARCHAR(200),
    toUserID INTEGER NOT NULL,
    toGroupID INTEGER,
    timeSent TIMESTAMP NOT NULL,

    CONSTRAINT PK_message PRIMARY KEY (msgID) -- Messages are uniquely identified by their message ID. Each message has their own and this can never be null.
);

CREATE TABLE messageRecipient
(
    msgID INTEGER NOT NULL,
    userID INTEGER NOT NULL,

    CONSTRAINT PK_messageRecipient PRIMARY KEY  (msgId, userID), -- Both the msgID and userID are the primary key as in order to uniquely identify who the recipient of a message is, we must know the user (identified by userID) and the message they receive (messageID)
    CONSTRAINT FK_messageRecipient FOREIGN KEY (msgID) REFERENCES message(msgID), -- this reference allows for access of the message's attributes.
    CONSTRAINT FK_messageRecipient1 FOREIGN KEY (userID) REFERENCES PROFILE(userID) --this reference allows for access of the recipient's (user) attributes.

);

CREATE TABLE clock
(
    pseudo_time TIMESTAMP,
    CONSTRAINT PK_Clock PRIMARY KEY (pseudo_time)
);






