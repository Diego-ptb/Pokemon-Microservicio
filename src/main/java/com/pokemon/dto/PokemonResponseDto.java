package com.pokemon.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

/**
 * DTO de respuesta para Pokémon.
 *
 * Se usa en GET requests para devolver datos del Pokémon.
 * Incluye campos de auditoría (createdAt, updatedAt) porque el cliente
 * necesita saber cuándo se creó/actualizó el recurso.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class PokemonResponseDto {

    private Long id;

    private String name;

    private String type;

    private Integer level;

    private String description;

    private String imageUrl;

    private LocalDateTime createdAt;

    private LocalDateTime updatedAt;

}
