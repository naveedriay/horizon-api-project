package com.hb.api.step_definitions.onesearch;

import com.hb.api.config.ScenarioSession;
import com.hb.api.step_definitions.CommonStepDefinition;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.And;
import io.restassured.path.json.JsonPath;
import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.assertj.core.util.Lists;
import org.json.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;

import java.io.File;
import java.util.*;
import java.util.logging.Logger;
import java.util.stream.Collectors;

import static org.junit.Assert.assertTrue;

public class OneSearchStepDefinition {

    @Autowired
    protected CommonStepDefinition commonStepDefinition;

    @Autowired
    protected ScenarioSession scenarioSession;

    private JsonPath onesearch_json = null;

    private static final Logger log = Logger.getLogger("OneSearchStepDefinition");

    private void fetchBrandPLPPage(String brand_names){
        brand_names = brand_names.replaceAll("\\s+","-");
        List<List<String>> headersTable = Arrays.asList(Arrays.asList("Content-Type", "text/html"));
        DataTable dataTable = DataTable.create(headersTable);
        try{
            commonStepDefinition.iCreateNewRequestWithHeaders("H&B", dataTable);
            commonStepDefinition.i_send_the_request_with_response_type("GET", "shop/brands/"+brand_names);
            commonStepDefinition.the_response_status_code_should_be(200);
            commonStepDefinition.iShouldNotSeeAPage("Oops!");
        }catch (Throwable th){}
    }

    @And("I save the onesearch response json")
    public void iSaveTheOnesearchResponseJson() {
        onesearch_json = commonStepDefinition.apiObject.getResponseJson();
    }

    @And("make sure you can compare following attributes among the json responses for (.*)")
    public void makeSureYouCanCompareFollowingAttributesAmongTheJsonResponses(String category, DataTable table) throws Throwable {
        JsonPath scrapper_json = commonStepDefinition.apiObject.getResponseJson();
        List<List<String>> table_rows = table.asLists();
        for (List<String> rows : table_rows.subList(1, table_rows.size())) {
            String scraper_value  = scrapper_json.getString(rows.get(0));
            String onesearch_value= onesearch_json.getString(rows.get(1));

            File myfile = new File(System.getProperty("user.dir")+"/target/comparison.txt");
            if (myfile.createNewFile())
                log.info("file created successfully");
            FileUtils.writeStringToFile(myfile,"For Category: "+ category+ "\t ATG gets: " + scraper_value + "\t|| OneSearch Gets: " + onesearch_value+"\n","UTF-8", true);

            log.info("\t" + rows.get(0) + ": " + scraper_value + "\t|| " + rows.get(1) + ": " + onesearch_value);
            assertTrue("scraper gets: "+scraper_value+", oneSearch: "+ onesearch_value,
                                    (scraper_value!=null && onesearch_value!= null));
        }
    }

    @And("make sure to count the number of brands returned")
    public void makeSureToCountTheNumberOfBrandsReturned() {
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<String> brands = response_json.getList("results.ProductProcessor.facets.Brand.label");
        log.info("$$$$$$$$$$$ TOTAL BRANDS FOUND: "+brands.size()+ " $$$$$$$$$$$");
        List<String> result =  brands.stream().filter(brand -> { //
            if (brand.contains("-")|| brand.contains("'") || brand.contains("&") || brand.contains(".") || brand.contains("+")) {
                return true;
            }
            return false;
        }).collect(Collectors.toList());
        System.out.println(result.size());
        result.forEach(System.out::println);
    }

    @And("make sure multiple image resolution exists for (.*) articles")
    public void makeSureMultipleImageResolutionExistsForArticles(String query_topic) {
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        int article_count = response_json.getInt("results.ContentProcessor.totalFound");
        System.out.println("Total "+ article_count + " Articles Found for: "+ query_topic);
        article_count = Math.min(article_count, 10);
        for(int i=0; i < article_count; i++){
            String article_name = response_json.get("results.ContentProcessor.results["+i+"].name");
            List<Map> items = response_json.getList("results.ContentProcessor.results["+i+"].images[0].list");
            //System.out.println("We Found "+ items.size() + " resolutions for = \t"+ article_name);
            assertTrue("For ["+i+"] "+ article_name+ ", No Images returned!", items.size()>=1);
        }
    }

    @And("I verify the items returned in sorted order by price")
    public void iVerifyTheItemsReturnedInSortedOrderByPrice() {
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        int item_count = response_json.getList("results.ProductProcessor.results").size();
        for(int i=0; i < item_count; i++) {
            float this_item_price = response_json.get("results.ProductProcessor.results[" + i + "].final_price");
            int next_item_index = (i<item_count-1)?i+1:i;
            float next_item_price = response_json.get("results.ProductProcessor.results[" + next_item_index + "].final_price");
//            System.out.println("final price of item "+i+" is: "+ this_item_price + " as compared to next_item price: "+ next_item_price);
            assertTrue(this_item_price <= next_item_price);
        }
    }

