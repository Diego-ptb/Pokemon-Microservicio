package com.pokemon.service;

import com.pokemon.dto.CreatePokemonDto;
import com.pokemon.dto.PokemonResponseDto;
import com.pokemon.dto.UpdatePokemonDto;
import com.pokemon.entity.Pokemon;
import com.pokemon.exception.ResourceNotFoundException;
import com.pokemon.repository.PokemonRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/**
 * Tests unitarios para PokemonService.
 *
 * Usa Mockito para mocquear el repositorio.
 * No requiere base de datos real.
 */
@ExtendWith(MockitoExtension.class)
@DisplayName("PokemonService Tests")
class PokemonServiceTest {

    @Mock
    private PokemonRepository pokemonRepository;

    @InjectMocks
    private PokemonService pokemonService;

    private Pokemon testPokemon;
    private CreatePokemonDto createDto;
    private UpdatePokemonDto updateDto;

    @BeforeEach
    void setUp() {
        // Preparar datos de prueba
        testPokemon = new Pokemon();
        testPokemon.setId(1L);
        testPokemon.setName("Pikachu");
        testPokemon.setType("Electric");
        testPokemon.setLevel(25);
        testPokemon.setDescription("El famoso Pokémon");
        testPokemon.setImageUrl("https://example.com/pikachu.png");
        testPokemon.setCreatedAt(LocalDateTime.now());
        testPokemon.setUpdatedAt(LocalDateTime.now());

        createDto = new CreatePokemonDto();
        createDto.setName("Pikachu");
        createDto.setType("Electric");
        createDto.setLevel(25);
        createDto.setDescription("El famoso Pokémon");

        updateDto = new UpdatePokemonDto();
        updateDto.setLevel(50);
    }

    // ============================================
    // Tests para CREATE
    // ============================================

    @Test
    @DisplayName("Crear un Pokémon exitosamente")
    void testCreatePokemon() {
        // Arrange
        when(pokemonRepository.save(any(Pokemon.class))).thenReturn(testPokemon);

        // Act
        PokemonResponseDto result = pokemonService.createPokemon(createDto);

        // Assert
        assertNotNull(result);
        assertEquals("Pikachu", result.getName());
        assertEquals("Electric", result.getType());
        assertEquals(25, result.getLevel());
        verify(pokemonRepository, times(1)).save(any(Pokemon.class));
    }

    // ============================================
    // Tests para READ ALL
    // ============================================

    @Test
    @DisplayName("Obtener todos los Pokémon")
    void testGetAllPokemon() {
        // Arrange
        Pokemon pokemon2 = new Pokemon();
        pokemon2.setId(2L);
        pokemon2.setName("Charizard");
        pokemon2.setType("Fire");
        pokemon2.setLevel(36);

        when(pokemonRepository.findAll()).thenReturn(Arrays.asList(testPokemon, pokemon2));

        // Act
        List<PokemonResponseDto> result = pokemonService.getAllPokemon();

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("Pikachu", result.get(0).getName());
        assertEquals("Charizard", result.get(1).getName());
        verify(pokemonRepository, times(1)).findAll();
    }

    @Test
    @DisplayName("Obtener todos cuando está vacío")
    void testGetAllPokemonEmpty() {
        // Arrange
        when(pokemonRepository.findAll()).thenReturn(Arrays.asList());

        // Act
        List<PokemonResponseDto> result = pokemonService.getAllPokemon();

        // Assert
        assertNotNull(result);
        assertEquals(0, result.size());
        verify(pokemonRepository, times(1)).findAll();
    }

    // ============================================
    // Tests para READ BY ID
    // ============================================

    @Test
    @DisplayName("Obtener Pokémon por ID exitosamente")
    void testGetPokemonById() {
        // Arrange
        when(pokemonRepository.findById(1L)).thenReturn(Optional.of(testPokemon));

        // Act
        PokemonResponseDto result = pokemonService.getPokemonById(1L);

        // Assert
        assertNotNull(result);
        assertEquals(1L, result.getId());
        assertEquals("Pikachu", result.getName());
        verify(pokemonRepository, times(1)).findById(1L);
    }

    @Test
    @DisplayName("Obtener Pokémon por ID no encontrado lanza excepción")
    void testGetPokemonByIdNotFound() {
        // Arrange
        when(pokemonRepository.findById(999L)).thenReturn(Optional.empty());

        // Act & Assert
        ResourceNotFoundException exception = assertThrows(
                ResourceNotFoundException.class,
                () -> pokemonService.getPokemonById(999L));

        assertTrue(exception.getMessage().contains("999"));
        verify(pokemonRepository, times(1)).findById(999L);
    }

    // ============================================
    // Tests para UPDATE
    // ============================================

    @Test
    @DisplayName("Actualizar un Pokémon exitosamente")
    void testUpdatePokemon() {
        // Arrange
        Pokemon updatedPokemon = new Pokemon();
        updatedPokemon.setId(1L);
        updatedPokemon.setName("Pikachu");
        updatedPokemon.setType("Electric");
        updatedPokemon.setLevel(50);
        updatedPokemon.setDescription("El famoso Pokémon");

        when(pokemonRepository.findById(1L)).thenReturn(Optional.of(testPokemon));
        when(pokemonRepository.save(any(Pokemon.class))).thenReturn(updatedPokemon);

        // Act
        PokemonResponseDto result = pokemonService.updatePokemon(1L, updateDto);

        // Assert
        assertNotNull(result);
        assertEquals(50, result.getLevel());
        verify(pokemonRepository, times(1)).findById(1L);
        verify(pokemonRepository, times(1)).save(any(Pokemon.class));
    }

    @Test
    @DisplayName("Actualizar Pokémon no encontrado lanza excepción")
    void testUpdatePokemonNotFound() {
        // Arrange
        when(pokemonRepository.findById(999L)).thenReturn(Optional.empty());

        // Act & Assert
        ResourceNotFoundException exception = assertThrows(
                ResourceNotFoundException.class,
                () -> pokemonService.updatePokemon(999L, updateDto));

        assertTrue(exception.getMessage().contains("999"));
        verify(pokemonRepository, times(1)).findById(999L);
    }

    // ============================================
    // Tests para DELETE
    // ============================================

    @Test
    @DisplayName("Eliminar un Pokémon exitosamente")
    void testDeletePokemon() {
        // Arrange
        when(pokemonRepository.existsById(1L)).thenReturn(true);

        // Act
        pokemonService.deletePokemon(1L);

        // Assert
        verify(pokemonRepository, times(1)).existsById(1L);
        verify(pokemonRepository, times(1)).deleteById(1L);
    }

    @Test
    @DisplayName("Eliminar Pokémon no encontrado lanza excepción")
    void testDeletePokemonNotFound() {
        // Arrange
        when(pokemonRepository.existsById(999L)).thenReturn(false);

        // Act & Assert
        ResourceNotFoundException exception = assertThrows(
                ResourceNotFoundException.class,
                () -> pokemonService.deletePokemon(999L));

        assertTrue(exception.getMessage().contains("999"));
        verify(pokemonRepository, times(1)).existsById(999L);
        verify(pokemonRepository, never()).deleteById(any());
    }

}
