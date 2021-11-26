@api @checkout @paymentCard @payment

Feature: Payment Card Api

  @sanity @FULFIL-1771
  Scenario: Verify adding & retrieving a new payment card using cardId
    Given  I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename checkout/paycard/visa_card_payload.json replacing values
      | userId       | 978582501 |
    When I send a POST request to payments/card endpoint
    Then The response status code should be 200
    And I save the id from within response json as cardId
    And make sure following attributes exist within response json
      | id      | [GUID]   |
      | userId | 978582501 |
    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments/card/{cardId} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | id     | [GUID]    |
      | userId | 978582501 |

  @sanity @FULFIL-1771
  Scenario: Verify retrieving all payment cards for a user using userId
    Given  I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename checkout/paycard/amex_card_payload.json replacing values
      | userId       | 978582501 |
    When I send a POST request to payments/card endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | id     | [GUID]    |
      | userId | 978582501 |
    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments/card?userId=977872768 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | [0].type | amex         |
      | [1].type | mastercard   |

  @sanity @FULFIL-1771
  Scenario: Verify setting preferred Card for a user's existing card
    Given I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments/card?userId=977872768 endpoint
    Then The response status code should be 200
    And I save the [0].id from within response json as cardId
    And I save the [0].token.value from within response json as tokenId
    And make sure following attributes exist within response json
      | [0].type | amex         |
      | [1].type | mastercard   |

    Given  I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename checkout/paycard/update_preferred_card.json replacing values
      | userId       | 977872768 |
      | preferred    | true      |
      | id           | {cardId}  |
      | token.value  | {tokenId} |
    When I send a POST request to payments/card endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | userId       | 977872768 |
      | preferred    | true      |
      | type         | amex      |


  @sanity @FULFIL-1771
  Scenario: Verify deleting all payment cards for a user using DELETE
    Given I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a DELETE request to payments?userId=978582501 endpoint
    Then The response status code should be 200
    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments?userId=978582501 endpoint
    Then The response status code should be 200
    And make sure the response body contains the []

  @sanity @FULFIL-1771
  Scenario: Verify deleting particular payment card for a user using DELETE
    Given  I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file checkout/paycard/amex_card_payload.json
    When I send a POST request to payments/card endpoint
    Then The response status code should be 200
    And I save the id from within response json as cardId
    And make sure following attributes exist within response json
      | id     | [GUID]    |
      | userId | 978582501 |
    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a DELETE request to payments/{cardId} endpoint
    Then The response status code should be 200
    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    And I wait 5 secs before the next step
    When I send a GET request to payments/card?userId=978582501 endpoint
    Then The response status code should be 200
    And make sure the response body contains the []

  @negative @FULFIL-1771
  Scenario: Verify retrieving payment card using non existing cardId
    Given  I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments/card/e20dc6f9-c77a-4281-867b-6a7d631e8b4e endpoint
    Then The response status code should be 404

  @negative @FULFIL-1771
  Scenario: Verify retrieving payment card using non existing userId
    Given  I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments/card?userId=012345678 endpoint
    Then The response status code should be 200
    And make sure the response body contains the []

#    ====================  PAYPAL PAYMENT SCENARIOS ==========================#
#    FOLLOWING SCENARIO WILL SAVE THE PAYPAL PAYMENT DETAILS FOR A REGISTERED USER IN PAYMENT API

  @sanity @FULFIL-2126
  Scenario: Verify adding & retrieving a new Paypal payment using userId
    Given  I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename checkout/paycard/paypal_payment.json replacing values
      | userId       | 978582501 |
    When I send a POST request to payments/paypal endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | id      | [GUID]   |
      | userId | 978582501 |
    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments/paypal?userId=978582501 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | [0].id     | [GUID]    |
      | [0].userId | 978582501 |
      | [0].method | PAYPAL    |

  @sanity @FULFIL-2126
  Scenario: Verify retrieving a paypal payment for a user using payment uuid
    Given  I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename checkout/paycard/paypal_payment.json replacing values
      | userId       | 978582501 |
    When I send a POST request to payments/paypal endpoint
    Then The response status code should be 200
    And I save the id from within response json as paypalId
    And make sure following attributes exist within response json
      | id     | [GUID]    |
      | userId | 978582501 |
    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to /payments/paypal/{paypalId} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | id     | [GUID]    |
      | userId | 978582501 |
      | method | PAYPAL    |

  @sanity @FULFIL-2126
  Scenario: Verify deleting paypal payment detail for a user using DELETE
    Given  I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename checkout/paycard/paypal_payment.json replacing values
      | userId       | 978582501 |
    When I send a POST request to payments/paypal endpoint
    Then The response status code should be 200
    And I save the id from within response json as paypalId
    And make sure following attributes exist within response json
      | id     | [GUID]    |
      | userId | 978582501 |
    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a DELETE request to /payments/{paypalId} endpoint
    Then The response status code should be 200
    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments/paypal?userId=978582501 endpoint
    Then The response status code should be 200
    And make sure the response body contains the []
