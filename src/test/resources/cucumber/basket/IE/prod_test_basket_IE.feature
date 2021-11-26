@api @prodTestIE @prodBasketIE
Feature: Test Prod New Hybrid Basket

  @regression @BASKET-247
  Scenario Outline: Verify diff item statuses by adding them to Hybrid Basket
    Given I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | <skuId>      | <quantity> |
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | horizonSuccess | true   |
      | atgSuccess     | true   |
    And the following items contains correct status
      | <skuId>        |<status>|

    Examples:
      | skuId    | quantity   | status            |
      | 004233   | 1          | ADDED             |
      | 036939   | 1          | NOTAVAILABLE      |
      | 048508   | 1          | OUTOFSTOCK        |
      | 016154   | 31         | ADDED_MAXQUANTITY |

  @regression @BASKET-247
  Scenario: Verify Creating a large Hybrid Basket
    Given I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | 007745 | 1 |
      | 012166 | 1 |
      | 093265 | 2 |
      | 004925 | 1 |
      | 049203 | 1 |
      | 003162 | 1 |
      | 005955 | 1 |
      | 016154 | 1 |
      | 040060 | 1 |
      | 042727 | 1 |
      | 004072 | 1 |
      | 018334 | 1 |
      | 010190 | 1 |
      | 017810 | 1 |
      | 001170 | 1 |
      | 006011 | 1 |
      | 004741 | 1 |
      | 001698 | 1 |
      | 035296 | 1 |
      | 086223 | 1 |
      | 001435 | 1 |
      | 030178 | 1 |
      | 012051 | 1 |
      | 004360 | 1 |
      | 012050 | 1 |
      | 084533 | 1 |
      | 005652 | 1 |
      | 017451 | 1 |
      | 001380 | 1 |
      | 007198 | 1 |
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And make sure there are 30 products in the basket
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 30 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal


  @regression @BASKET-247
  Scenario: Testing promotion items for a new Hybrid Basket using 2 diff items
    Given I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | 004360       | 1                |
      | 093265       | 1                |
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 004360 | 1             |           |
      | 093265 | 1             |           |
    And make sure following attributes exist within response json
      | basket.uuid                  | [GUID]    |
      | basket.items[0].skuId        | 004360    |
      | basket.items[0].subtotal     | 11.99     |
      | basket.items[0].total        | 11.99     |
      | basket.items[0].promoNames   | [Buy One Get One 1/2 Price] |
      | basket.items[1].skuId        | 093265    |
      | basket.items[1].subtotal     | 5.99      |
      | basket.items[1].total        | 2.99      |
      | basket.items[1].promoNames   | [Buy One Get One 1/2 Price] |

  @regression @BASKET-247
  Scenario Outline: Test promo attract message for <promotion-type> added to Hybrid basket
    Given I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | <skuId>      |   1              |
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to v2/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes doesnot exist within response json
      | basket.promotions |             |
    And make sure following attributes exist within response json
      | basket.items[0].skuId                 | <skuId>            |
      | basket.items[0].promoNames            | <promotion-type>   |
      | basket.items[0].promoAttractMessage   | <promo-attract-msg>|

    Examples:
      | skuId  | promotion-type              | promo-attract-msg            |
      | 046973 |[Buy One Get One for a Penny]| add another for a penny      |
      | 004360 | [Buy One Get One 1/2 Price] | add another for half price   |
#      | 083612 | [3 for 2]                   | add 2 more to get 1 for free |
      | 014639 | [2 for £4 Mix & Match]      | add 1 more for only £4       |
#      | 036606 | [2 for £1.20 Mix & Match]   | add 1 more for only £1.2     |
#      | 048760 | [Buy One Get One Free]      | add 1 more to get 1 for free |

  @regression @BASKET-247
  Scenario Outline: Test apportionment info for <promotion-type> added to Hybrid basket
    Given I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | <skuId>      |   2              |
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And I save the basket.uuid from within response json as basketUUID
    And I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    And I add following attributes in the request query string
      | apportionment| true             |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | basket.items[0].skuId                                | <skuId>  |
      | basket.items[0].promoAttractMessage                  | [EMPTY]  |
      | basket.items[0].apportionmentDetails[0].discount     | [number] |
      | basket.items[0].apportionmentDetails[0].discountChain|[value>=1]|
      | basket.items[0].promoNames                           | <promotion-type> |
      | basket.promotions.promotion                          | <promotion-type> |

    Examples:
      | skuId  | promotion-type              |
      | 046973 |[Buy One Get One for a Penny]|
      | 004360 | [Buy One Get One 1/2 Price] |
      | 014639 | [2 for £4 Mix & Match]      |
