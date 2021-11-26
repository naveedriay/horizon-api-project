package com.hb.api.step_definitions.checkout;

import com.hb.api.api_objects.CommonApiObject;
import com.hb.api.config.ScenarioSession;
import com.hb.api.step_definitions.CommonStepDefinition;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.restassured.path.json.JsonPath;
import org.json.JSONArray;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;

import java.util.Arrays;
import java.util.List;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

public class CheckoutStepDefinition {

    @Autowired
    protected CommonStepDefinition commonStepDefinition;

    @Autowired
    protected ScenarioSession scenarioSession;

    @Given("I have successfully created Checkout using (.*)$")
    public void iHaveSuccessfullyCreatedANewBasketWithItems(String payloadFilename) throws Throwable {

        List<List<String>> headersTable = Arrays.asList(Arrays.asList("Content-Type", "application/graphql"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("checkout", dataTable);

        List<List<String>> checkoutPayloadTable = Arrays.asList(Arrays.asList("basketUUID", "{basketUUID}"));
        DataTable data_table = DataTable.create(checkoutPayloadTable);
        add_a_graphql_payload_using_file_replacing(payloadFilename, data_table);

        commonStepDefinition.iSendAGraphqlQueryToItsDesiredServer();
        commonStepDefinition.the_response_status_code_should_be(200);

        // saves the basket GUID from responseJson to scenarioSession
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        scenarioSession.putData("checkoutUUID", response_json.get("data.createCheckout.id").toString());

//            for(int i=0; i < response_json.getList("results").size(); i++){
//                assertFalse(response_json.get("results["+i+"].price_per_uom").toString().contains("undefined"));
//            }
    }

    @And("I have successfully (added|queried|selected) (.*) Information using (.*)$")
    public void iHaveSuccessfullyAddedDeliveryInformationUsingFile(String option, String requestType, String filename)  throws Throwable {

        List<List<String>> checkoutPayloadTable = Arrays.asList(Arrays.asList("checkoutUUID", "{checkoutUUID}"));
        List<List<String>> headersTable = Arrays.asList(Arrays.asList("Content-Type", "application/graphql"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("checkout", dataTable);

        switch (requestType){
            case "deliveryOptions":
            case "collectionOptions":
                if(option.equals("selected")) {
                    checkoutPayloadTable = Arrays.asList(Arrays.asList("checkoutUUID", "{checkoutUUID}"),
                                                         Arrays.asList("optionId", "{optionID}"));     }
                break;
            case "saved_delivery": // {addressId} comes from a saved user's deliveryAddresses mutation
                checkoutPayloadTable = Arrays.asList( Arrays.asList("checkoutUUID", "{checkoutUUID}"),
                                                      Arrays.asList("externalId", "{addressId}"));
                break;
            case "payment":
                checkoutPayloadTable = Arrays.asList( Arrays.asList("checkoutUUID", "{checkoutUUID}"),
                                                      Arrays.asList("basketTotal", "{basketTotal}"),
                                                      Arrays.asList("transactionId", "{transactionId}"),
                                                      Arrays.asList("pspReference", "{pspReference}"));
                break;
            default:
                checkoutPayloadTable = Arrays.asList(Arrays.asList("checkoutUUID", "{checkoutUUID}"));
        }

        DataTable data_table = DataTable.create(checkoutPayloadTable);
        add_a_graphql_payload_using_file_replacing(filename, data_table);

        commonStepDefinition.iSendAGraphqlQueryToItsDesiredServer();
        commonStepDefinition.the_response_status_code_should_be(200);

    }

    @And("^I add a graphql payload using filename (.*) replacing values$")
    public void add_a_graphql_payload_using_file_replacing(String dataFileName, DataTable table) throws Throwable {

        String payload = commonStepDefinition.apiObject.readJsonFromFile(dataFileName);
        String new_value = "";

        for (List<String> rows : table.asLists()) {
            String attribute = rows.get(0);
            String replaceable_key = rows.get(1);
            switch(attribute){
                case "checkoutUUID":
                    new_value = (replaceable_key.equals("{checkoutUUID}"))?scenarioSession.getData("checkoutUUID"):replaceable_key;
                    payload = payload.replace("{checkoutUUID}", new_value);
                    break;
                case "basketUUID":
                    new_value = (replaceable_key.equals("{basketUUID}"))?scenarioSession.getData("basketUUID"):replaceable_key;
                    payload = payload.replace("{basketUUID}", new_value);
                    break;
                case "transactionId":
                    new_value = (replaceable_key.equals("{transactionId}"))?scenarioSession.getData("transactionId"):replaceable_key;
                    payload = payload.replace("{transactionId}", new_value);
                    break;
                case "basketTotal":
                    new_value = (replaceable_key.equals("{basketTotal}"))?scenarioSession.getData("basketTotal"):replaceable_key;
                    payload = payload.replace("{basketTotal}", new_value);
                    break;
                case "emailMarketingConsent":
                    payload = payload.replace("emailMarketingConsent: true","");
                    break;
                case "deliveryOption":
                    payload = payload.replace("{deliveryOption}",replaceable_key);
                    break;
                case "instructions":
                    payload = payload.replace("{deliveryInstruction}",replaceable_key);
                    break;
                case "email":
                    payload = payload.replace("{bad-email}",replaceable_key);
                    break;
                case "customerId":
                    payload = payload.replace("{bad-custId}",replaceable_key);
                    break;
                case "externalId":
                    new_value = (replaceable_key.equals("{addressId}"))?scenarioSession.getData("addressId"):replaceable_key;
                    payload = payload.replace("{addressId}",new_value);
                    break;
                case "addressId":
                    new_value = (replaceable_key.equals("{addressId}"))?scenarioSession.getData("addressId"):replaceable_key;
                    payload = payload.replace("{addressId}",new_value);
                    break;
                case "orderId":
                    new_value = (replaceable_key.equals("{orderId}"))?scenarioSession.getData("orderId"):replaceable_key;
                    payload = payload.replace("{orderId}",new_value);
                    break;
                case "userId":
                    new_value = (replaceable_key.equals("{userId}"))?scenarioSession.getData("userId"):replaceable_key;
                    payload = payload.replace("{userId}",new_value);
                    break;
                case "cardId":
                    new_value = (replaceable_key.equals("{cardId}"))?scenarioSession.getData("cardId"):replaceable_key;
                    payload = payload.replace("{cardId}",new_value);
                    break;
                case "optionId":
                    new_value = (replaceable_key.equals("{optionID}"))?scenarioSession.getData("optionID"):replaceable_key;
                    payload = payload.replace("{optionID}",new_value);
                    break;
                case "savedPaymentId":
                case "paymentId":
                    new_value = (replaceable_key.equals("{paymentId}"))?scenarioSession.getData("paymentId"):replaceable_key;
                    payload = payload.replace("{paymentId}",new_value);
                    break;
                case "pspReference":
                    new_value = (replaceable_key.equals("{pspReference}"))?scenarioSession.getData("pspReference"):replaceable_key;
                    payload = payload.replace("{pspReference}",new_value);
                    break;
                case "shopperReference":
                    new_value = (replaceable_key.equals("{customerId}"))?scenarioSession.getData("customerId"):replaceable_key;
                    payload = payload.replace("{customerId}",new_value);
                    break;
                case "applyPayToken":
                    payload = payload.replace("{applyPayToken}",replaceable_key);
                    break;
                case "saveCard":
                    payload = payload.replace("saveCard: false","saveCard: "+replaceable_key);
                    break;
            }
        }
        CommonApiObject.REQUEST_PAYLOAD = payload;
        commonStepDefinition.apiObject.addJSONRequestBodyData();
    }

    @And("make sure the response body contains the (.*)$")
    public void makeSureTheResponseBodyContainsTheData(String response_body_expected) {
        String response_body_actual = commonStepDefinition.apiObject.getResponseBody();
        assertTrue("Expecting "+ response_body_expected+", but Found: "+ response_body_actual,
                response_body_expected.equalsIgnoreCase(response_body_actual));
    }

    @Given("I fetched all the addresses for (.*)")
    public void iFetchedAllTheAddressesFor(String query_str) throws Throwable{
        List<List<String>> headersTable = Arrays.asList(
                Arrays.asList("Content-Type", "application/json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("addresslookup", dataTable);
        commonStepDefinition.i_send_the_request_with_response_type("GET", "search?"+query_str);
        commonStepDefinition.the_response_status_code_should_be(200);
    }

    @And("I verify the order in OMS for the following attributes")
    public void iVerifyTheOrderInOMSForTheFollowingAttributes(DataTable table) throws Throwable{
        Thread.sleep(20000);
        String order_taker_endpoint = "orders/"+scenarioSession.getData("orderId");

        List<List<String>> headersTable = Arrays.asList(
                Arrays.asList("Content-Type", "application/json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("order-taker", dataTable);
        commonStepDefinition.i_send_the_request_with_response_type("GET", order_taker_endpoint);
        commonStepDefinition.the_response_status_code_should_be(200);
        commonStepDefinition.makeSureFollowingAttributesExistsWithinResponseJson("exist", table);
    }

    @And("I call paymentOrchestrator for (.*) using (.*)$")
    public void iQueryPOForPaymentOptionsUsing(String requestType, String filename)  throws Throwable {

        String partial_settleAmount = "0.0";
        List<List<String>> paymentPayloadTable;
        List<List<String>> headersTable = Arrays.asList(Arrays.asList("Content-Type", "application/graphql"));
        DataTable dataTable = DataTable.create(headersTable);

        if(requestType.contains("partial")){
            partial_settleAmount = requestType.substring(requestType.indexOf('-')+1);
            requestType = requestType.substring(0, requestType.indexOf('-'));
        }

        commonStepDefinition.iCreateNewRequestWithHeaders("payment", dataTable);

        switch (requestType){
            case "requestSettle":
                paymentPayloadTable = Arrays.asList(Arrays.asList("transactionId", "{transactionId}"),
                                                    Arrays.asList("basketTotal", "{basketTotal}"),
                                                    Arrays.asList("orderId", "{orderId}")); break;
            case "partialSettle":
                paymentPayloadTable = Arrays.asList(Arrays.asList("transactionId", "{transactionId}"),
                                                    Arrays.asList("basketTotal", partial_settleAmount),
                                                    Arrays.asList("orderId", "{orderId}")); break;
            case "requestCancel":
                paymentPayloadTable = Arrays.asList(Arrays.asList("transactionId", "{transactionId}"));
                break;
            case "requestRefund":
                paymentPayloadTable = Arrays.asList(Arrays.asList("transactionId", "{transactionId}"),
                                                    Arrays.asList("basketTotal", "{basketTotal}")); break;
            case "partialRefund":
                paymentPayloadTable = Arrays.asList(Arrays.asList("transactionId", "{transactionId}"),
                                                    Arrays.asList("basketTotal", partial_settleAmount)); break;
            case "makingRegUserPayment_anyCard":
                paymentPayloadTable = Arrays.asList(Arrays.asList("shopperReference", "979156020"),
                                                    Arrays.asList("saveCard", "true"),
                                                    Arrays.asList("basketTotal", "{basketTotal}")); break;
            case "makingRegUserPayment_savedCard":
                paymentPayloadTable = Arrays.asList(Arrays.asList("shopperReference", "979156020"),
                                                    Arrays.asList("saveCard", "true"),
                                                    Arrays.asList("cardId", "{cardId}"),
                                                    Arrays.asList("basketTotal", "{basketTotal}")); break;
            default:  // when requestType = makingPayment
                paymentPayloadTable = Arrays.asList(Arrays.asList("basketTotal", "{basketTotal}"));
        }

        DataTable data_table = DataTable.create(paymentPayloadTable);
        add_a_graphql_payload_using_file_replacing(filename, data_table);

        commonStepDefinition.iSendAGraphqlQueryToItsDesiredServer();
        commonStepDefinition.the_response_status_code_should_be(200);

        // saving some the values out of makePayment Mutation Response - to be sent to Checkout Orch
        if(requestType.equals("makingPayment") || requestType.contains("makingRegUserPayment")){
            JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
            scenarioSession.putData("transactionId", response_json.get("data.makePayment.transactionId").toString());
            scenarioSession.putData("paymentId", response_json.get("data.makePayment.paymentId").toString());
            scenarioSession.putData("pspReference", response_json.get("data.makePayment.pspReference").toString());
            String payment_status = response_json.get("data.makePayment.status").toString();
            assertEquals("Expecting AUTHORISED, but Found: "+ payment_status, "AUTHORISED", payment_status);
        }
    }

    @And("make sure following delivery options are resulted")
    public void makeSureFollowingDeliveryOptionsAreResulted(DataTable table) {

        boolean decision = false;
        String regexUuid = "[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}";
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<String> all_delivery_options = response_json.getList("data.deliveryOptions");

        List<List<String>> table_rows = table.asLists();
        for (List<String> rows : table_rows.subList(1, table_rows.size())) {
            String expected_option   = rows.get(0);
            String expected_price    = rows.get(1);
            String expected_currency = rows.get(2);
            String expected_optionId = rows.get(3).replaceAll("\\[GUID]", regexUuid);
            String message = "";

            for (int i = 0; i < all_delivery_options.size(); i++) {
                String actual_option    = response_json.get("data.deliveryOptions[" + i + "].type");
                String actual_price     = response_json.get("data.deliveryOptions[" + i + "].price.amount").toString();
                String actual_currency  = response_json.get("data.deliveryOptions[" + i + "].price.currency");
                String actual_optionId  = response_json.get("data.deliveryOptions[" + i + "].optionId");
                System.out.println("Trying to Find Option: " + expected_option);
                if (    expected_price.equals(actual_price)  &&
                        expected_option.equals(actual_option) &&
                        expected_currency.equals(actual_currency) &&
                        actual_optionId.matches(expected_optionId) )
                {
                    decision = true;
                    break;
                } else {
                    message = "Delivery Option: " + expected_option+ " not found in actual response";
                    decision = false;
                }
            }
            assertTrue(message, decision);
        }
    }

    @And("I save the (.*) optionId from response json as optionID$")
    public void iSaveTheOptionIdFromResponseJsonFor(String delivery_option) {
        String optionId_uuid = "";
        boolean decision = false;
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<String> all_delivery_options = response_json.getList("data.deliveryOptions");

        for (int i = 0; i < all_delivery_options.size(); i++) {
            String actual_option = response_json.get("data.deliveryOptions[" + i + "].type");
//            System.out.println("Trying to Find Option: " + delivery_option);
            if (actual_option.equals(delivery_option)) {
                scenarioSession.putData("optionID",  response_json.get("data.deliveryOptions[" + i + "].optionId"));
                decision = true; break;
            } else {
                decision = false;
            }
        }
        assertTrue(delivery_option+ " NOT FOUND among the response json", decision);
    }

    @And("make sure metapack returns following delivery options")
    public void makeSureMetapackReturnsFollowingDeliveryOptions(DataTable table) throws Throwable{

        boolean decision = false;
        JSONArray json_arr = new JSONArray(commonStepDefinition.apiObject.getResponseBody());

        for (int i = 0; i < json_arr.length(); i++) {
            String actual_type = json_arr.getJSONObject(i).getString("type");

            List<List<String>> table_rows = table.asLists();
            for (List<String> rows : table_rows.subList(1, table_rows.size())) {
                String expected_type = rows.get(0);
                if (expected_type.equals(actual_type)) {
                    assertEquals("For "+expected_type+", name not correct",           rows.get(1), json_arr.getJSONObject(i).getString("name"));
                    assertEquals("For "+expected_type+", deliveryMethod not correct", rows.get(2), json_arr.getJSONObject(i).getString("deliveryMethod"));
                    assertEquals("For "+expected_type+", price not correct",          rows.get(3), json_arr.getJSONObject(i).getJSONObject("price").getString("amount"));
                    assertEquals("For "+expected_type+", groupCode not correct",      rows.get(4), json_arr.getJSONObject(i).getJSONObject("carrierData").getString("groupCode"));
                }
            }
        }
    }

    @And("I successfully (added|deleted) a payment card to (.*) api for userId (.*)$")
    public void addingPaymentCardToPaymentcardApiForUserId(String requestType, String api_name, String userId) throws Throwable{
        List<List<String>> jsonPayloadTable;
        List<List<String>> headersTable = Arrays.asList( Arrays.asList("Content-Type", "application/json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders(api_name, dataTable);

        if(requestType.equals("added")){
            jsonPayloadTable = Arrays.asList(Arrays.asList("userId", userId));
            DataTable payload_table = DataTable.create(jsonPayloadTable);
            commonStepDefinition.add_a_json_payload_using_filename_replacing("checkout/paycard/visa_card_payload.json", payload_table);
            commonStepDefinition.i_send_the_request_with_response_type("POST", "payments/card");
        }
        else
            commonStepDefinition.i_send_the_request_with_response_type("DELETE", "payments/{cardId}");

        commonStepDefinition.the_response_status_code_should_be(200);
        commonStepDefinition.iSaveAttributeFromResponseToScenarioSession("id","json", "cardId");
    }

/* ***** Following Step Definition cater for 2 specific scenarios where we want to
 ******* find number of delivery addresses / number of saved cards for a user  ***** */
    @And("make sure there are (.*) found for this user")
    public void makeSureThereAreAddressesFoundForThisUser(String option) {
        int number = Character.getNumericValue(option.charAt(0));
        String attribute_to_fetch = (option.contains("addresses"))?"data.deliveryAddresses":"data.paymentCards.type";
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<String> found_list = response_json.getList(attribute_to_fetch);
        int total_entries = (found_list != null) ? found_list.size() : 0;
        assertTrue("Expected: " + number + ", Found: " + total_entries, total_entries == number);
    }

    @And("I clear all subscriptions orders for customer (.*)$")
    public void iClearAllSubscriptionsOrdersForCustomer(String ochId) throws Throwable{
        List<List<String>> headersTable = Arrays.asList(
                Arrays.asList("Content-Type", "application/vnd.subscription.product.v1+json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("subscribe-item", dataTable);
        commonStepDefinition.i_send_the_request_with_response_type("DELETE", "subscriptions/acceptance-test/customer/"+ ochId);
        commonStepDefinition.the_response_status_code_should_be(200);
    }

    @And("I call paymentCard api for (any|preferred) saved cards for this user (.*)$")
    public void iCallPaymentCardApiForAnySavedCardsForThisUser(String option, String customerId) throws Throwable{
        List<List<String>> headersTable = Arrays.asList(
                Arrays.asList("Content-Type", "application/json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("paymentcard", dataTable);
        commonStepDefinition.i_send_the_request_with_response_type("GET", "cards?userId="+ customerId);
        commonStepDefinition.the_response_status_code_should_be(200);
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        if(option.equals("any"))
            commonStepDefinition.iSaveAttributeFromResponseToScenarioSession("[0].id","json", "cardId");
        else
            scenarioSession.putData("cardId", getPreferredCardId(response_json));
    }

    @And("make sure only (.*) collection option is returned in response$")
    public void makeSureOnlyCollectionOptionIsReturnedInResponse(String collection_type) {

        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        List<Object> collectionList = response_json.getList("data.collectionOptions.type")
                                            .stream()
                                            .distinct()
                                            .collect(Collectors.toList());
        boolean decision = ((collectionList.size() ==1) && collectionList.get(0).equals(collection_type))? true: false;
        assertTrue("Expected Only: "+ collection_type +", Found: "+collectionList.toString(), decision);
    }

    private String getPreferredCardId(JsonPath jsonResponse){
        String preferred_cardId = "";
        List<Boolean> categories = jsonResponse.getList("preferred");
        for (int i = 0; i < categories.size(); i++) {
            if(categories.get(i)) {
                preferred_cardId = jsonResponse.get("["+i+"].id"); break;
            }
        } return preferred_cardId;
    }
}
