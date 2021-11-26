@api @IEbasket @horizonBasketIE
Feature: Horizon IE Basket Api - GET

    Scenario: Verify response for valid GET request for existing horizon basket
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/basket_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                       |
      | 048791 | 2             | Naturtint Root Retouch Crème - Light Blonde 45ml|
      | 018904 | 3             | Holland & Barrett BetaCarotene 100 Softgel Capsules 6mg|
      | 084144 | 2             | Seven Seas Haliborange Teens Omega-3 DHA 30 Capsules    |
    And make sure following attributes exist within response json
      | horizonSuccess                      | true     |
      | basket.subtotal                     |          |
      | basket.total                        |          |
      | basket.items[1].productId           |          |
      | basket.items[1].quantity            | 3 |
      | basket.items[1].available           | true     |
      | basket.items[1].subscribable        | true     |
      | basket.items[1].brand               | holland-barrett|
      | basket.items[1].category            | vitamins-supplements/vitamins/vitamin-a |

      | basket.items[0].productId           |          |
      | basket.items[0].available           | true     |
      | basket.items[0].subscribable        | true     |
      | basket.items[0].brand               | naturtint  |
      | basket.items[0].category            | natural-beauty/hair-care/hair-colouring |
      | basket.shipping                     |          |


  Scenario: Verify delivery restriction item responses for Horizon Basket
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/delivery_restriction_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | horizonSuccess                      | true     |
      | basket.currency                     | EUR     |
      | basket.subtotal                     |          |
      | basket.total                        |          |
      | basket.items[0].shippingRestriction |[value>1] |
      | basket.items[1].shippingRestriction |[value>1] |
      | basket.items[2].shippingRestriction |[value>1] |
      | basket.items[2].shippingRestriction |[EST, FIN, FRA, DEU, GIB, GRC, HUN, ISL, ITA, LVA, LIE, LUX, MLT, NLD, POL, PRT, ROU, SVK, SVN, ESP, SWE, AUT, BEL, BGR, HRV, CZE, DNK] |

  @negative
  Scenario: Verify horizon basket Api response for invalid NON GUID basketId
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/11111 endpoint
    Then The response status code should be 400

  @negative
  Scenario: Verify horizon basket Api response for non existing valid GUID basketId
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/b5d007d6-2b77-444d-9889-eeeaf38d3456 endpoint
    Then The response status code should be 404
    And make sure following attributes exist within response json
      | status    | NOT_FOUND           |
      | message   | 404 Not Found from GET https://hbi-basket-internal-eks.eu-west-1.dev.hbi.systems/api/v1/basket/b5d007d6-2b77-444d-9889-eeeaf38d3456 |


  Scenario: Verify large number of items being added & fetched from horizon basket
    Given I have successfully added items to Horizon Basket using basket/IE_payloads/large_30items_payload_IE.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 25 products in the basket
    And make sure items total collectively make the basket total
    And currently basket contains following items
       | skuId  | item_quantity | item_name                                       |
       | 017451 | 1             | Vitabiotics Ultra Vitamin C & Zinc Effervescent |
       | 004072 | 1             | Holland & Barrett Timed Release Vitamin C with Rose Hips 120 Caplets 1000mg |
       | 001435 | 1             | Solgar Ester-C 1000mg Vitamin C 90 Capsules     |
       | 001898 | 1             | Nature's Aid Vitamin C Drops 100mg Orange 50ml  |
       | 007198 | 1             | Together Health WholeVits Vitamin C 30 Capsules |
       | 005955 | 1             | Miaroma Relaxing Lavender Sleep Mist Spray 100ml|
       | 001698 | 1             | Holland & Barrett Gentle Iron 20mg 90 Capsules |
       | 001429 | 1             | Solgar Vitamin C 1000mg 100 Vegi Capsules       |
       | 004293 | 1             | Holland & Barrett Calcium Magnesium & Zinc 250 Caplets                |
       | 010190 | 1             | Holland & Barrett Iron & Vitamin C 30 Tablets   |
       | 005652 | 1             |                                                 |
       | 049203 | 1             |                                                 |
       | 030178 | 1             |                                                 |
       | 012050 | 1             |                                                 |
       | 012051 | 1             |                                                 |
       | 083610 | 1             | Dr Organic Aloe Vera Concentrated Cream 50ml    |
       | 086223 | 1             | The Vital Ingredient Ground Cinnamon 75g        |
       | 003162 | 1             | Holland & Barrett Pure Vitamin C 567g Powder 2500mg |
       | 004741 | 1             | Holland & Barrett Colon Care Plus Powder 340g |
       | 042727 | 1             | Aduna Moringa Green Superleaf 100g Powder |
       | 018334 | 1             | Jacob Hooy CBD+ Oil 5% 30ml |
       | 089874 | 1             | The Natural Wheat Bag Co Microwaveable Body Pillow Lavender |
       | 018889 | 1             | Holland & Barrett Vitamin E 400iu 250 Softgel Capsules |
       | 017810 | 1             | Vitabiotics Ultra Vitamin D 1000 IU Optimum Level 96 Tablets |
       | 004925 | 1             | Unbeelievable Health Bee Prepared Daily Defence 30 Capsules |


  @ignore
  Scenario: Verify getting apportionment info from horizon basket for promotion items with diff quantities
    Given I have successfully added items to Horizon Basket using basket/all_promotions_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | apportionment| true             |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
