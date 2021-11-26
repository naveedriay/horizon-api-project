package com.hb.api.api_objects;

import com.hb.api.config.ProjectProperties;
import io.restassured.path.json.JsonPath;
import io.restassured.path.json.exception.JsonPathException;
import org.apache.http.client.HttpClient;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.apache.http.impl.client.HttpClients;
import org.apache.commons.io.FileUtils;

import org.springframework.context.annotation.Scope;
import org.springframework.http.*;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;

import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import java.io.File;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

import java.util.logging.Logger;

@Component
@Scope("cucumber-glue")
public class CommonApiObject {

    private static final Logger log = Logger.getLogger("CommonApiObject");
    public  static String  REQUEST_PAYLOAD = "";

    protected int responseStatusCode;
    protected String responseStatusReason;
    protected String baseUrl, responseBody, requestJson;
    protected JsonPath json_path;
    protected ResponseEntity responseEntity;
    protected HttpStatus responseStatus;
    protected HttpHeaders responseHeaders, requestHeaders;
    protected HttpEntity requestEntity;
    protected UriComponentsBuilder builder;
    protected Object errorBody;

    public RestTemplate restTemplate;   //Added for Reusable Send Request Method
    public Map<String, String> queryParams;
    public ProjectProperties projectProperties;

    public CommonApiObject() {
        restTemplate = new RestTemplate();
        projectProperties = new ProjectProperties();
        HttpComponentsClientHttpRequestFactory requestFactory = new HttpComponentsClientHttpRequestFactory();
        HttpClient httpClient = HttpClients.custom().setSSLHostnameVerifier(new NoopHostnameVerifier()).build();
        int defaultTimeout = Integer.parseInt(projectProperties.getProperty("request.timeout"));
        requestFactory.setHttpClient(httpClient);
        requestFactory.setConnectTimeout(defaultTimeout);
        requestFactory.setReadTimeout(defaultTimeout);
        requestFactory.setConnectionRequestTimeout(defaultTimeout);
        restTemplate.setRequestFactory(requestFactory);
        restTemplate.getMessageConverters().add(0, new StringHttpMessageConverter(Charset.forName("UTF-8")));
        requestHeaders = new HttpHeaders();
        queryParams    = new HashMap<>();
    }

    public String getReformattedDate(String dateValue, String toDatePattern) {
        String reformattedDateString = "";
        try {
            SimpleDateFormat dateFormat = new SimpleDateFormat(toDatePattern);
            dateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
            Date dateObjectToReformat = dateFormat.parse(dateValue);
            reformattedDateString = dateFormat.format(dateObjectToReformat);
            log.info("***Reformatting date from [" + dateValue + "] to [" + reformattedDateString + "]");
        } catch (ParseException e) {
            e.printStackTrace();
        }

        return reformattedDateString;
    }

    public void setBaseUrl(String api_base) {
        baseUrl = projectProperties.getApplicationBaseUrl(api_base);
    }

    public void configureEndpointToBaseUrl(String endpoint) {
        baseUrl = baseUrl + endpoint;
        builder = UriComponentsBuilder.fromHttpUrl(baseUrl);

        queryParams.forEach((param, value) -> {
           // Each parameter value needs to be encoded otherwise you get unexpected behaviour from the called service
            try {
                builder  = builder.queryParam(param, URLEncoder.encode(value, "UTF-8"));
            } catch (UnsupportedEncodingException e) {
                e.printStackTrace();
            }
        });
    }

    public void addHeaders(Map<String, String> headersMap) {
        requestHeaders.clear(); // System.out.println("********** requestHeaders.clear() IS CALLED ***********");
        requestHeaders.setAll(headersMap);
//        requestHeaders.setContentType(MediaType.APPLICATION_JSON_UTF8);
        requestHeaders.setAcceptCharset(Collections.singletonList(StandardCharsets.UTF_8));
        requestHeaders.setAccept(Collections.singletonList(MediaType.APPLICATION_JSON));
        requestEntity = new HttpEntity(requestHeaders);
    }

    public String readJsonFromFile(String fileName) throws Exception {
        fileName = projectProperties.getPayloadPath() + fileName;
        requestJson = FileUtils.readFileToString(new File(fileName), "UTF-8");
        return requestJson;
    }

    public void writeJsonToFile(String json_payload, String fileName) throws Exception {
        fileName = projectProperties.getPayloadPath() + fileName;
        FileUtils.writeStringToFile(new File(fileName),json_payload, "UTF-8");
    }

    public void addJSONRequestBodyData() {
        requestEntity = new HttpEntity<>(REQUEST_PAYLOAD, requestHeaders);
    }

