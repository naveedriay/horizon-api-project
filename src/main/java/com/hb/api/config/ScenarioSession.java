package com.hb.api.config;

import org.springframework.context.annotation.Scope;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;
import java.util.logging.Logger;

@Component
public class ScenarioSession {

    private static final java.util.logging.Logger log = Logger.getLogger("ScenarioSession");

    private Map<String, String> sessionData = new HashMap<String, String>();

    public void putData(String key, String value) {
//        log.info("Putting data with key=" + key + " value=" + value);
        sessionData.put(key, value);
    }

    public String getData(String key) {
//        log.info("Getting data with key=" + key + " value=" + sessionData.get(key));
        return sessionData.get(key);
    }

    public void clearScenarioData() {
//        log.info("Clearing scenario data...");
        sessionData.clear();
    }

}

