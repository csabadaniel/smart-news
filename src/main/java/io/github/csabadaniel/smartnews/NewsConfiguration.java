package io.github.csabadaniel.smartnews;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.JavaMailSenderImpl;

@Configuration
public class NewsConfiguration {

    private static final Logger log = LoggerFactory.getLogger(NewsConfiguration.class);

    @Bean
    public ChatClient chatClient(ChatModel chatModel) {
        return ChatClient.create(chatModel);
    }

    @Bean
    public CommandLineRunner logMailConfig(NewsProperties newsProperties, JavaMailSender mailSender) {
        return args -> {
            if (mailSender instanceof JavaMailSenderImpl impl) {
                log.info("Mail host: {}", impl.getHost());
                log.info("Mail port: {}", impl.getPort());
                log.info("Mail username: {}", impl.getUsername());
                String password = impl.getPassword();
                log.info("Mail password resolved: {}", password != null && !password.isBlank()
                        ? password.substring(0, Math.min(6, password.length())) + "****"
                        : "EMPTY/NULL");
            }
            log.info("Mail from: {}", newsProperties.mail().from());
            log.info("Mail to: {}", newsProperties.mail().to());
        };
    }

}
