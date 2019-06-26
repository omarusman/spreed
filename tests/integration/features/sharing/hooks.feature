Feature: hooks

  Background:
    Given user "participant1" exists
    Given user "participant2" exists
    Given user "participant3" exists
    Given user "participant4" exists

  # Entering a room does not really require any hook to work, but conceptually
  # these tests belong here.
  Scenario: invite user to group room after a file was shared
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    When user "participant1" adds "participant2" to room "group room" with 200
    Then user "participant2" gets last share
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

  Scenario: join public room after a file was shared
    Given user "participant1" creates room "public room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" renames room "public room" to "Public room" with 200
    And user "participant1" shares "welcome.txt" with room "public room" with OCS 100
    And user "participant2" joins room "public room" with 200
    Then user "participant2" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | public room |
      | share_with_displayname | Public room |
      | token                  | A_TOKEN |



  Scenario: remove sharer from group room after sharing a file
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant2" shares "welcome.txt" with room "group room" with OCS 100
    When user "participant1" removes "participant2" from room "group room" with 200
    Then user "participant1" gets last share
    And the OCS status code should be "404"
    And user "participant2" gets last share
    And the OCS status code should be "404"

  Scenario: remove herself from group room after sharing a file
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant2" shares "welcome.txt" with room "group room" with OCS 100
    When user "participant2" removes themselves from room "group room" with 200
    Then user "participant1" gets last share
    And the OCS status code should be "404"
    And user "participant2" gets last share
    And the OCS status code should be "404"

  Scenario: leave group room after sharing a file
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant2" shares "welcome.txt" with room "group room" with OCS 100
    When user "participant2" leaves room "group room" with 200
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room |
      | share_with_displayname | Group room |
    And user "participant2" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant2 |
      | file_target            | /welcome.txt |
      | share_with             | group room |
      | share_with_displayname | Group room |

  Scenario: leave public room invited to after sharing a file
    Given user "participant1" creates room "public room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" renames room "public room" to "Public room" with 200
    And user "participant1" adds "participant2" to room "public room" with 200
    And user "participant2" shares "welcome.txt" with room "public room" with OCS 100
    When user "participant2" leaves room "public room" with 200
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | public room |
      | share_with_displayname | Public room |
      | token                  | A_TOKEN |
    And user "participant2" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant2 |
      | file_target            | /welcome.txt |
      | share_with             | public room |
      | share_with_displayname | Public room |
      | token                  | A_TOKEN |

  Scenario: leave public room self joined to after sharing a file
    Given user "participant1" creates room "public room"
      | roomType | 3 |
      | roomName | room |
    And user "participant2" joins room "public room" with 200
    And user "participant2" shares "welcome.txt" with room "public room" with OCS 100
    When user "participant2" leaves room "public room" with 200
    Then user "participant1" gets last share
    And the OCS status code should be "404"
    And user "participant2" gets last share
    And the OCS status code should be "404"

  Scenario: remove sharer from group room with other shares after sharing a file
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" creates folder "test"
    And user "participant1" shares "test" with room "group room" with OCS 100
    And user "participant2" shares "welcome.txt" with room "group room" with OCS 100
    When user "participant1" removes "participant2" from room "group room" with 200
    Then user "participant1" gets last share
    And the OCS status code should be "404"
    And user "participant2" gets last share
    And the OCS status code should be "404"
    And user "participant1" gets all shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | uid_file_owner         | participant1 |
      | displayname_file_owner | participant1-displayname |
      | path                   | /test |
      | item_type              | folder |
      | mimetype               | httpd/unix-directory |
      | storage_id             | home::participant1 |
      | file_target            | /test |
      | share_with             | group room |
      | share_with_displayname | Group room |
      | permissions            | 31 |



  Scenario: remove sharer from group room after sharing a file and a receiver reshared it
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant2" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant1" shares "welcome (2).txt" with user "participant3" with OCS 100
    When user "participant1" removes "participant2" from room "group room" with 200
    Then user "participant1" gets last share
    And the OCS status code should be "404"
    And user "participant1" gets all shares
    And the list of returned shares has 0 shares
    And user "participant2" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | uid_file_owner         | participant2 |
      | displayname_file_owner | participant2-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant2 |
      | file_target            | /welcome (2).txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |
    And user "participant2" gets all shares
    And the list of returned shares has 0 shares
    And user "participant3" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | uid_file_owner         | participant2 |
      | displayname_file_owner | participant2-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |



  Scenario: remove sharee from group room after a file was shared
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    When user "participant1" removes "participant2" from room "group room" with 200
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
    And the OCS status code should be "404"

  Scenario: remove sharee from group room after a file was shared and the sharee moved it
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" moves file "welcome (2).txt" to "renamed.txt"
    When user "participant1" removes "participant2" from room "group room" with 200
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
    And the OCS status code should be "404"

  Scenario: remove herself from group room after a file was shared
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    When user "participant2" removes themselves from room "group room" with 200
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
    And the OCS status code should be "404"

  Scenario: remove herself from group room after a file was shared and the sharee moved it
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" moves file "welcome (2).txt" to "renamed.txt"
    When user "participant2" removes themselves from room "group room" with 200
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
    And the OCS status code should be "404"

  Scenario: leave public room self joined to after a file was shared
    Given user "participant1" creates room "public room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" renames room "public room" to "Public room" with 200
    And user "participant2" joins room "public room" with 200
    And user "participant1" shares "welcome.txt" with room "public room" with OCS 100
    When user "participant2" leaves room "public room" with 200
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome.txt |
      | share_with             | public room |
      | share_with_displayname | Public room |
      | token                  | A_TOKEN |
    And user "participant2" gets last share
    And the OCS status code should be "404"

  Scenario: leave public room self joined to after a file was shared and the sharee moved it
    Given user "participant1" creates room "public room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" renames room "public room" to "Public room" with 200
    And user "participant2" joins room "public room" with 200
    And user "participant1" shares "welcome.txt" with room "public room" with OCS 100
    And user "participant2" moves file "welcome (2).txt" to "renamed.txt"
    When user "participant2" leaves room "public room" with 200
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome.txt |
      | share_with             | public room |
      | share_with_displayname | Public room |
      | token                  | A_TOKEN |
    And user "participant2" gets last share
    And the OCS status code should be "404"

  Scenario: remove sharee from group room with other sharees after a file was shared and the sharees moved it
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" adds "participant3" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" moves file "welcome (2).txt" to "renamed.txt"
    And user "participant3" moves file "welcome (2).txt" to "renamed too.txt"
    When user "participant1" removes "participant2" from room "group room" with 200
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
    And the OCS status code should be "404"
    And user "participant3" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /renamed too.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/renamed too.txt |
      | file_target            | /renamed too.txt |
      | share_with             | group room |
      | share_with_displayname | Group room |



  Scenario: remove sharee from group room after a file was shared and the sharee reshared it
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" shares "welcome (2).txt" with user "participant3" with OCS 100
    When user "participant1" removes "participant2" from room "group room" with 200
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | uid_file_owner         | participant1 |
      | displayname_file_owner | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome (2).txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |
    And user "participant2" gets last share
    And the OCS status code should be "404"
    And user "participant2" gets all shares
    And the list of returned shares has 0 shares
    And user "participant3" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | uid_file_owner         | participant1 |
      | displayname_file_owner | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |



  Scenario: add sharer again to group room after sharing a file and the sharer was removed from the room
    Given user "participant2" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant2" adds "participant1" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" removes "participant1" from room "group room" with 200
    When user "participant2" adds "participant1" to room "group room" with 200
    Then user "participant1" gets all shares
    And the list of returned shares has 0 shares
    And user "participant2" gets all received shares
    And the list of returned shares has 0 shares

  Scenario: add sharer again to group room after sharing a file and the sharer removed herself from the room
    Given user "participant2" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant2" adds "participant1" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant1" removes themselves from room "group room" with 200
    When user "participant2" adds "participant1" to room "group room" with 200
    Then user "participant1" gets all shares
    And the list of returned shares has 0 shares
    And user "participant2" gets all received shares
    And the list of returned shares has 0 shares

  Scenario: join public room again after sharing a file and the sharer left the room
    Given user "participant2" creates room "public room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" joins room "public room" with 200
    And user "participant1" shares "welcome.txt" with room "public room" with OCS 100
    And user "participant1" leaves room "public room" with 200
    When user "participant1" joins room "public room" with 200
    Then user "participant1" gets all shares
    And the list of returned shares has 0 shares
    And user "participant2" gets all received shares
    And the list of returned shares has 0 shares



  Scenario: add sharer again to group room after sharing a file and a receiver reshared it and the sharer was removed from the room
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant2" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant1" shares "welcome (2).txt" with user "participant3" with OCS 100
    And user "participant1" removes "participant2" from room "group room" with 200
    When user "participant1" adds "participant2" to room "group room" with 200
    Then user "participant1" gets last share
    And the OCS status code should be "404"
    And user "participant1" gets all shares
    And the list of returned shares has 0 shares
    And user "participant2" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | uid_file_owner         | participant2 |
      | displayname_file_owner | participant2-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant2 |
      | file_target            | /welcome (2).txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |
    And user "participant2" gets all shares
    And the list of returned shares has 0 shares
    And user "participant3" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | uid_file_owner         | participant2 |
      | displayname_file_owner | participant2-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |



  Scenario: add sharee again to group room after a file was shared and the sharee was removed from the room
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant1" removes "participant2" from room "group room" with 200
    When user "participant1" adds "participant2" to room "group room" with 200
    Then user "participant2" gets all received shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room |
      | share_with_displayname | Group room |

  Scenario: add sharee again to group room after a file was shared and moved by the sharee and the sharee was removed from the room
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" moves file "welcome (2).txt" to "renamed.txt"
    And user "participant1" removes "participant2" from room "group room" with 200
    When user "participant1" adds "participant2" to room "group room" with 200
    Then user "participant2" gets all received shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room |
      | share_with_displayname | Group room |

  Scenario: add sharee again to group room after a file was shared and the sharee removed herself from the room
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" removes themselves from room "group room" with 200
    When user "participant1" adds "participant2" to room "group room" with 200
    Then user "participant2" gets all received shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room |
      | share_with_displayname | Group room |

  Scenario: add sharee again to group room after a file was shared and moved by the sharee and the sharee removed herself from the room
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" moves file "welcome (2).txt" to "renamed.txt"
    And user "participant2" removes themselves from room "group room" with 200
    When user "participant1" adds "participant2" to room "group room" with 200
    Then user "participant2" gets all received shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room |
      | share_with_displayname | Group room |

  Scenario: join sharee again to public room after a file was shared and the sharee left the room
    Given user "participant1" creates room "public room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" renames room "public room" to "Public room" with 200
    And user "participant2" joins room "public room" with 200
    And user "participant1" shares "welcome.txt" with room "public room" with OCS 100
    And user "participant2" leaves room "public room" with 200
    When user "participant2" joins room "public room" with 200
    Then user "participant2" gets all received shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | public room |
      | share_with_displayname | Public room |
      | token                  | A_TOKEN |

  Scenario: join sharee again to public room after a file was shared and moved by the sharee and the sharee left the room
    Given user "participant1" creates room "public room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" renames room "public room" to "Public room" with 200
    And user "participant2" joins room "public room" with 200
    And user "participant1" shares "welcome.txt" with room "public room" with OCS 100
    And user "participant2" moves file "welcome (2).txt" to "renamed.txt"
    And user "participant2" leaves room "public room" with 200
    When user "participant2" joins room "public room" with 200
    Then user "participant2" gets all received shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | public room |
      | share_with_displayname | Public room |
      | token                  | A_TOKEN |



  Scenario: add sharee again to group room after a file was shared and the sharee reshared it and the sharee was removed from the room
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" shares "welcome (2).txt" with user "participant3" with OCS 100
    And user "participant1" removes "participant2" from room "group room" with 200
    When user "participant1" adds "participant2" to room "group room" with 200
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | uid_file_owner         | participant1 |
      | displayname_file_owner | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome (2).txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |
    And user "participant2" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | uid_file_owner         | participant1 |
      | displayname_file_owner | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |
    And user "participant3" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | uid_file_owner         | participant1 |
      | displayname_file_owner | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |



  Scenario: delete one-to-one room after sharing a file
    Given user "participant1" creates room "own one-to-one room"
      | roomType | 1 |
      | invite   | participant2 |
    And user "participant1" shares "welcome.txt" with room "own one-to-one room" with OCS 100
    When user "participant1" removes themselves from room "own one-to-one room" with 200
    When user "participant2" removes themselves from room "own one-to-one room" with 200
    And user "participant1" is not participant of room "own one-to-one room"
    And user "participant2" is not participant of room "own one-to-one room"
    Then user "participant1" gets last share
    And the OCS status code should be "404"
    And user "participant2" gets last share
    And the OCS status code should be "404"

  Scenario: delete group room after sharing a file
    Given user "participant1" creates room "own group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "own group room" with 200
    And user "participant1" shares "welcome.txt" with room "own group room" with OCS 100
    When user "participant1" deletes room "own group room" with 200
    Then user "participant1" gets last share
    And the OCS status code should be "404"
    And user "participant2" gets last share
    And the OCS status code should be "404"

  Scenario: delete public room after sharing a file
    Given user "participant1" creates room "own public room"
      | roomType | 3 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "own public room" with 200
    And user "participant3" joins room "own public room" with 200
    And user "participant1" shares "welcome.txt" with room "own public room" with OCS 100
    When user "participant1" deletes room "own public room" with 200
    Then user "participant1" gets last share
    And the OCS status code should be "404"
    And user "participant2" gets last share
    And the OCS status code should be "404"
    And user "participant3" gets last share
    And the OCS status code should be "404"

  Scenario: delete room after a file was shared and the sharee moved it
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" moves file "welcome (2).txt" to "renamed.txt"
    When user "participant1" deletes room "group room" with 200
    Then user "participant1" gets last share
    And the OCS status code should be "404"
    And user "participant2" gets last share
    And the OCS status code should be "404"

  Scenario: delete room after a file was shared and the sharee reshared it
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" shares "welcome (2).txt" with user "participant3" with OCS 100
    When user "participant1" deletes room "group room" with 200
    Then user "participant1" gets all shares
    And the list of returned shares has 0 shares
    And user "participant2" gets all shares
    And the list of returned shares has 0 shares
    And user "participant2" gets all received shares
    And the list of returned shares has 0 shares
    And user "participant3" gets all received shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | uid_file_owner         | participant1 |
      | displayname_file_owner | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |

  Scenario: delete room after a file was shared and the sharee moved and reshared it
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant2" moves file "welcome (2).txt" to "renamed.txt"
    And user "participant2" shares "renamed.txt" with user "participant3" with OCS 100
    When user "participant1" deletes room "group room" with 200
    Then user "participant1" gets all shares
    And the list of returned shares has 0 shares
    And user "participant2" gets all shares
    And the list of returned shares has 0 shares
    And user "participant2" gets all received shares
    And the list of returned shares has 0 shares
    And user "participant3" gets all received shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2-displayname |
      | uid_file_owner         | participant1 |
      | displayname_file_owner | participant1-displayname |
      | path                   | /renamed.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/renamed.txt |
      | file_target            | /renamed.txt |
      | share_with             | participant3 |
      | share_with_displayname | participant3-displayname |
      | share_type             | 0 |

  Scenario: delete room after sharing a file with several rooms
    Given user "participant1" creates room "group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room" to "Group room" with 200
    And user "participant1" creates room "another group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "another group room" to "Another group room" with 200
    And user "participant1" creates room "yet another group room"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "yet another group room" to "Yet another group room" with 200
    And user "participant1" adds "participant2" to room "group room" with 200
    And user "participant1" adds "participant2" to room "another group room" with 200
    And user "participant1" adds "participant2" to room "yet another group room" with 200
    And user "participant1" shares "welcome.txt" with room "group room" with OCS 100
    And user "participant1" shares "welcome.txt" with room "another group room" with OCS 100
    And user "participant1" shares "welcome.txt" with room "yet another group room" with OCS 100
    When user "participant1" deletes room "group room" with 200
    Then user "participant1" gets all shares
    And the list of returned shares has 2 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome.txt |
      | share_with             | another group room |
      | share_with_displayname | Another group room |
    And share 1 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome.txt |
      | share_with             | yet another group room |
      | share_with_displayname | Yet another group room |
    And user "participant2" gets all received shares
    And the list of returned shares has 2 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | another group room |
      | share_with_displayname | Another group room |
    And share 1 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | yet another group room |
      | share_with_displayname | Yet another group room |



  Scenario: delete user after sharing a file
    Given user "participant1" creates room "group room invited to"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" adds "participant2" to room "group room invited to" with 200
    And user "participant2" shares "welcome.txt" with room "group room invited to" with OCS 100
    When user "participant2" is deleted
    Then user "participant1" gets last share
    And the OCS status code should be "404"

  Scenario: delete user after receiving a shared a file
    Given user "participant1" creates room "group room invited to"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room invited to" to "Group room invited to" with 200
    And user "participant1" adds "participant2" to room "group room invited to" with 200
    And user "participant1" adds "participant3" to room "group room invited to" with 200
    And user "participant1" shares "welcome.txt" with room "group room invited to" with OCS 100
    When user "participant2" is deleted
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome.txt |
      | share_with             | group room invited to |
      | share_with_displayname | Group room invited to |
    And user "participant3" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room invited to |
      | share_with_displayname | Group room invited to |

  Scenario: delete user after receiving and moving a shared a file
    Given user "participant1" creates room "group room invited to"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room invited to" to "Group room invited to" with 200
    And user "participant1" adds "participant2" to room "group room invited to" with 200
    And user "participant1" adds "participant3" to room "group room invited to" with 200
    And user "participant1" shares "welcome.txt" with room "group room invited to" with OCS 100
    And user "participant2" moves file "welcome (2).txt" to "renamed.txt"
    When user "participant2" is deleted
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome.txt |
      | share_with             | group room invited to |
      | share_with_displayname | Group room invited to |
    And user "participant3" gets last share
    And share is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room invited to |
      | share_with_displayname | Group room invited to |

  Scenario: delete user after resharing a file
    Given user "participant1" creates room "group room invited to"
      | roomType | 2 |
      | roomName | room |
    And user "participant1" renames room "group room invited to" to "Group room invited to" with 200
    And user "participant1" adds "participant2" to room "group room invited to" with 200
    And user "participant1" adds "participant3" to room "group room invited to" with 200
    And user "participant1" shares "welcome.txt" with room "group room invited to" with OCS 100
    And user "participant2" shares "welcome (2).txt" with user "participant4" with OCS 100
    When user "participant2" is deleted
    Then user "participant1" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2 |
      | uid_file_owner         | participant1 |
      | displayname_file_owner | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome (2).txt |
      | share_with             | participant4 |
      | share_with_displayname | participant4-displayname |
      | share_type             | 0 |
    And user "participant1" gets all shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome.txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | home::participant1 |
      | file_target            | /welcome.txt |
      | share_with             | group room invited to |
      | share_with_displayname | Group room invited to |
    And user "participant3" gets last share
    And the OCS status code should be "404"
    And the HTTP status code should be "200"
    And user "participant3" gets all received shares
    And the list of returned shares has 1 shares
    And share 0 is returned with
      | uid_owner              | participant1 |
      | displayname_owner      | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | group room invited to |
      | share_with_displayname | Group room invited to |
    And user "participant4" gets last share
    And share is returned with
      | uid_owner              | participant2 |
      | displayname_owner      | participant2 |
      | uid_file_owner         | participant1 |
      | displayname_file_owner | participant1-displayname |
      | path                   | /welcome (2).txt |
      | item_type              | file |
      | mimetype               | text/plain |
      | storage_id             | shared::/welcome (2).txt |
      | file_target            | /welcome (2).txt |
      | share_with             | participant4 |
      | share_with_displayname | participant4-displayname |
      | share_type             | 0 |