    public JsonPath getResponseJson() {  return JsonPath.with(responseBody);   }

    public String getResponseBody() {  return responseBody;    }

    public ResponseEntity getResponseEntity() {  return responseEntity;   }

    public int getStatusCode() {  return responseStatusCode;   }

    public String getResponseStatusReason() {  return responseStatusReason;  }

    public HttpHeaders getResponseHeaders() {  return responseHeaders;       }

    public void sendRequestToService(String request, Class responseType){
        switch (request) {
            case "GET":
                responseEntity = restTemplate.exchange(builder.build(true).toUri(), HttpMethod.GET, requestEntity, responseType);
                break;
            case "PUT":
                responseEntity = restTemplate.exchange(builder.build(true).toUri(),HttpMethod.PUT, requestEntity, responseType);
                break;
            case "POST":
                responseEntity = restTemplate.exchange(builder.build(true).toUri(),HttpMethod.POST, requestEntity, responseType);
//                responseEntity = restTemplate.postForEntity(builder.build(true).toUri(), requestEntity, responseType);
                break;
            case "DELETE":
                responseEntity = restTemplate.exchange(builder.build(true).toUri(), HttpMethod.DELETE, requestEntity, responseType);
                break;
            case "PATCH":
                responseEntity = restTemplate.exchange(builder.build(true).toUri(), HttpMethod.PATCH, requestEntity, responseType);
                break;
            }
    }

    public void sendRequestToEndpoint(String requestType, String endpoint) {
        configureEndpointToBaseUrl(endpoint);

        System.out.println("Performing a " + requestType + " to URL:" + builder.build(true).toUri() + " with RequestEntity\n"+ requestEntity.toString());
        try {
             Class responseType = Class.forName("java.lang.String");
             sendRequestToService(requestType, responseType);

            responseHeaders = responseEntity.getHeaders();
            responseStatus  = responseEntity.getStatusCode();
            responseStatusReason = responseStatus.getReasonPhrase();
            responseStatusCode   = responseEntity.getStatusCode().value();

            if (responseEntity != null && responseEntity.getBody() != null) {
                log.info("responseEntity= " + responseEntity); // comment me out
                responseBody = responseEntity.getBody().toString();
                json_path = JsonPath.with(responseBody);
            }
        } catch (ClassNotFoundException e) {
                e.printStackTrace();
        } catch (HttpStatusCodeException httpEx) {
            // Get response information
            responseStatus = httpEx.getStatusCode();
            responseStatusCode = responseStatus.value();
            responseStatusReason = responseStatus.getReasonPhrase();
            responseHeaders = httpEx.getResponseHeaders();
            responseBody = httpEx.getResponseBodyAsString();
            errorBody = httpEx.getResponseBodyAsByteArray();
            log.warning(httpEx.getMessage() + " from call " + builder.build(true).toUri());
//            log.warning(httpEx.getResponseBodyAsString());

        } catch (JsonPathException e) { //JSONException
            log.warning("Response body was not JSON: " + e.getMessage());
        } catch (NullPointerException ne) {
            log.warning("Response body was empty: " + ne.getMessage() + " " + ne.toString());
        }

    }

    public void sendGraphqlRequestToServer(){
        builder = UriComponentsBuilder.fromHttpUrl(baseUrl);
        queryParams.forEach((param, value) -> {
            try {   // Each parameter value needs to be encoded otherwise you get unexpected behaviour from the called service
                builder  = builder.queryParam(param, URLEncoder.encode(value, "UTF-8"));
            } catch (UnsupportedEncodingException e) {  e.printStackTrace();
            }
        });
        System.out.println("Performing a POST to URL:" + builder.build(true).toUri() + " with RequestEntity\n"+ requestEntity.toString());
        try {
            Class responseType = Class.forName("java.lang.String");
            sendRequestToService("POST", responseType);

            responseHeaders = responseEntity.getHeaders();
            responseStatus  = responseEntity.getStatusCode();
            responseStatusReason = responseStatus.getReasonPhrase();
            responseStatusCode   = responseEntity.getStatusCode().value();

            if (responseEntity != null && responseEntity.getBody() != null) {
                log.info("responseEntity= " + responseEntity); // comment me out
                responseBody = responseEntity.getBody().toString();
                json_path = JsonPath.with(responseBody);
            }
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        } catch (JsonPathException e) { //JSONException
            log.warning("Response body was not JSON: " + e.getMessage());
        } catch (NullPointerException ne) {
            log.warning("Response body was empty: " + ne.getMessage() + " " + ne.toString());
        }

    }


}
