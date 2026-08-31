-- ============================================
-- Schema SQL para Pokemon Service
-- ============================================
-- Ejecutar este script en Supabase (SQL Editor)
-- para crear la tabla pokemon
-- ============================================

-- Crear tabla pokemon
CREATE TABLE IF NOT EXISTS pokemon (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(50) NOT NULL,
    level INTEGER NOT NULL CHECK (level > 0),
    description TEXT,
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Crear índices para mejorar performance
CREATE INDEX IF NOT EXISTS idx_pokemon_name ON pokemon(name);
CREATE INDEX IF NOT EXISTS idx_pokemon_type ON pokemon(type);
CREATE INDEX IF NOT EXISTS idx_pokemon_level ON pokemon(level);

-- Crear trigger para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_pokemon_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS pokemon_updated_at_trigger ON pokemon;

CREATE TRIGGER pokemon_updated_at_trigger
BEFORE UPDATE ON pokemon
FOR EACH ROW
EXECUTE FUNCTION update_pokemon_updated_at();

-- Comentarios de tabla para documentación
COMMENT ON TABLE pokemon IS 'Tabla que almacena información de Pokémon';
COMMENT ON COLUMN pokemon.id IS 'ID único del Pokémon (auto-generado)';
COMMENT ON COLUMN pokemon.name IS 'Nombre del Pokémon';
COMMENT ON COLUMN pokemon.type IS 'Tipo del Pokémon (ej: Fire, Water, Electric)';
COMMENT ON COLUMN pokemon.level IS 'Nivel del Pokémon (debe ser > 0)';
COMMENT ON COLUMN pokemon.description IS 'Descripción opcional del Pokémon';
COMMENT ON COLUMN pokemon.image_url IS 'URL de la imagen del Pokémon';
COMMENT ON COLUMN pokemon.created_at IS 'Fecha/hora de creación del registro';
COMMENT ON COLUMN pokemon.updated_at IS 'Fecha/hora de la última actualización';

-- ============================================
-- Datos iniciales de Pokémon
-- ============================================
-- Importante: el esquema real tiene columnas:
-- id, name, type, level, description, image_url, created_at, updated_at
-- Por eso el insert incluye fechas para evitar nulls en columnas NOT NULL.

TRUNCATE TABLE pokemon;

INSERT INTO pokemon (
    id, name, type, level, description, image_url, created_at, updated_at
)
VALUES
    (1, 'Bulbasaur', 'Planta/Veneno', 1, 'Nace con una semilla en el lomo que crece junto con él.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/1.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (2, 'Ivysaur', 'Planta/Veneno', 2, 'Cuando el bulbo de su lomo florece, desprende un aroma agradable.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/2.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (3, 'Venusaur', 'Planta/Veneno', 3, 'La flor de su lomo absorbe energía solar para aumentar su fuerza.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/3.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (4, 'Charmander', 'Fuego', 4, 'La llama de su cola indica su estado vital y emocional.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/4.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (5, 'Charmeleon', 'Fuego', 5, 'Su carácter feroz lo lleva a luchar constantemente contra rivales poderosos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/5.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (6, 'Charizard', 'Fuego/Volador', 6, 'Puede volar y lanzar potentes llamas capaces de derretir grandes rocas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/6.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (7, 'Squirtle', 'Agua', 7, 'Se protege de los ataques ocultándose dentro de su caparazón.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/7.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (8, 'Wartortle', 'Agua', 8, 'Su cola está cubierta de pelo y es un símbolo de longevidad.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/8.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (9, 'Blastoise', 'Agua', 9, 'Dispara potentes chorros de agua desde los cañones de su caparazón.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/9.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (10, 'Caterpie', 'Bicho', 10, 'Tiene un apetito enorme y puede devorar hojas más grandes que él.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/10.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (11, 'Metapod', 'Bicho', 11, 'Su dura coraza lo protege mientras su cuerpo evoluciona.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/11.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (12, 'Butterfree', 'Bicho/Volador', 12, 'Sus alas liberan escamas que pueden causar diferentes efectos en sus enemigos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/12.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (13, 'Weedle', 'Bicho/Veneno', 13, 'Posee un pequeño aguijón venenoso en la cabeza.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/13.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (14, 'Kakuna', 'Bicho/Veneno', 14, 'Permanece prácticamente inmóvil mientras se prepara para evolucionar.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/14.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (15, 'Beedrill', 'Bicho/Veneno', 15, 'Vive en enjambres y ataca utilizando sus grandes aguijones.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/15.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (16, 'Pidgey', 'Normal/Volador', 16, 'Tiene un excelente sentido de la orientación y rara vez se pierde.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/16.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (17, 'Pidgeotto', 'Normal/Volador', 17, 'Posee unas garras muy desarrolladas que utiliza para atrapar presas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/17.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (18, 'Pidgeot', 'Normal/Volador', 18, 'Puede alcanzar velocidades enormes mientras vuela.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/18.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (19, 'Rattata', 'Normal', 19, 'Sus grandes incisivos crecen continuamente y necesita roer constantemente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/19.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (20, 'Raticate', 'Normal', 20, 'Sus dientes son extremadamente fuertes y pueden atravesar materiales resistentes.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/20.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (21, 'Spearow', 'Normal/Volador', 21, 'Es agresivo y puede atacar a enemigos mucho más grandes que él.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/21.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (22, 'Fearow', 'Normal/Volador', 22, 'Sus largas alas le permiten volar durante largos periodos sin descansar.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/22.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (23, 'Ekans', 'Veneno', 23, 'Se desplaza silenciosamente por la hierba y utiliza su cuerpo para atrapar presas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/23.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (24, 'Arbok', 'Veneno', 24, 'El dibujo de su capucha puede intimidar a sus enemigos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/24.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (25, 'Pikachu', 'Eléctrico', 25, 'Almacena electricidad en sus mejillas y puede liberarla mediante potentes descargas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/25.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (26, 'Raichu', 'Eléctrico', 26, 'Puede almacenar grandes cantidades de electricidad y descargarla a través de su cola.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/26.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (27, 'Sandshrew', 'Tierra', 27, 'Puede enrollarse formando una bola para protegerse de los ataques.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/27.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (28, 'Sandslash', 'Tierra', 28, 'Sus garras y púas le permiten defenderse y excavar rápidamente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/28.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (29, 'Nidoran♀', 'Veneno', 29, 'Las hembras poseen pequeños cuernos y pueden liberar sustancias venenosas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/29.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (30, 'Nidorina', 'Veneno', 30, 'Es más tranquila que los machos y utiliza sustancias venenosas para defenderse.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/30.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (31, 'Nidoqueen', 'Veneno/Tierra', 31, 'Su cuerpo está cubierto por una piel resistente que la protege de los ataques.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/31.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (32, 'Nidoran♂', 'Veneno', 32, 'Sus grandes orejas pueden detectar sonidos a gran distancia.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/32.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (33, 'Nidorino', 'Veneno', 33, 'Su cuerno venenoso es extremadamente peligroso.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/33.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (34, 'Nidoking', 'Veneno/Tierra', 34, 'Utiliza su poderoso cuerno y su enorme fuerza para derrotar a sus enemigos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/34.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (35, 'Clefairy', 'Hada', 35, 'Se dice que aparece durante las noches de luna llena y que baila en grupo.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/35.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (36, 'Clefable', 'Hada', 36, 'Es muy tímido y suele vivir lejos de los humanos en lugares tranquilos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/36.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (37, 'Vulpix', 'Fuego', 37, 'Nace con una sola cola que se divide en varias a medida que crece.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/37.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (38, 'Ninetales', 'Fuego', 38, 'Se dice que puede vivir miles de años y posee poderes misteriosos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/38.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (39, 'Jigglypuff', 'Normal/Hada', 39, 'Su canto provoca sueño en quienes lo escuchan.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/39.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (40, 'Wigglytuff', 'Normal/Hada', 40, 'Su cuerpo es extremadamente flexible y puede inflarse considerablemente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/40.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (41, 'Zubat', 'Veneno/Volador', 41, 'Utiliza ondas ultrasónicas para orientarse en lugares oscuros.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/41.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (42, 'Golbat', 'Veneno/Volador', 42, 'Bebe grandes cantidades de sangre utilizando sus afilados colmillos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/42.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (43, 'Oddish', 'Planta/Veneno', 43, 'Durante la noche se desplaza para plantar sus semillas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/43.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (44, 'Gloom', 'Planta/Veneno', 44, 'Su cuerpo desprende un olor extremadamente desagradable.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/44.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (45, 'Vileplume', 'Planta/Veneno', 45, 'Sus grandes pétalos liberan polen venenoso.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/45.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (46, 'Paras', 'Bicho/Planta', 46, 'Los hongos de su espalda crecen alimentándose de sus nutrientes.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/46.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (47, 'Parasect', 'Bicho/Planta', 47, 'El hongo controla gran parte del cuerpo del Pokémon.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/47.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (48, 'Venonat', 'Bicho/Veneno', 48, 'Sus grandes ojos funcionan como sensores que detectan pequeños movimientos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/48.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (49, 'Venomoth', 'Bicho/Veneno', 49, 'Sus alas liberan un polvo venenoso durante el vuelo.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/49.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (50, 'Diglett', 'Tierra', 50, 'Vive bajo tierra y excava túneles a gran velocidad.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/50.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (51, 'Dugtrio', 'Tierra', 51, 'Tres Diglett unidos trabajan juntos para excavar enormes túneles.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/51.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (52, 'Meowth', 'Normal', 52, 'Le atraen los objetos brillantes y suele recoger monedas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/52.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (53, 'Persian', 'Normal', 53, 'Es elegante pero agresivo y posee garras extremadamente afiladas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/53.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (54, 'Psyduck', 'Agua', 54, 'Sufre constantemente dolores de cabeza que pueden liberar poderes psíquicos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/54.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (55, 'Golduck', 'Agua', 55, 'Es un nadador excelente y puede moverse rápidamente por el agua.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/55.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (56, 'Mankey', 'Lucha', 56, 'Es muy temperamental y puede enfadarse fácilmente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/56.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (57, 'Primeape', 'Lucha', 57, 'Se enfurece con facilidad y persigue a cualquiera que lo provoque.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/57.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (58, 'Growlithe', 'Fuego', 58, 'Es leal y valiente, y puede aprender rápidamente a obedecer a su entrenador.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/58.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (59, 'Arcanine', 'Fuego', 59, 'Es conocido por su velocidad y majestuosidad y aparece en antiguas leyendas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/59.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (60, 'Poliwag', 'Agua', 60, 'Su piel es húmeda y transparente, permitiendo ver sus órganos internos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/60.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (61, 'Poliwhirl', 'Agua', 61, 'Su espiral abdominal puede hipnotizar a quienes la observan fijamente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/61.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (62, 'Poliwrath', 'Agua/Lucha', 62, 'Posee una gran resistencia y puede nadar largas distancias.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/62.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (63, 'Abra', 'Psíquico', 63, 'Utiliza la teletransportación para escapar de situaciones peligrosas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/63.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (64, 'Kadabra', 'Psíquico', 64, 'Posee grandes poderes psíquicos que pueden alterar objetos y personas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/64.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (65, 'Alakazam', 'Psíquico', 65, 'Su enorme inteligencia le permite recordar prácticamente todo lo que aprende.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/65.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (66, 'Machop', 'Lucha', 66, 'Entrena constantemente para aumentar su fuerza física.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/66.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (67, 'Machoke', 'Lucha', 67, 'Su musculoso cuerpo le proporciona una fuerza extraordinaria.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/67.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (68, 'Machamp', 'Lucha', 68, 'Sus cuatro brazos le permiten lanzar numerosos golpes simultáneamente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/68.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (69, 'Bellsprout', 'Planta/Veneno', 69, 'Tiene un cuerpo flexible y puede atrapar presas con sus lianas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/69.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (70, 'Weepinbell', 'Planta/Veneno', 70, 'Utiliza líquidos corrosivos para digerir a sus presas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/70.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (71, 'Victreebel', 'Planta/Veneno', 71, 'Atrae a sus presas utilizando un dulce aroma antes de devorarlas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/71.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (72, 'Tentacool', 'Agua/Veneno', 72, 'Flota en el océano y utiliza sus tentáculos para defenderse.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/72.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (73, 'Tentacruel', 'Agua/Veneno', 73, 'Puede extender sus numerosos tentáculos para atrapar enemigos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/73.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (74, 'Geodude', 'Roca/Tierra', 74, 'Su cuerpo rocoso le permite vivir en montañas y lugares pedregosos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/74.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (75, 'Graveler', 'Roca/Tierra', 75, 'Suele rodar por las laderas de las montañas para desplazarse.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/75.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (76, 'Golem', 'Roca/Tierra', 76, 'Su cuerpo rocoso es extremadamente resistente y puede soportar explosiones.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/76.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (77, 'Ponyta', 'Fuego', 77, 'Sus patas son extremadamente fuertes y puede saltar obstáculos enormes.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/77.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (78, 'Rapidash', 'Fuego', 78, 'Corre a gran velocidad dejando llamas a su paso.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/78.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (79, 'Slowpoke', 'Agua/Psíquico', 79, 'Es muy lento y tranquilo, y suele quedarse inmóvil durante mucho tiempo.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/79.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (80, 'Slowbro', 'Agua/Psíquico', 80, 'El Shellder de su cola provoca cambios en su comportamiento.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/80.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (81, 'Magnemite', 'Eléctrico/Acero', 81, 'Flota utilizando fuerzas magnéticas y absorbe electricidad.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/81.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (82, 'Magneton', 'Eléctrico/Acero', 82, 'Tres Magnemite unidos generan un poderoso campo magnético.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/82.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (83, 'Farfetch''d', 'Normal/Volador', 83, 'Siempre lleva consigo un tallo de puerro que utiliza como arma.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/83.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (84, 'Doduo', 'Normal/Volador', 84, 'Sus dos cabezas pueden actuar de manera independiente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/84.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (85, 'Dodrio', 'Normal/Volador', 85, 'Sus tres cabezas pueden correr y pensar de forma independiente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/85.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (86, 'Seel', 'Agua', 86, 'Le gusta nadar en aguas frías y está protegido por una gruesa capa de grasa.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/86.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (87, 'Dewgong', 'Agua/Hielo', 87, 'Su cuerpo blanco le permite camuflarse entre el hielo.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/87.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (88, 'Grimer', 'Veneno', 88, 'Está formado por residuos tóxicos y puede contaminar el suelo que pisa.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/88.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (89, 'Muk', 'Veneno', 89, 'Su cuerpo está compuesto por sustancias tóxicas y desprende un olor desagradable.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/89.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (90, 'Shellder', 'Agua', 90, 'Su duro caparazón lo protege de los ataques externos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/90.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (91, 'Cloyster', 'Agua/Hielo', 91, 'Su caparazón es extremadamente resistente y sus púas pueden dispararse.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/91.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (92, 'Gastly', 'Fantasma/Veneno', 92, 'Está compuesto principalmente de gas y puede atravesar paredes.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/92.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (93, 'Haunter', 'Fantasma/Veneno', 93, 'Se esconde en lugares oscuros y puede lamer a sus víctimas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/93.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (94, 'Gengar', 'Fantasma/Veneno', 94, 'Se oculta en las sombras y puede hacerse prácticamente invisible.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/94.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (95, 'Onix', 'Roca/Tierra', 95, 'Excava túneles bajo tierra y su cuerpo rocoso crece continuamente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/95.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (96, 'Drowzee', 'Psíquico', 96, 'Se alimenta de los sueños de las personas y puede provocar somnolencia.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/96.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (97, 'Hypno', 'Psíquico', 97, 'Utiliza un péndulo para hipnotizar a sus víctimas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/97.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (98, 'Krabby', 'Agua', 98, 'Sus grandes pinzas pueden cortar objetos duros.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/98.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (99, 'Kingler', 'Agua', 99, 'Una de sus pinzas es enorme y posee una fuerza extraordinaria.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/99.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (100, 'Voltorb', 'Eléctrico', 100, 'Se parece a una Poké Ball y puede explotar repentinamente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/100.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (101, 'Electrode', 'Eléctrico', 101, 'Absorbe electricidad y puede explotar al acumular demasiada energía.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/101.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (102, 'Exeggcute', 'Planta/Psíquico', 102, 'Está formado por seis semillas que actúan como un solo Pokémon.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/102.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (103, 'Exeggutor', 'Planta/Psíquico', 103, 'Sus tres cabezas pueden pensar de manera independiente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/103.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (104, 'Cubone', 'Tierra', 104, 'Lleva sobre su cabeza el cráneo de su madre fallecida.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/104.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (105, 'Marowak', 'Tierra', 105, 'Utiliza un hueso como arma y ha desarrollado una gran habilidad para manejarlo.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/105.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (106, 'Hitmonlee', 'Lucha', 106, 'Sus piernas pueden estirarse y utiliza potentes patadas para combatir.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/106.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (107, 'Hitmonchan', 'Lucha', 107, 'Sus puños pueden moverse a una velocidad increíble durante los combates.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/107.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (108, 'Lickitung', 'Normal', 108, 'Su lengua es extremadamente larga y la utiliza para explorar y atacar.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/108.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (109, 'Koffing', 'Veneno', 109, 'Flota en el aire y libera gases tóxicos desde su cuerpo.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/109.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (110, 'Weezing', 'Veneno', 110, 'Dos Koffing unidos producen grandes cantidades de gases venenosos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/110.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (111, 'Rhyhorn', 'Tierra/Roca', 111, 'Su cuerpo es muy resistente y puede atravesar obstáculos con sus embestidas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/111.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (112, 'Rhydon', 'Tierra/Roca', 112, 'Su piel es resistente y puede soportar temperaturas extremas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/112.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (113, 'Chansey', 'Normal', 113, 'Es muy amable y lleva huevos nutritivos que comparte con Pokémon heridos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/113.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (114, 'Tangela', 'Planta', 114, 'Su cuerpo está cubierto por enredaderas azules que crecen continuamente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/114.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (115, 'Kangaskhan', 'Normal', 115, 'Protege con gran dedicación a su cría, que vive en su bolsa.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/115.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (116, 'Horsea', 'Agua', 116, 'Utiliza tinta para defenderse y puede nadar moviendo rápidamente sus aletas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/116.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (117, 'Seadra', 'Agua', 117, 'Sus púas contienen veneno y puede crear remolinos mientras nada.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/117.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (118, 'Goldeen', 'Agua', 118, 'Su elegante aleta dorsal le permite nadar con gran velocidad.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/118.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (119, 'Seaking', 'Agua', 119, 'Utiliza su poderoso cuerno para luchar y excavar.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/119.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (120, 'Staryu', 'Agua', 120, 'La joya central de su cuerpo brilla intensamente durante la noche.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/120.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (121, 'Starmie', 'Agua/Psíquico', 121, 'Su núcleo central emite un misterioso brillo de color.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/121.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (122, 'Mr. Mime', 'Psíquico/Hada', 122, 'Puede crear barreras invisibles utilizando movimientos de mimo.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/122.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (123, 'Scyther', 'Bicho/Volador', 123, 'Sus afiladas guadañas le permiten cortar árboles con facilidad.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/123.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (124, 'Jynx', 'Hielo/Psíquico', 124, 'Se comunica mediante movimientos y un lenguaje propio.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/124.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (125, 'Electabuzz', 'Eléctrico', 125, 'Absorbe electricidad de las tormentas y puede generar grandes descargas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/125.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (126, 'Magmar', 'Fuego', 126, 'Su cuerpo desprende un calor intenso y puede lanzar llamas desde su cuerpo.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/126.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (127, 'Pinsir', 'Bicho', 127, 'Utiliza sus enormes pinzas para agarrar y lanzar a sus enemigos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/127.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (128, 'Tauros', 'Normal', 128, 'Es extremadamente agresivo y suele cargar contra sus enemigos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/128.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (129, 'Magikarp', 'Agua', 129, 'Es conocido por su escasa fuerza, aunque puede sobrevivir en aguas muy contaminadas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/129.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (130, 'Gyarados', 'Agua/Volador', 130, 'Su naturaleza cambia drásticamente al evolucionar y se vuelve extremadamente agresivo.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/130.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (131, 'Lapras', 'Agua/Hielo', 131, 'Es amable y permite que las personas viajen sobre su espalda.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/131.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (132, 'Ditto', 'Normal', 132, 'Puede transformarse en cualquier Pokémon que observe.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/132.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (133, 'Eevee', 'Normal', 133, 'Su estructura genética inestable le permite evolucionar de diferentes maneras.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/133.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (134, 'Vaporeon', 'Agua', 134, 'Su cuerpo se adapta al agua y puede disolverse parcialmente en ella.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/134.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (135, 'Jolteon', 'Eléctrico', 135, 'Acumula electricidad en su cuerpo y puede crear potentes descargas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/135.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (136, 'Flareon', 'Fuego', 136, 'Almacena aire caliente en su cuerpo y puede expulsarlo como llamas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/136.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (137, 'Porygon', 'Normal', 137, 'Fue creado artificialmente mediante tecnología informática avanzada.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/137.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (138, 'Omanyte', 'Roca/Agua', 138, 'Es un Pokémon prehistórico que vivía en antiguos océanos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/138.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (139, 'Omastar', 'Roca/Agua', 139, 'Sus tentáculos y afilados colmillos le permiten atrapar presas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/139.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (140, 'Kabuto', 'Roca/Agua', 140, 'Es un Pokémon prehistórico que permaneció prácticamente sin cambios durante millones de años.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/140.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (141, 'Kabutops', 'Roca/Agua', 141, 'Sus afiladas extremidades le permiten cortar a sus presas rápidamente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/141.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (142, 'Aerodactyl', 'Roca/Volador', 142, 'Es un Pokémon prehistórico feroz que dominaba los cielos antiguos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/142.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (143, 'Snorlax', 'Normal', 143, 'Pasa gran parte del día durmiendo y puede comer enormes cantidades de comida.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/143.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (144, 'Articuno', 'Hielo/Volador', 144, 'Es un Pokémon legendario asociado con el hielo y las bajas temperaturas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/144.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (145, 'Zapdos', 'Eléctrico/Volador', 145, 'Es un Pokémon legendario que aparece durante las tormentas eléctricas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/145.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (146, 'Moltres', 'Fuego/Volador', 146, 'Es un Pokémon legendario relacionado con el fuego y las llamas.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/146.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (147, 'Dratini', 'Dragón', 147, 'Es un Pokémon serpentino que vive en aguas tranquilas y evoluciona lentamente.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/147.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (148, 'Dragonair', 'Dragón', 148, 'Su cuerpo elegante y sus cristales pueden emitir una misteriosa energía.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/148.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (149, 'Dragonite', 'Dragón/Volador', 149, 'Es muy inteligente, amable y capaz de volar a grandes velocidades.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/149.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (150, 'Mewtwo', 'Psíquico', 150, 'Fue creado mediante experimentos genéticos y posee enormes poderes psíquicos.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/150.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (151, 'Mew', 'Psíquico', 151, 'Es extremadamente raro y posee el material genético de todos los Pokémon.', 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/151.png', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;