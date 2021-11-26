@api @checkout @deliveryOptions

Feature: Delivery Options

#  ACs
#  Consumers are able to request a new checkout by sending a basket ID and the channel
#  When the operation is successful, the system returns a 200 OK and the newly created checkoutId
#  NOTE: Currently Basket API only supports en-GB|it-IT locales
  @regression @FULFIL-1052 @prod_checkout
  Scenario: Query deliveryOptions using Customer delivery Info set for GB address
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following delivery options are resulted
      | delivery_type     | price | currency | optionId |
      | NEXT_DAY_DELIVERY | 3.99  | GBP      | [GUID]   |
      | STANDARD_DELIVERY | 2.99  | GBP      | [GUID]   |
#      | NOMINATED_DAY     | 3.99  | GBP      | [GUID]   |

  @regression @FULFIL-1662 @prod_checkout
  Scenario: Query deliveryOptions using coordinates for GB address
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
#    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryOptions_coord.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following delivery options are resulted
      | delivery_type     | price | currency | optionId |
      | NEXT_DAY_DELIVERY | 3.99  | GBP      | [GUID]   |
      | STANDARD_DELIVERY | 2.99  | GBP      | [GUID]   |
#      | NOMINATED_DAY     | 3.99  | GBP      | [GUID]   |

#  ACs
#  Consumers are able to request a new checkout by sending a basket ID and the channel
#  When the operation is successful, the system returns a 200 OK and the newly created checkoutId
#  NOTE: Currently Checkout API only supports en-GB||nl-NL|en-IE|en-FR|fr-BE|nl-BE|fr-FR|it-IT locales
#  #  When en-US|en-AU locale will be available, then this test will need updating to use intl_basket_payload.json
  @sanity @integration @FULFIL-1052 @ignore
  Scenario: Verify deliveryOptions mutation using Checkout Orchestrator for US address
    Given I have successfully added items to Horizon Basket using checkout/deliveryOpt/intl_basket_payload.json
    And I have successfully created Checkout using checkout/deliveryOpt/intl_createCheckout.graphqls
    And I have successfully added delivery Information using checkout/deliveryOpt/intl_addDeliveryInfo.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.deliveryOptions[0].id             | INTERNATIONAL_STANDARD |
      | data.deliveryOptions[0].price.amount   | [number]               |
      | data.deliveryOptions[0].price.currency | USD                    |
      | data.deliveryOptions[1].id             | INTERNATIONAL_EXPRESS  |
      | data.deliveryOptions[1].price.amount   | [number]               |
      | data.deliveryOptions[1].price.currency | USD                    |

#  NOTE: Currently Checkout API only supports en-GB||nl-NL|en-IE|en-FR|fr-BE|nl-BE|fr-FR|it-IT locales
#  When en-US|en-AU locale will be available, then this test will need updating to use aus_basket_payload.json
  @sanity @integration @FULFIL-1052 @ignore
  Scenario: Verify deliveryOptions mutation using Checkout Orchestrator for Australia address
    Given I have successfully added items to Horizon Basket using checkout/deliveryOpt/aus_basket_payload.json
    And I have successfully created Checkout using checkout/deliveryOpt/aus_createCheckout.graphqls
    And I have successfully added delivery Information using checkout/deliveryOpt/aus_addDeliveryInfo.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.deliveryOptions[0].id             | INTERNATIONAL_STANDARD |
      | data.deliveryOptions[0].price.amount   | [number]               |
      | data.deliveryOptions[0].price.currency | AUD                    |
      | data.deliveryOptions[1].id             | INTERNATIONAL_EXPRESS  |
      | data.deliveryOptions[1].price.amount   | [number]               |
      | data.deliveryOptions[1].price.currency | AUD                    |

