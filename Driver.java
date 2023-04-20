import java.sql.*;
import java.sql.Date;
import java.util.*;
import java.util.List;

public class Driver{
    public static void main(String[] args) throws SQLException {
        setup();
        
        testLogin("admin@besocial.com", "admin");
        System.out.println("\n\n\n");

        testCreateProfile("Test_FN LastName", "test@email.com", "testPassword", "2011-01-01");
        System.out.println("\n\n\n");

        testDropProfile("test@email.com");
        System.out.println("\n\n\n");

        System.out.println("We will now insert 5 new profiles into the profile that will be used at various points.");
        loadFiveProfiles();
        System.out.println("\n\n\n");

        System.out.println("While we are still logged in as admin, we will send two friends requests.");
        testInitiateFriendship(4, "friend req. msg.");
        testInitiateFriendship(5,"friend req. msg.");
        System.out.println("When we check the pendingfriend table, we can now see the two entries");
        displayPendingFriendsTable();
        System.out.println("\n\n\n");

        System.out.println("We can now logout of admin.");
        testLogout();
        System.out.println("\n\n\n");

        System.out.println("We can now login to the first profile ADMIN sent a friend request to.");
        BeSocial.login("lr@email.com", "pass");
        System.out.println();
        System.out.println("And now we can accept the friend request");
        testConfirmFriendRequest(new Integer[]{1});
        System.out.println("We can now see the request removed from pendingfriend...");
        displayPendingFriendsTable();
        System.out.println("And can see it in friend...");
        displayFriendTable();
        System.out.println("\n\n\n");

        System.out.println("Lets send a friend request to the same second user as ADMIN did then logout.");
        testInitiateFriendship(5,"req from user 4");
        testLogout();
        System.out.println("\n\n\n");

        System.out.println("Now that user 5 has two requests, we can login and test adding multiple\n" +
                "friends at once using the 'ALL' feature");
        BeSocial.login("js@email.com", "pass");
        System.out.println();
        testConfirmFriendRequest(new Integer[]{1,4});
        System.out.println("We can now see both requests removed from pendingfriend...");
        displayPendingFriendsTable();
        System.out.println("And can see both to userID 5 in friend...\n");
        displayFriendTable();
        testLogout();
        System.out.println("\n\n\n");

        System.out.println("Lets log back into ADMIN and test create group functionality.");
        BeSocial.login("admin@besocial.com", "admin");
        System.out.println();
        System.out.println("Let's make two groups where ADMIN should be manager.");
        testCreateGroup("Test Group", "group created for testing in driver", 5);
        testCreateGroup("Admin Group 2", "second test group for driver", 5);
        System.out.println("We have created two new groups. We can see the changes in groupinfo.........................\n");
        displayGroupInfoTable();
        System.out.println("\nand in the groupmember table................................................................\n");
        displayGroupMemberTable();
        BeSocial.logout();
        System.out.println("\n\n\n");


        System.out.println("Now lets log in to user 4,5 and have them request to join the first group");
        BeSocial.login("lr@email.com", "pass");
        System.out.println();
        testInitiateAddingGroup(1,"req. to join first group");
        BeSocial.logout();
        BeSocial.login("js@email.com", "pass");
        System.out.println();
        testInitiateAddingGroup(1,"req. to join first group 2");
        BeSocial.logout();
        System.out.println("\nWe can now see the new entries in pendinggroupmembers ");
        displayPendingGroupMemberTable();
        System.out.println("...........................................................................................");
        System.out.println("\n\n\n");

        System.out.println("Now we can go and accept the group requests from ADMIN's profile, since it is the manager.");
        BeSocial.login("admin@besocial.com", "admin");
        System.out.println();

        HashMap<Integer, List<Integer>> myMap = new HashMap<>();
        myMap.put(1, Arrays.asList(4, 5));
        testConfirmGroupMembership(myMap);
        System.out.println("We can check the pendinggroupmembers and see those entries gone...");
        displayPendingGroupMemberTable();
        System.out.println("...........................................................................................");
        System.out.println("And we can see them in groupmember now");
        displayGroupMemberTable();
        System.out.println("...........................................................................................");
        BeSocial.logout();
        System.out.println("\n\n\n");

        System.out.println("We can now have Users 6,7 request to join the second group ADMIN created.");
        BeSocial.login("jm@email.com", "pass");
        System.out.println();
        testInitiateAddingGroup(2,"req. to join first group");
        BeSocial.logout();
        BeSocial.login("rv@email.com", "pass");
        System.out.println();
        testInitiateAddingGroup(2,"req. to join first group 2");
        BeSocial.logout();
        System.out.println("\nWe can now see the new entries in pendinggroupmembers ");
        displayPendingGroupMemberTable();
        System.out.println("...........................................................................................");
        System.out.println("\n\n\n");

        System.out.println("Now we can go and accept the new group requests from ADMIN's profile, since it is the manager");
        BeSocial.login("admin@besocial.com", "admin");

        myMap.clear();
        myMap.put(2, Arrays.asList(6, 7));
        testConfirmGroupMembership(myMap);
        System.out.println("We can check the pendinggroupmembers and see those entries gone...\n");
        displayPendingGroupMemberTable();
        System.out.println("...........................................................................................");
        System.out.println("And we can see them in groupmember now...");
        displayGroupMemberTable();
        System.out.println("...........................................................................................");
        BeSocial.logout();
        System.out.println("\n\n\n");

        System.out.println("Now lets log back in as user 7 and test the leave group.");
        BeSocial.login("rv@email.com", "pass");
        System.out.println();
        testLeaveGroup(2);
        System.out.println("We can see the changes in the groupmember table...");
        displayGroupMemberTable();
        System.out.println("...........................................................................................");
        System.out.println("After User 7 just left, ADMIN's first group should be larger than the second.");
        System.out.println("We can confirm this by testing rank groups");
        testRankGroups();
        System.out.println("...........................................................................................");
        System.out.println("\n\n\n");

        System.out.println("We can test search for profile logged in as User 7");
        System.out.println("Lets search for \"admin Lisa\"");
        testSearchForProfile("admin Lisa");
        BeSocial.logout();
        System.out.println("...........................................................................................");
        System.out.println("\n\n\n");

        System.out.println("Lets switch back to admin and test sending messages");
        BeSocial.login("admin@besocial.com", "admin");
        System.out.println();
        System.out.println("Lets send \"Test message from admin to UserID 4\" to UserID 4, one of our friends");
        testSendMessageToUser(4, "Test message from admin to UserID 4");
        System.out.println("Lets also send \"Test message from admin to GroupId 1\" to GroupID 1, one of our groups");
        testSendMessageToGroup(1, "Test message from admin to GroupID1");
        System.out.println("We can see these new messages in message...");
        displayMessage();
        System.out.println("...........................................................................................");
        System.out.println("And we can see the trigger also insert them in messagerecipient...");
        displayMessageRecipient();
        BeSocial.logout();
        System.out.println("...........................................................................................");
        System.out.println("\n\n\n");

        System.out.println("Lets switch over to UserID 4 who got both a personal and group message from ADMIN");
        BeSocial.login("lr@email.com", "pass");
        System.out.println();
        testDisplayMessages();
        System.out.println("Here you see the messages we just sent from ADMIN were received.");
        System.out.println("...........................................................................................");
        System.out.println("\n\n\n");

        System.out.println("Lets also look at some friend features. First the friends list");
        System.out.println("We will also test the view profile feature by looking into friend UserID 1, ADMIN");
        testDisplayFriends(true, new String[]{"1", "QUIT"});
        System.out.println("...........................................................................................");
        System.out.println("\n\n\n");

        System.out.println("Lets test rank profiles based off of number of friends + group members who aren't friend.");
        testRankProfiles();
        System.out.println("...........................................................................................");
        System.out.println("\n\n\n");

        System.out.println("Lets send some more friend requests so we can see up to three degree connections");
        System.out.println("Since we have already exhaustively tested sending friend requests and accepting from\n" +
                "the recipient's profile, I'll skip showing the tables for those parts");
        System.out.println("Instead, you can see what the user would see as responses.");
        System.out.println("We are going to add a friendship from UID4 to UID6 and UID6 to UID7\n");
        testInitiateFriendship(6,"req from user 4");
        BeSocial.logout();
        BeSocial.login("jm@email.com", "pass");
        System.out.println();
        testConfirmFriendRequest(new Integer[]{4});
        testInitiateFriendship(7,"req from user 6");
        BeSocial.logout();
        System.out.println();
        BeSocial.login("rv@email.com", "pass");
        System.out.println();
        testConfirmFriendRequest(new Integer[]{6});
        System.out.println("\nWe can now search for a connection from UID7 to UID1");
        testThreeDegrees(1);
        System.out.println("\n...........................................................................................");
        System.out.println("\n\n\n");

        System.out.println("That almost wraps up testing. Only thing left is exit. Here you go!");
        testExit();

    }
    public static void setup() throws SQLException{
        Connection conn = BeSocial.openConnection();
        Statement statement = conn.createStatement();

        String deleteQuery = "DELETE FROM clock WHERE 1=1;";
        statement.executeUpdate(deleteQuery);
        String insertIntoClock = "INSERT INTO clock VALUES ('2021-01-01 00:00:00');";
        statement.executeUpdate(insertIntoClock);
        String insertIntoProfile = "INSERT INTO profile VALUES (default, 'admin', 'admin@besocial.com', 'admin', '1963-03-15', '2022-09-11T03:00:03');";
        statement.executeUpdate(insertIntoProfile);
        conn.close();

        System.out.println("Assuming you ran schema2.sql and trigger2.sql already, the driver is setup!");
    }
    public static void testLogin(String email, String password) throws SQLException {
        System.out.println("We will first login as admin since only admin has permissions to add or drop profiles.");
        BeSocial.login(email, password);
        System.out.println("\nIf we try to login again, we will not be allowed...");
        BeSocial.login(email, password);
    }
    public static void testCreateProfile(String name, String email, String password, String dob) throws SQLException {
        if(BeSocial.createProfile(name,email,password,dob)==1) System.out.println("Profile was added.");

        System.out.println("Changes to Profile...............................................................................................................................");

        Connection conn = BeSocial.openConnection();
        PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM PROFILE WHERE email = ?");
        displayStatement.setString(1, email);
        ResultSet resultSet = displayStatement.executeQuery();
        conn.close();

        while (resultSet.next()) {
            int userId = resultSet.getInt("userID");
            String profileName = resultSet.getString("name");
            String profilePassword = resultSet.getString("password");
            Date profileDOB = resultSet.getDate("date_of_birth");
            Timestamp lastLogin = resultSet.getTimestamp("lastLogin");
            System.out.println("User ID: " + userId + ", Name: " + profileName + ", Email: " + email + ", Password: "
                    + profilePassword + ", DOB: " + profileDOB.toString() + ", Last Login: " + lastLogin.toString());
        }
        System.out.println(".................................................................................................................................................");
        System.out.println("Trying to insert the same user again will fail because of unique email constraint");

        BeSocial.createProfile(name,email,password,dob);

        System.out.println("NOTICE NO CHANGES to Profile...............................................................................................................................");
        conn = BeSocial.openConnection();
        displayStatement = conn.prepareStatement("SELECT * FROM PROFILE WHERE email = ?");
        displayStatement.setString(1, email);
        resultSet = displayStatement.executeQuery();
        conn.close();

        while (resultSet.next()) {
            int userId = resultSet.getInt("userID");
            String profileName = resultSet.getString("name");
            String profilePassword = resultSet.getString("password");
            Date profileDOB = resultSet.getDate("date_of_birth");
            Timestamp lastLogin = resultSet.getTimestamp("lastLogin");
            System.out.println("User ID: " + userId + ", Name: " + profileName + ", Email: " + email + ", Password: "
                    + profilePassword + ", DOB: " + profileDOB.toString() + ", Last Login: " + lastLogin.toString());
        }
        System.out.println(".................................................................................................................................................");
    }
    private static void testDropProfile(String email) throws SQLException {
        System.out.println("We will now remove the user we just added");

        if(BeSocial.dropProfile(email)==1){
            System.out.println("The user was dropped");
            System.out.println("Changes to Profile...............................................................................................................................");

            Connection conn = BeSocial.openConnection();
            PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM PROFILE WHERE email = ?");
            displayStatement.setString(1, email);
            ResultSet resultSet = displayStatement.executeQuery();
            conn.close();

            while (resultSet.next()) {
                int userId = resultSet.getInt("userID");
                String profileName = resultSet.getString("name");
                String profilePassword = resultSet.getString("password");
                Date profileDOB = resultSet.getDate("date_of_birth");
                Timestamp lastLogin = resultSet.getTimestamp("lastLogin");
                System.out.println("User ID: " + userId + ", Name: " + profileName + ", Email: " + email + ", Password: "
                        + profilePassword + ", DOB: " + profileDOB.toString() + ", Last Login: " + lastLogin.toString());
            }
            System.out.println(".................................................................................................................................................");
        }

        System.out.println("If we try to drop this same user again, we will not be able to...");
        if(BeSocial.dropProfile(email)==-1){
            System.out.println("Changes to Profile...............................................................................................................................");

            Connection conn = BeSocial.openConnection();
            PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM PROFILE WHERE email = ?");
            displayStatement.setString(1, email);
            ResultSet resultSet = displayStatement.executeQuery();
            conn.close();

            while (resultSet.next()) {
                int userId = resultSet.getInt("userID");
                String profileName = resultSet.getString("name");
                String profilePassword = resultSet.getString("password");
                Date profileDOB = resultSet.getDate("date_of_birth");
                Timestamp lastLogin = resultSet.getTimestamp("lastLogin");
                System.out.println("User ID: " + userId + ", Name: " + profileName + ", Email: " + email + ", Password: "
                        + profilePassword + ", DOB: " + profileDOB.toString() + ", Last Login: " + lastLogin.toString());
            }
            System.out.println(".................................................................................................................................................");
        }


    }
    private static void testInitiateFriendship(int toUserID, String message) throws SQLException {
        BeSocial.initiateFriendship(toUserID, message);
    }
    private static void testLogout() throws SQLException {
        if(BeSocial.logout()==1) System.out.println("You have successfully logged out");
    }
    private static void testConfirmFriendRequest(Integer[] toAccept) throws SQLException {
        BeSocial.confirmFriendRequests(toAccept);
    }

