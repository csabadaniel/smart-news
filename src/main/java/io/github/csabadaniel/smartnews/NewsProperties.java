package io.github.csabadaniel.smartnews;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "news")
public record NewsProperties(String prompt, Mail mail) {

    public record Mail(String from, String to, String subject) {}

}
