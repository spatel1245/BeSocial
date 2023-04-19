DROP VIEW IF EXISTS group_reqs_to_accept;

CREATE VIEW group_reqs_to_accept AS
SELECT p.*
FROM pendingGroupMember p
         JOIN groupMember g ON p.gID = g.gID
WHERE p.userID = 0 AND g.role = 'manager';

-- CREATE OR REPLACE PROCEDURE get_pending_members(user_id INTEGER)
-- AS $$
-- BEGIN
--     EXECUTE 'CREATE OR REPLACE VIEW group_reqs_to_accept AS
--              SELECT p.*
--              FROM pendingGroupMember p
--              JOIN groupMember g ON p.gID = g.gID
--              WHERE g.userID = ' || user_id || ' AND g.role = ''manager'';';
-- END;
-- $$ LANGUAGE plpgsql;
-- DROP PROCEDURE IF EXISTS get_pending_members(user_id INTEGER);
DROP FUNCTION IF EXISTS get_pending_members(user_id INTEGER);

CREATE OR REPLACE FUNCTION get_pending_members(p_user_id INTEGER)
    RETURNS SETOF pendingGroupMember AS $$
BEGIN
    EXECUTE 'CREATE OR REPLACE VIEW group_reqs_to_accept AS
             SELECT p.*
             FROM pendingGroupMember p
             JOIN groupMember g ON p.gID = g.gID
             WHERE g.userID = ' || p_user_id || ' AND g.role = ''manager'';';
--     CREATE OR REPLACE VIEW group_reqs_to_accept AS
--     SELECT p.*
--     FROM pendingGroupMember p
--              JOIN groupMember g ON p.gID = g.gID
--     WHERE g.userID = p_user_id AND g.role = 'manager';

    RETURN QUERY SELECT * FROM group_reqs_to_accept;
END;
$$ LANGUAGE plpgsql;