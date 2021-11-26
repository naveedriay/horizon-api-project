@api @IEbasket @basketProxyIE
Feature: Test IE Basket Proxy Api

  Scenario: REST-Verify creating new Proxy Basket using valid POST request
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/basket_payload_IE.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 048791 | 2             |  |
      | 018904 | 3             |  |
      | 084144 | 2             |  |
    And the following items contains correct status
      | 048791 | ADDED         |
      | 018904 | ADDED         |
      | 084144 | ADDED      |
    And make sure following attributes exist within response json
      | basket.status            | ACTIVE       |
      | basket.currency          | EUR          |
      | basket.createdDate       | [sysDate]    |
      | basket.uuid              | [GUID]       |
      | basket.items[0].skuId    | 048791       |
      | basket.items[0].quantity | 2            |
      | basket.items[0].category | natural-beauty/hair-care/hair-colouring |
      | basket.items[0].brand    | naturtint    |
      | basket.items[1].skuId    | 018904       |
      | basket.items[1].quantity | 3            |
      | basket.shipping          |              |

  Scenario: REST-Verify updating existing Proxy Basket using valid POST request
    Given I have successfully added items to Proxy Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add a json payload using the file basket/IE_payloads/append_item_payload_IE.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 048791 | 6             |  |
      | 018904 | 3             |  |
      | 084144 | 2             |  |
      | 001143 | 1             |  |
    And the following items contains correct status
      | 001143 | ADDED         |
      | 048791 | ADDED         |
    And make sure following attributes exist within response json
      | basket.status      | ACTIVE    |
      | basket.currency    | EUR       |
      | basket.createdDate | [sysDate] |
      | basket.uuid        | [GUID]    |

  Scenario: REST-Verify creating new Proxy Basket using bundled items payload
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/bundled_items_payload_IE.json
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
      | basket.currency                 | EUR       |
      | basket.uuid                     | [GUID]       |
      | basket.status                   | ACTIVE       |
      | basket.items[0].skuId           | 005606       |
      | basket.items[0].quantity        | 1            |
      | basket.items[0].size.unit       | Bottles      |
      | basket.items[0].size.value      | 8            |
      | basket.items[0].bundle.id       | [005605]     |
      | basket.items[0].bundle.quantity | [8]          |
      | basket.items[0].category        | food-drink/drinks/protein-drinks |



  Scenario: REST-Verify fetching existing Proxy basket without bid cookie in header
    Given I have successfully added items to Proxy Basket using basket/IE_payloads/append_item_payload_IE.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | siteId   | 30    |
      | currency | EUR   |
      | locale   | en-IE |
    When I send a GET request to rest endpoint
    Then The response status code should be 200
    And make sure there are 0 products in the basket
    And make sure following attributes exist within response json
      | status             | []        |
      | basket.status      | ACTIVE    |
      | basket.items       | []        |
      | basket.currency    | EUR       |
      | basket.locale      | en-IE     |
      | basket.createdDate | [sysDate] |
      | basket.uuid        | [GUID]    |


  Scenario: Verify Creating a new Proxy Basket using max item quantity exceeded
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/IE_payloads/nonpromo_item_payload_IE.json replacing values
      | items[0].quantity | 32          |
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items subtotal collectively make the basket subtotal
    And the following items contains correct status
      | 010190 | ADDED_MAXQUANTITY  |
      | 042727 | ADDED              |
    And make sure following attributes exist within response json
      | basket.items[0].skuId      | 010190    |
      | basket.items[0].quantity   | 30        |
      | basket.items[0].brand      | holland-barrett |


  Scenario: REST-Verify fetching existing Proxy basket with valid GET Request (bid cookie)
    Given I have successfully added items to Proxy Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 30    |
      | currency | EUR   |
      | locale   | en-IE |
    When I send a GET request to rest endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                               |
      | 018904 | 3             | Holland & Barrett BetaCarotene 100 Softgel Capsules 6mg |
      | 048791 | 2             | Naturtint Root Retouch Crème - Light Blonde 45ml        |


  Scenario: REST-Verify response for Invalid GET request for non existing Proxy Basket
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to rest endpoint
    Then The response status code should be 400
    And make sure following attributes exist within response json
      | success | false                                                                      |
      | error   | Missing required configuration, please provide currency, locale and siteId |


  Scenario Outline: REST-Verify sending an Invalid POST request with no siteId/locale info
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/<payload>
    When I send a POST request to rest endpoint
    Then The response status code should be 400
    And make sure following attributes exist within response json
      | success | false                                                                      |
      | error   | Missing required configuration, please provide currency, locale and siteId |

    Examples:
      | payload                 |
      | basket_min_payload_IE.json |
      | empty_payload.json      |


  Scenario: REST-Verify sending valid POST request using QueryParams to Basket Proxy service
    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/no_items_payload_IE.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And make sure there are 0 products in the basket
    And make sure following attributes exist within response json
#      | horizonSuccess     | true      |
      | status             | []        |
      | basket.status      | ACTIVE    |
      | basket.currency    | EUR       |
      | basket.locale      | en-IE     |
      | basket.createdDate | [sysDate] |
