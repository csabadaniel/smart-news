package io.github.csabadaniel.smartnews;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(NewsController.class)
class NewsControllerTest {

    private static final String NEWS_ENDPOINT = "/news";
    private static final String NEWS_MAIL_ENDPOINT = "/news/mail";
    private static final String NEWS_RESPONSE = "Top story: TDD works.";

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private NewsService newsService;

    @Test
    void shouldReturnNewsFromService() throws Exception {
        when(newsService.getNews()).thenReturn(NEWS_RESPONSE);

        mockMvc.perform(get(NEWS_ENDPOINT))
                .andExpect(status().isOk())
                .andExpect(content().string(NEWS_RESPONSE));
    }

    @Test
    void shouldReturnNoContentWhenMailEndpointIsCalled() throws Exception {
        mockMvc.perform(post(NEWS_MAIL_ENDPOINT))
                .andExpect(status().isNoContent());

        verify(newsService).sendMail();
    }

}
