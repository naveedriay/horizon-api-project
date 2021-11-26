@api @oldATGBasket
Feature: Test PreProd /rest/api/basket Api

  @ATG-24872
  Scenario: Verify POST by creating a ATG basket using Old PreProd API
    Given I create a new preProd-rest api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/basket_min_payload.json
    When I send a POST request to basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure following attributes exist within response json
      | results[0].status  | ADDED  |
      | results[1].status  | ADDED  |
      | basket[0].quantity | 1      |
      | basket[0].skuId    | 048791 |
      | basket[1].quantity | 1      |
      | basket[1].skuId    | 001014 |

  @regression @ATG-24872
  Scenario: Verify GET for an existing preprod basket just created
    Given I create a new preProd-rest api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/basket_min_payload.json
    When I send a POST request to basket endpoint
    Then The response status code should be 200
    And I save the JSESSIONID from within response header as JSession-ID

    Given I create a new preProd-rest api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to basket endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basketInfo.lineItems[0].productInfo.skuId  | 048791   |
      | basketInfo.lineItems[0].promoNames         | [Buy one, Get one Half Price] |
#      | basketInfo.lineItems[0].promoAttractMessage| Add another for half price   |
      | basketInfo.lineItems[1].productInfo.skuId  | 001014   |
      | basketInfo.orderId                         | [number] |
      | basketInfo.rflPoints                       | [number] |
      | basketInfo.shipping.price                  | 2.99     |
      | basketInfo.subtotal                        | 15.98    |
      | basketInfo.total                           | 18.97    |

  @ATG-24872
  Scenario: Verify PUT for an existing preprod basket just created
    Given I create a new preProd-rest api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/basket_min_payload.json
    When I send a POST request to basket endpoint
    Then The response status code should be 200
    And I save the JSESSIONID from within response header as JSession-ID

    Given I create a new preProd-rest api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    And I add a json payload using filename basket/basket_min_payload.json replacing values
      | items[0].quantity |  2          |
      | items[1].quantity |  2          |
    When I send a PUT request to basket endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | results[0].status  | UPDATED  |
      | results[1].status  | UPDATED  |
      | basket[0].quantity | 2        |
      | basket[1].quantity | 2        |

    Given I create a new preProd-rest api request with following headers
      | Content-Type | application/json |
      | Cookie       | [JSession-ID]    |
    When I send a GET request to basket endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | basketInfo.lineItems[0].productInfo.skuId  | 048791   |
      | basketInfo.lineItems[0].promoNames         | [Buy one, Get one Half Price] |
#      | basketInfo.lineItems[0].promoQualifierMessage| 1 product for 50 %         |
      | basketInfo.lineItems[1].productInfo.skuId  | 001014   |
      | basketInfo.orderId                         | [number] |
      | basketInfo.rflPoints                       | [number] |
      | basketInfo.shipping.price                  | 0        |
      | basketInfo.subtotal                        | [number] |
      | basketInfo.total                           | [number] |