@api @IEbasket @hybridBasketIE @A2B @ignore
Feature: Hybrid Basket Api - Dev

  @basket_sanity @regression @BASKET-247
  Scenario: Verify Creating a new Hybrid Basket using POST with valid payload
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/hybrid/hybrid_basket_payload.json replacing values
      | items[0].quantity | 32          |
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 003969 | 1             |           |
      | 048791 | 30            |           |
    And the following items contains correct status
      | 048791 | ADDED_MAXQUANTITY |
      | 003969 | ADDED             |
    And make sure following attributes exist within response json
      | basket.sessionInfo.JSESSIONID              |           |
      | basket.sessionInfo.NBTY_ORDERID_COOKIE     |           |
      | basket.sessionInfo.NBTY_BASKETITEMS_COOKIE |           |
      | basket.uuid                                | [GUID]    |
      | basket.status                              | ACTIVE    |
      | basket.currency                            | GBP       |
      | basket.locale                              | en-GB     |
      | basket.isStaff                             | false     |
      | basket.promotionalDiscountValue.amount     | [NOTEMPTY]|
      | basket.createdDate                         | [sysDate] |
      | basket.updatedDate                         | [sysDate] |
      | horizonSuccess                             | true      |
      | atgSuccess                                 | true      |

  @sanity @regression @BASKET-247
  Scenario: Verify Creating a new Hybrid Basket using max item quantity exceeded (basic=false & basketType=ATG)
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/markdown_items_payload.json replacing values
      | items[0].quantity | 32          |
    When I send a POST request to v2/basket?basic=false&basketType=ATG endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And the following items contains correct status
      | 009726 | ADDED_MAXQUANTITY |
      | 089710 | ADDED             |
    And make sure following attributes exist within response json
      | basket.items[0].productId                  | 60009726  |
      | basket.items[0].unitWasPrice               | 12.99     |
      | basket.items[0].unitNowPrice               | 11.5      |
      | basket.items[0].subtotal                   | [number]  |
      | basket.items[0].quantity                   | 30        |
      | basket.items[0].images                     | [value>1] |
    And make sure following attributes doesnot exist within response json
      | basket.uuid                                | [GUID]    |
      | basket.isStaff                             | false     |
      | basket.promotionalDiscountValue.amount     | [NOTEMPTY]|


  @FULFIL-1653
  Scenario: Verify fetching hybrid basket info containing delivery restriction skus
    Given I have successfully added items to Hybrid Basket using basket/delivery_restriction_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
#    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | horizonSuccess                      | true     |
      | basket.subtotal                     |          |
      | basket.total                        |          |
      | basket.items[0].shippingRestriction |[value>1] |
      | basket.items[1].shippingRestriction |[value>1] |
      | basket.items[2].shippingRestriction |[value>1] |
      | basket.items[2].shippingRestriction |[EST, FIN, FRA, DEU, GIB, GRC, HUN, ISL, ITA, LVA, LIE, LUX, MLT, NLD, POL, PRT, ROU, SVK, SVN, ESP, SWE, AUT, BEL, BGR, HRV, CZE, DNK] |

#  THIS TEST FOR stock_promotion_threshold, SHOULD ONLY BE RUN WITH PROMO_V2 ENABLED
  @FULFIL-1664 @FULFIL-1677 @basket_sanity
  Scenario: Verify hybrid basket response for valid SBP item in basket
    Given I have successfully added items to Hybrid Basket using basket/SBP_items_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And make sure following attributes exist within response json
      | basket.items[0].unitWasPrice                     |  11.5    |
      | basket.items[0].unitNowPrice                     |  4.5     |
      | basket.items[0].total                            |  4.5     |
      | basket.items[0].stock_promotion_threshold.enable | true     |
      | basket.items[0].stock_promotion_threshold.price  | [number] |
      | basket.items[0].stock_promotion_threshold.stock  | [number] |
      | basket.items[0].stock_promotion_threshold.key    |          |
      | basket.items[0].stock_promotion_threshold.id     |          |
      | basket.items[0].stock_promotion_threshold.sbp_stock_available| true  |

  @BASKET-379
  Scenario: Verify fetching existing Hybrid basket by sending GET to Hybrid Basket api
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 048791 | 2             |Naturtint Root Retouch Crème - Light Blonde 45ml |
      | 003969 | 1             |Dr Organic Moroccan Argan Oil Day Cream 50ml     |
    And make sure following attributes exist within response json
      | basket.uuid                  | [GUID]    |
      | basket.channel               | WEB       |
      | basket.status                | ACTIVE    |
      | basket.items[1].unitWasPrice | [number]  |
      | basket.items[1].unitNowPrice | [number]  |
      | basket.items[1].subtotal     | [number]  |
      | basket.items[1].images       | [value>1] |
      | basket.items[1].available    | true      |
      | basket.items[1].subscribable | true      |
      | basket.items[0].images       | [value>1] |
      | basket.items[0].available    | true      |
      | basket.items[0].subscribable | true      |
      | basket.shipping              |           |
      | basket.isStaff               | false     |
      | basket.hasSubscription       | false     |
      | basket.promotions.promotion  | [Buy one, Get one Half Price] |
