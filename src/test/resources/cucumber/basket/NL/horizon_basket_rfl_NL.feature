@api @NLbasket @HorizonBasketNL @A2B @Rfl @ignore
Feature: Test NL RFL Card and Coupon

  @sanity @FULFIL-1363 @basket_sanity
  Scenario Outline: Verify Adding <type> RFL card (no coupons) to existing basket
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    When I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a PUT request to v1/horizon/basket/{basketUUID}/card/<rfl-card-number> endpoint
    Then The response status code should be 200
#    And make sure there are 4 products in the basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode   | SUCCESS |
      | basket.reward.memberStatus | <state> |
      | basket.reward.programName  | RFL-UK  |
      | basket.reward.cardNumber   |         |
      | basket.rewardPoints        | [number]|

    Examples:
      | type     | rfl-card-number | state         |
      | ACTIVE   | 2916000000927   | ACTIVE        |
      | INACTIVE | 2910111334490   | NOT_ACTIVATED |

  @sanity @FULFIL-1363
  Scenario: Verify Adding & Deleting an existing RFL card (no coupons) to horizon basket
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    When I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a PUT request to v1/horizon/basket/{basketUUID}/card/2916000000927 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode | SUCCESS |
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a DELETE request to v1/horizon/basket/{basketUUID}/card/2916000000927 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode | REMOVED       |
      | basket.reward.cardNumber | 2916000000927 |

  @negative @FULFIL-1363
  Scenario: Verify Deleting an RFL Card which was never added to horizon basket
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a DELETE request to v1/horizon/basket/{basketUUID}/card/2916000000927 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode | REMOVED       |
      | basket.reward.cardNumber | 2916000000927 |

  @negative @FULFIL-1363
  Scenario Outline: Test adding Invalid RFL cards to existing basket
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    When I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a PUT request to v1/horizon/basket/{basketUUID}/card/<card-number> endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode | INVALID |

    Examples:
      | card-number   |
      | 2919000000999 |
      | abcdefghijklm |
      | 36cdg-ijk-pqr |

  @negative @FULFIL-1369
  Scenario: Verify Adding a valid RFL card to non existing horizon basket
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a PUT request to v1/horizon/basket/b5d644d6-2b78-449d-9800-eeeaf38d3149/card/2916000000927 endpoint
    Then The response status code should be 404

