@api @NLbasket @atgbasketNL
Feature: Test NL ATG Basket Api

  #Converted
  @regression
  Scenario: Verify creating new ATG NL Basket with valid payload json
    Given I create a new atg-basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/NL_payloads/atg_basket_payload_NLv2.json replacing values
      | items[0].skuId | 013234 |
      | items[1].skuId | 004025 |
    When I send a POST request to v1/basket endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | items[0].skuId                             | 013234 |
      | items[1].skuId                             | 004025 |
      | itemUpdateStatusList[0].status             | ADDED  |
      | itemUpdateStatusList[1].status             | ADDED  |


  #Converted
  @regression @BASKET-306
  Scenario: Verify ATG Basket response for valid GET request
    Given I have successfully added items to ATG Basket using basket/NL_payloads/atg_basket_payload_NL.json
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
      | atgSuccess                   | true      |
      | basket.subtotal              | [number]  |
      | basket.total                 | [number]  |
      | basket.items[0].productId    |           |
      | basket.items[0].images       | [value>1] |
      | basket.items[0].available    | true      |
      | basket.items[0].subscribable | true      |
      | basket.items[0].active       | true      |


      | basket.items[1].productId    |           |
      | basket.items[1].images       | [value>1] |
      | basket.items[1].available    | true      |
      | basket.items[1].subscribable | true      |
      | basket.items[1].active       | true      |
      | basket.items[2].productId    |           |
      | basket.items[2].images       | [value>1] |
      | basket.items[2].available    | true      |
      | basket.items[2].subscribable | true      |
      | basket.items[2].active       | true      |

      | basket.shipping.discount     | 2.99      |
      | basket.shipping.price        |           |

    #Converted
  @regression @promoItems @BASKET-254
  Scenario: Verify ATG Basket's total after adding all types of promotion items
    Given I have successfully added items to ATG Basket using basket/promotion_item_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v1/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                            |
      | 073370 | 2             | Naturtint Permanente Haarkleuring 1N Ebbenhout Zwart |
      | 003969 | 2             | Dr. Organic Moroccan Argan Oil Day Cream             |
    And make sure that basket.total is less than basket.subtotal
    And make sure following attributes exist within response json
      | basket.promotions[0].promotion | Buy One Get One For a Penny |
      | basket.promotions[2].promotion | Buy one, Get one Half Price |

  #Converted
  @BASKET-254
  Scenario: Verify Creating a new ATG Basket using max item quantity exceeded
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/NL_payloads/atg_basket_payload_NL.json replacing values
      | items[0].quantity | 32 |
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And the following items contains correct status
      | 013234 | ADDED_MAXQUANTITY |
      | 004025 | ADDED             |
    And make sure following attributes exist within response json
      | basket.currency          | EUR    |
      | basket.locale            | nl-NL  |
      | atgSuccess               | true   |
      | basket.sessionInfo       |        |
      | basket.items[0].skuId    | 013234 |
      | basket.items[0].quantity | 30     |

    #Converted
  @promoItems @BASKET-254
  Scenario: Verify ATG Basket's total after adding all types of non promo items
    Given I have successfully added items to ATG Basket using basket/nonpromo_item_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v1/basket endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.subtotal       | 15.98 |
      | basket.shipping.price | 2.99  |
      | basket.total          | 18.97 |
    And make sure following attributes doesnot exist within response json
      | basket.promotions |  |

    #Converted
  @vouchers @regression @BASKET-302
  Scenario: Verify adding valid Voucher Code to existing ATG basket using PUT request
    Given I have successfully added items to ATG Basket using basket/NL_payloads/atg_basket_payload_NLv2.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v1/basket/voucher/39002 endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure that basket.total is less than basket.subtotal
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Applied |
      | responseStatus.result.voucherId | 39002   |



   #Converted
  @vouchers @negative @BASKET-302
  Scenario: Verify adding Invalid Voucher Code to existing ATG basket using PUT request
    Given I have successfully added items to ATG Basket using basket/NL_payloads/atg_basket_payload_NL.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v1/basket/voucher/VOUCHER123 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | VoucherNotFound |
      | responseStatus.result.voucherId | VOUCHER123      |

     #Converted
  @vouchers @regression @BASKET-317
  Scenario: Verify Removing existing Voucher Code from a ATG basket using DEL request
    Given I have successfully added items to ATG Basket using basket/NL_payloads/atg_basket_payload_NLv2.json
    When I send a PUT request to v1/basket/voucher/VOUCHER123 endpoint
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v1/basket/voucher/39002 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | ActivePromotionNotFound |
      | responseStatus.result.voucherId | 39002                   |
    And make sure following attributes doesnot exist within response json
      | basket.coupons |  |

     #Converted
  @vouchers @BASKET-317
  Scenario: Verify Removing non-existing Voucher Code from a ATG basket using DEL request
    Given I have successfully added items to ATG Basket using basket/NL_payloads/atg_basket_payload_NLv2.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v1/basket/voucher/39002 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | responseStatus.result.status    | ActivePromotionNotFound |
      | responseStatus.result.voucherId | 39002                   |
    And make sure following attributes doesnot exist within response json
      | basket.coupons |  |



