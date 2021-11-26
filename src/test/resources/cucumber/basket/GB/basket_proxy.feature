@api @basketGB @basketProxyGB
Feature: Test Basket Proxy Api

  @sanity @integration @BASKET-353
  Scenario: REST-Verify creating new Proxy Basket using valid POST request
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/basket_payload.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
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
      | basket.channel           | WEB          |
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

  @sanity @integration @BASKET-353
  Scenario: REST-Verify updating existing Proxy Basket using valid POST request
    Given I have successfully added items to Proxy Basket using basket/basket_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add a json payload using the file basket/append_item_payload.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
#    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                        |
      | 005955 | 3             | Miaroma Relaxing Lavender Sleep Mist Spray 100ml |
      | 001143 | 1             | Holland & Barrett Vitamin D3 250 Tablets 10ug    |
      | 048791 | 3             | Naturtint Root Retouch Crème - Light Blonde 45ml |
    And the following items contains correct status
      | 001143 | ADDED         |
      | 048791 | ADDED       |
    And make sure following attributes exist within response json
      | basket.status      | ACTIVE    |
      | basket.currency    | GBP       |
      | basket.channel     | WEB       |
      | basket.createdDate | [sysDate] |
#     | basket.updatedDate | [sysDate] |
      | basket.uuid        | [GUID]    |

  @sanity @integration @BASKET-353
  Scenario: REST-Verify creating new Proxy Basket using bundled items payload
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/bundled_items_payload.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                |
      | 005606 | 1             | UFIT Protein Drink Chocolate 8 x 310ml   |
      | 077006 | 1             | USN Protein Fuel RTD Chocolate 6 x 500ml |
    And make sure following attributes exist within response json
      | basket.uuid                     | [GUID]       |
      | basket.status                   | ACTIVE       |
      | basket.items[0].skuId           | 005606       |
      | basket.items[0].quantity        | 1            |
      | basket.items[0].size.unit       | Bottles      |
      | basket.items[0].size.value      | 8            |
      | basket.items[0].bundle.id       | [005605]     |
      | basket.items[0].bundle.quantity | [8]          |
      | basket.items[0].category        | food-drink/drinks/protein-drinks |


  @sanity @BASKET-353
  Scenario: REST-Verify fetching existing Proxy basket without bid cookie in header
    Given I have successfully added items to Proxy Basket using basket/basket_payload.json
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
  Scenario: Verify Creating a new Proxy Basket using max item quantity exceeded
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/nonpromo_item_payload.json replacing values
      | items[0].quantity | 32          |
    When I send a POST request to rest endpoint
    Then The response status code should be 200
#    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And the following items contains correct status
      | 039085 | ADDED_MAXQUANTITY  |
      | 042727 | ADDED              |
    And make sure following attributes exist within response json
      | basket.items[0].skuId      | 039085    |
      | basket.items[0].quantity   | 30        |
      | basket.items[0].brand      | holland-barrett |
#      | basket.items[0].category   | vitamins-supplements/supplements/omega-fish-oils/cod-liver-oil|

  @sanity @regression @BASKET-353  @basket_sanity
  Scenario: REST-Verify fetching existing Proxy basket with valid GET Request (bid cookie)
    Given I have successfully added items to Proxy Basket using basket/basket_payload.json
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
  Scenario: REST-Verify response for Invalid GET request for non existing Proxy Basket
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to rest endpoint
    Then The response status code should be 400
    And make sure following attributes exist within response json
      | success | false                                                                      |
      | error   | Missing required configuration, please provide currency, locale and siteId |

  @negative @BASKET-353
  Scenario Outline: REST-Verify sending an Invalid POST request with no siteId/locale info
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
  Scenario: REST-Verify sending valid POST request using QueryParams to Basket Proxy service
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

