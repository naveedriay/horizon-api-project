@api @sessions @content_sanity

Feature: Sessions Api

  @regression
  Scenario: Verify creating a new Empty Session with GET call
    Given I create a new session api request with following headers
      | Content-Type | application/json |
    When I send a GET request to session endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | session.basketItems              | []     |
      | session.giftlistId               |        |
      | session.hasCompletedQuestionaire | false  |
      | session.loginStatus              | false  |
      | session.unlimited                | false  |
      | session.rewardsCards             | []     |
      | session.userId                   |[number]|


  Scenario: Verify fetching a Session for existing Registered user
    Given I create a new login api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/rfl/regUser_login_credentials.json replacing values
      | email    | sanvi@test.com |
      | password | Qwerty@123     |
    When I send a POST request to login endpoint
    Then The response status code should be 200
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure following attributes exist within response json
      | message  | Authentication complete    |
      | status   | success                    |
#    NOW FETCH THE SESSION INFO FOR THIS REGISTERED USER
    Given I create a new session api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to session endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | session.basketItems              | []     |
      | session.giftlistId               |        |
      | session.unlimited                | false  |
      | session.hasCompletedQuestionaire | false  |
      | session.loginStatus              | true   |
      | session.email                    | sanvi@test.com |
      | session.name                     | SANVI SANU     |
      | session.ochId                    | 1-166KISU      |
      | session.rewardsCards             | [2916000000286]|
      | session.userId                   | 933800424      |


  @regression
  Scenario: Verify fetching Session for a Guest User with basket items
    Given I create a new preProd-rest api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/nonpromo_item_payload.json
    When I send a POST request to basket endpoint
    Then The response status code should be 200
    And I save the JSESSIONID from within response header as JSession-ID
    Given I create a new session api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to session endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | session.basketItems[0].skuId     | 039085   |
      | session.basketItems[1].skuId     | 042727   |
      | session.giftlistId               |          |
      | session.hasCompletedQuestionaire | false    |
      | session.loginStatus              | false    |
      | session.unlimited                | false    |
      | session.rewardsCards             | []       |
      | session.userId                   | [number] |
