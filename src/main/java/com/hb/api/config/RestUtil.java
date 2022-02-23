package com.hb.api.config;

import com.google.gson.JsonObject;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import io.restassured.response.ResponseBody;
import io.restassured.specification.ProxySpecification;
import io.restassured.specification.RequestSpecification;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.CloseableHttpResponse;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.mime.MultipartEntityBuilder;
import org.apache.http.entity.mime.content.FileBody;
import org.apache.http.impl.client.BasicCredentialsProvider;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;
import org.junit.Assert;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.context.annotation.Scope;
import org.springframework.util.ResourceUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Arrays;
import java.util.Map;

import static io.restassured.RestAssured.given;

@Component
@Scope("cucumber-glue")
public class RestUtil {

    private static final Logger LOGGER = LoggerFactory.getLogger(RestUtil.class);

    @Value("${proxyHost}")
    private String proxyHost;

    @Value("${proxyPort}")
    private String proxyPort;

    @Value("${proxyUsername}")
    private String userName;

    @Value("${proxyPassword}")
    private String userPassword;

    @Value("${keyStorePassword}")
    private String keyStorePassword;

    @Value("${keystoreLocation}")
    private String keystoreLocation;

    @Value("${test.environment}")
    private String testEnv;

    @Value("${jira.base.uri}")
    private String jiraBaseURL;

    @Value("${jira.username}")
    private String jiraUsername;

    @Value("${jira.password}")
    private String jiraPassword;

    @Autowired
    private JWTCreatorUtil jwtCreatorUtil;

    private RequestSpecification requestSpecification;
    private RequestSpecification requestSpecification2;

    private Response response;

    public RestUtil() {
    }

    public void initiateRequest(String baseURI) {
        requestSpecification = given();
        requestSpecification.log().all();
        requestSpecification.baseUri(baseURI);
        ProxySpecification proxySpecification = new ProxySpecification(proxyHost, new Integer(proxyPort), "http").withAuth(userName, userPassword);
        requestSpecification.proxy(proxySpecification);
    }

    // initiate request for tyk end point
    public void initiateRequestForTyk(String baseUri) {
        requestSpecification = given();
        requestSpecification.log().all(true);
        requestSpecification.baseUri(baseUri);
    }

    public void setQueryParam(String param, String paramValue) {
        requestSpecification.queryParam(param, paramValue);
    }

    public void initiateRequestWithoutToken(String baseURI) {
        requestSpecification = given();
        requestSpecification.log().all();
        requestSpecification.baseUri(baseURI);
    }

    public void setContentType(ContentType Type) {
        requestSpecification.contentType(Type);
    }

    public void setHeaders(String headerName, String headerValue) {
        requestSpecification.header(headerName, headerValue);
    }

    public void generatePostBodyFromJsonObject(JsonObject jsonObject) {
        requestSpecification.body(jsonObject.toString());
    }

    public void generatePostBodyFromJsonObject(JSONObject jsonObject) {
        requestSpecification.body(jsonObject.toString());
    }

    public void getRequest(String url) {
        // Making GET request directly by RequestSpecification.get() method
        response = requestSpecification.get(url);
        System.out.println(url);
        System.out.println("Response body is " + response.getBody().asString());
    }

    public void postRequest(String url, String bearerToken) throws IOException {
        response = requestSpecification.accept(ContentType.JSON)
                .keyStore(ResourceUtils.getFile(keystoreLocation), keyStorePassword)
                .trustStore(ResourceUtils.getFile(keystoreLocation), keyStorePassword)
                .auth().oauth2(bearerToken).post(url);
        LOGGER.info("URL is " + url);
        LOGGER.info(response.getBody().asString());
    }

    public void postRequestWithoutToken(String url) {
        response = requestSpecification.accept(ContentType.JSON).post(url);
        System.out.println("URL is " + url);
        System.out.println(response.getBody().asString());
    }


    public Response getResponseJson() {
        return response;
    }


    public String generateBearerToken(String iamBaseUri) throws Exception {
        RequestSpecification requestSpecification = given()
                .log().all()
                .keyStore(ResourceUtils.getFile(keystoreLocation), keyStorePassword)
                .trustStore(ResourceUtils.getFile(keystoreLocation), keyStorePassword)
                .baseUri(iamBaseUri);

        Response response = requestSpecification.contentType(ContentType.URLENC)
                .formParam("grant_type", "client_credentials")
                .formParam("client_assertion_type", "urn:ietf:params:oauth:client-assertion-type:jwt-bearer")
                .formParam("scope", "mortgages-v1:hbo-credit-risk-scoring")
                .formParam("client_assertion", jwtCreatorUtil.getJwt())
                .post("/as/token.oauth2");
        return new JSONObject(response.getBody().prettyPrint()).get("access_token").toString();
    }

