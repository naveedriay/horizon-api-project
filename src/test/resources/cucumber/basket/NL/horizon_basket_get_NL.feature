@api @NLbasket @HorizonBasketNL @A2B
Feature: Test NL Horizon Basket Api - GET

  #Converted
  @sanity @regression @BASKET-248 @BASKET-306 @basket_sanity
  Scenario: Verify response for valid GET request for existing horizon basket
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/atg_basket_payload_NLv2.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 2 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                   |
      | 013234 | 3             | Grenade Carb Killa Peanut                   |
      | 004025 | 1             | GDr. Organic Virgin Coconut Oil Skin Lotion |
    And make sure following attributes exist within response json
      | horizonSuccess               | true                                                             |
      | basket.subtotal              |                                                                  |
      | basket.total                 |                                                                  |
      | basket.items[1].productId    |                                                                  |
      | basket.items[1].images       | [value>1]                                                        |
      | basket.items[1].available    | true                                                             |
      | basket.items[1].subscribable | true                                                             |
      | basket.items[1].brand        | dr-organic                                                       |
      | basket.items[1].category     | persoonlijke-verzorging/lichaamsverzorging/bodylotion-bodybutter |


      | basket.items[0].productId    |                                                                  |
      | basket.items[0].images       | [value>1]                                                        |
      | basket.items[0].available    | true                                                             |
      | basket.items[0].subscribable | true                                                             |
      | basket.items[0].brand        | grenade                                                          |
      | basket.items[0].category     | sportvoeding/eiwitrepen                                          |
      | basket.shipping              |                                                                  |
      | basket.site                  | 40                                                               |
      | basket.currency              | EUR                                                              |
      | basket.locale                | nl-NL                                                            |

   #Converted
  @sanity @regression @FUFLIL-1653
  Scenario: Verify delivery restriction item responses for Horizon Basket
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/delivery_restriction_payload_NL.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | horizonSuccess                      | true                                                                                                                                    |
      | basket.subtotal                     |                                                                                                                                         |
      | basket.total                        |                                                                                                                                         |
      | basket.items[1].shippingRestriction | [value>1]                                                                                                                               |


    #Converted
  @negative
  Scenario: Verify horizon basket Api response for invalid NON GUID basketId
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/11111 endpoint
    Then The response status code should be 400

  #Converted
  @negative
  Scenario: Verify horizon basket Api response for non existing valid GUID basketId
    Given I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/b5d007d6-2b77-444d-9889-eeeaf38d3456 endpoint
    Then The response status code should be 404
    And make sure following attributes exist within response json
      | status  | NOT_FOUND                                                                                                                           |
      | message | 404 Not Found from GET https://hbi-basket-internal-eks.eu-west-1.dev.hbi.systems/api/v1/basket/b5d007d6-2b77-444d-9889-eeeaf38d3456 |

    # Converted
  @BASKET-381  @horizonBasket
  Scenario: Verify large number of items being added & fetched from horizon basket
    Given I have successfully added items to Horizon Basket using basket/NL_payloads/large_30items_payload_NL.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 30 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And currently basket contains following items
      | skuId  | item_quantity | item_name                                                       |
      | 018904 | 1             | Holland & Barrett Bétacaroteen                                  |
      | 007743 | 1             | Holland & Barrett Cod Liver Oil 1000mg 120 Capsules             |
      | 007745 | 1             | Holland & Barrett Cod Liver Oil 1000mg 240 Capsules             |
      | 012160 | 1             | Holland & Barrett Selenium Met Vitamine A, C En E               |
      | 032979 | 1             | Möllers Levertraan Citroen 250 ml                               |

      | 010570 | 1             | Lucovitaal Vitamine B12 1000mcg 60 Kauwtabletten                |
      | 004799 | 1             | Garden Of Life Raw Vitamine B12 Energie                         |
      | 002812 | 1             | Holland & Barrett Vitamine B 100mg Timed Release                |
      | 016667 | 1             | Physalis Happy Mama Pronatal+ Tabletten                         |
      | 004801 | 1             | Garden Of Life Raw B Complex                                    |
      | 010569 | 1             | Lucovitaal Vitamine B12 1000mcg 30 Kauwtabletten                |

      | 058275 | 1             | A.Vogel Echinaforce Junior + Vitamine C                         |
      | 004072 | 1             | Holland & Barrett Vitamine C Timed Release 1000mg 120 Tabletten |
      | 092549 | 1             | Royal Green Camu Camu + Vitamine C                              |
      | 025308 | 1             | A.Vogel Echinaforce + Vitamine C                                |
      | 032295 | 1             | Purasana Raw Camu Camu Poeder Bio                               |
      | 008463 | 1             | Royal Green Vitamine C Complex                                  |

      | 016558 | 1             | Physalis Vitamine D3 Forte                                      |
      | 034735 | 1             | Royal Green Vitamine D3                                         |
      | 015605 | 1             | Holland & Barrett Vitamine D3 25mcg 100 Tabletten               |
      | 010994 | 1             | Holland & Barrett Vitamine D3 10mcg Capsules                    |
      | 098445 | 1             | Pharma Nord Bio Vitamine D3                                     |
      | 008478 | 1             | Lucovitaal Vitamine D3 75mcg                                    |

      | 004000 | 1             | Precision Engineered Whey Protein Banaan 908gr                  |
      | 008176 | 1             | Purition Original Vanille en Macadamia 1 Portie                 |
      | 002694 | 1             | Precision Engineered Whey Proteïne Vanille 908gr                |
      | 002692 | 1             | Precision Engineered Whey Protein Chocolade 908gr               |
      | 008459 | 1             | Whey Concentrate Protein                                        |
      | 006957 | 1             | Precision Engineered Whey Proteïn Cookies & Cream 250gr         |
      | 006958 | 1             | Precision Engineered Whey Proteïn Natural 250gr                 |
    And make sure following attributes exist within response json
      | basket.site     | 40    |
      | basket.currency | EUR   |
      | basket.locale   | nl-NL |

  #Not required
  @FULFIL-1333 @FULFIL-1402 @horizonBasket @basket_sanity @ignore
  Scenario: Verify getting apportionment info from horizon basket for promotion items with diff quantities
    Given I have successfully added items to Horizon Basket using basket/all_promotions_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | apportionment | true |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 3 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
