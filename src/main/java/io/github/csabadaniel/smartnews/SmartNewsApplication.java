package io.github.csabadaniel.smartnews;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class SmartNewsApplication {

    public static void main(String[] args) {
        SpringApplication.run(SmartNewsApplication.class, args);
    }

}
