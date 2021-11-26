package com.hb.api.step_definitions.persuade;

import com.hb.api.config.ScenarioSession;
import com.hb.api.step_definitions.CommonStepDefinition;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.When;
import io.restassured.path.json.JsonPath;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Arrays;
import java.util.List;
import java.util.logging.Logger;

import static org.junit.Assert.assertTrue;

public class PersuadeStepDefinition {

    @Autowired
    protected CommonStepDefinition commonStepDefinition;

    @Autowired
    protected ScenarioSession scenarioSession;

    private static final Logger log = Logger.getLogger("PersuadeStepDefinition");


    @And("I expect following attributes under each array node (.*) to contain")
    public void expectFollowingAttributesInArrayToContain(String arr_attribute, DataTable table) {
        boolean decision = false;
        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
        int item_count = response_json.getList(arr_attribute).size();
        assertTrue("Given array attribute: "+ arr_attribute +" is empty", item_count > 0);

        List<String> all_req_fields = table.row(0); //List<String> all_req_fields = rows.subList(0, rows.size()); // complete 1st row captured.

        for(int row = 1; row < table.asLists().size(); row++) {  //for (List<String> rows : table.asLists()) {
            String expected_siteName = table.row(row).get(0);
            String expected_title0 = table.row(row).get(1);
            String expected_title1 = table.row(row).get(2);
            String expected_title2 = table.row(row).get(3);

            for(int i=0; i < item_count; i++) {
                String actual_siteName = response_json.get(arr_attribute+"[" + i + "].@name");
                String actual_title0 = response_json.get(arr_attribute+"[" + i + "].deliveryOptions0.title");
                String actual_title1 = response_json.get(arr_attribute+"[" + i + "].deliveryOptions1.title");
                String actual_title2 = response_json.get(arr_attribute+"[" + i + "].deliveryOptions2.title");


                if(actual_siteName.equals(expected_siteName) && (actual_title0.contains(expected_title0))) {
//                    System.out.println("RECIEVED DATA: " + actual_siteName + ", " + actual_title0 + ", " + actual_title1 + ", " + actual_title2);
//                    System.out.println("EXPECTED DATA: " + expected_siteName + ", " + expected_title0 + ", " + expected_title1 + ", " + expected_title2);
                    decision = true;
                    break;
                } else {
                    decision = false;
                }
            }
            assertTrue(expected_siteName + ": DATA NOT FOUND", decision);
        }
    }

    @Given("I have created a user session using (.*) endpoint")
    public void iHaveCreatedAUserSessionUsingSessionEndpoint(String endpoint) throws Throwable{

        List<List<String>> headersTable = Arrays.asList(
                Arrays.asList("Content-Type", "application/json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("session", dataTable);
        commonStepDefinition.i_send_the_request_with_response_type("GET", endpoint);
        commonStepDefinition.the_response_status_code_should_be(200);
    }

    @And("^I have (added|deleted) favourite items for this user using (.*)$")
    public void iHaveAddedFavouritesItemsForThisUserUsing(String option, String payloadFilename) throws Throwable {
        String requestType = (option.equals("added"))?"PUT":"DELETE";

        List<List<String>> headersTable = Arrays.asList( Arrays.asList("Content-Type", "application/json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("favourites", dataTable);
        commonStepDefinition.add_a_request_payload_using_file("json", payloadFilename);
        commonStepDefinition.i_send_the_request_with_response_type(requestType, "favourites/user/{UserId}");
        commonStepDefinition.the_response_status_code_should_be(200);
//        JsonPath response_json = commonStepDefinition.apiObject.getResponseJson();
    }

    @When("I get the favourites items for current user")
    public void iGetTheFavouritesItemsForCurrentUserUsing() throws Throwable {
        List<List<String>> headersTable = Arrays.asList(
                Arrays.asList("Content-Type", "application/json"));
        DataTable dataTable = DataTable.create(headersTable);
        commonStepDefinition.iCreateNewRequestWithHeaders("favourites", dataTable);
        commonStepDefinition.i_send_the_request_with_response_type("GET", "favourites/user/{UserId}");
        commonStepDefinition.the_response_status_code_should_be(200);
    }

}
