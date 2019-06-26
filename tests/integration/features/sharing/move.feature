Feature: move

  Background:
    Given user "participant1" exists
    Given user "participant2" exists
    Given user "participant3" exists
    Given user "participant4" exists

  Scenario: move share to another folder
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" adds "participant3" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant1" creates folder "/test"
    When user "participant1" moves file "/welcome.txt" to "/test/renamed.txt" with 201
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /test/renamed.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome.txt |
      | share_with             | group room |
      | share_with_displayname | Group room |
    And user "participant2" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room |
      | share_with_displayname | Group room |
    And user "participant3" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room |
      | share_with_displayname | Group room |

#  # When an own share is moved into a received shared folder the ownership of
#  # the share is handed over to the folder owner.
#  Scenario: move share to received shared folder from a user in the room
#    Given user "participant1" creates room "group room"
#      | roomType | 2 |
#      | roomName | room |
#    And user "participant1" renames room "group room" to "Group room" with 200
#    And user "participant1" adds "participant2" to room "group room" with 200
#    And user "participant1" adds "participant3" to room "group room" with 200
#    And user "participant3" creates folder "/test"
#    And user "participant3" shares "/test" with user "participant1" with OCS 100
#    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
#    When user "participant1" moves file "/welcome.txt" to "/test/renamed.txt" with 201
#    Then user "participant1" gets last share
#    And share is returned with
#      | uid_owner              | participant1 |
#      | displayname_owner      | participant1-displayname |
#      | uid_file_owner         | participant3 |
#      | displayname_file_owner | participant3-displayname |
#      | path                   | /test/renamed.txt |
#      | item_type              | file |
#      | mimetype               | text/plain |
#      | storage_id             | shared::/test |
#      | file_target            | /welcome.txt |
#      | share_with             | group room |
#      | share_with_displayname | Group room |
#    And user "participant2" gets last share
#    And share is returned with
#      | uid_owner              | participant1 |
#      | displayname_owner      | participant1-displayname |
#      | uid_file_owner         | participant3 |
#      | displayname_file_owner | participant3-displayname |
#      | path                   | /welcome (2).txt |
#      | item_type              | file |
#      | mimetype               | text/plain |
#      | storage_id             | shared::/welcome (2).txt |
#      | file_target            | /welcome (2).txt |
#      | share_with             | group room |
#      | share_with_displayname | Group room |
#    And user "participant3" gets last share
#    And share is returned with
#      | uid_owner              | participant1 |
#      | displayname_owner      | participant1-displayname |
#      | uid_file_owner         | participant3 |
#      | displayname_file_owner | participant3-displayname |
#      | path                   | /test/renamed.txt |
#      | item_type              | file |
#      | mimetype               | text/plain |
#      | storage_id             | home::participant3 |
#      | file_target            | /welcome (2).txt |
#      | share_with             | group room |
#      | share_with_displayname | Group room |

#  Scenario: move share to received shared folder from a user not in the room
#    Given user "participant1" creates room "group room"
#      | roomType | 2 |
#      | roomName | room |
#    And user "participant1" renames room "group room" to "Group room" with 200
#    And user "participant1" adds "participant2" to room "group room" with 200
#    And user "participant1" adds "participant3" to room "group room" with 200
#    And user "participant4" creates folder "/test"
#    And user "participant4" shares "/test" with user "participant1" with OCS 100
#    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
#    When user "participant1" moves file "/welcome.txt" to "/test/renamed.txt" with 201
#    Then user "participant1" gets last share
#    And share is returned with
#      | uid_owner              | participant1 |
#      | displayname_owner      | participant1-displayname |
#      | uid_file_owner         | participant4 |
#      | displayname_file_owner | participant4-displayname |
#      | path                   | /test/renamed.txt |
#      | item_type              | file |
#      | mimetype               | text/plain |
#      | storage_id             | shared::/test |
#      | file_target            | /welcome.txt |
#      | share_with             | group room |
#      | share_with_displayname | Group room |
#    And user "participant2" gets last share
#    And share is returned with
#      | uid_owner              | participant1 |
#      | displayname_owner      | participant1-displayname |
#      | uid_file_owner         | participant4 |
#      | displayname_file_owner | participant4-displayname |
#      | path                   | /welcome (2).txt |
#      | item_type              | file |
#      | mimetype               | text/plain |
#      | storage_id             | shared::/welcome (2).txt |
#      | file_target            | /welcome (2).txt |
#      | share_with             | group room |
#      | share_with_displayname | Group room |
#    And user "participant3" gets last share
#    And share is returned with
#      | uid_owner              | participant1 |
#      | displayname_owner      | participant1-displayname |
#      | uid_file_owner         | participant4 |
#      | displayname_file_owner | participant4-displayname |
#      | path                   | /welcome (2).txt |
#      | item_type              | file |
#      | mimetype               | text/plain |
#      | storage_id             | shared::/welcome (2).txt |
#      | file_target            | /welcome (2).txt |
#      | share_with             | group room |
#      | share_with_displayname | Group room |

