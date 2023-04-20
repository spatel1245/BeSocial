# BeSocial

## Welcome!

### This is BeSocial, a Social Networking System for the University of Pittsburgh! 
 <br> 

 *Created by: Shiv Patel, Andres Trujillo, and Ben Zarom in April 2023*
 <br> <br>

# HOW TO USE BeSocial:

<br>

```
We did all development and testing on
openjdk version "1.8.0_352"
OpenJDK Runtime Environment (Temurin)(build 1.8.0_352-b08)

NOTE: WE HAVE ONLY MACs SO THAT IS WHAT WE TESTED ON

Once you have all the necessary files in the same folder and have a command line open at that folder, you can do the following:
1. Update password in BeSocial.java
       You must open BeSocial.java and update your password in the openConnection() function below main. 
       
2. Compile:
For Mac:
     javac -cp postgresql-42.6.0.jar BeSocial.java Driver.java
For Windows:
     javac -cp "postgresql-42.6.0.jar;." BeSocial.java Driver.java
     
3. Run SQL Files
     run schema2.sql
     run trigger2.sql
     * This will ensure the system is empty before starting... ESSENTIAL for driver*
     
4. Run:
For Mac:      
      java -cp postgresql-42.6.0.jar:. Driver
      or
      java -cp postgresql-42.6.0.jar:. BeSocial

For Windows:
      java -cp "postgresql-42.6.0.jar;." Driver
      or
      java -cp "postgresql-42.6.0.jar;." BeSocial
      
      Select whichever is appropriate for your system. Driver is the auto-test file and BeSocial is manual interaction.
```

## Before you log in:
 
<details>
<br>

**Here's what you can do** *before* **you log into BeSocial:**
<br>

 In the menu, you see 4 options. Here is each feature and how to use them:
 <br>
 

**1. Create Profile**
```
Enter ‘1’ to create a profile (ONLY A LOGGED IN ADMIN CAN DO THIS)
```

**2. Drop Profile**
```
Enter ‘2’ to REMOVE a profile (ONLY A LOGGED IN ADMIN CAN DO THIS)
```


**3. Login**
```
Enter ‘3’ to Login to an account
Enter user email
Enter user password
```


**4. Exit**
```
Enter ‘4’ to exit the system and close the app
```

</details>
<br>


<br>

## After Logging in: 

 <details>

 **Here's what you can do**  *after*  **you log into BeSocial:**
<br>

 In the menu, you see 20 options. Here is each feature and how to use them:


**1. Create Profile**
```
Enter ‘1’ to CREATE a profile (ONLY A LOGGED IN ADMIN CAN DO THIS).
```


**2. Drop Profile**
```

Enter ‘2’ to DELETE a profile (ONLY A LOGGED IN ADMIN CAN DO THIS)
```


**3. Initiate Friendship**
```
Enter '3' to ADD A FRIEND.
```


**4. Confirm Friend Request(s)**
```
Enter '4' to view your pending friend request(s), and accept/deny one/all Friend Request(s).
```


**5. Create Group**
```
Enter '5' to Create a Group.
```

**6. Initiate Adding Group**
```
Enter '6' to Create a request to join a group.

```


**7. Confirm Group Membership**
```
Enter '7' to accept requests to join your group (LOGGED IN USER MUST BE THE MANAGER OF A GROUP).
```

**8. Leave Group**
```
Enter '8' to leave a group you are apart of.
```

**9. Search for Profile**
```
Enter '9' to search for other users. Then type in a prefix of their name and/or email.
```

**10. Send Message to User**
```
Enter '10' to send a message to another user.
```


**11. Send Message to Group**
```
Enter '11' to send a message to a group you are apart of. This will be sent to all members of the group.
```

**12. Display Messages**
```
Enter '12' to display all the messages you have received.
```


**13. Display New Messages**
```
Enter '13' to display all the NEW messages you have received. That is, the messages you have received since last logging in.
```


**14. Display Friends**
```
Enter '14' to display all your friends.
```

**15. Rank Groups**
```
Enter '15' to display a ranked list of all the groups on BeSocial in order of how many members they have. 
```

**16. Rank Profiles**
```
Enter '16' to display a ranked list of all the profiles on BeSocial in order of how many friends they have, counting those who are in the same groups as them as friends. 
```

**17. Top Messages**
```
Enter '17' to display a ranked list of k profiles on BeSocial in order of how many messages they have received within x months.
```

**18. Three Degrees**
```
Enter '18' to display the path/connection between you and a user that has at most 3 hops. In other words, the last number displayed in the path is a friend of a friend of a friend.
```

**19. Logout**
```
Enter '19' to logout.
```


**20. Exit**
```
Enter '20' to exit the system and close the app.
```

</details>
<br>



-----------------
<br>

# BeSocial Client Application (Technical information)



## Contains:
 ### Main Class.
 ### Main Method.
 ### All Required Methods. 
 ### Dashboard Class.
 ### Helper Classes for storing tuples in SQL. 

-----------------

