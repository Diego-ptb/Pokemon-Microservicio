package com.pokemon.repository;

import com.pokemon.entity.Pokemon;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Repositorio para la entidad Pokemon.
 *
 * JpaRepository proporciona métodos CRUD automáticamente:
 * - save()
 * - findById()
 * - findAll()
 * - delete()
 * - deleteById()
 * - etc.
 */
@Repository
public interface PokemonRepository extends JpaRepository<Pokemon, Long> {

    Optional<Pokemon> findByNameIgnoreCase(String name);
}