#     001698 item: Buy One Get One For a Penny
      | basket.items[0].productId                             | 60001698                                                   |
      | basket.items[0].skuId                                 | 001698                                                     |
      | basket.items[0].apportionmentDetails[0].quantity      | 2                                                          |
      | basket.items[0].apportionmentDetails[0].subtotal      | 21.78                                                      |
      | basket.items[0].apportionmentDetails[0].total         | 10.90                                                      |
      | basket.items[0].apportionmentDetails[0].discount      | 10.88                                                      |
      | basket.items[0].apportionmentDetails[0].discountChain | [value>=1]                                                 |
#     073594 item: Buy One Get One Half Price (herbs & spices)
      | basket.items[1].productId                             | 60073594                                                   |
      | basket.items[1].skuId                                 | 073594                                                     |
      | basket.items[1].apportionmentDetails[0].quantity      | 2                                                          |
      | basket.items[1].apportionmentDetails[0].subtotal      | 7.98                                                       |
      | basket.items[1].apportionmentDetails[0].total         | 5.98                                                       |
      | basket.items[1].apportionmentDetails[0].discount      | 2.00                                                       |
      | basket.items[1].apportionmentDetails[0].discountChain | [value>=1]                                                 |
      | basket.promotions.promotion                           | [Buy One Get One For a Penny, Buy one, Get one Half Price] |

    #Not required
  @FULFIL-1333 @FULFIL-1402 @regression @horizonBasket @basket_sanity @ignore
  Scenario: Verify getting apportionment info from horizon basket for promotion items AND voucher code applied
    Given I have successfully added items to Horizon Basket using basket/apportionment_test_payload.json
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | apportionment | true |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure there are 4 products in the basket
    And make sure items total collectively make the basket total
    And make sure items subtotal collectively make the basket subtotal
    And make sure following attributes exist within response json
      | horizonSuccess                                   | true   |
      | basket.items[0].skuId                            | 001698 |
      | basket.items[0].apportionmentDetails[0].quantity | 1      |
      | basket.items[0].apportionmentDetails[0].subtotal | 10.89  |
      | basket.items[0].apportionmentDetails[0].total    | 5.82   |
      | basket.items[0].apportionmentDetails[0].discount | 5.07   |

      | basket.items[1].skuId                            | 003969 |
      | basket.items[1].apportionmentDetails[0].quantity | 1      |
      | basket.items[1].apportionmentDetails[0].subtotal | 9.49   |
      | basket.items[1].apportionmentDetails[0].total    | 5.08   |
      | basket.items[1].apportionmentDetails[0].discount | 4.41   |
    And I have successfully added vouchercode VEGETARIAN10 to Horizon basket
    And I create a new basket api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | apportionment | true |
    When I send a GET request to v1/horizon/basket/{basketUUID} endpoint
    Then The response status code should be 200
    And make sure items total collectively make the basket total
    And make sure following attributes exist within response json
      | horizonSuccess                                   | true                                                                       |
      | basket.items[0].skuId                            | 001698                                                                     |
      | basket.items[0].apportionmentDetails[0].quantity | 1                                                                          |
      | basket.items[0].apportionmentDetails[0].subtotal | 10.89                                                                      |
      | basket.items[0].apportionmentDetails[0].total    | 5.23                                                                       |
      | basket.items[0].apportionmentDetails[0].discount | 5.66                                                                       |

      | basket.items[1].skuId                            | 003969                                                                     |
      | basket.items[1].apportionmentDetails[0].quantity | 1                                                                          |
      | basket.items[1].apportionmentDetails[0].subtotal | 9.49                                                                       |
      | basket.items[1].apportionmentDetails[0].total    | 4.58                                                                       |
      | basket.items[1].apportionmentDetails[0].discount | 4.91                                                                       |
      | basket.promotions.promotion                      | [Vegetarian 10%, Buy One Get One For a Penny, Buy one, Get one Half Price] |
