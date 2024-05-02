-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 02, 2024 at 05:23 AM
-- Server version: 10.6.17-MariaDB-cll-lve-log
-- PHP Version: 7.4.27

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `expepxiz_timetable`
--

-- --------------------------------------------------------

--
-- Table structure for table `courses`
--

CREATE TABLE `courses` (
  `id` int(11) NOT NULL,
  `name` varchar(30) NOT NULL,
  `level` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `courses`
--

INSERT INTO `courses` (`id`, `name`, `level`) VALUES
(1, 'Computer Science', '8'),
(2, 'IT', '8'),
(3, 'Computer Science-evening', '8'),
(4, 'IT-Evening', '8'),
(5, 'Computer science ', '4'),
(6, 'computer science', '5'),
(7, 'computer science', '6'),
(10, 'computer science', '7-2');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(11) NOT NULL,
  `payment_status` varchar(50) DEFAULT NULL,
  `payer_email` varchar(100) DEFAULT NULL,
  `item_name` varchar(255) DEFAULT NULL,
  `payment_amount` decimal(10,2) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subjects`
--

CREATE TABLE `subjects` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(15) NOT NULL,
  `course` varchar(255) NOT NULL,
  `level` varchar(255) NOT NULL,
  `semester` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `subjects`
--

INSERT INTO `subjects` (`id`, `name`, `code`, `course`, `level`, `semester`) VALUES
(2, 'Data structure', 'CSU 23', 'Information technology', '5', 2),
(3, 'networking', 'csu120', 'Computer Science', '8', 1);

-- --------------------------------------------------------

--
-- Table structure for table `teachers`
--

CREATE TABLE `teachers` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `department` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `teachers`
--

INSERT INTO `teachers` (`id`, `name`, `department`) VALUES
(2, 'Mr Manyahi', 'ICT'),
(3, 'Mr Faraja', 'ICT'),
(4, 'Mr Sengura', 'GST'),
(5, 'Mr Kaijage', 'ICT'),
(6, 'Mr Mwasaga', 'ICT'),
(7, 'Madam Kafuria', 'ICT'),
(8, 'Mr Simalike', 'ICT'),
(9, 'Mr Kirobo', 'ICT'),
(10, 'ALI', 'CIVIL');

-- --------------------------------------------------------

--
-- Table structure for table `timetable`
--

CREATE TABLE `timetable` (
  `id` int(11) NOT NULL,
  `course` varchar(255) NOT NULL,
  `level` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `venue` varchar(255) NOT NULL,
  `teacher` varchar(255) NOT NULL,
  `day` varchar(10) NOT NULL,
  `time_start` time NOT NULL,
  `time_end` time NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `timetable`
--

INSERT INTO `timetable` (`id`, `course`, `level`, `subject`, `venue`, `teacher`, `day`, `time_start`, `time_end`) VALUES
(5, 'Computer Science', '8', 'Software Development', 'Room 06', 'Mr Kaijage', 'Monday', '16:30:00', '18:00:00'),
(6, 'Computer Science', '8', 'Data Structure', 's-12', 'Mr Simalike', 'Tuesday', '07:30:00', '09:00:00'),
(7, 'Computer Science', '8', 'Data Structure', 's-12', 'Mr Simalike', 'Tuesday', '09:00:00', '10:30:00'),
(8, 'Computer Science', '8', 'Cryptology', 'Comp R31', 'Mr Mwasaga', 'Tuesday', '13:15:00', '14:45:00'),
(9, 'Computer Science', '8', 'Software Development', 'Comp R31', 'Mr Kaijage', 'Tuesday', '16:30:00', '18:00:00'),
(10, 'Computer Science', '8', 'Network Administrtion', 'UF-05', 'Mr Manyahi', 'Wednesday', '13:15:00', '14:45:00'),
(11, 'Computer Science', '8', 'Crptology', 'UF-01', 'Mr Mwasaga', 'Wednesday', '15:00:00', '16:30:00'),
(12, 'Computer Science', '8', 'Network Administration ', 'Comp R 32/33', 'Mr Manyahi', 'Wednesday', '16:30:00', '18:30:00'),
(13, 'Computer Science', '8', 'Data Structure', 'Room 11', 'Mr Simalike', 'Thursday', '07:30:00', '09:00:00'),
(14, 'Computer Science', '8', 'Cryptology', 's-12', 'Mr Mwasaga', 'Thursday', '13:15:00', '14:45:00'),
(15, 'Computer Science', '8', 'Project Development', 'Room 42- LAB', 'Mr Kaijage', 'Thursday', '15:00:00', '16:30:00'),
(16, 'Computer Science', '8', 'Network Administration ', 'Comp R 32/33', 'Mr Manyahi', 'Friday', '14:00:00', '15:30:00'),
(17, 'Computer Science', '8', 'Project Development', 'Room 42- LAB', 'Mr Kaijage', 'Friday', '15:30:00', '17:00:00'),
(18, 'IT-Evening', '8', 'Software Development', 'Comp R 32/33', 'Mr Kaijage', 'Monday', '16:30:00', '18:00:00'),
(19, 'IT-Evening', '8', 'Software Development', 'Comp R 32/33', 'Mr Kaijage', 'Tuesday', '16:30:00', '18:00:00'),
(20, 'IT-Evening', '8', 'IT security and Auditing', 'Comp R31', 'Madam Kafuria', 'Tuesday', '19:30:00', '22:30:00'),
(21, 'IT-Evening', '8', 'Network Administration ', 'Comp R 32/33', 'Mr Manyahi', 'Wednesday', '16:30:00', '18:00:00'),
(22, 'IT-Evening', '8', 'E-commerce', 'Comp R31', 'Mr Kirobo', 'Wednesday', '19:30:00', '22:30:00'),
(23, 'IT-Evening', '8', 'Project Development', 'Room 42- LAB', 'Mr Kaijage', 'Thursday', '15:00:00', '16:30:00'),
(24, 'IT-Evening', '8', 'Network Administration ', 'Comp R 32/33', 'Mr Manyahi', 'Thursday', '18:00:00', '21:00:00'),
(25, 'IT-Evening', '8', 'Project Development', 'Room 42- LAB', 'Mr Kaijage', 'Friday', '15:30:00', '17:00:00'),
(26, 'IT-Evening', '8', 'It security and Auditing', 'Comp R31', 'Madam Kafuria', 'Friday', '17:00:00', '18:30:00'),
(29, 'Civil', '5', 'Algebra', 'S12', 'Kevoo', 'Monday', '11:00:00', '12:30:00'),
(30, 'Computer Science-evening', '7-2', 'Decision support', 'UG 06', 'Mr. kirobo', 'Friday', '20:26:00', '21:30:00');

-- --------------------------------------------------------

--
-- Table structure for table `venues`
--

CREATE TABLE `venues` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `capacity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `venues`
--

INSERT INTO `venues` (`id`, `name`, `capacity`) VALUES
(3, 'Room 06', 40),
(4, 'Room 12/13', 120),
(5, 'Room 11', 40),
(6, 'Room 14', 50),
(7, 's-12', 120),
(8, 'Comp R 32/33', 60),
(9, 'Comp R31', 40),
(10, 'UF-01', 90),
(11, 'UF-05', 80),
(12, 'Room 42- LAB', 100),
(13, 'UG 06', 45),
(14, 'Comp R22/23', 60);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `courses`
--
ALTER TABLE `courses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `subjects`
--
ALTER TABLE `subjects`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `teachers`
--
ALTER TABLE `teachers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `timetable`
--
ALTER TABLE `timetable`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `venues`
--
ALTER TABLE `venues`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `courses`
--
ALTER TABLE `courses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subjects`
--
ALTER TABLE `subjects`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `teachers`
--
ALTER TABLE `teachers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `timetable`
--
ALTER TABLE `timetable`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `venues`
--
ALTER TABLE `venues`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