#    NOTE: Currently Basket API only supports en-GB||nl-NL|en-IE|fr-BE|nl-BE|fr-FR|it-IT locales
#    When de-DE locale will be available, then this test will need updating to use germany_basket_payload.json
  @sanity @integration @FULFIL-1052 @ignore
  Scenario: Verify deliveryOptions mutation using Checkout Orchestrator for Germany address
    Given I have successfully added items to Horizon Basket using checkout/deliveryOpt/germany_basket_payload.json
    And I have successfully created Checkout using checkout/deliveryOpt/germany_createCheckout.graphqls
    And I have successfully added delivery Information using checkout/deliveryOpt/germany_addDeliveryInfo.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.deliveryOptions[0].id             | INTERNATIONAL_STANDARD |
      | data.deliveryOptions[0].price.amount   | [number]               |
      | data.deliveryOptions[0].price.currency | EUR                    |
      | data.deliveryOptions[1].id             | INTERNATIONAL_EXPRESS  |
      | data.deliveryOptions[1].price.amount   | [number]               |
      | data.deliveryOptions[1].price.currency | EUR                    |

  @sanity @integration @FULFIL-1052 @ignore
  Scenario: Verify deliveryOptions mutation using Checkout Orchestrator for Italy address
    Given I have successfully added items to Horizon Basket using checkout/deliveryOpt/italian_basket_payload.json
    And I have successfully created Checkout using checkout/deliveryOpt/italian_createCheckout.graphqls
    And I have successfully added delivery Information using checkout/deliveryOpt/italian_addDeliveryInfo.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.deliveryOptions[1].id             | INTERNATIONAL_STANDARD |
      | data.deliveryOptions[1].price.amount   | [number]               |
      | data.deliveryOptions[1].price.currency | EUR                    |
      | data.deliveryOptions[0].id             | INTERNATIONAL_EXPRESS  |
      | data.deliveryOptions[0].price.amount   | [number]               |
      | data.deliveryOptions[0].price.currency | EUR                    |

   @integration @FULFIL-1052 @checkoutsanity1 @france @ignore
  Scenario: Verify deliveryOptions mutation using Checkout Orchestrator for France address
    Given I have successfully added items to Horizon Basket using checkout/deliveryOpt/french_basket_payload.json
    And I have successfully created Checkout using checkout/deliveryOpt/french_createCheckout.graphqls
    And I have successfully added delivery Information using checkout/deliveryOpt/french_addDeliveryInfo.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.deliveryOptions[1].id             | INTERNATIONAL_STANDARD |
      | data.deliveryOptions[1].price.amount   | [number]               |
      | data.deliveryOptions[1].price.currency | EUR                    |
      | data.deliveryOptions[0].id             | INTERNATIONAL_EXPRESS  |
      | data.deliveryOptions[0].price.amount   | [number]               |
      | data.deliveryOptions[0].price.currency | EUR                    |

  @FULFIL-1052
  Scenario: Verify Empty/No deliveryOptions using Checkout Orchestrator for GB address
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
#    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors[0].path                      | [deliveryOptions]                                                                           |
      | errors[0].extensions.classification | DataFetchingException                                                                       |
      | errors[0].message                   | Exception while fetching data (/deliveryOptions) : Missing or invalid location for delivery |

  @FULFIL-1052 @checkoutsanity
  Scenario: Verify deliveryOptions gives Exception when tried without a delivery Address
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors.message                   | [Exception while fetching data (/deliveryOptions) : Missing or invalid location for delivery] |
      | errors.path                      | [[deliveryOptions]]                                                                           |
      | errors.extensions.classification | [DataFetchingException]                                                                       |

# ==============================================================================================================
#     SELECT DELIVERY OPTIONS MUTATION TESTS
# ==============================================================================================================
  @FULFIL-1518 @regression @checkoutsanity @prod_checkout
  Scenario: Verify selecting STANDARD_DELIVERY DeliveryOptions to GB Basket successfully added correct delivery charges
    Given I have successfully added items to Horizon Basket using basket/append_item_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And make sure following delivery options are resulted
      | delivery_type     | price | currency | optionId |
      | NEXT_DAY_DELIVERY | 3.99  | GBP      | [GUID]   |
      | STANDARD_DELIVERY | 2.99  | GBP      | [GUID]   |
