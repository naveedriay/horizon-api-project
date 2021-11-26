@api @atg-scraper @discover @nl_be_scraper @review

Feature: Benelux

  @scraperGet @DISCOVER-1348 @ignore
  Scenario Outline: Verify Benelux Scraper Api for path=<category-path>
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | path         | <category-path> |
      | host         | www.hollandandbarrett.nl |
    When I send a GET request to getproductlist endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | totalResults | [number] |
      | totalPages   | [number] |
      | pageSize     | 20       |
      | pageIndex    | 1        |

    Examples:
      | category-path                      |
      | vitamines-supplementen/vitamines   |
      | voeding-dranken/dranken            |
      | voeding-dranken/speciale-voeding   |
      | sportvoeding                       |
      | persoonlijke-verzorging            |
      | persoonlijke-verzorging/bad-douche |
      | sportvoeding/nieuw-in-sportvoeding |
      | sportvoeding/nieuw-in-sportvoeding |


  # NOTE: This test is IGNORED because the GlobalBanners are now configured in Magnolia API rather than via Scraper API.
  @scraperGet @DISCOVER-1349 @ignore
  Scenario Outline: Verify GlobalBanner presence using /getproductlistheader endpoint
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
      | category-path                      |
      | vitamines-supplementen/vitamines   |
      | voeding-dranken/dranken            |
      | voeding-dranken/speciale-voeding   |
      | sportvoeding                       |
      | persoonlijke-verzorging            |
      | persoonlijke-verzorging/bad-douche |
      | sportvoeding/nieuw-in-sportvoeding |
      | sportvoeding/nieuw-in-sportvoeding |


