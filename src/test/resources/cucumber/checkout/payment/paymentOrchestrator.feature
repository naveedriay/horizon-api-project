@api @checkout @payment @paymentOrchestrator
Feature: Payment Orchestrator

  @regression @FULFIL-1432 @FULFIL-1726 @checkoutsanity
  Scenario: Verify getting Payment Methods by querying Payment Orchestrator for GB Site
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/getpayment_query_gb.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.getPaymentMethods[0].provider         | adyen                     |
      | data.getPaymentMethods[0].method           | paypalexpress             |
      | data.getPaymentMethods[1].provider         | adyen                     |
      | data.getPaymentMethods[1].method           | scheme                    |
      | data.getPaymentMethods[1].specifics.name   | Credit Card               |
      | data.getPaymentMethods[1].specifics.brands | [visa, mc, amex, maestro] |
      | data.getPaymentMethods[2].provider         | adyen                     |
      | data.getPaymentMethods[2].method           | paypal                    |
      | data.getPaymentMethods[2].specifics.name   | PayPal                    |
      | data.getPaymentMethods[3].provider         | adyen                     |
      | data.getPaymentMethods[3].method           | alipay                    |
      | data.getPaymentMethods[3].specifics.name   | AliPay                    |
      | data.getPaymentMethods[4].provider         | adyen                     |
      | data.getPaymentMethods[4].method           | applepay                  |
      | data.getPaymentMethods[4].specifics.name   | Apple Pay                 |

  @france
  Scenario: Verify getting Payment Methods by querying Payment Orchestrator for FR site
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/getpayment_query_fr.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.getPaymentMethods[0].provider         | adyen                     |
      | data.getPaymentMethods[0].method           | scheme                    |
      | data.getPaymentMethods[0].specifics.name   | Credit Card               |
      | data.getPaymentMethods[0].specifics.type   | scheme                    |
      | data.getPaymentMethods[0].specifics.brands | [visa, mc, amex, maestro] |

  @FULFIL-1196 @FULFIL-1432 @checkoutsanity
  Scenario: Verify making successful Payment using makePayment mutation [card]
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/makePayment_card.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.makePayment.transactionId           | [GUID]       |
      | data.makePayment.paymentId               | [GUID]       |
      | data.makePayment.status                  | AUTHORISED   |
      | data.makePayment.mode.provider           | adyen        |
      | data.makePayment.mode.method             | adyen_scheme |
      | data.makePayment.mode.lastFourCardDigits | 2909         |
      | data.makePayment.mode.expiryDate         | 3/2030       |
      | data.makePayment.money.currency          | GBP          |
      | data.makePayment.money.value             | 176.76       |

  @FULFIL-1196 @FULFIL-1432
  Scenario: Verify making failed Payment using makePayment mutation [card failed]
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/makePayment_cardfail.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.makePayment.transactionId  | [GUID]       |
      | data.makePayment.paymentId      | [GUID]       |
      | data.makePayment.status         | REFUSED      |
      | data.makePayment.mode.provider  | adyen        |
      | data.makePayment.mode.method    | adyen_scheme |
      | data.makePayment.money.currency | GBP          |
      | data.makePayment.money.value    | 176.76       |

  @FULFIL-1196 @FULFIL-1432 @checkoutsanity
  Scenario: Verify making successful Payment using makePayment mutation [paypal]
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/makePayment_paypal.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.makePayment.transactionId | [GUID]     |
      | data.makePayment.paymentId     | [GUID]     |
      | data.makePayment.status        | REDIRECTED |

  @FULFIL-1196 @FULFIL-1432 @checkoutsanity
  Scenario: Verify making successful Payment using makePayment mutation [AliPay]
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/makePayment_alipay.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.makePayment.transactionId | [GUID]     |
      | data.makePayment.paymentId     | [GUID]     |
      | data.makePayment.status        | REDIRECTED |

  @FULFIL-1196 @FULFIL-1432 @checkoutsanity
  Scenario: Verify making failed Payment attempts using used applepay token [ApplePay]
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/makePayment_applepay.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.makePayment.transactionId | [GUID]     |
      | data.makePayment.paymentId     | [GUID]     |
      | data.makePayment.status        | FAILED     |

  @FULFIL-1196 @FULFIL-1432
  Scenario Outline: Verify making failed Payment attempts using <token-type> token [ApplePay]
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/makePayment_applepayfail.graphqls replacing values
      | applePayToken | <applyPayToken>    |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.makePayment.transactionId | [GUID]     |
      | data.makePayment.paymentId     | [GUID]     |
      | data.makePayment.status        | FAILED     |

    Examples:
      | token-type   | applyPayToken  |
      | empty        |                |
      | incorrect    | 1234567890     |

  @FULFIL-1577 @checkFAILEDoutsanity
  Scenario: Verify making confirmPayment mutation on a fresh payment ( Card 3DS)
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/makePayment_card3DS.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the data.makePayment.transactionId from within response json as transactionId
    And I save the data.makePayment.paymentId from within response json as paymentId

    And I create a new payment api request with following headers
      | Content-Type  | application/graphql|
    And I add a graphql payload using filename checkout/payment/confirmPayment.graphqls replacing values
      | transactionId | {transactionId}    |
      | paymentId     | {paymentId}        |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.confirmPayment.status| FAILED |

  @FULFIL-1577
  Scenario: Verify confirmPayment throws error for already Settled Transaction
    Given I have successfully added items to Horizon Basket using basket/all_promotions_payload.json
    And I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/makePayment_card.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the data.makePayment.transactionId from within response json as transactionId

    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/requestSettleTransaction.graphqls replacing values
      | transactionId | {transactionId}    |
      | orderId       | 9000007537         |
      | basketTotal   | {basketTotal}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.requestSettle.payments[0].paymentId    | [GUID]           |
      | data.requestSettle.payments[0].status       | SETTLE_REQUESTED |
    And I save the data.requestSettle.payments[0].paymentId from within response json as paymentId

    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/confirmPayment_error.graphqls replacing values
      | transactionId | {transactionId}    |
      | paymentId     | {paymentId}        |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure attribute errors[0].message contains double POST (usually the customer hitting refresh) when the state was already on SETTLED
    And make sure following attributes exist within response json
      | errors[0].extensions.classification | DataFetchingException  |
      | errors[0].extensions.currentState   | SETTLED                |

  @FULFIL-1577
  Scenario: Verify refunding the full payment after its being settled.
    Given I have successfully added items to Horizon Basket using basket/horizon_sku_payload.json
    And I have successfully added vouchercode HSD10 to Horizon basket
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And I save the STANDARD_DELIVERY optionId from response json as optionID
    And I have successfully selected deliveryOptions Information using checkout/selectDeliveryOptions.graphqls
    And I UPDATE the current basket using v1/horizon/basket/{basketUUID} endpoint
    And I call paymentOrchestrator for paymentOptions using checkout/payment/getpayment_query_gb.graphqls
    And I call paymentOrchestrator for makingPayment using checkout/payment/makePayment_basket.graphqls
    And I have successfully added payment Information using checkout/addPaymentInformation.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/submitCheckout.graphqls replacing values
      | checkoutUUID | {checkoutUUID} |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the  data.submitCheckout.orderId from within response json as orderId
    And I call paymentOrchestrator for requestSettle using checkout/payment/requestSettleTransaction.graphqls
    And make sure following attributes exist within response json
      | data.requestSettle.payments[0].paymentId    | [GUID]           |
      | data.requestSettle.payments[0].status       | SETTLE_REQUESTED |
    And I save the data.requestSettle.payments[0].paymentId from within response json as paymentId

    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/requestRefundTransaction.graphqls replacing values
      | transactionId | {transactionId}    |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.requestRefund.payments[0].paymentId    | [GUID]           |
      | data.requestRefund.payments[0].status       | REFUND_REQUESTED |
      | data.requestRefund.total.value              | 69.20            |



  @FULFIL-1196 @FULFIL-1547
  Scenario: Verify querying Transaction status before and after requestSettle mutation
    Given I have successfully added items to Horizon Basket using basket/all_promotions_payload.json
    And I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/makePayment_card.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the data.makePayment.transactionId from within response json as transactionId
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/getTransaction_query.graphqls replacing values
      | transactionId | {transactionId} |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.getTransaction.transactionId           | [GUID]       |
      | data.getTransaction.total.currency          | GBP          |
      | data.getTransaction.total.value             | 176.76       |
      | data.getTransaction.payments.paymentId      | [NOTEMPTY]   |
      | data.getTransaction.payments.status         | [AUTHORISED] |
      | data.getTransaction.payments.money.currency | [GBP]        |
      | data.getTransaction.payments.money.value    | [176.76]     |
      | data.getTransaction.payments.mode           | [NOTEMPTY]   |
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/requestSettleTransaction.graphqls replacing values
      | transactionId | {transactionId}    |
      | orderId       | 9000007537         |
      | basketTotal   | {basketTotal}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.requestSettle.payments[0].paymentId    | [GUID]           |
      | data.requestSettle.payments[0].status       | SETTLE_REQUESTED |
      | data.requestSettle.payments[0].pspReference | [NOTEMPTY]       |
      | data.requestSettle.settleRequested.currency | GBP              |
      | data.requestSettle.settleRequested.value    | [number]         |
      | data.requestSettle.settleConfirmed.currency | GBP              |
      | data.requestSettle.settleConfirmed.value    | 0.00             |

  @FULFIL-1558 @regression
  Scenario: Verify cancelling an order by using requestCancel mutation for existing transactionId
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/makePayment_card.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the data.makePayment.transactionId from within response json as transactionId
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/getTransaction_query.graphqls replacing values
      | transactionId | {transactionId} |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.getTransaction.transactionId           | [GUID]       |
      | data.getTransaction.payments.paymentId      | [NOTEMPTY]   |
      | data.getTransaction.payments.status         | [AUTHORISED] |
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/requestCancelTransaction.graphqls replacing values
      | transactionId | {transactionId} |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.requestCancel.payments[0].paymentId    | [GUID]           |
      | data.requestCancel.payments[0].pspReference | [NOTEMPTY]       |
      | data.requestCancel.payments[0].status       | CANCEL_REQUESTED |
      | data.requestCancel.settleConfirmed.currency | GBP              |
      | data.requestCancel.settleConfirmed.value    | 0.00             |

  @FULFIL-1196 @FULFIL-1585 @checkoutsanity
  Scenario: Verify getting Transaction info for existing payment via REST endpoint
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using the file checkout/payment/makePayment_card.graphqls
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the data.makePayment.transactionId from within response json as transactionId
    And I save the data.makePayment.paymentId from within response json as paymentId

    And I create a new payment-orch api request with following headers
      | Content-Type  | application/json|
    When I send a GET request to transaction/{transactionId} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | payments[0].transactionId | [GUID]           |
      | payments[0].status        | AUTHORISED       |
      | payments[0].pspReference  | [NOTEMPTY]       |

    And I create a new payment-orch api request with following headers
      | Content-Type  | application/json|
    When I send a GET request to transaction?pid={paymentId} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | payments[0].paymentId     | [GUID]           |
      | payments[0].status        | AUTHORISED       |
      | payments[0].pspReference  | [NOTEMPTY]       |
      | payments[0].events[0].type |PAYMENT_INITIALIZED|
      | payments[0].events[1].type |PAYMENT_REQUESTED |
      | payments[0].events[2].type |AUTHORISED        |


  @FULFIL-1585 @negative
  Scenario: Verify getting Transaction info for non existing transaction via REST endpoint
    And I create a new payment-orch api request with following headers
      | Content-Type  | application/json|
    When I send a GET request to transaction/629406ad-fa0c-4f6f-8c5a-a5bce5600f3e endpoint
    Then The response status code should be 404
