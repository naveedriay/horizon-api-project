@api @deliveryApi @checkout @metapack @collectOptions

Feature: Metapack Driven Delivery Options

  @sanity @integration @FULFIL-1209 @FULFIL-1480 @checkoutsanity @prod_checkout
  Scenario: Check detailed responses for delivery Options returned for UK store search
    Given I create a new delivery api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file checkout/deliveryOpt/metapack/store_search.json
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | [0].type                               | FREE_STORE_COLLECTION     |
      | [0].name                               | Free Click & Collect      |
      | [0].deliveryMethod                     | HB_STORE                  |
      | [0].cutoff                             |                           |
      | [0].price.amount                       | 0.00                      |
      | [0].price.currency                     | GBP                       |
      | [0].carrierData.groupCode              | NBTYFREE                  |
      | [0].storeDetails.name                  | Kensington High St        |
      | [0].storeDetails.storeId               | 3012                      |
      | [0].storeDetails.address               | [NOTEMPTY]                |
      | [0].storeDetails.distance.value        | [number]                  |
      | [0].storeDetails.distance.unit         | mi                        |
      | [0].storeDetails.coordinates.longitude | [number]                  |
      | [0].storeDetails.coordinates.latitude  | [number]                  |
      | [0].storeDetails.storeTimes            |                           |

      | [1].type                               | STANDARD_STORE_COLLECTION |
      | [1].name                               | Click & Collect Next Day  |
      | [1].deliveryMethod                     | HB_STORE                  |
      | [1].cutoff                             |                           |
      | [1].price.amount                       | [number]                  |
      | [1].price.currency                     | GBP                       |
      | [1].carrierData.groupCode              | NBTYSTORE                 |


  @sanity @regression  @FULFIL-1209 @checkoutsanity @prod_checkout
  Scenario: Check detailed responses for delivery Options returned for UK home delivery search
    Given I create a new delivery api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file checkout/deliveryOpt/metapack/homeDelivery_gb_search.json
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure metapack returns following delivery options
      | delivery_type     | delivery_name         | deliveryMethod  | deliveryPrice | groupCode  |
      | NEXT_DAY_DELIVERY | Next Day              | HOME_DELIVERY   | 3.99          | NEXTDAY    |
      | STANDARD_DELIVERY | Standard              | HOME_DELIVERY   | 2.99          | STANDARD   |
      | NOMINATED_DAY     | Nominated Day Delivery| HOME_DELIVERY   | 3.99          | NOMDD      |

  @sanity @regression @FULFIL-1209 @FULFIL-1480 @checkoutsanity @prod_checkout
  Scenario: Verify delivery Options returned for UK collection point search
    Given I create a new delivery api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file checkout/deliveryOpt/metapack/collection_point.json
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure metapack returns following delivery options
      | delivery_type     | delivery_name         | deliveryMethod  | deliveryPrice | groupCode  |
      | PARCEL_SHOP       | ParcelShop            | COLLECTION_POINT| 1.95          | PARCELSHOP |
      | COLLECT_PLUS      | Collect+              | COLLECTION_POINT| 1.95          | COLLECTPLUS|

  @sanity @integration @FULFIL-1209 @FULFIL-1480 @checkoutsanity @prod_checkout
  Scenario: Verify delivery Options returned for UK co-ordinate search
    Given I create a new delivery api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file checkout/deliveryOpt/metapack/coordinate_search.json
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure metapack returns following delivery options
      | delivery_type     | delivery_name         | deliveryMethod  | deliveryPrice | groupCode  |
      | PARCEL_SHOP       | ParcelShop            | COLLECTION_POINT| 1.95          | PARCELSHOP |
      | COLLECT_PLUS      | Collect+              | COLLECTION_POINT| 1.95          | COLLECTPLUS|

  @sanity @negative @FULFIL-1209
  Scenario: Verify delivery Options are not returned for international store search
    Given I create a new delivery api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename checkout/deliveryOpt/metapack/store_search.json replacing values
      | address.postcode | 70565 |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure the response body contains the []

  @sanity @negative @FULFIL-1209
  Scenario: Verify delivery Options search from metapack api with wrong payload
    Given I create a new delivery api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename checkout/deliveryOpt/metapack/store_search.json replacing values
      | deliveryMethods | WRONG_METHOD |
    When I send a POST request to search endpoint
    Then The response status code should be 400

  @sanity @negative @FULFIL-1209
  Scenario: Verify delivery Options search from metapack api with wrong postcode
    Given I create a new delivery api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename checkout/deliveryOpt/metapack/homeDelivery_gb_search.json replacing values
      | address.postcode | DX45ABXA |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure the response body contains the []
