@api @prodBasketIE @prodProxyIE
Feature: Test Prod Basket Proxy Api

   @integration @BASKET-353
  Scenario: PROXY REST-Verify creating new Proxy Basket using valid POST request
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/basket_payload.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
#    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                        |
      | 005955 | 3             | Miaroma Relaxing Lavender Sleep Mist Spray 100ml |
      | 048791 | 2             | Naturtint Root Retouch Crème - Light Blonde 45ml |
    And the following items contains correct status
      | 048791 | ADDED         |
      | 005955 | ADDED         |
      | 061187 | NOTFOUND      |
    And make sure following attributes exist within response json
      | basket.status            | ACTIVE       |
      | basket.currency          | GBP          |
      | basket.createdDate       | [sysDate]    |
#      | basket.updatedDate       | [sysDate]    |
      | basket.uuid              | [GUID]       |
      | basket.items[0].skuId    | 048791       |
      | basket.items[0].quantity | 2            |
      | basket.items[0].category | natural-beauty/hair-care/hair-colouring |
      | basket.items[0].brand    | naturtint    |
      | basket.items[1].skuId    | 005955       |
      | basket.items[1].quantity | 3            |
      | basket.items[1].category | natural-beauty/aromatherapy-home |
      | basket.items[1].brand    | miaroma      |
      | basket.shipping          |              |

  @integration @BASKET-353
  Scenario: PROXY REST-Verify updating existing Proxy Basket using valid POST request
    Given I successfully added items to prod Proxy Basket using payload basket/prod/prod_nopromo_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add a json payload using the file basket/prod/prod_append_payload.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                        |
      | 016154 | 2             | Miaroma Relaxing Lavender Sleep Mist Spray 100ml |
      | 012166 | 1             | Holland & Barrett Vitamin D3 250 Tablets 10ug    |
      | 006011 | 1             | Holland & Barrett l-lysine 60 Tablets 1000mg     |
#    And the following items contains correct status
#      | 012166 | ADDED         |
#      | 048791 | ADDED         |
    And make sure following attributes exist within response json
      | basket.status      | ACTIVE    |
      | basket.currency    | GBP       |
      | basket.createdDate | [sysDate] |
#     | basket.updatedDate | [sysDate] |
      | basket.uuid        | [GUID]    |

  @integration @BASKET-353
  Scenario: PROXY REST-Verify creating new Proxy Basket using bundled items payload
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_bundled_payload.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                |
      | 048259 | 1             | UFIT Protein Drink Chocolate 8 x 310ml   |
    And make sure following attributes exist within response json
      | basket.uuid                     | [GUID]       |
      | basket.status                   | ACTIVE       |
      | basket.items[0].skuId           | 048259       |
      | basket.items[0].quantity        | 1            |
      | basket.items[0].size.unit       | Capsules     |
      | basket.items[0].size.value      | 60           |
      | basket.items[0].bundle.id       | [002091]     |
      | basket.items[0].bundle.quantity | [2]          |
      | basket.items[0].category        | vitamins-supplements/supplements/co-enzyme-q10 |


   @BASKET-353
  Scenario: PROXY REST-Verify fetching existing Proxy basket without bid cookie in header
    Given I successfully added items to prod Proxy Basket using payload basket/basket_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
#      | Cookie       | [bid-Cookie]     |
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a GET request to rest endpoint
    Then The response status code should be 200
    And make sure there are 0 products in the basket
    And make sure following attributes exist within response json
#      | horizonSuccess     | true      |
      | status             | []        |
      | basket.status      | ACTIVE    |
      | basket.items       | []        |
      | basket.currency    | GBP       |
      | basket.locale      | en-GB     |
      | basket.createdDate | [sysDate] |
