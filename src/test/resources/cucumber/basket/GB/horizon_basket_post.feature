@api @basketGB @HorizonGB @A2B @horizonPOST
Feature: Test Horizon Basket Api - POST

  @sanity @regression
  Scenario: Verify creating new Horizon GBP Basket with valid payload json
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/rfl/rfl_guestUser_payload.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
#    And make sure there are 4 products in the basket
    And make sure items total collectively make the basket total
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                              |
      | 021031 | 1             | Holland & Barrett Raspberry Ketone Complex 90 Capsules |
      | 086380 | 1             | Dr Organic Royal Jelly Leg & Vein Cream 200ml          |
      | 007026 | 2             | Spatone Apple Liquid Iron Supplement 28 x 20ml Sachets |
      | 035296 | 2             | Holland & Barrett Stress Relief Passionflower 30 Tablets 425mg |
    And the following items contains correct status
      | 021031 | ADDED  |
      | 086380 | ADDED  |
      | 007026 | ADDED  |
      | 035296 | ADDED  |
    And make sure following attributes exist within response json
      | horizonSuccess           | true         |
      | basket.status            | ACTIVE       |
      | basket.currency          | GBP          |
      | basket.createdDate       | [sysDate]    |
      | basket.updatedDate       | [sysDate]    |
      | basket.uuid              | [GUID]       |
      | basket.items[0].skuId    | 021031       |
      | basket.items[0].quantity | 1            |
      | basket.items[0].subtotal | [number]     |
      | basket.items[0].total    | [number]     |
      | basket.shipping          |              |
      | basket.items[0].brand    |holland-barrett|
      | basket.items[0].category | vitamins-supplements/supplements/raspberry-ketones|
# NOTE: The shipping info is now been removed from Basket Orchestrator which was being sent by promo_v1.1

  @sanity
  Scenario: Verify creating new Horizon GBP Basket using query params on POST request
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | basic     | false  |
      | currency  | GBP    |
      | siteId    | 10     |
      | locale    | en-GB  |
    And I add a json payload using the file basket/markdown_items_payload.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
#    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And the following items contains correct status
      | 009726 | ADDED         |
      | 089710 | ADDED         |
    And make sure following attributes exist within response json
      | horizonSuccess               | true      |
      | basket.status                | ACTIVE    |
      | basket.currency              | GBP       |
      | basket.createdDate           | [sysDate] |
      | basket.updatedDate           | [sysDate] |
      | basket.uuid                  | [GUID]    |
      | basket.items[0].skuId        | 009726    |
      | basket.items[0].quantity     | 1         |
      | basket.items[0].unitWasPrice | 12.99     |
      | basket.items[0].unitNowPrice | 11.5      |
      | basket.items[0].subtotal     | 12.99     |
      | basket.items[0].total        | 11.5      |
      | basket.items[0].images       | [value>1] |
      | basket.items[0].available    | true      |
      | basket.subtotal              | [number]  |
      | basket.total                 | [number]  |

  @BASKET-254
  Scenario: Verify Creating a new Horizon Basket using max item quantity exceeded
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/basket_payload.json replacing values
      | items[0].quantity | 32          |
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And the following items contains correct status
      | 048791 | ADDED  |
      | 005955 | ADDED  |
    And make sure following attributes exist within response json
      | horizonSuccess             | true      |
      | basket.items[0].skuId      | 048791    |
      | basket.items[0].quantity   | 30        |
      | basket.items[0].brand      | naturtint |
      | basket.items[0].category   | natural-beauty/hair-care/hair-colouring|

  @sanity @regression @italy
  Scenario: Verify creating new Italian Horizon Basket with valid payload json
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/italian_basket_payload.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And the following items contains correct status
      | 001014 | ADDED         |
      | 005955 | NOTFOUND      |
    And make sure following attributes exist within response json
      | basket.status            | ACTIVE       |
      | basket.currency          | EUR          |
      | basket.locale            | it-IT        |
      | basket.createdDate       | [sysDate]    |
      | basket.updatedDate       | [sysDate]    |
      | basket.uuid              | [GUID]       |
      | basket.items[0].skuId    | 001014       |
      | basket.items[0].quantity | 1            |
      | horizonSuccess           | true         |
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | siteId |  66 |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And make sure following attributes exist within response json
      | basket.currency | EUR   |
      | basket.locale   | it-IT |
      | horizonSuccess  | true  |


  @sanity @italy
  Scenario: Verify creating new Italian Basket using query params on POST request
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | basic     | false  |
      | currency  | EUR    |
      | siteId    | 66     |
      | locale    | it-IT  |
    And I add a json payload using the file basket/basket_min_payload.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And the following items contains correct status
      | 001014 | ADDED         |
      | 048791 | NOTFOUND      |
    And make sure following attributes exist within response json
      | basket.status                | ACTIVE    |
      | basket.currency              | EUR       |
      | basket.createdDate           | [sysDate] |
      | basket.updatedDate           | [sysDate] |
      | basket.uuid                  | [GUID]    |
      | basket.items[0].skuId        | 001014    |
      | basket.items[0].quantity     | 1         |
      | basket.items[0].unitWasPrice | [number]  |
      | basket.items[0].unitNowPrice | [number]  |
      | basket.items[0].subtotal     | [number]  |
      | basket.items[0].images       | [value>1] |
      | basket.items[0].available    | true      |
      | horizonSuccess               | true      |
#      | basket.items[0].status       | INSTOCK   |
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | siteId  | 66 |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 1 products in the basket
    And make sure following attributes exist within response json
      | basket.currency | EUR   |
      | basket.locale   | it-IT |
      | horizonSuccess  | true  |

  @sanity @regression @france @ignore
  Scenario: Verify creating new French Horizon Basket with valid payload json
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/french_basket_payload.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And I save the basket.uuid from within response json as basketUUID
    And make sure items total collectively make the basket total
    And the following items contains correct status
      | 060187 | ADDED         |
      | 004925 | ADDED         |
    And make sure following attributes exist within response json
      | basket.status            | ACTIVE       |
      | basket.currency          | EUR          |
      | basket.locale            | en-FR        |
      | basket.createdDate       | [sysDate]    |
      | basket.updatedDate       | [sysDate]    |
      | basket.uuid              | [GUID]       |
      | basket.items[0].skuId    | 060187       |
      | basket.items[0].quantity | 1            |
      | horizonSuccess           | true         |
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | basket.currency | EUR   |
      | basket.locale   | en-FR |
      | horizonSuccess  | true  |

  @sanity @negative
  Scenario: Valid POST request with No Items in payload json
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/no_items_payload.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And make sure an empty basket with no items is returned

  @negative
  Scenario: Invalid POST request with No payload json
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/empty_payload.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 400

  @negative
  Scenario: Valid POST request with invalid SkuId in Json Payload
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/invalid_skuId_payload.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And the following items contains correct status
      | 000000 | NOTFOUND |
      | 099999 | NOTFOUND |
      | 0fffff | NOTFOUND |
    And make sure following attributes exist within response json
      | basket.items       | []        |
      | basket.currency    | GBP       |
      | basket.createdDate | [sysDate] |
      | basket.updatedDate | [sysDate] |
      | basket.uuid        | [GUID]    |
      | horizonSuccess     | true      |

