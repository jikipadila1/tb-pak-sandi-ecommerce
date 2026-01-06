-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 06, 2026 at 01:05 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tbecommerce_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `carts`
--

CREATE TABLE `carts` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) UNSIGNED NOT NULL,
  `product_id` int(11) UNSIGNED NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `carts`
--

INSERT INTO `carts` (`id`, `user_id`, `product_id`, `quantity`, `created_at`, `updated_at`) VALUES
(12, 22, 2, 1, '2025-12-21 15:49:38', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`id`, `name`, `slug`, `description`, `image`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'Electronics', 'electronics', 'Electronic devices and gadgets', NULL, 1, '2025-12-01 06:30:26', '2025-12-01 06:30:26'),
(2, 'Fashion', 'fashion', 'Clothing and accessories', NULL, 1, '2025-12-01 06:30:26', '2025-12-01 06:30:26'),
(3, 'Books', 'books', 'Books and magazines', NULL, 1, '2025-12-01 06:30:26', '2025-12-01 06:30:26'),
(4, 'Sports', 'sports', 'Sports equipment and accessories', NULL, 1, '2025-12-01 06:30:26', '2025-12-01 06:30:26');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `version` varchar(255) NOT NULL,
  `class` varchar(255) NOT NULL,
  `group` varchar(255) NOT NULL,
  `namespace` varchar(255) NOT NULL,
  `time` int(11) NOT NULL,
  `batch` int(11) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `version`, `class`, `group`, `namespace`, `time`, `batch`) VALUES
(1, '2024-01-01-000001', 'App\\Database\\Migrations\\CreateUsersTable', 'default', 'App', 1764570612, 1),
(2, '2024-01-01-000002', 'App\\Database\\Migrations\\CreateCategoriesTable', 'default', 'App', 1764570612, 1),
(3, '2024-01-01-000003', 'App\\Database\\Migrations\\CreateProductsTable', 'default', 'App', 1764570612, 1),
(4, '2024-01-01-000004', 'App\\Database\\Migrations\\CreateCartsTable', 'default', 'App', 1764570612, 1),
(5, '2024-01-01-000005', 'App\\Database\\Migrations\\CreateOrdersTable', 'default', 'App', 1764570612, 1),
(6, '2024-01-01-000006', 'App\\Database\\Migrations\\CreateOrderItemsTable', 'default', 'App', 1764570612, 1),
(7, '2024-01-01-000007', 'App\\Database\\Migrations\\CreatePaymentsTable', 'default', 'App', 1764570612, 1);

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) UNSIGNED NOT NULL,
  `order_number` varchar(50) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `status` enum('pending','processing','shipped','delivered','cancelled') NOT NULL DEFAULT 'pending',
  `shipping_address` text NOT NULL,
  `shipping_phone` varchar(20) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `order_number`, `total_amount`, `status`, `shipping_address`, `shipping_phone`, `notes`, `created_at`, `updated_at`) VALUES
(7, 22, 'ORD-20251220-42FEB8', 5999000.00, 'cancelled', 'jl .benhil tanah abang, jakarta 10210', '+6285880491365', 'jangan pecah', '2025-12-20 04:06:44', '2025-12-21 15:52:12'),
(8, 29, 'ORD-20251221-32D92B', 31998000.00, 'pending', 'jl .benhil tanah abang, jakarta 10210', '+6285880491365', '', '2025-12-21 16:40:19', '2025-12-21 16:40:19'),
(9, 29, 'ORD-20251221-F6BD0C', 198000.00, 'pending', 'jl .benhil tanah abang, jakarta 10210', '+6285880491365', '', '2025-12-21 16:49:35', '2025-12-21 16:49:35'),
(10, 29, 'ORD-20251221-D47EAD', 15999000.00, 'cancelled', 'jl .benhil tanah abang, jakarta 10210', '+6285880491365', '', '2025-12-21 16:56:45', '2025-12-21 17:08:18'),
(11, 29, 'ORD-20251221-68A483', 5999000.00, 'pending', 'jl .benhil tanah abang, jakarta 10210', '+6285880491365', '', '2025-12-21 17:08:38', '2025-12-21 17:08:38'),
(12, 29, 'ORD-20251221-0DA324', 15999000.00, 'pending', 'jl .benhil tanah abang, jakarta 10210', '+6285880491365', '', '2025-12-21 17:15:44', '2025-12-21 17:15:44');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) UNSIGNED NOT NULL,
  `order_id` int(11) UNSIGNED NOT NULL,
  `product_id` int(11) UNSIGNED NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `quantity` int(11) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `product_name`, `price`, `quantity`, `subtotal`, `created_at`, `updated_at`) VALUES
