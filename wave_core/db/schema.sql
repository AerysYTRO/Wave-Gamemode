-- Wave Romania Roleplay - Database Schema
-- MariaDB/MySQL Schema for Player Management System

-- =====================================================
-- Players Table (UPDATED - Added bank_money and cash_money for HUD)
-- =====================================================
CREATE TABLE IF NOT EXISTS `players` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(64) UNIQUE NOT NULL,
    `password_hash` VARCHAR(255) NOT NULL,
    `last_ip` VARCHAR(45),
    `last_login` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `is_banned` BOOLEAN DEFAULT FALSE,
    `ban_reason` TEXT,
    `ban_until` DATETIME,
    `bank_money` INT DEFAULT 0,
    `cash_money` INT DEFAULT 0,
    UNIQUE KEY `username_idx` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Player Groups Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `player_groups` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT NOT NULL,
    `group_name` VARCHAR(64) NOT NULL,
    `assigned_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `player_group_idx` (`player_id`, `group_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Player Permissions Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `player_permissions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT NOT NULL,
    `permission` VARCHAR(128) NOT NULL,
    `assigned_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `player_perm_idx` (`player_id`, `permission`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Player Priority Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `player_priority` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT UNIQUE NOT NULL,
    `priority_level` INT DEFAULT 1,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Factions Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `factions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(128) UNIQUE NOT NULL,
    `faction_id` INT UNIQUE NOT NULL,
    `leader_id` INT,
    `description` TEXT,
    `max_members` INT DEFAULT 50,
    `founded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `color` VARCHAR(7),
    FOREIGN KEY (`leader_id`) REFERENCES `players`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Faction Members Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `faction_members` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `faction_id` INT NOT NULL,
    `player_id` INT NOT NULL,
    `rank` VARCHAR(64) DEFAULT 'Member',
    `joined_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`faction_id`) REFERENCES `factions`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `faction_player_idx` (`faction_id`, `player_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Faction Permissions Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `faction_permissions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `faction_id` INT NOT NULL,
    `permission` VARCHAR(128) NOT NULL,
    `assigned_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`faction_id`) REFERENCES `factions`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `faction_perm_idx` (`faction_id`, `permission`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- VIP Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `player_vip` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT UNIQUE NOT NULL,
    `is_vip` BOOLEAN DEFAULT FALSE,
    `vip_expire_date` DATETIME,
    `vip_level` INT DEFAULT 1,
    `granted_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Donator Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `player_donator` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT UNIQUE NOT NULL,
    `is_donator` BOOLEAN DEFAULT FALSE,
    `donator_tier` VARCHAR(64),
    `total_donated` FLOAT DEFAULT 0,
    `donated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_reward_claimed` DATETIME,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Logs Table (for command history, admin actions, etc)
-- =====================================================
CREATE TABLE IF NOT EXISTS `logs` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT,
    `action` VARCHAR(128) NOT NULL,
    `details` TEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `player_idx` (`player_id`),
    INDEX `action_idx` (`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Warnings/Infractions Table
-- =====================================================
CREATE TABLE IF NOT EXISTS `player_warnings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `player_id` INT NOT NULL,
    `warned_by_id` INT,
    `reason` VARCHAR(255),
    `warn_count` INT DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`player_id`) REFERENCES `players`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`warned_by_id`) REFERENCES `players`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Create Indexes for Performance
-- =====================================================
CREATE INDEX `idx_players_created_at` ON `players`(`created_at`);
CREATE INDEX `idx_players_last_login` ON `players`(`last_login`);
CREATE INDEX `idx_faction_members_faction` ON `faction_members`(`faction_id`);
CREATE INDEX `idx_faction_members_player` ON `faction_members`(`player_id`);
CREATE INDEX `idx_player_groups_player` ON `player_groups`(`player_id`);
CREATE INDEX `idx_player_vip` ON `player_vip`(`is_vip`);
CREATE INDEX `idx_player_donator` ON `player_donator`(`is_donator`);