#    ================== RFL CARD + COUPON SCENARIOS ========================

  @sanity @FULFIL-1742 @FULFIL-1844
  Scenario: Verify adding Active RFL Card & Coupon to existing basket
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    And I save the basket.total from within response json as basketTotalBeforeCoupon
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    When I have successfully added an RFL Card 2910003161531 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910003161531 |
      | basket.rewardPoints                               | [number]      |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a PUT request to v1/horizon/basket/{basketUUID}/card/2910003161531/coupon/9815000054899 endpoint
    Then The response status code should be 200
    And make sure that basket.total is less than {basketTotalBeforeCoupon}
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.couponDetails[0].couponNumber       | 9815000054899 |
      | basket.reward.couponDetails[0].couponStatus       | AVAILABLE     |
      | basket.reward.couponDetails[0].couponStartDate    |               |
      | basket.reward.couponDetails[0].couponExpiryDate   |               |
      | basket.reward.couponDetails[0].couponValue.amount | 7.00          |
      | basket.reward.couponDetails[0].couponValue.currency| GBP          |

  @sanity @FULFIL-1742 @basket_sanity
  Scenario: Verify Deleting already added Active RFL Coupon from existing basket
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    And I save the basket.total from within response json as basketTotalBeforeCoupon
    When I have successfully added an RFL Card 2910003161531 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910003161531 |
      | basket.rewardPoints                               | [number]      |
    When I have successfully added an RFL Coupon 9815000054899 to the existing Horizon basket
    And make sure attribute basket.reward.couponDetails[0].couponStatus contains AVAILABLE
    And make sure that basket.total is less than {basketTotalBeforeCoupon}
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a DELETE request to v1/horizon/basket/{basketUUID}/card/2910003161531/coupon/9815000054899 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                   | SUCCESS       |
      | basket.reward.cardNumber                   | 2910003161531 |
      | basket.reward.couponDetails[0].couponNumber| 9815000054899 |
      | basket.reward.couponDetails[0].couponStatus| REMOVED       |

  @sanity @FULFIL-1742 @basket_sanity
  Scenario: Test adding two RFL Coupons to basket then delete one of them
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    And I save the basket.total from within response json as basketTotalBeforeCoupon
    When I have successfully added an RFL Card 2910105102883 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910105102883 |
      | basket.rewardPoints                               | [number]      |
    When I have successfully added an RFL Coupon 9815000102644 to the existing Horizon basket
    And make sure attribute basket.reward.couponDetails[0].couponStatus contains AVAILABLE
    And make sure that basket.total is less than {basketTotalBeforeCoupon}
    And I save the basket.total from within response json as basketTotalUpon1stCoupon
    When I have successfully added an RFL Coupon 9815000030787 to the existing Horizon basket
    And make sure attribute basket.reward.couponDetails[0].couponStatus contains AVAILABLE
    And make sure that basket.total is less than {basketTotalUpon1stCoupon}
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a DELETE request to v1/horizon/basket/{basketUUID}/card/2910105102883/coupon/9815000102644 endpoint
    Then The response status code should be 200
    And make sure that basket.total is less than {basketTotalBeforeCoupon}
    And make sure following attributes exist within response json
      | basket.reward.couponDetails[0].couponNumber      | 9815000030787 |
      | basket.reward.couponDetails[0].couponStatus      | AVAILABLE     |
      | basket.reward.couponDetails[0].applied           | true          |
      | basket.reward.couponDetails[0].couponValue.amount| [number]      |
      | basket.reward.couponDetails[1].couponNumber      | 9815000102644 |
      | basket.reward.couponDetails[1].couponStatus      | REMOVED       |
      | basket.reward.couponDetails[1].applied           | false         |

  @sanity @FULFIL-1742 @basket_sanity
  Scenario: Test adding USED RFL Coupon to basket for a given RFL card
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    And I save the basket.total from within response json as basketTotalBeforeCoupon
    When I have successfully added an RFL Card 2910000000017 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910000000017 |
      | basket.rewardPoints                               | [number]      |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a PUT request to v1/horizon/basket/{basketUUID}/card/2910000000017/coupon/9815900000248 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.couponDetails[0].couponNumber       | 9815900000248 |
      | basket.reward.couponDetails[0].couponStatus       | USED          |
      | basket.reward.couponDetails[0].applied            | false         |

