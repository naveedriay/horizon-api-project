@api @prodBasketIE @prodHybridIE
Feature: Test Prod Hybrid Basket Api

  @regression @BASKET-247
  Scenario: Verify Creating a new Hybrid Basket using POST with valid payload
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/prod/prod_nopromo_payload.json replacing values
      | items[0].quantity | 32          |
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 006011 | 1             |           |
      | 016154 | 30            |           |
    And the following items contains correct status
      | 016154 | ADDED_MAXQUANTITY |
      | 006011 | ADDED             |
    And make sure following attributes exist within response json
      | basket.sessionInfo.JSESSIONID              |           |
      | basket.sessionInfo.NBTY_ORDERID_COOKIE     |           |
      | basket.sessionInfo.NBTY_BASKETITEMS_COOKIE |           |
      | basket.uuid                                | [GUID]    |
      | basket.status                              | ACTIVE    |
      | basket.currency                            | GBP       |
      | basket.locale                              | en-GB     |
      | basket.createdDate                         | [sysDate] |
#      | basket.updatedDate                         | [sysDate] |
      | horizonSuccess                             | true      |
      | atgSuccess                                 | true      |

  @regression @BASKET-247
  Scenario: Testing 1/2 price promotion for a new Hybrid Basket using 2 diff items
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_pennysale_payload.json
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 005790 | 1             |           |
      | 001670 | 1             |           |
    And make sure following attributes exist within response json
      | basket.uuid                  | [GUID]    |
      | basket.items[0].skuId        | 005790    |
      | basket.items[0].images       | [value>1] |
      | basket.items[0].subtotal     | 5.99      |
      | basket.items[0].total        | 0.01      |
      | basket.items[0].promoNames   | [Buy One Get One for a Penny] |
      | basket.items[1].skuId        | 001670    |
      | basket.items[1].subtotal     | 6.99      |
      | basket.items[1].total        | 6.99      |
      | basket.items[1].images       | [value>1] |
      | basket.items[1].promoNames   | [Buy One Get One for a Penny] |
      | basket.subtotal              | 12.98     |
      | basket.total                 | 7.0       |
      | basket.rewardPoints          | 28        |
#      | basket.shipping.discount     |           |
#      | basket.shipping.price        | 2.99      |
# NOTE: The shipping info is now been removed from Basket Orchestrator which was being sent by promo_v1.1

  @regression @FULFIL-1677 @SBPItems
  Scenario: Verify response for SBP items present in hybrid basket
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_sbp_payload.json
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID

    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 046563 | 1             | Veganz Biscuit with Butter Flavour 200g |
      | 009899 | 1             | Iovate Purely Inspired Apple Cider Vinegar with Green Coffee 1500mg 100 Caplets |
    And make sure following attributes exist within response json
      | horizonSuccess                                               | true |
      | basket.items[0].stock_promotion_threshold.enable             | true |
      | basket.items[0].stock_promotion_threshold.sbp_stock_available| true |
      | basket.items[1].stock_promotion_threshold.enable             | true |
      | basket.items[1].stock_promotion_threshold.sbp_stock_available| true |
      | basket.items[0].promoNames | [Buy One Get One 1/2 Price, Short Dated: Expires September 2021]  |
      | basket.items[1].promoNames | [Buy One Get One 1/2 Price, Short Dated: Expires September 2021]  |

  @regression @BASKET-248 @BASKET-306 @FULFIL-1402 @Subscribe
  Scenario: Verify response for Sub&Save items present in hybrid basket
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_sub_save_items_payload.json
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID

    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 000231 | 2             | Holland & Barrett Dried Goji Berries 225g     |
      | 037075 | 1             | Dr Bronner's Baby Unscented Pure-Castile Liquid Soap 946ml  |
    And make sure following attributes exist within response json
      | horizonSuccess                      | true     |
      | basket.subtotal                     |          |
      | basket.total                        |          |
      | basket.items[1].productId           |          |
      | basket.items[1].images              |[value>1] |
      | basket.items[1].available           | true     |
      | basket.items[1].subscribable        | true     |
      | basket.items[1].frequency           | 4        |
      | basket.items[1].period              | 2        |
