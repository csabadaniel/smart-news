package io.github.csabadaniel.smartnews;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.boot.test.context.ConfigDataApplicationContextInitializer;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringJUnitConfig;

import static org.assertj.core.api.Assertions.assertThat;

@SpringJUnitConfig
@ContextConfiguration(
        initializers = ConfigDataApplicationContextInitializer.class,
        classes = NewsPropertiesTest.Config.class
)
class NewsPropertiesTest {

    @EnableConfigurationProperties(NewsProperties.class)
    static class Config {}

    @Autowired
    private NewsProperties newsProperties;

    @Test
    void shouldLoadPromptProperty() {
        assertThat(newsProperties.prompt()).isEqualTo("Give me today's top news summary.");
    }

    @Test
    void shouldLoadMailProperties() {
        assertThat(newsProperties.mail()).isEqualTo(
                new NewsProperties.Mail("smart-news@example.com", "reader@example.com", "Smart News", "Here is your news!"));
    }

}
