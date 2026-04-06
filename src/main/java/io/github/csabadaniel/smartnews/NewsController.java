package io.github.csabadaniel.smartnews;

import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class NewsController {

    private final NewsService newsService;

    @GetMapping("/news")
    public String getNews() {
        return newsService.getNews();
    }

    @PostMapping("/news/mail")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void sendNewsMail() {
        newsService.sendMail();
    }

}
