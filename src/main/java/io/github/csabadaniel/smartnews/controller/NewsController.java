package io.github.csabadaniel.smartnews.controller;

import io.github.csabadaniel.smartnews.service.NewsService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class NewsController {

    private final NewsService newsService;

    NewsController(NewsService newsService) {
        this.newsService = newsService;
    }

    @GetMapping("/news")
    public ResponseEntity<NewsResponse> getNews() {
        return ResponseEntity.ok(new NewsResponse(newsService.getNews()));
    }
}
