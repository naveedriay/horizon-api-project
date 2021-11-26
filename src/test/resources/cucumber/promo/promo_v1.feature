@api @promoV1 @Promotions
Feature: Promo_v1.1 Api

  @sanity @regression @PROMO-1
  Scenario: Verify Promo Service successfully fetches promos for PennySale item
    Given I create a new promo api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/promo/penny_sale_payload.json
    When I send a POST request to v1/promotion/calculation endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.items[0].skuId          | 004293                         |
      | data.items[0].promoNames[0]  | Buy One Get One For a Penny    |
      | data.promotions.promotion[0] | Free Standard delivery on Â£25 |
      | data.promotions.promotion[1] | Buy One Get One For a Penny    |

  @sanity @PROMO-1
  Scenario: Verify Promo Service successfully fetches promos for BOGOF item
    Given I create a new promo api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/promo/voucher_codes_payload.json
    When I send a POST request to v1/promotion/calculation endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.voucherCodes.code           | [NOTEMPTY]                       |
      | data.voucherCodes[0].description | 10% Off - Digital Analytics Test |
      | data.promotions[0].promotion     | 10% Off - Digital Analytics Test |
      | data.promotions[1].promotion     | Free Standard delivery on Â£25   |

  @sanity @PROMO-1
  Scenario: Verify fetching apportionment info from Promo service
    Given I create a new promo api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/promo/multiple_promotion_payload.json
    When I send a POST request to v1.1/promotion/calculation?isChainGrouped=true endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.items[0].skuId                 | 001698                                                                  |
      | data.items[0].discount              | 10.88                                                                   |
      | data.items[0].quantity              | 2                                                                       |
      | data.items[0].promoNames            | [Buy One Get One For a Penny]                                           |
      | data.items[0].details.discountChain | [[{type=IBOG, subtotal=10.89, discount=10.88, total=0.01}], null]       |
      | data.items[2].skuId                 | 096685                                                                  |
      | data.items[2].discount              | 1.45                                                                    |
      | data.items[2].total                 | 4.33                                                                    |
      | data.items[2].quantity              | 2                                                                       |
      | data.items[2].promoNames            | [Buy One Get One Half Price on Herbs & Spices]                          |
      | data.items[2].details.total         | [1.44, 2.89]                                                            |
      | data.promotionSummary[0]            | {discount=10.88, promotion=Buy One Get One For a Penny}                 |
      | data.promotionSummary[2]            | {discount=2.99, promotion=FREE STANDARD SHIPPING}                       |
      | data.promotionSummary[1]            | {discount=1.45, promotion=Buy One Get One Half Price on Herbs & Spices} |
