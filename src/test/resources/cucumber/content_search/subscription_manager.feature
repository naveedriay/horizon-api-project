@api @subscription_manager @persuade @content_sanity

Feature: Test Subscription Manager Api endpoint for certain SkuId

  @PERSUADE-840
  Scenario: Test Get Endpoint for Subscription Manager
    Given I create a new subscription api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | period | 90 |
      | locale | en |
      | siteId | 10 |
    When I send a GET request to skus/011890 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | sku-id       | 011890   |
      | best-price   | [number] |
#      | subscribable | true     |