package io.github.csabadaniel.smartnews;

import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
@RefreshScope
@RequiredArgsConstructor
public class NewsService {

    private final ChatClient chatClient;

    private final NewsProperties newsProperties;

    private final JavaMailSender mailSender;

    public String getNews() {
        return chatClient.prompt(newsProperties.prompt())
            .call()
            .content();
    }

    public void sendMail() {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom(newsProperties.mail().from());
        message.setTo(newsProperties.mail().to());
        message.setSubject(newsProperties.mail().subject());
        message.setText(getNews());
        mailSender.send(message);
    }

}