#    AFTER Implementing FULFIL-2229 ticket, this scenario is obsolete. Can ignore or remove it completely.
  @FULFIL-1428  @FULFIL-2229 @ignore
  Scenario: REST-Verify Creating new Proxy basket by sending POST without basket Items but correct JSessionID
    Given I have successfully added items to ATG Basket using basket/atg_basket_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
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
    Then make sure there are 3 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                      |
      | 013234 | 3             | Grenade Carb Killa Bar Peanut Nutter Bar 60g   |
      | 060188 | 2             | Miaroma Tea Tree Pure Essential Oil 20ml       |
      | 004025 | 1             | Dr Organic Virgin Coconut Oil Skin Lotion 200ml|

  @FULFIL-2231 @FULFIL-2229
  Scenario: Verify Proxy Basket get User Details after a Registered User Logged In
    Given I create a new login api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/rfl/regUser_login_credentials.json
    When I send a POST request to login endpoint
    Then The response status code should be 200
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure following attributes exist within response json
      | message  | Authentication complete    |
      | status   | success                    |

    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    And I add a json payload using the file basket/rfl/rfl_regUser_payload.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And I save the bid from within response header as bid-Cookie
    And make sure there are 2 products in the basket
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


  @vouchers @FULFIL-1390  @basket_sanity
  Scenario: REST-Verify adding valid voucher codes to existing Proxy basket
    Given I have successfully added items to Proxy Basket using basket/promotion_item_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a POST request to rest/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Applied         |
      | responseStatus.result.voucherId | VEGETARIAN10    |
      | basket.coupons[0].alias         | VEGETARIAN10    |
      | basket.coupons[0].description   | Vegetarian 10%  |
      | basket.promotions.promotion     | [Vegetarian 10%, Buy One Get One For a Penny, Buy one, Get one Half Price]|

  @vouchers @negative @FULFIL-1390
  Scenario: Verify adding Invalid Voucher Code to existing Proxy basket using POST
    Given I have successfully added items to Proxy Basket using basket/promotion_item_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    When I send a POST request to rest/voucher/VOUCHER123?currency=GBP&locale=en-GB&siteId=10 endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure following attributes exist within response json
      | responseStatus.result.status    | INVALID_VOUCHER|
      | responseStatus.result.voucherId | VOUCHER123     |

  @vouchers @FULFIL-1390 @basket_sanity
  Scenario: Verify Removing existing Voucher Code from a Proxy basket using DELETE
    Given I have successfully added items to Proxy Basket using basket/promotion_item_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add a json payload using the file basket/no_items_payload.json
    When I send a POST request to rest/voucher/VEGETARIAN10 endpoint
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
    When I send a DELETE request to rest/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And make sure that basket.total is greater than {basketTotalUponVoucher}
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed      |
      | responseStatus.result.voucherId | VEGETARIAN10 |
      | basket.promotions.promotion     | [Buy One Get One For a Penny, Buy one, Get one Half Price] |
    And make sure following attributes doesnot exist within response json
      | basket.coupons                  |              |

  @vouchers @FULFIL-1390
  Scenario: Verify Removing non-existing Voucher Code from a Proxy basket using DELETE
    Given I have successfully added items to Proxy Basket using basket/basket_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add a json payload using the file basket/no_items_payload.json
    When I send a DELETE request to rest/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed      |
      | responseStatus.result.voucherId | VEGETARIAN10 |
    And make sure following attributes doesnot exist within response json
      | basket.coupons                  |              |

