-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 09, 2025 at 11:16 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

USE mydb;
SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE `users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(100) NOT NULL UNIQUE,
  `password` varchar(512) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `highest_kill_game` INT DEFAULT 0,
  `last_inventory` JSON DEFAULT NULL,
  `last_position_x` FLOAT DEFAULT 0,
  `last_position_y` FLOAT DEFAULT 0,
  `total_kills` INT UNSIGNED NOT NULL DEFAULT 0,
  `total_playtime` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

INSERT INTO `users` (`id`, `user_name`, `password`, `created_at`, `updated_at`, `highest_kill_game`, `last_inventory`, `last_position_x`, `last_position_y`) VALUES
(1, 'testuser', '$2y$12$0hw8lbi3YEzPLAfzaNTCieZZ0azPqGWY4Z.stDx/F0pGcTXi9KIQi', '2025-02-09 09:47:58', '2025-02-09 09:47:58', 0, NULL, 0, 0);

COMMIT;