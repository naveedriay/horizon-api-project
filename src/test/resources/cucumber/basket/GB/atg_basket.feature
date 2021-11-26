@api @atgbasket
Feature: Test ATG Basket Api

  @regression
  Scenario: Verify creating new ATG GBP Basket with valid payload json
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/atg_basket_payload.json replacing values
      | items[0].skuId | 012713         |
    When I send a POST request to v1/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure following attributes exist within response json
      | atgSuccess                  | true         |
      | basket.sessionInfo.NBTY_BASKETITEMS_COOKIE | |
      | basket.sessionInfo.NBTY_ORDERID_COOKIE     | |
      | status[0].status            | NOTAVAILABLE |
      | status[1].status            | ADDED        |

  @regression @BASKET-306
  Scenario: Verify ATG Basket response for valid GET request
    Given I have successfully added items to ATG Basket using basket/atg_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v1/basket endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                       |
      | 013234 | 3             | Grenade Carb Killa Bar Peanut Nutter Bar 60g    |
      | 060188 | 2             | Miaroma Tea Tree Pure Essential Oil 20ml        |
      | 004025 | 1             | Dr Organic Virgin Coconut Oil Skin Lotion 200ml |
    And make sure following attributes exist within response json
      | atgSuccess                          | true     |
      | basket.subtotal                     | [number] |
      | basket.total                        | [number] |
      | basket.items[0].productId           |          |
      | basket.items[0].images              | [value>1]|
      | basket.items[0].available           | true     |
      | basket.items[0].subscribable        | true     |
      | basket.items[0].active              | true     |
      | basket.items[0].promoAttractMessage | Add another for half price    |
      | basket.items[0].promoNames          | [Buy One Get One Half Price]  |
#      | basket.items[0].stock_promotion_threshold.enable| true              |

      | basket.items[1].productId           |          |
      | basket.items[1].images              | [value>1]|
      | basket.items[1].available           | true     |
      | basket.items[1].subscribable        | true     |
      | basket.items[1].active              | false    |
      | basket.items[2].productId           |          |
      | basket.items[2].images              | [value>1]|
      | basket.items[2].available           | true     |
      | basket.items[2].subscribable        | true     |
      | basket.items[2].active              | true     |

      | basket.shipping.discount            | 2.99     |
      | basket.shipping.price               |          |

  @regression @promoItems @BASKET-254
  Scenario: Verify ATG Basket's total after adding all types of promotion items
    Given I have successfully added items to ATG Basket using basket/promotion_item_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v1/basket endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                    |
      | 028203 | 2             | Meridian Natural Date Syrup 330g             |
      | 048773 | 1             | Manuka Pharm Manuka Honey MGO 55 250g        |
      | 013234 | 2             | Grenade Carb Killa Bar Peanut Nutter Bar 60g |
#      | 013234 | 3             | Grenade Carb Killa Bar Peanut Nutter Bar 60g |
    And make sure that basket.total is less than basket.subtotal
    And make sure following attributes exist within response json
      | basket.promotions[0].promotion | Buy One Get One Half Price           |
      | basket.promotions[1].promotion | Free Standard delivery on Â£25       |
      | basket.promotions[2].promotion | Scenario 6: Spend 20 in Honey, Jams & Spreads get free syrup as gift |

  @BASKET-254
  Scenario: Verify Creating a new ATG Basket using max item quantity exceeded
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/atg_basket_payload.json replacing values
      | items[0].quantity | 32          |
    When I send a POST request to v1/basket endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And the following items contains correct status
      | 013234 | ADDED_MAXQUANTITY |
      | 060188 | ADDED             |
      | 004025 | ADDED             |
    And make sure following attributes exist within response json
      | atgSuccess                 | true      |
      | basket.sessionInfo         |           |
      | basket.items[0].skuId      | 013234    |
      | basket.items[0].quantity   | 30        |

  @promoItems @BASKET-254
  Scenario: Verify ATG Basket's total after adding all types of non promo items
    Given I have successfully added items to ATG Basket using basket/nonpromo_item_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v1/basket endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.subtotal       | 16.48 |
      | basket.shipping.price | 2.99  |
      | basket.total          | 19.47 |
    And make sure following attributes doesnot exist within response json
      | basket.promotions     |       |

  @vouchers @regression @BASKET-302
  Scenario: Verify adding valid Voucher Code to existing ATG basket using PUT request
    Given I have successfully added items to ATG Basket using basket/atg_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v1/basket/voucher/VEGAN10 endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure that basket.total is less than basket.subtotal
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Applied     |
      | responseStatus.result.voucherId | VEGAN10     |
      | basket.items[0].couponCodes[0].code          | [number]    |
      | basket.items[0].couponCodes[0].description   | Vegan 10%   |
      | basket.promotions.promotion     | [Vegan 10%, Buy One Get One Half Price, Free Standard delivery on Â£25]|

  @vouchers @negative @BASKET-302
  Scenario: Verify adding Invalid Voucher Code to existing ATG basket using PUT request
    Given I have successfully added items to ATG Basket using basket/atg_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v1/basket/voucher/VOUCHER123 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | VoucherNotFound|
      | responseStatus.result.voucherId | VOUCHER123     |

  @vouchers @regression @BASKET-317
  Scenario: Verify Removing existing Voucher Code from a ATG basket using DEL request
    Given I have successfully added items to ATG Basket using basket/atg_basket_payload.json
    And I have successfully added vouchercode VEGETARIAN10 to ATG basket
    And I save the basket.total from within response json as basketTotalUponVoucher
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v1/basket/voucher/VEGETARIAN10 endpoint
    Then The response status code should be 200
    And make sure that basket.total is greater than {basketTotalUponVoucher}
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed     |
      | responseStatus.result.voucherId | VEGETARIAN10|
      | basket.promotions.promotion     | [Free Standard delivery on Â£25] |
    And make sure following attributes doesnot exist within response json
      | basket.coupons |                |

  @vouchers @BASKET-317
  Scenario: Verify Removing non-existing Voucher Code from a ATG basket using DEL request
    Given I have successfully added items to ATG Basket using basket/atg_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v1/basket/voucher/VEGAN10 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | ActivePromotionNotFound |
      | responseStatus.result.voucherId | VEGAN10                 |
    And make sure following attributes doesnot exist within response json
      | basket.coupons |                |



