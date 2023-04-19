package org.example;

import javax.swing.*;
import javax.xml.stream.events.ProcessingInstruction;
import java.sql.*;
import java.sql.Date;
import java.util.*;

public class BeSocial{

    private static final String url = "jdbc:postgresql://localhost:5432/";
    private static final String user = "postgres";
    private static final String pass = "4qwkzaaw";
    public static Profile currentAccount = null;

    public static void main(String[] args) throws SQLException {

        Scanner scanner = new Scanner(System.in);
        boolean quit = false;

        while (!quit){
            System.out.printf("-----BeSocial-----\n");

            if(currentAccount==null) {
                System.out.println("Please select an option:");
                System.out.println("1. Create Profile");
                System.out.println("2. Drop Profile");
                System.out.println("3. Login");
                System.out.println("4. Exit");
                System.out.print("Selecting option: ");
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1 -> Dashboard.startCreateProfile();
                    case 2 -> Dashboard.startDropProfile();
                    case 3 -> Dashboard.startLogin();
                    case 4 -> {
                        exit();
                        Dashboard.scanner.close();
                        quit = true;
                    }
                    default -> System.out.println("Invalid choice, please try again");
                }
            }else if(currentAccount!=null) {
                System.out.printf("Welcome, %s\n\n", currentAccount.getName());
                System.out.println("1. Create Profile");
                System.out.println("2. Drop Profile");
                System.out.println("3. Initiate Friendship");
                System.out.println("4. Confirm Friend Request(s)");
                System.out.println("5. Create Group");
                System.out.println("6. Initiate Adding Group");
                System.out.println("7. Confirm Group Membership");
                System.out.println("8. Leave Group");
                System.out.println("9. Search for Profile");
                System.out.println("10. Send Message to User");
                System.out.println("11. Send Message to Group");
                System.out.println("12. Display Messages");
                System.out.println("13. Display New Messages");
                System.out.println("14. Display Friends");
                System.out.println("15. Rank Groups");
                System.out.println("16. Rank Profiles");
                System.out.println("17. Top Messages");
                System.out.println("18. Three Degrees");
                System.out.println("19. Logout");
                System.out.println("20. Exit");
                System.out.print("Selecting option: ");
                int choice = scanner.nextInt();
                switch (choice) {
                    case 1:
                        Dashboard.startCreateProfile();
                        break;
                    case 2:
                        Dashboard.startDropProfile();
                        break;
                    case 3:
                        Dashboard.startInitiateFriendship();
                        break;
                    case 4:
                        Dashboard.startConfirmFriendRequest();
                        break;
                    case 5:
                        Dashboard.startCreateGroup();
                        break;
                    case 6:
                        Dashboard.startInitiateAddingGroup();
                        break;
                    case 7:
                        Dashboard.startConfirmGroupMembership();
                        break;
                    case 8:
                        Dashboard.startLeaveGroup();
                        break;
                    case 9:
                        Dashboard.startSearchForProfile();
                        break;
                    case 10:
                        Dashboard.startSendMessageToUser();
                        break;
                    case 11:
                        System.out.println("You chose option 11: Send Message to Group");
                        // Code to send a message to a group
                        break;
                    case 12:
                        System.out.println("You chose option 12: Display Messages");
                        // Code to display messages
                        break;
                    case 13:
                        System.out.println("You chose option 13: Display New Messages");
                        // Code to display new messages
                        break;
                    case 14:
                        System.out.println("You chose option 14: Display Friends");
                        // Code to display friends
                        break;
                    case 15:
                        System.out.println("You chose option 15: Rank Groups");
                        // Code to rank groups
                        break;
                    case 16:
                        System.out.println("You chose option 16: Rank Profiles");
                        // Code to rank profiles
                        break;
                    case 17:
                        System.out.println("You chose option 17: Top Messages");
                        // Code to display top messages
                        break;
                    case 18:
                        System.out.println("You chose option 18: Three Degrees");
                    case 19:
                        logout();
                        System.out.printf("\n\n\n\n\n\n\n\n");
                        break;
                    case 20:
                        System.out.printf("Thanks for visiting, %s\n", exit());
                        Dashboard.scanner.close();
                        quit = true;
                        break;
                    default:
                        System.out.println("Invalid choice, please try again");
                        break;
                }
            }
        }


    }

    public static Connection openConnection() {
        Connection connToReturn = null;

        try {
            Class.forName("org.postgresql.Driver");
        } catch (Exception e) {
            System.out.println("Message = " + "Postgresql Driver class not found");
            e.printStackTrace();
        }

        try {
            connToReturn = DriverManager.getConnection(url, user, pass);
            connToReturn.setAutoCommit(true);
            connToReturn.setTransactionIsolation(Connection.TRANSACTION_SERIALIZABLE);
        } catch (Exception e) {
            System.out.println("Message = " + "Connection to database failed!");
            e.printStackTrace();
        }

        return connToReturn;
    }

    /**
     * Creates a new user profile with the given parameters and adds to the profile relation.
     *
     * @param name the name of the user
     * @param email the email address of the user
     * @param password the password of the user
     * @param DOB the date of birth of the user
     * @return the userID of the newly created user profile, or -1 if an error occurred
     * @throws SQLException if an error occurs while executing the SQL statements
     */
    public static int createProfile(String name, String email, String password, String DOB) throws SQLException{

        Connection conn = openConnection();

        PreparedStatement preparedStatement = conn.prepareStatement("INSERT INTO PROFILE values(default, ?, ?, ?, ?)");
        preparedStatement.setString(1, name);
        preparedStatement.setString(2, email);
        preparedStatement.setString(3, password);
        preparedStatement.setDate(4, Date.valueOf(DOB));
        //preparedStatement.setString(4, DOB);
        preparedStatement.executeUpdate();

        //TODO: we should be returning the ID of the user that was just added. For now we are just
        // returning 1 and -1. FIX TO RETURN USERID

        conn.close();
        return 1;
    }

    /**
     * Removes a user profile and associated data from the system.
     *
     * <p>Prompts for the email of the user profile to remove and deletes the profile along with all of their
     * information from the system. When a profile is removed, the system should use a trigger to delete the user
     * from the groups they are a member of. The system should also use a trigger to delete any message whose
     * sender and all receivers are deleted. Attention should be paid to handling integrity constraints.</>
     *
     * @param email the email address of the user profile to remove
     * @return 1 if the profile was successfully deleted, -1 otherwise
     * @throws SQLException if an error occurs while executing the SQL statements
     */
    public static int dropProfile(String email) throws SQLException{
        if(currentAccount==null || (currentAccount!=null && !currentAccount.isAdmin())){
            System.out.println("You do not have permission to perform this operation.");
        }

        Connection conn = openConnection();

        PreparedStatement preparedStatement = conn.prepareStatement("DELETE FROM PROFILE where email=?");
        preparedStatement.setString(1, email);
        int affectedRows = preparedStatement.executeUpdate();
        conn.close();

        //TODO: we should be returning 1 if the user was successfully deleted. We need to implement the triggers that
        // check and remove the rest of the areas it touches

        if(affectedRows>0){
            return 1;
        }else{
            return -1;
        }
    }

    /**
     * Logs in a user with the provided email and password.
     *
     * @param email The email of the user attempting to log in.
     * @param password The password of the user attempting to log in.
     * @return An integer value representing the user ID of the logged in user if login is successful,
     *         or -1 if the email or password is invalid or if an error occurs.
     * @throws SQLException if an error occurs while executing the SQL statements
     */
    public static int login(String email, String password) throws SQLException{
        if (currentAccount != null) return -1;

        Connection conn = openConnection();

        PreparedStatement preparedStatement = conn.prepareStatement("SELECT userID, name, date_of_birth" +
                " FROM PROFILE WHERE email=? AND password=?");
        preparedStatement.setString(1, email);
        preparedStatement.setString(2, password);
        ResultSet response = preparedStatement.executeQuery();

        if (response.next()) {
            Profile profile = new Profile(email, password);
            profile.setUserID(response.getInt("userID"));
            profile.setName(response.getString("name"));
            profile.setEmail(email);
            profile.setPassword(password);
            profile.setDateOfBirth(response.getDate("date_of_birth"));

            if(currentAccount==null) currentAccount = profile;
        }

        if(currentAccount!=null){
            System.out.printf("The user was found. Name is %s, email is %s", currentAccount.getName(),
                    currentAccount.getEmail());
            return 1;
        }else{
            System.out.println("nothing matching was found");
            return -1;
        }

    }

    /**
     * Creates a pending friendship from the logged-in user profile to another user profile based on userID.
     * The application displays the name of the person that will be sent a friend request and prompts the user
     * to enter the text to be sent along with the request. A last confirmation is requested before an entry
     * is inserted into the pendingFriend relation. Success or failure feedback is displayed for the user.
     *
     * @param sendToUserID the user ID of the user to send a friend request to
     * @throws SQLException if an error occurs while accessing the database
     */
    public static int initiateFriendship(int sendToUserID) throws SQLException{
        if(currentAccount==null) return -1;

        Connection conn = openConnection();
        PreparedStatement preparedStatement = conn.prepareStatement("SELECT name FROM PROFILE WHERE " +
                "userID=?");
        preparedStatement.setInt(1, sendToUserID);
        ResultSet response  = preparedStatement.executeQuery();
        conn.close();

        String name = null;
        if (response.next()){
            name = response.getString("name");
            String message = Dashboard.initiateFriendshipMessage(name);

            if(message!=null){
                conn = openConnection();
                preparedStatement = conn.prepareStatement("INSERT INTO pendingFriend (userID1, userID2, " +
                        "requestText) VALUES (?, ?, ?)");
                preparedStatement.setInt(1, currentAccount.getUserID());
                preparedStatement.setInt(2, sendToUserID);
                preparedStatement.setString(3, message);
                preparedStatement.executeUpdate();
                conn.close();
                System.out.println("Your friend request was sent");
                return 1;
            }
            System.out.println("Request not sent.");
            return -1;
        }
        System.out.println("Request failed.");
        return -1;
    }

    /**
     * Displays a formatted, numbered list of all outstanding friend requests with associated request text.
     * Prompts the user for the number of the request(s) they want to confirm or the option to confirm them all.
     * Moves the selected request(s) from the pendingFriend relation to the friend relation with JDate set to the
     * current date of the Clock table. Declines and removes the remaining requests from the pendingFriend relation.
     *
     * @return the number of friends that were added (if any),
     *      -1 if an error occurs during database operations,
     *       0 if the user has no pending friend requests.
     * @throws SQLException if there is an error accessing the database
     */
    public static int confirmFriendRequests() throws SQLException{
        if(currentAccount==null) return -1;

        Connection conn = openConnection();
        PreparedStatement preparedStatement = conn.prepareStatement("SELECT userID1, requestText FROM pendingFriend WHERE userID2=?");
        preparedStatement.setInt(1, currentAccount.getUserID());
        ResultSet response  = preparedStatement.executeQuery();
        conn.close();

        List<FriendRequest> friendRequestList = new ArrayList<>();
        while(response.next()){
            FriendRequest friendRequest = new FriendRequest();
            friendRequest.setUserID1(response.getInt("userID1"));
            friendRequest.setUserID2(currentAccount.getUserID());
            friendRequest.setRequestText(response.getString("requestText"));
            friendRequestList.add(friendRequest);
        }

        int responseCode = Dashboard.displayFriendRequests(friendRequestList);
        if(responseCode==-1) return -1;

        Integer[] toAdd = Dashboard.getFriendsToAdd(friendRequestList);
        if(toAdd.length==0){
            System.out.println("No new friends were add. Requests deleted!");
            return -1;
        }else{
            System.out.println("IDs that are being added: " + Arrays.toString(toAdd));
        }

        conn = openConnection();
        CallableStatement callableStatement = conn.prepareCall("call add_select_friend_reqs(?,?)");
        callableStatement.setInt(1, currentAccount.getUserID());
        callableStatement.setArray(2, conn.createArrayOf("INTEGER", toAdd));
        callableStatement.execute();
        conn.close();

        System.out.println("Selected friends were added!");

        return 1;
    }
    public static int createGroup(String groupName, String description, int membershipLimit) throws SQLException {
        if(currentAccount==null) return -1;

        //CREATE OR REPLACE PROCEDURE createGroup (name varchar(50),size int,description varchar(200),userid int)
        Connection conn = openConnection();
        CallableStatement callableStatement = conn.prepareCall("call createGroup(?,?,?,?)");
        callableStatement.setString(1, groupName);
        callableStatement.setInt(2, membershipLimit);
        callableStatement.setString(3, description);
        callableStatement.setInt(4, currentAccount.getUserID());
        callableStatement.execute();
        conn.close();

        return 1;
    }
    public static int initiateAddingGroup(int groupID, String requestText) throws SQLException{
        if(currentAccount==null) return -1;

        Connection conn = openConnection();
        CallableStatement callableStatement = conn.prepareCall("call createPendingGroupMember(?,?,?)");
        callableStatement.setInt(1, groupID);
        callableStatement.setInt(2, currentAccount.getUserID());
        callableStatement.setString(3, requestText);
        callableStatement.execute();
        conn.close();

        System.out.println("Your request to join the group was sent!");

        return -1;
    }
    public static int confirmGroupMembership() throws SQLException {
        if(currentAccount==null) return -1;

        Connection conn = openConnection();
        PreparedStatement preparedStatement = conn.prepareStatement("SELECT * FROM get_pending_members(?)");
        preparedStatement.setInt(1, currentAccount.getUserID());
        ResultSet resultSet = preparedStatement.executeQuery();

        conn.close();

        List<GroupRequest> groupRequestList = new ArrayList<>();
        while(resultSet.next()){
            GroupRequest groupRequest = new GroupRequest();
            groupRequest.setgID(resultSet.getInt("gID"));
            groupRequest.setUserID(resultSet.getInt("userID"));
            groupRequest.setRequestText(resultSet.getString("requestText"));
            groupRequest.setRequestTime(resultSet.getDate("requestTime"));
            groupRequestList.add(groupRequest);
        }

        int responseCode = Dashboard.displayGroupRequests(groupRequestList);
        if(responseCode==-1){
            System.out.println("No Pending Group Membership Requests");
            return -1;
        }


        HashMap<Integer, List<Integer>> groupAndToAcceptMapping = Dashboard.getGroupRequestsToAdd(groupRequestList);
        int numToAdd = groupAndToAcceptMapping.size();
        if(numToAdd==0){
            System.out.println("No new group members were added. Requests deleted!");
            return -1;
        }else{
            System.out.println("Adding the selected group members");
            conn = openConnection();
            for(int i : groupAndToAcceptMapping.keySet()){
                CallableStatement callableStatement = conn.prepareCall("call confirmGroupMembers(?, ?)");
                callableStatement.setInt(1,i);
                callableStatement.setArray(2, conn.createArrayOf("INTEGER", groupAndToAcceptMapping.get(i).toArray()));
                callableStatement.execute();
            }
            conn.close();
        }

        //TODO: handle "No groups are currently managed" should be displayed if the user is not a manager of any groups
        return 1;
    }
    public static int leaveGroup(int gID) throws SQLException {
        if(currentAccount==null) return -1;

        Connection conn = openConnection();
        CallableStatement callableStatement = conn.prepareCall("SELECT leaveGroup(?,?)");
        callableStatement.setInt(1, gID);
        callableStatement.setInt(2, currentAccount.getUserID());
        ResultSet rs = callableStatement.executeQuery();
        conn.close();

        int affected=0;
        if (rs.next()) {
            affected = rs.getInt(1);
        }

        if(affected == 1){
            System.out.println("You have left the group!");
            return 1;
        }else{
            System.out.println("Not a Member of any Groups");
        }

        return -1;

    }
    public static int searchForProfile(String search) throws SQLException {
        if(currentAccount==null) return -1;

        Connection conn = openConnection();
        PreparedStatement preparedStatement = conn.prepareStatement("SELECT search_user_profiles(?)");
        preparedStatement.setArray(1, conn.createArrayOf("text", search.split(" ")));
        ResultSet resultSet = preparedStatement.executeQuery();
        conn.close();

        ResultSetMetaData metadata = resultSet.getMetaData();
        int numColumns = metadata.getColumnCount();



        List<Profile> matchingProfileList = new ArrayList<Profile>();
        while(resultSet.next()){
            Profile p = new Profile();
            String response = resultSet.getString("search_user_profiles");
            //this is a case to handle when the user only has a single name, such as in the case of admin
            //in those cases, the resulting string doesn't have "" surrounding, so the substring bounds are adjusted
            if(response.charAt(response.length()-1)!='"'){
                String[] fields = response.substring(1,response.length()-1).split(",");
                p.setUserID(Integer.parseInt(fields[0]));
                p.setName(fields[1]);
            }else{
                String[] fields = response.substring(1,response.length()-2).split(",");
                p.setUserID(Integer.parseInt(fields[0]));
                p.setName(fields[1].substring(1));
            }
            matchingProfileList.add(p);
        }
        Dashboard.displayProfiles(matchingProfileList);
        return -1;
    }

    public static int sendMessageToUser(int userId) throws SQLException {
        Connection conn = openConnection();
        PreparedStatement preparedStatement = conn.prepareStatement("SELECT name FROM PROFILE WHERE " +
                "userID=?");
        preparedStatement.setInt(1, userId);
        ResultSet response  = preparedStatement.executeQuery();
        conn.close();

        String name = null;
        if (response.next()){
            name = response.getString("name");
            String message = Dashboard.sendMessageInput(name);

            if(message!=null){
                conn = openConnection();
                CallableStatement callableStatement = conn.prepareCall("call send_message_to_friend(?,?,?)");
                callableStatement.setInt(1, currentAccount.getUserID());
                callableStatement.setInt(2, userId);
                callableStatement.setString(3, message);
                callableStatement.executeUpdate();
                conn.close();

                System.out.println("Your message was sent.");
                return 1;
            }
            System.out.println("Message not sent.");
            return -1;
        }else{
            System.out.println("That userID wasn't found. Message send failed.");
            return -1;
        }

    }

    public static int sendMessageToGroup(){
        return -1;
    }

    public static int displayMessages(){
        return -1;
    }

    public static int displayNewMessages(){
        return -1;
    }

    public static int displayFriends(){
        return -1;
    }
    public static int rankGroups(){
        return -1;
    }

    public static int rankProfiles(){
        return -1;
    }

    public static int topMessages(){
        return -1;
    }

    public static int threeDegrees(){
        return -1;
    }

    public static int logout() throws SQLException {
        if(currentAccount==null) return -1;

        Connection conn = openConnection();
        CallableStatement callableStatement = conn.prepareCall("call update_last_login(?)");
        callableStatement.setInt(1, currentAccount.getUserID());
        callableStatement.execute();
        conn.close();
        currentAccount=null;
        return 1;
    }

    public static String exit() throws SQLException {
        System.out.println("Now exiting BeSocial!");
        if(currentAccount!=null){
            String toReturn = currentAccount.getName();
            logout();
            return toReturn;
        }
        return null;
    }


    public static class Profile {
        private int userID;
        private String name;
        private String email;
        private String password;
        private Date dateOfBirth;
        private Date lastLogin;

        public Profile(int userID, String name, String email, String password, Date dateOfBirth, Date lastLogin) {
            this.userID = userID;
            this.name = name;
            this.email = email;
            this.password = password;
            this.dateOfBirth = dateOfBirth;
            this.lastLogin = lastLogin;
        }

        public Profile(String email, String password) {
            this.email = email;
            this.password = password;
        }

        public Profile() {

        }

        public int getUserID() {
            return userID;
        }

        public void setUserID(int userID) {
            this.userID = userID;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getEmail() {
            return email;
        }

        public void setEmail(String email) {
            this.email = email;
        }

        public String getPassword() {
            return password;
        }

        public void setPassword(String password) {
            this.password = password;
        }

        public Date getDateOfBirth() {
            return dateOfBirth;
        }

        public void setDateOfBirth(Date dateOfBirth) {
            this.dateOfBirth = dateOfBirth;
        }

        public Date getLastLogin() {
            return lastLogin;
        }

        public void setLastLogin(Date lastLogin) {
            this.lastLogin = lastLogin;
        }

        public boolean isAdmin() {
            if(this.name.equals("admin") &&
                    this.email.equals("admin@besocial.com")&&
                    this.password.equals("admin")
            ) return true;
            return false;
        }
    }

    public static class FriendRequest{
        private int UserID1;
        private int UserID2;
        private String requestText;

        public FriendRequest() {
        }

        public FriendRequest(int userID1, String requestText) {
            UserID1 = userID1;
            this.requestText = requestText;
        }

        public int getUserID1() {
            return UserID1;
        }

        public void setUserID1(int userID1) {
            UserID1 = userID1;
        }

        public int getUserID2() {
            return UserID2;
        }

        public void setUserID2(int userID2) {
            UserID2 = userID2;
        }

        public String getRequestText() {
            return requestText;
        }

        public void setRequestText(String requestText) {
            this.requestText = requestText;
        }
    }
    public static class GroupRequest{
        private int gID;
        private int userID;
        private String requestText;
        private Date requestTime;

        public GroupRequest() {
        }

        public int getgID() {
            return gID;
        }

        public void setgID(int gID) {
            this.gID = gID;
        }

        public int getUserID() {
            return userID;
        }

        public void setUserID(int userID) {
            this.userID = userID;
        }

        public String getRequestText() {
            return requestText;
        }

        public void setRequestText(String requestText) {
            this.requestText = requestText;
        }

        public Date getRequestTime() {
            return requestTime;
        }

        public void setRequestTime(Date requestTime) {
            this.requestTime = requestTime;
        }
    }

    public static class Dashboard{

        public static Scanner scanner = new Scanner(System.in);


        //code for createProfile--------------------------------------------------------
        private static void startCreateProfile() throws SQLException {
            if(currentAccount==null || (currentAccount!=null && !currentAccount.isAdmin())){
                System.out.println("You do not have permission to perform this operation.");
                return;
            }

            List<String> details = getProfileDetails();
            int response = createProfile(details.get(0),details.get(1),details.get(2), details.get(3));
            if(response == -1){
                System.out.println("Profile creation failed... returning to menu!");
            }else{
                System.out.printf("The new profile has been created with ID %n\n", response);
            }
        }
        private static List<String> getProfileDetails(){
            List<String> response = new ArrayList<>(2);
            System.out.printf("To create a new profile, enter the details below.\n");
            System.out.print("Name: ");
            response.add(scanner.nextLine().trim());
            System.out.print("Email: ");
            response.add(scanner.nextLine().trim());
            System.out.print("Password: ");
            response.add(scanner.nextLine().trim());
            System.out.print("Date of Birth: ");
            response.add(scanner.nextLine().trim());
            return response;
        }

        //end code for createProfile-----------------------------------------------------



        //code for dropProfile-----------------------------------------------------
        private static void startDropProfile() throws SQLException {
            if(currentAccount==null || (currentAccount!=null && !currentAccount.isAdmin())){
                System.out.println("You do not have permission to perform this operation.");
                return;
            }

            String email = getEmail();
            int response = dropProfile(email);
            if(response == -1){
                System.out.println("Drop profile creation failed... returning to menu!");
            }else{
                System.out.printf("The user with email %s and ID %n has been removed\n", email, response);
            }
        }
        private static String getEmail(){
            System.out.printf("To drop a profile, enter the email below.\n");
            System.out.print("Email: ");
            String email = scanner.nextLine().trim();
            return email;
        }
        //end code for dropProfile-------------------------------------------------



        //code for login--------------------------------------------------------
        private static void startLogin() throws SQLException {
            List<String> loginDetails = getLoginDetails();
            int response = login(loginDetails.get(0), loginDetails.get(1));
            if(response == -1){
                System.out.println("Login failed... returning to menu!");
            }else{
                System.out.printf("You are now logged in as %s\n", currentAccount.getName());
            }
        }
        private static List<String> getLoginDetails(){
            List<String> response = new ArrayList<>(2);
            System.out.printf("Welcome to BeSocial! Enter your login below.\n");
            System.out.print("Email: ");
            String email = scanner.nextLine().trim();
            response.add(email);
            System.out.print("Password: ");
            String password = scanner.nextLine().trim();
            response.add(password);
            return response;
        }
        //end code for login--------------------------------------------------------



        //code for initiate friend request--------------------------------------------------------
        private static int startInitiateFriendship() throws SQLException {
            int toUserID = getUserID();
            initiateFriendship(toUserID);
            return 1;
        }
        private static int getUserID(){
            System.out.print("Enter the UserID of the person you would like to request.\nUserID: ");
            String input = scanner.nextLine().trim();
            try {
                int userID = Integer.parseInt(input);
                return userID;
            } catch (NumberFormatException e) {
                System.out.println("Enter the UserID of the user you would like to request.");
            }
            return -1;
        }
        private static String initiateFriendshipMessage(String name){
            System.out.printf("You are sending a friend request to %s. Enter your message below.\n", name);
            System.out.print("Message: ");
            String message = scanner.nextLine();
            System.out.println("\n");
            System.out.printf("Are you sure you want to send this message to %s? (Y/N)\n", name);
            char response = scanner.nextLine().toLowerCase().trim().charAt(0);
            if(response == 'y'){
                return message;
            }else{
                return null;
            }
        }
        //end code for initiate friend request--------------------------------------------------------



        //code for confirm friend request--------------------------------------------------------
        private static void startConfirmFriendRequest() throws SQLException {
            confirmFriendRequests();
            return;
        }
        public static int displayFriendRequests(List<FriendRequest> response) {
            if(response.size()==0){
                System.out.println("No Pending Friend Requests");
                return -1;
            }

            System.out.println("-------+------------------+------------------------------+");
            System.out.printf("%-3s | %-16s | %-28s |\n", "Req. #" ,"From UserID", "Request Text");
            System.out.println("-------+------------------+------------------------------+");
            int i=1;
            for (FriendRequest fr : response) {
                int userID = fr.getUserID1();
                String requestText = fr.getRequestText();
                System.out.printf("%-6s | %-16d | %-28s |\n",i++, userID, requestText);
            }
            System.out.println("-------+------------------+------------------------------+");
            return 1;
        }
        private static Integer[] getFriendsToAdd(List<FriendRequest> friendRequestList){
            int MAX_NUM=friendRequestList.size();
            ArrayList<Integer> newList = new ArrayList<>(MAX_NUM);
            boolean done = false;
            while (!done) {
                System.out.print("Enter a request number to accept (or 'ALL' for all or 'DONE' to stop): ");
                String input = scanner.nextLine().trim().toUpperCase();
                int cur=0;
                switch (input) {
                    case "ALL":
                        newList.clear();
                        for (int i = 0; i < MAX_NUM; i++) {
                            newList.add(friendRequestList.get(i).getUserID1());
                        }
                        System.out.println("Accepted all requests.");
                        break;
                    case "DONE":
                        done = true;
                        break;
                    default:
                        try {
                            int requestNumber = Integer.parseInt(input);
                            if (requestNumber >= 1 && requestNumber <= MAX_NUM) {
                                newList.add(friendRequestList.get(requestNumber-1).getUserID1());
                                //toAdd[cur++]=friendRequestList.get(requestNumber-1).getUserID1(); //-1 since it will correspond to the index in caller
                                System.out.printf("Added request %d, UserID: %d.\n", requestNumber, friendRequestList.get(requestNumber-1).getUserID1());
                            } else {
                                System.out.printf("Request number must be between 1 and %d.%n", friendRequestList.size());
                            }
                        } catch (NumberFormatException e) {
                            System.out.println("Invalid input.");
                        }
                }
            }
            return newList.toArray(new Integer[0]);
        }
        //end code for confirm friend request----------------------------------------------------



        //code for create group--------------------------------------------------------
        private static void startCreateGroup() throws SQLException {
            List<String> resultSet = getGroupDetails();
            createGroup(resultSet.get(0), resultSet.get(1), Integer.parseInt(resultSet.get(2)));
        }

        private static List<String> getGroupDetails(){
            List<String> detailList = new ArrayList<>(3);

            System.out.println("To create a new group, enter the details below.");
            System.out.print("Group name: ");
            detailList.add(scanner.nextLine().trim());
            System.out.print("Description: ");
            detailList.add(scanner.nextLine().trim());

            try {
                System.out.print("Max group size: ");
                int groupSize = scanner.nextInt();
                detailList.add(groupSize+"");
            } catch (NumberFormatException e) {
                System.out.println("You must enter a number for the max group size.");
            }
            return detailList;
        }
        //end code for create group----------------------------------------------------


        //code for initiate adding group----------------------------------------------------
        public static void startInitiateAddingGroup() throws SQLException {
            List<String> inputDetails = getGroupReqDetails();
            initiateAddingGroup(Integer.parseInt(inputDetails.get(0)), inputDetails.get(1));
        }
        public static List<String> getGroupReqDetails(){
            List<String> toReturnDetails = new ArrayList<>(2);
            System.out.print("Enter the details of the group you'd like to join.\nGroupID: ");
            String input = scanner.nextLine().trim();
            try {
                int gID = Integer.parseInt(input);
                toReturnDetails.add(gID+"");
            } catch (NumberFormatException e) {
                System.out.println("Enter the Group ID you would like to request.");
            }
            System.out.print("Enter your request text: ");
            toReturnDetails.add(scanner.nextLine());

            return toReturnDetails;
        }
        //end code for initiate adding group-------------------------------------------------



        //code for confirm group member----------------------------------------------------
        public static void startConfirmGroupMembership() throws SQLException {
            confirmGroupMembership();
        }
        public static int displayGroupRequests(List<GroupRequest> response) {
            if(response.size()==0){
                System.out.println("No Pending Group Member Requests");
                return -1;
            }

            System.out.println("+-------+----------+--------------------------+--------------------------------------+");
            System.out.println("| Req.# | Group ID | From User ID             | Request Text                         |");
            System.out.println("+-------+----------+--------------------------+--------------------------------------+");
            int i=1;
            for (GroupRequest gr : response) {
                int gId = gr.getgID();
                int userID = gr.getUserID();
                String requestText = gr.getRequestText();
                System.out.printf("| %-5d | %-8d | %-24d | %-36s |\n", i++, gId, userID, requestText);
            }
            System.out.println("+-------+----------+--------------------------+--------------------------------------+");
            return 1;
        }
        public static HashMap<Integer, List<Integer>> getGroupRequestsToAdd(List<GroupRequest> groupRequestList) {
            int MAX_NUM=groupRequestList.size();
            HashMap<Integer, List<Integer>> newList = new HashMap<>();

            boolean done = false;
            while (!done) {
                System.out.print("Enter a request number to accept (or 'ALL' for all or 'DONE' to stop): ");
                String input = scanner.nextLine().trim().toUpperCase();
                switch (input) {
                    case "ALL":
                        newList.clear();
                        for(GroupRequest gr : groupRequestList){
                            if(newList.containsKey(gr.gID)){
                                //TODO: both of the .add(dr.userID) will need to do a sorted add where it adds
                                // them in chronological order
                                newList.get(gr.gID).add(gr.userID);
                            }else{
                                List<Integer> idList = new ArrayList<>();
                                idList.add(gr.userID);
                                newList.put(gr.gID, idList);
                            }
                        }
                        System.out.println("Accepted all requests.");
                        break;
                    case "DONE":
                        done = true;
                        break;
                    default:
                        try {
                            int requestNumber = Integer.parseInt(input);
                            if (requestNumber >= 1 && requestNumber <= MAX_NUM) {
                                GroupRequest gr = groupRequestList.get(requestNumber-1);
                                if(newList.containsKey(gr.gID)){
                                    //TODO: both of the .add(dr.userID) will need to do a sorted add where it adds
                                    // them in chronological order
                                    newList.get(gr.gID).add(gr.userID);
                                }else{
                                    List<Integer> idList = new ArrayList<>();
                                    idList.add(gr.userID);
                                    newList.put(gr.gID, idList);
                                }
                                System.out.printf("Added request %d, UserID: %d.\n", requestNumber, gr.getUserID());
                            } else {
                                System.out.printf("Request number must be between 1 and %d.%n", MAX_NUM);
                            }
                        } catch (NumberFormatException e) {
                            System.out.println("Invalid input.");
                        }
                }
            }
            return newList;
        }
        //end code for confirm group member-------------------------------------------------



        //code for leave group -------------------------------------------------
        public static void startLeaveGroup() throws SQLException {
            leaveGroup(getGroupID());
        }
        private static int getGroupID(){
            System.out.print("Enter the GroupID of the group you would like to leave.\nGroupID: ");
            String input = scanner.nextLine().trim();
            try {
                int gID = Integer.parseInt(input);
                return gID;
            } catch (NumberFormatException e) {
                System.out.println("Enter the GroupID of the group you would like to leave.");
            }
            return -1;
        }
        //end code for leave group -------------------------------------------------



        //code for search for profile -------------------------------------------------
        public static void startSearchForProfile() throws SQLException {
            searchForProfile(getSearchString());
        }
        public static String getSearchString() {
            System.out.println("Search for a user by their name or email. Separate your search words with a space.");
            System.out.print("Search: ");
            return scanner.nextLine();
        }
        public static void displayProfiles(List<Profile> matchingProfileList) {
            System.out.println("+----------+--------------------------+");
            System.out.println("| User ID  | Name                     |");
            System.out.println("+----------+--------------------------+");
            for (Profile p : matchingProfileList) {
                int userID = p.getUserID();
                String name = p.getName();
                System.out.printf("| %-8d | %-24s |\n", userID, name);
            }
            System.out.println("+----------+--------------------------+");

            System.out.print("Press enter when you are done viewing the results.");
            scanner.nextLine();
        }
        //end code for search for profile -------------------------------------------------



        //code for send Message To User -------------------------------------------------
        public static void startSendMessageToUser() throws SQLException {
            sendMessageToUser(getRecipUserID());
        }
        private static int getRecipUserID(){
            System.out.print("Enter the UserID of the person you would like send a message to.\nUserID: ");
            String input = scanner.nextLine().trim();
            try {
                int userID = Integer.parseInt(input);
                return userID;
            } catch (NumberFormatException e) {
                System.out.println("Enter the UserID of the person you would like send a message to.");
            }
            return -1;
        }

        public static String sendMessageInput(String name) {
            System.out.printf("You are sending a message to %s. Enter your message below.\n", name);
            System.out.print("Message: ");
            String message = scanner.nextLine();
            System.out.println("\n");
            System.out.printf("Are you sure you want to send this message to %s? (Y/N)\n", name);
            char response = scanner.nextLine().toLowerCase().trim().charAt(0);
            if(response == 'y'){
                return message;
            }else{
                return null;
            }
        }
        //end code for send Message To User -------------------------------------------------



        //code for send Message To Group -------------------------------------------------
        public static void startSendMessageToGroup() {
        }
        //end code for send Message To Group -------------------------------------------------



        //code for Display Messages -------------------------------------------------
        public static void startDisplayMessages() {
        }
        //end code for Display Messages -------------------------------------------------



        //code for Display New Messages -------------------------------------------------
        public static void startDisplayNewMessages() {
        }
        //end code for Display New Messages -------------------------------------------------



        //code for Display Friends -------------------------------------------------
        public static void startDisplayFriends() {
        }
        //end code for Display Friends -------------------------------------------------



        //code for Rank Groups -------------------------------------------------
        public static void startRankGroups() {
        }
        //end code for Rank Groups -------------------------------------------------




        //code for Rank Profiles -------------------------------------------------
        public static void startRankProfiles() {
        }
        //end code for Rank Profiles -------------------------------------------------



        //code for Top Messages -------------------------------------------------
        public static void startTopMessages() {
        }
        //end code for Top Messages -------------------------------------------------




        //code for Three Degrees -------------------------------------------------
        public static void startThreeDegrees() {
        }

        //end code for Three Degrees -------------------------------------------------

    }
}
