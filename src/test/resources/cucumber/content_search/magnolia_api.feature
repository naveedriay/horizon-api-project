@api @magnolia

Feature: Magnolia Api

  @DISCOVER-1366
  Scenario Outline: Magnolia Seeded Content for path=<query-path>
    Given I create a new magnolia api request with following headers
      | Content-Type | application/json |
    When I send a GET request to delivery/v1/content/plp/uk/<query-path> endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | @name                       | <name>               |
      | @path                       | /plp/uk/<query-path> |
      | seededContentImagePosition  | center               |
      | seededContentBottomGradient | [NOTEMPTY]           |
      | seededContentTopGradient    | [NOTEMPTY]           |
      | seededContentTitle          | <title>              |
      | seededContentImageDesktop   | [NOTEMPTY]           |
      | seededContentDescription    | [NOTEMPTY]           |
      | seededContentLink           | [NOTEMPTY]           |
      | seededContentPosition       | 6                    |
    Examples:
      | query-path                                              | name                        | title         |
      | shop/vitamins-supplements/vitamins                      | vitamins                    | Find out more |
      | shop/vitamins-supplements/supplements                   | supplements                 | Find out more |
      | shop/vitamins-supplements/vitamins/vitamin-c            | vitamin-c                   | Find out more |
      | shop/food-drink/honey-jams-spreads/honey                | honey                       | Take the quiz |
      | shop/natural-beauty/washing-bathing/hand-wash           | hand-wash                   | Find out more |
      | shop/vitamins-supplements/supplements/aloe-vera         | aloe-vera                   | Find out more |