#      | basket.shipping.discount     |           |
#      | basket.shipping.price        | 2.99      |
# NOTE: The shipping info is now been removed from Basket Orchestrator which was being sent by promo_v1.1

  @BASKET-379
  Scenario: Verify fetching existing Hybrid basket using bundled items in it
    Given I have successfully added items to Hybrid Basket using basket/bundled_items_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And make sure following attributes exist within response json
      | basket.uuid                     | [GUID]    |
      | basket.items[0].productId       | 60005605  |
      | basket.items[0].skuId           | 005606    |
      | basket.items[0].quantity        | 1         |
      | basket.items[0].size.unit       | Bottles   |
      | basket.items[0].size.value      | 8.0       |
      | basket.items[0].bundle.id       | [005605]  |
      | basket.items[0].bundle.quantity | [8]       |
      | basket.items[0].available       | true      |
      | basket.items[1].subscribable    | true      |

  @sanity @regression @BASKET-248 @BASKET-306 @FULFIL-1402 @Subscribe
  Scenario: Verify response for Sub&Save items present in hybrid basket
    Given I have successfully added items to Hybrid Basket using basket/sub_save_items_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 083171 | 2             | Holland & Barrett Salad Sprinkle 250g |
    And make sure following attributes exist within response json
      | horizonSuccess                      | true     |
      | atgSuccess                          | true     |
      | basket.isStaff                      | false    |
      | basket.total                        |          |
      | basket.hasSubscription              | true     |
      | basket.items[0].productId           |          |
      | basket.items[0].images              |[value>1] |
      | basket.items[0].available           | true     |
      | basket.items[0].subscribable        | true     |
      | basket.items[0].frequency           | 4        |
      | basket.items[0].period              | 2        |
#      | basket.shipping.price               | 0        |
#      | basket.shipping.discount            | 2.99     |
# NOTE: The shipping info is now been removed from Basket Orchestrator which was being sent by promo_v1.1
# THERE IS BUG IN ATG WHERE IT RETURNS THE (basket.shipping.discount: 0) HAVING A SUB&SAVE ITEM IN BASKET

  @sanity @regression @BASKET-248 @BASKET-306 @FULFIL-1402 @Subscribe
  Scenario: Verify Sub&Save wont take effect when frequency & period = 0
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/sub_save_items_payload.json replacing values
      | items[0].period    | 0 |
      | items[0].frequency | 0 |
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And the following items contains correct status
      | 083171 | ADDED         |
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID

    Given I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 083171 | 2             | Holland & Barrett Salad Sprinkle 250g |
    And make sure following attributes doesnot exist within response json
      | basket.items[0].frequency           |          |
      | basket.items[0].period              |          |
    And make sure following attributes exist within response json
      | horizonSuccess                      | true     |
      | atgSuccess                          | true     |
      | basket.isStaff                      | false    |
      | basket.total                        |          |
      | basket.isStaff                      | false    |
      | basket.channel                      | WEB    |
      | basket.hasSubscription              | false    |
      | basket.items[0].productId           |          |
      | basket.items[0].images              | [value>1]|
      | basket.items[0].available           | true     |
      | basket.items[0].subscribable        | true     |
      | basket.shipping                     |          |