#      | basket.updatedDate | [sysDate] |
      | basket.uuid        | [GUID]    |
      | basket.items       | []        |

  Scenario: REST-Verify Creating new Proxy basket by sending POST without basket Items but correct JSessionID
    Given I have successfully added items to ATG Basket using basket/IE_payloads/atg_basket_payload_IE.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    And I add a json payload using the file basket/IE_payloads/no_items_payload_IE.json
    When I send a POST request to rest endpoint
    Then The response status code should be 200
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    And I add following attributes in the request query string
      | siteId   | 30    |
      | currency | EUR   |
      | locale   | en-IE |
    When I send a GET request to rest endpoint
    Then The response status code should be 200
    Then make sure there are 3 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                      |
      | 013234 | 3             | Grenade Carb Killa Bar Peanut Nutter Bar 60g   |
      | 060188 | 2             | Miaroma Tea Tree Pure Essential Oil 20ml       |
      | 004025 | 1             | Dr Organic Virgin Coconut Oil Skin Lotion 200ml|

  @vouchers @FULFIL-1390  @basket_sanity @ignore
    #not converted to IE
  Scenario: REST-Verify adding valid voucher codes to existing Proxy basket
    Given I have successfully added items to Proxy Basket using basket/IE_payloads/promotion_item_payload_IE.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 30    |
      | currency | EUR   |
      | locale   | en-IE |
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

  @vouchers @negative @FULFIL-1390 @ignore
    #not converted to IE
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

  @vouchers @FULFIL-1390 @basket_sanity @ignore
  #not converted to IE
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


  Scenario: Verify Removing non-existing Voucher Code from a Proxy basket using DELETE
    Given I have successfully added items to Proxy Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add a json payload using the file basket/IE_payloads/no_items_payload_IE.json
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
  Scenario: GraphQL-Verify Creating a new Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/IE_payloads/proxy_IE/createBasket_IE.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID]   |
      | data.updateItem.basket.locale            | en-IE    |
      | data.updateItem.basket.currency          | EUR      |
      | data.updateItem.basket.subtotal          | [number] |
      | data.updateItem.basket.total             | [number] |
      | data.updateItem.basket.items[0].id       | 003969   |
      | data.updateItem.basket.items[0].name     |          |
      | data.updateItem.basket.items[0].quantity | 2        |
      | data.updateItem.basket.items[0].total    | [number] |


  Scenario: GraphQL-Verify Querying the existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/IE_payloads/proxy_IE/createBasket_IE.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql query in the request query string using basket/IE_payloads/proxy_IE/queryBasket_IE.graphqls
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


  Scenario: GraphQL-Verify Updating 1 item's quantity in an existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/IE_payloads/proxy_IE/createBasket_IE.graphqls
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
    And I add the graphql mutation in the request query string using basket/IE_payloads/proxy_IE/updateBasket_IE.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID] |
      | data.updateItem.basket.locale            | en-IE  |
      | data.updateItem.basket.currency          | EUR    |
      | data.updateItem.basket.items[0].id       | 003969 |
      | data.updateItem.basket.items[0].quantity | 4      |

#    FOR FOLLOWING TEST, I AM UPDATING THE EXISTING PROXY BASKET BUT AFTER UPDATE ITEM RUN, I GET ALL THE
#    ITEM'S STATUS AS [NOTINBASKET] IN RESPONSE. WHY??
  Scenario: GraphQL-Verify Adding/updating multiple items in an existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/IE_payloads/proxy_IE/createBasket_IE.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.basket.id                | [GUID] |
      | data.updateItem.basket.locale            | en-IE  |
      | data.updateItem.basket.currency          | EUR    |
      | data.updateItem.basket.items[0].id       | 003969 |
      | data.updateItem.basket.items[0].quantity | 2      |
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql mutation in the request query string using basket/IE_payloads/proxy_IE/updateMultipleItems_IE.graphqls
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

  Scenario: GraphQL-Verify Deleting an items from existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql mutation in the request query string using basket/IE_payloads/proxy_IE/createBasket_IE.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the bid from within response header as bid-Cookie
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
      | Cookie       | [bid-Cookie]        |
    And I add the graphql mutation in the request query string using basket/IE_payloads/proxy_IE/deleteBasket_IE.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.updateItem.itemErrors.status | [DELETED] |
      | data.updateItem.basket.id         | [GUID]    |
      | data.updateItem.basket.items      | []        |
      | data.updateItem.basket.total      | 0         |
#      | data.updateItem.basket.subtotal   |   |


  Scenario: GraphQL-Verify Querying non existing Proxy basket using GraphQL Query
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql query in the request query string using basket/IE_payloads/proxy_IE/queryBasket_IE.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.basket.id       | [GUID] |
      | data.basket.items    | []     |
#      | data.basket.subtotal |        |
#      | data.basket.total    |        |


    Scenario: GraphQL-Verify creating a Proxy Basket using bad (invalid) payload - no items
    Given I create a new proxybasket api request with following headers
      | Content-Type | application/graphql |
    And I add the graphql query in the request query string using basket/IE_payloads/proxy_IE/invalidBasket_noItems_IE.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors.message | [Request failed with status code 400] |