#      | shop/vitamins-supplements/condition/cold-immune-support | cold-immune-support         | Find out more |
      | shop/product-group/holland-barrett-gut-powered          | holland-barrett-gut-powered | Find out more |
      | shop/vitamins-supplements/new-in-vitamins-supplements   | new-in-vitamins-supplements | Find out more |
      | shop/food-drink/honey-jams-spreads/honey/manuka-honey   | manuka-honey                | Take the quiz |

    @ignore
    Examples: PLP with Articles
      | query-path                                                               | name                        |
      | shop/vitamins-supplements/supplements/plant-sourced-supplements/turmeric | turmeric                    |
      | shop/vitamins-supplements/vitamins/vitamin-d                             | vitamin-d                   |

    @ignore
    Examples: Inactive Offers
      | query-path                                                               | name                        |
      | shop/offers/price-drop                                                   | price-drop                  |

  @persuade @DISCOVER-1382
  Scenario: Magnolia Global Components (Banners) on PLP/SRP
    Given I create a new magnolia api request with following headers
      | Content-Type | application/json |
    When I send a GET request to delivery/v1/sites/site/uk endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | @name                             | uk                             |
      | @path                             | /site/uk                       |
      | @id                               | [GUID]                         |
      | @nodeType                         | mgnl:page                      |
      | title                             | UK Site                        |
      | "mgnl:template"                   | attract:pages/Site             |
      | globalPages.@id                   | [GUID]                         |
      | globalPages.noIndex               | true                           |
      | globalPages.noHeader              | false                          |
      | globalPages.noFooter              | false                          |
      | globalPages.layout                | [NOTEMPTY]                     |
      | globalPages.banners               | [NOTEMPTY]                     |
      | globalPages.popups                | [NOTEMPTY]                     |
      | globalPages.@nodes                | [layout, popups, banners]      |
      | hrefLang                          | en-gb                          |
      | onesearchLocale                   | en                             |
      | globalPages.layout.head.@name     | head                           |
      | globalPages.layout.head.@path     | /global/uk/layout/head         |
      | globalPages.layout.head.@id       | [GUID]                         |
      | globalPages.layout.head.@nodeType | mgnl:area                      |
      | globalPages.layout.foot.@name     | foot                           |
      | globalPages.layout.foot.@path     | /global/uk/layout/foot         |
      | globalPages.layout.foot.@id       | [GUID]                         |
      | globalPages.layout.foot.@nodeType | mgnl:area                      |

  @regression @NOT-FOUND-404
  Scenario: Magnolia Delivery Options for International Sites
    Given I create a new magnolia api request with following headers
      | Content-Type | application/json |
    When I send a GET request to delivery/deliveryinfo endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | results | [value>1] |
    And I expect following attributes under each array node results to contain
      | @name | deliveryOptions0.title               | deliveryOptions1.title | deliveryOptions2.title   |
      | ie    | Standard Delivery                    | Express Delivery       | Express Click & Collect  |
      | nl    | Standaard Bezorging binnen Nederland | Click & Collect        | Passie klantenkaart      |
      | be-fr | Livraison standard                   | Click & Collect        | Livraison internationale |
      | be    | Standaard Bezorging                  | Click & Collect        | Internationale Bezorging |
      | uk    | FREE UK Delivery when you spend      | Next Day Delivery      | Next Day Click & Collect |

  @regression
  Scenario: Magnolia Product Flags for International Sites
    Given I create a new magnolia api request with following headers
      | Content-Type | application/json |
    When I send a GET request to delivery/v1/productflags/uk/@nodes endpoint
    Then The response status code should be 200
    And make sure number of entries returned for results are less than 200
    And the following Product Flags appear in the result
      | product-flag      |
      | age18             |
      | age16             |
      | hbexclusive       |
      | limitedtwo        |
      | immunitysupport   |
      | trending          |
      | onlineexclusive   |
      | newin             |
      | vatfree           |
      | weightmanagement  |
      | justadded         |
      | sd-Omega3         |
      | sd-Grapeseed      |
      | overlayPromoBeauty|
      | overlayPromoFood  |
      | overlayPromoSports|
      | digitalmag        |
      | newgreatlook      |
      | hearthealth       |
      | onlineonly        |
      | promoBanner1      |

  @content_sanity @regression
  Scenario: Magnolia Global Header on Homepage
    Given I create a new magnolia api request with following headers
      | Content-Type | application/json |
    When I send a GET request to delivery/v1/sites/site/uk endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | globalPages.layout.@name                              | layout                                                              |
      | globalPages.layout.@path                              | /global/uk/layout                                                   |
      # HEADER TOP RIGHT ELEMENTS PRESENCE TESTED HERE
      | globalPages.layout.head.0.header.0.menuItems.00.title | Account                                                             |
      | globalPages.layout.head.0.header.0.menuItems.01.title | Rewards                                                             |
      | globalPages.layout.head.0.header.0.menuItems.02.title | Help                                                                |
      | globalPages.layout.head.0.header.0.menuItems.03.title | Search                                                              |
      | globalPages.layout.head.0.header.0.menuItems.04.title | Basket                                                              |
      # HEADER MAIN CATEGORIES PRESENCE TESTED BELOW
      | globalPages.layout.head.0.header.00.menus[0].link     | /shop/vitamins-supplements/                                         |
      | globalPages.layout.head.0.header.00.menus[1].link     | /shop/food-drink/                                                   |
      | globalPages.layout.head.0.header.00.menus[2].link     | /shop/sports-nutrition/                                             |
#      | globalPages.layout.head.0.header.00.menus[3].link     | /shop/health-wellness/                                              |
      | globalPages.layout.head.0.header.00.menus[3].link     | /shop/cbd/                                                          |
      | globalPages.layout.head.0.header.00.menus[4].link     | /shop/vegan/                                                        |
