@api @atg-scraper @discover @review

Feature: ATG Scraper

  @scraperGet @DISCOVER-1348 @ignore
  Scenario Outline: Get Scraper Api for path=<category-path>
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | path         | <category-path> |
    When I send a GET request to getproductlist endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | totalResults | [number] |
      | totalPages   | [number] |
      | pageSize     | 20       |
      | pageIndex    | 1        |

    Examples:
      | category-path                                | total_results | total_pages |
      | vitamins-supplements/vitamins                | 370           | 19          |
      | food-drink/drinks                            | 562           | 29          |
      | sports-nutrition                             | 1072          | 54          |
      | free-from                                    | 479           | 24          |
      | natural-beauty/new-in-beauty                 | 196           | 10          |
      | weight-management/weight-management-shop-all | 239           | 12          |
      | household                                    | 245           | 13          |
      | offers/new-in                                | 589           | 30          |
      | vitamins-supplements/cbd                     | 33            | 2           |
      | vitamins-supplements/homeopathic-flower-remedies |  176      | 9           |

  # NOTE: This test is IGNORED because the GlobalBanners are now configured in Magnolia API rather than via Scraper API.
  @scraperGet @DISCOVER-1349 @ignore
  Scenario Outline: GlobalBanner presence using /getproductlistheader endpoint
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | path         | /shop/<category-path> |
    When I send a GET request to getproductlistheader endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | globalBanner.displayGlobalBanner  | [boolean] |
      | globalBanner.href                 |           |
      | globalBanner.srcset.desktopBanner |           |
      | globalBanner.srcset.mobileBanner  |           |
      | meta.title                        |           |
      | meta.description                  |           |
      | countdown.displayCountdown        |           |

    Examples:
      | category-path                                        |
      | vitamins-supplements/vitamins                        |
      | vitamins-supplements/vitamins/vitamin-c              |
      | vitamins-supplements/vitamins/vitamin-d              |
      | natural-beauty/washing-bathing/hand-wash             |
      | vitamins-supplements/homeopathic-flower-remedies     |
      | vitamins-supplements/cbd                             |
      | vitamins-supplements/vitamins/                       |
      | vitamins-supplements/minerals/zinc                   |
      | vitamins-supplements/minerals/magnesium              |
      | vitamins-supplements/vitamins/multivitamins          |
      | vitamins-supplements/vitamins-supplements-shop-all   |
      | vitamins-supplements/condition/cold-immune-support   |
      | food-drink/drinks                                    |
      | food-drink/home-baking/flour                         |
      | food-drink/honey-jams-spreads/honey/manuka-honey     |
      | food-drink/dried-fruit-nuts-seeds/nuts               |
      | offers/1-2-price                                     |
      | sports-nutrition                                     |
      | free-from                                            |
      | natural-beauty/new-in-beauty                         |
      | weight-management/weight-management-shop-all         |
      | household                                            |
      | offers/new-in                                        |

  @scraperGet @search @content_sanity @ignore
  Scenario Outline: Verify ATG search return SRP data for different top search string <category>
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | path         | /search    |
      | isSearch     | true       |
      | query        | <category> |
    When I send a GET request to /getproductlist endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | listedCategory.title | You searched for '<category>' |
      | totalResults         | [number]                      |

    Examples:
      | category     |
      | vitamin-c    |
      | turmeric     |
      | collagen     |
      | honey        |
      | manuka honey |
      | yeast        |
      | coconut oil  |
      | vitamin d3   |

  @scraperGet @search @DISCOVER-1384 @ignore
  Scenario Outline: ATG search against a SKU redirects to PDP page
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | path         | /search    |
      | isSearch     | true       |
      | query        | <sku-id>   |
    When I send a GET request to /getproductlist endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | redirect     | <redirect string> |

    Examples:
      | sku-id | redirect string                                                         |
      | 003969 | /shop/product/dr-organic-moroccan-argan-oil-day-cream-60003969?skuid=003969 |
      | 013790 | /shop/product/vitabiotics-perfectil-tablets-60013790?skuid=013790       |
      | 048776 | /shop/product/manuka-pharm-manuka-honey-mgo-70-60048775?skuid=048776    |

  @DISCOVER-1404 @comparing @ignore
  Scenario Outline: Compare ATG & OneSearch SRP against <category> for IRELAND site
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/srp_search_payload.json replacing values
      | SiteId       |  30              |
      | Query        | <category>       |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And I save the onesearch response json
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | path         | /search     |
      | isSearch     | true        |
      | query        | <category>  |
      | host         | www.hollandandbarrett.ie |
    When I send a GET request to /getproductlist endpoint
    Then The response status code should be 200
    And make sure you can compare following attributes among the json responses for <category>
      | scraper_attribute | onesearch_attribute                 |
      | totalResults      | results.ProductProcessor.totalFound |

    Examples:
      | category     |
      | vitamin-c    |
      | turmeric     |
      | collagen     |
      | hair care    |
      | skin oil     |
      | yeast        |
      | coconut oil  |
      | vitamin d3   |

  @scraperGet @DISCOVER-1409 @ignore
  Scenario Outline: Verify ATG for search query with special chars
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    When I send a GET request to getproductlist?path=/search&host=www.hollandandbarrett.com&isSearch=true&query=<search-param> endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | searchTerm   | <search-term>    |
      | totalResults | [number]         |

    Examples:
      | search-param          | search-term       |
      |holland%20%26%20barrett| holland & barrett |
      | food%20%26%20drink    | food & drink      |
      | mother%20%26%20baby   | mother & baby     |
      | nature%27s%20garden   | nature's garden   |
      | bio-kult              | bio-kult          |
      | burt%27s              | burt's            |
      | enjoy!                | enjoy!            |
      | manuka%20(MGO%2070)   | manuka (MGO 70)   |
      | Dr%20%2A              | Dr *              |
