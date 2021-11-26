@api @NLbasket @basketProxyNL
Feature: Test Basket Proxy Api for NL

  #Converted
  @sanity @integration @BASKET-353
  Scenario: REST-Verify creating new Proxy Basket using valid POST request
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/basket_payload_NL.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                                         |
      | 007745 | 2             | Holland & Barrett Cod Liver Oil Met Vitamine A & D (240 Capsules) |
      | 012160 | 1             | Holland & Barrett Selenium Met Vitamine A, C En E (90 Tabletten)  |
      | 018904 | 3             | holland-barrett-betacaroteen                                      |
    And the following items contains correct status
      | 007745 | ADDED |
      | 012160 | ADDED |
      | 018904 | ADDED |
    And make sure following attributes exist within response json
      | basket.status            | ACTIVE                                                                  |
      | basket.currency          | EUR                                                                     |
      | basket.createdDate       | [sysDate]                                                               |
      | basket.locale            | nl-NL                                                                   |
      | basket.uuid              | [GUID]                                                                  |
      | basket.items[0].skuId    | 007745                                                                  |
      | basket.items[0].quantity | 2                                                                       |
      | basket.items[0].category | vitamines-supplementen/supplementen/visolie-omega/visolie/cod-liver-oil |
      | basket.items[0].brand    | holland-barrett                                                         |
      | basket.items[1].skuId    | 012160                                                                  |
      | basket.items[1].quantity | 1                                                                       |
      | basket.items[1].category | vitamines-supplementen/mineralen/selenium                               |
      | basket.items[1].brand    | holland-barrett                                                         |

   #Converted
  @sanity @integration @BASKET-353
  Scenario: REST-Verify updating existing Proxy Basket using valid POST request
    Given I have successfully added items to Proxy Basket using basket/NL_payloads/basket_payload_NL.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json   |
      | Cookie       | [bid-JSess-Cookie] |
    And I add a json payload using the file basket/NL_payloads/append_item_payload_NL.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                                         |
      | 007745 | 4             | Holland & Barrett Cod Liver Oil Met Vitamine A & D (240 Capsules) |
      | 012160 | 1             | Holland & Barrett Selenium Met Vitamine A, C En E (90 Tabletten)  |
      | 018904 | 3             | holland-barrett-betacaroteen                                      |
    And the following items contains correct status
      | 007745 | UPDATED |

    And make sure following attributes exist within response json
      | basket.status      | ACTIVE    |
      | basket.currency    | EUR       |
      | basket.createdDate | [sysDate] |
      | basket.locale      | nl-NL     |
      | basket.uuid        | [GUID]    |

  #Converted
  @sanity @integration @BASKET-353
  Scenario: REST-Verify creating new Proxy Basket using bundled items payload
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/bundled_items_payload_NL.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                              |
      | 044122 | 1             | PhD Pharma Whey HT+ Bar Double Chocolate 12 x 75g Bars |
    And make sure following attributes exist within response json
      | basket.uuid                     | [GUID]                  |
      | basket.status                   | ACTIVE                  |
      | basket.items[0].skuId           | 044122                  |
      | basket.items[0].quantity        | 1                       |
      | basket.items[0].size.unit       | repen                   |
      | basket.items[0].size.value      | 75                      |
      | basket.items[0].bundle.id       | [042707]                |
      | basket.items[0].bundle.quantity | [12]                    |
      | basket.items[0].category        | sportvoeding/eiwitrepen |

  #Converted
  @sanity @BASKET-353
  Scenario: REST-Verify fetching existing Proxy basket without bid cookie in header
    Given I have successfully added items to Proxy Basket using basket/NL_payloads/basket_payload_NL.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | siteId   | 40    |
      | currency | EUR   |
      | locale   | nl-NL |
    When I send a GET request to rest endpoint
    Then The response status code should be 200
    And make sure there are 0 products in the basket
    And make sure following attributes exist within response json

      | status             | []        |
      | basket.status      | ACTIVE    |
      | basket.items       | []        |
      | basket.currency    | EUR       |
      | basket.locale      | nl-NL     |
      | basket.createdDate | [sysDate] |
      | basket.uuid        | [GUID]    |

    #Converted
  @BASKET-254
  Scenario: Verify Creating a new Proxy Basket using max item quantity exceeded
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/NL_payloads/nonpromo_item_payload_NL.json replacing values
      | items[0].quantity | 32 |
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And the following items contains correct status
      | 010190 | ADDED |
      | 012160 | ADDED |
    And make sure following attributes exist within response json
      | basket.currency          | EUR             |
      | basket.locale            | nl-NL           |
      | basket.items[0].skuId    | 010190          |
      | basket.items[0].quantity | 30              |
      | basket.items[0].brand    | holland-barrett |

 #Converted
  @sanity @regression @BASKET-353  @basket_sanity
  Scenario: REST-Verify fetching existing Proxy basket with valid GET Request (bid cookie)
    Given I have successfully added items to Proxy Basket using basket/NL_payloads/basket_payload_NL.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json   |
      | Cookie       | [bid-JSess-Cookie] |
    And I add following attributes in the request query string
      | siteId   | 40    |
      | currency | EUR   |
      | locale   | nl-NL |
    When I send a GET request to rest endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                                         |
      | 007745 | 2             | Holland & Barrett Cod Liver Oil Met Vitamine A & D (240 Capsules) |
      | 012160 | 1             | Holland & Barrett Selenium Met Vitamine A, C En E (90 Tabletten)  |
      | 018904 | 3             | holland-barrett-betacaroteen                                      |

    #Converted
  @negative @BASKET-353
  Scenario: REST-Verify response for Invalid GET request for non existing Proxy Basket
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to rest endpoint
    Then The response status code should be 400
    And make sure following attributes exist within response json
      | success | false                                                                      |
      | error   | Missing required configuration, please provide currency, locale and siteId |

    #Converted
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

    #Converted
  @BASKET-353
  Scenario: REST-Verify sending valid POST request using QueryParams to Basket Proxy service
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/no_items_payload_NL.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 0 products in the basket
    And make sure following attributes exist within response json
      | status             | []        |
      | basket.status      | ACTIVE    |
      | basket.currency    | EUR       |
      | basket.locale      | nl-NL     |
      | basket.createdDate | [sysDate] |
      | basket.uuid        | [GUID]    |
      | basket.items       | []        |

    #Invalid Scenario
  @FULFIL-1428  @basket_sanity @ignore
  Scenario: REST-Verify Creating new Proxy basket by sending POST without basket Items but correct JSessionID
    Given I have successfully added items to ATG Basket using basket/NL_payloads/atg_basket_payload_NL.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    And I add a json payload using the file basket/NL_payloads/no_items_payload_NL.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    And I add following attributes in the request query string
      | siteId   | 40    |
      | currency | EUR   |
      | locale   | nl-NL |
    When I send a GET request to rest endpoint
    Then The response status code should be 200
    Then make sure there are 3 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                  |
      | 013234 | 3             | Grenade Carb Killa Peanut                  |
      | 060188 | 2             | Miaroma Zoete Amandel Olie 100% Puur 100ml |
      | 004025 | 1             | Dr. Organic Virgin Coconut Oil Skin Lotion |


  @vouchers @FULFIL-1390  @basket_sanity @ignore
  Scenario: REST-Verify adding valid voucher codes to existing Proxy basket
    Given I have successfully added items to Proxy Basket using basket/NL_payloads/promotion_item_payload_NL.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json   |
      | Cookie       | [bid-JSess-Cookie] |
    And I add following attributes in the request query string
      | siteId   | 40    |
      | currency | EUR   |
      | locale   | nl-NL |
    When I send a POST request to rest/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Applied                                                                    |
      | responseStatus.result.voucherId | VEGETARIAN10                                                               |
      | basket.coupons[0].alias         | VEGETARIAN10                                                               |
      | basket.coupons[0].description   | Vegetarian 10%                                                             |
      | basket.promotions.promotion     | [Vegetarian 10%, Buy One Get One For a Penny, Buy one, Get one Half Price] |

  @vouchers @negative @FULFIL-1390 @ignore
  Scenario: Verify adding Invalid Voucher Code to existing Proxy basket using POST
    Given I have successfully added items to Proxy Basket using basket/promotion_item_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json   |
      | Cookie       | [bid-JSess-Cookie] |
    When I send a POST request to rest/voucher/VOUCHER123?currency=GBP&locale=en-GB&siteId=10 endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure following attributes exist within response json
      | responseStatus.result.status    | INVALID_VOUCHER |
      | responseStatus.result.voucherId | VOUCHER123      |

  @vouchers @FULFIL-1390 @basket_sanity @ignore
  Scenario: Verify Removing existing Voucher Code from a Proxy basket using DELETE
    Given I have successfully added items to Proxy Basket using basket/promotion_item_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json   |
      | Cookie       | [bid-JSess-Cookie] |
    And I add a json payload using the file basket/no_items_payload.json
    When I send a POST request to rest/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And I save the basket.total from within response json as basketTotalUponVoucher
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json   |
      | Cookie       | [bid-JSess-Cookie] |
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a DELETE request to rest/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And make sure that basket.total is greater than {basketTotalUponVoucher}
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed                                                    |
      | responseStatus.result.voucherId | VEGETARIAN10                                               |
      | basket.promotions.promotion     | [Buy One Get One For a Penny, Buy one, Get one Half Price] |
    And make sure following attributes doesnot exist within response json
      | basket.coupons |  |

    #Invalid Scenario
  @vouchers @FULFIL-1390 @ignore
  Scenario: Verify Removing non-existing Voucher Code from a Proxy basket using DELETE
    Given I have successfully added items to Proxy Basket using basket/NL_payloads/basket_payload_NL.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json   |
      | Cookie       | [bid-JSess-Cookie] |
    And I add a json payload using the file basket/NL_payloads/no_items_payload_NL.json
    When I send a DELETE request to rest/voucher/DIGITAL endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed |
      | responseStatus.result.voucherId | DIGITAL |
    And make sure following attributes doesnot exist within response json
      | basket.coupons |  |

