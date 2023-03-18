

CS 1555/2055 – Database Management Systems (Spring 2023)

Dept. of Computer Science, University of Pittsburgh

Project: BeSocial

Release Date: Mar. 18, 2023

Phase 1 Due: 8:00 PM, Apr. 5, 2023

Phase 2 Due: 8:00 PM, Apr. 19, 2023

Team Formation Due: 8:00 PM, Mar. 3, 2023

Project Demos: Apr. 27 & 28, 2023

Purpose of the project

The primary goal of this project is to implement a single Java application program that will

operate BeSocial, a Social Networking System for the University of Pittsburgh. The core of such

a system is a database system. The secondary goal is to learn how to work as a member of a team

which designs and develops a relatively large, real database application.

You must implement your application program using Java, PostgreSQL, and JDBC. The assign-

ment focuses on the database component and not on the user interface (UI). Hence, NO HTML or

other graphical user interface is required for this project and carry no bonus points.

It is expected that all members of a team will be involved in all aspects of the project devel-

opment and contribute equally. Division of labor to data engineering (db component) and software

engineering (java component) is not acceptable since each member of the team will be evaluated on

both components.

Phase 1: The BeSocial database schema and example data

Due: 8:00 PM, Apr. 5, 2023

Your BeSocial database includes the standard basic information found in a social networking

system such as user proﬁles, friends, etc. It will have the following relations. You are required to

deﬁne all of the structural and semantic integrity constraints and their modes of evaluation. For

both structural and semantic integrity constraints, you must state your assumptions as comments in

your database creation script. Any semantic integrity constraints involving multiple relations should

be speciﬁed using triggers in this phase Yo u should not change table and attribute names.

• user (userID, name, email, password, date of birth, lastlogin)

Stores the user and login information for each user registered in the system.

Datatype

userID: integer

name: varchar(50)

email: varchar(50)

password: varchar(50)

date of birth: date

lastlogin: timestamp

• friend (userID1, userID2, JDate, requestText)

Stores the friends lists for every user in the system. The JDate is when they became friends,

and the requestText is the text from the original friend request.

1





Datatype

userID1: integer

userID1: integer

JDate: date

requestText: varchar(200)

• pendingFriend (fromID, toID, requestText)

Stores pending friends requests that have yet to be conﬁrmed by the recipient of the request.

Datatype

fromID: integer

toID: integer

requestText: varchar(200)

• groupInfo (gID, name, size, description)

Stores information for each group in the system.

Datatype

gID: integer

name: varchar(50)

size: integer

description: varchar(200)

• groupMember (gID, userID, role, lastConﬁrmed)

Stores the users who are members of each group in the system. The “role” indicates whether

a user is a manager of a group (who can accept joining group requests) or a member.

The lastConﬁrmed attribute stores when the group member was successfully added to the

group.

Datatype

gID: integer

userID: integer

role: varchar(20)

lastConﬁrmed: timestamp

• pendingGroupMember (gID, userID, requestText, requestTime)

Stores pending joining group requests that have yet to be accepted/rejected by the manager of

the group. The requestTime is the time when the user requested group membership.

Datatype

gID: integer

userID: integer

requestText: varchar(200)

requestTime: timestamp

• message (msgID, fromID, messageBody, toUserID, toGroupID, timeSent)

Stores every message sent by users in the system. Note that the default values of toUserID

and toGroupID should be NULL.

2





Datatype

msgID: integer

fromID: integer

messageBody: varchar(200)

toUserID: integer

toGroupID: integer

timeSent: timestamp

• messageRecipient (msgID, userID)

Stores the recipients of each message stored in the system.

Datatype

msgID: integer

userID: integer

To facilitate time travel, you are expected to implement a Clock. You must maintain a “pseudo”

timestamp (not the real system timestamp) in the auxilliary table Clock. The reason for making such

a timestamp and not using the system one is to make it easy to generate scenarios (time traveling)

to debug and test your project. Clock has only one tuple, inserted as part of initialization and

is updated during time traveling. That is, all functions on the Clock relation will be done on the

database side and not through JDBC. The schema of this relation is the following.

• CLOCK ( pseudo time )

PK (pseudo time)

Datatype: pseudo time: timestamp

Recall that triggers can be used to make your code more eﬃcient besides enforcing integrity

constraints. In this ﬁrst phase, you are expected to write and submit at least two triggers.

