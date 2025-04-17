-- MySQL dump 10.13  Distrib 8.0.41, for Win64 (x86_64)
--
-- Host: localhost    Database: ecommerce_store
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cart`
--

DROP TABLE IF EXISTS `cart`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cart` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `quantity` int DEFAULT NULL,
  `product_id` bigint DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK3d704slv66tw6x5hmbm6p2x3u` (`product_id`),
  KEY `FKl70asp4l4w0jmbm1tqyofho4o` (`user_id`),
  CONSTRAINT `FK3d704slv66tw6x5hmbm6p2x3u` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`),
  CONSTRAINT `FKl70asp4l4w0jmbm1tqyofho4o` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cart`
--

LOCK TABLES `cart` WRITE;
/*!40000 ALTER TABLE `cart` DISABLE KEYS */;
INSERT INTO `cart` VALUES (1,3,10,1),(2,1,2,2);
/*!40000 ALTER TABLE `cart` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `category`
--

DROP TABLE IF EXISTS `category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `category` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `category_image` varchar(255) DEFAULT NULL,
  `category_name` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `category`
--

LOCK TABLES `category` WRITE;
/*!40000 ALTER TABLE `category` DISABLE KEYS */;
INSERT INTO `category` VALUES (7,'Pant.jpg','pant','2025-04-16 17:02:22.469203',_binary '','2025-04-16 17:02:22.470206'),(8,'panjabi.jpg','panjabi','2025-04-16 17:02:40.043557',_binary '','2025-04-16 17:02:40.043557'),(10,'Blazer.jpg','Blazer','2025-04-16 17:03:00.093846',_binary '','2025-04-16 17:03:00.093846'),(11,'Accessories.jpg','Accessories','2025-04-16 17:03:54.254657',_binary '','2025-04-16 17:03:54.254657'),(12,'KnitWear.jpg','KnitWear','2025-04-16 17:04:11.043569',_binary '','2025-04-16 17:04:11.043569'),(13,'CasualShirt.jpg','CasualShirt','2025-04-16 17:04:42.361683',_binary '','2025-04-16 17:04:42.361683');
/*!40000 ALTER TABLE `category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_address`
--

DROP TABLE IF EXISTS `order_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_address` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `pin_code` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_address`
--

LOCK TABLES `order_address` WRITE;
/*!40000 ALTER TABLE `order_address` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_address` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product`
--

DROP TABLE IF EXISTS `product`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `created_at` datetime(6) DEFAULT NULL,
  `discount` int NOT NULL,
  `discount_price` double DEFAULT NULL,
  `is_active` bit(1) DEFAULT NULL,
  `product_category` varchar(255) DEFAULT NULL,
  `product_description` varchar(5000) DEFAULT NULL,
  `product_image` varchar(255) DEFAULT NULL,
  `product_price` double DEFAULT NULL,
  `product_stock` int NOT NULL,
  `product_title` varchar(500) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product`
--

LOCK TABLES `product` WRITE;
/*!40000 ALTER TABLE `product` DISABLE KEYS */;
INSERT INTO `product` VALUES (2,NULL,15,25.4915,_binary '','Clothes','Soft cotton v-neck t-shirt with short sleeves. Perfect for everyday casual wear.','Casual-Shirt-Slim-Fit.jpg',29.99,250,'V-Neck Cotton T-Shirt','2025-04-16 17:12:04.054807'),(3,NULL,20,31.992,_binary '','Clothes','Long sleeve button-down shirt made from breathable oxford fabric. Available in various colors.','T-Shirt.jpg',39.99,180,'T-Shirt','2025-04-16 17:12:31.935464'),(4,NULL,10,44.991,_binary '','Clothes','Cozy knit sweater with ribbed cuffs and hem. Ideal for layering in cooler weather.','Blazer.jpg',49.99,120,'Classic Knit Sweater','2025-04-16 17:13:48.345455'),(5,NULL,5,56.990500000000004,_binary '','Clothes','Lightweight zip-up hoodie with front pockets. Great for workouts or casual outings.','panjabi-slim-fit.jpg',59.99,150,'Athletic Zip Hoodie','2025-04-16 17:15:55.641294'),(6,NULL,25,59.99249999999999,_binary '','Clothes','Relaxed fit chino pants made from durable twill cotton. Business casual essential.','KnitWear.jpg',79.99,140,'Classic Chino Pants','2025-04-16 17:15:42.227839'),(8,NULL,30,27.993000000000002,_binary '','Clothes','Casual shorts with elastic waistband. Perfect for summer activities.','Accessories.jpg',39.99,160,'Casual Summer Shorts','2025-04-16 17:15:19.462977'),(9,NULL,0,89.99,_binary '','Clothes','Tailored dress pants with flat front design. Wrinkle-resistant fabric blend.','laptopImg.jpeg',89.99,100,'Tailored Dress Pants','2025-04-16 17:14:43.724539'),(10,NULL,20,79.99199999999999,_binary '','Clothes','Waterproof rain jacket with hood and zippered pockets. Lightweight and packable.','CasualShirt.jpg',99.99,85,'Waterproof Rain Jacket','2025-04-16 17:14:32.365716'),(18,'2025-04-16 17:10:15.989122',0,123,_binary '','panjabi','this is a panjabi','panjabi.jpg',123,5,'panjabi','2025-04-16 17:10:15.990118');
/*!40000 ALTER TABLE `product` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_order`
--

DROP TABLE IF EXISTS `product_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_order` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `order_date` datetime(6) DEFAULT NULL,
  `order_id` varchar(255) DEFAULT NULL,
  `payment_type` varchar(255) DEFAULT NULL,
  `price` double DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `order_address_id` bigint DEFAULT NULL,
  `product_id` bigint DEFAULT NULL,
  `user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UKqcdbxaeuc7c5gahwh0dutg04r` (`order_address_id`),
  KEY `FKh73acsd9s5wp6l0e55td6jr1m` (`product_id`),
  KEY `FKa9own0mc8gwle8cckiij9ubsl` (`user_id`),
  CONSTRAINT `FK8frxalwc79tpxo7hgqp3hsjck` FOREIGN KEY (`order_address_id`) REFERENCES `order_address` (`id`),
  CONSTRAINT `FKa9own0mc8gwle8cckiij9ubsl` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  CONSTRAINT `FKh73acsd9s5wp6l0e55td6jr1m` FOREIGN KEY (`product_id`) REFERENCES `product` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
INSERT INTO product_order (
    order_date,
    order_id,
    payment_type,
    price,
    quantity,
    status,
    product_id,
    user_id
)
VALUES (
           NOW(), -- ou '2025-04-17 15:30:00'
           'ORD20250417001',
           'Credit Card',
           25.49,
           2,
           'Pending',
           2,  -- ID du produit
           1   -- ID de l'utilisateur
       );

--
-- Dumping data for table `product_order`
--

LOCK TABLES `product_order` WRITE;
/*!40000 ALTER TABLE `product_order` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_order` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user`
--

DROP TABLE IF EXISTS `user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `account_lock_time` datetime(6) DEFAULT NULL,
  `account_status_non_locked` bit(1) DEFAULT NULL,
  `accountfailed_attempt_count` int DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `is_enable` bit(1) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `pin_code` varchar(255) DEFAULT NULL,
  `profile_image` varchar(255) DEFAULT NULL,
  `reset_tokens` varchar(255) DEFAULT NULL,
  `role` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user`
--

LOCK TABLES `user` WRITE;
/*!40000 ALTER TABLE `user` DISABLE KEYS */;
INSERT INTO `user` VALUES (1,NULL,_binary '',1,'casa','casablanca','2025-04-12 18:04:01.123982','bernardtaha09@gmail.com',_binary '','0766303622','rida','$2a$10$cQ4b0w2IXcN/iM4OUsvo0e5dCuxDsNB6XIppXs3JaAs0VyQthHaaS','1234','default.jpg',NULL,'ROLE_USER','single','2025-04-12 19:48:24.383975'),(2,NULL,_binary '',0,'casa','casablanca','2025-04-12 19:01:53.589632','badrbernane@gmail.com',_binary '','0766303622','badr','$2a$10$0ipDw7pYGp02WFOzsEEg7.oi7kiJReXuq1I1kUS0kdYRbxL/k57Pq','1235','images.jfif',NULL,'ROLE_USER','single','2025-04-12 19:01:53.589632'),(3,NULL,_binary '',3,'Rabat','Rabat','2025-04-12 19:01:53.589632','badradmin@gmail.com',_binary '','O638742555','BADR','$2a$10$0ipDw7pYGp02WFOzsEEg7.oi7kiJReXuq1I1kUS0kdYRbxL/k57Pq','12234567',NULL,NULL,'ROLE_USER','mzwj','2025-04-12 19:47:08.863416'),(4,NULL,_binary '',1,'casa','casablanca','2025-04-12 19:50:01.108968','bernarAdmin@gmail.com',_binary '','0766303622','badr','$2a$10$o.35g7ed/Uw9S1zNe8hb8ez.2yEudXUmjqxiCb4SDnh3Xa4fAfJRm','1235','default.jpg',NULL,'ROLE_ADMIN','single','2025-04-14 01:08:59.874414');
/*!40000 ALTER TABLE `user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'ecommerce_store'
--

--
-- Dumping routines for database 'ecommerce_store'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-04-16 17:26:10
