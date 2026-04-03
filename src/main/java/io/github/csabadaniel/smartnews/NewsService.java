package io.github.csabadaniel.smartnews;

import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.cloud.context.config.annotation.RefreshScope;
import org.springframework.stereotype.Service;

@Service
@RefreshScope
@RequiredArgsConstructor
public class NewsService {

    private final ChatClient chatClient;

    @Value("${news.prompt}")
    private final String newsPrompt;

    public String getNews() {
        return chatClient.prompt(newsPrompt)
            .call()
            .content();
    }

}
