package com.mdtalalwasim.ecommerce;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class IntegrationTests {

	@LocalServerPort
	private int port;

	@Autowired
	private TestRestTemplate restTemplate;

	@Test
	public void homePageShouldReturnOkStatus() {
		var response = this.restTemplate.getForEntity("http://localhost:" + port + "/", String.class);

		// Afficher le status HTTP
		System.out.println(" Status code: " + response.getStatusCode());

		// Afficher le corps (body) de la réponse
		System.out.println(" Response body:\n" + response.getBody());

		// Vérification que la réponse est 200 OK
		assertThat(response.getStatusCode().is2xxSuccessful()).isTrue();
	}
}