#    Following scenario related to the fact that One customer can have multiple RFL cards
#    And RFL Coupons are associated to a customer (not RFL card), hence we test by applying such a coupon and then
#    changing /updating the RFL card.  IGNORING THIS TEST AS NO TEST DATA AVAILABLE RIGHT NOW [12 Oct 2021]
  @sanity @FULFIL-1873 @ignore
  Scenario: Test adding Coupon belonging to same customer but associated to more than one RFL Card
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    And I save the basket.total from within response json as basketTotalBeforeCoupon
    When I have successfully added an RFL Card 2911986201757 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.cardNumber                          | 2911986201757 |
    When I have successfully added an RFL Coupon 9815000210738 to the existing Horizon basket
    And make sure attribute basket.reward.couponDetails[0].couponStatus contains AVAILABLE
    And make sure that basket.total is less than {basketTotalBeforeCoupon}

    When I have successfully added an RFL Card 2910701191632 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.cardNumber                          | 2910701191632 |
    Then make sure following attributes doesnot exist within response json
      | basket.reward.couponDetails |  |
    When I have successfully added an RFL Coupon 9815000210738 to the existing Horizon basket
    And make sure attribute basket.reward.couponDetails[0].couponStatus contains AVAILABLE
    And make sure that basket.total is less than {basketTotalBeforeCoupon}

  @sanity @FULFIL-1864 @FULFIL-1841 @basket_sanity
  Scenario: Test changing/updating RFL card to basket will also delete already added coupon for old RFL card
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    And I save the basket.total from within response json as basketTotalBeforeCoupon
    When I have successfully added an RFL Card 2910105102883 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910105102883 |
      | basket.rewardPoints                               | [number]      |
    When I have successfully added an RFL Coupon 9815000102644 to the existing Horizon basket
    And make sure attribute basket.reward.couponDetails[0].couponStatus contains AVAILABLE
    And make sure that basket.total is less than {basketTotalBeforeCoupon}
    When I have successfully added an RFL Card 2910003161531 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910003161531 |
      | basket.rewardPoints                               | [number]      |
    Then make sure following attributes doesnot exist within response json
      | basket.reward.couponDetails |  |

  @sanity @FULFIL-1864 @FULFIL-1841 @basket_sanity
  Scenario: Test deleting RFL card from basket will also delete any added coupon for that RFL card
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    And I save the basket.total from within response json as basketTotalBeforeCoupon
    When I have successfully added an RFL Card 2910105102883 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910105102883 |
      | basket.rewardPoints                               | [number]      |
    When I have successfully added an RFL Coupon 9815000102644 to the existing Horizon basket
    And make sure attribute basket.reward.couponDetails[0].couponStatus contains AVAILABLE
    And make sure that basket.total is less than {basketTotalBeforeCoupon}
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a DELETE request to v1/horizon/basket/{basketUUID}/card/2910105102883 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode | REMOVED       |
      | basket.reward.cardNumber | 2910105102883 |
    Then make sure following attributes doesnot exist within response json
      | basket.reward.couponDetails |  |

  @sanity @FULFIL-1742
  Scenario: Test adding Active RFL Card & Coupon exceeding the value of basket
    Given I have successfully added items to Horizon Basket using basket/minimum_basket_value.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    When I have successfully added an RFL Card 2910003161531 to the existing Horizon basket
    And make sure there are 1 products in the basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910003161531 |
      | basket.rewardPoints                               | [number]      |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a PUT request to v1/horizon/basket/{basketUUID}/card/2910003161531/coupon/9815000054899 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.exceeds                             | true          |
      | basket.reward.couponDetails[0].couponNumber       | 9815000054899 |
      | basket.reward.couponDetails[0].couponStatus       | AVAILABLE     |
      | basket.reward.couponDetails[0].couponStartDate    |               |
      | basket.reward.couponDetails[0].couponExpiryDate   |               |
      | basket.reward.couponDetails[0].couponValue.amount | [number]      |
      | basket.reward.couponDetails[0].couponValue.currency| GBP          |

  @sanity @FULFIL-1742
  Scenario: Test adding Active RFL Card with Expired Coupon to existing Horizon basket
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    When I have successfully added an RFL Card 2910000125253 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910000125253 |
      | basket.rewardPoints                               | [number]      |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a PUT request to v1/horizon/basket/{basketUUID}/card/2910000125253/coupon/9815900000200 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.couponDetails[0].couponNumber       | 9815900000200 |
      | basket.reward.couponDetails[0].couponStatus       | EXPIRED       |
      | basket.reward.couponDetails[0].applied            | false         |

  @sanity @FULFIL-1742
  Scenario: Test adding Active RFL Card but with Non Existing Coupon to existing Horizon basket
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    When I have successfully added an RFL Card 2910000125253 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910000125253 |
      | basket.rewardPoints                               | [number]      |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a PUT request to v1/horizon/basket/{basketUUID}/card/2910000125253/coupon/9815900000000 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.couponDetails[0].couponNumber       | 9815900000000 |
      | basket.reward.couponDetails[0].couponStatus       | NOTFOUND      |
      | basket.reward.couponDetails[0].applied            | false         |

  @sanity @FULFIL-1742
  Scenario: Test adding Active RFL Card & Coupon belonging to two diff customers
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_guestUser_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes doesnot exist within response json
      | basket.reward.points |  |
    When I have successfully added an RFL Card 2910000125253 to the existing Horizon basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910000125253 |
      | basket.rewardPoints                               | [number]      |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a PUT request to v1/horizon/basket/{basketUUID}/card/2910000125253/coupon/9815000102644 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.couponDetails[0].couponNumber       | 9815000102644 |
      | basket.reward.couponDetails[0].couponStatus       | NOTFOUND      |
      | basket.reward.couponDetails[0].applied            | false         |