#      | basket.shipping.price               |          |
#      | basket.shipping.discount            |          |
# NOTE: The shipping info is now been removed from Basket Orchestrator which was being sent by promo_v1.1

  @BASKET-379
  Scenario: Verify fetching existing Hybrid basket by sending GET without JSessionID but correct basket UUID
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | horizonSuccess           | false   |
      | atgSuccess               | false   |
      | basketError.errorMessage | JSESSIONID/Basket UUID cannot be null |

  @FULFIL-1428 @basket_sanity
  Scenario: Verify Creating new Hybrid basket by sending POST without basket Items but correct JSessionID
    Given I have successfully added items to ATG Basket using basket/atg_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    And I add a json payload using the file basket/no_items_payload.json
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    Then make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                      |
      | 013234 | 3             | Grenade Carb Killa Bar Peanut Nutter Bar 60g   |
      | 060188 | 2             | Miaroma Tea Tree Pure Essential Oil 20ml       |
      | 004025 | 1             | Dr Organic Virgin Coconut Oil Skin Lotion 200ml|

  @BASKET-379
  Scenario: Verify fetching existing Hybrid basket by sending non-existing basketUUID & correct JSessionID
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/b5d007d6-2b77-444d-9889-eeeaf38d3456 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | horizonSuccess           | false   |
      | atgSuccess               | true    |
      | basketError.errorMessage | 404 Not Found from GET https://hbi-basket-internal-eks.eu-west-1.dev.hbi.systems/api/v1/basket/b5d007d6-2b77-444d-9889-eeeaf38d3456|

#    This test try to add 3 items using Hybrid Basket
#      - 048791  - available in both ATG & Horizon world           => Result: should get added to both baskets
#      - 060187  - only available in ATG, NotAvailable in Horizon  => Result: not get added to any of baskets
#      - 012713  - Not Available in ATG, only available in Horizon => Result: not get added to any of baskets
  @BASKET-247
  Scenario: Validate already Created Hybrid Basket using GET to ATG & Horizon Basket
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v1/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                    |
      | 048791 | 2             | Grenade Carb Killa Bar Peanut Nutter Bar 60g |
      | 003969 | 1             | dr-organic-moroccan-argan-oil-day-cream-50ml |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                    |
      | 048791 | 2             | Grenade Carb Killa Bar Peanut Nutter Bar 60g |
      | 003969 | 1             | Mr Organic Balsamic Vinegar 500ml            |


#    This test try to add only 1 item using Hybrid Basket
#      - 012713  - Not Available in ATG, only available in Horizon
#    An Empty basket (both ATG & Horizon Basket) is created but no items are in that basket
#    Try to Populate that basket using existing basket UUID ( VIA PUT Request)

  @BASKET-247
  Scenario: Test Creating Empty Hybrid Basket using UNAVAILABLE item in ATG, then add new item to it
    Given I have successfully added items to Hybrid Basket using basket/hybrid/notAvailable_payload.json
    And make sure following attributes exist within response json
      | status[0].status | NOTFOUND |
      | status[0].skuId  | 061187   |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v1/basket endpoint
    Then The response status code should be 200
    And make sure there are 0 products in the basket
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 0 products in the basket
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/hybrid/update_nonexisting_payload.json replacing values
      | JSESSIONID | {JSessionID}  |
      | uuid       | {basketUUID}  |
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And make sure following attributes exist within response json
      | status[0].status | ADDED  |
      | status[0].skuId  | 097652 |

  @regression @BASKET-247 @basket_sanity
  Scenario: Test updating item quantities on an existing Hybrid Basket using PUT Request
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 003969 | 1             |           |
      | 048791 | 2             |           |
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/hybrid/update_existing_payload.json replacing values
      | JSESSIONID | {JSessionID} |
      | uuid       | {basketUUID}  |
    When I send a PUT request to v2/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 003969 | 5             |           |
      | 048791 | 2             |           |

  @negative @BASKET-247
  Scenario: Test updating an item on an existing Hybrid Basket which doesn't exist in that basket
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 003969 | 1             |           |
      | 048791 | 2             |           |
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/hybrid/update_nonexisting_payload.json replacing values
      | JSESSIONID | {JSessionID}  |
      | uuid       | {basketUUID}  |
    When I send a PUT request to v2/basket endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And the following items contains correct status
      | 097652 | ADDED       |
      | 048791 | UPDATED     |
      | 003969 | UPDATED     |

