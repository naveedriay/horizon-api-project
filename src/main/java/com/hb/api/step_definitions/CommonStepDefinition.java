package com.hb.api.step_definitions;

import com.hb.api.api_objects.CommonApiObject;
import com.hb.api.config.JsonUtils;
import com.hb.api.config.ScenarioSession;
import io.cucumber.core.api.Scenario;
import io.cucumber.datatable.DataTable;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.restassured.path.json.JsonPath;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.Assert;
import org.skyscreamer.jsonassert.JSONAssert;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.test.context.ContextConfiguration;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.regex.Pattern;

import static org.junit.Assert.*;

@ContextConfiguration(locations = {"classpath:spring-config.xml"})
public class CommonStepDefinition {

    protected Scenario scenario;
    private final Date date = new Date();

    private static final Logger log = Logger.getLogger("CommonStepDefinition");

    public CommonApiObject apiObject;

    @Autowired
    public ScenarioSession scenarioSession;

    @Autowired
    public JsonUtils jsonUtils;

    /**
     * Get a reference to the current cucumber scenario
     * Supports writing text and xml to report within test steps
     *
     * @param scenario
     */
    @Before
    public void before(Scenario scenario){
        this.scenario = scenario;
    }

    @After
    public void after()  throws Exception{
        scenarioSession.clearScenarioData();
    }

    private int getRandomNumberBetween(double min, double max){
        Double value = (Math.random()*((max-min)+1))+min;
        return value.intValue();
    }

    private String appendEndpointWithCorrectData(String end_point){                 // end_point= v1/horizon/basket/{basketUUID}
        // regex for {basketUUID}  = "({+[a-zA-Z0-9]+})"
        String endpoint_suffix = end_point.substring(end_point.indexOf("{"),end_point.indexOf("}")+1);       // = {basketUUID}
        String keyName = endpoint_suffix.replaceAll("[^a-zA-Z0-9]", ""); // = basketUUID

        return end_point.replace(endpoint_suffix, scenarioSession.getData(keyName));
    }

    private boolean isAttributePresent(String attribute){
        JsonPath response_json = apiObject.getResponseJson();
        try{
            return response_json.get(attribute) != null;
        }
        catch (NullPointerException ne){
            return false;
        }
    }

    @Given("I create a new (.*) api request with following headers$")
    public void iCreateNewRequestWithHeaders(String apiBase, DataTable headersTable) throws Throwable {
        apiObject = new CommonApiObject();
        apiObject.setBaseUrl(apiBase);
        add_the_following_headers_to_the_request(headersTable);
    }

    @And("I add following attributes in the request query string")
    public void iAddAttributesInTheRequestQueryString(DataTable table) {

        for (List<String> rows : table.asLists()) {
            String variable = rows.get(0);
            String value    = rows.get(1);
            apiObject.queryParams.put(variable, value);
        }
    }

    @When("^I add the following headers to the request$")
    public void add_the_following_headers_to_the_request(DataTable headersTable) {
        Map<String, String> headersMap = new HashMap<>();
        String header_name, header_value;
        for (List<String> row : headersTable.asLists()) {
            header_name = row.get(0);
            header_value = row.get(1);
            switch(header_value){
                case "[JSession-ID]":
                    String sessionId = scenarioSession.getData("JSession-ID");
                    headersMap.put(header_name, sessionId);
                    break;
                case "[NonExist-JSessionID]":
                    String corruptId = "iH7nGIZAhcJLFeO40H_EmUP5tuvCS90Xfht6-EMupUp7hihDFXYn!-1051895545"; //invalid non existing sessionId
                    headersMap.put(header_name, corruptId);
                    break;
                case "[bid-Cookie]":
                    String bidCookie = scenarioSession.getData("bid-Cookie");
                    headersMap.put(header_name, bidCookie);
                    break;
                case "[bid-JSess-Cookie]":
                    String cookie = scenarioSession.getData("bid-Cookie") + "," + scenarioSession.getData("JSession-ID");;
                    headersMap.put(header_name, cookie);
                    break;
                default:
                    headersMap.put(header_name, header_value);
            }
        }
        apiObject.addHeaders(headersMap);
    }

    @Then("^The response status code should be (\\d+)$")
    public void the_response_status_code_should_be(int statusCode) throws Throwable {
        assertEquals("Expected Status not received: Expected " + statusCode + ", Got: " + apiObject.getStatusCode() + ":" + apiObject.getResponseStatusReason(), statusCode, apiObject.getStatusCode());
    }

    @And("^I add a (json|graphql) payload using the file (.*)$")
    public void add_a_request_payload_using_file(String option, String dataFileName) throws Throwable {
        if(dataFileName.contains("empty_payload")) {
            CommonApiObject.REQUEST_PAYLOAD = "";
            apiObject.addJSONRequestBodyData();
        } else {
            CommonApiObject.REQUEST_PAYLOAD = apiObject.readJsonFromFile(dataFileName);
//            String payload_json = apiObject.readJsonFromFile(dataFileName);
            apiObject.addJSONRequestBodyData();
        }
    }

