@api @basketGB @HorizonGB @A2B @horizonPUT
Feature: Test Horizon Basket Api - PUT

  @sanity
  Scenario: Verify adding new item to an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/add_item_payload.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
#    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | basket.locale            | en-GB   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | GBP     |
      | basket.channel           | WEB     |
      | horizonSuccess           | true    |
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 005955 | 3             |            |
      | 048791 | 2             |            |
      | 001698 | 2             |            |

  @regression @basket_sanity
  Scenario: Verify append item quantity to an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/append_item_payload.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
#    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 005955 | 3             |            |
      | 048791 | 3             |            |
      | 001143 | 1             |            |
    And the following items contains correct status
      | 001143 | ADDED         |
      | 048791 | UPDATED       |
    And make sure following attributes exist within response json
      | basket.locale            | en-GB     |
      | basket.currency          | GBP       |
      | basket.status            | ACTIVE    |
      | basket.createdDate       | [sysDate] |
      | horizonSuccess           | true      |

#    After BASKET-340 ticket, Basket Orchestrator service is integrated with Promotions service v1.1, which doesn't support
#    any kind of DELIVERY options, hence when Basket (after being applied the delivery options) calls the promotions service
#    it overrides its discount and only cater for shipping discount based on £30 rule (i.e. free if basket.total >= 30)
  @sanity @integration
  Scenario: Verify adding Standard delivery Option to an existing GB basket
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/add_deliveryOption_GB.json replacing values
      |deliveryOption.deliveryType | STANDARD_DELIVERY |
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | basket.locale            | en-GB   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | GBP     |
      | horizonSuccess           | true    |
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | STANDARD_DELIVERY     |
      | basket.shipping.destination  | GB                    |
#      | basket.shipping.price        | 3.95                  |

#    After BASKET-340 ticket, Basket Orchestrator service is integrated with Promotions service v1.1, which doesn't support
#    any kind of DELIVERY options, hence when Basket (after being applied the delivery options) calls the promotions service
#    it overrides its discount and only cater for shipping discount based on £30 rule (i.e. free if basket.total >= 30)
  @FULFIL-1213
  Scenario: Verify basket total got Next Day Delivery Price added for GB Basket
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
#    Then make sure attribute basket.total contains 65.48
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/add_deliveryOption_GB.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | basket.locale            | en-GB   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | GBP     |
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | NEXT_DAY_DELIVERY |
      | basket.shipping.destination  | GB                    |
#      | basket.shipping.price        | 3.95                  |
#      | basket.total                 | 65.48                 | this price should be more than original basket price

#    After BASKET-340 ticket, Basket Orchestrator service is integrated with Promotions service v1.1, which doesn't support
#    International delivery options, hence when Basket (after being applied the delivery options) calls the promotions service
#    it overrides its discount and only cater for shipping discount based on £30 rule (i.e. free if basket.total >= 30)
  @integration @PROBLEM
  Scenario: Verify adding International Standard delivery Option to an existing IT basket
    Given I have successfully added items to Horizon Basket using basket/italian_basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/add_deliveryOption_IT.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And make sure following attributes exist within response json
      | status[0].status         | UPDATED |
      | status[0].skuId          | 001014  |
      | basket.locale            | it-IT   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | EUR     |
    When I GET the current basket using v1/horizon/basket/{basketUUID}?siteId=66 endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | INTERNATIONAL_EXPRESS |
      | basket.shipping.destination  | IT                    |
#      | basket.shipping.price        | 7.95                  |


#locked status has expired, only active and complete exist now.
  @regression @basket_sanity @ignore
  Scenario: Verify remove item's quantity from an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/append_item_payload.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/remove_item_payload.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And the following items contains correct status
      | 048791 | UPDATED       |
      | 005955 | DELETED       |
      | 001143 | DELETED       |
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.locale            | en-GB     |
      | basket.currency          | GBP       |
      | basket.status            | LOCKED    |
      | basket.createdDate       | [sysDate] |
#      | basket.items[0].skuId    | 048791    |
#      | basket.items[0].quantity | 1         |

  @regression @basket_sanity
  Scenario: Verify remove all items from an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And make sure there are 2 products in the basket
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/delete_all_payload.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And the following items contains correct status
      | 048791 | DELETED       |
      | 005955 | DELETED       |
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.locale            | en-GB     |
      | basket.currency          | GBP       |
      | basket.status            | ACTIVE    |
      | basket.createdDate       | [sysDate] |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure an empty basket with no items is returned

#locked status has expired, only active and complete exist now.
  @BASKET-356 @ignore
  Scenario: Verify a LOCKED basket can't be updated using PUT request
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/remove_item_payload.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.locale            | en-GB     |
      | basket.currency          | GBP       |
      | basket.status            | LOCKED    |
      | basket.createdDate       | [sysDate] |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/delete_all_payload.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 409
    And make sure attribute errors[0] contains com.hollandandbarrett.service.basket.exception.ResourceInvalidException: Basket Update: Basket is in a LOCKED status  - can only update Status
    And make sure following attributes exist within response json
      | status    | CONFLICT  |

  @negative
  Scenario: Verify horizon basket Api response for non existing basketId UUID
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/append_item_payload.json
    When I send a PUT request to v1/horizon/basket/b5d644d6-2b78-449d-9800-eeeaf38d3149 endpoint
    Then The response status code should be 404
    And make sure following attributes exist within response json
      | status    | NOT_FOUND           |
      | message   | 404 Not Found from PUT https://hbi-basket-internal-eks.eu-west-1.dev.hbi.systems/api/v1/basket/b5d644d6-2b78-449d-9800-eeeaf38d3149 |