#    When you try to UPDATE item to a corrupt basket JSessionId, it doesn't recognize the basket, hence won't update items
#    Rather it will create a new JSessionID for an empty basket. The corresponding Horizon basket will also be made empty.
#    This test will require rewritten as the Precendence of Hybrid API is changed from ATG to Horizon basket functionality.
#    So even after sending with Corrupt JSessionID, its UUID is valid, hence item added to the basket (just like Horizon)
   @negative @BASKET-247 @BASKET-296
   Scenario: Test updating items on an existing Hybrid Basket with expired/corrupt JSessionID
     Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
     And make sure there are 2 products in the basket
     And currently basket contains following items
       | skuId  | item_quantity | item_name |
       | 003969 | 1             |           |
       | 048791 | 2             |           |
     Given I create a new basket api request with following headers
       | Content-Type | application/json    |
       | JSESSIONID   |[NonExist-JSessionID]|
     And I add a json payload using filename basket/hybrid/update_nonexisting_payload.json replacing values
       | JSESSIONID | {NonExist-JSessionID} |
       | uuid       | {basketUUID}          |
     When I send a PUT request to v2/basket endpoint
     Then The response status code should be 200
     And the following items contains correct status
       | 048791 | UPDATED |
       | 003969 | UPDATED |
       | 097652 | ADDED   |
     And I create a new basket api request with following headers
       | Content-Type | application/json |
       | Cookie       | [JSession-ID]    |
     When I send a GET request to v2/basket/{basketUUID} endpoint
     Then The response status code should be 200
     And make sure there are 3 products in the basket
     And make sure items total collectively make the basket total
     And make sure items subtotal collectively make the basket subtotal
     And make sure basket total is correctly calculated after applying promotionalDiscountValue
     And currently basket contains following items
       | skuId  | item_quantity | item_name |
       | 003969 | 1             |           |
       | 048791 | 2             |           |
       | 097652 | 2             |           |

