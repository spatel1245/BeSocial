ALTER TABLE profile
    ADD CONSTRAINT PROFILE_Check_Empty_Password
    CHECK(profile.password!='');


ALTER TABLE profile
    ADD CONSTRAINT PROFILE_check_underAge
    CHECK (profile.date_of_birth>'2009-12-31');


ALTER TABLE friend
    ADD CONSTRAINT FRIEND_check_no_duplicate_friends
    CHECK (friend.userid1<friend.userid2);


ALTER TABLE friend
    ADD CONSTRAINT FRIEND_check_dateOfFriendship
    CHECK (friend.jdate>'2014-12-31');

-- ALTER TABLE pendingfriend
--     ADD CONSTRAINT PENDINGFRINED_check_already_friends
--     CHECK ()

ALTER TABLE groupinfo
    ADD CONSTRAINT GROUPINFO_name_not_empty
    CHECK (groupinfo.name!='');

ALTER TABLE groupinfo
    ADD CONSTRAINT GROUPINFO_checkSize
    CHECK (groupinfo.size<32 AND groupinfo.size>=0);
