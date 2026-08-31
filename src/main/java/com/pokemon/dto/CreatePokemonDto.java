package com.pokemon.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * DTO para crear un nuevo Pokémon.
 *
 * Justificación de usar DTOs:
 * 1. Separación de responsabilidades: Entity es interna, DTO es la API pública
 * 2. Validación: Las validaciones se hacen en el DTO, no en la Entity
 * 3. Seguridad: No exponemos campos internos (id, timestamps, etc.)
 * 4. Flexibilidad: La API puede cambiar sin afectar la BD
 * 5. Serialización controlada: Decidimos qué campos serializar/deserializar
 * 6. Evitar ataques: No permitimos sobrescribir campos del sistema (id,
 * createdAt)
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreatePokemonDto {

    @NotBlank(message = "El nombre del Pokémon es obligatorio")
    private String name;

    @NotBlank(message = "El tipo del Pokémon es obligatorio")
    private String type;

    @NotNull(message = "El nivel es obligatorio")
    @Min(value = 1, message = "El nivel debe ser mayor que 0")
    private Integer level;

    private String description;

    private String imageUrl;

}