# ========================================================================================================== #
#  BASKET PROXY SERVICE GRAPHQL QUERIES SCENARIOS
#  Proxy Basket Base URL: https://preprod-com.hollandandbarrett.net/basket/api/graphql?query=<mutation>
# ========================================================================================================== #
  @BASKET-353 @proxy_graphql
  Scenario: GraphQL-Verify Creating a new Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/proxy/createBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID]   |
      | data.updateItem.basket.locale            | en-GB    |
      | data.updateItem.basket.currency          | GBP      |
      | data.updateItem.basket.subtotal          | [number] |
      | data.updateItem.basket.total             | [number] |
      | data.updateItem.basket.items[0].id       | 003969   |
      | data.updateItem.basket.items[0].name     |          |
      | data.updateItem.basket.items[0].quantity | 2        |
      | data.updateItem.basket.items[0].total    | [number] |


  @regression @BASKET-353 @proxy_graphql @basket_sanity
  Scenario: GraphQL-Verify Querying the existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/proxy/createBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql query in the request query string using basket/proxy/queryBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.basket.id                    | [GUID]   |
      | data.basket.subtotal              | [number] |
      | data.basket.total                 | [number] |
      | data.basket.items[0].id           | 003969   |
      | data.basket.items[0].name         |          |
      | data.basket.items[0].quantity     | 2        |
      | data.basket.items[0].total        | [number] |
      | data.basket.items[0].subtotal     | [number] |
      | data.basket.items[0].unitNowPrice | [number] |
      | data.basket.shipping              |          |

  @regression @BASKET-353 @proxy_graphql @basket_sanity
  Scenario: GraphQL-Verify Applying Voucher code to existing Proxy basket and then Querying it
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Referer      | naveed-test         |
    And I add the graphql mutation in the request query string using basket/proxy/createBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the bid from within response header as bid-Cookie
    And I save the JSESSIONID from within response header as JSession-ID

    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    When I send a POST request to rest/voucher/VEGETARIAN10?currency=GBP&locale=en-GB&siteId=10 endpoint
    Then The response status code should be 200

    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Referer      | naveed-test         |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql query in the request query string using basket/proxy/queryBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.basket.id                    | [GUID]   |
      | data.basket.subtotal              | [number] |
      | data.basket.total                 | [number] |
      | data.basket.items[0].id           | 003969   |
      | data.basket.items[0].name         |          |
      | data.basket.items[0].quantity     | 2        |
      | data.basket.coupons[0].code       | VEGETARIAN10   |
      | data.basket.coupons[0].description| Vegetarian 10% |

  @BASKET-353 @proxy_graphql
  Scenario: GraphQL-Verify Updating 1 item's quantity in an existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Referer      | naveed-test         |
    And I add the graphql mutation in the request query string using basket/proxy/createBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID] |
      | data.updateItem.basket.items[0].id       | 003969 |
      | data.updateItem.basket.items[0].quantity | 2      |
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Referer      | naveed-test         |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql mutation in the request query string using basket/proxy/updateBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID] |
      | data.updateItem.basket.items[0].id       | 003969 |
      | data.updateItem.basket.items[0].quantity | 4      |

#    FOR FOLLOWING TEST, I AM UPDATING THE EXISTING PROXY BASKET BUT AFTER UPDATE ITEM RUN, I GET ALL THE
#    ITEM'S STATUS AS [NOTINBASKET] IN RESPONSE. WHY??
  @FULFIL-2040 @proxy_graphql
  Scenario: GraphQL-Verify Adding/updating multiple items in an existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/proxy/createBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID] |
      | data.updateItem.basket.items[0].id       | 003969 |
      | data.updateItem.basket.items[0].quantity | 2      |
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql mutation in the request query string using basket/proxy/updateMultipleItems_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItems.basket.id                | [GUID] |
      | data.updateItems.basket.items[0].id       | 001993 |
      | data.updateItems.basket.items[0].quantity | 1      |
      | data.updateItems.basket.items[1].id       | 011879 |
      | data.updateItems.basket.items[1].quantity | 1      |
      | data.updateItems.basket.items[2].id       | 003969 |
      | data.updateItems.basket.items[2].quantity | 1      |
      | data.updateItems.basket.items[2].frequency| 4      |
#      | data.updateItems.basket.items[2].period   | null   |

  @BASKET-353 @proxy_graphql
  Scenario: GraphQL-Verify Deleting an items from existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/proxy/createBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql mutation in the request query string using basket/proxy/deleteBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.itemErrors.status | [DELETED] |
      | data.updateItem.basket.id         | [GUID]    |
      | data.updateItem.basket.items      | []        |
      | data.updateItem.basket.total      | 0         |
#      | data.updateItem.basket.subtotal   |   |

  @BASKET-353 @proxy_graphql
  Scenario: GraphQL-Verify Querying non existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql query in the request query string using basket/proxy/queryBasket_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.basket.id       | [GUID] |
      | data.basket.items    | []     |
#      | data.basket.subtotal |        |
#      | data.basket.total    |        |

  @BASKET-353 @negative @proxy_graphql
    Scenario: GraphQL-Verify creating a Proxy Basket using bad (invalid) payload - no items
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql query in the request query string using basket/proxy/invalidBasket_noItems.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors.message | [Request failed with status code 400] |