#      | NOMINATED_DAY     | 3.99  | GBP      | [GUID]   |
    And I save the STANDARD_DELIVERY optionId from response json as optionID
    Given I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/selectDeliveryOptions.graphqls replacing values
      | checkoutUUID   | {checkoutUUID}    |
      | optionId       | {optionID}        |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.selectDeliveryOption.id                                     | [GUID]   |
      | data.selectDeliveryOption.location.type                          | DELIVERY |
      | data.selectDeliveryOption.location.address.postalCode            | E17 4SW  |
      | data.selectDeliveryOption.location.address.city                  | london   |
      | data.selectDeliveryOption.location.address.country               | GB       |
      | data.selectDeliveryOption.location.deliveryOption.price.amount   | [number] |
      | data.selectDeliveryOption.location.deliveryOption.price.currency | GBP      |
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | STANDARD_DELIVERY |
      | basket.shipping.destination  | GB                |
      | basket.shipping.price        | [number]          |

  @FULFIL-1371 @FULFIL-1518 @checkoutsanity @prod_checkout
  Scenario: Verify selecting NEXT_DAY_DELIVERY DeliveryOptions to GB Basket successfully added correct delivery charges
    Given I have successfully added items to Horizon Basket using basket/append_item_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And make sure following delivery options are resulted
      | delivery_type     | price | currency | optionId |
      | NEXT_DAY_DELIVERY | 3.99  | GBP      | [GUID]   |
      | STANDARD_DELIVERY | 2.99  | GBP      | [GUID]   |
#      | NOMINATED_DAY     | 3.99  | GBP      | [GUID]   |
    And I save the NEXT_DAY_DELIVERY optionId from response json as optionID
    Given I create a new checkout api request with following headers
      | Content-Type   | application/graphql |
    And I add a graphql payload using filename checkout/selectDeliveryOptions.graphqls replacing values
      | checkoutUUID   | {checkoutUUID}      |
      | optionId       | {optionID}          |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.selectDeliveryOption.id                                     | [GUID]   |
      | data.selectDeliveryOption.location.type                          | DELIVERY |
      | data.selectDeliveryOption.location.address.postalCode            | E17 4SW  |
      | data.selectDeliveryOption.location.address.city                  | london   |
      | data.selectDeliveryOption.location.address.country               | GB       |
      | data.selectDeliveryOption.location.deliveryOption.price.amount   | [number] |
      | data.selectDeliveryOption.location.deliveryOption.price.currency | GBP      |
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | NEXT_DAY_DELIVERY |
      | basket.shipping.destination  | GB                |
      | basket.shipping.price        | [number]          |


  @FULFIL-1518 @FULFIL-1371 @prod_checkout @ignore
  Scenario: Verify selecting NOMINATED_DAY DeliveryOptions to GB Basket successfully added correct delivery charges
    Given I have successfully added items to Horizon Basket using basket/append_item_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And make sure following delivery options are resulted
      | delivery_type     | price | currency | optionId |
      | NEXT_DAY_DELIVERY | 3.99  | GBP      | [GUID]   |
      | STANDARD_DELIVERY | 2.99  | GBP      | [GUID]   |
      | NOMINATED_DAY     | 3.99  | GBP      | [GUID]   |
    And I save the NOMINATED_DAY optionId from response json as optionID
    Given I create a new checkout api request with following headers
      | Content-Type   | application/graphql |
    And I add a graphql payload using filename checkout/selectDeliveryOptions.graphqls replacing values
      | checkoutUUID   | {checkoutUUID}      |
      | optionId       | {optionID}          |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.selectDeliveryOption.id                                     | [GUID]   |
      | data.selectDeliveryOption.location.type                          | DELIVERY |
      | data.selectDeliveryOption.location.address.postalCode            | E17 4SW  |
      | data.selectDeliveryOption.location.address.city                  | london   |
      | data.selectDeliveryOption.location.address.country               | GB       |
      | data.selectDeliveryOption.location.deliveryOption.price.amount   | 3.99     |
      | data.selectDeliveryOption.location.deliveryOption.price.currency | GBP      |
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure following attributes exist within response json
      | basket.shipping.deliveryType | NOMINATED_DAY |
      | basket.shipping.destination  | GB            |
      | basket.shipping.price        | 3.99          |

  @FULFIL-2017 @FULFIL-1968 @negative
  Scenario Outline: Verify implementing delivery instructions with <test-type> for deliveryOptions mutation
    Given I have successfully added items to Horizon Basket using basket/append_item_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And I save the STANDARD_DELIVERY optionId from response json as optionID
    Given I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/selectDeliveryOptions_bad.graphqls replacing values
      | checkoutUUID   | {checkoutUUID}    |
      | optionId       | {optionID}        |
      | instructions   | <deliveryMsg>     |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors.path                      | [[selectDeliveryOption]]        |
      | errors.extensions.errorMessage   | [size must be between 1 and 100]|
      | errors.extensions.classification | [ValidationError]               |

    Examples:
      | test-type        | deliveryMsg                                                                                           |
      | msg-length > 100 | This is long message for the delivery instruction to be tested for more than 100 characters in length |
      | msg-length empty |                                                                                                       |