Some examples of triggers as discussed in Phase 2 could be:

• addMessageRecipient which adds a corresponding entry into the messageRecipient relation

upon adding a new message to the message relation

• updateGroup which moves a pending accepted request in the pendingGroupMember relation to

the groupMember relation when a member leaves the group.

Once you have created a schema and integrity constraints for storing all of this information, you

should generate sample data to insert into your tables. Generate the data to represent at least 100

users, 200 friendships, 10 groups, and 300 messages.

Phase 2: A JDBC application to manage BeSocial

Due: 8:00 PM, Apr. 19, 2023

The objective of this phase of the project is to familiarize yourself with all the powerful features

of SQL/PL, which include functions, procedures, and triggers. All tasks can be implemented in

database approaches using triggers, stored procedures and functions. You will lose points if you

implement them using Java approaches.

Attention must be paid in deﬁning transactions appropriately. Speciﬁcally, you need to design

the SQL transactions appropriately and when necessary, use the concurrency control mechanism

3





supported by PostgreSQL (e.g., isolation level, locking models) to make sure that inconsistent states

will not occur. Assume that multiple requests for changes of BeSocial can be made on behalf of

multiple diﬀerent users concurrently. For example, it could happen when a group manager A is

trying to add a new group member B while another group manager C is trying to add a new group

member D at the same time (i.e., concurrently).

The application should implement a system of interfaces (non-graphical) that will allow users to

connect to the database and perform predeﬁned functions accomplishing a task. A good design may

be a two level menu such that the higher level menu provides options for createUser, DropUser, login,

and exit. If a user successfully logged in, then the lower level menu is shown to provide options to do

the remaining functions. You are expected to use Java interfacing PostgreSQL server using JDBC.

For all tasks, you are expected to check for and properly react to any errors reported by the

DBMS (PostgreSQL), and provide appropriate success or failure feedback to the user. For example,

functions could return 1 if the operation succeeded or -1 if the operation is not possible or failed.

Further be sure that your application carefully checks the input data from the user and avoids SQL

injection.

Your application should implement the following functions for managing BeSocial. You can th

1\. createUser

Given a name, email address, password and date of birth, add a new user to the system by

inserting a new entry into the user relation. userIDs should be auto-generated.

2\. dropUser

This functions prompts for a user email and removes the user along with all of their information

from the system. When a user is removed, the system should use a trigger to delete the user

from the groups they are a member of. The system should also use a trigger to delete any

message whose sender and all receivers are deleted. Attention should be paid to handling

integrity constraints.

3\. login

Given email and password, login as the user in the system when an appropriate match is found.

4\. initiateFriendship

Create a pending friendship from the logged-in user to another user based on userID. The

application should display the name of the person that will be sent a friend request and the

user should be prompted to enter the text to be sent along with the request. A last conﬁrmation

should be requested of the user before an entry is inserted into the pendingFriend relation, and

success or failure feedback is displayed for the user.

5\. conﬁrmFriendRequests

This task should ﬁrst display a formatted, numbered list of all the outstanding friend requests

with the associated request text. Then the user should be prompted for a number of the request

they would like to conﬁrm, one at a time, or given the option to conﬁrm them all.

The application should move the selected request(s) from the pendingFriend relation to the

friend relation with JDate set to the current date of the Clock table.

The remaining requests which were not selected are declined and removed from the pend-

ingFriend relation.

In the event that the user has no pending friend requests, a message “No Pending Friend

Requests” should be displayed to the user.

4





6\. createGroup

Given a name, description, and membership limit (i.e., size), add a new group to the system,

add the current user as its ﬁrst member with the role manager. gIDs should be auto-generated.

7\. initiateAddingGroup

Given a group ID and the request’s text, create a pending request of adding the logged-in user

to the group by inserting a new entry into the pendingGroupMember relation.

8\. conﬁrmGroupMembership

This task should ﬁrst display a formatted, numbered list of all the pending group membership

requests with the associated request text for any groups where the user is a group manager.

Then, the user should be prompted for a number of the request they would like to conﬁrm, one

at a time, or given the option to conﬁrm them all.

The application should move the selected request(s) from the pendingGroupMember relation

to the groupMember relation using the current time in Clock for the lastConﬁrmed timestamp.

If accepting a pending group membership request would exceed the group’s size, the accepted

request should remain in pendingGroupMember.

The remaining requests which were not selected are declined and removed from the pending-

GroupMember relation.

