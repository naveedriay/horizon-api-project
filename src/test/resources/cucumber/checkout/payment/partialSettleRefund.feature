@api @checkout @partial_settle @partial_refund

Feature: Partial Settle - Refund

#  ACs
#  Consumers are able to submit a checkout by sending a valid CheckoutID & paymentReference
#  When the operation is successful, the system returns a 200 OK and the newly created orderId
  @sanity @regression @FULFIL-1651
  Scenario: Testing Partial Settle and Refund to correct order value
    Given I have successfully added items to Horizon Basket using basket/horizonpromo_sku_payload.json
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
    And make sure following attributes exist within response json
      | data.submitCheckout.status  | ACCEPTED  |
      | data.submitCheckout.orderId | [orderId] |
    And I call paymentOrchestrator for partialSettle-13.60 using checkout/payment/partialSettleTransaction.graphqls
    And make sure attribute data.requestSettle.settleRequested.value contains 13.60
    And I call paymentOrchestrator for partialSettle-19.99 using checkout/payment/partialSettleTransaction.graphqls
    And make sure attribute data.requestSettle.settleRequested.value contains 33.59
    And I call paymentOrchestrator for partialSettle-5.18 using checkout/payment/partialSettleTransaction.graphqls
    And make sure attribute data.requestSettle.settleRequested.value contains 38.77

    And I call paymentOrchestrator for partialRefund-13.60 using checkout/payment/partialRefundTransaction.graphqls
    And make sure attribute data.requestRefund.settleRequested.value contains 25.17
    And I call paymentOrchestrator for partialRefund-19.99 using checkout/payment/partialRefundTransaction.graphqls
    And make sure attribute data.requestRefund.settleRequested.value contains 5.18
    And I call paymentOrchestrator for partialRefund-5.18 using checkout/payment/partialRefundTransaction.graphqls
    And make sure attribute data.requestRefund.settleRequested.value contains 0.00

#    And I verify the order in OMS for the following attributes
#      | order-id[0].id                          | [orderId]  |
#      | order-id[0].scope                       | WEB        |
#      | creation-date-time                      | [sysDate]  |
#      | status.value                            | [NOTEMPTY] |
#      | fulfilments[0].fulfilment-type          | NOMINATED_DAY_HOME_DELIVERY |
#      | fulfilments[0].shipments[0].order-lines | [value>1]  |
#      | customer.customer-id[0].id              | [NOTEMPTY] |
#      | customer.customer-id[0].scope           | OCH        |
#      | customer                                | [NOTEMPTY] |

  @sanity @regression @FULFIL-1651
  Scenario: Testing Partial Settle beyond Order value
    Given I have successfully added items to Horizon Basket using basket/horizonpromo_sku_payload.json
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
    And make sure following attributes exist within response json
      | data.submitCheckout.status  | ACCEPTED  |
      | data.submitCheckout.orderId | [orderId] |
    And I call paymentOrchestrator for partialSettle-9.99 using checkout/payment/partialSettleTransaction.graphqls
    And make sure attribute data.requestSettle.settleRequested.value contains 9.99
    And I call paymentOrchestrator for partialSettle-19.99 using checkout/payment/partialSettleTransaction.graphqls
    And make sure attribute data.requestSettle.settleRequested.value contains 29.98
    And I call paymentOrchestrator for partialSettle-15.50 using checkout/payment/partialSettleTransaction.graphqls
    And make sure attribute errors[0].extensions.errorMessage contains Insufficient balance on payment. SETTLE_REQUESTED  with SettleRequest
    And make sure following attributes exist within response json
      | errors[0].extensions.currentState | SETTLE_REQUESTED |
      | errors[0].extensions.offer        | SettleRequest    |

  @sanity @regression @FULFIL-1651
  Scenario: Testing Partial Refund beyond order value
    Given I have successfully added items to Horizon Basket using basket/horizonpromo_sku_payload.json
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
    And make sure following attributes exist within response json
      | data.submitCheckout.status  | ACCEPTED  |
      | data.submitCheckout.orderId | [orderId] |
    And I call paymentOrchestrator for partialSettle-13.60 using checkout/payment/partialSettleTransaction.graphqls
    And make sure attribute data.requestSettle.settleRequested.value contains 13.60
    And I call paymentOrchestrator for partialSettle-17.99 using checkout/payment/partialSettleTransaction.graphqls
    And make sure attribute data.requestSettle.settleRequested.value contains 31.59
    And I call paymentOrchestrator for partialSettle-3.31 using checkout/payment/partialSettleTransaction.graphqls
    And make sure attribute data.requestSettle.settleRequested.value contains 34.90

    And I call paymentOrchestrator for partialRefund-23.60 using checkout/payment/partialRefundTransaction.graphqls
    And make sure attribute data.requestRefund.settleRequested.value contains 11.30
    And I call paymentOrchestrator for partialRefund-20.00 using checkout/payment/partialRefundTransaction.graphqls
    And make sure attribute errors[0].extensions.errorMessage contains Insufficient balance on payment. REFUND_REQUESTED  with RefundRequest.
    And make sure following attributes exist within response json
      | errors[0].extensions.currentState | REFUND_REQUESTED |
      | errors[0].extensions.offer        | RefundRequest    |

  @sanity @regression @FULFIL-1651
  Scenario: Testing Partial Refund before settle Request is made
    Given I have successfully added items to Horizon Basket using basket/horizonpromo_sku_payload.json
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
    And make sure following attributes exist within response json
      | data.submitCheckout.status  | ACCEPTED  |
      | data.submitCheckout.orderId | [orderId] |
    And I call paymentOrchestrator for partialRefund-13.60 using checkout/payment/partialRefundTransaction.graphqls
    And make sure following attributes exist within response json
      | errors[0].message |               |
      | errors[0].path[0] | requestRefund |