#    And make sure following attributes exist within response json
#      | message    | Cannot find tid:629406ad-fa0c-4f6f-8c5a-a5bce5600f3e, pid:null|


  @FULFIL-1585 @negative
  Scenario: Verify getting Transaction info for non existing payment via REST endpoint
    And I create a new payment-orch api request with following headers
      | Content-Type  | application/json|
    When I send a GET request to transaction?pid=629406ad-fa0c-4f6f-8c5a-a5bce5600f3e endpoint
    Then The response status code should be 404
#    And make sure following attributes exist within response json
#      | message    | Cannot find tid:null, pid:629406ad-fa0c-4f6f-8c5a-a5bce5600f3e|

  @FULFIL-1547 @negative
  Scenario: Verify querying Transaction status for a non existing transactionId
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/getTransaction_query.graphqls replacing values
      | transactionId | a6361f4a-7d9a-4c0a-a90c-16ff196f1626 |
    When I send a graphql query to its desired server
    Then The response status code should be 200
#    And make sure attribute errors.message contains Cannot find tid:Optional[a6361f4a-7d9a-4c0a-a90c-16ff196f1626]
    And make sure following attributes exist within response json
      | errors[0].path[0]                   | getTransaction        |
      | errors[0].extensions.classification | DataFetchingException |
      | errors[0].extensions.errorMessage   | Cannot find tid:Optional[a6361f4a-7d9a-4c0a-a90c-16ff196f1626] |

  @FULFIL-1547 @negative
  Scenario: Verify making settleTransaction request for a non existing transactionId
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/requestSettleTransaction.graphqls replacing values
      | transactionId | a6361f4a-7d9a-4c0a-a90c-16ff196f1626 |
      | orderId       | 9000007537                           |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors[0].path[0]                   | requestSettle         |
      | errors[0].extensions.classification | DataFetchingException |
      | errors[0].extensions.errorMessage   | cannot find transaction 'a6361f4a-7d9a-4c0a-a90c-16ff196f1626' |

  @FULFIL-1558 @negative
  Scenario: Verify cancelling a Transaction for a non existing transactionId
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/requestCancelTransaction.graphqls replacing values
      | transactionId | a6361f4a-7d9a-4c0a-a90c-16ff196f1626 |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors[0].path[0]                   | requestCancel         |
      | errors[0].extensions.classification | DataFetchingException |
      | errors[0].extensions.errorMessage   | cannot find transaction 'a6361f4a-7d9a-4c0a-a90c-16ff196f1626' |

