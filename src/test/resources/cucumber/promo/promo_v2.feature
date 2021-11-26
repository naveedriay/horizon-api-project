@api @promoV2 @Promotions
Feature: Promo_v2 Api

  @sanity @regression
  Scenario: Verify Promo Service successfully fetches promos for PennySale item
    Given I create a new promo api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/promo/penny_sale_payload.json
    When I send a POST request to v2/promotion/calculation?isChainGrouped=true endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.items[0].skuId                | 004293                      |
      | data.items[0].promoNames[0]        | Buy One Get One For a Penny |
      | data.promotionSummary[0].discount  | 30.86                       |
      | data.promotionSummary[0].promotion | Buy One Get One For a Penny |


  @sanity
  Scenario: Verify Promo Service successfully fetches ORDER LEVEL promos
    Given I create a new promo api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/promo/orderLevel_voucher_payload.json
    When I send a POST request to v2/promotion/calculation endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.items[0].details[0].discountChain.promoName| [Vegetarian 10%] |
      | data.items[0].voucherCodes[]           | []               |
      | data.order.voucherCodes[0].code        | VEGETARIAN10     |
      | data.order.voucherCodes[0].description | Vegetarian 10%   |
      | data.promotionSummary[0].discount      | 3.25             |
      | data.promotionSummary[0].promotion     | Vegetarian 10%   |


  @sanity
  Scenario: Verify Promo Service successfully fetches ITEM LEVEL promos for qualifying item
    Given I create a new promo api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/promo/itemLevel_voucher_payload.json
    When I send a POST request to v2/promotion/calculation endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.items[0].voucherCodes.code           | [20OFF]              |
      | data.items[0].voucherCodes[0].description | Healthy Coupon       |
      | data.items[0].details[0].discountChain.promoName|[Healthy Coupon]|
      | data.items[1].voucherCodes.code           | [20OFF]              |
      | data.items[1].voucherCodes[0].description | Healthy Coupon       |
      | data.items[1].details[0].discountChain.promoName|[Healthy Coupon]|

      | data.order.voucherCodes[]                 | []                   |
      | data.promotionSummary[0].discount         | 4.14                 |
      | data.promotionSummary[0].promotion        | Healthy Coupon       |
