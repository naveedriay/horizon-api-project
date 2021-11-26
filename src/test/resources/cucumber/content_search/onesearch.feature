@api @onesearch @discover
Feature: OneSearch

  @oneSearch
  Scenario: Verify Prod OneSearch ability to check skuIds availability
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file onesearch/skuId_payload.json
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | results.ProductProcessor.success        | true |
      | results.ProductProcessor.totalFound     | 14   |
      | results.ProductProcessor.totalRetrieved | 10   |

  @plp @DISCOVER-1350 @content_sanity
  Scenario: OneSearch Query for PDP
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file onesearch/pdp_payload.json
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | results.ProductProcessor.success                                     | true                                   |
      | results.ProductProcessor.totalFound                                  | 1                                      |
      | results.ProductProcessor.totalRetrieved                              | 1                                      |
      | results.ProductProcessor.results[0].is_subscribable                  | false                                  |
      | results.ProductProcessor.results[0].brand.name                       | Almighty Foods                         |
      | results.ProductProcessor.results[0].brand.id                         | 3028                                   |
      | results.ProductProcessor.results[0].list_price                       | 2.69                                   |
      | results.ProductProcessor.results[0].product.name                     | Almighty Foods Raw White CBD Chocolate |
      | results.ProductProcessor.results[0].stock_promotion_threshold.enable | [boolean]                              |
      | results.ProductProcessor.results[0].stock_promotion_threshold.price  | 0.99                                   |
      | results.ProductProcessor.results[0].stock_promotion_threshold.stock  | [number]                               |
     # | results.ProductProcessor.results[0].stock_promotion_threshold.key               | DECEMBER[Short Dated: End of December 2020]   |

  @DISCOVER-1350
  Scenario Outline: OneSearch Query for PLP category <CategoryPath>
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/plp_payload.json replacing values
      | SiteId       | <site-id>      |
      | categorypath | <CategoryPath> |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | environment                         | Production |
      | searchId                            | [GUID]     |
      | results.ProductProcessor.totalFound | [number]   |
      | results.ProductProcessor.results    | [value>1]  |
      | results.ProductsSortOptions.success | true       |
      | results.ProductsSortOptions.results | [value>1]  |

    Examples:
      | site-id | CategoryPath                                 |
#      GB .COM SITE PLP IS HERE
      | 10      | vitamins-supplements/vitamins                |
      | 10      | food-drink/drinks                            |
      | 10      | sports-nutrition                             |
      | 10      | free-from                                    |
      | 10      | natural-beauty/new-in-beauty                 |
      | 10      | weight-management/weight-management-shop-all |
      | 10      | household                                    |
      | 10      | offers/new-in                                |
