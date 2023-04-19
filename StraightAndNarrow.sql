-- 10. searchForProfile
-- Given a string on which to match any user profile in the system, any item in this string must be matched against the “name” and “email” fields of a user’s profile. That is if the user searches for “xyz abc”, the results should be the set of all user profiles that have “xyz” in their “name” or “email” union the set of all user profiles that have “abc” in their “name” or “email”.







-- 11. sendMessageToUser
-- With this the user can send a message to one friend given the friend’s userID. The application should display the name of the recipient and the user should be prompted to enter the body of the message, which could be multi-lined. Once entered, the application should “send” the message to the receiving user by adding an appropriate entry into the message relation (msgIDs should be auto-generated and timeSent should be set to the current time of the Clock table) and use a trigger to add a corresponding entry into the messageRecipient relation. The user should lastly be shown success or failure feedback.
-- 5






-- 12. sendMessageToGroup
-- With this the user can send a message to a recipient group given the group ID, if the user is within the group. Every member of this group should receive the message. The user should be prompted to enter the body of the message, which could be multi-lined. Then the application should “send” the message to the group by adding an appropriate entry into the message relation (msgIDs should be auto-generated and timeSent should be set to the current time of the Clock table) and use a trigger to add corresponding entries into the messageRecipient relation. The user should lastly be shown success or failure feedback.
-- Note that if the user sends a message to one friend, you only need to put the friend’s userID to ToUserID in the table of message. If the user wants to send a message to a group, you need to put the group ID to ToGroupID in the table of message and use a trigger to populate the messageRecipient table with proper user ID information as defined by the groupMember relation.
-- 13. displayMessages





-- When the user selects this option, the entire contents of every message sent to the user (in- cluding group messages) should be displayed in a nicely formatted way.
-- 14. displayNewMessages





-- This should display messages in the same fashion as the previous task except that only those messages sent since the last time the user logged into the system should be displayed (including group messages).
-- 15. displayFriends
-- This task supports the browsing of the logged-in user’s friends’ profiles. It first displays each of the user’s friends’ names and userIDs. Then it allows the user to either retrieve a friend’s entire profile by entering the appropriate userID or exit browsing and return to the main menu by entering 0 as a userID. When selected, a friend’s profile should be displayed in a nicely formatted way, after which the user should be prompted to either select to retrieve another friend’s profile or return to the main menu.








-- 16. rankGroups
-- This task should produce a ranked list of groups based on their number of members.
-- In the event that there are no groups in the system, a message “No Groups to Rank” should be displayed to the user.







-- 17. rankProfiles
-- This task should produce a ranked list of user profiles based on the number of friends they
-- have along with their number of friends.
-- Note the number of friends of a profile includes those who are members of the groups the user profile belongs to.






-- 18. topMessages
-- Display the top k users with respect to the number of messages sent to the logged-in user plus the number of messages received from the logged-in user in the past x months. x and k are input parameters to this function. 1 month is defined as 30 days counting back starting from the current date of the Clock table. Group messages do not need to be considered in this function.
-- 6
--







-- 19. threeDegrees
-- Given a userID, find a path, if one exists, between the logged-in user and that user profile with at most 3 hops between them. A hop is defined as a friendship between any two users.
-- This query should be written using plpgsql and should only use java for interfacing.






-- 20. logout
-- The function should return the user to the top level of the UI after marking the time of the user’s logout in the user’s “lastlogin” field of the user relation from the Clock table.
-- 21. exit
-- This option should cleanly shut down and exit the program.
