package io.github.csabadaniel.smartnews.service;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class NewsServiceTest {

    private final NewsService newsService = new NewsService();

    @Test
    void getNewsReturnsStaticMessage() {
        String result = newsService.getNews();

        assertEquals("Smart news will be returned here.", result);
    }
}