#      | basket.shipping.price               | 0        |
#      | basket.shipping.discount            | 2.99     |
# NOTE: The shipping info is now been removed from Basket Orchestrator which was being sent by promo_v1.1
# THERE IS BUG IN ATG WHERE IT RETURNS THE (basket.shipping.discount: 0) HAVING A SUB&SAVE ITEM IN BASKET

  @regression @BASKET-248 @BASKET-306 @FULFIL-1402 @Subscribe
  Scenario: Verify Sub&Save wont take effect when frequency & period = 0
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/prod/prod_sub_save_items_payload.json replacing values
      | items[0].period    | 0 |
      | items[0].frequency | 0 |
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And the following items contains correct status
      | 037075 | ADDED         |
      | 000231 | ADDED         |
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID

    Given I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 000231 | 2             | Holland & Barrett Dried Goji Berries 225g     |
      | 037075 | 1             | Dr Bronner's Baby Unscented Pure-Castile Liquid Soap 946ml |
    And make sure following attributes doesnot exist within response json
      | basket.items[0].frequency           |          |
      | basket.items[0].period              |          |
    And make sure following attributes exist within response json
      | horizonSuccess                      | true     |
      | basket.subtotal                     |          |
      | basket.total                        |          |
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
    Given  I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v2/basket/81fa1f5f-f02c-424e-9dcd-7c309b24ea4a endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | horizonSuccess           | false   |
      | atgSuccess               | false   |
      | basketError.errorMessage | JSESSIONID/Basket UUID cannot be null |

  @BASKET-379
  Scenario: Verify fetching existing Hybrid basket by sending non-existing basketUUID & correct JSessionID
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_sub_save_items_payload.json
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID

    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/b5d007d6-2b77-444d-9889-eeeaf38d3456 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | horizonSuccess           | false   |
      | atgSuccess               | true    |
      | basketError.errorMessage | 404 Not Found from GET https://hbi-basket-internal-eks.eu-west-1.prod.hbi.systems/api/v1/basket/b5d007d6-2b77-444d-9889-eeeaf38d3456|

#    This test try to add 3 items using Hybrid Basket
#      - 016154  - available in both ATG & Horizon world           => Result: should get added to both baskets
#      - 061187  - only available in ATG, NotAvailable in Horizon  => Result: not get added to any of baskets
#      - 012713  - Not Available in ATG, only available in Horizon => Result: not get added to any of baskets
  @BASKET-247
  Scenario: Validate already Created Hybrid Basket using GET to ATG & Horizon Basket
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_nopromo_payload.json
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID

    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v1/basket endpoint
    Then The response status code should be 200
#    And make sure there are 3 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                    |
      | 006011 | 1             | Holland & Barrett l-lysine 60 Tablets 1000mg |
      | 016154 | 2             | Grenade Carb Killa Bar Peanut Nutter Bar 60g |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
#    And make sure there are 3 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                    |
      | 016154 | 2             | Grenade Carb Killa Bar Peanut Nutter Bar 60g |
      | 006011 | 1             | Dr Organic Moroccan Argan Oil Day Cream 50ml |


#    This test try to add only 1 item using Hybrid Basket
#      - 012713  - Not Available in ATG, only available in Horizon
#    An Empty basket (both ATG & Horizon Basket) is created but no items are in that basket
#    Try to Populate that basket using existing basket UUID ( VIA PUT Request)

  @BASKET-247
  Scenario: Test Creating Empty Hybrid Basket using UNAVAILABLE item in ATG, then add new item to it
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/hybrid/notAvailable_payload.json
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
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
    And make sure following attributes exist within response json
      | status[0].status | ADDED  |
      | status[0].skuId  | 097652 |

  @regression @BASKET-247
  Scenario: Test updating item quantities on an existing Hybrid Basket using PUT Request
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_nopromo_payload.json
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 006011 | 1             |           |
      | 016154 | 2             |           |
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/prod/update_prod_payload.json replacing values
      | JSESSIONID | {JSessionID}  |
      | uuid       | {basketUUID}  |
    When I send a PUT request to v2/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 006011 | 5             |           |
      | 016154 | 2             |           |

  @negative @BASKET-247
  Scenario: Test updating an item on an existing Hybrid Basket which doesn't exist in that basket
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_nopromo_payload.json
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 006011 | 1             |           |
      | 016154 | 2             |           |
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/hybrid/update_nonexisting_payload.json replacing values
      | JSESSIONID     | {JSessionID} |
      | uuid           | {basketUUID} |
      | items[0].skuId | 009142       |
    When I send a PUT request to v2/basket endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And the following items contains correct status
      | 009142 | ADDED       |
      | 016154 | UPDATED     |
      | 006011 | UPDATED     |

