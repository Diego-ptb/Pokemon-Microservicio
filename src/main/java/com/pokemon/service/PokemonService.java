package com.pokemon.service;

import com.pokemon.dto.CreatePokemonDto;
import com.pokemon.dto.UpdatePokemonDto;
import com.pokemon.dto.PokemonResponseDto;
import com.pokemon.entity.Pokemon;
import com.pokemon.exception.ResourceNotFoundException;
import com.pokemon.repository.PokemonRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

/**
 * Servicio de negocio para Pokémon.
 *
 * Responsabilidades:
 * 1. Lógica de negocio (en este caso, es simple)
 * 2. Conversión entre DTOs y Entities
 * 3. Manejo de excepciones
 * 4. Coordinación con el repositorio
 *
 * @Service: Spring lo registra como bean singleton
 * @RequiredArgsConstructor: Lombok genera constructor con dependencias finales
 * @Slf4j: Lombok genera logger automáticamente
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class PokemonService {

    private final PokemonRepository pokemonRepository;

    /**
     * Obtiene todos los Pokémon.
     *
     * @return Lista de PokemonResponseDto
     */
    public List<PokemonResponseDto> getAllPokemon() {
        log.info("Obteniendo todos los Pokémon");
        return pokemonRepository.findAll()
                .stream()
                .map(this::convertToResponseDto)
                .collect(Collectors.toList());
    }

    /**
     * Obtiene un Pokémon por ID.
     *
     * @param id ID del Pokémon
     * @return PokemonResponseDto
     * @throws ResourceNotFoundException si el Pokémon no existe
     */
    public PokemonResponseDto getPokemonById(Long id) {
        log.info("Obteniendo Pokémon con ID: {}", id);
        return pokemonRepository.findById(id)
                .map(this::convertToResponseDto)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Pokémon no encontrado con ID: " + id));
    }

    /**
     * Obtiene un Pokémon por nombre, ignorando mayúsculas/minúsculas.
     *
     * @param name Nombre del Pokémon
     * @return PokemonResponseDto
     * @throws ResourceNotFoundException si el Pokémon no existe
     */
    public PokemonResponseDto getPokemonByName(String name) {
        log.info("Obteniendo Pokémon por nombre: {}", name);
        return pokemonRepository.findByNameIgnoreCase(name)
                .map(this::convertToResponseDto)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Pokémon no encontrado con nombre: " + name));
    }

    /**
     * Crea un nuevo Pokémon.
     *
     * @param createDto Datos del Pokémon a crear
     * @return PokemonResponseDto del Pokémon creado
     */
    @Transactional
    public PokemonResponseDto createPokemon(CreatePokemonDto createDto) {
        log.info("Creando nuevo Pokémon: {}", createDto.getName());

        Pokemon pokemon = new Pokemon();
        pokemon.setName(createDto.getName());
        pokemon.setType(createDto.getType());
        pokemon.setLevel(createDto.getLevel());
        pokemon.setDescription(createDto.getDescription());
        pokemon.setImageUrl(createDto.getImageUrl());

        Pokemon saved = pokemonRepository.save(pokemon);
        log.info("Pokémon creado exitosamente con ID: {}", saved.getId());

        return convertToResponseDto(saved);
    }

    /**
     * Actualiza un Pokémon existente.
     *
     * @param id        ID del Pokémon a actualizar
     * @param updateDto Datos a actualizar
     * @return PokemonResponseDto del Pokémon actualizado
     * @throws ResourceNotFoundException si el Pokémon no existe
     */
    @Transactional
    public PokemonResponseDto updatePokemon(Long id, UpdatePokemonDto updateDto) {
        log.info("Actualizando Pokémon con ID: {}", id);

        Pokemon pokemon = pokemonRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Pokémon no encontrado con ID: " + id));

        // Actualizar solo los campos que no son nulos
        if (updateDto.getName() != null && !updateDto.getName().isBlank()) {
            pokemon.setName(updateDto.getName());
        }
        if (updateDto.getType() != null && !updateDto.getType().isBlank()) {
            pokemon.setType(updateDto.getType());
        }
        if (updateDto.getLevel() != null) {
            pokemon.setLevel(updateDto.getLevel());
        }
        if (updateDto.getDescription() != null) {
            pokemon.setDescription(updateDto.getDescription());
        }
        if (updateDto.getImageUrl() != null) {
            pokemon.setImageUrl(updateDto.getImageUrl());
        }

        Pokemon updated = pokemonRepository.save(pokemon);
        log.info("Pokémon actualizado exitosamente con ID: {}", id);

        return convertToResponseDto(updated);
    }

    /**
     * Elimina un Pokémon por ID.
     *
     * @param id ID del Pokémon a eliminar
     * @throws ResourceNotFoundException si el Pokémon no existe
     */
    @Transactional
    public void deletePokemon(Long id) {
        log.info("Eliminando Pokémon con ID: {}", id);

        if (!pokemonRepository.existsById(id)) {
            throw new ResourceNotFoundException(
                    "Pokémon no encontrado con ID: " + id);
        }

        pokemonRepository.deleteById(id);
        log.info("Pokémon eliminado exitosamente con ID: {}", id);
    }

    /**
     * Convierte una Entity Pokemon a PokemonResponseDto.
     *
     * @param pokemon Entity a convertir
     * @return PokemonResponseDto
     */
    private PokemonResponseDto convertToResponseDto(Pokemon pokemon) {
        return new PokemonResponseDto(
                pokemon.getId(),
                pokemon.getName(),
                pokemon.getType(),
                pokemon.getLevel(),
                pokemon.getDescription(),
                pokemon.getImageUrl(),
                pokemon.getCreatedAt(),
                pokemon.getUpdatedAt());
    }

}