    public HttpPost authJIRA(String URL) {
        String auth = (Arrays.toString((jiraUsername + ":" + jiraPassword).getBytes()));
        HttpPost httppost = new HttpPost(URL);
        httppost.setHeader("X-Atlassian-Token", "nocheck");
        httppost.setHeader("Authorization", "Basic " + auth);
        return httppost;
    }

    public boolean addAttachmentToIssue(String issueKey, String fullfilename) throws IOException {

        boolean flag = false;
        String url = jiraBaseURL + "/api/latest/issue/" + issueKey + "/attachments";
        CloseableHttpClient httpclient = HttpClients.createDefault();
//        String auth = (Arrays.toString(("anbam:test").getBytes()));
//        String jira_attachment_baseURL = "https://jira-dts.fm.rbsgrp.net/";
//        HttpPost httppost = new HttpPost(jira_attachment_baseURL + "/api/latest/issue/" + issueKey + "/attachments");
//        httppost.setHeader("X-Atlassian-Token", "nocheck");
//        httppost.setHeader("Authorization", "Basic " + auth);

        HttpPost httppost = authJIRA(url);

        File fileToUpload = new File(fullfilename);
        FileBody fileBody = new FileBody(fileToUpload);

        HttpEntity entity = MultipartEntityBuilder.create()
                .addPart("file", fileBody)
                .build();

        httppost.setEntity(entity);
        String mess = "executing request " + httppost.getRequestLine();
//        logger.info(mess);
        System.out.println(mess);

        CloseableHttpResponse response = null;

        try {
            response = httpclient.execute(httppost);
        } catch (Exception e) {
            System.out.println(e.getLocalizedMessage());
        } finally {
            httpclient.close();
        }

        if (response.getStatusLine().getStatusCode() == 200) {
            flag = true;
        }

        return flag;
    }

    public String getMetadataFromJIRA() {
        String url = jiraBaseURL + "/rest/api/latest/issue/createmeta";
        String strResponse = "";
//        String auth = (Arrays.toString((jiraUsername + ":" + jiraPassword).getBytes()));
//        CloseableHttpClient httpclient = HttpClients.createDefault();
//        CredentialsProvider provider = new BasicCredentialsProvider();
//        UsernamePasswordCredentials credentials = new UsernamePasswordCredentials(jiraUsername,jiraPassword);
//        provider.setCredentials(AuthScope.ANY, credentials);
//        HttpClient client = HttpClientBuilder.create().setDefaultCredentialsProvider(provider).build();

//        HttpClient client = HttpClients.createDefault();

//        HttpGet httpGet =new HttpGet(url);
//        httpGet.setHeader("X-Atlassian-Token", "nocheck");
//        httpGet.setHeader("Authorization", "Basic " + auth);
//        httpGet.setHeader("Content-Type", "application/json" );
//        HttpResponse response = null;



//        try {
//            response = client.execute(httpGet);
//            HttpEntity entity = response.getEntity();
//            strResponse = entity.getContent().toString();
//        } catch (Exception e) {
//            System.out.println(e.getLocalizedMessage());
//        }
//        RestAssured.baseURI = jiraBaseURL;
//        RequestSpecification httpRequest = given();
//        httpRequest.header("Content-Type","application/json");
        Response resp = given().auth().basic(jiraUsername, jiraPassword).header("Content-Type","application/json").get(url);
        ResponseBody obj = resp.getBody();
        return strResponse;
    }


    //Response code assertion

    public void checkStatusCode(int statusCode){
        int actual_status = response.getStatusCode();
        Assert.assertEquals(statusCode, actual_status);
    }
    public void checkStatusLine(String statusLine){
        String actual_status = response.getStatusLine();
        Assert.assertEquals(statusLine, actual_status);
    }

    public void checkStatusIs200() {
        Assert.assertEquals("Response OK", 200, response.getStatusCode());
    }

    public void checkStatusIs400() { Assert.assertEquals("Mandatory missing ", 400, response.getStatusCode());   }

    public void checkStatusIs401() {
        Assert.assertEquals("Authentication error", 401, response.getStatusCode());
    }

    public void checkStatusIs403() {
        Assert.assertEquals("Forbidden", 403, response.getStatusCode());
    }

    public void checkStatusIs404() {
        Assert.assertEquals("Not Found", 404, response.getStatusCode());
    }

    public void checkStatusIs500() { Assert.assertEquals("Response Internal Server Error", 500, response.getStatusCode()); }

    public void checkStatusIs422() {
        Assert.assertEquals("Response NOT FOUND", 422, response.getStatusCode());
    }

    //Response body evaluation


}
