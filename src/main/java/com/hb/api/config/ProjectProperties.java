package com.hb.api.config;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.util.Properties;


public class ProjectProperties {

    private Properties project_properties = new Properties();
    private String project_dir = null;

    public ProjectProperties(){
        try {
            project_dir  = System.getProperty("user.dir");
            loadProperties();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
    public void loadProperties() throws Exception {
        InputStream inputStream =  Thread.currentThread().getContextClassLoader().getResourceAsStream("properties/service.properties");

        if (inputStream == null)
            throw new FileNotFoundException("property file 'project.properties' not found in the classpath");

        project_properties.load(inputStream);
    }

    public String getApplicationBaseUrl(String api_base) {
        String api_url = project_properties.getProperty(api_base + ".base.url");
        return api_url.replace("eu-west-1.dev", "eu-west-1."+ getEnvironment());
    }

    public String getProperty(String property_name){
        return project_properties.getProperty(property_name);
    }

    public String getRequestTimeoutValue() {
        return project_properties.getProperty("request.timeout");
    }

    public String getPayloadPath(){
        return project_dir+"/src/test/resources/json_payload/";
    }

    public String getEnvironment(){ return project_properties.getProperty("test-environment");
    }
}