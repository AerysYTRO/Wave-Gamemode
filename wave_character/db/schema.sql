-- wave_character/db/schema.sql
-- SQL schema for storing player characters

CREATE TABLE IF NOT EXISTS `player_characters` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `player_serial` VARCHAR(255) NOT NULL,
  `char_index` INT NOT NULL DEFAULT 1,
  `name` VARCHAR(100) NOT NULL,
  `age` VARCHAR(10) DEFAULT NULL,
  `race` VARCHAR(32) DEFAULT NULL,
  `gender` VARCHAR(32) DEFAULT NULL,
  `story` TEXT,
  `weight` VARCHAR(10) DEFAULT NULL,
  `height` VARCHAR(10) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX (`player_serial`),
  UNIQUE KEY `ux_player_char_index` (`player_serial`, `char_index`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Example queries
-- Insert a character (char_index should be 1..5)
-- INSERT INTO player_characters (player_serial, char_index, name, age, race, gender, story, weight, height) VALUES ('SERIAL123', 1, 'Ion Popescu', '24', 'Alb', 'Barbat', 'Povestea mea', '80', '180');

-- Select characters for a player
-- SELECT * FROM player_characters WHERE player_serial = 'SERIAL123' ORDER BY char_index ASC;

-- Delete all characters for a player (used by server save logic before reinserting)
-- DELETE FROM player_characters WHERE player_serial = 'SERIAL123';