#      | vitamins-supplements/vitamins                        |
#      | vitamins-supplements/vitamins/vitamin-c              |
#      | vitamins-supplements/vitamins/vitamin-d              |
#      | natural-beauty/washing-bathing/hand-wash             |
#      | vitamins-supplements/homeopathic-flower-remedies     |
#      | vitamins-supplements/cbd                             |
#      | vitamins-supplements/vitamins/                       |
#      | vitamins-supplements/minerals/zinc                   |
#      | vitamins-supplements/minerals/magnesium              |
#      | vitamins-supplements/vitamins/multivitamins          |
#      | vitamins-supplements/vitamins-supplements-shop-all   |
#      | vitamins-supplements/condition/cold-immune-support   |
#      | food-drink/drinks                                    |
#      | food-drink/home-baking/flour                         |
#      | food-drink/honey-jams-spreads/honey/manuka-honey     |
#      | food-drink/dried-fruit-nuts-seeds/nuts               |
#      | offers/1-2-price                                     |
#      | sports-nutrition                                     |
#      | free-from                                            |
#      | natural-beauty/new-in-beauty                         |
#      | weight-management/weight-management-shop-all         |
#      | household                                            |
#      | offers/new-in                                        |

  @scraperGet @search @ignore
  Scenario Outline: Verify ATG search return SRP data for different top search string <category>
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | path         | /search    |
      | isSearch     | true       |
      | query        | <category> |
      | host         | www.hollandandbarrett.nl |
    When I send a GET request to /getproductlist endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | listedCategory.title | You searched for '<category>' |
      | totalResults         | [number]                      |

    Examples:
      | category     |
      | vitamin-c    |
      | henna        |
      | collagen     |
      | honey        |
      | manuka honey |
      | gist         |
      | Kokosolie    |
      | vitamin d3   |

  @DISCOVER-1433 @comparing @ignore
  Scenario Outline: Compare ATG & OneSearch SRP against <category> for NETHERLANDS site
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/srp_search_payload.json replacing values
      | SiteId       |  40              |
      | Locale       |  nl              |
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
      | host         | www.hollandandbarrett.nl |
    When I send a GET request to /getproductlist endpoint
    Then The response status code should be 200
    And make sure you can compare following attributes among the json responses for <category>
      | scraper_attribute | onesearch_attribute                 |
      | totalResults      | results.ProductProcessor.totalFound |

    Examples:
      | category     |
      | Vitamine-C   |
      | Collageen    |
      | honing       |
      | huid olie    |
      | gist         |
      | coconut oil  |
      | Haarverzorging|

  @scraperGet @DISCOVER-1409 @ignore
  Scenario Outline: Verify ATG search query with special chars
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    When I send a GET request to getproductlist?path=/search&host=www.hollandandbarrett.nl&isSearch=true&query=<search-param> endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | searchTerm   | <search-term>    |
      | totalResults | [number]         |

    Examples:
      | search-param          | search-term       |
      |holland%20%26%20barrett| holland & barrett |
      |Voeding%20%26%20Dranken| Voeding & Dranken |
      | agatha-s-bester       | agatha-s-bester   |
      | nature%27s%20garden   | nature's garden   |
      | bio-oil               | bio-oil           |
      | burt%27s              | burt's            |
      | enjoy!                | enjoy!            |
      | manuka%20(MGO%2070)   | manuka (MGO 70)   |
      | Dr%20%2A              | Dr *              |
      | jack-n-jill           | jack-n-jill       |

      | heath%20%26%20heather | heath & heather   |
      | dr-will-s             | dr-will-s         |
      | nature%27s%20way      | nature's way      |
      | enjoy%21              | enjoy!            |

  @scraperGet @DISCOVER-1407 @ignore
  Scenario Outline: Verify Brand pages from ATG for brand <brand-name>
    Given I create a new scraper api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | path         | /brands/<brand-name> |
      | host         | www.hollandandbarrett.nl |
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
      | hair-gro         |
      | weleda           |
      | phd              |
      | swisse           |
      | optima-healthcare|
      | faith-in-nature  |
      | pukka            |
      | heath-heather    |
      | t-vlierbos       |
      | sambucol         |
      | burt-s-bees      |

  @getOffers @DISCOVER-1184 @ignore
  Scenario Outline: Verify ATG offers & promotions
    Given I create a new scraper api request with following headers
      | Content-Type  | application/json |
    And I add following attributes in the request query string
      | path         | /shop/offers/<offer-name> |
      | host         | www.hollandandbarrett.nl |
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

  @DISCOVER-1433 @comparing @ignore
  Scenario Outline: Compare ATG & OneSearch SRP against <category> for BELGIUM site
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/srp_search_payload.json replacing values
      | SiteId       |  60              |
      | Locale       |  nl              |
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
      | host         | www.hollandandbarrett.be |
    When I send a GET request to /getproductlist endpoint
    Then The response status code should be 200
    And make sure you can compare following attributes among the json responses for <category>
      | scraper_attribute | onesearch_attribute                 |
      | totalResults      | results.ProductProcessor.totalFound |

    Examples:
      | category     |
      | Vitamine-C   |
      | Kurkuma      |
      | Collageen    |
      | honing       |
      | manuka honing|
      | gist         |
      | coconut oil  |
      | Haarverzorging|

  @DISCOVER-1433 @comparing @ignore
  Scenario Outline: Compare ATG & OneSearch SRP against <category> for NETHERLANDS site
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/srp_search_payload.json replacing values
      | SiteId       |  40              |
      | Locale       |  nl              |
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
      | host         | www.hollandandbarrett.nl |
    When I send a GET request to /getproductlist endpoint
    Then The response status code should be 200
    And make sure you can compare following attributes among the json responses for <category>
      | scraper_attribute | onesearch_attribute                 |
      | totalResults      | results.ProductProcessor.totalFound |

    Examples:
      | category     |
      | Vitamine-C   |
      | Collageen    |
      | honing       |
      | huid olie    |
      | gist         |
      | coconut oil  |
      | Haarverzorging|

  @comparison @ignore
  Scenario Outline: Verify & Compare the results for category <category>
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using filename onesearch/srp_search_payload.json replacing values
      | Query | <category> |
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And I save the onesearch response json
    And I create a new scraper api request with following headers
      | Content-Type | application/json |
    When I send a GET request to getproductlist?path=/search&isSearch=true&query=<category> endpoint
    Then The response status code should be 200
    And make sure you can compare following attributes among the json responses for <category>
      | scraper_attribute | onesearch_attribute                 |
      | totalResults      | results.ProductProcessor.totalFound |

    Examples:
      | category            |
      | cbd                 |
      | manuka honey        |
      | collagen            |
      | turmeric            |
      | honey               |
      | omega 3             |
      | vitamin d3          |
      | coconut oil         |
      | glucosamine         |
      | vitamin b12         |
      | tumeric             |
      | apple cider vinegar |
      | wellkid             |
      | ginger              |
      | castor oil          |
      | anxiety             |
      | hair                |
      | grenade             |
      | kids vitamins       |
      | folic acid          |
      | vitamin d           |
      | turmeric capsules   |
      | manuka              |
      | sleep               |
      | walnuts             |
      | cranberry           |
      | pumpkin seeds       |
      | creatine            |
      | green tea           |
      | rescue remedy       |
      | aloe vera juice     |
      | oil                 |
      | turmeric tablets    |
      | acne                |
      | peppermint oil      |
      | spirulina           |
      | hemp oil            |
      | lavender            |
      | alive               |
      | cherry juice        |
      | dates               |
      | almond oil          |
      | flaxseed            |
      | matcha              |
      | hair vitamins       |
      | selenium            |
      | hyaluronic acid     |
      | magnesium spray     |
      | d3                  |
      | omega               |
      | coconut             |
      | sunflower seeds     |
      | pregnacare          |
      | garlic              |
      | vitamin b           |
      | gummies             |
      | collagen powder     |
      | vitamin d spray     |
      | stevia              |
      | hemp                |
      | raw honey           |
      | propolis            |
      | psyllium husks      |
      | apple cider gummies |
      | maca                |
      | hydrogen peroxide   |
      | floradix            |
      | vitamin c           |
      | pregnancy           |
      | detox               |
      | evening primrose    |
      | iron tablets        |
      | lavender oil        |
      | liquorice           |
      | sage                |
      | low carb            |
      | ginseng             |
      | magnesium           |
      | vitamin b complex   |
      | peppermint          |
      | shampoo bar         |
      | black cohosh        |
      | hair growth shampoo |
      | royal jelly         |
      | valerian            |
      | magnesium tablets   |
      | tea tree            |
