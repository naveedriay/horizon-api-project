@api @favourites @@AddtoFavourites

Feature: Favourites Api

  @regression
  Scenario: Verify Adding & Fetching favourites for a valid userId
    Given I have created a user session using session endpoint
    And I save the session.userId from within response json as UserId
    And I have added favourite items for this user using persuade/favourites/add_to_favourites.json
    And make sure following attributes exist within response json
      | summary.status | ADDED     |
      | summary.skuids | [value>1] |
    When I create a new favourites api request with following headers
      | Content-Type | application/json |
    And I send a GET request to favourites/user/{UserId} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | favourites[0] | 003969 |
      | favourites[1] | 048776 |


  Scenario: Verify Adding, Updating & Fetching favourites for a valid userId
    Given I have created a user session using session endpoint
    And I save the session.userId from within response json as UserId
    And I have added favourite items for this user using persuade/favourites/add_to_favourites.json
    And make sure following attributes exist within response json
      | summary.status | ADDED     |
      | summary.skuids | [value>1] |
    When I create a new favourites api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file persuade/favourites/patch_to_favourites.json
    And I send a PATCH request to favourites/user/{UserId} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | summary.status | ADDED                    |
      | summary.skuid  | 011890                   |
      | favourites     | [003969, 048776, 011890] |
    When I get the favourites items for current user
    And make sure following attributes exist within response json
      | favourites[0] | 003969 |
      | favourites[1] | 048776 |
      | favourites[2] | 011890 |

  Scenario: Verify Adding, Deleting & Fetching favourites for a valid userId
    Given I have created a user session using session endpoint
    And I save the session.userId from within response json as UserId
    And I have added favourite items for this user using persuade/favourites/add_to_favourites.json
    And make sure following attributes exist within response json
      | summary.status | ADDED     |
      | summary.skuids | [value>1] |
    When I create a new favourites api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file persuade/favourites/delete_from_favourites.json
    And I send a DELETE request to favourites/user/{UserId} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | summary.status | REMOVED  |
      | summary.skuid  | 003969   |
      | favourites     | [048776] |
    When I get the favourites items for current user
    Then make sure following attributes exist within response json
      | favourites[0]  | 048776   |

  @negative
  Scenario: Verify Fetching favourites for a non existing userId
    Given I create a new favourites api request with following headers
      | Content-Type | application/json |
    When I send a GET request to favourites/user/1234567890 endpoint
    Then The response status code should be 404
    And make sure following attributes exist within response json
      | message | User does not exist |

    @ignore
  Scenario: Verify Fetching favourites for a userId with no favourites in it
    Given I have created a user session using session endpoint
    And I save the session.userId from within response json as UserId
    And I have added favourite items for this user using persuade/favourites/delete_from_favourites.json
    When I get the favourites items for current user

    When I have deleted favourite items for this user using persuade/favourites/delete_from_favourites.json
    When I create a new favourites api request with following headers
      | Content-Type | application/json |
    And I send a GET request to favourites/user/{UserId} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | favourites | [] |