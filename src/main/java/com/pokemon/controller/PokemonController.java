package com.pokemon.controller;

import com.pokemon.dto.CreatePokemonDto;
import com.pokemon.dto.UpdatePokemonDto;
import com.pokemon.dto.PokemonResponseDto;
import com.pokemon.service.PokemonService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador REST para Pokémon.
 *
 * Maneja todas las requests HTTP relacionadas con el CRUD de Pokémon.
 *
 * Responsabilidades:
 * 1. Definir endpoints REST
 * 2. Validar requests (@Valid)
 * 3. Delegar lógica al Service
 * 4. Retornar respuestas con códigos HTTP correctos
 *
 * @RestController: Combina @Controller + @ResponseBody
 * @RequestMapping: Define la ruta base /api/pokemons
 * @RequiredArgsConstructor: Inyecta dependencias (PokemonService)
 */
@RestController
@RequestMapping("/api/pokemons")
@RequiredArgsConstructor
@Tag(name = "Pokemon", description = "API para gestionar Pokémon")
public class PokemonController {

    private final PokemonService pokemonService;

    /**
     * GET /api/pokemons
     * Obtiene todos los Pokémon.
     *
     * @return Lista de Pokémon (200 OK)
     */
    @GetMapping
    @Operation(summary = "Obtener todos los Pokémon", description = "Devuelve la lista de todos los Pokémon registrados")
    @ApiResponse(responseCode = "200", description = "Lista de Pokémon obtenida exitosamente", content = @Content(schema = @Schema(implementation = PokemonResponseDto.class)))
    public ResponseEntity<List<PokemonResponseDto>> getAllPokemon() {
        List<PokemonResponseDto> pokemons = pokemonService.getAllPokemon();
        return ResponseEntity.ok(pokemons);
    }

    /**
     * GET /api/pokemons/{id}
     * Obtiene un Pokémon por ID.
     *
     * @param id ID del Pokémon
     * @return Pokémon encontrado (200 OK) o 404 Not Found
     */
    @GetMapping("/{id}")
    @Operation(summary = "Obtener Pokémon por ID", description = "Devuelve un Pokémon específico mediante su ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Pokémon encontrado", content = @Content(schema = @Schema(implementation = PokemonResponseDto.class))),
            @ApiResponse(responseCode = "404", description = "Pokémon no encontrado")
    })
    public ResponseEntity<PokemonResponseDto> getPokemonById(
            @Parameter(description = "ID del Pokémon", required = true, example = "1") @PathVariable Long id) {
        PokemonResponseDto pokemon = pokemonService.getPokemonById(id);
        return ResponseEntity.ok(pokemon);
    }

    /**
     * POST /api/pokemons
     * Crea un nuevo Pokémon.
     *
     * @param createDto Datos del Pokémon a crear
     * @return Pokémon creado (201 Created)
     */
    @PostMapping
    @Operation(summary = "Crear nuevo Pokémon", description = "Crea un nuevo Pokémon con los datos proporcionados")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201", description = "Pokémon creado exitosamente", content = @Content(schema = @Schema(implementation = PokemonResponseDto.class))),
            @ApiResponse(responseCode = "400", description = "Datos inválidos o incompletos")
    })
    public ResponseEntity<PokemonResponseDto> createPokemon(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(description = "Datos del Pokémon a crear", required = true, content = @Content(schema = @Schema(implementation = CreatePokemonDto.class))) @Valid @RequestBody CreatePokemonDto createDto) {
        PokemonResponseDto created = pokemonService.createPokemon(createDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(created);
    }

    /**
     * PUT /api/pokemons/{id}
     * Actualiza un Pokémon existente.
     *
     * @param id        ID del Pokémon a actualizar
     * @param updateDto Datos a actualizar
     * @return Pokémon actualizado (200 OK) o 404 Not Found
     */
    @PutMapping("/{id}")
    @Operation(summary = "Actualizar Pokémon", description = "Actualiza un Pokémon existente con los nuevos datos")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200", description = "Pokémon actualizado exitosamente", content = @Content(schema = @Schema(implementation = PokemonResponseDto.class))),
            @ApiResponse(responseCode = "404", description = "Pokémon no encontrado"),
            @ApiResponse(responseCode = "400", description = "Datos inválidos")
    })
    public ResponseEntity<PokemonResponseDto> updatePokemon(
            @Parameter(description = "ID del Pokémon a actualizar", required = true, example = "1") @PathVariable Long id,
            @io.swagger.v3.oas.annotations.parameters.RequestBody(description = "Datos del Pokémon a actualizar", required = true, content = @Content(schema = @Schema(implementation = UpdatePokemonDto.class))) @Valid @RequestBody UpdatePokemonDto updateDto) {
        PokemonResponseDto updated = pokemonService.updatePokemon(id, updateDto);
        return ResponseEntity.ok(updated);
    }

    /**
     * DELETE /api/pokemons/{id}
     * Elimina un Pokémon por ID.
     *
     * @param id ID del Pokémon a eliminar
     * @return Sin contenido (204 No Content) o 404 Not Found
     */
    @DeleteMapping("/{id}")
    @Operation(summary = "Eliminar Pokémon", description = "Elimina un Pokémon existente por su ID")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204", description = "Pokémon eliminado exitosamente"),
            @ApiResponse(responseCode = "404", description = "Pokémon no encontrado")
    })
    public ResponseEntity<Void> deletePokemon(
            @Parameter(description = "ID del Pokémon a eliminar", required = true, example = "1") @PathVariable Long id) {
        pokemonService.deletePokemon(id);
        return ResponseEntity.noContent().build();
    }

}