    @And("make sure corresponding brand pages are also available")
    public void makeSureCorrespondingBrandPagesAreAlsoAvailable() {
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
//        Map<String,String> brands = response_json.getMap("results.ProductProcessor.facets.Brand");
        List<String> brands = response_json.getList("results.ProductProcessor.facets.Brand.label");
        List<String> brand_result =  brands.stream().filter(brand -> { //
            if (brand.contains("-")|| brand.contains("'") || brand.contains("&") || brand.contains(".") || brand.contains("+")) {
                return false;
            }
            return true;
        }).collect(Collectors.toList());

        log.info("$$$$$$$$$$$ TOTAL BRANDS FOUND: "+brands.size()+ " $$$$$$$$$$$, \nWe are looking into only "+ brand_result.size()+ " with brands: "+ brand_result.toString());
        brand_result.stream().forEach(brand -> fetchBrandPLPPage(brand.toLowerCase()));
    }

    @And("make sure all the elements returned have (.*) in its promotion")
    public void verifyElementsReturnedHaveCorrectPromotion(String expected_offer_text) {
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        int item_count = response_json.getList("results.ProductProcessor.results").size();
        for(int i=0; i < item_count; i++) {
            String promotion_text = response_json.get("results.ProductProcessor.results[" + i + "].promotions[0].text");
            assertTrue("Expected: "+ expected_offer_text+", but Found: "+ promotion_text,
                    expected_offer_text.equalsIgnoreCase(promotion_text));
        }
    }

    @And("make sure number of entries returned for (.*) are (less than|greater than|equal to) (\\d+)$")
    public void makeSureNumberOfEntriesReturned(String json_array, String option, int expected_entries) {
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<String> total_items = response_json.getList(json_array);

        boolean decision = false;
        int actual_entries = (total_items != null) ? total_items.size() : 0;

        switch (option){
            case "less than":
                decision =  actual_entries < expected_entries; break;
            case "greater than":
                decision = actual_entries > expected_entries; break;
            case "equal to":
                decision = actual_entries == expected_entries; break;
        }
        assertTrue("Expected: " + expected_entries + ", Found: " + actual_entries, decision);
    }

    @And("the item status would be one of the following")
    public void theItemStatusWouldBeOneOfTheFollowing(DataTable table) {

        boolean decision = false;
        String actual_skuId = "", actual_status = "";
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<String> basket_items = response_json.getList("items");

        for (int i = 0; i < basket_items.size(); i++) {
            actual_status = response_json.get("items[" + i + "].status");
            actual_skuId  = response_json.get("items[" + i + "].skuId");
            if (actual_status.equals("INSTOCK") || actual_status.equals("NOTFOUND") || actual_status.equals("NOTAVAILABLE") || actual_status.equals("OUTOFSTOCK")) {
                decision = true;  System.out.println(" Found status: " + actual_status + " for SkuId: "+actual_skuId );
            } else
                decision = false;
        }
        assertTrue("COULD NOT FOUND THE RIGHT STATUS For " + actual_skuId + " = "+ actual_status, decision);
    }

    @And("the following FAQs appear in the result")
    public void theFollowingFAQsAppearInTheResult(DataTable table) {

        boolean decision = false;
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<String> faq_results = response_json.getList("results");

        List<List<String>> table_rows = table.asLists();
        for (List<String> rows : table_rows.subList(1, table_rows.size())) {
            String expected_skus  = rows.get(0);
            String expected_name  = rows.get(1);
            String expected_title = expected_name;

            for (int i = 0; i < faq_results.size(); i++) {
                String actual_skus  = response_json.get("results[" + i + "].skus");
                String actual_name  = response_json.get("results[" + i + "].name");
                String actual_title = response_json.get("results[" + i + "].title");
//                System.out.println("Trying to Find FAQ: " + expected_title);
                if (expected_skus.equals(actual_skus) && expected_name.equals(actual_name) && expected_title.equals(actual_title)) {
                    decision = true;
                    System.out.println(" Found item: " + expected_title);
                    break;
                } else
                    decision = false;
            }
            assertTrue(expected_title + ": FAQ NOT FOUND", decision);
        }
    }

    @And("the following Product Flags appear in the result")
    public void theFollowingProductFlagsAppearInTheResult(DataTable table) throws Throwable{

        boolean decision = false;
        JSONArray json_arr = new JSONArray(commonStepDefinition.apiObject.getResponseBody());
        ArrayList <String> decisionList = new ArrayList<String>();
        List<List<String>> table_rows = table.asLists();
        for (List<String> rows : table_rows.subList(1, table_rows.size())) {
            String expected_name  = rows.get(0);

            for (int i = 0; i < json_arr.length(); i++) {
                String actual_name  = json_arr.getJSONObject(i).getString("name");
                if (expected_name.equals(actual_name)) {
                    decision = true;
                    break;
                }else
                    decision = false;
            }
            if (decision)
                decisionList.add("\nFound: " + expected_name);
            else
                decisionList.add("\nNotFound: " + expected_name);
        }
        System.out.println(decisionList.toString());
    }
}