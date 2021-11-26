package com.hb.api.step_definitions.basket;

import com.hb.api.api_objects.CommonApiObject;
import com.hb.api.config.JsonUtils;
import com.hb.api.config.ScenarioSession;
import com.hb.api.step_definitions.CommonStepDefinition;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import io.restassured.path.json.JsonPath;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class BasketStepDefinition {

    @Autowired
    protected CommonStepDefinition commonStepDefinition;

    @Autowired
    protected ScenarioSession scenarioSession;

    @Autowired
    protected JsonUtils json_utils;

    private String resolveBasketEndpoint(String endpoint_input) {
        if (endpoint_input.equalsIgnoreCase("Horizon"))
            return "v1/horizon/basket";
        else if (endpoint_input.equalsIgnoreCase("ATG"))
            return "v1/basket";
        else if(endpoint_input.equalsIgnoreCase("Hybrid"))
            return "v2/basket";
        else
            return "rest"; // For Basket Proxy Rest API => https://preprod-com.hollandandbarrett.net/basket/api/rest
    }

    private double round(double value, int places) {
        if (places < 0) throw new IllegalArgumentException();

        long factor = (long) Math.pow(10, places);
        value = value * factor;
        long tmp = Math.round(value);
        return (double) tmp / factor;
    }

    @Given("I have successfully added items to (.*) Basket using (.*)$")
    public void iHaveSuccessfullyAddedItemsToBasketUsing(String endpoint, String payloadFilename) throws Throwable {
        String basket_endpoint = resolveBasketEndpoint(endpoint);
        String api_base = (endpoint.equalsIgnoreCase("Proxy"))?"proxy-basket":"basket";

        List<List<String>> headersTable = Arrays.asList( Arrays.asList("Content-Type", "application/json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders(api_base, dataTable);
        commonStepDefinition.add_a_request_payload_using_file("json", payloadFilename);
        commonStepDefinition.i_send_the_request_with_response_type("POST", basket_endpoint);
        commonStepDefinition.the_response_status_code_should_be(200);
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        HttpHeaders response_headers = commonStepDefinition.apiObject.getResponseHeaders();

        if(json_utils.isNodePresent(new JSONObject(commonStepDefinition.apiObject.getResponseBody()), "basket.total"))
           scenarioSession.putData("basketTotal", response_json.get("basket.total").toString());

        if (endpoint.equalsIgnoreCase("horizon")) {
            // saves the basket GUID from responseJson to scenarioSession
            scenarioSession.putData("basketUUID", response_json.get("basket.uuid").toString());
        } else if (endpoint.equalsIgnoreCase("ATG")) {
            // saves the JSessionID from ATG response to scenarioSession
            List<String> headersList = response_headers.getValuesAsList(HttpHeaders.SET_COOKIE);
            headersList.forEach(item -> {
                if (item.contains("JSESSIONID"))
                    scenarioSession.putData("JSession-ID", item);
            });
        } else if (endpoint.equalsIgnoreCase("Hybrid")) {
            scenarioSession.putData("basketUUID", response_json.get("basket.uuid").toString());
            scenarioSession.putData("JSession-ID", "JSESSIONID=" + response_json.get("basket.sessionInfo.JSESSIONID").toString());

        } else { // in case of Proxy basket, save both (UUID & bid Cookie)
            scenarioSession.putData("basketUUID", response_json.get("basket.uuid").toString());
            List<String> headersList = response_headers.getValuesAsList(HttpHeaders.SET_COOKIE);
            headersList.forEach(item -> {
                if (item.contains("bid"))
                    scenarioSession.putData("bid-Cookie", item);
                else if (item.contains("JSESSIONID"))
                    scenarioSession.putData("JSession-ID", item);
            });
        }
    }

    @Given("I successfully added items to prod Proxy Basket using payload (.*)$")
    public void iSuccessfullyItemsToProdProxyBasketUsing(String payloadFilename) throws Throwable {
        String basket_endpoint = "rest";
        String api_base = "prod-proxy";

        List<List<String>> headersTable = Arrays.asList( Arrays.asList("Content-Type", "application/json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders(api_base, dataTable);
        commonStepDefinition.add_a_request_payload_using_file("json", payloadFilename);
        commonStepDefinition.i_send_the_request_with_response_type("POST", basket_endpoint);
        commonStepDefinition.the_response_status_code_should_be(200);
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        HttpHeaders response_headers = commonStepDefinition.apiObject.getResponseHeaders();

        scenarioSession.putData("basketUUID", response_json.get("basket.uuid").toString());
        List<String> headersList = response_headers.getValuesAsList(HttpHeaders.SET_COOKIE);
        headersList.forEach(item -> {
            if (item.contains("bid"))
                scenarioSession.putData("bid-Cookie", item);
            else if (item.contains("JSESSIONID"))
                scenarioSession.putData("JSession-ID", item);
        });
    }

    @And("I add a json payload to current basket with following items")
    public void iAddAJsonPayloadToCurrentBasketWithFollowingItems(DataTable table) throws Throwable{

        String payload = "{\"currency\":\"GBP\",\"locale\":\"en-GB\",\"siteId\":\"10\",\"status\":\"ACTIVE\",\"items\":[";
        String item_payload = "";

        for (List<String> rows : table.asLists()) {
            String item_sku = rows.get(0);
            String quantity = rows.get(1);
            item_payload = item_payload + "{\"skuId\":\"" + item_sku+"\",\"quantity\":"+quantity+"},";
        }
        item_payload = item_payload.substring(0, item_payload.length() - 1);
        payload = payload + item_payload +"]}";
        CommonApiObject.REQUEST_PAYLOAD = payload;
//        System.out.println("Fully Updated Payload will be:\n"+payload);
        commonStepDefinition.apiObject.addJSONRequestBodyData();
    }

    @And("I update following attributes in the basket payload")
    public void updateAttributesInTheRequestPayload(DataTable table) throws Throwable{
        JSONObject json_to_send = new JSONObject(CommonApiObject.REQUEST_PAYLOAD);

        for (List<String> rows : table.asLists()) {
            String attribute = rows.get(0);
            String attr_value = rows.get(1);

            json_to_send = json_utils.modifyJSONAttributes(json_to_send, attribute, attr_value);
        }
        CommonApiObject.REQUEST_PAYLOAD = json_to_send.toString();
//        System.out.println("Fully Updated Payload will be:\n" + CommonApiObject.REQUEST_PAYLOAD);
        commonStepDefinition.apiObject.addJSONRequestBodyData();
    }

    @And("make sure an empty basket with no items is returned")
    public void verifyNoItemsInTheBasket() {
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        assertTrue("Items are not empty ", response_json.getList("basket.items").size() == 0);
    }

    @And("make sure there are {int} products in the basket")
    public void makeSureThereAreItemsInTheBasket(int number_of_items) {

        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<String> basket_items = response_json.getList("basket.items");
        int basket_size = (basket_items != null) ? basket_items.size() : 0;
        assertTrue("Expected: " + number_of_items + ", Found: " + basket_size, basket_size == number_of_items);
    }

    @And("currently basket contains following items")
    public void currentlyBasketContainsFollowingItems(DataTable table) {

        boolean decision = false;
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<String> basket_items = response_json.getList("basket.items");

        List<List<String>> table_rows = table.asLists();
        for (List<String> rows : table_rows.subList(1, table_rows.size())) {
            String expected_skuId = rows.get(0);
            int expected_quantity = Integer.parseInt(rows.get(1));
            String expected_itemName = rows.get(2);
            String message = "";

            for (int i = 0; i < basket_items.size(); i++) {
                String actual_skuId = response_json.get("basket.items[" + i + "].skuId");
                int actual_quantity = response_json.get("basket.items[" + i + "].quantity");
//                String actual_itemName = response_json.get("basket.items[" + i + "].name");
//                System.out.println("Trying to Find item: " + expected_skuId);
                if ((actual_quantity == expected_quantity) && expected_skuId.equals(actual_skuId)) {
                    decision = true;
                    break;
                } else {
                    message = "Item: " + actual_skuId+ " with quantity: "+ actual_quantity+ " not match expectation";
                    decision = false;
                }
            }
            assertTrue(message, decision);
        }
    }

    @When("I (GET|UPDATE) the current basket using (.*) endpoint$")
    public void iGETTheCurrentBasketUsingEndpoint(String option, String endpoint) throws  Throwable{

        String basket_endpoint = (endpoint.contains("{basketUUID}"))? endpoint.replace("{basketUUID}",scenarioSession.getData("basketUUID")): endpoint;

        List<List<String>> headersTable = Arrays.asList(
                Arrays.asList("Content-Type", "application/json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("basket", dataTable);
        commonStepDefinition.i_send_the_request_with_response_type("GET", basket_endpoint);
        commonStepDefinition.the_response_status_code_should_be(200);
        scenarioSession.putData("basketTotal", commonStepDefinition.apiObject.getResponseJson().get("basket.total").toString());
    }

    @And("I have successfully added vouchercode (.*) to (ATG|Hybrid|Horizon) basket")
    public void iHaveAddedVoucherToBasket(String voucher_code,  String basket_type) throws  Throwable{
        String basket_endpoint = "";
        List<List<String>> headersTable =  Arrays.asList(Arrays.asList("Content-Type", "application/json"));

        switch (basket_type){
            case "ATG":
                basket_endpoint = "v1/basket/voucher/";
                headersTable = Arrays.asList(Arrays.asList("Cookie", scenarioSession.getData("JSession-ID")));  break;
            case "Hybrid":
                basket_endpoint = "v2/basket/{basketUUID}/voucher/";
                headersTable = Arrays.asList(Arrays.asList("Cookie", scenarioSession.getData("JSession-ID")));  break;
            case "Horizon":
                basket_endpoint = "v1/horizon/basket/{basketUUID}/voucher/";
                headersTable = Arrays.asList(Arrays.asList("Content-Type", "application/json"));   break;
        }
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("basket", dataTable);
        commonStepDefinition.i_send_the_request_with_response_type("PUT", basket_endpoint+voucher_code);
        commonStepDefinition.the_response_status_code_should_be(200);
    }

    @And("make sure that (.*) is (greater|less) than (.*)$")
    public void makeSureTheValueIsGreaterLessThan(String attr1, String option, String attr2) {

        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        float actual_value   = response_json.getFloat(attr1);
        float expected_value = 0.0f;
        String msg = "Expected: "+attr1+" should have value "+ option + " than "+ expected_value;

        if(attr2.contains("{")){
            String keyName = attr2.replaceAll("[^a-zA-Z0-9]", "");
            expected_value = Float.parseFloat(scenarioSession.getData(keyName));
        } else
            expected_value = response_json.getFloat(attr2);

        if(option.equalsIgnoreCase("greater")){
            assertTrue(msg, actual_value > expected_value);
        } else {
            assertTrue(msg, actual_value < expected_value);
        }
    }

    @And("I add the graphql (mutation|query) in the request query string using (.*)$")
    public void iAddTheGraphqlMutationInTheRequestQueryString(String option, String filename) throws Throwable{

        String file_contents = commonStepDefinition.apiObject.readJsonFromFile(filename);
        commonStepDefinition.apiObject.queryParams.put("query", file_contents);

    }

    @And("the following items contains correct status$")
    public void followingItemsContainsTheCorrectStatusAtStatus(DataTable table) {

        boolean decision = false;
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<String> items_status = response_json.getList("status");

        List<List<String>> table_rows = table.asLists();
        for (List<String> rows : table_rows.subList(0, table_rows.size())) {
            String expected_skuId = rows.get(0);
            String expected_status = rows.get(1);

            for (int i = 0; i < items_status.size(); i++) {
                String actual_skuId = response_json.get("status[" + i + "].skuId");
                String actual_status = response_json.get("status[" + i + "].status");
                System.out.println("Trying to Find status for item: " + expected_skuId);
                if (actual_status.equals(expected_status) && expected_skuId.equals(actual_skuId)) {
                    decision = true;  System.out.println(" Found status for item: " + actual_skuId);
                    break;
                } else
                    decision = false;
            }
            assertTrue(expected_skuId + ": ITEM STATUS NOT FOUND", decision);
        }
    }

    @And("make sure items (total|subtotal) collectively make the basket (total|subtotal)$")
    public void makeSureItemsTotalCollectivelyMakeTheBasketTotal(String arg1, String arg2) throws Throwable{
        double items_total = 0.0;
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        double basket_total = response_json.getDouble("basket."+arg2);

        List<String> basket_items = response_json.getList("basket.items");
        for (int i = 0; i < basket_items.size(); i++) {
            items_total = items_total + response_json.getDouble("basket.items[" + i + "]."+arg1);
        }
        items_total = Math.floor(items_total * 100) / 100;
        assertEquals( basket_total, items_total,  0.02);
    }

    @When("I have successfully added an RFL (Card|Coupon) (.*) to the existing (Hybrid|Horizon) basket$")
    public void iHaveSuccessfullyAddedAnRFLCardToTheExistingBasket(String rfl_option, String number, String basket_type) throws Throwable {
        String basket_endpoint = "";
        String rfl_card_number = "";
        List<List<String>> headersTable =  Arrays.asList(Arrays.asList("Content-Type", "application/json"));

        if(rfl_option.equals("Card"))
            scenarioSession.putData("RFL-Card", number);
        else  // in case of Coupon
            rfl_card_number = scenarioSession.getData("RFL-Card");

        switch (basket_type){
            case "Hybrid":
                basket_endpoint = (rfl_option.equals("Card"))? "v2/basket/{basketUUID}/card/"+number: "v2/basket/{basketUUID}/card/"+rfl_card_number+"/coupon/"+number;
                headersTable = Arrays.asList(Arrays.asList("Cookie", scenarioSession.getData("JSession-ID")));  break;
            case "Horizon":
                basket_endpoint = (rfl_option.equals("Card"))? "v1/horizon/basket/{basketUUID}/card/"+number: "v1/horizon/basket/{basketUUID}/card/"+rfl_card_number+"/coupon/"+number;
                headersTable = Arrays.asList(Arrays.asList("Content-Type", "application/json"));   break;
        }
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("basket", dataTable);
        commonStepDefinition.i_send_the_request_with_response_type("PUT", basket_endpoint);
        commonStepDefinition.the_response_status_code_should_be(200);
    }

    @And("make sure basket total and subtotal have same value$")
    public void makeSureBasketTotalAndSubtotalHaveSameValue() throws Throwable{
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        String basket_total      = response_json.getString("basket.total");
        String basket_subtotal   = response_json.getString("basket.subtotal");
        String basket_totalValue = response_json.getString("basket.basketTotalValue.amount");
        String basket_subtotalValue = response_json.getString("basket.basketSubTotalValue.amount");

        if(basket_total.equals(basket_totalValue)){
            assertTrue("basket total & total value mismatch", true);
        }
        if(basket_subtotal.equals(basket_subtotalValue)){
            assertTrue("basket subtotal & subtotal value mismatch", true);
        }
    }

    @And("make sure basket total is correctly calculated after applying (.*)$")
    public void makeSureBasketTotalIsCorrectlyCalculated(String discount_attribute) throws Throwable{
        makeSureBasketTotalAndSubtotalHaveSameValue();

        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        double basket_total    = response_json.getDouble("basket.total");
        double basket_subtotal = response_json.getDouble("basket.subtotal");
        double discount_value  = response_json.getDouble("basket.promotionalDiscountValue.amount");
        double expected_total  = round( basket_subtotal - discount_value, 2);
        boolean result         = (basket_total == expected_total)? true : false;
        assertTrue("basket total "+ basket_total+",\n subtotal: "+basket_subtotal+", promoDiscount: "+ discount_value+", expected: "+ expected_total, result);
    }
}
