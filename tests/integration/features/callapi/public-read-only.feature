Feature: callapi/public-read-only
  Background:
    Given user "participant1" exists
    And user "participant2" exists
    And user "participant3" exists

  Scenario: User1 invites user2 to a public room and they cant join the call in a locked conversation
    When user "participant1" creates room "room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "room" with 200
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

  Scenario: User1 invites user2 to a public room and user3 cant join the call in a locked conversation
    When user "participant1" creates room "room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "room" with 200
    Then user "participant1" is participant of room "room"
    Then user "participant3" is not participant of room "room"
    When user "participant1" locks room "room" with 200
    And user "participant1" joins room "room" with 200
    And user "participant1" joins call "room" with 403
    And user "participant3" joins room "room" with 200
    And user "participant3" joins call "room" with 403
    Then user "participant1" sees 0 peers in call "room" with 403
    And user "participant3" sees 0 peers in call "room" with 403
    When user "participant1" unlocks room "room" with 200
    And user "participant1" joins call "room" with 200
    And user "participant3" joins call "room" with 200
    Then user "participant1" sees 2 peers in call "room" with 200
    And user "participant3" sees 2 peers in call "room" with 200

  Scenario: User1 invites user2 to a public room and guest cant join the call in a locked conversation
    When user "participant1" creates room "room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "room" with 200
    Then user "participant1" is participant of room "room"
    When user "participant1" locks room "room" with 200
    And user "guest" sees 0 peers in call "room" with 404
    Then user "participant1" joins room "room" with 200
    Then user "participant1" joins call "room" with 403
    Then user "guest" joins room "room" with 200
    And user "guest" joins call "room" with 403
    Then user "participant1" sees 0 peers in call "room" with 403
    And user "guest" sees 0 peers in call "room" with 403
    When user "participant1" unlocks room "room" with 200
    And user "participant1" sees 0 peers in call "room" with 200
    And user "guest" sees 0 peers in call "room" with 200
    Then user "participant1" joins call "room" with 200
    And user "guest" joins call "room" with 200
    Then user "participant1" sees 2 peers in call "room" with 200
    And user "guest" sees 2 peers in call "room" with 200
