@api @delivery @checkout @addresslookup

Feature: Address Lookup
#  A service that wraps the Experian Address validation service to provide an address lookup service to frontend web and mobile apps

  @FULFIL-1138
  Scenario Outline: Get a list best matched addresses for the given locale <locale>
    Given I create a new addresslookup api request with following headers
      | Content-Type | application/json |
    And I add following attributes in the request query string
      | query   | <query>  |
      | country | <locale> |
    When I send a GET request to search endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | more_results | <check>   |
      | results.id   | [value>1] |
      | results.text | [value>1] |
    Examples:
      | query                                | locale | check | address                                                                                                                                                                                                                                                                                      |
      | 88437                                | USA    | true  | [88437 Abilene Christian University, Abilene TX 79699, 88437 Us Highway 89, Afton WY 83110, 88437 Missent, Agoura Hills CA 91301, 88437 Missequenced, Agoura Hills CA 91301, 88437 Missort, Agoura Hills CA 91301, 88437 Other, Agoura Hills CA 91301, 88437 426Th Ave, Ainsworth NE 69210]  |
      | CV107RH                              | GBR    | true  | [Research Garage, 1 Barling Way, Nuneaton, CV10 ..., Listers Volkswagen, 2 Barling Way, Nuneaton, CV10 ..., Lyson Architecture Ltd, 4 Barling Way, Nuneaton, CV10 ..., Video 2 Video Ltd, 4 Barling Way, Nuneaton, CV10 ..., Warwickshire County Council, 4 Barling Way, Nuneaton, CV10 ..., S F B Wealth Management, 4 Barling Way, Nuneaton, CV10 ..., Covnetics Ltd, 4 Barling Way, Nuneaton, CV10 ...]  |
      | 4659, Queensland                     | AUS    | true  | [12 Queensland Road, CASINO  NSW 2470, 14 Queensland Road, CASINO  NSW 2470, 16 Queensland Road, CASINO  NSW 2470, 18 Queensland Road, CASINO  NSW 2470, 20 Queensland Road, CASINO  NSW 2470, 22 Queensland Road, CASINO  NSW 2470, 24 Queensland Road, CASINO  NSW 2470]                   |
      | Connolly, Dublin, D01 X6P6           | IRL    | false | [6, Connolly Avenue, DUBLIN 8, 6, Connolly Gardens, DUBLIN 8, 1, Connolly Crescent, Co Dublin, Bermuda Isle, 1, Connolly Avenue, MALAHIDE, Co Dublin, 6, Connolly Avenue, MALAHIDE, Co Dublin, Avondale, 6A, Connolly Avenue, MALAHIDE, Co Dublin, 6B, Connolly Avenue, MALAHIDE, Co Dublin] |
      | 2591 EX, Den Haag, Zuid-Holland      | NLD    | false | [Isabellaland 2016, 'S-GRAVENHAGE 2591 EX, Isabellaland 2018, 'S-GRAVENHAGE 2591 EX, Isabellaland 2020, 'S-GRAVENHAGE 2591 EX, Isabellaland 2022, 'S-GRAVENHAGE 2591 EX, Isabellaland 2024, 'S-GRAVENHAGE 2591 EX, Isabellaland 2032, 'S-GRAVENHAGE 2591 EX, Isabellaland 2034, 'S-GRAVENHAGE 2591 EX, Isabellaland 2036, 'S-GRAVENHAGE 2591 EX, Isabellaland 2038, 'S-GRAVENHAGE 2591 EX, Isabellaland 2040, 'S-GRAVENHAGE 2591 EX, Isabellaland 2042, 'S-GRAVENHAGE 2591 EX, Isabellaland 2044, 'S-GRAVENHAGE 2591 EX, Isabellaland 2046, 'S-GRAVENHAGE 2591 EX, Isabellaland 2048, 'S-GRAVENHAGE 2591 EX, Isabellaland 2050, 'S-GRAVENHAGE 2591 EX, Isabellaland 2052, 'S-GRAVENHAGE 2591 EX, Isabellaland 2054, 'S-GRAVENHAGE 2591 EX, Isabellaland 2056, 'S-GRAVENHAGE 2591 EX, Isabellaland 2058, 'S-GRAVENHAGE 2591 EX, Isabellaland 2060, 'S-GRAVENHAGE 2591 EX] |
      | 3700, Rutten, Rue des Buissons 271   | BEL    | false | [Beekstraat 271, RUTTEN, Limburg 3700, Boudewijnstraat 271, RUTTEN, Limburg 3700, Etjesstraat 271, RUTTEN, Limburg 3700,Godgavestraat 271, RUTTEN, Limburg 3700,de Grunnestraat 271, RUTTEN, Limburg 3700, Haccostraat 271, RUTTEN, Limburg 3700, Hagelindeweg 271, RUTTEN, Limburg 3700]                                                                                                                                                                                               |
      | 75014, 48 Boulevard Jourdan          | FRA    | true  | [48 boulevard Jourdan, 75014 PARIS, 48 boulevard Jourdan, 13014 MARSEILLE, 48 boulevard Jourdan Prolonge, 13014 MARSEILLE, Institut Mutualiste Montsouris, 48 boulevard Jourdan, CS 40011, 75674 PARIS CEDEX 14, Bureau de Poste Cite Universitai, 48 boulevard Jourdan, 75675 PARIS CEDEX 14, Carlo Sarl, 48 boulevard Jourdan, BP 90210, 13308 MARSEILLE CEDEX 14, Interiale, 48 boulevard Jourdan, CS 20380, 13311 MARSEILLE CEDEX 14] |

  @FULFIL-1173
  Scenario: Verify addressLookup service return formatted address for IRL
    Given I fetched all the addresses for query=Connolly, Dublin, D01 X6P6&country=IRL
    And I save the results[0].id from within response json as addressID
    Given I create a new addresslookup api request with following headers
      | Content-Type | application/json |
    When I send a GET request to address/{addressID} endpoint
    Then The response status code should be 200
    And make sure attribute id contains IRL
    And make sure following attributes exist within response json
      | address.address_line_1 | 6, Connolly Avenue |
      | address.address_line_2 | Dublin 8           |
      | address.address_line_3 | [EMPTY]            |
      | address.region         | [EMPTY]            |
      | address.locality       | DUBLIN 8           |
      | address.country        | IRELAND            |

  @FULFIL-1173
  Scenario: Verify addressLookup service return formatted address for BEL
    Given I fetched all the addresses for query=3700, Rutten, Rue des Buissons 271&country=BEL
    And I save the results[0].id from within response json as addressID
    Given I create a new addresslookup api request with following headers
      | Content-Type | application/json |
    When I send a GET request to address/{addressID} endpoint
    Then The response status code should be 200
    And make sure attribute id contains BEL
    And make sure following attributes exist within response json
      | address.address_line_1 | Beekstraat 271 |
      | address.address_line_2 | [EMPTY]        |
      | address.address_line_3 | [EMPTY]        |
      | address.region         | Limburg        |
      | address.locality       | RUTTEN         |
      | address.postal_code    | 3700           |
      | address.country        | BELGIUM        |

    @FULFIL-1173 @regression
    Scenario: Verify addressLookup service return formatted address for GBR
      Given I fetched all the addresses for query=CV107RH&country=GBR
      And I save the results[0].id from within response json as addressID
      Given I create a new addresslookup api request with following headers
        | Content-Type | application/json |
      When I send a GET request to address/{addressID} endpoint
      Then The response status code should be 200
      And make sure following attributes exist within response json
        | address.address_line_1 | Research Garage |
        | address.address_line_2 | 1 Barling Way   |
        | address.address_line_3 | [EMPTY]         |
        | address.region         | [EMPTY]         |
        | address.locality       | NUNEATON        |
        | address.postal_code    | CV10 7RH        |
        | address.country        | UNITED KINGDOM  |


  @FULFIL-1173
  Scenario: Verify addressLookup service return formatted address for USA
    Given I fetched all the addresses for query=88437&country=USA
    And I save the results[0].id from within response json as addressID
    Given I create a new addresslookup api request with following headers
      | Content-Type | application/json |
    When I send a GET request to address/{addressID} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | address.address_line_1 | 88437 Abilene Christian University |
      | address.address_line_2 | [EMPTY]    |
      | address.address_line_3 | [EMPTY]    |
      | address.region         | TX         |
      | address.locality       | Abilene    |
      | address.postal_code    | 79699-0001 |
      | address.country        | UNITED STATES OF AMERICA |

  @FULFIL-1217 @france
  Scenario: Verify addressLookup service return formatted address for FRA
    Given I fetched all the addresses for query=75014, 48 Boulevard Jourdan&country=FRA
    And I save the results[0].id from within response json as addressID
    Given I create a new addresslookup api request with following headers
      | Content-Type | application/json |
    When I send a GET request to address/{addressID} endpoint
    Then The response status code should be 200
    And make sure following attributes exist within response json
      | address.address_line_1 | 48 BOULEVARD JOURDAN |
      | address.address_line_2 | [EMPTY] |
      | address.address_line_3 | [EMPTY] |
      | address.region         | [EMPTY] |
      | address.locality       | PARIS   |
      | address.postal_code    | 75014   |
      | address.country        | FRANCE  |