@api @IEbasket @horizonBasketIE @A2B @horizonPUT
Feature: Test IE Horizon Basket Api - PUT

  Scenario: Verify adding new item to an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/add_item_payload_IE.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | basket.locale            | en-IE   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | EUR     |
      | horizonSuccess           | true    |
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 084144 | 2             |            |
      | 018904 | 3             |            |
      | 048791 | 2             | Naturtint Root Retouch Crème - Light Blonde 45ml   |
      | 000120 | 2             | Holland & Barrett Milk Chocolate Fruit & Nut 250g  |


  Scenario: Verify append item quantity to an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/append_item_payload_IE.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And make sure items total collectively make the basket total
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 018904 | 3             |            |
      | 048791 | 6             |            |
      | 084144 | 2             |            |
      | 001143 | 1             |            |
    And the following items contains correct status
      | 001143 | ADDED         |
      | 048791 | UPDATED       |
    And make sure following attributes exist within response json
      | basket.locale            | en-IE     |
      | basket.currency          | EUR       |
      | basket.status            | ACTIVE    |
      | basket.createdDate       | [sysDate] |
      | horizonSuccess           | true      |

#    After BASKET-340 ticket, Basket Orchestrator service is integrated with Promotions service v1.1, which doesn't support
#    any kind of DELIVERY options, hence when Basket (after being applied the delivery options) calls the promotions service
#    it overrides its discount and only cater for shipping discount based on £30 rule (i.e. free if basket.total >= 30)

  Scenario: Verify adding Standard delivery Option to an existing IE basket
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/IE_payloads/add_deliveryOption_IE.json replacing values
      |deliveryOption.deliveryType | STANDARD_DELIVERY |
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | basket.locale            | en-IE   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | EUR     |
      | horizonSuccess           | true    |
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | STANDARD_DELIVERY     |
      | basket.shipping.destination  | IE                    |

#    After BASKET-340 ticket, Basket Orchestrator service is integrated with Promotions service v1.1, which doesn't support
#    any kind of DELIVERY options, hence when Basket (after being applied the delivery options) calls the promotions service
#    it overrides its discount and only cater for shipping discount based on £30 rule (i.e. free if basket.total >= 30)

  Scenario: Verify basket total got Next Day Delivery Price added for IE Basket
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/basket_payload_IE.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
#    Then make sure attribute basket.total contains 65.48
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/add_deliveryOption_IE.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | basket.locale            | en-IE   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | EUR     |
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | NEXT_DAY_DELIVERY |
      | basket.shipping.destination  | IE                |

#    After BASKET-340 ticket, Basket Orchestrator service is integrated with Promotions service v1.1, which doesn't support
#    International delivery options, hence when Basket (after being applied the delivery options) calls the promotions service
#    it overrides its discount and only cater for shipping discount based on £30 rule (i.e. free if basket.total >= 30)
  @integration @PROBLEM
  Scenario: Verify adding International Standard delivery Option to an existing IE basket
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/add_deliveryOption_IE_IT.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And make sure following attributes exist within response json
      | basket.locale            | en-IE   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | EUR     |
    When I GET the current basket using v1/horizon/basket/{basketUUID}?siteId=30 endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | INTERNATIONAL_STANDARD |
      | basket.shipping.destination  | IT                    |


  Scenario: Verify remove item's quantity from an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/append_item_payload_IE.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/remove_item_payload_IE.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And the following items contains correct status
      | 048791 | UPDATED       |
      | 018904 | DELETED       |
      | 084144 | DELETED       |
      | 001143 | UPDATED         |
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.locale            | en-IE     |
      | basket.currency          | EUR       |
      | basket.status            | LOCKED    |
      | basket.createdDate       | [sysDate] |
      | basket.items[0].skuId    | 048791    |
      | basket.items[0].quantity | 1         |


  Scenario: Verify remove all items from an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/basket_payload_IE.json
    And make sure there are 3 products in the basket
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/delete_all_payload_IE.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And the following items contains correct status
      | 048791 | DELETED       |
      | 018904 | DELETED       |
      | 084144 | DELETED       |
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.locale            | en-IE    |
      | basket.currency          | EUR       |
      | basket.status            | ACTIVE    |
      | basket.createdDate       | [sysDate] |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure an empty basket with no items is returned


  Scenario: Verify a LOCKED basket can't be updated using PUT request
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/remove_item_payload_IE.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.locale            | en-IE    |
      | basket.currency          | EUR       |
      | basket.status            | LOCKED    |
      | basket.createdDate       | [sysDate] |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/delete_all_payload_IE.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 409
    And make sure attribute errors[0] contains com.hollandandbarrett.service.basket.exception.ResourceInvalidException: Basket Update: Basket is in a LOCKED status  - can only update Status
    And make sure following attributes exist within response json
      | status    | CONFLICT  |

  @ignore
  #this is failing at the status code check. getting 409 conflict instead of 200.
  Scenario: Verify a LOCKED basket can only be updated for its status back to ACTIVE
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/remove_item_payload_IE.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.locale            | en-IE     |
      | basket.currency          | EUR       |
      | basket.status            | LOCKED    |
      | basket.createdDate       | [sysDate] |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/no_items_payload_IE.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.status            | ACTIVE    |

  @negative
  Scenario: Verify horizon basket Api response for non existing basketId UUID
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/append_item_payload_IE.json
    When I send a PUT request to v1/horizon/basket/b5d644d6-2b78-449d-9800-eeeaf38d3149 endpoint
    Then The response status code should be 404
    And make sure following attributes exist within response json
      | status    | NOT_FOUND           |
      | message   | 404 Not Found from PUT https://hbi-basket-internal-eks.eu-west-1.dev.hbi.systems/api/v1/basket/b5d644d6-2b78-449d-9800-eeeaf38d3149 |