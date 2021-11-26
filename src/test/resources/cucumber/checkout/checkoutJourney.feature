@api @checkout @checkout_full

Feature: Checkout Journey

  @sanity @regression @FULFIL-1037 @checkoutsanity
  Scenario: Full Guest User Journey til OMS - all Promotion Skus with NEXT_DAY delivery
    Given I have successfully added items to Horizon Basket using basket/all_promotions_payload.json
    And I have successfully added vouchercode DIGITAL to Horizon basket
    When I have successfully added an RFL Card 2916000000927 to the existing Horizon basket
#    And I have successfully added an RFL Coupon 9815000162822 to the existing Horizon basket
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And I save the NEXT_DAY_DELIVERY optionId from response json as optionID
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
    And I call paymentOrchestrator for requestSettle using checkout/payment/requestSettleTransaction.graphqls
    And I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    And make sure following attributes exist within response json
      | basket.status     | COMPLETE     |
      | basket.orderId    | [orderId]    |
      | basket.checkoutId | [checkoutId] |
    And I verify the order in OMS for the following attributes
      | order-id[0].id                          | [orderId]                 |
      | order-id[0].scope                       | WEB                       |
      | creation-date-time                      | [sysDate]                 |
      | fulfilments[0].fulfilment-type          | NEXT_DAY_HOME_DELIVERY    |
      | fulfilments[0].shipments[0].order-lines | [value>1]                 |
#      | customer.customer-id[0].id              | [NOTEMPTY]                |
#      | customer.customer-id[0].scope           | OCH                       |
      | customer.title                          | Mr                        |
      | customer.first-name                     | Nav                       |
      | customer.last-name                      | Tester                    |
      | customer.contact.email                  | navtest1@gmail.com        |

    # FROM HERE ONWARDS, PLEASE CALL https://hbi-order-event-service-internal-eks.eu-west-1.dev.hbi.systems/orders/9000003272
    # AND VERIFY THE APPORTIONMENT INFO FOR THE PROMOTION ITEMS BEING REACHED THE ORDER TAKER API & OMS. 9000003274

  @sanity @regression @FULFIL-1037 @checkoutsanity
  Scenario: Full Guest User Journey - Horizon No Promotion Skus with STANDARD delivery
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
    And make sure following attributes exist within response json
      | data.submitCheckout.status  | ACCEPTED  |
      | data.submitCheckout.orderId | [orderId] |
    And I call paymentOrchestrator for requestSettle using checkout/payment/requestSettleTransaction.graphqls
    And I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    And make sure following attributes exist within response json
      | basket.status     | COMPLETE     |
      | basket.orderId    | [orderId]    |
      | basket.checkoutId | [checkoutId] |
    And I verify the order in OMS for the following attributes
      | order-id[0].id                          | [orderId]  |
      | order-id[0].scope                       | WEB        |
      | creation-date-time                      | [sysDate]  |
      | status.value                            | [NOTEMPTY] |
      | fulfilments[0].fulfilment-type          | STANDARD_HOME_DELIVERY |
      | fulfilments[0].shipments[0].order-lines | [value>1]  |
#      | customer.customer-id[0].id              | [NOTEMPTY] |
#      | customer.customer-id[0].scope           | OCH        |
      | customer                                | [NOTEMPTY] |


  @regression @FULFIL-1596 @FULFIL-1564 @checkoutsanity
  Scenario: Full Guest User Journey - Collection Options
    Given I have successfully added items to Horizon Basket using basket/horizonpromo_sku_payload.json
    And I have successfully added vouchercode DIGITAL to Horizon basket
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I have successfully queried collectionOptions Information using checkout/query_collectionOptions_coord.graphqls
    And I save the data.collectionOptions[1].id from within response json as optionID
    And I have successfully selected collectionOptions Information using checkout/selectCollectionOptions.graphqls
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
    And I call paymentOrchestrator for requestSettle using checkout/payment/requestSettleTransaction.graphqls
    And I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    And make sure following attributes exist within response json
      | basket.status     | COMPLETE     |
      | basket.orderId    | [orderId]    |
      | basket.checkoutId | [checkoutId] |
    And I verify the order in OMS for the following attributes
      | order-id[0].id                          | [orderId]  |
      | order-id[0].scope                       | WEB        |
      | creation-date-time                      | [sysDate]  |
      | status.value                            | [NOTEMPTY] |
      | fulfilments[0].fulfilment-type          | STANDARD_CLICK_AND_COLLECT |
      | fulfilments[0].shipments[0].order-lines | [NOTEMPTY] |
