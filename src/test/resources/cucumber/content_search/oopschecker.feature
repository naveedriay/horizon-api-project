@checker
Feature: Oops Checker

  # THIS TEST SHOULD BE RUN AS PER NEED FOR ANY GIVEN SITEID (set via paylaod) TO FETCH ALL BRANDS #
  # THIS TEST WILL TAKE 20-25 MINS TO COMPLETE.
  # THEN CALL THE CORRESPONDING BRAND PAGE TO CHECK IT DOESN'T SHOW OOPS PAGE
  @getBrands @DISCOVER-1407
  Scenario: Verify that all site-wide brand pages are not returning Oops
    Given I create a new onesearch api request with following headers
      | Content-Type | application/json |
    And I add a json payload using the file onesearch/allbrands_payload.json
    When I send a POST request to search endpoint
    Then The response status code should be 200
    And make sure to count the number of brands returned
    And make sure corresponding brand pages are also available

  @ignore @review
  Scenario Outline:  Verify the given pages do not return Oops page
    Given I create a new H&B_Prod api request with following headers
      | Content-Type | text/html |
    When I send a GET request to <PageUrl> endpoint
    Then The response status code should be <status>
    And I should not see a "Oops!" page
    Examples:
      | status | PageUrl                                                                                  |
#      | 200    | shop/brands/manuka-doctor/?t=skupromo_buy-one-get-one-for-a-penny/&icmp=HP_P2_SLOT_3_FOOD_manuka |
      | 200    | shop/brands/dr-organic/?isOneSearchMVT=true                                              |
#      | 200    | shop/sports-nutrition/protein/?t=skupromo_buy-one-get-one-for-a-penny&icmp=HP_P2_SLOT_2_SN_PE    |       |
      | 200    | christmas/?icmp=HP_STRIP_P1_CHRISTMAS_SHOP                                               |
      | 200    | shop/offers/save-up-to-1-2-price/                                                        |
      | 200    | shop/offers/                                                                             |
      | 200    | shop/brands/vitaskin/                                                                    |
      | 200    | shop/brands/bioglan/?isOneSearchMVT=true                                                 |
#      | 200    | shop/product-group/reduced-to-clear/?icmp=HP_STRIP_P13_clearance                         |
#      | 308    | shop/vitamins-supplements/condition/fatigue/&icmp=HP_MAIN_P2_Energy_Variation            |
      | 200    | shop/vitamins-supplements/condition/cold-immune-support/?icmp=HP_P2_SLOT_1_VHMS_IMMUNITY |
      | 200    | shop/product-group/christmas-shop-all/                                                   |
      | 200    | shop/food-drink/advent-calendars/?icmp=P2_CHRISTMAS_ADVENT_STRIP                         |
      | 200    | shop/vitamins-supplements/vitamins/vitamin-d/?icmp=HP_trend_vit_d                        |
      | 200    | shop/vitamins-supplements/vitamins-supplements-shop-all/?t=skupromo_save-up-to-1-2-price |

  Scenario:  FlyOuts are not returning Oops
  Scenario:  Offer Banners are not returning Oops