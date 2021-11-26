@api @IEbasket @horizonBasketIE
Feature: Test IE Horizon Basket Api - POST


  Scenario: Verify creating new Horizon GBP Basket with valid payload json
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/rfl_guestUser_payload_IE.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                              |
      | 021031 | 1             | Holland & Barrett Raspberry Ketone Complex 90 Capsules |
      | 086380 | 1             | Dr Organic Royal Jelly Leg & Vein Cream 200ml          |
      | 007026 | 2             | Spatone Apple Liquid Iron Supplement 28 x 20ml Sachets |
    And the following items contains correct status
      | 021031 | ADDED  |
      | 086380 | ADDED  |
      | 007026 | ADDED  |
      | 035296 | NOTFOUND  |
    And make sure following attributes exist within response json
      | horizonSuccess           | true         |
      | basket.status            | ACTIVE       |
      | basket.currency          | EUR          |
      | basket.createdDate       | [sysDate]    |
      | basket.updatedDate       | [sysDate]    |
      | basket.uuid              | [GUID]       |
      | basket.items[0].skuId    | 021031       |
      | basket.items[0].quantity | 1            |
      | basket.items[0].subtotal | [number]     |
      | basket.items[0].total    | [number]     |
      | basket.shipping          |              |
      | basket.items[0].brand    |holland-barrett|
      | basket.items[0].category |vitamins-supplements|


  Scenario: Verify creating new Horizon GBP Basket using query params on POST request
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | basic     | false  |
      | currency  | EUR    |
      | siteId    | 30     |
      | locale    | en-IE  |
    And I add a json payload using the file basket/IE_payloads/markdown_items_payload_IE.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And the following items contains correct status
      | 013234 | ADDED         |
      | 005611 | ADDED         |
    And make sure following attributes exist within response json
      | horizonSuccess               | true      |
      | basket.status                | ACTIVE    |
      | basket.currency              | EUR       |
      | basket.createdDate           | [sysDate] |
      | basket.updatedDate           | [sysDate] |
      | basket.uuid                  | [GUID]    |
      | basket.items[0].skuId        | 013234    |
      | basket.items[0].quantity     | 1         |
      | basket.items[0].unitWasPrice | 2.79     |
      | basket.items[0].unitNowPrice | 2.49      |
      | basket.items[0].subtotal     | 2.79     |
      | basket.items[0].total        | 2.49      |
      | basket.items[0].available    | true      |
      | basket.subtotal              | 5.58     |
      | basket.total                 | 4.98      |


  Scenario: Verify Creating a new Horizon Basket using max item quantity exceeded
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename basket/IE_payloads/basket_payload_IE.json replacing values
      | items[0].quantity | 32          |
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And the following items contains correct status
      | 048791 | ADDED  |
      | 018904 | ADDED  |
      | 084144 | ADDED  |
    And make sure following attributes exist within response json
      | horizonSuccess             | true      |
      | basket.items[0].skuId      | 048791    |
      | basket.items[0].quantity   | 30        |
      | basket.items[0].brand      | naturtint |
      | basket.items[0].category   | natural-beauty/hair-care/hair-colouring|

  @sanity @negative
  Scenario: Valid POST request with No Items in payload json
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/no_items_payload_IE.json
    When I send a POST request to v1/horizon/basket endpoint
    Then The response status code should be 200
    And make sure an empty basket with no items is returned


  @negative
  Scenario: Valid POST request with invalid SkuId in Json Payload
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file basket/IE_payloads/invalid_skuId_payload_IE.json
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

