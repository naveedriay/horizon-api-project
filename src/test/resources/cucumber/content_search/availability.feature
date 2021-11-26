@api @availability @discover @DISCOVER-1577

Feature: Availability API

  # ======================================================================================================  #
  # ==  TESTING AVAILABILITY API PROXY SERVICE at https://preprod-com.hollandandbarrett.net/api/availability
  # ======================================================================================================  #
  @negative
  Scenario: Verify the Availability Proxy Service (prod) with Invalid Empty Payload
    Given I create a new preProd api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file onesearch/empty_payload.json
    When I send a POST request to api/availability endpoint
    Then The response status code should be 400

 # @content_sanity
  Scenario Outline: Availability Proxy Service for locale <locale>
    Given I create a new availability api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/proxy_availability_payload.json replacing values
      | locale | <locale> |
    When I send a POST request to availability endpoint
    Then The response status code should be 200
    And make sure number of entries returned for items are equal to 11
    And the item status would be one of the following
      | status       |
      | INSTOCK      |
      | INSTOCK      |
      | NOTFOUND     |
      | NOTAVAILABLE |
      | OUTOFSTOCK   |

    Examples:
      | locale |
      | en-GB  |
      | en-FR  |

  #@content_sanity
  Scenario: Availability Proxy Service for Locale Ireland
    Given I create a new availability api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/proxy_availability_payload.json replacing values
      | locale | en-IE |
    When I send a POST request to availability endpoint
    Then The response status code should be 200
    And make sure number of entries returned for items are equal to 11
    And the item status would be one of the following
      | status       |
      | INSTOCK      |
      | INSTOCK      |
      | NOTFOUND     |
      | NOTAVAILABLE |
      | OUTOFSTOCK   |