#      | msg-length = 1   | it works fine                                                                                         |
#      | msg is null      | it works fine                                                                                         |

  @BASKET-259 @regression @italy @ignore
  Scenario: Verify selecting INTERNATIONAL_STANDARD DeliveryOptions to IT Basket successfully added correct delivery charges
    Given I have successfully added items to Horizon Basket using checkout/deliveryOpt/italian_basket_payload.json
    And I have successfully created Checkout using checkout/deliveryOpt/italian_createCheckout.graphqls
    And I have successfully added delivery Information using checkout/deliveryOpt/italian_addDeliveryInfo.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    Given I create a new checkout api request with following headers
      | Content-Type   | application/graphql |
    And I add a graphql payload using filename checkout/selectDeliveryOptions.graphqls replacing values
      | checkoutUUID   | {checkoutUUID}        |
      | deliveryOption | INTERNATIONAL_STANDARD|
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.selectDeliveryOption.id                                     | [GUID]   |
      | data.selectDeliveryOption.location.type                          | DELIVERY |
      | data.selectDeliveryOption.location.address.postalCode            | 84033    |
      | data.selectDeliveryOption.location.address.city                  | Milan    |
      | data.selectDeliveryOption.location.address.country               | IT       |
      | data.selectDeliveryOption.location.deliveryOption.price.amount   | [number] |
      | data.selectDeliveryOption.location.deliveryOption.price.currency | EUR      |
    When I GET the current basket using v1/horizon/basket/{basketUUID}?siteId=66 endpoint
    And make sure following attributes exist within response json
      | basket.shipping.deliveryType | INTERNATIONAL_STANDARD |
      | basket.shipping.destination  | IT                     |
      | basket.shipping.price        | [number]               |

  @BASKET-259 @regression @italy @ignore
  Scenario: Verify selecting INTERNATIONAL_EXPRESS DeliveryOptions to IT Basket successfully added correct delivery charges
    Given I have successfully added items to Horizon Basket using checkout/deliveryOpt/italian_basket_payload.json
    And I have successfully created Checkout using checkout/deliveryOpt/italian_createCheckout.graphqls
    And I have successfully added delivery Information using checkout/deliveryOpt/italian_addDeliveryInfo.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    Given I create a new checkout api request with following headers
      | Content-Type   | application/graphql |
    And I add a graphql payload using filename checkout/selectDeliveryOptions.graphqls replacing values
      | checkoutUUID   | {checkoutUUID}        |
      | deliveryOption | INTERNATIONAL_EXPRESS |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.selectDeliveryOption.id                                     | [GUID]   |
      | data.selectDeliveryOption.location.type                          | DELIVERY |
      | data.selectDeliveryOption.location.address.postalCode            | 84033    |
      | data.selectDeliveryOption.location.address.city                  | Milan    |
      | data.selectDeliveryOption.location.address.country               | IT       |
      | data.selectDeliveryOption.location.deliveryOption.price.amount   | [number] |
      | data.selectDeliveryOption.location.deliveryOption.price.currency | EUR      |
    When I GET the current basket using v1/horizon/basket/{basketUUID}?siteId=66 endpoint
    And make sure following attributes exist within response json
      | basket.shipping.deliveryType | INTERNATIONAL_EXPRESS |
      | basket.shipping.destination  | IT                    |
      | basket.shipping.price        | [number]              |
