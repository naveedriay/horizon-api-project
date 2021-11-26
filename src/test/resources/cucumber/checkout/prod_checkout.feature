@api @prod_checkout

Feature: Prod Checkout Scenarios

  @guestUser
  Scenario Outline: Verify delivery option <delivery-option> for a Guest User Journey in prod
    Given I have successfully added items to Horizon Basket using basket/prod/prod_nopromo_payload.json
    And I have successfully added vouchercode VEGAN2019 to Horizon basket
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And I save the <delivery-option> optionId from response json as optionID
    And I have successfully selected deliveryOptions Information using checkout/selectDeliveryOptions.graphqls
    And I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    And make sure following attributes exist within response json
      | basket.isStaff               | false     |
      | basket.shipping.discount     | 0.0       |
      | basket.shipping.deliveryType | <delivery-option>|
      | basket.shipping.price        | <delivery-price> |

    Examples:
      | delivery-option   | delivery-price |
      | NEXT_DAY_DELIVERY | 3.99           |
      | STANDARD_DELIVERY | 2.99           |
#      | NOMINATED_DAY     | 3.99           |
#   NOTE: NOMINATED DAY DELIVERY IS DISABLED IN PROD CURRENTLY, HENCE DISABLED ABOVE. ENABLE IT WHEN ITS WORKING.

  @regUser
  Scenario: Test fetching all delivery addresses for a registered user in prod
    Given I have successfully added items to Horizon Basket using basket/prod/prod_regUser_payload.json
    And I have successfully added vouchercode VEGAN2019 to Horizon basket
    When I have successfully added an RFL Card 2916000224378 to the existing Horizon basket
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_prodUser.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryAddress.graphqls replacing values
      | checkoutUUID | {checkoutUUID}  |
    When I send a graphql query to its desired server
    Then The response status code should be 200
#    And make sure there are 6 addresses found for this user
#    And make sure following attributes exist within response json
#      | data.deliveryAddresses                       |[value>1]|
#      | data.deliveryAddresses[0].address.country    | GB      |
#      | data.deliveryAddresses[1].address.country    | GB      |
#      | data.deliveryAddresses[2].address.country    | GB      |
#      | data.deliveryAddresses[3].address.country    | AU      |
#      | data.deliveryAddresses[4].address.country    | US      |
#      | data.deliveryAddresses[5].address.country    | GB      |

  @regUser
  Scenario: Reg User Scenario for RFL Card + Coupon discount checks
    Given I have successfully added items to Horizon Basket using basket/prod/prod_regUser_payload.json
    When I have successfully added an RFL Card 2910226140450 to the existing Horizon basket
#    And I have successfully added an RFL Coupon 9815000344327 to the existing Horizon basket  [COUPON EXPIRED]
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_prodUser.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation_prodUser.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And I save the NEXT_DAY_DELIVERY optionId from response json as optionID
    And I have successfully selected deliveryOptions Information using checkout/selectDeliveryOptions.graphqls
    And I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    And make sure following attributes exist within response json
      | basket.isStaff                                    | false         |
      | basket.reward.statusCode                          | SUCCESS       |
      | basket.reward.memberStatus                        | ACTIVE        |
      | basket.reward.programName                         | RFL-UK        |
      | basket.reward.cardNumber                          | 2910226140450 |
      | basket.rewardPoints                               | 64            |
      | basket.shipping.price                             | 3.99          |
      | basket.shipping.deliveryType                      | NEXT_DAY_DELIVERY |
#      | basket.couponPaymentValue.amount                  | 8.50          |
#      | basket.reward.couponDetails[0].applied            | true          |
#      | basket.reward.couponDetails[0].couponNumber       | 9815000344327 |
#      | basket.reward.couponDetails[0].couponStatus       | AVAILABLE     |
#      | basket.reward.couponDetails[0].couponValue.amount | 8.50          |