#    When you try to UPDATE item to a corrupt basket JSessionId, it doesn't recognize the basket, hence won't update items
#    Rather it will create a new JSessionID for an empty basket. The corresponding Horizon basket will also be made empty.
#    This test will require rewritten as the Precendence of Hybrid API is changed from ATG to Horizon basket functionality.
#    So even after sending with Corrupt JSessionID, its UUID is valid, hence item added to the basket (just like Horizon)
  @negative @BASKET-247 @BASKET-296
  Scenario: Test updating items on an existing Hybrid Basket with expired/corrupt JSessionID
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_nopromo_payload.json
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 006011 | 1             |           |
      | 016154 | 2             |           |
    Given I create a new basket api request with following headers
      | Content-Type | application/json    |
      | JSESSIONID   |[NonExist-JSessionID]|
    And I add a json payload using filename basket/hybrid/update_nonexisting_payload.json replacing values
      | JSESSIONID | {NonExist-JSessionID} |
      | uuid       | {basketUUID}          |
    When I send a PUT request to v2/basket endpoint
    Then The response status code should be 200
    And the following items contains correct status
      | 006011 | UPDATED |
      | 016154 | UPDATED |
      | 097652 | ADDED   |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
#    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 006011 | 1             |           |
      | 016154 | 2             |           |
      | 097652 | 2             |           |

#   When you try to update item to a corrupt basket uuid, it doesn't recognize the basket
#   Horizon Basket throws a 404
  @negative @BASKET-247
  Scenario: Test updating items on an existing Hybrid Basket with expired/non-existing Basket-UUID
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_nopromo_payload.json
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 006011 | 1             |           |
      | 016154 | 2             |           |
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
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_nopromo_payload.json
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 006011 | 1             |           |
      | 016154 | 2             |           |
    Given I create a new basket api request with following headers
      | Content-Type | application/json   |
    And I add a json payload using filename basket/hybrid/update_nonexisting_payload.json replacing values
      | JSESSIONID | {JSessionID}         |
      | uuid       | {Corrupt-basketUUID} |
    When I send a PUT request to v2/basket endpoint
    Then The response status code should be 400

  @vouchers @regression @BASKET-379
  Scenario: Verify applying valid ORDER LEVEL Voucher code to an existing Hybrid basket using PUT
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_promo_payload.json
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/voucher/WELCOME20-0110 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status     | Applied        |
      | responseStatus.result.voucherId  | WELCOME20-0110 |
      | basket.coupons[0].description    | Welcome! Here's your 20% off! |
      | basket.promotions.promotion      | [Buy One Get One 1/2 Price, Welcome! Here's your 20% off!]|

  @vouchers @regression @BASKET-379
  Scenario: Verify applying valid ITEM LEVEL Voucher code to an existing Hybrid basket using PUT
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_promo_payload.json
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And I save the basket.total from within response json as basketTotalBeforeVoucher
    And make sure there are 2 products in the basket
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/voucher/5665478952412 endpoint
    Then The response status code should be 200
    And make sure that basket.total is less than {basketTotalBeforeVoucher}
    And make sure following attributes exist within response json
      | responseStatus.result.status         | Applied       |
      | responseStatus.result.voucherId      | 5665478952412 |
      | basket.items[0].couponCodes[0].code  | 5665478952412 |
      | basket.promotions.promotion          | [Buy One Get One 1/2 Price, 10% off Vegan]|

  @vouchers @negative @BASKET-379
  Scenario: Verify adding Invalid Voucher Code to existing Hybrid basket using PUT
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_promo_payload.json
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket

    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/voucher/VOUCHER123 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | INVALID_VOUCHER|
      | responseStatus.result.voucherId | VOUCHER123     |

  @vouchers @BASKET-379
  Scenario: Verify Removing existing Voucher Code from a Hybrid basket using DELETE
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_promo_payload.json
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/voucher/WELCOME20-0110 endpoint
    Then The response status code should be 200
    And I save the basket.total from within response json as basketTotalUponVoucher

    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v2/basket/{basketUUID}/voucher/WELCOME20-0110 endpoint
    Then The response status code should be 200
    And make sure that basket.total is greater than {basketTotalUponVoucher}
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed        |
      | responseStatus.result.voucherId | WELCOME20-0110 |
      | basket.promotions.promotion     | [Buy One Get One 1/2 Price] |
    And make sure following attributes doesnot exist within response json
      | basket.coupons                  |               |

  @vouchers @BASKET-379
  Scenario: Verify Removing non-existing Voucher Code from a Hybrid basket using DELETE
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/prod/prod_promo_payload.json
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v2/basket/{basketUUID}/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed      |
      | responseStatus.result.voucherId | VEGETARIAN10 |
    And make sure following attributes doesnot exist within response json
      | basket.coupons                  |              |

