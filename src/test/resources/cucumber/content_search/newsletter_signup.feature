@api @NewsLetterSignup @persuade

Feature: Test NewsLetter SignUp Mechanism

  @regression @content_sanity
  Scenario: Verify creating a new NewsLetter Signup Request via SignUp Api
    Given I create a new preProd api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file persuade/newsletter_signup_payload.json
    When I send a POST request to api/signup endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | success | true |

  Scenario Outline: Verify creating a new NewsLetter Signup Request via SignUp Api
    Given I create a new preProd api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename persuade/newsletter_signup_payload.json replacing values
      | <attribute> |  |
    When I send a POST request to api/signup endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | success | false |

    Examples:
      | attribute |
      | firstName |
      | lastName  |
      | email     |