Feature: conversation/files

  Background:
    Given user "participant1" exists
    Given user "participant2" exists
    Given user "participant3" exists
    And group "group1" exists
    And user "participant2" is member of group "group1"

  # When "user XXX gets the room for path YYY with 200" succeeds the room token
  # can later be used by any participant using the "file YYY room" identifier.

  Scenario: get room for file not shared
    When user "participant1" gets the room for path "welcome.txt" with 404



  Scenario: get room for file shared with user
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    When user "participant1" gets the room for path "welcome.txt" with 200
    And user "participant2" gets the room for path "welcome (2).txt" with 200
    Then user "participant1" is participant of room "file welcome (2).txt room"
    And user "participant2" is participant of room "file welcome (2).txt room"

  Scenario: get room for folder shared with user
    Given user "participant1" creates folder "/test"
    And user "participant1" shares "test" with user "participant2" with OCS 100
    When user "participant1" gets the room for path "test" with 404
    And user "participant2" gets the room for path "test" with 404

  Scenario: get room for file in folder shared with user
    Given user "participant1" creates folder "/test"
    And user "participant1" moves file "/welcome.txt" to "/test/renamed.txt" with 201
    And user "participant1" shares "test" with user "participant2" with OCS 100
    When user "participant1" gets the room for path "test/renamed.txt" with 200
    And user "participant2" gets the room for path "test/renamed.txt" with 200
    Then user "participant1" is participant of room "file test/renamed.txt room"
    And user "participant2" is participant of room "file test/renamed.txt room"

  Scenario: get room for file in folder reshared with user
    Given user "participant1" creates folder "/test"
    And user "participant1" moves file "/welcome.txt" to "/test/renamed.txt" with 201
    And user "participant1" shares "test" with user "participant2" with OCS 100
    And user "participant2" shares "test" with user "participant3" with OCS 100
    When user "participant1" gets the room for path "test/renamed.txt" with 200
    And user "participant2" gets the room for path "test/renamed.txt" with 200
    And user "participant3" gets the room for path "test/renamed.txt" with 200
    Then user "participant1" is participant of room "file test/renamed.txt room"
    And user "participant2" is participant of room "file test/renamed.txt room"
    And user "participant3" is participant of room "file test/renamed.txt room"

  Scenario: get room for file no longer shared
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant1" deletes last share
    When user "participant1" gets the room for path "welcome.txt" with 404



  Scenario: get room for file shared with group
    Given user "participant1" shares "welcome.txt" with group "group1" with OCS 100
    When user "participant1" gets the room for path "welcome.txt" with 200
    And user "participant2" gets the room for path "welcome (2).txt" with 200
    Then user "participant1" is participant of room "file welcome (2).txt room"
    And user "participant2" is participant of room "file welcome (2).txt room"

  Scenario: get room for file shared with user and group
    Given user "participant1" shares "welcome.txt" with group "group1" with OCS 100
    And user "participant1" shares "welcome.txt" with user "participant3" with OCS 100
    When user "participant1" gets the room for path "welcome.txt" with 200
    And user "participant2" gets the room for path "welcome (2).txt" with 200
    And user "participant3" gets the room for path "welcome (2).txt" with 200
    Then user "participant1" is participant of room "file welcome (2).txt room"
    And user "participant2" is participant of room "file welcome (2).txt room"
    And user "participant3" is participant of room "file welcome (2).txt room"



  Scenario: get room for file shared by link
    Given user "participant1" shares "welcome.txt" by link with OCS 100
    When user "participant1" gets the room for path "welcome.txt" with 404

  Scenario: get room for file shared with user and by link
    Given user "participant1" shares "welcome.txt" by link with OCS 100
    And user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    When user "participant1" gets the room for path "welcome.txt" with 200
    And user "participant2" gets the room for path "welcome (2).txt" with 200
    Then user "participant1" is participant of room "file welcome (2).txt room"
    And user "participant2" is participant of room "file welcome (2).txt room"



  Scenario: owner of a shared file can join its room
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant2" gets the room for path "welcome (2).txt" with 200
    When user "participant1" joins room "file welcome (2).txt room" with 200
    Then user "participant1" is participant of room "file welcome (2).txt room"

  Scenario: user with access to a file can join its room
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant1" gets the room for path "welcome.txt" with 200
    When user "participant2" joins room "file welcome.txt room" with 200
    Then user "participant2" is participant of room "file welcome.txt room"

  Scenario: owner of a file in a shared folder can join its room
    Given user "participant1" creates folder "/test"
    And user "participant1" moves file "/welcome.txt" to "/test/renamed.txt" with 201
    And user "participant1" shares "test" with user "participant2" with OCS 100
    And user "participant2" gets the room for path "test/renamed.txt" with 200
    When user "participant1" joins room "file test/renamed.txt room" with 200
    Then user "participant1" is participant of room "file test/renamed.txt room"

  Scenario: user with access to a file in a shared folder can join its room
    Given user "participant1" creates folder "/test"
    And user "participant1" moves file "/welcome.txt" to "/test/renamed.txt" with 201
    And user "participant1" shares "test" with user "participant2" with OCS 100
    And user "participant1" gets the room for path "test/renamed.txt" with 200
    When user "participant2" joins room "file test/renamed.txt room" with 200
    Then user "participant2" is participant of room "file test/renamed.txt room"

  Scenario: owner of a no longer shared file can not join its room
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant2" gets the room for path "welcome (2).txt" with 200
    And user "participant1" deletes last share
    When user "participant1" joins room "file welcome (2).txt room" with 404
    Then user "participant1" is not participant of room "file welcome (2).txt room"

  Scenario: user no longer with access to a file can not join its room
    Given user "participant1" shares "welcome.txt" with user "participant3" with OCS 100
    And user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant1" gets the room for path "welcome.txt" with 200
    And user "participant1" deletes last share
    When user "participant2" joins room "file welcome.txt room" with 404
    Then user "participant2" is not participant of room "file welcome.txt room"

  Scenario: user without access to a file can not join its room
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant1" gets the room for path "welcome.txt" with 200
    When user "participant3" joins room "file welcome.txt room" with 404
    Then user "participant3" is not participant of room "file welcome.txt room"

  Scenario: guest can not join a file room
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant1" gets the room for path "welcome.txt" with 200
    When user "guest" joins room "file welcome.txt room" with 404



  Scenario: owner of a shared file can join its room again after leaving it
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant2" gets the room for path "welcome (2).txt" with 200
    And user "participant1" joins room "file welcome (2).txt room" with 200
    And user "participant1" is participant of room "file welcome (2).txt room"
    When user "participant1" leaves room "file welcome (2).txt room" with 200
    And user "participant1" is not participant of room "file welcome (2).txt room"
    And user "participant1" joins room "file welcome (2).txt room" with 200
    Then user "participant1" is participant of room "file welcome (2).txt room"

  Scenario: user with access to a file can join its room again after leaving it
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant1" gets the room for path "welcome.txt" with 200
    And user "participant2" joins room "file welcome.txt room" with 200
    And user "participant2" is participant of room "file welcome.txt room"
    When user "participant2" leaves room "file welcome.txt room" with 200
    And user "participant2" is not participant of room "file welcome.txt room"
    And user "participant2" joins room "file welcome.txt room" with 200
    Then user "participant2" is participant of room "file welcome.txt room"



  # Participants are removed from the room for a no longer shared file once they
  # try to join the room again, but not when the file is unshared.

  Scenario: owner is not participant of room for file no longer shared
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant1" gets the room for path "welcome.txt" with 200
    And user "participant1" is participant of room "file welcome.txt room"
    When user "participant1" deletes last share
    Then user "participant1" is participant of room "file welcome.txt room"
    And user "participant1" joins room "file welcome.txt room" with 404
    And user "participant1" is not participant of room "file welcome.txt room"

  Scenario: user is not participant of room for file no longer with access to it
    Given user "participant1" shares "welcome.txt" with user "participant2" with OCS 100
    And user "participant2" gets the room for path "welcome (2).txt" with 200
    And user "participant2" is participant of room "file welcome (2).txt room"
    When user "participant1" deletes last share
    Then user "participant2" is participant of room "file welcome (2).txt room"
    And user "participant2" joins room "file welcome (2).txt room" with 404
    And user "participant2" is not participant of room "file welcome (2).txt room"
