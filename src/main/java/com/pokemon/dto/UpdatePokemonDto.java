package com.pokemon.dto;

import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para actualizar un Pokémon existente.
 *
 * Todos los campos son opcionales (@NotNull no se usa) porque permite
 * actualizaciones parciales (PATCH). Si queremos requerir todos los campos,
 * deberíamos usar @NotNull en todos.
 *
 * Para este ejemplo, permitimos actualizar cualquier campo individualmente.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class UpdatePokemonDto {

    private String name;

    private String type;

    @Min(value = 1, message = "El nivel debe ser mayor que 0")
    private Integer level;

    private String description;

    private String imageUrl;

}