#      IRELAND .ie SITE PLP IS HERE
      | 30      | vitamins-supplements/vitamins                |
      | 30      | food-drink/drinks                            |
      | 30      | sports-nutrition                             |
      | 30      | free-from                                    |
      | 30      | natural-beauty/new-in-beauty                 |
      | 30      | weight-management/weight-management-shop-all |
      | 30      | household                                    |
      | 30      | offers/new-in                                |

  @content_sanity
    Examples: COM Ireland Sanity
      | site-id | CategoryPath                                 |
      | 30      | food-drink/drinks                            |
      | 10      | sports-nutrition                             |
      | 30      | offers/new-in                                |
      | 10      | weight-management/weight-management-shop-all |

  @DISCOVER-1350 @regression
  Scenario Outline: OneSearch Query for Search <category>
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/srp_search_payload.json replacing values
      | Query        | <category>       |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | environment                         | Production |
      | searchId                            | [GUID]     |
      | results.ProductProcessor.totalFound | [number]   |
      | results.ProductProcessor.results    | [value>1]  |

    Examples: Full Pack
      | category     |
      | vitamin-c    |
      | turmeric     |
      | cbd          |
      | hair care    |
      | skin oil     |
      | yeast        |
      | coconut oil  |

    @content_sanity
    Examples: OneSearch Sanity
      | category    |
      | vitamin-c   |
      | hair care   |
      | coconut oil |

  Scenario Outline: OneSearch Query for Redirected Search <category>
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/srp_search_payload.json replacing values
      | Query        | <category>       |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | environment                           | Production |
      | searchId                              | [GUID]     |
      | results.RedirectProcessor.success     | true       |
      | results.RedirectProcessor             | [NOTEMPTY] |
      | results.RedirectProcessor.results     | [value>=1] |
      | results.RedirectProcessor.results.redirectUrl | [NOTEMPTY] |

    Examples:
      | category           |
      | vitamin d3         |
      | Sanitizers         |
      | Face Wipes         |
      | clean & conscious  |
      | m+lk               |
      | subscribe and save |
      | immune system      |
      | frozen food        |



  @DISCOVER-1350
  Scenario Outline: OneSearch Query for NL/BE site with PLP Payload for category <CategoryPath>
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/plp_payload.json replacing values
      | SiteId       | <site-id>      |
      | Locale       |  nl            |
      | categorypath | <CategoryPath> |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | environment                         | Production |
      | searchId                            | [GUID]     |
      | results.ProductProcessor.totalFound | [number]   |
      | results.ProductProcessor.results    | [value>1]  |
      | results.ProductsSortOptions.success | true       |
      | results.ProductsSortOptions.results | [value>1]  |

    Examples:
      | site-id | CategoryPath                       |
#      NETHERLAND .nl SITE PLP TESTS
      | 40      | vitamines-supplementen/vitamines   |
      | 40      | voeding-dranken/dranken            |
      | 40      | voeding-dranken/speciale-voeding   |
      | 40      | sportvoeding                       |
      | 40      | persoonlijke-verzorging            |
      | 40      | persoonlijke-verzorging/bad-douche |
      | 40      | sportvoeding/nieuw-in-sportvoeding |
      | 40      | sportvoeding/nieuw-in-sportvoeding |