# ========================================================================================================== #
#  BASKET PROXY SERVICE GRAPHQL QUERIES SCENARIOS
#  Proxy Basket Base URL: https://preprod-com.hollandandbarrett.net/basket/api/graphql?query=<mutation>
# ========================================================================================================== #

  #Converted
  @BASKET-353 @proxy_graphql
  Scenario: GraphQL-Verify Creating a new Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/NL_payloads/proxy_NL/createBasket_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID]   |
      | data.updateItem.basket.locale            | nl-NL    |
      | data.updateItem.basket.currency          | EUR      |
      | data.updateItem.basket.subtotal          | [number] |
      | data.updateItem.basket.total             | [number] |
      | data.updateItem.basket.items[0].id       | 016154   |
      | data.updateItem.basket.items[0].name     |          |
      | data.updateItem.basket.items[0].quantity | 2        |
      | data.updateItem.basket.items[0].total    | [number] |

   #Converted
  @regression @BASKET-353 @proxy_graphql @basket_sanity
  Scenario: GraphQL-Verify Querying the existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/NL_payloads/proxy_NL/createBasket_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql query in the request query string using basket/NL_payloads/proxy_NL/queryBasket_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.basket.id                    | [GUID]   |
      | data.basket.subtotal              | [number] |
      | data.basket.total                 | [number] |
      | data.basket.items[0].id           | 016154   |
      | data.basket.items[0].quantity     | 2        |
      | data.basket.items[0].total        | [number] |
      | data.basket.items[0].subtotal     | [number] |
      | data.basket.items[0].unitNowPrice | [number] |


  #Converted
  @BASKET-353 @proxy_graphql
  Scenario: GraphQL-Verify Updating 1 item's quantity in an existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/NL_payloads/proxy_NL/createBasket_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID] |
      | data.updateItem.basket.items[0].id       | 016154 |
      | data.updateItem.basket.items[0].quantity | 2      |
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql mutation in the request query string using basket/NL_payloads/proxy_NL/updateBasket_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID] |
      | data.updateItem.basket.items[0].id       | 016154 |
      | data.updateItem.basket.items[0].quantity | 4      |
      | data.updateItem.basket.locale            | nl-NL  |
      | data.updateItem.basket.currency          | EUR    |

  #Converted
  @FULFIL-2040 @proxy_graphql
  Scenario: GraphQL-Verify Adding/updating multiple items in an existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/NL_payloads/proxy_NL/createBasket_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID] |
      | data.updateItem.basket.items[0].id       | 016154 |
      | data.updateItem.basket.items[0].quantity | 2      |
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql mutation in the request query string using basket/NL_payloads/proxy_NL/updateMultipleItems_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItems.basket.id                | [GUID] |
      | data.updateItems.basket.items[0].id       | 001250 |
      | data.updateItems.basket.items[0].quantity | 1      |
      | data.updateItems.basket.items[1].id       | 003969 |
      | data.updateItems.basket.items[1].quantity | 1      |
      | data.updateItems.basket.items[2].id       | 001380 |
      | data.updateItems.basket.items[2].quantity | 1      |



  #Converted
  @BASKET-353 @proxy_graphql
  Scenario: GraphQL-Verify Deleting an items from existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/NL_payloads/proxy_NL/createBasket_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql mutation in the request query string using basket/NL_payloads/proxy_NL/deleteBasket_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.itemErrors.status | [DELETED] |
      | data.updateItem.basket.id         | [GUID]    |
      | data.updateItem.basket.items      | []        |
      | data.updateItem.basket.total      | 0         |
      | data.updateItem.basket.locale     | nl-NL     |
      | data.updateItem.basket.currency   | EUR       |

   #Converted
  @BASKET-353 @proxy_graphql
  Scenario: GraphQL-Verify Querying non existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql query in the request query string using basket/NL_payloads/proxy_NL/queryBasket_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.basket.id    | [GUID] |
      | data.basket.items | []     |

    #Converted
  @BASKET-353 @negative @proxy_graphql
  Scenario: GraphQL-Verify creating a Proxy Basket using bad (invalid) payload - no items
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql query in the request query string using basket/NL_payloads/proxy_NL/invalidBasket_noItems_NL.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors.message | [Request failed with status code 400] |