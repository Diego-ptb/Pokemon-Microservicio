package com.pokemon.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.License;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Configuración de Swagger/OpenAPI.
 *
 * Define metadatos de la API que se mostrarán en la documentación Swagger.
 * Accesible en: http://localhost:8080/swagger-ui/index.html
 */
@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Pokemon Service API")
                        .version("1.0.0")
                        .description("CRUD REST API para gestionar Pokémon con Spring Boot y Supabase")
                        .contact(new Contact()
                                .name("Pokemon Service")
                                .url("https://github.com/yourusername/pokemon-service"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://www.apache.org/licenses/LICENSE-2.0.html")));
    }

}