#     001698 item: Buy One Get One For a Penny
      | basket.items[0].productId                        | 60001698 |
      | basket.items[0].skuId                            | 001698   |
      | basket.items[0].apportionmentDetails[0].quantity | 2        |
      | basket.items[0].apportionmentDetails[0].subtotal | 21.78    |
      | basket.items[0].apportionmentDetails[0].total    | 10.90    |
      | basket.items[0].apportionmentDetails[0].discount | 10.88    |
      | basket.items[0].apportionmentDetails[0].discountChain|[value>=1]|
#     073594 item: Buy One Get One Half Price (herbs & spices)
      | basket.items[1].productId                        | 60073594 |
      | basket.items[1].skuId                            | 073594   |
      | basket.items[1].apportionmentDetails[0].quantity | 2        |
      | basket.items[1].apportionmentDetails[0].subtotal | 7.98     |
      | basket.items[1].apportionmentDetails[0].total    | 5.98     |
      | basket.items[1].apportionmentDetails[0].discount | 2.00     |
      | basket.items[1].apportionmentDetails[0].discountChain|[value>=1]|
      | basket.promotions.promotion | [Buy One Get One For a Penny, Buy one, Get one Half Price] |

  @ignore
  Scenario: Verify getting apportionment info from horizon basket for promotion items AND voucher code applied
    Given I have successfully added items to Horizon Basket using basket/apportionment_test_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | apportionment| true             |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | horizonSuccess                                   | true     |
      | basket.items[0].skuId                            | 001698   |
      | basket.items[0].apportionmentDetails[0].quantity | 1        |
      | basket.items[0].apportionmentDetails[0].subtotal | 10.89    |
      | basket.items[0].apportionmentDetails[0].total    | 5.82     |
      | basket.items[0].apportionmentDetails[0].discount | 5.07     |

      | basket.items[1].skuId                            | 003969   |
      | basket.items[1].apportionmentDetails[0].quantity | 1        |
      | basket.items[1].apportionmentDetails[0].subtotal | 9.49     |
      | basket.items[1].apportionmentDetails[0].total    | 5.08     |
      | basket.items[1].apportionmentDetails[0].discount | 4.41     |
    And I have successfully added vouchercode VEGETARIAN10 to Horizon basket
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | apportionment| true             |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | horizonSuccess                                   | true     |
      | basket.items[0].skuId                            | 001698   |
      | basket.items[0].apportionmentDetails[0].quantity | 1        |
      | basket.items[0].apportionmentDetails[0].subtotal | 10.89    |
      | basket.items[0].apportionmentDetails[0].total    | 5.23     |
      | basket.items[0].apportionmentDetails[0].discount | 5.66     |

      | basket.items[1].skuId                            | 003969   |
      | basket.items[1].apportionmentDetails[0].quantity | 1        |
      | basket.items[1].apportionmentDetails[0].subtotal | 9.49     |
      | basket.items[1].apportionmentDetails[0].total    | 4.58     |
      | basket.items[1].apportionmentDetails[0].discount | 4.91     |
      | basket.promotions.promotion | [Vegetarian 10%, Buy One Get One For a Penny, Buy one, Get one Half Price] |