#      | basket.updatedDate | [sysDate] |
      | basket.uuid        | [GUID]    |

  @BASKET-254
  Scenario: PROXY REST-Verify Creating a new Proxy Basket using max item quantity exceeded
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/prod/prod_nopromo_payload.json replacing values
      | items[0].quantity | 32          |
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And the following items contains correct status
      | 016154 | ADDED_MAXQUANTITY  |
      | 006011 | ADDED              |
    And make sure following attributes exist within response json
      | basket.items[0].skuId      | 016154    |
      | basket.items[0].quantity   | 30        |
      | basket.items[0].brand      | holland-barrett |
      | basket.items[0].category   | vitamins-supplements/minerals/calcium|

   @regression @BASKET-353
  Scenario: PROXY REST-Verify fetching existing Proxy basket with valid GET Request (bid cookie)
    Given I successfully added items to prod Proxy Basket using payload basket/basket_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a GET request to rest endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                       |
      | 005955 | 3             | Miaroma Relaxing Lavender Sleep Mist Spray 100ml|
      | 048791 | 2             | Naturtint Root Retouch Crème - Light Blonde 45ml    |

  @negative @BASKET-353
  Scenario: PROXY REST-Verify response for Invalid GET request for non existing Proxy Basket
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to rest endpoint
    Then The response status code should be 400
    And make sure following attributes exist within response json
      | success | false                                                                      |
      | error   | Missing required configuration, please provide currency, locale and siteId |

  @negative @BASKET-353
  Scenario Outline: PROXY REST-Verify sending an Invalid POST request with no siteId/locale info
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/<payload>
    When I send a POST request to rest endpoint
    Then The response status code should be 400
    And make sure following attributes exist within response json
      | success | false                                                                      |
      | error   | Missing required configuration, please provide currency, locale and siteId |

    Examples:
      | payload                 |
      | basket_min_payload.json |
      | empty_payload.json      |

  @BASKET-353
  Scenario: PROXY REST-Verify sending valid POST request using QueryParams to Basket Proxy service
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/no_items_payload.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 0 products in the basket
    And make sure following attributes exist within response json
#      | horizonSuccess     | true      |
      | status             | []        |
      | basket.status      | ACTIVE    |
      | basket.currency    | GBP       |
      | basket.locale      | en-GB     |
      | basket.createdDate | [sysDate] |
#      | basket.updatedDate | [sysDate] |
      | basket.uuid        | [GUID]    |
      | basket.items       | []        |

  @FULFIL-1428
  Scenario: PROXY REST-Verify Creating new Proxy basket by sending POST without basket Items but correct JSessionID
    Given I successfully added items to prod Proxy Basket using payload basket/atg_basket_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
      | Cookie       | [bid-JSess-Cookie]|
    And I add a json payload using the file basket/no_items_payload.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a GET request to rest endpoint
    Then The response status code should be 200
    Then make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                      |
      | 013234 | 3             | Grenade Carb Killa Bar Peanut Nutter Bar 60g   |
      | 004025 | 1             | Dr Organic Virgin Coconut Oil Skin Lotion 200ml|

  @vouchers @FULFIL-1390
  Scenario: PROXY REST-Verify adding valid voucher codes to existing Proxy basket
    Given I successfully added items to prod Proxy Basket using payload basket/prod/prod_promo_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a POST request to rest/voucher/WELCOME20-0110 endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | responseStatus.result.status     | Applied        |
      | responseStatus.result.voucherId  | WELCOME20-0110 |
      | basket.coupons[0].code           | WELCOME20-0110 |
      | basket.coupons[0].description    | Welcome! Here's your 20% off!|
      | basket.promotions.promotion      | [Buy One Get One 1/2 Price, Welcome! Here's your 20% off!]|

  @vouchers @negative @FULFIL-1390  @ignore
  Scenario: Verify adding Invalid Voucher Code to existing Proxy basket using POST
    Given I successfully added items to prod Proxy Basket using payload basket/prod/prod_promo_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    When I send a POST request to rest/voucher/VOUCHER123?currency=GBP&locale=en-GB&siteId=10 endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure following attributes exist within response json
      | responseStatus.result.status    | INVALID_VOUCHER|
      | responseStatus.result.voucherId | VOUCHER123     |

  @vouchers @FULFIL-1390
  Scenario: Verify Removing existing Voucher Code from a Proxy basket using DELETE
    Given I successfully added items to prod Proxy Basket using payload basket/prod/prod_promo_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add a json payload using the file basket/no_items_payload.json
    When I send a POST request to rest/voucher/WELCOME20-0110 endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And I save the basket.total from within response json as basketTotalUponVoucher
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a DELETE request to rest/voucher/WELCOME20-0110 endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And make sure that basket.total is greater than {basketTotalUponVoucher}
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed        |
      | responseStatus.result.voucherId | WELCOME20-0110 |
      | basket.promotions.promotion     | [Buy One Get One 1/2 Price] |
    And make sure following attributes doesnot exist within response json
      | basket.coupons                  |              |
