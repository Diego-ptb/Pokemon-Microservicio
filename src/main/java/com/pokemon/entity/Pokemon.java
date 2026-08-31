package com.pokemon.entity;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Min;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

/**
 * Entity de Pokémon.
 * Representa un Pokémon en la base de datos.
 *
 * Justificación:
 * - @Entity: Indica que es una entidad JPA
 * - @Table: Mapea la tabla en PostgreSQL
 * - @CreationTimestamp y @UpdateTimestamp: Auditoría automática
 * - @Data (Lombok): Genera getter, setter, toString, equals, hashCode
 * - Validaciones: Se realizan en la capa de DTO, no aquí
 */
@Entity
@Table(name = "pokemon")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Pokemon {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank(message = "El nombre no puede estar vacío")
    @Column(nullable = false, length = 100)
    private String name;

    @NotBlank(message = "El tipo no puede estar vacío")
    @Column(nullable = false, length = 50)
    private String type;

    @NotNull(message = "El nivel es obligatorio")
    @Min(value = 1, message = "El nivel debe ser mayor que 0")
    @Column(nullable = false)
    private Integer level;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "image_url", length = 500)
    private String imageUrl;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

}