#    ====================  REGISTERED USER PAYMENT SCENARIOS ==========================#
#    FOLLOWING SCENARIO WILL SAVE THE PAYMENT CARD DETAILS FOR A REGISTERED USER IN PAYMENT-CARD API
  @regUser @FULFIL-1772 @checkoutsanity
  Scenario: Verify payment card info saved for a registered user if saveCard: true
    Given I have successfully added items to Horizon Basket using basket/all_promotions_payload.json
    And I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/makePayment_cardRegUser.graphqls replacing values
      | shopperReference | 978582501   |
      | saveCard         | true        |
      | basketTotal      |{basketTotal}|
    When I send a graphql query to its desired server
    Then The response status code should be 200

    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments/card?userId=978582501 endpoint
    Then The response status code should be 200
    And I save the [0].id from within response json as cardId
    And make sure following attributes exist within response json
      | [0].type | visa  |
    And I wait 5 secs before the next step
    And I successfully deleted a payment card to paymentcard api for userId 979156020

  @regUser @FULFIL-1772
  Scenario: Verify payment card info not saved for a registered user if saveCard: false
    Given I have successfully added items to Horizon Basket using basket/all_promotions_payload.json
    And I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/makePayment_cardRegUser.graphqls replacing values
      | shopperReference | 980971765       |
      | basketTotal      | {basketTotal}   |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the data.makePayment.transactionId from within response json as transactionId
    And I save the data.makePayment.paymentId from within response json as paymentId

    And I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments/card?userId=980971765 endpoint
    Then The response status code should be 200
    And make sure the response body contains the []

    @regUser @FULFIL-1773
    Scenario: Verify making a payment using registered user valid saved cardId
      Given I create a new paymentcard api request with following headers
        | Content-Type | application/json |
      When I send a GET request to payments/card?userId=979156020 endpoint
      Then The response status code should be 200
      And I save the [0].id from within response json as cardId
      And make sure following attributes exist within response json
        | [0].type       | visa  |
        | [0].lastDigits | 1111  |

      Given I create a new payment api request with following headers
        | Content-Type | application/graphql |
      And I add a graphql payload using filename checkout/payment/makePayment_savedCard.graphqls replacing values
        | shopperReference | 979156020 |
        | cardId           | {cardId}  |
        | basketTotal      | 27.36     |
      When I send a graphql query to its desired server
      Then The response status code should be 200
      And make sure following attributes exist within response json
        | data.makePayment.transactionId           | [GUID]       |
        | data.makePayment.paymentId               | [GUID]       |
        | data.makePayment.status                  | AUTHORISED   |
        | data.makePayment.mode.provider           | adyen        |
        | data.makePayment.mode.method             | adyen_scheme |
        | data.makePayment.mode.lastFourCardDigits | 1111         |
        | data.makePayment.mode.expiryDate         | 3/2030       |
        | data.makePayment.money.currency          | GBP          |

  @regUser @FULFIL-1773
  Scenario: Verify making a payment using registered user Invalid saved cardId
    Given I create a new payment api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/payment/makePayment_savedCard.graphqls replacing values
      | shopperReference | 979156020 |
      | basketTotal      | 27.36     |
      | cardId           | 06574b82-41c6-49a5-b5ab-21ed0d22aaba |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the data.makePayment.transactionId from within response json as transactionId
    And make sure following attributes exist within response json
      | data.makePayment.transactionId           | [GUID]       |
      | data.makePayment.paymentId               | [GUID]       |
      | data.makePayment.status                  | FAILED       |
    And I create a new payment-orch api request with following headers
      | Content-Type  | application/json|
    When I send a GET request to transaction/{transactionId} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | payments[0].transactionId     | [GUID]             |
      | payments[0].events[0].type    | PAYMENT_INITIALIZED|
      | payments[0].events[1].type    | FAILED             |
      | payments[0].events[1].message | No card with ID: 06574b82-41c6-49a5-b5ab-21ed0d22aaba |