#   When you try to update item to a corrupt basket uuid, it doesn't recognize the basket
#   Horizon Basket throws a 404
  @negative @BASKET-247
  Scenario: Test updating items on an existing Hybrid Basket with expired/non-existing Basket-UUID
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 003969 | 1             |           |
      | 048791 | 2             |           |
    Given I create a new basket api request with following headers
      | Content-Type | application/json   |
    And I add a json payload using filename basket/hybrid/update_nonexisting_payload.json replacing values
      | JSESSIONID | {JSessionID}          |
      | uuid       | {NonExist-basketUUID} |
    When I send a PUT request to v2/basket endpoint
    Then The response status code should be 200
    And make sure attribute basketError.errorMessage contains 404 Not Found from PUT
    And make sure following attributes exist within response json
      | horizonSuccess           | false   |
      | atgSuccess               | true    |

  @negative @BASKET-247
  Scenario: Test updating items on an existing Hybrid Basket with corrupt Basket-UUID (non GUID)
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 003969 | 1             |           |
      | 048791 | 2             |           |
    Given I create a new basket api request with following headers
      | Content-Type | application/json   |
    And I add a json payload using filename basket/hybrid/update_nonexisting_payload.json replacing values
      | JSESSIONID | {JSessionID}         |
      | uuid       | {Corrupt-basketUUID} |
    When I send a PUT request to v2/basket endpoint
    Then The response status code should be 400

  @vouchers @regression @BASKET-379
  Scenario: Verify applying valid ORDER LEVEL Voucher code to an existing Hybrid basket using PUT
    Given I have successfully added items to Hybrid Basket using basket/IE_payloads/hybrid_basket_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Applied  |
      | responseStatus.result.voucherId | VEGETARIAN10  |
      | basket.coupons[0].alias         | VEGETARIAN10  |
      | basket.coupons[0].description   | Vegetarian 10% |
      | basket.promotions.promotion     | [Vegetarian 10%, Buy One Get One For a Penny, Buy one, Get one Half Price]|

  @vouchers @regression @BASKET-379
  Scenario: Verify applying valid ITEM LEVEL Voucher code to an existing Hybrid basket using PUT
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | 048841       | 1                |
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 1 products in the basket

    Given I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/voucher/25MANUKA endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And make sure following attributes exist within response json
      | responseStatus.result.status               | Applied        |
      | responseStatus.result.voucherId            | 25MANUKA       |
      | basket.items[0].couponCodes[0].code        | 25MANUKA       |
      | basket.items[0].couponCodes[0].description | Scenario 10h: 25% off 1st Manuka Honey with Coupon  |
      | basket.promotions.promotion                | [Scenario 10h: 25% off 1st Manuka Honey with Coupon]|

  @vouchers @regression @FULFIL-1648 @ignore
  Scenario: Verify applying ONE-TIME Coupon code to an existing Hybrid basket using PUT
    Given I have successfully added items to Hybrid Basket using basket/add_item_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/voucher/344410172412 endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And make sure basket total and subtotal have same value
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Applied      |
      | responseStatus.result.voucherId | 344410172412 |
      | basket.coupons[0].code          | 344410172412 |
      | basket.coupons[0].description   | Scenario 13: 10% Off |
      | basket.promotions.promotion     | [Buy One Get One For a Penny, Scenario 13: 10% Off]|

  @vouchers @regression @FULFIL-1970 @ignore
  Scenario: Verify applying FREE ITEM Coupon code to an existing Hybrid basket using PUT
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | 048771       | 1                |
      | 081030       | 2                |
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.total from within response json as basketTotalBeforeCoupon
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
#    NOW ADD ONE TIME COUPON CODE WHICH WILL ADD A FREE ITEM TO BASKET (IF basket.total >25)
    When I send a PUT request to v2/basket/{basketUUID}/voucher/56781021040 endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure basket total and subtotal have same value
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 013355 | 1             |           |
      | 048771 | 1             |           |
      | 081030 | 2             |           |
#    NOW AMEND THE BASKET BY REDUCING THE basket.total < 25 ( and see if free item stays)
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/hybrid/update_existing_payload.json replacing values
      | JSESSIONID        | {JSessionID}  |
      | uuid              | {basketUUID}  |
      | items[0].skuId    | 081030        |
      | items[0].quantity | 0             |
    When I send a PUT request to v2/basket endpoint
    Then The response status code should be 200
#    MAKE SURE FREE ITEM REMAIN IN BASKET, BUT ITS NOT FREE NOW (original price of item added to basket total)
#    CURRENTLY A BUG TICKET ON OFFER SQUAD FOR THIS [OFFER-445] as item is still free despite not fulfilling promo condition

  @vouchers @negative @BASKET-379
  Scenario: Verify adding Invalid Voucher Code to existing Hybrid basket using PUT
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/voucher/VOUCHER123 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | INVALID_VOUCHER|
      | responseStatus.result.voucherId | VOUCHER123     |

  @vouchers @BASKET-379 @basket_sanity
  Scenario: Verify Removing existing Voucher Code from a Hybrid basket using DELETE
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And I have successfully added vouchercode VEGETARIAN10 to Hybrid basket
    And I save the basket.total from within response json as basketTotalUponVoucher
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v2/basket/{basketUUID}/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure that basket.total is greater than {basketTotalUponVoucher}
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed                       |
      | responseStatus.result.voucherId | VEGETARIAN10                  |
      | basket.promotions.promotion     | [Buy one, Get one Half Price] |
    And make sure following attributes doesnot exist within response json
      | basket.coupons |                |

  @vouchers @BASKET-379 @basket_sanity @ignore
  Scenario: Verify Removing existing ONE-TIME Coupon Code from a Hybrid basket using DELETE
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And I have successfully added vouchercode 344410172412 to Hybrid basket
    And I save the basket.total from within response json as basketTotalUponVoucher
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v2/basket/{basketUUID}/voucher/344410172412 endpoint
    Then The response status code should be 200
    And make sure that basket.total is greater than {basketTotalUponVoucher}
