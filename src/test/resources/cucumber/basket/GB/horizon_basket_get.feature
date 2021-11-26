@api @basketGB @HorizonGB @A2B
Feature: Horizon Basket Api - GET

  @sanity @regression @BASKET-248 @BASKET-306 @basket_sanity
  Scenario: Verify response for valid GET request for existing horizon basket
    Given I have successfully added items to Horizon Basket using basket/basket_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                       |
      | 005955 | 3             | Miaroma Relaxing Lavender Sleep Mist Spray 100ml|
      | 048791 | 2             | Grenade Carb Killa Bar Peanut Nutter Bar 60g    |
    And make sure following attributes exist within response json
      | horizonSuccess                      | true     |
      | basket.subtotal                     |          |
      | basket.total                        |          |
      | basket.channel                      | WEB      |
#      | basket.items[1].productId           |          |
#      | basket.items[1].images              | [value>1]|
#      | basket.items[1].available           | true     |
#      | basket.items[1].subscribable        | true     |
#      | basket.items[1].brand               | naturtint|
#      | basket.items[1].category            | natural-beauty/hair-care/hair-colouring |
#      | basket.items[1].promoNames          | [Buy One Get One 1/2 Price]|

#      | basket.items[0].productId           |          |
#      | basket.items[0].images              | [value>1]|
#      | basket.items[0].available           | true     |
#      | basket.items[0].subscribable        | true     |
#      | basket.items[0].brand               | miaroma  |
#      | basket.items[0].category            | natural-beauty/aromatherapy-home |
#      | basket.shipping                     |          |
#      | basket.shipping.discount            | 0        |
#      | basket.shipping.price               | 2.99     |
# NOTE: The shipping info is now been removed from Basket Orchestrator which was being sent by promo_v1.1

  @sanity @regression @FUFLIL-1653
  Scenario: Verify delivery restriction item responses for Horizon Basket
    Given I have successfully added items to Horizon Basket using basket/delivery_restriction_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
#    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | horizonSuccess                      | true     |
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

    # preprod data is seriously buggured, only getting 15 out of these 30 items, once its back on track, will uncomment
  @BASKET-381  @horizonBasket
  Scenario: Verify large number of items being added & fetched from horizon basket
    Given I have successfully added items to Horizon Basket using basket/large_30items_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
#    And make sure there are 30 products in the basket
    And make sure items total collectively make the basket total
#    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                       |
      | 017451 | 1             | Vitabiotics Ultra Vitamin C & Zinc Effervescent |
      | 004072 | 1             | Holland & Barrett Timed Release Vitamin C with Rose Hips 120 Caplets 1000mg |
      | 001435 | 1             | Solgar Ester-C 1000mg Vitamin C 90 Capsules     |
      | 001898 | 1             | Nature's Aid Vitamin C Drops 100mg Orange 50ml  |
      | 007198 | 1             | Together Health WholeVits Vitamin C 30 Capsules |
      | 005955 | 1             | Miaroma Relaxing Lavender Sleep Mist Spray 100ml|
      | 001380 | 1             | Holland & Barrett Timed Release Vitamin B12 100 Tablets 1000ug |
      | 001429 | 1             | Solgar Vitamin C 1000mg 100 Vegi Capsules       |
      | 007022 | 1             | Minerva Pure Gold Collagen 50ml                 |
      | 010190 | 1             | Holland & Barrett Iron & Vitamin C 30 Tablets   |
      | 005652 | 1             |                                                 |
      | 049203 | 1             |                                                 |
      | 030178 | 1             |                                                 |
      | 012050 | 1             |                                                 |
      | 012051 | 1             |                                                 |

  @FULFIL-1333 @FULFIL-1402 @horizonBasket @basket_sanity
  Scenario: Verify getting apportionment info from horizon basket for promotion items with diff quantities
    Given I have successfully added items to Horizon Basket using basket/all_promotions_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | apportionment| true             |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
#    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
#     001698 item: Buy One Get One For a Penny
      | basket.items[0].productId                        | 60001698 |
      | basket.items[0].skuId                            | 001698   |
      | basket.items[0].apportionmentDetails[0].quantity | 2        |
      | basket.items[0].apportionmentDetails[0].subtotal | 21.78    |
      | basket.items[0].apportionmentDetails[0].total    | 9.35    |
      | basket.items[0].apportionmentDetails[0].discount | 12.43    |
      | basket.items[0].apportionmentDetails[0].discountChain|[value>=1]|
#     073594 item: Buy One Get One Half Price (herbs & spices)
      | basket.items[1].productId                        | 60096685|
      | basket.items[1].skuId                            | 096685 |
      | basket.items[1].apportionmentDetails[0].quantity | 2        |
      | basket.items[1].apportionmentDetails[0].subtotal | 5.78     |
      | basket.items[1].apportionmentDetails[0].total    | 5.78     |
      | basket.items[1].apportionmentDetails[0].discount | 0.00     |
#      | basket.items[1].apportionmentDetails[0].discountChain|[value>=1]|
      | basket.promotions.promotion | [Buy One Get One For a Penny, Buy one, Get one Half Price, Free Vitamin D when you buy any Vitamins & Supplements] |

  @FULFIL-1333 @FULFIL-1402 @regression @horizonBasket @basket_sanity
  Scenario: Verify getting apportionment info from horizon basket for promotion items AND voucher code applied
    Given I have successfully added items to Horizon Basket using basket/apportionment_test_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | apportionment| true             |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
#    And make sure there are 4 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | horizonSuccess                                   | true     |
      | basket.items[0].skuId                            | 001698   |
      | basket.items[0].apportionmentDetails[0].quantity | 1        |
      | basket.items[0].apportionmentDetails[0].subtotal | 10.89    |
      | basket.items[0].apportionmentDetails[0].total    | 3.79     |
      | basket.items[0].apportionmentDetails[0].discount | 7.10     |

      | basket.items[1].skuId                            | 073594   |
      | basket.items[1].apportionmentDetails[0].quantity | 1        |
      | basket.items[1].apportionmentDetails[0].subtotal | 3.99     |
      | basket.items[1].apportionmentDetails[0].total    | 3.46     |
      | basket.items[1].apportionmentDetails[0].discount | 0.53    |
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
      | basket.items[0].apportionmentDetails[0].total    | 3.42     |
      | basket.items[0].apportionmentDetails[0].discount | 7.47     |

      | basket.items[1].skuId                            | 073594  |
      | basket.items[1].apportionmentDetails[0].quantity | 1        |
      | basket.items[1].apportionmentDetails[0].subtotal | 3.99     |
      | basket.items[1].apportionmentDetails[0].total    | 3.12     |
      | basket.items[1].apportionmentDetails[0].discount | 0.87    |
      | basket.promotions.promotion | [Vegetarian 10%, Buy One Get One For a Penny, Buy one, Get one Half Price, Free Vitamin D when you buy any Vitamins & Supplements] |
