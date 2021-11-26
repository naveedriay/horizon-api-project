@api @NLbasket @HorizonBasketNL @A2B
Feature: Test NL Horizon Basket Api - PUT

  #Converted
  @sanity
  Scenario: Verify adding new item to an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/basket_payload_NL.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/add_item_payload_NL.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | basket.locale            | nl-NL   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | EUR     |
      | horizonSuccess           | true    |
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 007745 | 2             |            |
      | 012160 | 1            |            |
      | 018904 | 3           |            |
      | 001698 | 1           |            |

  #Converted
  @regression @basket_sanity
  Scenario: Verify append item quantity to an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/basket_payload_NL.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/append_item_payload_NL.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And currently basket contains following items
      | skuId  | item_quantity | item_name  |
      | 007745 | 4            |            |
      | 012160 | 1             |            |
      | 018904 | 3             |            |
    And the following items contains correct status
      | 007745 | UPDATED       |
    And make sure following attributes exist within response json
      | basket.locale            | nl-NL     |
      | basket.currency          | EUR       |
      | basket.status            | ACTIVE    |
      | basket.createdDate       | [sysDate] |
      | horizonSuccess           | true      |

  #Converted
  @sanity @integration
  Scenario: Verify adding Standard delivery Option to an existing NL basket
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/basket_payload_NL.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/NL_payloads/add_deliveryOption_NL.json replacing values
      |deliveryOption.deliveryType | STANDARD_DELIVERY |
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | basket.locale            | nl-NL   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | EUR     |
      | horizonSuccess           | true    |
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | STANDARD_DELIVERY     |
      | basket.shipping.destination  | NL                    |

  #Converted
  @FULFIL-1213
  Scenario: Verify basket total got Next Day Delivery Price added for NL Basket
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/basket_payload_NL.json
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/add_deliveryOption_NL.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | basket.locale            | nl-NL   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | EUR     |
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | NEXT_DAY_DELIVERY |
      | basket.shipping.destination  | NL                    |

  #Converted
  @integration @PROBLEM
  Scenario: Verify adding International Standard delivery Option to an existing NL basket
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/basket_payload_NL.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/add_deliveryOption_NL_INT.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And make sure following attributes exist within response json
      | status[0].status         | UPDATED |
      | status[0].skuId          | 018904  |
      | basket.locale            | nl-NL   |
      | basket.uuid              | [GUID]  |
      | basket.currency          | EUR     |
    When I GET the current basket using v1/horizon/basket/{basketUUID}?siteId=66 endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | INTERNATIONAL_EXPRESS |
      | basket.shipping.destination  | NL                    |


  #Converted
  Scenario: Verify remove item's quantity from an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/basket_payload_NL.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/append_item_payload_NL.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/remove_item_payload_NL.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And the following items contains correct status
      | 007745 | UPDATED       |
      | 012160 | DELETED       |
      | 018904 | DELETED       |
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.locale            | nl-NL     |
      | basket.currency          | EUR       |
      | basket.status            | LOCKED    |
      | basket.createdDate       | [sysDate] |

  #Converted
  @regression @basket_sanity
  Scenario: Verify remove all items from an existing basket using PUT request
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/basket_payload_NL.json
    And make sure there are 3 products in the basket
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/delete_all_payload_NL.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And the following items contains correct status
      | 007745 | DELETED       |
      | 012160 | DELETED       |
      | 018904 | DELETED       |
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.locale            | nl-NL     |
      | basket.currency          | EUR       |
      | basket.status            | ACTIVE    |
      | basket.createdDate       | [sysDate] |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure an empty basket with no items is returned

  #Converted
  @BASKET-356
  Scenario: Verify a LOCKED basket can't be updated using PUT request
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/basket_payload_NL.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/remove_item_payload_NL.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | horizonSuccess           | true      |
      | basket.locale            | nl-NL     |
      | basket.currency          | EUR      |
      | basket.status            | LOCKED    |
      | basket.createdDate       | [sysDate] |
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/delete_all_payload_NL.json
    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 409
    And make sure attribute errors[0] contains com.hollandandbarrett.service.basket.exception.ResourceInvalidException: Basket Update: Basket is in a LOCKED status  - can only update Status
    And make sure following attributes exist within response json
      | status    | CONFLICT  |


#  @regression @BASKET-356 @ignore
#  Scenario: Verify a LOCKED basket can only be updated for its status back to ACTIVE
#    Given I have successfully added items to Horizon Basket using basket/NL_payloads/basket_payload_NL.json
#    And I create a new basket api request with following headers
#      | Content-Type | application/json |
#    And I add a json payload using the file basket/NL_payloads/remove_item_payload_NL.json
#    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
#    Then The response status code should be 200
#    And make sure following attributes exist within response json
#      | horizonSuccess           | true      |
#      | basket.locale            | nl-NL    |
#      | basket.currency          | EUR       |
#      | basket.status            | LOCKED    |
#      | basket.createdDate       | [sysDate] |
#    And I create a new basket api request with following headers
#      | Content-Type | application/json |
#    And I add a json payload using the file basket/NL_payloads/no_items_payload_NL.json
#    When I send a PUT request to v1/horizon/basket/{basketUUID} endpoint
#    Then The response status code should be 200
#    And make sure following attributes exist within response json
#      | horizonSuccess           | true      |
#      | basket.status            | ACTIVE    |

  @negative
  Scenario: Verify horizon basket Api response for non existing basketId UUID
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/append_item_payload_NL.json
    When I send a PUT request to v1/horizon/basket/b5d644d6-2b78-449d-9800-eeeaf38d3149 endpoint
    Then The response status code should be 404
    And make sure following attributes exist within response json
      | status    | NOT_FOUND           |
      | message   | 404 Not Found from PUT https://hbi-basket-internal-eks.eu-west-1.dev.hbi.systems/api/v1/basket/b5d644d6-2b78-449d-9800-eeeaf38d3149 |
