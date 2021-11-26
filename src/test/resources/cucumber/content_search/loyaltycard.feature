@api @loyaltycard @persuade @content_sanity

Feature: Test loyalty card Api endpoint for PUT request

  @regression @PERS-41
  Scenario: Test PUT request for Loyalty card service for new Customer
    Given I create a new loyaltycard api request with following headers
      | Content-Type  | application/json |
    And I add a json payload using filename persuade/newuser_loyaltycard.json replacing values
      | customer.email         | {random-email}   |
      | customer-identifier.id | {random-OCHId}   |
    When I send a PUT request to loyalty-card endpoint
    Then The response status code should be 201
    And make sure following attributes exist within response json
      | loyalty-card-id | [number]   |

  @negative @PERS-41
  Scenario: Test PUT request for Loyalty card service for new Customer
    Given I create a new loyaltycard api request with following headers
      | Content-Type  | application/json |
    And I add a json payload using the file persuade/existingUser_loyaltycard.json
    When I send a PUT request to loyalty-card endpoint
    Then The response status code should be 409
    And make sure following attributes exist within response json
      | loyalty-card-id | 2916000000569 |

  @negative @PERS-41
  Scenario: Test PUT request for Loyalty card service for new Customer
    Given I create a new loyaltycard api request with following headers
      | Content-Type  | application/json |
    And I add a json payload using filename persuade/bad_loyaltycard.json replacing values
      | customer.email| {random-email}   |
    When I send a PUT request to loyalty-card endpoint
    Then The response status code should be 400
    And make sure following attributes exist within response json
      | status | 400          |
      | error  | Bad Request  |
      | path   | /loyalty-card|


