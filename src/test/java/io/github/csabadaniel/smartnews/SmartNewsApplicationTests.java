package io.github.csabadaniel.smartnews;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class SmartNewsApplicationTests {

    @Value("${local.server.port}")
    private int port;

    private final HttpClient client = HttpClient.newHttpClient();

    @Test
    void contextLoads() {
    }

    @Test
    void actuatorHealthIsUp() throws Exception {
        HttpRequest request = HttpRequest.newBuilder().uri(URI.create("http://localhost:" + port + "/actuator/health")).GET().build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        assertEquals(200, response.statusCode());
        assertEquals("UP", JsonPath.<String>read(response.body(), "$.status"));
    }

    @Test
    void newsEndpointReturnsNewsAsJsonString() throws Exception {
        HttpRequest request = HttpRequest.newBuilder().uri(URI.create("http://localhost:" + port + "/news")).GET().build();

        HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

        assertEquals(200, response.statusCode());
        assertEquals("Smart news will be returned here.", JsonPath.<String>read(response.body(), "$.news"));
    }

}