#      | customer.customer-id[0].id              | [NOTEMPTY] |
#      | customer.customer-id[0].scope           | OCH        |
      | customer                                | [NOTEMPTY] |

  @sanity @regression @FULFIL-1558 @FULFIL-1559
  Scenario: Full Guest User Journey with Payment Error - Verify Payment Cancellation when CO submitCheckout fails
    Given I have successfully added items to Horizon Basket using basket/horizonpromo_sku_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And I save the STANDARD_DELIVERY optionId from response json as optionID
    And I have successfully selected deliveryOptions Information using checkout/selectDeliveryOptions.graphqls
    And I call paymentOrchestrator for paymentOptions using checkout/payment/getpayment_query_gb.graphqls
    And I call paymentOrchestrator for makingPayment using checkout/payment/makePayment_basket.graphqls
    And I have successfully added payment Information using checkout/addPaymentInformation_bad.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/submitCheckout.graphqls replacing values
      | checkoutUUID | {checkoutUUID} |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.submitCheckout.status  | REJECTED  |
      | data.submitCheckout.message | Price paid differ from the basket total |
    And I call paymentOrchestrator for requestCancel using checkout/payment/requestCancelTransaction.graphqls
    And make sure following attributes exist within response json
      | data.requestCancel.payments[0].paymentId    | [GUID]           |
      | data.requestCancel.payments[0].pspReference | [NOTEMPTY]       |
      | data.requestCancel.payments[0].status       | CANCEL_REQUESTED |
    And make sure following attributes doesnot exist within response json
      | basket.orderId    |    |
      | basket.checkoutId |    |
#  ACs
#  We Used to return error upon submitting an already submitted order to OMS ( same checkoutId)
#  Now, we return the same orderNo associated to this checkoutId in OMS
  @integration @FULFIL-1616
  Scenario: Verify submitCheckout mutation using already submitted CheckoutId
    Given I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/submitCheckout.graphqls replacing values
      | checkoutUUID | ec90fc39-df4a-42ad-bb93-1298db273056 |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.submitCheckout.status  | REJECTED   |
      #| data.submitCheckout.orderId | 9000009669 |

#  ACs
#  Consumers are unable to request a new checkout by sending an invalid checkout ID and the channel
  @sanity @integration @FULFIL-1037
  Scenario Outline: Verify submitCheckout mutation when CheckoutId <scenario-type>
    Given I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/submitCheckout.graphqls replacing values
      | checkoutUUID | <invalid-checkoutId> |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors[0].message                   | <error-message>      |
      | errors[0].extensions.classification | <classification-msg> |
    Examples:
      | scenario-type  | invalid-checkoutId                   | classification-msg    | error-message                                                                                                                                                                                            |
      | does not exist | 2e74ef6c-e30c-439c-b648-1c4862316b34 | DataFetchingException | Exception while fetching data (/submitCheckout) : No checkout for id [2e74ef6c-e30c-439c-b648-1c4862316b34].                                                                                             |
      | is not-GUID    | abcd-1234-xyzpqr                     | ValidationError       | Validation error of type WrongType: argument 'checkoutId' with value 'StringValue{value='abcd-1234-xyzpqr'}' is not a valid 'UUID' - Unable to convert [abcd-1234-xyzpqr] into a UUID @ 'submitCheckout' |
      | is null        | null                                 | ValidationError       | Validation error of type WrongType: argument 'checkoutId' with value 'StringValue{value='null'}' is not a valid 'UUID' - Unable to convert [null] into a UUID @ 'submitCheckout'                         |
      | is empty       |                                      | ValidationError       | Validation error of type WrongType: argument 'checkoutId' with value 'StringValue{value=''}' is not a valid 'UUID' - Unable to convert [] into a UUID @ 'submitCheckout'                                 |

#   ===========================  REGISTERED USER JOURNEY ================================= #