#  Scenario: move share to received shared folder which is also a received shared folder
#    Given user "participant1" creates room "group room"
#      | roomType | 2 |
#      | roomName | room |
#    And user "participant1" renames room "group room" to "Group room" with 200
#    And user "participant1" adds "participant2" to room "group room" with 200
#    And user "participant3" creates folder "/test"
#    And user "participant3" shares "/test" with user "participant4" with OCS 100
#    And user "participant4" shares "/test" with user "participant1" with OCS 100
#    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
#    When user "participant1" moves file "/welcome.txt" to "/test/renamed.txt" with 201
#    Then user "participant1" gets last share
#    And share is returned with
#      | uid_owner              | participant1 |
#      | displayname_owner      | participant1-displayname |
#      | uid_file_owner         | participant3 |
#      | displayname_file_owner | participant3-displayname |
#      | path                   | /test/renamed.txt |
#      | item_type              | file |
#      | mimetype               | text/plain |
#      | storage_id             | shared::/test |
#      | file_target            | /welcome.txt |
#      | share_with             | group room |
#      | share_with_displayname | Group room |
#    And user "participant2" gets last share
#    And share is returned with
#      | uid_owner              | participant1 |
#      | displayname_owner      | participant1-displayname |
#      | uid_file_owner         | participant3 |
#      | displayname_file_owner | participant3-displayname |
#      | path                   | /welcome (2).txt |
#      | item_type              | file |
#      | mimetype               | text/plain |
#      | storage_id             | shared::/welcome (2).txt |
#      | file_target            | /welcome (2).txt |
#      | share_with             | group room |
#      | share_with_displayname | Group room |
#    And user "participant3" gets last share
#    And share is returned with
#      | uid_owner              | participant1 |
#      | displayname_owner      | participant1-displayname |
#      | uid_file_owner         | participant3 |
#      | displayname_file_owner | participant3-displayname |
#      | path                   | /test/renamed.txt |
#      | item_type              | file |
#      | mimetype               | text/plain |
#      | storage_id             | home::participant3 |
#      | file_target            | /welcome.txt |
#      | share_with             | group room |
#      | share_with_displayname | Group room |
#    And user "participant4" gets last share
#    Then the OCS status code should be "404"
#    And the HTTP status code should be "200"

  Scenario: move received share to another folder
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" adds "participant3" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" creates folder "/test"
    When user "participant2" moves file "/welcome (2).txt" to "/test/renamed.txt" with 201
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome.txt |
      | share_with             | group room |
      | share_with_displayname | Group room |
    And user "participant2" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /test/renamed.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/test/renamed.txt |
      | file_target            | /test/renamed.txt |
      | share_with             | group room |
      | share_with_displayname | Group room |
    And user "participant3" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room |
      | share_with_displayname | Group room |



  # Received shares can not be moved into other shares (general limitation of
  # the sharing system, not related to room shares).
  Scenario: move received share to shared folder
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" adds "participant3" to room "group room" with 200
    And user "participant3" creates folder "/test"
    And user "participant3" shares "/test" with user "participant2" with OCS 100
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    When user "participant3" moves file "/welcome (2).txt" to "/test/renamed.txt"
    Then the HTTP status code should be "403"
