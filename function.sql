--1. For JDBC method 20.logout
-- The function should return the user to the top level of the UI after marking the time of the
-- user’s logout in the user’s “lastlogin” field of the user relation from the Clock table.

CREATE OR REPLACE PROCEDURE update_last_login(p_userID INTEGER)
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE profile SET lastLogin = NOW() WHERE userID = p_userID;
END;
$$;