#    ==========================================================================
#     PROXY BASKET ENDPOINT TESTING FOR RFL
#    ==========================================================================

  @proxy_rfl @FULFIL-1805
  Scenario Outline: PROXY-Verify Adding <type> RFL card (no coupons) to Proxy basket
    Given I have successfully added items to Proxy Basket using basket/rfl/rfl_guestUser_payload.json
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a PUT request to rest/card/<rfl-card-number> endpoint
    Then The response status code should be 200
#    And make sure there are 4 products in the basket
    And make sure following attributes exist within response json
      | basket.reward.statusCode   | SUCCESS |
      | basket.reward.memberStatus | <state> |
      | basket.reward.programName  | RFL-UK  |
      | basket.reward.cardNumber   |         |
      | basket.rewardPoints        | [number]|

    Examples:
      | type     | rfl-card-number | state         |
      | ACTIVE   | 2916000000927   | ACTIVE        |
      | INACTIVE | 2910111334490   | NOT_ACTIVATED |

  @proxy_rfl @FULFIL-1805
  Scenario: PROXY-Verify Adding & Deleting an existing RFL card (no coupons) to horizon basket
    Given I have successfully added items to Proxy Basket using basket/rfl/rfl_guestUser_payload.json
#    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
#    Then make sure following attributes doesnot exist within response json
#      | basket.reward.points |  |
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a PUT request to rest/card/2916000000927 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode | SUCCESS |

    Given I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a DELETE request to rest/card/2916000000927 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode | REMOVED       |
      | basket.reward.cardNumber | 2916000000927 |

  @proxy_rfl @FULFIL-1742 @basket_sanity
  Scenario: PROXY-Verify Adding/Removing Active RFL Card & Coupon to Proxy basket
    Given I have successfully added items to Proxy Basket using basket/rfl/rfl_guestUser_payload.json
#    Make a Request to add RFL card
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    When I send a PUT request to rest/card/2910003161531?siteId=10&currency=GBP&locale=en-GB endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910003161531 |
      | basket.rewardPoints                               | [number]      |
#    Make a Request to add RFL Coupon
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a PUT request to rest/card/2910003161531/coupon/9815000054899 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.couponDetails[0].couponNumber       | 9815000054899 |
      | basket.reward.couponDetails[0].couponStatus       | AVAILABLE     |
      | basket.reward.couponDetails[0].couponStartDate    |               |
      | basket.reward.couponDetails[0].couponExpiryDate   |               |
      | basket.reward.couponDetails[0].couponValue.amount | [number]      |
      | basket.reward.couponDetails[0].couponValue.currency| GBP          |
#    Make a Request to Remove RFL Coupon
    And I create a new proxy-basket api request with following headers
      | Content-Type | application/json  |
      | Cookie       | [bid-JSess-Cookie]|
    And I add following attributes in the request query string
      | siteId   | 10    |
      | currency | GBP   |
      | locale   | en-GB |
    When I send a DELETE request to rest/card/2910003161531/coupon/9815000054899 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basket.reward.statusCode                   | SUCCESS       |
      | basket.reward.cardNumber                   | 2910003161531 |
      | basket.reward.couponDetails[0].couponNumber| 9815000054899 |
      | basket.reward.couponDetails[0].couponStatus| REMOVED       |