#  NOTE:  NOMINATED DAY DELIVERY OPTIONS ARE STOPPED IN METAPACK FOR NOW, HENCE IGNORING THIS TEST,
#  WHEN ITS ENABLED, PLZ UPDATE THE TEST
  @sanity @regression @FULFIL-1037 @FULFIL-1371 @ignore
  Scenario: Full Registered User Journey Paid via saved card - with NOMINATED DAY delivery
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_regUser_payload.json
    And I have successfully added vouchercode DIGITAL to Horizon basket
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_regUser.graphqls
    And I have successfully queried deliveryAddress Information using checkout/query_deliveryAddress.graphqls
    And I save the data.deliveryAddresses[1].metadata.externalId from within response json as addressId
    And I have successfully added saved_delivery Information using checkout/addDeliveryInformation_regUser.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And I save the NOMINATED_DAY optionId from response json as optionID
    And I have successfully selected deliveryOptions Information using checkout/selectDeliveryOptions.graphqls
    And I UPDATE the current basket using v1/horizon/basket/{basketUUID} endpoint
    And I have successfully queried paymentCards Information using checkout/query_paymentCard.graphqls
##    And I call paymentOrchestrator for paymentOptions using checkout/payment/getpayment_query_gb.graphqls
    And I call paymentCard api for any saved cards for this user 958625400
    And I call paymentOrchestrator for makingRegUserPayment_anyCard using checkt/payment/makePayment_cardRegUser.graphqls
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
    And I call paymentOrchestrator for requestSettle using checkout/payment/requestSettleTransaction.graphqls
    And I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    And make sure following attributes exist within response json
      | basket.status     | COMPLETE     |
      | basket.orderId    | [orderId]    |
      | basket.checkoutId | [checkoutId] |
    And I verify the order in OMS for the following attributes
      | order-id[0].id                          | [orderId]  |
      | order-id[0].scope                       | WEB        |
      | creation-date-time                      | [sysDate]  |
      | status.value                            | [NOTEMPTY] |
      | fulfilments[0].fulfilment-type          | NOMINATED_DAY_HOME_DELIVERY |
      | fulfilments[0].shipments[0].order-lines | [value>1]  |
      | customer.customer-id                    | [value>1]  |
      | customer.customer-id[0].id              | 1-16XP5OK  |
      | customer.customer-id[0].scope           | OCH        |
      | customer.customer-id[1].id              | 958625400  |
      | customer.customer-id[1].scope           | ATG        |

  @regUser @checkoutsanity1
  Scenario: Full Registered User Journey Staff - Subscription Items in basket with Standard Delivery Paid via saved card
    Given I have successfully added items to Horizon Basket using basket/sub_save_regUser_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_staffUser.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation_staffUser.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And I save the STANDARD_DELIVERY optionId from response json as optionID
    And I have successfully selected deliveryOptions Information using checkout/selectDeliveryOptions.graphqls
    And I UPDATE the current basket using v1/horizon/basket/{basketUUID} endpoint
    And make sure basket total is correctly calculated after applying promotionalDiscountValue
    And I call paymentOrchestrator for paymentOptions using checkout/payment/getpayment_query_gb.graphqls
    And I call paymentCard api for preferred saved cards for this user 979156020
    And I call paymentOrchestrator for makingRegUserPayment_savedCard using checkout/payment/makePayment_savedCard.graphqls
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
    And I call paymentOrchestrator for requestSettle using checkout/payment/requestSettleTransaction.graphqls
    And I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    And make sure following attributes exist within response json
      | basket.status          | COMPLETE     |
      | basket.isStaff         | true         |
      | basket.hasSubscription | true         |
      | basket.orderId         | [orderId]    |
      | basket.checkoutId      | [checkoutId] |
    And I wait 5 secs before the next step
    Given I create a new subscribe-item api request with following headers
      | Content-Type | application/vnd.subscription.product.v1+json |
    When I send a GET request to subscriptions/customers/1-1WCHTM6 endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | [0].type                        | NEW_SUBSCRIPTION                 |
      | [0].subscription-frequency-days | 28                               |
      | [0].customer.email              | naveedriay@hollandandbarrett.com |
      | [0].sku                         | 048771                           |
      | [0].quantity                    | 1                                |
    And I clear all subscriptions orders for customer 1-1WCHTM6