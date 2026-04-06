package io.github.csabadaniel.smartnews;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class NewsServiceTest {

    private static final String EXPECTED_NEWS_RESPONSE = "Top story: London school TDD keeps this clean.";
    private static final NewsProperties NEWS_PROPERTIES = new NewsProperties(
            "Give me today's top news summary.",
            new NewsProperties.Mail("smart-news@example.com", "reader@example.com", "Smart News")
    );

    @Mock
    private ChatClient chatClient;

    @Mock
    private ChatClient.ChatClientRequestSpec chatClientRequestSpec;

    @Mock
    private ChatClient.CallResponseSpec callResponseSpec;

    @Mock
    private JavaMailSender mailSender;

    private NewsService newsService;

    @BeforeEach
    void setUp() {
        newsService = new NewsService(chatClient, NEWS_PROPERTIES, mailSender);
    }

    private void stubChatClientToReturn(String content) {
        when(chatClient.prompt(NEWS_PROPERTIES.prompt())).thenReturn(chatClientRequestSpec);
        when(chatClientRequestSpec.call()).thenReturn(callResponseSpec);
        when(callResponseSpec.content()).thenReturn(content);
    }

    @Test
    void shouldGetNewsFromChatClient() {
        stubChatClientToReturn(EXPECTED_NEWS_RESPONSE);

        String news = newsService.getNews();

        assertThat(news).isEqualTo(EXPECTED_NEWS_RESPONSE);
    }

    @Test
    void shouldSendEmailWithActualNewsFromGemini() {
        stubChatClientToReturn(EXPECTED_NEWS_RESPONSE);

        newsService.sendMail();

        SimpleMailMessage expectedMessage = new SimpleMailMessage();
        expectedMessage.setFrom(NEWS_PROPERTIES.mail().from());
        expectedMessage.setTo(NEWS_PROPERTIES.mail().to());
        expectedMessage.setSubject(NEWS_PROPERTIES.mail().subject());
        expectedMessage.setText(EXPECTED_NEWS_RESPONSE);
        verify(mailSender).send(expectedMessage);
    }

}
