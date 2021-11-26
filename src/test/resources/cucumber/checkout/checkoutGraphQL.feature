@api @checkout @checkoutOrch

Feature: Checkout GraphQL

#  ACs
#  Consumers are able to request a new checkout by sending a basket ID and the channel
#  When the operation is successful, the system returns a 200 OK and the newly created checkoutId
  @sanity @FULFIL-975
  Scenario: Verify creating Checkout with basket UUID using Checkout Orchestrator
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/createCheckout.graphqls replacing values
      | basketUUID | {basketUUID} |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.createCheckout.id | [GUID] |

#  ACs
#  Consumers are able to query an existing checkout by sending a checkout ID and the channel
#  When the operation is successful, the system returns a 200 OK  (checkoutId & createdDate)
  @sanity @regression @FULFIL-1151
  Scenario: Verify querying existing checkout using checkoutById query (GB)
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_checkoutById.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.checkoutById.id        | [GUID]    |
      | data.checkoutById.createdAt | [sysDate] |

    #  ACs
#  Consumers are able to query an existing checkout by sending a Basket ID and the channel
#  When the operation is successful, the system returns a 200 OK  (checkoutId, basketId & createdDate)
  @sanity @regression @FULFIL-1151 @prod_checkout
  Scenario: Verify querying existing checkout using checkoutByBasketId query (GB)
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_checkoutByBasketId.graphqls replacing values
      | basketUUID   | {basketUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.checkoutByBasketId[0].id               | [GUID]    |
      | data.checkoutByBasketId[0].createdAt        | [sysDate] |
      | data.checkoutByBasketId[0].basketId         | [GUID]    |
      | data.checkoutByBasketId[0].events[0].status | CREATED   |

#  ACs
#  Consumers are unable to request a new checkout by sending an invalid basket ID
  @sanity @FULFIL-1083
  Scenario Outline: Verify createCheckout mutation when basketId <scenario-type>
    Given I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/createCheckout.graphqls replacing values
      | basketUUID   | <invalid-basketId> |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors.message                   | <error-message>       |
      | errors.extensions.classification | <classification-msg>  |

    Examples:
      | scenario-type  | invalid-basketId                     | classification-msg      | error-message  |
     # | already used   | 94cbdcad-f428-48aa-8b55-f0ba808175bb | [DataFetchingException] | [Exception while fetching data (/createCheckout) : Basket id [94cbdcad-f428-48aa-8b55-f0ba808175bb] has already been checked out.] |
      | does not exist | 2e74ef6c-e30c-439c-b648-1c4862316b34 | [DataFetchingException] | [Exception while fetching data (/createCheckout) : No basket for id [2e74ef6c-e30c-439c-b648-1c4862316b34].] |
      | is not-GUID    | abcd-1234-xyzpqr                     | [ValidationError]       | [Validation error of type WrongType: argument 'basketId' with value 'StringValue{value='abcd-1234-xyzpqr'}' is not a valid 'UUID' - Unable to convert [abcd-1234-xyzpqr] into a UUID @ 'createCheckout'] |
      | is null        | null                                 | [ValidationError]       | [Validation error of type WrongType: argument 'basketId' with value 'StringValue{value='null'}' is not a valid 'UUID' - Unable to convert [null] into a UUID @ 'createCheckout']                         |
      | is empty       |                                      | [ValidationError]       | [Validation error of type WrongType: argument 'basketId' with value 'StringValue{value=''}' is not a valid 'UUID' - Unable to convert [] into a UUID @ 'createCheckout']                                 |

#  ACs
#  Consumers are able to call a graphql mutation to add customer information
#  When calling the mutation, then the customer information is saved in the checkout process
#  If the email the consumer is trying to save is not a valid email the server should return a validation error
#  if the checkout doesn’t exist, the server returns an checkout not found error
  @sanity @regression @FULFIL-976 @FULFIL-1074 @FULFIL-1077 @FULFIL-1095 @prod_checkout
  Scenario: Verify addCustomerIdentity mutation using Checkout Orchestrator and MarketingPrefs set
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/addCustIdentity_guestUser.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.addCustomerIdentity.id                            | [GUID] |
      | data.addCustomerIdentity.customer.email                | navtest1@gmail.com |
      | data.addCustomerIdentity.customer.smsMarketingConsent  | false  |
      | data.addCustomerIdentity.customer.emailMarketingConsent| true   |

  @sanity @FULFIL-976 @FULFIL-1095 @prod_checkout
  Scenario: addCustomerIdentity mutation: Testing with only 1 Marketing preferences set
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/addCustIdentity_guestUser.graphqls replacing values
      | checkoutUUID          | {checkoutUUID} |
      | emailMarketingConsent | {remove}       |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.addCustomerIdentity.id                            | [GUID] |
      | data.addCustomerIdentity.customer.email                | navtest1@gmail.com |
      | data.addCustomerIdentity.customer.smsMarketingConsent  | false  |

  @sanity @FULFIL-976
  Scenario: addCustomerIdentity - for invalid email the server should return a validation error
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/addCustIdentity_invalid.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
      | email        | bademail.com        |
      | customerId   | 1-OCH16ID           |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors.message                   | [Exception while validating data (addCustomerIdentity.customer.email) : must be a well-formed email address] |
      | errors.path                      | [[addCustomerIdentity]]              |
      | errors.extensions.errorMessage   | [must be a well-formed email address]|

  @sanity @FULFIL-976
  Scenario: addCustomerIdentity - for invalid blank customerId the server should return a validation error
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/addCustIdentity_invalid.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
      | email        | valid@email.com     |
      | customerId   |                     |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors.message                   | [Exception while validating data (addCustomerIdentity.customer.customerId) : must match "\S+"] |
      | errors.path                      | [[addCustomerIdentity]]                                                                        |
      | errors.extensions.classification | [ValidationError]                                                                              |

  @sanity @FULFIL-1095
  Scenario Outline: addCustomerIdentity - for invalid marketing preferences, the server should return a validation error
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/marketing_prefs/<marketingPref_filename>.graphqls replacing values
      | checkoutUUID | {checkoutUUID} |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure attribute errors.message contains <marketing_error_msg>
    And make sure following attributes exist within response json
      | errors.extensions.classification | [ValidationError]     |

    Examples:
      | marketingPref_filename | marketing_error_msg |
      | invalidPrefsTitle      | Validation error of type WrongType: argument 'identity' with value |
      | invalidPrefsValues     | Validation error of type WrongType: argument 'identity.smsMarketingConsent' with value 'EnumValue{name='agree'}' is not a valid 'Boolean' |

#  ACs
#  Consumers are unable to request addCustomerIdentity by sending an invalid checkout ID to the service.
  @sanity @negative @FULFIL-976 @FULFIL-1037
  Scenario Outline: addCustomerIdentity - if the checkoutId <scenario-type>, the server returns error
    Given I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/addCustIdentity_guestUser.graphqls replacing values
      | checkoutUUID | <invalid-checkoutId> |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors.message                   | <error-message>       |
      | errors.extensions.classification | <classification-msg>  |

    Examples:
      | scenario-type  | invalid-checkoutId                   | classification-msg      | error-message  |
      | does not exist | 2e74ef6c-e30c-439c-b648-1c4862316b34 | [DataFetchingException] | [Exception while fetching data (/addCustomerIdentity) : No checkout for id [2e74ef6c-e30c-439c-b648-1c4862316b34].]                                                                                             |
      | is not-GUID    | abcd-1234-xyzpqr                     | [ValidationError]       | [Validation error of type WrongType: argument 'checkoutId' with value 'StringValue{value='abcd-1234-xyzpqr'}' is not a valid 'UUID' - Unable to convert [abcd-1234-xyzpqr] into a UUID @ 'addCustomerIdentity'] |
      | is null        | null                                 | [ValidationError]       | [Validation error of type WrongType: argument 'checkoutId' with value 'StringValue{value='null'}' is not a valid 'UUID' - Unable to convert [null] into a UUID @ 'addCustomerIdentity']                         |
      | is empty       |                                      | [ValidationError]       | [Validation error of type WrongType: argument 'checkoutId' with value 'StringValue{value=''}' is not a valid 'UUID' - Unable to convert [] into a UUID @ 'addCustomerIdentity']                                 |

#  ACs
#  Consumers are able to call a graphql mutation to add delivery information
#  Consumers are able to add the delivery address
#  Consumers are able to add the delivery contact
#  When calling the mutation, then the delivery information is saved in the checkout process
#  if the checkout doesn’t exist, the server returns an checkout not found error
  @sanity @FULFIL-977 @prod_checkout
  Scenario: Verify addDeliveryInformation mutation using Checkout Orchestrator
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/addDeliveryInformation.graphqls replacing values
      | checkoutUUID | {checkoutUUID} |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.addDeliveryInformation.id                            | [GUID]          |
      | data.addDeliveryInformation.location.type                 | DELIVERY        |
      | data.addDeliveryInformation.location.contact.title        | Mr              |
      | data.addDeliveryInformation.location.contact.firstName    | Nav             |
      | data.addDeliveryInformation.location.contact.lastName     | Tester          |
      | data.addDeliveryInformation.location.contact.phoneNumber  | 01123456789     |
      | data.addDeliveryInformation.location.address.postalCode   | E17 4SW         |
      | data.addDeliveryInformation.location.address.addressLine1 | 50 Byron Road   |
      | data.addDeliveryInformation.location.address.city         | london          |

#  ACs
#  Consumers are able to call a graphql mutation to add payment information
#  Consumers are able to add the payment reference AND transactionId
#  When calling the mutation, then the payment information is saved in the checkout process
#  if the checkoutId or transactionId isn't provided, the server returns an error
  @sanity @integration @FULFIL-978 @FULFIL-1091 @FULFIL-1683 @prod_checkout
  Scenario: Verify addPaymentInformation mutation using Checkout Orchestrator
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/addPaymentInformation.graphqls replacing values
      | checkoutUUID | {checkoutUUID} |
      | basketTotal  | {basketTotal}  |
      | pspReference | DMMY0123456789E|
      | transactionId| 54c2ab0d-2f1a-4b25-66c1-ae6d9eef99a3|
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.addPaymentInformation.id                                      | [GUID]          |
      | data.addPaymentInformation.paymentInformation.paymentReference     | [NOTEMPTY]      |
      | data.addPaymentInformation.paymentInformation.transactionId        | [GUID]          |
      | data.addPaymentInformation.paymentInformation.address.postalCode   | E17 4SW         |
      | data.addPaymentInformation.paymentInformation.address.addressLine1 | 50 Byron Road   |
      | data.addPaymentInformation.paymentInformation.address.city         | london          |
      | data.addPaymentInformation.paymentInformation.address.country      | GB              |

  @sanity @FULFIL-1526 @FULFIL-1596 @collectOptions @prod_checkout
  Scenario Outline: Verify querying & selecting collection options for a given store coordinates
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/hybrid/collection_item_payload.json replacing values
      | items[0].quantity | <quantity> |
      | items[1].quantity | <quantity> |
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID

    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_collectionOptions_coord.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the data.collectionOptions[0].id from within response json as optionID
    And make sure following attributes exist within response json
      | data.collectionOptions                             | [value>=1] |
      | data.collectionOptions[0].id                       | [GUID]     |
      | data.collectionOptions[0].type                     | <collection_output> |
      | data.collectionOptions[0].price.amount             | [number]   |
      | data.collectionOptions[0].price.currency           | GBP        |
      | data.collectionOptions[0].storeDetails.name        | Dover      |
      | data.collectionOptions[0].storeDetails.storeId     | 3774       |
      | data.collectionOptions[0].storeDetails.address     | [NOTEMPTY] |
      | data.collectionOptions[0].storeDetails.distance    | [NOTEMPTY] |
      | data.collectionOptions[0].storeDetails.coordinates | [NOTEMPTY] |
      | data.collectionOptions[0].storeDetails.storeTimes  | [NOTEMPTY] |

    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/selectCollectionOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
      | optionId     | {optionID}          |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.selectCollectionOption.id             | [GUID]   |
      | data.selectCollectionOption.location.type  | STORE    |
      | data.selectCollectionOption.location.deliveryOption.price.amount   | [number] |
      | data.selectCollectionOption.location.deliveryOption.price.currency | GBP      |

    Examples:
      | quantity  | collection_output         |
      | 1         | STANDARD_STORE_COLLECTION |
#      | 2         | FREE_STORE_COLLECTION     |

  @sanity @FULFIL-1564 @FULFIL-1596 @collectOptions @prod_checkout
  Scenario Outline: Verify querying & selecting collection options for a given store postcode
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/hybrid/collection_item_payload.json replacing values
      | items[0].quantity | <quantity> |
      | items[1].quantity | <quantity> |
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID

    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_collectionOptions_postcode.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the data.collectionOptions[0].id from within response json as optionID
    And make sure following attributes exist within response json
      | data.collectionOptions                             | [value>=1] |
      | data.collectionOptions[0].id                       | [GUID]     |
      | data.collectionOptions[0].type                     | <collection_output> |
      | data.collectionOptions[0].price.amount             | [number]   |
      | data.collectionOptions[0].price.currency           | GBP        |
      | data.collectionOptions[0].storeDetails.name        | Folkestone |
      | data.collectionOptions[0].storeDetails.storeId     | 3803       |
      | data.collectionOptions[0].storeDetails.address     | [NOTEMPTY] |
      | data.collectionOptions[0].storeDetails.distance    | [NOTEMPTY] |
      | data.collectionOptions[0].storeDetails.coordinates | [NOTEMPTY] |
      | data.collectionOptions[0].storeDetails.storeTimes  | [NOTEMPTY] |

    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/selectCollectionOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
      | optionId     | {optionID}          |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.selectCollectionOption.id             | [GUID]   |
      | data.selectCollectionOption.location.type  | STORE    |
      | data.selectCollectionOption.location.deliveryOption.price.amount   | [number] |
      | data.selectCollectionOption.location.deliveryOption.price.currency | GBP      |

    Examples:
      | quantity  | collection_output         |
      | 1         | STANDARD_STORE_COLLECTION |
#      | 2         | FREE_STORE_COLLECTION     |

  @sanity @FULFIL-2125 @collectOptions @checkoutsanity
  Scenario: Verify getting only STANDARD collection options for registered user subscription order
    Given I have successfully added items to Horizon Basket using basket/sub_save_regUser_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_staffUser.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_collectionOptions_postcode.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure only STANDARD_STORE_COLLECTION collection option is returned in response

  @regression @FULFIL-1596 @FULFIL-1564 @checkoutsanity
  Scenario: Verify selecting STANDARD Store collection option will add the amount to basket total
    Given I have successfully added items to Horizon Basket using basket/hybrid/collection_item_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I have successfully queried collectionOptions Information using checkout/query_collectionOptions_coord.graphqls
    And I save the data.collectionOptions[1].id from within response json as optionID
    And I have successfully selected collectionOptions Information using checkout/selectCollectionOptions.graphqls
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure there are 2 products in the basket
    And make sure following attributes exist within response json
#      | basket.subtotal              | 13.28 |
#      | basket.total                 | 15.27 |
      | basket.shipping.price        | 1.99  |
      | basket.shipping.deliveryType |STANDARD_STORE_COLLECTION |
    Given I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_checkoutByBasketId.graphqls replacing values
      | basketUUID   | {basketUUID}        |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.checkoutByBasketId[0].id               | [GUID]    |
      | data.checkoutByBasketId[0].createdAt        | [sysDate] |
      | data.checkoutByBasketId[0].basketId         | [GUID]    |
      | data.checkoutByBasketId[0].collectionOptions| [value>1] |

  @regression @FULFIL-1596 @FULFIL-1564 @checkoutsanity
  Scenario: Verify selecting NEXT_DAY Delivery option will add the amount to basket total
    Given I have successfully added items to Horizon Basket using basket/hybrid/collection_item_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_guestUser.graphqls
    And I have successfully added delivery Information using checkout/addDeliveryInformation.graphqls
    And I have successfully queried deliveryOptions Information using checkout/query_deliveryOptions.graphqls
    And I save the NEXT_DAY_DELIVERY optionId from response json as optionID
    And I have successfully selected deliveryOptions Information using checkout/selectDeliveryOptions.graphqls
    When I GET the current basket using v1/horizon/basket/{basketUUID} endpoint
    Then make sure there are 2 products in the basket
    And make sure following attributes exist within response json
#      | basket.subtotal              | 13.28 |
#      | basket.total                 | 17.27 |
      | basket.shipping.price        | 3.99  |
      | basket.shipping.deliveryType |NEXT_DAY_DELIVERY |
    Given I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_checkoutById.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.checkoutById.id               | [GUID]    |
      | data.checkoutById.createdAt        | [sysDate] |
      | data.checkoutById.basketId         | [GUID]    |
      | data.checkoutById.deliveryOptions  | [value>1] |

  @negative @FULFIL-1596 @FULFIL-1564 @prod_checkout
  Scenario: Test selecting CollectionOption with wrong checkoutId
    Given I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/selectCollectionOptions.graphqls replacing values
      | checkoutUUID | 4c03db93-e26b-4c4b-a23d-d24ecb9c2491 |
      | optionId     | 3e13c0a9-944d-4e6a-b992-4c4bfd887882 |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors[0].extensions.errorMessage  | No checkout for id [4c03db93-e26b-4c4b-a23d-d24ecb9c2491]. |

  @negative @FULFIL-1596 @FULFIL-1564 @prod_checkout
  Scenario: Test selecting CollectionOption with wrong checkoutId
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/selectCollectionOptions.graphqls replacing values
      | checkoutUUID | {checkoutUUID}      |
      | optionId     | 3e13c0a9-944d-4e6a-b992-4c4bfd887882 |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | errors[0].extensions.errorMessage  | Unable to select collection option, no options is available. |

  @negative @FULFIL-978 @FULFIL-1091 @FULFIL-1683
  Scenario Outline: Test adding paymentInformation with transactionId being <error-type>
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/addPaymentInformation.graphqls replacing values
      | checkoutUUID | {checkoutUUID}  |
      | basketTotal  | {basketTotal}   |
      | pspReference | DMMY0123456789E |
      | transactionId| <transaction-Id>|
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure attribute errors[0].message contains <error-message>

    Examples:
      | error-type |  transaction-Id                 |  error-message                       |
      | null       | null                            | Unable to convert [null] into a UUID |
      | empty      |                                 | Unable to convert [] into a UUID     |
      | wrong-guid | 3e1a933333d4d-4e6a-b992-4c4b882 |is not a valid 'UUID' - Unable to convert [3e1a933333d4d-4e6a-b992-4c4b882] into a UUID |

  @regUser @FULFIL-1766 @checkoutsanity
  Scenario: Test fetching all delivery addresses for already registered user
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a graphql payload using filename basket/rfl/rfl_regUser_payload.json replacing values
      | customerId   | 932577282  |
      | ochId        | 1-165VXNK  |
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_miscUser.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryAddress.graphqls replacing values
      | checkoutUUID | {checkoutUUID}  |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure there are 2 addresses found for this user
    And make sure following attributes exist within response json
      | data.deliveryAddresses                       |[value>1]|
      | data.deliveryAddresses[0].address.postalCode | CV5 6GH |
      | data.deliveryAddresses[1].address.postalCode | GU14 6RW|

  @regUser @FULFIL-1766
  Scenario Outline: Test fetching specific delivery address for registered user with <option>
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_regUser.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_deliveryAddress_id.graphqls replacing values
      | checkoutUUID | {checkoutUUID}  |
      | addressId    | <address-id>    |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.deliveryAddresses |<result-records>|

    Examples:
      | option            | address-id | result-records |
      | correct addressId | 976695411  | [value>=1]     |
      | non existing id   | 123456789  | []             |


  @regUser @FULFIL-1766
  Scenario: Test Adding & Removing a new address for a already registered user
    Given I have successfully added items to Horizon Basket using basket/rfl/rfl_staffUser_payload.json
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_staffUser.graphqls
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/updateRegUserAddress.graphqls replacing values
      | userId       | 979156020 |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And I save the data.upsertCustomerAddress.id from within response json as addressId
    And make sure following attributes exist within response json
      | data.upsertCustomerAddress.status  | true |

    And I wait 10 secs before the next step
    And I have successfully queried deliveryAddress Information using checkout/query_deliveryAddress.graphqls
#    And make sure there are 2 addresses found for this user

    And I wait 10 secs before the next step
    Given I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/deleteRegUserAddress.graphqls replacing values
      | userId       | 979156020    |
      | addressId    | {addressId}  |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | data.deleteCustomerAddress.id      |[NOTEMPTY]|
      | data.deleteCustomerAddress.status  | true     |

  @regUser @FULFIL-1766
  Scenario: Test CO can fetch all payment cards for already registered user with saved cards
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/basket_payload.json replacing values
      | customerId   | 979155055 |
      | ochId        | 1-1XBB81O |
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID

    And I successfully added a payment card to paymentcard api for userId 979155055
    And I have successfully created Checkout using checkout/createCheckout.graphqls
    And I have successfully added customer Information using checkout/addCustIdentity_noCardUser.graphqls
#    NOW Checkout Orchestrator  will Query PaymentCards for this user via checkoutId
    And I create a new checkout api request with following headers
      | Content-Type | application/graphql |
    And I add a graphql payload using filename checkout/query_paymentCard.graphqls replacing values
      | checkoutUUID | {checkoutUUID}  |
    When I send a graphql query to its desired server
    Then The response status code should be 200
    And make sure there are 3 cards found for this user
    And make sure following attributes exist within response json
      | data.paymentCards[0].id       | [GUID]    |
      | data.paymentCards[0].userId   | 979155055 |
#      | data.paymentCards.type        | [amex, visa, maestro] |
    And I successfully deleted a payment card to paymentcard api for userId 979155055