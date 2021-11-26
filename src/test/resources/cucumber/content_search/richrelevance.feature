@api @richrelevance @Recommendations

Feature: RichRelevance

  @content_sanity @regression @DISCOVER-1273
  Scenario: RichRelevance for valid SignedIn User Session
    Given I create a new richrelevance api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | apiClientKey | bf4bba1cc072c0d5 |
      | apiKey       | 3254ec731ecd5afc |
      | placements   | category_page.replenishment_2 |
      | sessionId    | 83604f3a4013e3c3221e52ea702b1fe073ffaec2f8e7a25b71b1d7a7600e2de9 |
      | userId       | e3c04f59e880ae4d4451d161a95590ea6f6be783e46ecfad5bc2b22a4c0f82f0 |
      | categoryId   | 10001                                                            |
    When I send a GET request to recsForPlacements endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | status       | ok                 |
      #| placements[0].recommendedProducts | [value>1] |