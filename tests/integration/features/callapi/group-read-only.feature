Feature: callapi/group-read-only
  Background:
    Given user "participant1" exists
    And user "participant2" exists
    And user "participant3" exists
    And group "attendees1" exists
    And user "participant2" is member of group "attendees1"

  Scenario: User1 invites group attendees1 to a group room and they cant join the call in a locked conversation
    When user "participant1" creates room "room"
      | roomType | 2 |
      | invite   | attendees1 |
    Then user "participant1" is participant of room "room"
    And user "participant2" is participant of room "room"
    Then user "participant1" sees 0 peers in call "room" with 200
    And user "participant2" sees 0 peers in call "room" with 200
    When user "participant1" locks room "room" with 200
    And user "participant1" joins room "room" with 200
    And user "participant1" joins call "room" with 403
    And user "participant2" joins room "room" with 200
    And user "participant2" joins call "room" with 403
    Then user "participant1" sees 0 peers in call "room" with 403
    And user "participant2" sees 0 peers in call "room" with 403
    When user "participant1" unlocks room "room" with 200
    And user "participant1" joins call "room" with 200
    And user "participant2" joins call "room" with 200
    Then user "participant1" sees 2 peers in call "room" with 200
    And user "participant2" sees 2 peers in call "room" with 200
