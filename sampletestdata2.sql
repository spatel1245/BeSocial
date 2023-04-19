INSERT INTO profile VALUES (1, 'Lisa Robinson', 'kingkimberly@example.com', '_9QwOuHC', '1998-09-09', '2022-06-16T16:51:28');
INSERT INTO profile VALUES (2, 'Jessica Savage', 'stephen69@example.org', 'T#wv4ZPs', '1983-02-23', '2022-09-22T11:32:03');
INSERT INTO profile VALUES (3, 'Jack Moore MD', 'emeza@example.org', '^4H@6usa', '1962-06-04', '2022-06-15T22:44:41');
INSERT INTO profile VALUES (4, 'Ryan Vargas', 'cbarrett@example.net', 'I%7VHugz', '1959-05-06', '2022-09-15T11:37:42');
INSERT INTO profile VALUES (5, 'Kevin Horn', 'xmosley@example.net', 'Z$1ZV@$q', '1963-03-15', '2022-09-11T03:00:03');
INSERT INTO profile VALUES (6, 'Carrie Shaw', 'jodijohns@example.com', '!p5BtmJr', '1926-11-03', '2022-12-19T00:10:32');
INSERT INTO profile VALUES (7, 'Michael Pittman', 'butlerjennifer@example.org', '(!3E8war', '2007-06-08', '2022-08-29T05:35:51');
INSERT INTO profile VALUES (8, 'Felicia Ewing', 'megan43@example.net', ')I6FbWG4', '1978-09-16', '2022-06-26T00:26:20');
INSERT INTO profile VALUES (9, 'Ryan Wood', 'christophergomez@example.org', '^1l0$Wzu', '1989-01-21', '2022-11-27T23:34:42');
INSERT INTO profile VALUES (10, 'Rodney Brooks', 'maureen09@example.com', '+e2VYqO%', '1929-01-05', '2022-07-09T07:10:37');


INSERT INTO groupInfo VALUES (1, 'treat', 9, 'Democrat push true resource.');
INSERT INTO groupInfo VALUES (2, 'top', 9, 'Important low no if institution account.');
INSERT INTO groupInfo VALUES (3, 'yeah', 5, 'Type soon yard whom important sport such.');
INSERT INTO groupInfo VALUES (4, 'job', 1, 'One home society impact road friend.');
INSERT INTO groupInfo VALUES (5, 'add', 14, 'Help instead system write from.');
INSERT INTO groupInfo VALUES (6, 'myself', 25, 'Off court professor deal.');
INSERT INTO groupInfo VALUES (7, 'little', 24, 'Tv force charge owner imagine.');
INSERT INTO groupInfo VALUES (8, 'senior', 29, 'Seat public three treat central including.');
INSERT INTO groupInfo VALUES (9, 'bed', 7, 'Democrat also lead cultural energy drug late.');
INSERT INTO groupInfo VALUES (10, 'year', 16, 'Mind notice firm factor authority million agent boy.');
INSERT INTO groupMember VALUES (5, 1, 'member', '2023-01-21T15:17:48');
INSERT INTO groupMember VALUES (9, 1, 'member', '2022-10-09T03:14:32');
INSERT INTO groupMember VALUES (1, 2, 'manager', '2022-07-29T14:56:49');
INSERT INTO groupMember VALUES (6, 3, 'manager', '2023-02-18T18:11:33');
INSERT INTO groupMember VALUES (7, 4, 'manager', '2023-03-07T07:04:20');
INSERT INTO groupMember VALUES (4, 5, 'member', '2022-11-08T22:25:03');
INSERT INTO groupMember VALUES (8, 6, 'member', '2023-02-19T17:12:14');
INSERT INTO groupMember VALUES (2, 7, 'member', '2022-10-25T22:36:30');
INSERT INTO groupMember VALUES (1, 8, 'member', '2023-03-28T12:35:25');
INSERT INTO groupMember VALUES (2, 9, 'member', '2022-10-09T07:49:08');
INSERT INTO message VALUES (1, 1, 'Analysis although hit yard.', null, 1, '2022-04-20T09:23:35');

INSERT INTO message VALUES (2, 4, 'Decision effect main last.', 1, null,'2022-11-22T14:26:59');
INSERT INTO message VALUES (3, 5, 'They table cup another.', 1, null,'2023-03-04T19:53:25');

INSERT INTO groupMember VALUES (3, 1, 'member', '2022-10-09T03:14:32');
INSERT INTO groupMember VALUES (4, 1, 'member', now());
INSERT INTO groupMember VALUES (4, 3, 'member', now());


delete from profile where userid =1;
--delete from profile where userid =3;

--3: 5, 4: 1, 7:24