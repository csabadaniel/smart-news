package io.github.csabadaniel.smartnews;

import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NewsService {

    private static final String NEWS_PROMPT = "Give me today's top news summary.";

    private final ChatClient chatClient;

    public String getNews() {
        return chatClient.prompt(NEWS_PROMPT)
            .call()
            .content();
    }

}