#    ====================  REGISTERED USER PAYPAL PAYMENT SCENARIOS ==========================#
#    FOLLOWING SCENARIO WILL SAVE THE PAYPAL PAYMENT DETAILS FOR A REGISTERED USER IN PAYMENT API
  @regUser @FULFIL-1772 @FULFIL-2225
  Scenario: Verify paypal info saved for a registered user if savePayment: true
#    Given  I create a new payment api request with following headers
#      | Content-Type | application/graphql |
#    And I add a graphql payload using filename checkout/payment/makePayment_paypal.graphqls replacing values
#      | shopperReference | 979155055   |
#      | saveCard         | true        |
#      | basketTotal      | 41.14       |
#    When I send a graphql query to its desired server
#    Then The response status code should be 200
#    And I save the data.makePayment.paymentId from within response json as paypalId

#  *********  ABOVE STEPS SHOULD BE PERFORMED BY FE TO MAKE A SUCCESSFUL PAYPAL PAYMENT FOR 979155055  ********
#  *********  BELOW WE 1st FETCH ALL THE SAVED PAYMENT TYPES FOR THIS USER   ********
    Given I create a new paymentcard api request with following headers
      | Content-Type | application/json |
    When I send a GET request to payments/paypal?userId=979155055 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | [0].id     | [GUID]    |
      | [0].userId | 979155055 |
      | [0].method | PAYPAL    |
    And I save the [0].id from within response json as paymentId

    Given I create a new payment api request with following headers
      | Content-Type   | application/graphql |
    And I add a graphql payload using filename checkout/payment/makePayment_savedPaypal.graphqls replacing values
      | savedPaymentId | {paymentId}         |
    When I send a graphql query to its desired server
    Then The response status code should be 200

    @FULFIL-2264 @checkoutsanity
    Scenario: Verify FreeOrder being processed in PaymentOrchestrator as AUTHORISED
      Given I create a new paymentcard api request with following headers
        | Content-Type | application/json |
      When I send a GET request to payments/paypal?userId=979155055 endpoint
      Then The response status code should be 200
      And make sure following attributes exist within response json
        | [0].id     | [GUID]    |
        | [0].userId | 979155055 |
        | [0].method | PAYPAL    |
      And I save the [0].id from within response json as paymentId

      Given I create a new payment api request with following headers
        | Content-Type   | application/graphql |
      And I add a graphql payload using filename checkout/payment/makePayment_savedPaypal_freeOrder.graphqls replacing values
        | savedPaymentId | {paymentId}         |
      When I send a graphql query to its desired server
      Then The response status code should be 200
      And make sure following attributes exist within response json
        | data.makePayment.transactionId | [GUID]       |
        | data.makePayment.paymentId     | [GUID]       |
        | data.makePayment.status        | AUTHORISED   |

    @FULFIL-2264
    Scenario: Verify freeOrder without freeOrder:true will result in FAILED state
      Given I create a new paymentcard api request with following headers
        | Content-Type | application/json |
      When I send a GET request to payments/paypal?userId=979155055 endpoint
      Then The response status code should be 200
      And make sure following attributes exist within response json
        | [0].id     | [GUID]    |
        | [0].userId | 979155055 |
        | [0].method | PAYPAL    |
      And I save the [0].id from within response json as paymentId

      Given I create a new payment api request with following headers
        | Content-Type   | application/graphql |
      And I add a graphql payload using filename checkout/payment/makePayment_savedPaypal.graphqls replacing values
        | savedPaymentId | {paymentId} |
        | basketTotal    | 0.00        |
      When I send a graphql query to its desired server
      Then The response status code should be 200
      And make sure following attributes exist within response json
        | data.makePayment.transactionId | [GUID]   |
        | data.makePayment.paymentId     | [GUID]   |
        | data.makePayment.status        | FAILED   |