#      | 036606 | [2 for £1.20 Mix & Match]   |
#      | 048760 | [Buy One Get One Free]      |

  @vouchers @regression @BASKET-379
  Scenario Outline: Verify applying valid Voucher code <voucher-code> to an existing Hybrid basket
    Given I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | 006011       | 2                |
      | 004483       | 2                |
    When I send a POST request to v2/basket?basketType=BOTH endpoint
    Then The response status code should be 200
    And I save the basket.total from within response json as basketTotalBeforeVoucher
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket
    And I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/voucher/<voucher-code> endpoint
    Then The response status code should be 200
    And make sure that basket.total is less than {basketTotalBeforeVoucher}
    And I save the basket.total from within response json as basketTotalUponVoucher
    And make sure following attributes exist within response json
      | responseStatus.result.status     | Applied        |
      | responseStatus.result.voucherId  | <voucher-code> |
      | basket.promotions[0].discount    | [number]       |
#      | basket.promotions[0].promotion   | <voucher-msg>  |

    And I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a DELETE request to v2/basket/{basketUUID}/voucher/<voucher-code> endpoint
    Then The response status code should be 200
    And make sure that basket.total is greater than {basketTotalUponVoucher}
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | responseStatus.result.status    | Removed        |
      | responseStatus.result.voucherId | <voucher-code> |

    Examples:
      | voucher-code   | voucher-msg    |
      | WELCOME20-0110 | Welcome! Here's your 20% off! |
#      | SAVE25       | SAVE25         |


  @regression @BASKET-247
  Scenario: Test updating item quantities on an existing Hybrid Basket using PUT Request
    Given I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | 021234       | 1                |
      | 048218       | 2                |
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 021234 | 1             |           |
      | 048218 | 2             |           |
    Given I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    And I add a json payload using filename basket/prod/update_prod_payload.json replacing values
      | JSESSIONID | {JSessionID}  |
      | uuid       | {basketUUID}  |
      | items[0].skuId    | 021234 |
      | items[0].quantity | 4      |
    When I send a PUT request to v2/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And currently basket contains following items
      | skuId  | item_quantity | item_name |
      | 021234 | 5             |           |
      | 048218 | 2             |           |

  @regression @BASKET-247
  Scenario: Test adding RFL card + monetary value coupon to existing basket
    Given I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | 050671       | 1                |
      | 016154       | 2                |
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And I save the basket.total from within response json as basketTotalBeforeCoupon
    And I save the basket.uuid from within response json as basketUUID
    And I save the JSESSIONID from within response header as JSession-ID
    And make sure there are 2 products in the basket

    And I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/card/2910226140450 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910226140450 |
      | basket.rewardPoints                               | [number]      |
    And I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a PUT request to v2/basket/{basketUUID}/card/2910226140450/coupon/9815000356238 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.couponDetails[0].couponNumber       | 9815000356238 |
      | basket.reward.couponDetails[0].couponStatus       | AVAILABLE     |
      | basket.reward.couponDetails[0].couponStartDate    |               |
      | basket.reward.couponDetails[0].couponExpiryDate   |               |
      | basket.reward.couponDetails[0].couponValue.amount | 6.25          |
      | basket.reward.couponDetails[0].couponValue.currency| GBP          |

  @regUser @FULFIL-1795
  Scenario: Verify testing 25% staff discount applied to Hybrid basket ( No Promo Items)
    Given I create a new hybridbasket api request with following headers
      | Content-Type | application/json |
    And I add a json payload to current basket with following items
      | 004606       | 1                |
    And I update following attributes in the basket payload
      | customerId   | 1604655950       |
    When I send a POST request to v2/basket endpoint
    Then The response status code should be 200
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And make sure there are 1 products in the basket
    And make sure following attributes exist within response json
      | basket.isStaff               | true   |
      | basket.subtotal              | 9.99   |
      | basket.total                 | 7.49   |
      | basket.promotions.promotion  | [Staff Discount - 25% off]|