#      | KIKI-Heal-h         | KIKI Heal h       |

      | heath%20%26%20heather | heath & heather   |
      | dr.%20paw%20paw       | dr. paw paw       |
      | nature%27s%20way      | nature's way      |
      | enjoy%21              | enjoy!            |


  @scraperGet @DISCOVER-1407 @ignore
  Scenario Outline: Brand pages from ATG for brand <brand-name>
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | path         | /brands/<brand-name> |
    When I send a GET request to getproductlist endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | totalResults       | [number]  |
      | results            | [value>1] |
      | facets.sortOptions | [value>1] |

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


  @getOffers @DISCOVER-1184 @ignore
  Scenario Outline: Verify ATG offers & promotions
    Given I create a new scraper api request with following headers
      | Content-Type  | application/json |
    And I add following attributes in the request query string
      | path         | /shop/offers/<offer-name> |
    When I send a GET request to getproductlist endpoint
    Then The response status code should be 200
#    And make sure all the elements returned have <offer-txt> in its promotion
    And make sure following attributes exist within response json
      | totalResults | [number] |
      | totalPages   | [number] |

    Examples:
      | offer-name                  | offer-txt                   |
      | 1-2-price                   | 1/2 Price                   |
      | price-drop                  | Price Drop                  |
      | buy-one-get-one-1-2-price   | Buy One Get One 1/2 Price   |
      | buy-one-get-one-for-a-penny | Buy One Get One for a Penny |


# Testing ATG Availability API at https://hb-preprod.hollandandbarrett.net/rest/api/catalog/availability
  @regression @ignore
  Scenario: Check ATG PreProd Availability Api for valid skuIds availability
    Given I create a new preProd-rest api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | skuId_0  | 038107 |
      | skuId_1  | 007198 |
      | skuId_2  | 003969 |
      | skuId_3  | 017451 |
      | skuId_4  | 043197 |
      | skuId_5  | 038106 |
      | skuId_6  | 040087 |
      | skuId_7  | 001435 |
      | skuId_8  | 033618 |
      | skuId_9  | 004072 |
      | skuId_10 | 001898 |
      | skuId_11 | 001429 |
      | skuId_12 | 043179 |
      | skuId_13 | 001380 |
      | skuId_14 | 010190 |
      | skuId_15 | 040564 |
      | skuId_16 | 040091 |
      | skuId_17 | 040092 |
      | skuId_19 | 040093 |
      | skuId_20 | 045807 |
      | skuId_21 | 005652 |
      | skuId_22 | 007022 |
      | skuId_23 | 011023 |
      | skuId_24 | 049203 |
#      | skuId_25 | 038075  | OUTOFSTOCK
      | skuId_26 | 038077 |
      | skuId_27 | 036704 |
      | skuId_29 | 030178 |
      | skuId_30 | 012050 |
    When I send a GET request to catalog/availability endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | items[0].skuId                 |         |
      | items[0].status                | INSTOCK |
      | items[0].stock-based-promotion |         |

  @get @comparison @DISCOVER-1350
  Scenario Outline: Verify & Compare the results found among oneSearch & ATG Scraper Api
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/plp_payload.json replacing values
      | categorypath | <CategoryPath> |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And I save the onesearch response json
    And I create a new scraper api request with following headers
      | Content-Type | application/json |
    When I send a GET request to getproductlist?path=<CategoryPath> endpoint
    Then The response status code should be 200
    And make sure you can compare following attributes among the json responses for <CategoryPath>
      | scraper_attribute | onesearch_attribute                 |
      | totalResults      | results.ProductProcessor.totalFound |

    Examples:
      | CategoryPath                                 |
      | vitamins-supplements/vitamins                |
      | food-drink/drinks                            |
      | sports-nutrition                             |
      | free-from                                    |
      | natural-beauty/new-in-beauty                 |
      | weight-management/weight-management-shop-all |
      | household                                    |
      | offers/new-in                                |


  Scenario Outline: Verify & Compare the stock status between Availability API and the 1S API
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/skuId_stock_payload.json replacing values
      | skuIds[0] | <SkuId> |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And I save the onesearch response json

    And I create a new prod-availability api request with following headers
      | Content-Type | application/json |
    When I send a GET request to availability?skuId_1=<SkuId> endpoint
    Then The response status code should be 200
    And make sure you can compare following attributes among the json responses for <SkuId>
      | availability_api_attribute | onesearch_attribute                              |
      | items[0].status            | results.ProductProcessor.results[0].stock_status |

    Examples:
      | SkuId     |
      | 018888    |
      | 045046    |
      | 042133    |