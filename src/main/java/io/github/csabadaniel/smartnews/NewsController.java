package io.github.csabadaniel.smartnews;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class NewsController {

    @GetMapping("/news")
    public String getNews() {
        return "News will be here soon.";
    }

}