### Initialization: BeSocial is initialized by setting the URL, user, and password as finals to the corresponding user and server. As well as temproarily sets the current user to null. 

### Main Function 

        The Main function consists of a while loop and switch statements that enable the user to select options indefinitely until they exit the program. 
        
----------

### Dashboard Methods
 <details>

        Dashboard class provides a variety of helper methods that correspond to the backEnd methods. Dashboard methods check if method has run succesfully, if it has it returns the information requested, if not it cleanly denies the user from doing the method. If Succesful, these messages print to the terminal in an organized, user-friendly, layout. 

        Dashboard Class Methods Include:

            1. startCreateProfile
            2. getProfileDetails 
            3. startDropProfile
            4. getEmail
            5. startLogin
            6. getLoginDetails
            7. startInitiateFriendship
            8. getUserID
            9.initiateFriendshipMessage
            10. startConfirmFriendRequest
            11. displayFriendRequests
            12. getFriendsToAdd
            13. startCreateGroup
            14. getGroupDetails
            15. startInitiateAddingGroup
            16. getGroupReqDetails
            17. startConfirmGroupMembership
            18. displayGroupRequests
            19. getGroupRequestsToAdd
            20. startLeaveGroup
            21. getGroupID
            22. startSearchForProfile
            23. getSearchString
            24. displayProfiles
            25. startSendMessageToUser()
            26. getRecipUserID
            27. sendMessageInput
            28. startSendMessageToGroup
            29. getRecipGroupID
            30. startDisplayMessages
            31. displayMSGsToUser
            32. splitMessage
            33. displayUsersFriends
            34. startDisplayNewMessages
            35. startDisplayFriends
            36. displayUsersFriends
            37. viewFriendsOrExit
            38. viewFriendProfile
            39. startRankGroups
            40. displayListOfGroups
            41. startRankProfiles
            42. displayListOfProfiles
            43. getInputTopMessages
            44. startThreeDegrees
            45. getSearchForId

</details>

### BackEnd methods

<details>
        Backend methods are static methods that belong to the BeSocial class. Specified in the project descriptions they include : 

------------------------------------------------------------------------------------
        
1. createUser:
<details>
        Given a name, email address, password and date of birth, add a new user to the system by
        inserting a new entry into theuserrelation. userIDs should be auto-generated.
        Enter ‘1’ to create a profile (ONLY A LOGGED IN ADMIN CAN DO THIS)
</details>

------------------------------------------------------------------------------------

2. dropUser:

<details>

        This functions prompts for a user email and removes the user along with all of their information from the system. When a user is removed, the system shoulduse a triggerto delete the user from the groups they are a member of. The system should alsouse a triggerto delete any message whose sender and all receivers are deleted. Attention should be paid to handling integrity constraints.
</details>

------------------------------------------------------------------------------------

3. Login:

<details>
Given email and password, login as the user in the system when an appropriate match is found.

Enter ‘3’ to Login to an account
Enter user email
Enter user password

 </details>    

------------------------------------------------------------------------------------

4. initiateFriendship

<details>
Create a pending friendship from the logged-in user to another user based on userID. The application should display the name of the person that will be sent a friend request and the
user should be prompted to enter the text to be sent along with the request. A last confirmation
should be requested of the user before an entry is inserted into thependingFriendrelation, and
success or failure feedback is displayed for the user.
 </details>

------------------------------------------------------------------------------------

5. confirmFriendRequests
<details>
This task should first display a formatted, numbered list of all the outstanding friend requests
with the associated request text. Then the user should be prompted for a number of the request
they would like to confirm,one at a time, or given the option to confirm them all.
The application should move the selected request(s) from thependingFriend relation to the
friendrelation with JDate set to the current date of theClocktable.
The remaining requests which were not selected are declined and removed from the pend-
ingFriend relation.
In the event that the user has no pending friend requests, a message “No Pending Friend
Requests” should be displayed to the user.
</details>

----------

6. createGroup

<details>
Given a name, description, and membership limit (i.e., size), add a new group to the system,
add the current user as its first member with the role manager. gIDs should be auto-generated.
</details>


--------

7. initiateAddingGroup

<details>
Given a group ID and the request’s text, create a pending request of adding the logged-in user
to the group by inserting a new entry into thependingGroupMemberrelation.
</details>

----------------

8. confirmGroupMembership
<details>
This task should first display a formatted, numbered list of all the pending group membership
requests with the associated request text for any groups where the user is a group manager.
Then, the user should be prompted for a number of the request they would like to confirm,one
at a time, or given the option to confirm them all.
The application should move the selected request(s) from thependingGroupMemberrelation
to thegroupMemberrelation using the current time inClockfor the lastConfirmed timestamp.
If accepting a pending group membership request would exceed the group’s size, the accepted
request should remain inpendingGroupMember.
The remaining requests which were not selected are declined and removed from thepending-
GroupMember relation.
In the event that there are no pending group membership requests for any groups that the user
is a manager of, a message “No Pending Group Membership Requests” should be displayed to
the user. Furthermore, a message “No groups are currently managed” should be displayed if
the user is not a manager of any groups.
</details>