    @And("^I add a json payload using filename (.*) replacing values$")
    public void add_a_json_payload_using_filename_replacing(String fileName, DataTable table) throws Throwable {

        String payload = apiObject.readJsonFromFile(fileName);
        JSONObject json_to_send = new JSONObject(payload);

        for (List<String> rows : table.asLists()) {
            String attribute = rows.get(0);
            String attr_value = rows.get(1);

            switch(attr_value) {
                case "{basketUUID}":
                    attr_value = scenarioSession.getData("basketUUID");
                    json_to_send.put(attribute, attr_value);
                    break;
                case "{JSessionID}":
                    attr_value = scenarioSession.getData("JSession-ID").replace("JSESSIONID=","");
                    JSONObject jObject = json_to_send.getJSONObject("sessionInfo").put(attribute, attr_value);
                    json_to_send = json_to_send.put("sessionInfo",jObject);
                    break;
                case "{Corrupt-basketUUID}":
                    attr_value = "15k87-7b81-45d6-8082-3af20e1c"; // invalid corrupt guid value
                    json_to_send.put(attribute, attr_value);
                    break;
                case "{NonExist-basketUUID}":
                    attr_value = "eea36387-7b81-45d6-8082-37af20144e1c"; // non existing Basket UUID
                    json_to_send.put(attribute, attr_value);
                    break;
                case "{NonExist-JSessionID}":
                    attr_value = "iH7nGIZAhcJLFeO40H_EmUP5tuvCS90Xfht6-EMupUp7hihDFXYn!-1051895545"; //invalid non existing sessionId
                    JSONObject jsnObject = json_to_send.getJSONObject("sessionInfo").put(attribute, attr_value);
                    json_to_send = json_to_send.put("sessionInfo",jsnObject);
                    break;
                case "{random-email}":
                    String random_email = "test_"+getRandomNumberBetween(1000,999999)+"@email.com";
                    JSONObject jsonObj_email = json_to_send.getJSONObject("customer").put("email", random_email);
                    json_to_send = json_to_send.put("customer",jsonObj_email);
                    break;
                case "{random-OCHId}":
                    String OCH_ID = "1-"+getRandomNumberBetween(10,99)+"PQR"+getRandomNumberBetween(10,99);
                    json_to_send.getJSONObject("customer").getJSONObject("customer-identifier").put("id", OCH_ID);
                    break;
                case "{cardId}":
                    attr_value = scenarioSession.getData("cardId");
                    json_to_send.put(attribute, attr_value);
                    break;
                case "{tokenId}":
                    attr_value = scenarioSession.getData("tokenId");
                    json_to_send.put(attribute, attr_value);
                    break;
                default:
                    json_to_send = jsonUtils.modifyJSONAttributes(json_to_send, attribute, attr_value);
            }
        }
        payload = json_to_send.toString();
        System.out.println("Fully Updated Payload will be:\n"+payload);
        CommonApiObject.REQUEST_PAYLOAD = payload;
        apiObject.addJSONRequestBodyData();
    }

    @When("^I send a (GET|PUT|PATCH|POST|DELETE) request to (.*) endpoint$")
    public void i_send_the_request_with_response_type(String requestType, String endpoint) throws Throwable {
        endpoint = (endpoint.contains("{"))? appendEndpointWithCorrectData(endpoint): endpoint;
        endpoint = (endpoint.contains(" "))? endpoint.replace(" ", "%20"): endpoint;
        endpoint = (endpoint.contains("|"))? endpoint.replace("|", "%7C"): endpoint;
        apiObject.sendRequestToEndpoint(requestType, endpoint);
    }

    @When("I send a graphql query to its desired server")
    public void iSendAGraphqlQueryToItsDesiredServer() {
        apiObject.sendGraphqlRequestToServer();
    }

