package com.hb.api.runner;


import io.cucumber.junit.Cucumber;
import io.cucumber.junit.CucumberOptions;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;

@RunWith(Cucumber.class)
@ContextConfiguration(locations = {"file:/src/test/resources/spring-config.xml"})
@CucumberOptions(
        glue = "com.hb.api",
        features = "classpath:cucumber",
        tags = {"not @ignore", "@checkoutsanity"}, // skip tests with @ignore and @device tag (i.e. run test which are not ignore)
        monochrome = true,
        plugin = {"pretty", "html:target/cucumber-reports",
                "json:target/cucumber-reports/cucumber.json",
                "junit:target/cucumber-reports/cucumber.xml",
                "rerun:target/rerun.txt"} //Creates a text file with failed scenarios
)
/* A nice article about Cucumber.Options is here https://testingneeds.wordpress.com/tag/cucumberoptions/    */

public class TestRunner {
}
