package io.github.csabadaniel.smartnews;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class SmartNewsApplicationTests {

    private static final String HEALTH_ENDPOINT = "/actuator/health";
    private static final String STATUS_PATH = "$.status";
    private static final String HEALTH_STATUS_UP = "UP";

    @Autowired
    private MockMvc mockMvc;

    @Test
    void actuatorHealthIsUp() throws Exception {
        mockMvc.perform(get(HEALTH_ENDPOINT))
                .andExpect(status().isOk())
                .andExpect(jsonPath(STATUS_PATH).value(HEALTH_STATUS_UP));
    }

}