    @Then("^make sure following attributes (exist|doesnot exist) within response json$")
    public void makeSureFollowingAttributesExistsWithinResponseJson(String presence, DataTable table) throws Throwable {
        JsonPath response_json = apiObject.getResponseJson();

        for (List<String> rows : table.asLists()) {
            String attribute = rows.get(0);
            String expected_value = rows.get(1);
            if(presence.equals("exist")) {
                assertTrue("Expected attribute "+ attribute+ " NOT FOUND", isAttributePresent(attribute));
                String  actualValue = response_json.get(attribute).toString();
                switch(expected_value) {
                    case "[GUID]":
                        String regexUuid = "[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}";
                        expected_value = expected_value.replaceAll("\\[GUID]", regexUuid);
                        assertTrue("For "+attribute+", didn't get valid GUID",actualValue.matches(expected_value));
                        break;
                    case "[number]":
                        Pattern pattern = Pattern.compile("-?\\d+(\\.\\d+)?");
//                        log.info("For "+ attribute + ": we found= "+ actualValue);
                        assertTrue("received id is not a number", pattern.matcher(actualValue).matches());
                        break;
                    case "[orderId]":
                        String expected_orderId = scenarioSession.getData("orderId");
                        assertEquals("received id is not a number", actualValue, expected_orderId);
                        break;
                    case "[checkoutId]":
                        String expected_checkoutId = scenarioSession.getData("checkoutUUID");
                        assertEquals("received checkoutId doesn't match", actualValue, expected_checkoutId);
                        break;
                    case "[sysDate]":
                        DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd"); // yyyy-MM-dd HH:mm:ss.SSSZ
                        expected_value = dateFormat.format(date); // gets current date in format yyyy-MM-dd
                        actualValue = apiObject.getReformattedDate(actualValue, "yyyy-MM-dd");
                        assertEquals(expected_value, actualValue);
                        break;
                    case "[boolean]":
                        boolean condition = actualValue.equalsIgnoreCase("true") || actualValue.equalsIgnoreCase("false");
                        assertTrue("Found value other than boolean", condition);
                        break;
                    case "[EMPTY]": // attribute value is empty, if not, throw an error
                        boolean var = (actualValue.isEmpty());
                        assertTrue("attribute " + attribute + " is not empty: contains some value:"+actualValue, var);
                        break;
                    case "[NOTEMPTY]": // attribute value could be anything, but not empty
                    case "":
                        boolean var1 = !(actualValue.isEmpty());
                        assertTrue("attribute " + attribute + " is empty: Doesn't contains value", var1);
                        break;
                    case "[value>1]":  // attribute value must be a JSON Array
                        List<Map> items = response_json.getList(attribute); log.info("Found "+ items.size()+" entries for "+ attribute);
                        assertTrue("For "+attribute+", Found count <=1", items.size()>1);
                        break;
                    case "[value>=1]":  // attribute value must be a JSON Array
                        List<Map> items_list = response_json.getList(attribute); log.info("Found "+ items_list.size()+" entries for "+ attribute);
                        assertTrue("For "+attribute+", Found count <=1", items_list.size()>=1);
                        break;
                    case "[value>=0]":  // attribute value must be a JSON Array
                        List<Map> all_items = response_json.getList(attribute); log.info("Found "+ all_items.size()+" entries for "+ attribute);
                        assertTrue("For "+attribute+", Found count <=1", all_items.size()>=0);
                        break;
                    default:
                        assertEquals("For " + attribute, expected_value, actualValue);
                }
            }else
                assertFalse("Attribute ["+ attribute+ "] ACTUALLY FOUND", isAttributePresent(attribute));
        }
    }

    @And("there are {int} records present on page {string}")
    public void thereAreRecordsPresentOnPage(int expected_size, String page_no) {
        JsonPath response_json = apiObject.getResponseJson();
        if(page_no.equals(response_json.get("page").toString())){
            List<String> data_elements = response_json.get("data");
            assertEquals("", data_elements.size(), expected_size);
        }
    }

    @And("make sure the output json file match correctly with (.*)$")
    public void makeSureOutputJsonFileMatchCorrectly(String expected_json_file)  throws Throwable {
        String response_json = apiObject.getResponseJson().prettyPrint();
        String expected_json = apiObject.readJsonFromFile(expected_json_file);
        JSONAssert.assertEquals(expected_json, response_json, false);

       // https://programtalk.com/java-api-usage-examples/io.restassured.internal.path.json.JSONAssertion/
    }

    @And("I save the (.*) from within response (json|header) as (.*)$")
    public void iSaveAttributeFromResponseToScenarioSession(String attribute, String option, String keyName) {
        JsonPath response_json = apiObject.getResponseJson();
        HttpHeaders response_headers = apiObject.getResponseHeaders();

        if(option.equalsIgnoreCase("header")){
            List<String> headersList = response_headers.getValuesAsList(HttpHeaders.SET_COOKIE);
            headersList.forEach(item -> {
                if (item.contains(attribute)) {
                    scenarioSession.putData(keyName, item); // System.out.println(" I saved: "+ keyName+ " : "+ item);
                }
            });
        }
        else {
            if(attribute.equalsIgnoreCase("complete response"))
                scenarioSession.putData(keyName, response_json.toString());
            else
                scenarioSession.putData(keyName, response_json.get(attribute).toString());
        }
    }

    @And("make sure attribute (.*) contains (.*)")
    public void makeSureAttributeContainsValue(String attribute_name, String expected_value) {
        JsonPath response_json = apiObject.getResponseJson();
        String actual_value = response_json.get(attribute_name).toString();
        String failing_msg = "For ["+attribute_name+ "], we found: "+ actual_value;
        assertTrue(failing_msg, actual_value.contains(expected_value));
    }

    @And("I should not see a {string} page")
    public void iShouldNotSeeAPage(String text) {
        String response_html = apiObject.getResponseBody();
        if(response_html != null)
            Assert.assertFalse(response_html.toString().contains(text));
    }

    @And("I wait {int} secs before the next step")
    public void iWaitSecsBeforeTheNextStep(int time_in_sec) throws Throwable{
        Thread.sleep(time_in_sec * 1000);
    }
}