In the event that there are no pending group membership requests for any groups that the user

is a manager of, a message “No Pending Group Membership Requests” should be displayed to

the user. Furthermore, a message “No groups are currently managed” should be displayed if

the user is not a manager of any groups.

9\. leaveGroup

This task should ﬁrst prompt the user for the gID of the group they would like to leave.

The application should remove the user from the group in the groupMember relation. Upon

removing the user from the group, you should use a trigger to check if there are pending

group membership requests in pendingGroupMember that were previously accepted, but could

not be added due exceeding the group’s size, and move the earliest such request from the pend-

ingGroupMember relation to the groupMember relation without changing the lastConﬁrmed

timestamp.

In the event that the user is not a member of the speciﬁed group, a message “Not a Member

of any Groups” should be displayed to the user.

10\. searchForUser

Given a string on which to match any user in the system, any item in this string must be

matched against the “name” and “email” ﬁelds of a user’s proﬁle. That is if the user searches

for “xyz abc”, the results should be the set of all users that have “xyz” in their “name” or

“email” union the set of all users that have “abc” in their “name” or “email”.

11\. sendMessageToUser

With this the user can send a message to one friend given the friend’s userID. The application

should display the name of the recipient and the user should be prompted to enter the body

of the message, which could be multi-lined. Once entered, the application should “send” the

message to the receiving user by adding an appropriate entry into the message relation (msgIDs

should be auto-generated and timeSent should be set to the current time of the Clock table)

and use a trigger to add a corresponding entry into the messageRecipient relation. The user

should lastly be shown success or failure feedback.

5





12\. sendMessageToGroup

With this the user can send a message to a recipient group given the group ID, if the user is

within the group. Every member of this group should receive the message. The user should be

prompted to enter the body of the message, which could be multi-lined. Then the application

should “send” the message to the group by adding an appropriate entry into the message

relation (msgIDs should be auto-generated and timeSent should be set to the current time of

the Clock table) and use a trigger to add corresponding entries into the messageRecipient

relation. The user should lastly be shown success or failure feedback.

Note that if the user sends a message to one friend, you only need to put the friend’s userID

to ToUserID in the table of message. If the user wants to send a message to a group, you need

to put the group ID to ToGroupID in the table of message and use a trigger to populate

the messageRecipient table with proper user ID information as deﬁned by the groupMember

relation.

13\. displayMessages

When the user selects this option, the entire contents of every message sent to the user (in-

cluding group messages) should be displayed in a nicely formatted way.

14\. displayNewMessages

This should display messages in the same fashion as the previous task except that only those

messages sent since the last time the user logged into the system should be displayed (including

group messages).

15\. displayFriends

This task supports the browsing of the logged-in user’s friends’ proﬁles. It ﬁrst displays each

of the user’s friends’ names and userIDs. Then it allows the user to either retrieve a friend’s

entire proﬁle by entering the appropriate userID or exit browsing and return to the main menu

by entering 0 as a userID. When selected, a friend’s proﬁle should be displayed in a nicely

formatted way, after which the user should be prompted to either select to retrieve another

friend’s proﬁle or return to the main menu.

16\. rankGroups

This task should produce a ranked list of groups based on their number of members.

In the event that there are no groups in the system, a message “No Groups to Rank” should

be displayed to the user.

17\. rankUsers

This task should produce a ranked list of users based on the number of friends they have along

with their number of friends.

Note the number of friends of a user includes those who are members of the groups user belongs

to.

18\. topMessages

Display the top k users with respect to the number of messages sent to the logged-in user plus

the number of messages received from the logged-in user in the past x months. x and k are

input parameters to this function. 1 month is deﬁned as 30 days counting back starting from

the current date of the Clock table. Group messages do not need to be considered in this

function.

6





19\. threeDegrees

Given a userID, ﬁnd a path, if one exists, between the logged-in user and that user with at

most 3 hops between them. A hop is deﬁned as a friendship between any two users.

This query should be written using plpgsql and should only use java for interfacing.

20\. logout

The function should return the user to the top level of the UI after marking the time of the

user’s logout in the user’s “lastlogin” ﬁeld of the user relation from the Clock table.

21\. exit

This option should cleanly shut down and exit the program.

In addition to the main program BeSocial.java that should contain all functions and UI, you are

expected to create a Java test driver program to demonstrate the correctness of your social network

backend. The driver program needs to call all of the above functions and display the content of the

