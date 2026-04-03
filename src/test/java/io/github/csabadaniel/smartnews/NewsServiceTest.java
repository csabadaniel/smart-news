package io.github.csabadaniel.smartnews;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.ai.chat.client.ChatClient;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NewsServiceTest {

    private static final String NEWS_PROMPT = "Give me today's top news summary.";
    private static final String EXPECTED_NEWS_RESPONSE = "Top story: London school TDD keeps this clean.";

    @Mock
    private ChatClient chatClient;

    @Mock
    private ChatClient.ChatClientRequestSpec chatClientRequestSpec;

    @Mock
    private ChatClient.CallResponseSpec callResponseSpec;

    private NewsService newsService;

    @BeforeEach
    void setUp() {
        newsService = new NewsService(chatClient, NEWS_PROMPT);
    }

    @Test
    void shouldGetNewsFromChatClient() {
        when(chatClient.prompt(NEWS_PROMPT)).thenReturn(chatClientRequestSpec);
        when(chatClientRequestSpec.call()).thenReturn(callResponseSpec);
        when(callResponseSpec.content()).thenReturn(EXPECTED_NEWS_RESPONSE);

        String news = newsService.getNews();

        assertThat(news).isEqualTo(EXPECTED_NEWS_RESPONSE);
    }

}
