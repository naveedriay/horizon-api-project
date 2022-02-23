package com.hb.api.config;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Component
public class JsonUtils {
    private static final Logger log = (Logger) LoggerFactory.getLogger(JsonUtils.class);
    private static final Pattern NODE_LIST_ARRAY_PATTERN = Pattern.compile("(.*?)\\[(\\d+)\\]");

    private String lastNode;
    private String parentNode;

    public boolean isNodePresent(JSONObject jsonObject, String node_name) throws JSONException {
        JSONObject json_obj = getCorrectJsonObject(jsonObject, node_name);
        return json_obj.has(lastNode);
    }

    public boolean isValueCorrect(JSONObject jsonObject, String node_name, String node_value) throws JSONException {
        JSONObject json_obj = getCorrectJsonObject(jsonObject, node_name);
        if (json_obj.has(lastNode)) {
            log.debug("lastNode value: "+json_obj.get(lastNode));
            return json_obj.get(lastNode).toString().equals(node_value);
        }
        return false;
    }

    public String getNodeValue(JSONObject jsonObject, String node_name) throws JSONException {
        JSONObject json_obj = getCorrectJsonObject(jsonObject, node_name);
        return json_obj.get(lastNode).toString();
    }
    
       public JSONObject removeJSONAttribute(JSONObject json_to_send, String attribute_to_remove)  throws JSONException{
        JSONObject json_obj = getCorrectJsonObject(json_to_send, attribute_to_remove);
        json_obj.remove(lastNode);
        return json_to_send;
    }

    public JSONObject modifyJSONAttributes(JSONObject json_to_send, String attribute_name, String new_value) throws JSONException {
        JSONObject modified_json = null;

                if (attribute_name.contains(".")) { // check if node_name has a child node or not
            modified_json = getCorrectJsonObject(json_to_send, attribute_name);
            if (new_value.equals(null))
                modified_json.put(lastNode, JSONObject.NULL);
            else
                modified_json.put(lastNode, getDataTypeFor(new_value));
        } else if(attribute_name.contains("[")){
            modified_json = getCorrectJsonArray(json_to_send, attribute_name, new_value);
            json_to_send = modified_json;
        } else {
            modified_json = getCorrectJsonObject(json_to_send, attribute_name);
            if (new_value.equals(null))
                modified_json.put(lastNode, JSONObject.NULL);
            else
                modified_json.put(lastNode, getDataTypeFor(new_value));
            json_to_send = modified_json;
        }

        log.debug("Modified JSON="+modified_json);
        log.debug("JSON To Send="+json_to_send);
        return json_to_send;
    }

    private List<String> getJsonNodesList(String node_name) {
        String[] node_list = node_name.split("\\.");
        return Arrays.asList(node_list);
    }

    private JSONObject getCorrectJsonArray(JSONObject jsonObj, String node_name, String new_value) throws JSONException {
        Matcher matcher = NODE_LIST_ARRAY_PATTERN.matcher(node_name);
        if(matcher.matches()) {
            String arrayNode  = matcher.group(1);
            int index = Integer.parseInt(matcher.group(2));
            JSONArray jsonArr = jsonObj.getJSONArray(arrayNode);
            jsonArr.put(index, new_value);
        }
        return jsonObj;
    }

    private JSONObject getCorrectJsonObject(JSONObject jsonObj, String node_name) throws JSONException {
        lastNode = node_name;
        log.debug("lastNode start="+lastNode);
        if (node_name.contains(".")) { // check if node_name has a child node or not
            List<String> node_list = getJsonNodesList(node_name);
            lastNode = node_list.get(node_list.size() - 1);
            log.debug("lastNode="+lastNode);
            parentNode = node_list.get(0);
            for (int i = 0; i < node_list.size() - 1; i++) {
                String node = node_list.get(i);
                Matcher matcher = NODE_LIST_ARRAY_PATTERN.matcher(node);
                if(matcher.matches()) {
                    String arrayNode  = matcher.group(1);
                    int index = Integer.parseInt(matcher.group(2));
                    jsonObj = (JSONObject) jsonObj.getJSONArray(arrayNode).get(index);
                }
                else {
                    jsonObj = jsonObj.getJSONObject(node_list.get(i));
                }
            }
        }
        return jsonObj;
    }
    
    private Object getDataTypeFor(String new_input_value){
        Object return_obj = new Object();
        String data_type = "";

        if(new_input_value.startsWith("\"") && new_input_value.endsWith("\"")){
            new_input_value = new_input_value.replaceAll("^\"|\"$", "");
            data_type = "String";
        }
        else {
            try (Scanner scanner = new Scanner(new_input_value)) {
                if (scanner.hasNextInt()) data_type = "Integer";
                else if (scanner.hasNextDouble()) data_type = "Double";
                else if (scanner.hasNextBoolean()) data_type = "Boolean";
                else data_type = "String";
            }
        }

        switch (data_type){
            case "Integer":
                return_obj = new Integer(new_input_value); break;
            case "String":
                return_obj = new StringBuilder(new_input_value); break;
            case "Boolean":
                return_obj = new Boolean(new_input_value); break;
            case "Double":
                return_obj = new Double(new_input_value); break;

        }
        return return_obj;
    }
}