aﬀected rows of the aﬀected tables after each call. If a function does not modify the database, then

showing the output/display of the function is enough. It may prove quite handy to write this driver

as you develop the functions as a way to test them. If you created a Java program to generate the

sample data inserts in Phase 1, you may also wish to reuse that program to dynamically generate a

large number of function calls within your driver.

Note that Driver.java is only used to test the functions without any manual user inputs. If

your functions in BeSocial.java involve manual user inputs, then you may create helper functions

in BeSocial.java that take in valid input arguments and interact with the DBMS directly without

involving manual user inputs, so that your functions in BeSocial.java can call those helper functions

and Driver.java can also call those helper functions for testing purposes.

Project Submission

Phase 1 The ﬁrst phase should contain SQL components for the SQL DDL, triggers, and INSERT

statements of the project. In addition you may submit any SQL queries for which you wish to receive

feedback. Speciﬁcally,

• schema.sql

the script to create the database schema with integrity constraints.

the script containing deﬁnitions of the triggers.

• trigger.sql

• sample-data.sql

the script containing all insert statements.

• optional-queries.sql the script containing your additional SQL queries.

Note that after the ﬁrst phase submission, you should continue working on your project without

waiting for our feedback. Furthermore, you should feel free to correct and enhance your SQL part

with new views, functions, procedures etc.

Phase 2 The second phase should contain, in addition to the SQL part, the Java code. Speciﬁcally,

• schema2.sql

• trigger2.sql

• BeSocial.java

the script to create the enhanced database schema with integrity

constraint evaluation modes.

the script containing deﬁnitions of the triggers, and any stored

procedures or functions that you designed

the ﬁle containing your main class and all the functions

7





• Driver.java

• README

the driver ﬁle to show correctness of your functions

a README ﬁle that elaborates (fully) on how to use your

BeSocial client application and driver program.

The project will be collected by submitting your GitHub repository to Gradescope. Therefore,

at the beginning of the project, you need to do two things:

1\. Create one common private GitHub repository as a team, where all team members are con-

tributing and use it to develop the project.

2\. Give full permission of the project repository to your TAs (GitHub ID: ralseghayer, GitHub

ID: anushrihv, GitHub ID: nixonb91).

To turn in your code, you must do three things by each deadline:

1\. Make a commit to your project repository that represents what should be graded as your group’s

submission for that phase. The message for this commit should be “Phase X submission” where

X is 1,2 or 3.

2\. Push that commit to the GitHub repository that you have shared with the TAs

3\. Submit your GitHub repository (including all necessary SQL ﬁles) to Gradescope under the

Project Phase X assignment link, where X is 1, 2, or 3.

To submit to Gradescope, you will need to:

• Select the appropriate assignment submission link (as you’ve previously done with home-

work assignments).

• On the “Submit Programming Assignment” window that appears, choose “GitHub.” If

this is your ﬁrst time submitting to Gradescope via GitHub, you will be prompted to link

your GitHub account and authenticate.

• Select your team’s GitHub repository in the dropdown (searching will ﬁlter the repositories

listed).

• Select the branch of your GitHub repository with the code your team wishes to submit

(typically just the main branch). Then click the green upload button in the bottom left

of the window.

• After uploading your team’s submission, you will be taken to the submission results page.

The next step is to add each team member to the assignment to allow for a single linked

submission. Note: There should only be one submission per team, i.e., every

team member does not need to submit.

• To link team members, click “Add Group Member” in the top right corner of this page.

• On the new window, add all of your corresponding team members to the group, then hit

the green “Save” button in the bottom left of this window.

• If done correctly, every team member should receive a conﬁrmation email from Grade-

scope.

Multiple submissions are allowed for each phase for each team. The last submission before the cor-

responding deadline will be graded. NO late submission is allowed.

8





Grading

The project will be graded on correctness (e.g. coping with violation of integrity constraints),

robustness (e.g. coping with failed transactions) and readability. You will not be graded on eﬃcient

code with respect to speed although bad programming will certainly lead to incorrect programs.

Programs that fail to compile or run or connect to the database server earn zero and no partial

points.

Academic Honesty

The work in this assignment is to be done independently by each team. Discussions with other

students or teams on the project should be limited to understanding the statement of the problem.

Cheating in any way, including giving your work to someone else will result in an F for the course

and a report to the appropriate University authority.

Enjoy your class project!

9


