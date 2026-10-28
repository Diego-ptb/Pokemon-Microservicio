package com.pokemon.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pokemon.dto.CreatePokemonDto;
import com.pokemon.dto.PokemonResponseDto;
import com.pokemon.dto.UpdatePokemonDto;
import com.pokemon.exception.ResourceNotFoundException;
import com.pokemon.service.PokemonService;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.time.LocalDateTime;
import java.util.List;

import static org.hamcrest.Matchers.hasSize;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Tests de la capa web (controlador + manejo global de errores).
 *
 * Usa @WebMvcTest: levanta solo la capa HTTP, con el servicio mockeado,
 * por lo que no necesita base de datos. Verifica códigos HTTP, validaciones
 * y el formato de las respuestas de error.
 */
@WebMvcTest(PokemonController.class)
@DisplayName("PokemonController Tests")
class PokemonControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockitoBean
    private PokemonService pokemonService;

    private PokemonResponseDto pikachu() {
        return new PokemonResponseDto(1L, "Pikachu", "Electric", 25,
                "El famoso Pokémon", "https://example.com/pikachu.png",
                LocalDateTime.now(), LocalDateTime.now());
    }

    @Test
    @DisplayName("GET /api/pokemons devuelve 200 y la lista")
    void getAllReturnsList() throws Exception {
        when(pokemonService.getAllPokemon()).thenReturn(List.of(pikachu()));

        mockMvc.perform(get("/api/pokemons"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", hasSize(1)))
                .andExpect(jsonPath("$[0].name").value("Pikachu"));
    }

    @Test
    @DisplayName("GET /api/pokemons/{id} devuelve 200 cuando existe")
    void getByIdFound() throws Exception {
        when(pokemonService.getPokemonById(1L)).thenReturn(pikachu());

        mockMvc.perform(get("/api/pokemons/1"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(1))
                .andExpect(jsonPath("$.type").value("Electric"));
    }

    @Test
    @DisplayName("GET /api/pokemons/{id} devuelve 404 con cuerpo de error cuando no existe")
    void getByIdNotFound() throws Exception {
        when(pokemonService.getPokemonById(99L))
                .thenThrow(new ResourceNotFoundException("Pokémon no encontrado con ID: 99"));

        mockMvc.perform(get("/api/pokemons/99"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.message").value("Pokémon no encontrado con ID: 99"))
                .andExpect(jsonPath("$.path").value("/api/pokemons/99"));
    }

    @Test
    @DisplayName("GET /api/pokemons/name/{name} devuelve 200 cuando existe")
    void getByNameFound() throws Exception {
        when(pokemonService.getPokemonByName("pikachu")).thenReturn(pikachu());

        mockMvc.perform(get("/api/pokemons/name/pikachu"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("Pikachu"));
    }

    @Test
    @DisplayName("POST /api/pokemons con datos válidos devuelve 201")
    void createValid() throws Exception {
        CreatePokemonDto dto = new CreatePokemonDto("Pikachu", "Electric", 25, "desc", null);
        when(pokemonService.createPokemon(any(CreatePokemonDto.class))).thenReturn(pikachu());

        mockMvc.perform(post("/api/pokemons")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1));
    }

    @Test
    @DisplayName("POST /api/pokemons sin nombre ni nivel válido devuelve 400 y no llama al servicio")
    void createInvalidReturns400() throws Exception {
        CreatePokemonDto dto = new CreatePokemonDto("", "Electric", 0, null, null);

        mockMvc.perform(post("/api/pokemons")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message").value("Validación fallida"))
                .andExpect(jsonPath("$.errors.name").exists())
                .andExpect(jsonPath("$.errors.level").exists());

        verify(pokemonService, never()).createPokemon(any());
    }

    @Test
    @DisplayName("PUT /api/pokemons/{id} devuelve 200 con el Pokémon actualizado")
    void updateValid() throws Exception {
        UpdatePokemonDto dto = new UpdatePokemonDto(null, null, 30, null, null);
        PokemonResponseDto updated = pikachu();
        updated.setLevel(30);
        when(pokemonService.updatePokemon(eq(1L), any(UpdatePokemonDto.class))).thenReturn(updated);

        mockMvc.perform(put("/api/pokemons/1")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(dto)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.level").value(30));
    }

    @Test
    @DisplayName("DELETE /api/pokemons/{id} devuelve 204")
    void deleteById() throws Exception {
        mockMvc.perform(delete("/api/pokemons/1"))
                .andExpect(status().isNoContent());

        verify(pokemonService).deletePokemon(1L);
    }

    @Test
    @DisplayName("DELETE /api/pokemons/name/{name} devuelve 404 cuando no existe")
    void deleteByNameNotFound() throws Exception {
        doThrow(new ResourceNotFoundException("Pokémon no encontrado con nombre: mew"))
                .when(pokemonService).deletePokemonByName("mew");

        mockMvc.perform(delete("/api/pokemons/name/mew"))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404));
    }

    @Test
    @DisplayName("Un error inesperado devuelve 500 con el formato estándar de error")
    void unexpectedErrorReturns500() throws Exception {
        when(pokemonService.getAllPokemon()).thenThrow(new IllegalStateException("BD caída"));

        mockMvc.perform(get("/api/pokemons"))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.status").value(500));
    }
}
