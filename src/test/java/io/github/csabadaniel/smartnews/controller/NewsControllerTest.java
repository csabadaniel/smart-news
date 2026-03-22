package io.github.csabadaniel.smartnews.controller;

import io.github.csabadaniel.smartnews.service.NewsService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@ExtendWith(MockitoExtension.class)
class NewsControllerTest {

    @Mock
    private NewsService newsService;

    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        mockMvc = MockMvcBuilders.standaloneSetup(new NewsController(newsService)).build();
    }

    @Test
    void getNewsReturnsNewsServiceResponse() throws Exception {
        when(newsService.getNews()).thenReturn("Smart news will be returned here.");

        mockMvc.perform(get("/news"))
                .andExpect(status().isOk())
            .andExpect(jsonPath("$.news").value("Smart news will be returned here."));
    }
}