(8, 7, 1, '', 5999000.00, 1, 5999000.00, NULL, NULL),
(9, 8, 2, '', 15999000.00, 2, 31998000.00, NULL, NULL),
(10, 9, 4, '', 99000.00, 2, 198000.00, NULL, NULL),
(11, 10, 2, '', 15999000.00, 1, 15999000.00, NULL, NULL),
(12, 11, 1, '', 5999000.00, 1, 5999000.00, NULL, NULL),
(13, 12, 2, '', 15999000.00, 1, 15999000.00, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(11) UNSIGNED NOT NULL,
  `order_id` int(11) UNSIGNED NOT NULL,
  `payment_method` enum('bank_transfer','credit_card','e-wallet','cod') NOT NULL DEFAULT 'bank_transfer',
  `payment_status` enum('pending','paid','failed') NOT NULL DEFAULT 'pending',
  `amount` decimal(10,2) NOT NULL,
  `payment_proof` varchar(255) DEFAULT NULL,
  `paid_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) UNSIGNED NOT NULL,
  `category_id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `image` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `category_id`, `name`, `slug`, `description`, `price`, `stock`, `image`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 1, 'Smartphone X Pro', 'smartphone-x-pro', 'Latest smartphone with advanced features', 5999000.00, 46, 'https://tse3.mm.bing.net/th/id/OIP.h_EmyhbIZgjpWRBExtpyYQHaGS?rs=1&pid=ImgDetMain&o=7&rm=3', 1, '2025-12-01 06:30:26', '2025-12-21 17:08:38'),
(2, 1, 'Laptop Gaming Pro', 'laptop-gaming-pro', 'High-performance gaming laptop', 15999000.00, 14, 'https://pisces.bbystatic.com/image2/BestBuy_US/images/products/6413/6413248cv1d.jpg', 1, '2025-12-01 06:30:26', '2025-12-21 17:15:44'),
(3, 1, 'Wireless Earbuds', 'wireless-earbuds', 'suara jernih', 1299000.00, 98, 'https://m.media-amazon.com/images/I/71qvQhK3OhL.jpg', 1, '2025-12-01 06:30:26', '2025-12-03 16:45:53'),
(4, 2, 'Classic T-Shirt', 'classic-t-shirt', 'Comfortable cotton t-shirt', 99000.00, 198, 'https://via.placeholder.com/400x300/764ba2/ffffff?text=Classic+T-Shirt', 1, '2025-12-01 06:30:26', '2025-12-21 16:49:35'),
(5, 2, 'Denim Jeans', 'denim-jeans', 'Premium quality denim jeans', 299000.00, 150, 'denim-jeans.jpg', 1, '2025-12-01 06:30:26', '2025-12-01 06:30:26'),
(6, 2, 'Sneakers Sport', 'sneakers-sport', 'Comfortable sports sneakers', 599000.00, 80, 'product-placeholder.jpg', 1, '2025-12-01 06:30:26', '2025-12-01 06:30:26'),
(7, 3, 'Programming Guide', 'programming-guide', 'Complete guide to modern programming', 150000.00, 50, 'product-placeholder.jpg', 1, '2025-12-01 06:30:26', '2025-12-01 06:30:26'),
(8, 3, 'Business Strategy Book', 'business-strategy-book', 'Learn business strategies from experts', 120000.00, 75, 'product-placeholder.jpg', 1, '2025-12-01 06:30:26', '2025-12-01 06:30:26'),
(9, 4, 'Yoga Mat', 'yoga-mat', 'Premium quality yoga mat', 199000.00, 100, 'product-placeholder.jpg', 1, '2025-12-01 06:30:26', '2025-12-01 06:30:26'),
(10, 4, 'Dumbbell Set', 'dumbbell-set', 'Complete dumbbell set for home workout', 499000.00, 40, 'product-placeholder.jpg', 1, '2025-12-01 06:30:26', '2025-12-01 06:30:26');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `role` enum('admin','customer') NOT NULL DEFAULT 'customer',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `username`, `email`, `password`, `full_name`, `phone`, `address`, `role`, `is_active`, `created_at`, `updated_at`) VALUES
(22, 'jiki', 'jikipadilah7667', 'jikipadilah7@gmail.com', '$2y$10$twOPjvHAh1LawRVDFLLE6.zExF1MmiETCr73ovYdUW0MRjQvDZsaq', '', NULL, NULL, 'customer', 1, '2025-12-20 03:54:41', '2025-12-20 03:54:41'),
(26, 'Admin User', 'admin', 'admin@test.com', '$2y$10$mDgn00z8MpIusAanRe4It.IX30nHAKC3X.hOo06qhT/0eTIhx2SJm', 'Admin User', '081234567891', 'Jl. Admin No. 456', 'admin', 1, '2025-12-20 10:57:28', '2025-12-20 10:57:28'),
(29, 'jiki', 'jikipadilah823', 'jikipadilah@gmail.com', '$2y$10$6Ua8.1GuokTu1X6/OIYTFOkM2xv0MJKw57DE0BFaSqVkD0didW2Wq', '', NULL, NULL, 'customer', 1, '2025-12-21 15:38:03', '2025-12-21 15:38:03');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `carts`
--
ALTER TABLE `carts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `carts_user_id_foreign` (`user_id`),
  ADD KEY `carts_product_id_foreign` (`product_id`);

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `order_number` (`order_number`),
  ADD KEY `orders_user_id_foreign` (`user_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_items_order_id_foreign` (`order_id`),
  ADD KEY `order_items_product_id_foreign` (`product_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `payments_order_id_foreign` (`order_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `products_category_id_foreign` (`category_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `carts`
--
ALTER TABLE `carts`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `carts`
--
ALTER TABLE `carts`
  ADD CONSTRAINT `carts_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `carts_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `order_items_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `order_items_product_id_foreign` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_order_id_foreign` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
