package org.example;

import java.sql.*;



public class Driver{
    public static void main(String[] args) throws SQLException {
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
        System.out.println(" And now we can accept the friend request");
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
        testConfirmFriendRequest(new Integer[]{1,4});
        System.out.println("We can now see both requests removed from pendingfriend...");
        displayPendingFriendsTable();
        System.out.println("And can see both to userID 5 in friend...");
        displayFriendTable();
        testLogout();
        System.out.println("\n\n\n");

        System.out.println("Lets log back into ADMIN and test group functionality.");
        BeSocial.login("admin@besocial.com", "admin");


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

    private static void testCreateGroup() throws SQLException {
        int res=  BeSocial.createGroup("Test Group", "group created for testing in driver",
                5);
        if (res==1){
            System.out.println("The group was successfully created.");
        }
    }

    private static void testInitiateAddingGroup() {

    }

    private static void testConfirmGroupMembership() {

    }

    private static void testLeaveGroup() {

    }

    private static void testSearchForProfile() {

    }

    private static void testSendMessageToUser() {

    }

    private static void testSendMessageToGroup() {

    }

    private static void testDisplayMessages() {

    }

    private static void testDisplayNewMessages() {

    }

    private static void testDisplayFriends() {

    }

    private static void testRankGroups() {

    }

    private static void testRankProfiles() {

    }

    private static void testTopMessages() {

    }

    private static void testThreeDegrees() {

    }

    private static void testExit() {

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
}
