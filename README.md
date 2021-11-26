# horizon-api-project
Api Automation Framework with Maven, Java, SpringBoot to test REST &amp; GraphQL Apis


## Overview
This Project outlines the framework structure for Horizon API Test Automation. 
It fulfills the need of any REST Based Api Testing for all its GET, PUT, POST, PATCH or DELETE Calls. 


## Getting Started

### 1. Install the [JDK1.8 Download Site](https://www.oracle.com/uk/java/technologies/javase/javase-jdk8-downloads.html)
### 2. Download Maven onto your local [Maven Site](https://maven.apache.org/download.cgi)
### 3. Download / Install IntelliJIdea Community Edition from [IDEA website](https://www.jetbrains.com/idea/download/#section=windows)
### 4. Set the Necessary Env Variables for the JDK and Maven /bin folders.
### 5. Clone the repository & Checkout the necessary branch
### 6. Open the Project in IntelliJIDEA using pom.xml
### 7. Execute the Unit and Integration tests to verify a stable build
* Sanity Tests 
    
        >mvn clean -U install "-Dcucumber.options=--tags @sanity"

* Integration Tests

        >clean -U install "-Dcucumber.options=--tags @api"

        >clean -U install "-Dcucumber.options=--tags @basket"


## FAQ

For Detailed instructions and settings, please visit https://hbidigital.atlassian.net/wiki/spaces/DD/pages/1388806172/Api+Test+Automation+Guidelines
