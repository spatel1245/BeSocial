--1. For JDBC method 20.logout
-- The function should return the user to the top level of the UI after marking the time of the
-- user’s logout in the user’s “lastlogin” field of the user relation from the Clock table.
DROP PROCEDURE update_last_login(p_userID INTEGER);


CREATE OR REPLACE PROCEDURE update_last_login(p_userID INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE profile SET lastLogin = NOW() WHERE userID = p_userID;
END;
$$;


--2.
CREATE OR REPLACE PROCEDURE add_select_friend_reqs(current_userID integer, userID_list integer[])
AS $$
DECLARE
    i integer;
BEGIN
    FOR i IN 1..array_length(userID_list, 1) LOOP
            INSERT INTO friend (userID1, userID2, JDate) VALUES (current_userID, userID_list[i], NOW());
    END LOOP;
    DELETE FROM pendingfriend WHERE userID2 = current_userID;

END;
$$ LANGUAGE plpgsql;