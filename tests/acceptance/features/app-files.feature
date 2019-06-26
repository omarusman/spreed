Feature: app-files

  Scenario: open chat tab in a file not shared
    Given I am logged in as the admin
    When I open the details view for "welcome.txt"
    And I open the Chat tab in the details view of the Files app
    Then I see that the "Start a conversation Share this file with others to discuss Share" empty content message is shown in the chat tab

  Scenario: open chat tab in a file again after sharing it with a user
    Given I am logged in as the admin
    And I open the details view for "welcome.txt"
    And I open the Chat tab in the details view of the Files app
    And I see that the "Start a conversation Share this file with others to discuss Share" empty content message is shown in the chat tab
    When I share "welcome.txt" with "user0"
    And I see that the file is shared with "user0"
    And I open the Chat tab in the details view of the Files app
    Then I see that the chat is shown in the Chat tab

  Scenario: open chat tab in a received shared file
    Given I act as John
    And I am logged in as the admin
    And I act as Jane
    And I am logged in
    And I act as John
    And I share "welcome.txt" with "user0"
    And I see that the file is shared with "user0"
    When I act as Jane
    # The Files app is open again to reload the file list
    And I open the Files app
    And I open the details view for "welcome (2).txt"
    And I open the Chat tab in the details view of the Files app
    Then I see that the chat is shown in the Chat tab

  Scenario: open chat tab in a file shared by link
    Given I am logged in as the admin
    When I share the link for "welcome.txt"
    # The shared link is not used for anything, but this ensures that the link
    # share is ready before continuing.
    And I write down the shared link
    And I open the Chat tab in the details view of the Files app
    Then I see that the "Start a conversation Share this file with others to discuss Share" empty content message is shown in the chat tab

  Scenario: chat tab header is not shown in a folder even if shared
    Given I am logged in as the admin
    # Open the details view for a file, which has the "Chat" tab header, to
    # ensure that opening the details view for a folder actually hides the
    # header.
    And I open the details view for "welcome.txt"
    And I see that the details view is open
    When I create a new folder named "Folder"
    Then I see that the Chat tab header is not shown in the details view
    And I share "Folder" with "user0"
    And I see that the file is shared with "user0"
    # Close and open the details view again to trigger an update of the tab
    # headers.
    And I close the details view
    And I open the details view for "Folder"
    And I see that the Chat tab header is not shown in the details view



  Scenario: open Talk after joining a file room
    Given I am logged in as the admin
    And I share "welcome.txt" with "user0"
    And I see that the file is shared with "user0"
    And I open the Chat tab in the details view of the Files app
    And I see that the chat is shown in the Chat tab
    When I have opened the Talk app
    Then I see that the "welcome.txt" conversation is shown in the list

  Scenario: joining again a file room after leaving it from Talk
    Given I am logged in as the admin
    And I share "welcome.txt" with "user0"
    And I see that the file is shared with "user0"
    And I open the Chat tab in the details view of the Files app
    And I see that the chat is shown in the Chat tab
    And I have opened the Talk app
    And I leave the "welcome.txt" conversation
    And I see that the "welcome.txt" conversation is not shown in the list
    When I open the Files app
    And I open the details view for "welcome.txt"
    And I open the Chat tab in the details view of the Files app
    Then I see that the chat is shown in the Chat tab



  Scenario: chat in a shared file
    Given I act as John
    And I am logged in as the admin
    And I act as Jane
    And I am logged in
    And I act as John
    And I share "welcome.txt" with "user0"
    And I see that the file is shared with "user0"
    And I open the Chat tab in the details view of the Files app
    And I act as Jane
    # The Files app is open again to reload the file list
    And I open the Files app
    And I open the details view for "welcome (2).txt"
    And I open the Chat tab in the details view of the Files app
    When I act as John
    And I send a new chat message with the text "Hello"
    And I act as Jane
    And I see that the message 1 was sent by "admin" with the text "Hello"
    And I send a new chat message with the text "Hi!"
    Then I see that the message 1 was sent by "admin" with the text "Hello"
    And I see that the message 2 was sent by "user0" with the text "Hi!"
    And I act as John
    And I see that the message 1 was sent by "admin" with the text "Hello"
    And I see that the message 2 was sent by "user0" with the text "Hi!"

#  Scenario: chat in a reshared file
#    Given I act as John
#    And I am logged in as the admin
#    And I act as Jane
#    And I am logged in
#    And I act as Jim
#    And I am logged in as "user1"
#    And I act as John
#    And I share "welcome.txt" with "user0"
#    And I see that the file is shared with "user0"
#    And I open the Chat tab in the details view of the Files app
#    And I act as Jane
#    # The Files app is open again to reload the file list
#    And I open the Files app
#    And I share "welcome (2).txt" with "user1"
#    And I see that the file is shared with "user1"
#    And I open the Chat tab in the details view of the Files app
#    And I act as Jim
#    # The Files app is open again to reload the file list
#    And I open the Files app
#    And I open the details view for "welcome (2).txt"
#    And I open the Chat tab in the details view of the Files app
#    When I act as John
#    And I send a new chat message with the text "Hello"
#    And I act as Jane
#    And I see that the message 1 was sent by "admin" with the text "Hello"
#    And I send a new chat message with the text "Hi!"
#    And I act as Jim
#    And I see that the message 2 was sent by "user0" with the text "Hi!"
#    And I send a new chat message with the text "Hey!"
#    Then I see that the message 1 was sent by "admin" with the text "Hello"
#    And I see that the message 2 was sent by "user0" with the text "Hi!"
#    And I see that the message 3 was sent by "user1" with the text "Hey!"
#    And I act as John
#    And I see that the message 1 was sent by "admin" with the text "Hello"
#    And I see that the message 2 was sent by "user0" with the text "Hi!"
#    And I see that the message 3 was sent by "user1" with the text "Hey!"
#    And I act as Jane
#    And I see that the message 1 was sent by "admin" with the text "Hello"
#    And I see that the message 2 was sent by "user0" with the text "Hi!"
#    And I see that the message 3 was sent by "user1" with the text "Hey!"