------

9. leaveGroup
<details>
This task should first prompt the user for thegIDof the group they would like to leave.
The application should remove the user from the group in thegroupMemberrelation. Upon
removing the user from the group, you shoulduse a triggerto check if there are pending
group membership requests inpendingGroupMemberthat were previously accepted, but could
not be added due exceeding the group’s size, and move the earliest such request from thepend-
ingGroupMember relation to thegroupMember relation without changing the lastConfirmed
timestamp.
In the event that the user is not a member of the specified group, a message “Not a Member
of any Groups” should be displayed to the user.
</details>


---------

10. searchForUser

<details>
Given a string on which to match any user in the system, any item in this string must be
matched against the “name” and “email” fields of a user’s profile. That is if the user searches
for “xyz abc”, the results should be the set of all users that have “xyz” in their “name” or
“email” union the set of all users that have “abc” in their “name” or “email”.
</details>


------------------------------------------------------------------------------------

11. sendMessageToUser
<details>
With this the user can send a message to one friend given the friend’s userID. The application
should display the name of the recipient and the user should be prompted to enter the body
of the message, which could be multi-lined. Once entered, the application should “send” the
message to the receiving user by adding an appropriate entry into themessagerelation (msgIDs
should be auto-generated and timeSent should be set to the current time of theClocktable)
anduse a triggerto add a corresponding entry into themessageRecipientrelation. The user
should lastly be shown success or failure feedback.
</details>



------------------------------------------------------------------------------------

12. sendMessageToGroup
<details>
With this the user can send a message to a recipient group given the group ID, if the user is
within the group. Every member of this group should receive the message. The user should be
prompted to enter the body of the message, which could be multi-lined. Then the application
should “send” the message to the group by adding an appropriate entry into the message
relation (msgIDs should be auto-generated and timeSent should be set to the current time of
theClocktable) anduse a triggerto add corresponding entries into themessageRecipient
relation. The user should lastly be shown success or failure feedback.
Note that if the user sends a message to one friend, you only need to put the friend’s userID
to ToUserID in the table ofmessage. If the user wants to send a message to a group, you need
to put the group ID to ToGroupID in the table ofmessageanduse a triggerto populate
themessageRecipient table with proper user ID information as defined by thegroupMember
relation.
</details>



------------------------------------------------------------------------------------

13. displayMessages
<details>
When the user selects this option, the entire contents of every message sent to the user (in-
cluding group messages) should be displayed in a nicely formatted way.
</details>


------------------------------------------------------------------------------------

14. displayNewMessages
<details>
This should display messages in the same fashion as the previous task except that only those
messages sent since the last time the user logged into the system should be displayed (including
group messages).
</details>



------------------------------------------------------------------------------------

15. displayFriends

<details>
This task supports the browsing of the logged-in user’s friends’ profiles. It first displays each
of the user’s friends’ names and userIDs. Then it allows the user to either retrieve a friend’s
entire profile by entering the appropriate userID or exit browsing and return to the main menu
by entering 0 as a userID. When selected, a friend’s profile should be displayed in a nicely
formatted way, after which the user should be prompted to either select to retrieve another
friend’s profile or return to the main menu.
</details>

------------------------------------------------------------------------------------


16. rankGroups
<details>
This task should produce a ranked list of groups based on their number of members.
In the event that there are no groups in the system, a message “No Groups to Rank” should
be displayed to the user.
</details>





------------------------------------------------------------------------------------

17. rankUsers
<details>
This task should produce a ranked list of users based on the number of friends they have along
with their number of friends.
Note the number of friends of a user includes those who are members of the groups user belongs
to.
</details>

------------------------------------------------------------------------------------

18. topMessages
<details>
Display the top k users with respect to the number of messages sent to the logged-in user plus
the number of messages received from the logged-in user in the past x months. x and k are
input parameters to this function. 1 month is defined as 30 days counting back starting from
the current date of the Clocktable. Group messages do not need to be considered in this
function.
</details>

------------------------------------------------------------------------------------

19. threeDegrees
<details>
Given a userID, find a path, if one exists, between the logged-in user and that user with at
most 3 hops between them. A hop is defined as a friendship between any two users.
This query should be written using plpgsql and should only use java for interfacing.
</details>

------------------------------------------------------------------------------------

20. logout
<details>
The function should return the user to the top level of the UI after marking the time of the
user’s logout in the user’s “lastlogin” field of theuserrelation from theClocktable.
</details>

------------------------------------------------------------------------------------


21. exit
<details>
This option should cleanly shut down and exit the program.

</details>

------------------------------------------------------------------------------------  

       
  

</details>




------------------------------------------------------------------------------------  
<br><br>


# BeSocial Driver 

### Driver file runs through BeSocial Application Client demonstrating its wide variety of functionality with sample data, running it all automatically. 

<details>
 
<br>
 
 **BEFORE YOU RUN THE Driver.java file:** Run the Schema.sql and Trigger.sql files before running the Driver file.
 
<br>

## Expected Output
<details>


</details>
<br>