#     | globalPages.layout.head.0.header.00.menus[5].link     | /shop/free-from/                                                    |
      | globalPages.layout.head.0.header.00.menus[5].link     | /shop/natural-beauty/                                               |
      | globalPages.layout.head.0.header.00.menus[6].link     | /shop/weight-management/                                            |
      | globalPages.layout.head.0.header.00.menus[7].link     | /shop/offers/black-friday-deals/                                    |
      | globalPages.layout.head.0.header.00.menus[8].link     | /shop/offers/                                                       |
      | globalPages.layout.head.0.header.00.menus[9].link     | https://www.hollandandbarrett.com/the-health-hub/?icmp=Menu_HH_main |

  @content_sanity
  Scenario: Magnolia Global Footer on Homepage
    Given I create a new magnolia api request with following headers
      | Content-Type | application/json |
    When I send a GET request to delivery/v1/sites/site/uk endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | globalPages.layout.@name                                    | layout                                                      |
      | globalPages.layout.@path                                    | /global/uk/layout                                           |
    # FOOTER TOP ELEMENTS PRESENCE TESTED HERE
      | globalPages.layout.foot.0.footerTop.0.items.0.title         | Join Rewards for Life                                       |
      | globalPages.layout.foot.0.footerTop.0.items.00.title        | Subscribe & Save                                            |
      | globalPages.layout.foot.0.footerTop.0.items.01.title        | Speak to an Advisor                                         |
     # FOOTER MIDDLE ELEMENTS PRESENCE TESTED HERE
      | globalPages.layout.foot.0.footerMiddle.00.items.items0.link | https://www.instagram.com/hollandandbarrett/                |
      | globalPages.layout.foot.0.footerMiddle.00.items.items1.link | https://www.pinterest.co.uk/hollandandbarrett/              |
      | globalPages.layout.foot.0.footerMiddle.00.items.items2.link | https://www.facebook.com/hollandandbarrett                  |
      | globalPages.layout.foot.0.footerMiddle.00.items.items3.link | https://twitter.com/intent/user?screen_name=holland_barrett |
      # FOOTER BOTTOM ELEMENTS PRESENCE TESTED HERE
      | globalPages.layout.foot.0.footerBottom.00.title             | Customer service                                            |
      | globalPages.layout.foot.0.footerBottom.01.title             | About us                                                    |
      | globalPages.layout.foot.0.footerBottom.02.title             | Trending                                                    |
      | globalPages.layout.foot.0.footerBottom.03.title             | Brands                                                      |
      | globalPages.layout.foot.0.footerBottom.04.title             | Download the app                                            |

  @content_sanity
  Scenario: Return Magnolia Product Group Pages Template
    Given I create a new magnolia api request with following headers
      | Content-Type | application/json |
    When I send a GET request to delivery/v1/content/plp/uk/shop/product-group/charcoal endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | @name               | charcoal                                          |
      | @path               | /plp/uk/shop/product-group/charcoal               |
      | h1.@path            | /plp/uk/shop/product-group/charcoal/h1            |
      | h1.0.title          | Activated Charcoal Powder                         |
      | subcategories.@path | /plp/uk/shop/product-group/charcoal/subcategories |
      | headerText.@path    | /plp/uk/shop/product-group/charcoal/headerText    |
      | promoContent.@path  | /plp/uk/shop/product-group/charcoal/promoContent  |
      | bottomContent.@path | /plp/uk/shop/product-group/charcoal/bottomContent |

  @DISCOVER-1514 @NOT-FOUND-404
  Scenario: Return Magnolia FAQ Flags
    Given I create a new magnolia api request with following headers
      | Content-Type | application/json |
    When I send a GET request to delivery/v1/content/plp/uk/faqflags endpoint
    Then The response status code should be 200
    And the following FAQs appear in the result
      | skus   | name                       | title                      |
      | 017478 | What is turmeric?          | What is turmeric?          |
      | 017478 | Is turmeric good for you?  | Is turmeric good for you?  |
      | 034670 | What is Garcinia Cambogia? | What is Garcinia Cambogia? |
      | 003832 | What is omega 3?           | What is omega 3?           |
      | 034245 | What is Kalms?             | What is Kalms?             |
      | 018333 | What is CBD oil good for?  | What is CBD oil good for?  |
    And make sure following attributes exist within response json
      | results.@name        |          |
      | results.@path        |          |
      | results.@id          |          |
      | results[0].@nodeType | faqFlags |