#    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed                      |
      | responseStatus.result.voucherId | 344410172412                  |
      | basket.promotions.promotion     | [Buy one, Get one Half Price] |
    And make sure following attributes doesnot exist within response json
      | basket.coupons |                |

  @vouchers @BASKET-379
  Scenario: Verify Removing non-existing Voucher Code from a Hybrid basket using DELETE
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v2/basket/{basketUUID}/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed      |
      | responseStatus.result.voucherId | VEGETARIAN10 |
    And make sure following attributes doesnot exist within response json
      | basket.coupons |                |

  @sanity @FULFIL-1742 @Rfl
  Scenario: Verify adding/deleting Active RFL Card & Coupon to hybrid basket
    Given I have successfully added items to Hybrid Basket using basket/hybrid/hybrid_basket_payload.json
    When I have successfully added an RFL Card 2910003161531 to the existing Hybrid basket
    And make sure there are 2 products in the basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910003161531 |
      | basket.rewardPoints                               | [number]      |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/card/2910003161531/coupon/9815000054899 endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure basket total and subtotal have same value
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.couponDetails[0].couponNumber       | 9815000054899 |
      | basket.reward.couponDetails[0].couponStatus       | AVAILABLE     |
      | basket.reward.couponDetails[0].couponStartDate    |               |
      | basket.reward.couponDetails[0].couponExpiryDate   |               |
      | basket.reward.couponDetails[0].couponValue.amount | [number]      |
      | basket.reward.couponDetails[0].couponValue.currency| GBP          |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v2/basket/{basketUUID}/card/2910003161531/coupon/9815000054899 endpoint
    Then The response status code should be 200
    And make sure basket total and subtotal have same value
    And make sure following attributes exist within response json
      | basket.reward.statusCode                   | SUCCESS       |
      | basket.reward.cardNumber                   | 2910003161531 |
      | basket.reward.couponDetails[0].couponNumber| 9815000054899 |
      | basket.reward.couponDetails[0].couponStatus| REMOVED       |

    # STAFF Discount is behind a feature switch, which is by default DISABLED on preProd.
    # In order to test this feature, the staff discount should be ENABLED on preProd.
  @regUser @FULFIL-1795
  Scenario: Verify testing 25% staff discount applied to Hybrid basket ( No Promo Items)
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/nonpromo_item_payload.json replacing values
      | customerId   | 958031646        |
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And make sure following attributes exist within response json
      | basket.isStaff               | true   |
      | basket.subtotal              | 15.98  |
      | basket.total                 | 11.98  |
      | basket.promotions.promotion  | [Scenario 1d: 25% off Staff Discount]|


  # STAFF Discount is behind a feature switch, which is by default DISABLED on preProd.
  # In order to test this feature, the staff discount should be ENABLED on preProd.
  @regUser @FULFIL-1795
  Scenario: Verify free shipping for Staff user despite basket total < 25
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_staffUser_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And I save the STANDARD_DELIVERY optionId from response json as optionID
    And I have successfully selected deliveryOptions Information using checkout/selectDeliveryOptions.graphqls
    And I UPDATE the current basket using v1/horizon/basket/{basketUUID} endpoint
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And make sure following attributes exist within response json
      | basket.isStaff               | true              |
      | basket.shipping.deliveryType | STANDARD_DELIVERY |
      | basket.shipping.discount     | 2.99              |
      | basket.shipping.price        | 0.0               |
#      | basket.promotions.promotion  | [Scenario 1d: 25% off Staff Discount, FREE STANDARD SHIPPING FOR EMPLOYEE]|

  # STAFF Discount is behind a feature switch, which is by default DISABLED on preProd.
  # In order to test this feature, the staff discount should be ENABLED on preProd.
  @regUser @FULFIL-1881
  Scenario Outline: Verify Hybrid basket responding with isStaff flag for <staff-status> customerId
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/nonpromo_item_payload.json replacing values
      | customerId   | <customerId>     |
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.isStaff | <isStaff_flag> |

    Examples:
      | staff-status  | customerId | isStaff_flag |
      | non-staff     | 977872768  | false        |
      | staff         | 958031646  | true         |