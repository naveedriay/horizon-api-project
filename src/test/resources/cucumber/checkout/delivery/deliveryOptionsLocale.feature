@api @deliveryApi @checkout

Feature: Delivery Options Locale - No longer in use

#  ACs
#  Consumers are able to request a delivery Options for an international delivery
#  Both STANDARD & EXPRESS deliveryOptions should be returned with respective prices
  @sanity @FULFIL-1107 @ignore @review
  Scenario Outline: Get the delivery options for a specific country and currency
    Given I create a new delivery api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | currency | <currency> |
      | country  | <country>  |
    When I send a GET request to deliveryOptions endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | [0].type           | INTERNATIONAL_STANDARD |
      | [0].price.amount   | <standard_price>       |
      | [0].price.currency | <currency>             |
      | [1].type           | INTERNATIONAL_EXPRESS  |
      | [1].price.amount   | <express_price>        |
      | [1].price.currency | <currency>             |
    Examples:
      | currency | country | standard_price | express_price |
      | EUR      | IT      | 5.95           | 8.95          |
      | EUR      | FR      | 5.95           | 8.95          |
      | EUR      | DE      | 5.95           | 8.95          |
      | AUD      | AU      | 13.45          | 25.67         |
      | USD      | US      | 6.78           | 14.56         |

#  ACs
#  Consumers are able to request delivery Options for any international deliveryType
#  ONLY Requested deliveryOptions for respective deliveryType is returned
  @sanity @FULFIL-1107 @ignore @review
  Scenario Outline: Get delivery options for a DeliveryType in any country
    Given I create a new delivery api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | deliveryType | <delivery_type> |
      | currency     | <currency>       |
      | country      | <country>        |
    When I send a GET request to deliveryOptions endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | [0].type           | <delivery_type>  |
      | [0].price.amount   | <delivery_price> |
      | [0].price.currency | <currency>       |

    Examples:
      | currency | country | delivery_price | delivery_type          |
      | EUR      | IT      | 5.95           | INTERNATIONAL_STANDARD |
      | EUR      | DE      | 5.95           | INTERNATIONAL_STANDARD |
      | EUR      | FR      | 5.95           | INTERNATIONAL_STANDARD |
      | AUD      | AU      | 13.45          | INTERNATIONAL_STANDARD |
      | USD      | US      | 6.78           | INTERNATIONAL_STANDARD |
      | EUR      | IT      | 8.95           | INTERNATIONAL_EXPRESS  |
      | EUR      | DE      | 8.95           | INTERNATIONAL_EXPRESS  |
      | EUR      | FR      | 8.95           | INTERNATIONAL_EXPRESS  |
      | AUD      | AU      | 25.67          | INTERNATIONAL_EXPRESS  |
      | USD      | US      | 14.56          | INTERNATIONAL_EXPRESS  |

  @negative @FULFIL-1107 @ignore @review
  Scenario Outline: Get the possible delivery options for a invalid country and currency
    Given I create a new delivery api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | currency | <currency> |
      | country  | <country>  |
    When I send a GET request to deliveryOptions endpoint
    Then The response status code should be 400
    And make sure the response body contains the <response_body>

    Examples:
      | currency | country | response_body                                                                |
      | GBB      | IT      | getInternationalDeliveryOptions.currency: must match "EUR\|USD\|AUD\|GBP"    |
      | ABC      | US      | getInternationalDeliveryOptions.currency: must match "EUR\|USD\|AUD\|GBP"    |
      | USD      | ZZ      | getInternationalDeliveryOptions.country: must match "IT\|DE\|US\|AU\|GB\|FR" |

#   ===============================================================================================
#    THE POST ENDPOINT FOR THIS DELIVERY OPTIONS API IS IMPLEMENTED UNDER src/test/resources/cucumber/delivery/metapack.feature
#   ===============================================================================================