    private static void testCreateGroup(String groupName, String desc, int size) throws SQLException {
        int res = BeSocial.createGroup(groupName, desc, size);
        if (res==1){
            System.out.println("The group was successfully created.");
        }else{
            System.out.println("The group was not created.");
        }
    }

    private static void testInitiateAddingGroup(int gID, String requestText) throws SQLException {
        BeSocial.initiateAddingGroup(gID, requestText);
    }

    private static void testConfirmGroupMembership(HashMap<Integer, List<Integer>> toAdd) throws SQLException {
        int response = BeSocial.confirmGroupMembership(toAdd);
        if(response==1){
            System.out.println("Those members were added to the group.");
        }
    }

    private static void testLeaveGroup(int gID) throws SQLException {
        BeSocial.leaveGroup(gID);
    }

    private static void testSearchForProfile(String search) throws SQLException {
        BeSocial.searchForProfile(search);
    }

    private static void testSendMessageToUser(int userID, String message) throws SQLException {
        BeSocial.sendMessageToUser(userID, message);
    }

    private static void testSendMessageToGroup(int gID, String message) throws SQLException {
        BeSocial.sendMessageToGroup(gID, message);
    }

    private static void testDisplayMessages() throws SQLException {
        BeSocial.displayMessages();
    }

    private static void testDisplayNewMessages() {
    }

