@api @NLbasket @HorizonBasketNL @A2B
Feature: Test NL Horizon Basket Api - POST
  #Converted
  @sanity @regression
  Scenario: Verify creating new Horizon GBP Basket with valid payload json
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/rfl/rfl_guestUser_payload.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
#    And make sure there are 5 products in the basket
    And make sure items total collectively make the basket total
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                                      |
      | 021031 | 1             | Holland & Barrett Raspberry Ketone Complex 90 Capsules         |
      | 086380 | 1             | Dr Organic Royal Jelly Leg & Vein Cream 200ml                  |
      | 007026 | 2             | Spatone Apple Liquid Iron Supplement 28 x 20ml Sachets         |
      | 035296 | 2             | Holland & Barrett Stress Relief Passionflower 30 Tablets 425mg |
    And the following items contains correct status
      | 021031 | ADDED |
      | 086380 | ADDED |
      | 007026 | ADDED |
      | 035296 | ADDED |
    And make sure following attributes exist within response json
      | horizonSuccess           | true                                               |
      | basket.status            | ACTIVE                                             |
      | basket.currency          | GBP                                                |
      | basket.createdDate       | [sysDate]                                          |
      | basket.updatedDate       | [sysDate]                                          |
      | basket.uuid              | [GUID]                                             |
      | basket.items[0].skuId    | 021031                                             |
      | basket.items[0].quantity | 1                                                  |
      | basket.items[0].subtotal | [number]                                           |
      | basket.items[0].total    | [number]                                           |
      | basket.shipping          |                                                    |
      | basket.items[0].brand    | holland-barrett                                    |
      | basket.items[0].category | vitamins-supplements/supplements/raspberry-ketones |
# NOTE: The shipping info is now been removed from Basket Orchestrator which was being sent by promo_v1.1

  #Converted
  @sanity
  Scenario: Verify creating new Horizon GBP Basket using query params on POST request
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | basic    | false |
      | currency | EUR   |
      | siteId   | 40    |
      | locale   | nl-NL |
    And I add a json payload using the file basket/NL_payloads/markdown_items_payload_NL.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And the following items contains correct status
      | 007961 | ADDED |
      | 008049 | ADDED |
    And make sure following attributes exist within response json
      | horizonSuccess               | true      |
      | basket.status                | ACTIVE    |
      | basket.currency              | EUR       |
      | basket.createdDate           | [sysDate] |
      | basket.updatedDate           | [sysDate] |
      | basket.uuid                  | [GUID]    |
      | basket.items[0].skuId        | 007961    |
      | basket.items[0].quantity     | 1         |
      | basket.items[0].unitWasPrice | 13.99     |
      | basket.items[0].unitNowPrice | 11.99     |
      | basket.items[0].subtotal     | 13.99     |
      | basket.items[0].total        | 11.99     |
      | basket.items[0].images       | [value>1] |
      | basket.items[0].available    | true      |
      | basket.subtotal              | 28.98     |
      | basket.total                 | 24.98     |

  #Converted
  @BASKET-254
  Scenario: Verify Creating a new Horizon Basket using max item quantity exceeded
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/NL_payloads/basket_payload_NLv2.json replacing values
      | items[0].quantity | 30 |
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And the following items contains correct status
      | 013234 | ADDED |
      | 004025 | ADDED |
    And make sure following attributes exist within response json
      | horizonSuccess           | true    |
      | basket.items[0].skuId    | 013234  |
      | basket.items[0].quantity | 30      |
      | basket.items[0].brand    | grenade |
      | basket.site              | 40      |
      | basket.currency          | EUR     |
      | basket.locale            | nl-NL   |

   #Converted
  @sanity @negative
  Scenario: Valid POST request with No Items in payload json
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/no_items_payload_NL.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And make sure an empty basket with no items is returned


   #Converted
  @negative
  Scenario: Valid POST request with invalid SkuId in Json Payload
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/NL_payloads/invalid_skuId_payload_NL.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And the following items contains correct status
      | 000000 | NOTFOUND |
      | 099999 | NOTFOUND |
      | 0fffff | NOTFOUND |
    And make sure following attributes exist within response json
      | basket.items       | []        |
      | basket.currency    | EUR       |
      | basket.createdDate | [sysDate] |
      | basket.updatedDate | [sysDate] |
      | basket.uuid        | [GUID]    |
      | horizonSuccess     | true      |





