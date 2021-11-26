@api @woosmap @content_sanity

Feature: Test WoosMap Api endpoint for Location services

  @sanity @regression
  Scenario: Test Get Endpoint for Woosmap Api for valid PostCode & Country
    Given I create a new woosmap api request with following headers
      | Content-Type | application/json |
      | referer      | http://localhost:8000/location/ |
    And I add following attributes in the request query string
      | input      | LE5 2AD    |
      | components | country:gb |
      | key        | woos-7dcebde8-9cf4-37a7-bac3-1dce1c0942ee |
    When I send a GET request to autocomplete endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | localities | [value>1] |

  @negative
  Scenario: Verify No Localities returned from Woosmap Api for Invalid PostCode & Country
    Given I create a new woosmap api request with following headers
      | Content-Type | application/json |
      | referer      | http://localhost:8000/location/ |
    And I add following attributes in the request query string
      | input      | 11223344   |
      | components | country:zz |
      | key        | woos-7dcebde8-9cf4-37a7-bac3-1dce1c0942ee |
    When I send a GET request to autocomplete endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | localities |            |