    private static void testDisplayFriends(boolean flag, String[] inputs) throws SQLException {
        BeSocial.displayFriends(flag, inputs);
    }

    private static void testRankGroups() throws SQLException {
        BeSocial.rankGroups();
    }

    private static void testRankProfiles() throws SQLException {
        BeSocial.rankProfiles();
    }

    private static void testTopMessages() {

    }

    private static void testThreeDegrees(int userID) throws SQLException {
        BeSocial.threeDegrees(userID);
    }
    private static void testExit() throws SQLException {
        BeSocial.exit();
    }


    //HELPER FUNCTIONS---------------------------------------------------------------------------
    private static void loadFiveProfiles() throws SQLException {
        BeSocial.createProfile("Lisa Robinson", "lr@email.com", "pass", "2011-09-09");
        BeSocial.createProfile("Jessica Savage", "js@email.com", "pass", "2011-02-23");
        BeSocial.createProfile("Jack Moore MD", "jm@email.com", "pass", "2011-06-04");
        BeSocial.createProfile("Ryan Vargas", "rv@email.com", "pass", "2011-05-06");
        BeSocial.createProfile("Carrie Shaw", "cs@email.com", "pass", "2011-11-03");

        System.out.println("Changes to Profile...............................................................................................................................");

        Connection conn = BeSocial.openConnection();
        PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM PROFILE");
        ResultSet resultSet = displayStatement.executeQuery();
        conn.close();

        while (resultSet.next()) {
            int userId = resultSet.getInt("userID");
            String profileName = resultSet.getString("name");
            String profilePassword = resultSet.getString("password");
            Date profileDOB = resultSet.getDate("date_of_birth");
            String email = resultSet.getString("email");
            Timestamp lastLogin = resultSet.getTimestamp("lastLogin");
            System.out.println("User ID: " + userId + ", Name: " + profileName + ", Email: " + email + ", Password: "
                    + profilePassword + ", DOB: " + profileDOB.toString() + ", Last Login: " + lastLogin.toString());
        }
        System.out.println(".................................................................................................................................................");
    }
    private static void displayPendingFriendsTable() throws SQLException {
        Connection conn = BeSocial.openConnection();
        PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM pendingfriend");
        ResultSet resultSet = displayStatement.executeQuery();
        conn.close();

        System.out.printf("%-10s %-10s %-50s%n", "userID1", "userID2", "requestText");
        System.out.println("---------------------------------------------------------");
        while (resultSet.next()) {
            int userID1 = resultSet.getInt("userID1");
            int userID2 = resultSet.getInt("userID2");
            String requestText = resultSet.getString("requestText");
            System.out.printf("%-10d %-10d %-50s%n", userID1, userID2, requestText);
        }
    }
    private static void displayFriendTable() throws SQLException {
        Connection conn = BeSocial.openConnection();
        PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM friend");
        ResultSet resultSet = displayStatement.executeQuery();
        conn.close();

        System.out.printf("%-10s %-10s %-10s %-50s%n", "userID1", "userID2", "JDate", "requestText");
        System.out.println("---------------------------------------------------------");
        while (resultSet.next()) {
            int userID1 = resultSet.getInt("userID1");
            int userID2 = resultSet.getInt("userID2");
            Date JDate = resultSet.getDate("JDate");
            String requestText = resultSet.getString("requestText");
            System.out.printf("%-10d %-10d %-10s %-50s%n", userID1, userID2, JDate.toString(), requestText);
        }
    }
    private static void displayGroupInfoTable() throws SQLException {
        Connection conn = BeSocial.openConnection();
        PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM groupinfo");
        ResultSet resultSet = displayStatement.executeQuery();
        conn.close();

        System.out.printf("%-5s %-30s %-10s %-50s%n", "gID", "name", "size", "description");
        System.out.println("--------------------------------------------------------------");
        while (resultSet.next()) {
            int gID = resultSet.getInt("gID");
            String name = resultSet.getString("name");
            int size = resultSet.getInt("size");
            String description = resultSet.getString("description");
            System.out.printf("%-5d %-30s %-10d %-50s%n", gID, name, size, description);
        }
    }
    private static void displayGroupMemberTable() throws SQLException {
        Connection conn = BeSocial.openConnection();
        PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM groupmember");
        ResultSet resultSet = displayStatement.executeQuery();
        conn.close();

        System.out.printf("%-10s %-10s %-20s %-25s%n", "gID", "userID", "role", "lastConfirmed");
        System.out.println("---------------------------------------------------------");
        while (resultSet.next()) {
            int gID = resultSet.getInt("gID");
            int userID = resultSet.getInt("userID");
            String role = resultSet.getString("role");
            Timestamp lastConfirmed = resultSet.getTimestamp("lastConfirmed");
            System.out.printf("%-10d %-10d %-20s %-25s%n", gID, userID, role, lastConfirmed.toString());
        }
    }
    private static void displayPendingGroupMemberTable() throws SQLException {
        Connection conn = BeSocial.openConnection();
        PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM pendinggroupmember");
        ResultSet resultSet = displayStatement.executeQuery();
        conn.close();

        System.out.printf("%-10s %-10s %-50s %-20s%n", "gID", "userID", "requestText", "requestTime");
        System.out.println("--------------------------------------------------------------------------------------");
        while (resultSet.next()) {
            int gID = resultSet.getInt("gID");
            int userID = resultSet.getInt("userID");
            String requestText = resultSet.getString("requestText");
            Timestamp requestTime = resultSet.getTimestamp("requestTime");
            System.out.printf("%-10d %-10d %-50s %-20s%n", gID, userID, requestText, requestTime.toString());
        }
    }
    private static void displayMessage() throws SQLException {
        Connection conn = BeSocial.openConnection();
        PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM message");
        ResultSet resultSet = displayStatement.executeQuery();
        conn.close();

        System.out.printf("%-8s %-8s %-25s %-8s %-10s %-25s%n", "msgID", "fromID", "messageBody", "toUserID", "toGroupID", "timeSent");
        System.out.println("---------------------------------------------------------------------");
        while (resultSet.next()) {
            int msgID = resultSet.getInt("msgID");
            int fromID = resultSet.getInt("fromID");
            String messageBody = resultSet.getString("messageBody");
            Integer toUserID = resultSet.getInt("toUserID");
            Integer toGroupID = resultSet.getInt("toGroupID");
            Timestamp timeSent = resultSet.getTimestamp("timeSent");
            System.out.printf("%-8d %-8d %-25s %-8d %-10d %-25s%n", msgID, fromID, messageBody, toUserID, toGroupID, timeSent.toString());
        }
    }
    private static void displayMessageRecipient() throws SQLException {
        Connection conn = BeSocial.openConnection();
        PreparedStatement displayStatement = conn.prepareStatement("SELECT * FROM messagerecipient");
        ResultSet resultSet = displayStatement.executeQuery();
        conn.close();

        System.out.printf("%-10s %-10s%n", "msgID", "userID");
        System.out.println("------------------------------");
        while (resultSet.next()) {
            int msgID = resultSet.getInt("msgID");
            int userID = resultSet.getInt("userID");
            System.out.printf("%-10d %-10d%n", msgID, userID);
        }

    }
}