#      BELGIUM .be SITE PLP TESTS
      | 60      | vitamines-supplementen/vitamines   |
      | 60      | voeding-dranken/dranken            |
      | 60      | voeding-dranken/speciale-voeding   |
      | 60      | sportvoeding                       |
      | 60      | persoonlijke-verzorging            |
      | 60      | persoonlijke-verzorging/bad-douche |
      | 60      | sportvoeding/nieuw-in-sportvoeding |

    @content_sanity
    Examples: Benelux Sanity
      | site-id | CategoryPath                       |
      | 40      | vitamines-supplementen/vitamines   |
      | 60      | voeding-dranken/dranken            |
      | 40      | persoonlijke-verzorging/bad-douche |
      | 60      | sportvoeding                       |

  @DISCOVER-1559 @content_sanity
  Scenario: Verify default sort options being used by OneSearch
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file onesearch/plp_payload.json
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure attribute results.ProductProcessor.query contains sort":[{"not_available":{"order":"asc"}}

  @getArticles @DISCOVER-1345
  Scenario Outline:  Multiple Image Resolutions returned for Articles <query-string>
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/articleList_payload.json replacing values
      | Query | <query-string> |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure multiple image resolution exists for <query-string> articles
    And make sure following attributes exist within response json
      | environment | Production |
      | searchId    | [GUID]     |

    Examples:
      | query-string   |
      | eye care       |
      | coconut oil    |
      | manuka honey   |
      | cbd            |
      | hair care      |
      | immune support |
      | tea tree       |
      | aloevera       |
      | mens health    |
      | womens health  |
      | hair care      |

  @content_sanity
    Examples:
      | query-string   |
      | manuka honey   |
      | womens health  |

  @getBrands @DISCOVER-1405
  Scenario Outline: OneSearch Query to sort Brands by price
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/sortOptions_brands_payload.json replacing values
      | BrandSlug    | <brand-name>     |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And I verify the items returned in sorted order by price
    And make sure following attributes exist within response json
      | results.ProductsSortOptions.name    | SortOptions |
      | results.ProductsSortOptions.type    | Products    |
      | results.ProductsSortOptions.success | true        |
      | results.ProductsSortOptions.results | [value>1]   |

   Examples:
      | brand-name       |
      | dr-organic       |
      | holland-barrett  |
      | hairburst        |
      | weleda           |
      | solgar           |
      | phd              |
      | starpowa         |
      | optimum-nutrition|
      | faith-in-nature  |
      | pukka            |

    @content_sanity
    Examples:
      | brand-name      |
      | holland-barrett |
      | solgar          |
      | pukka           |

  @getBrands @DISCOVER-1407
  Scenario Outline: OneSearch Query for Brand <brand-name>
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/getbrandslug_payload.json replacing values
      | BrandSlug    | <brand-name>     |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | environment                         | Production |
      | searchId                            | [GUID]     |
      | results.ProductProcessor.totalFound | [number]   |
      | results.ProductProcessor.results    | [value>1]  |
      | results.ProductsSortOptions.results | [value>1]  |

    Examples:
      | brand-name       |
      | dr-organic       |
      | holland-barrett  |
      | hairburst        |
      | weleda           |
      | solgar           |
      | phd              |
      | starpowa         |
      | optimum-nutrition|
      | faith-in-nature  |
      | pukka            |
      | heath-heather    |
      | dr-paw-paw       |
      | nature-s-way     |
      | bio-kult         |
      | burt-s-bees      |
      | enjoy            |

    @content_sanity
    Examples:
      | brand-name       |
      | dr-organic       |
      | starpowa         |
      | faith-in-nature  |

  @getOffers @DISCOVER-1184 @regression
  Scenario Outline: OneSearch Query to get Offers & Promotions for <offer-name>
    Given I create a new onesearch api request with following headers
      | Content-Type  | application/json |
    And I add a json payload using filename onesearch/getoffers_payload.json replacing values
      | PromotionSlug | <offer-name>     |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure all the elements returned have <offer-txt> in its promotion
    And make sure following attributes exist within response json
      | environment                         | Production |
      | searchId                            | [GUID]     |
      | results.ProductProcessor.totalFound | [number]   |
      | results.ProductProcessor.results    | [value>=0] |
      | results.ProductsSortOptions.results | [value>1]  |

    Examples:
      | offer-name                  | offer-txt                   |
      | 1-2-price                   | 1/2 Price                   |
#      | price-drop                  | Price Drop                  |
      | 2-for-80p                   | 2 for 80p                   |
      | flash-sale-50-off           | Buy One Get One 1/2 Price   |
      | buy-one-get-one-1-2-price   | Buy One Get One 1/2 Price   |
      | buy-one-get-one-for-a-penny | Buy One Get One for a Penny |
      | bigger-packs-better-value   | Bigger Packs Better Value   |

    @content_sanity
    Examples:
      | offer-name                  | offer-txt                   |
      | buy-one-get-one-1-2-price   | Buy One Get One 1/2 Price   |
      | buy-one-get-one-for-a-penny | Buy One Get One for a Penny |

  @getBrands @DISCOVER-1546
  Scenario Outline: OneSearch Query for Brand suggestions results of <query-name>
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/brand_suggestions_payload.json replacing values
      | Query    | <query-name>     |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | environment                             | Production |
      | results["Category Suggestions"].results | [value>=1] |
      | results["Brand Suggestions"].results    | [value>=0] |
      | results["Product Suggestions"].results  | [value>=1] |
      | results["Content Suggestions"].results  | [value>=0] |

    Examples:
      | query-name     |
      | protein        |
      | coconut        |
      | cbd            |
      | mens           |
      | honey          |
      | slim           |
      | whey           |

    @content_sanity
    Examples:
      | query-name |
      | protein    |
      | slim       |
      | cbd        |

  @oneSearch @content_sanity
  Scenario: OneSearch Query for skuIds Availability
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file onesearch/skuId_payload.json
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | results.ProductProcessor.success        | true |
      | results.ProductProcessor.totalFound     | 14   |
      | results.ProductProcessor.totalRetrieved | 10   |