-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 18, 2026 at 01:53 PM
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
-- Database: `back_holcim`
--

-- --------------------------------------------------------

--
-- Table structure for table `alerts`
--

CREATE TABLE `alerts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `employee_habilitation_id` bigint(20) UNSIGNED NOT NULL,
  `alert_type` enum('expiration_proche','recyclage') NOT NULL,
  `alert_date` date NOT NULL,
  `jours_avant_expiration` tinyint(3) UNSIGNED NOT NULL,
  `statut` enum('inactive','active','resolue') NOT NULL DEFAULT 'inactive',
  `email_sent_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `alerts`
--

INSERT INTO `alerts` (`id`, `employee_habilitation_id`, `alert_type`, `alert_date`, `jours_avant_expiration`, `statut`, `email_sent_at`) VALUES
(19, 63, 'expiration_proche', '2029-05-09', 30, 'inactive', NULL),
(20, 63, 'expiration_proche', '2029-06-01', 7, 'inactive', NULL),
(21, 63, 'expiration_proche', '2029-06-08', 0, 'inactive', NULL),
(28, 66, 'expiration_proche', '2029-09-05', 30, 'inactive', NULL),
(29, 66, 'expiration_proche', '2029-09-28', 7, 'inactive', NULL),
(30, 66, 'expiration_proche', '2029-10-05', 0, 'inactive', NULL),
(31, 67, 'expiration_proche', '2028-12-02', 30, 'inactive', NULL),
(32, 67, 'expiration_proche', '2028-12-25', 7, 'inactive', NULL),
(33, 67, 'expiration_proche', '2029-01-01', 0, 'inactive', NULL),
(34, 68, 'expiration_proche', '2028-12-02', 30, 'inactive', NULL),
(35, 68, 'expiration_proche', '2028-12-25', 7, 'inactive', NULL),
(36, 68, 'expiration_proche', '2029-01-01', 0, 'inactive', NULL),
(37, 69, 'expiration_proche', '2029-05-11', 30, 'inactive', NULL),
(38, 69, 'expiration_proche', '2029-06-03', 7, 'inactive', NULL),
(39, 69, 'expiration_proche', '2029-06-10', 0, 'inactive', NULL),
(40, 70, 'expiration_proche', '2029-05-12', 30, 'inactive', NULL),
(41, 70, 'expiration_proche', '2029-06-04', 7, 'inactive', NULL),
(42, 70, 'expiration_proche', '2029-06-11', 0, 'inactive', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `attribution_validations`
--

CREATE TABLE `attribution_validations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `employee_habilitation_id` bigint(20) UNSIGNED NOT NULL,
  `role` enum('employe','manager_service','manager_departement','resp_sst','directeur') NOT NULL,
  `signataire_nom` varchar(255) NOT NULL,
  `signataire_email` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `statut` enum('en_attente','confirme','refuse') NOT NULL DEFAULT 'en_attente',
  `commentaire` text DEFAULT NULL,
  `confirmed_at` timestamp NULL DEFAULT NULL,
  `ordre` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) NOT NULL,
  `value` mediumtext NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) NOT NULL,
  `owner` varchar(255) NOT NULL,
  `expiration` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `departements`
--

CREATE TABLE `departements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `responsable` varchar(150) DEFAULT NULL,
  `responsable_email` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `departements`
--

INSERT INTO `departements` (`id`, `nom`, `responsable`, `responsable_email`, `created_at`, `updated_at`) VALUES
(1, 'Production', 'Mohammed FANANE', 'azzichaimae@hotmail.com', '2026-03-03 09:48:09', '2026-06-10 08:28:34'),
(2, 'Maintenance', 'Alaa-eddine BOURHIM', 'chaymaeazzi2407@gmail.com', '2026-03-03 09:48:09', '2026-06-10 08:30:43'),
(5, 'Direction d\'Usine', 'Chakib EL OUDGHIRI', NULL, '2026-03-03 09:48:09', '2026-06-11 22:00:32'),
(9, 'Exploitation Carrières, Préparation Matières, Environnement et Système de Management Intégré', 'Mohammed HANAFI', NULL, '2026-06-09 12:30:14', '2026-06-10 08:32:33');

-- --------------------------------------------------------

--
-- Table structure for table `documents`
--

CREATE TABLE `documents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `chemin` varchar(255) NOT NULL,
  `type` enum('individuelle','note') NOT NULL DEFAULT 'individuelle',
  `employee_habilitation_id` bigint(20) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `archived` tinyint(1) DEFAULT NULL,
  `habilitation_id` bigint(20) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `documents`
--

INSERT INTO `documents` (`id`, `nom`, `chemin`, `type`, `employee_habilitation_id`, `created_at`, `updated_at`, `archived`, `habilitation_id`) VALUES
(76, 'note_habilitation_Porteur_de_cadenas_20260429.pdf', 'documents/note_habilitation_Porteur_de_cadenas_20260429.pdf', 'note', NULL, '2026-04-29 13:35:50', '2026-04-29 13:35:50', NULL, 17),
(93, 'Habilitation_63_20260608.pdf', 'documents/Habilitation_63_20260608.pdf', 'individuelle', 63, '2026-06-08 10:12:37', '2026-06-08 10:12:37', NULL, NULL),
(96, 'note_habilitation_Emetteur_de_permis_20260608.pdf', 'documents/note_habilitation_Emetteur_de_permis_20260608.pdf', 'note', NULL, '2026-06-08 10:14:37', '2026-06-08 10:14:37', NULL, 18),
(97, 'note_habilitation_Emetteur_de_permis_20260608_1.pdf', 'documents/note_habilitation_Emetteur_de_permis_20260608.pdf', 'note', NULL, '2026-06-08 10:17:29', '2026-06-08 10:17:29', NULL, 18),
(98, 'note_habilitation_Emetteur_de_permis_20260608_2.pdf', 'documents/note_habilitation_Emetteur_de_permis_20260608.pdf', 'note', NULL, '2026-06-08 10:21:17', '2026-06-08 10:21:17', NULL, 18),
(99, 'Habilitation_66_20260610.pdf', 'documents/Habilitation_66_20260610.pdf', 'individuelle', 66, '2026-06-10 09:34:45', '2026-06-10 09:34:45', NULL, NULL),
(100, 'Habilitation_67_20260610.pdf', 'documents/Habilitation_67_20260610.pdf', 'individuelle', 67, '2026-06-10 09:41:00', '2026-06-10 09:41:00', NULL, NULL),
(101, 'Habilitation_68_20260610.pdf', 'documents/Habilitation_68_20260610.pdf', 'individuelle', 68, '2026-06-10 09:41:02', '2026-06-10 09:41:02', NULL, NULL),
(102, 'Habilitation_69_Recyclage_20260610.pdf', 'documents/Habilitation_69_Recyclage_20260610.pdf', 'individuelle', 69, '2026-06-10 12:54:06', '2026-06-10 12:54:06', NULL, NULL),
(103, 'Habilitation_70_20260611.pdf', 'documents/Habilitation_70_20260611.pdf', 'individuelle', 70, '2026-06-11 22:07:02', '2026-06-11 22:07:02', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `employees`
--

CREATE TABLE `employees` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `matricule` int(10) UNSIGNED DEFAULT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `email_pro` varchar(255) DEFAULT NULL,
  `position` varchar(255) NOT NULL,
  `type` enum('propre','sous-traitant') NOT NULL DEFAULT 'propre',
  `societe` varchar(150) DEFAULT NULL,
  `service_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `employees`
--

INSERT INTO `employees` (`id`, `matricule`, `nom`, `prenom`, `email_pro`, `position`, `type`, `societe`, `service_id`, `created_at`, `updated_at`, `deleted_at`) VALUES
(5, 3, 'AZZI', 'Chaymae', 'azzichaimae710@hotmail.ma', 'Ingénieure IT', 'propre', NULL, 21, '2026-03-03 12:53:02', '2026-06-10 09:27:38', '2026-06-10 09:27:38'),
(15, 1803, 'TLAGHI', 'Noureddin', 'noureddin.tlaghi@holcim.com', 'Contremaître Broyage Ciment', 'propre', NULL, 11, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(16, 70102, 'AIT SALEM', 'Mohammed', 'mohammed.aitsalem@holcim.com', 'Agent de Maintien Broyage Ciment', 'propre', NULL, 11, '2026-06-10 09:26:17', '2026-06-12 06:48:26', NULL),
(17, 70482, 'CHANI', 'Rachid', 'rachid.chani@hoclim.com', 'Agent de Maintien Broayage Ciment', 'propre', NULL, 11, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(18, 70483, 'MAAZOUZI', 'Ahmed', 'ahmed.maazouzi@hoclim.com', 'Agent de Maintien Broayage Ciment', 'propre', NULL, 11, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(19, 72002, 'KSIBA', 'Amine', 'amine.ksiba@hoclim.com', 'Agent de Maintien Broayage Ciment', 'propre', NULL, 11, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(20, 1783, 'TALEB', 'Samir', 'samir.taleb@holcim.com', 'Préparateur Mécanique', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(21, 1807, 'YAFRHOUL', 'Mohamed', 'mohamed.yafrhoul@holcim.com', 'Superviseur Lubrification', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(22, 1814, 'ADDABAB', 'Fatna', 'fatna.addabab@holcim.com', 'Responsable Gestion de Srock', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(23, 70101, 'MOUMOU', 'Salaheddine', 'salaheddine.moumou@holcim.com', 'Visiteur', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(24, 70385, 'MOKHTARI', 'Radoaune', 'radouane.mokhtari@holcim.com', 'Préparateur Electrique', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(25, 70405, 'KHEIR', 'Mohammed', 'mohammed.kheir@hoclim.com', 'Technicien Magasinier', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(26, 70509, 'BOUCHNAFI', 'Omar', 'omar.bouchnafi@hoclim.com', 'Visiteur', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(27, 70878, 'DAHRI', 'Aziz', 'aziz.dahri@hoclim.com', 'Agent Lubrification', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(28, 72050, 'EL GOUMA', 'Taoufik', 'taoufik.el gouma@hoclim.com', 'Agent Lubrification', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(29, 72008, 'ARROUBIOU', 'Hassan', 'hassan.arroubiou@hoclim.com', 'Responsable Bureau Méthode et Travaux Neufs', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(30, 1778, 'BIKIS', 'Abdelaziz', 'abdelaziz.bikis@holcim.com', 'Préparateur Mécanique', 'propre', NULL, 20, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(31, 60008, 'HANAFI', 'Mohammed', 'mohammed.hanafi@holcim.com', 'Responsable Exploitation Carrières, Préparation Matières, Environnement et Système de Management Intégré', 'propre', NULL, 29, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(32, 1804, 'HAMMOUTI', 'El miloud', 'el miloud.hammouti@holcim.com', 'Superviseur Laboratoire', 'propre', NULL, 29, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(33, 70151, 'QERROUECH', 'Mohammed', 'mohammed.qerrouech@holcim.com', 'Agent Laboratoire', 'propre', NULL, 29, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(34, 70406, 'NACHCHAT', 'Abdelaziz', 'abdelaziz.nachchat@hoclim.com', 'Agent Laboratoire', 'propre', NULL, 29, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(35, 70480, 'TOUIL', 'Abdelilah', 'abdelilah.touil@hoclim.com', 'Agent Laboratoire', 'propre', NULL, 29, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(36, 70484, 'HAMDAI', 'Hafid', 'hafid.hamdai@hoclim.com', 'Agent Laboratoire', 'propre', NULL, 29, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(37, 70616, 'ERRHIOUI', 'Mohammed', 'mohammed.errhioui@hoclim.com', 'Agent Laboratoire', 'propre', NULL, 29, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(38, 72032, 'RABHI', 'Laila', 'laila.rabhi@hoclim.com', 'Responsable Contrôle Qualité et Système de management Intégré', 'propre', NULL, 29, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(39, 1805, 'MAHYAOUI', 'Zouhir', 'zouhir.mahyaoui@holcim.com', 'Contremaître Fabrication', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(40, 1816, 'KHATRI', 'Fares', 'fares.khatri@holcim.com', 'Chef de Poste', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(41, 1819, 'CHOURFI', 'Ahmed', 'ahmed.chourfi@holcim.com', 'Chef de Poste', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(42, 70129, 'N HAR', 'Mohammed', 'mohammed.n har@holcim.com', 'Chef de Poste', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(43, 70130, 'ABDI', 'Abdelkader', 'abdelkader.abdi@holcim.com', 'Opérateur Salle de Contrôle', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(44, 70387, 'MARAR', 'Kamal', 'kamal.marar@holcim.com', 'Chef de Poste', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(45, 70404, 'TOUITOU', 'Youssef', 'youssef.touitou@hoclim.com', 'Opérateur Salle de Contrôle', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(46, 70415, 'ABID', 'Mounir', 'mounir.abid@hoclim.com', 'Opérateur Salle de Contrôle', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(47, 70450, 'HAJI', 'Abdelkader', 'abdelkader.haji@hoclim.com', 'Agent de Maintien Mécanicien', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(48, 70470, 'ZERROUK', 'El miloud', 'el miloud.zerrouk@hoclim.com', 'Agent de Maintien Mécanicien', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(49, 70471, 'REGGANI', 'Samir', 'samir.reggani@hoclim.com', 'Agent de Maintien Mécanicien', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(50, 70481, 'SECOULI', 'Abdelmounim', 'abdelmounim.secouli@hoclim.com', 'Opérateur Salle de Contrôle', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(51, 70698, 'OUALI', 'Mohammed', 'mohammed.ouali@hoclim.com', 'Agent de Maintien Mécanicien', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(52, 70699, 'NAJI', 'Omar', 'omar.naji@hoclim.com', 'Agent de Maintien Cuisson', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(53, 70707, 'GHEZOUTI', 'Ayoub', 'ayoub.ghezouti@hoclim.com', 'Responsable Fabrication', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(54, 80445, 'CHABELLA', 'Abdelhafid', 'abdelhafid.chabella@hoclim.com', 'Opérateur Salle de Contrôle', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(55, 80457, 'MOUHSINE', 'Alaeddine', 'alaeddine.mouhsine@hoclim.com', 'Opérateur Salle de Contrôle', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(56, 72356, 'GHRIB', 'Ahmed', 'ahmed.ghrib @hoclim.com', 'Opérateur Salle de Contrôle', 'propre', NULL, 13, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(57, 1808, 'BENMOUSSA', 'El hassane', 'el hassane.benmoussa@holcim.com', 'Chargé OT / POT', 'propre', NULL, 3, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(58, 70347, 'AMEUR', 'Lakhdar', 'lakhdar.ameur@holcim.com', 'Electricien', 'propre', NULL, 3, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(59, 70386, 'ZAREHAOUI', 'Mouhcine', 'mouhcine.zarehaoui@holcim.com', 'Superviseur Electrique', 'propre', NULL, 3, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(60, 70493, 'HASSANI', 'Nabil', 'nabil.hassani@hoclim.com', 'Electricien', 'propre', NULL, 3, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(61, 70711, 'BOUZIANI', 'Mounir', 'mounir.bouziani@hoclim.com', 'Electricien', 'propre', NULL, 3, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(62, 70959, 'EL AABED', 'Anouar', 'anouar.elaabed@hoclim.com', 'Electricien', 'propre', NULL, 3, '2026-06-10 09:26:17', '2026-06-12 06:48:12', NULL),
(63, 72003, 'BOUTAYBI', 'Yahya', 'yahya.boutaybi@hoclim.com', 'Electricien', 'propre', NULL, 3, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(64, 72043, 'JBILOU', 'Salah-eddine', 'salah-eddine.jbilou@hoclim.com', 'Electricien', 'propre', NULL, 3, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(65, 72044, 'KASMI', 'Mohammed', 'mohammed.kasmi@hoclim.com', 'Electricien', 'propre', NULL, 3, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(66, 1785, 'SMAILI', 'Benali', 'benali.smaili@holcim.com', 'Mécanicien', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(67, 1802, 'ZAHRI', 'Abdelmajid', 'abdelmajid.zahri@holcim.com', 'Superviseur Mécanique', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(68, 1806, 'MIRI', 'Mohamed', 'mohamed.miri@holcim.com', 'Mécanicien', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(69, 1809, 'BAHRAOUI', 'Boujemaa', 'boujemaa.bahraoui@holcim.com', 'Superviseur Mécanique', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(70, 70402, 'FOUNOUNOU', 'Abdenasser', 'abdenasser.founounou@hoclim.com', 'Mécanicien', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(71, 70474, 'NIECH', 'El houcine', 'el houcine.niech@hoclim.com', 'Mécanicien', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(72, 70510, 'LAGROUH', 'Mohammed', 'mohammed.lagrouh@hoclim.com', 'Mécanicien', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(73, 70693, 'BOUFELJAT', 'Omar', 'omar.boufeljat@hoclim.com', 'Mécanicien', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(74, 70697, 'KHYA', 'Hassan', 'hassan.khya@hoclim.com', 'Mécanicien', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(75, 72056, 'AZZOUZI', 'El miloud', 'el miloud.azzouzi@hoclim.com', 'Mécanicien', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(76, 72057, 'SEDDIKI', 'Abderrahim', 'abderrahim.seddiki@hoclim.com', 'Mécanicien', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(77, 72058, 'BENGAG', 'Ahmed', 'ahmed.bengag@hoclim.com', 'Mécanicien', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(78, 72031, 'EDQIOUAQ', 'Taha', 'taha.edqiouaq@hoclim.com', 'Responsable Mécanique', 'propre', NULL, 10, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(79, 70224, 'AIT BRAHIM', 'Mounia', 'mounia.aitbrahim@holcim.com', 'Responsable Ressources Humaines', 'propre', NULL, 21, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(80, 72261, 'BOURKENE', 'Wassif', 'wassif.bourkene@hoclim.com', 'Chargé Paie et Administration RH', 'propre', NULL, 21, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(81, 70247, 'MEFTAH', 'Rachid', 'rachid.meftah@holcim.com', 'Animateur Santé & Sécuité & Environnement', 'propre', NULL, 31, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(82, 70963, 'CHARRIK', 'Fatima zzahra', 'fatima zzahra.charrik@hoclim.com', 'Responsable Santé Sécurité & Environnement', 'propre', NULL, 31, '2026-06-10 09:26:17', '2026-06-10 09:26:17', NULL),
(83, 1813, 'RMILI', 'Abdellah', 'abdellah.rmili@holcim.com', 'Opérateur Concasseur Principal', 'propre', NULL, 29, '2026-06-10 09:27:18', '2026-06-12 07:26:42', NULL),
(84, 70451, 'MBARKI', 'Farid', 'farid.mbarki@hoclim.com', 'Opérateur Concasseur Principal', 'propre', NULL, 29, '2026-06-10 09:27:18', '2026-06-10 09:27:18', NULL),
(86, NULL, 'RAMDANI', 'Ayoub', 'ayoub.ramdani@holcim.com', 'INFIRMIER', 'sous-traitant', NULL, 21, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(87, NULL, 'MAHDOUB', 'Mohammed', 'mohammed.mahdoub@holcim.com', 'AGENT DE MAINTIEN TOUR DOPOL', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(88, NULL, 'ZAID', 'Cheikh', 'cheikh.zaid@holcim.com', 'AGENT DE MAINTIEN TOUR DOPOL', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(89, NULL, 'ZAID', 'Ahmed', 'ahmed.zaid@holcim.com', 'AGENT DE MAINTIEN TOUR DOPOL', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(90, NULL, 'ZIANI', 'Jaouad', 'jaouad.ziani@holcim.com', 'AGENT DE MAINTIEN TOUR DOPOL', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(91, NULL, 'RACHDI', 'Jaouad', 'jaouad.rachdi@holcim.com', 'AGENT DE MAINTIEN TOUR DOPOL', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(92, NULL, 'EL AYDEL', 'Mohammed', 'mohammed.elaydel@holcim.com', 'AGENT DE MAINTIEN CUISSON', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(93, NULL, 'MACHICHI', 'Mustapha', 'mustapha.machichi@holcim.com', 'AGENT DE MAINTIEN CUISSON', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(94, NULL, 'MACHICHI', 'Yassine', 'yassine.machichi@holcim.com', 'AGENT DE MAINTIEN CUISSON', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(95, NULL, 'SERGHINI', 'Azzeddine', 'azzeddine.serghini@holcim.com', 'AGENT DE MAINTIEN CUISSON', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(96, NULL, 'ZAID', 'Said', 'said.zaid@holcim.com', 'AGENT NETTOYAGE PREPARATION MATIERE', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(97, NULL, 'ES-SOUFI', 'Mohammed', 'mohammed.es-soufi@holcim.com', 'AGENT NETTOYAGE PREPARATION MATIERE', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(98, NULL, 'GUETTAR', 'Mohammed', 'mohammed.guettar@holcim.com', 'AGENT NETTOYAGE CUISSON', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(99, NULL, 'EL-HORE', 'El miloud', 'elmiloud.el-hore@holcim.com', 'AGENT NETTOYAGE CUISSON', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(100, NULL, 'SFAKAS', 'Mohammed', 'mohammed.sfakas@holcim.com', 'AGENT NETTOYAGE CUISSON', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(101, NULL, 'AHSAYENE', 'Mohammed', 'mohammed.ahsayene@holcim.com', 'AGENT NETTOYAGE CUISSON', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(102, NULL, 'SAMHI', 'Nouredine', 'nouredine.samhi@holcim.com', 'AGENT NETTOYAGE PARC CHARBON', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(103, NULL, 'BENCHAOU', 'Mohammed', 'mohammed.benchaou@holcim.com', 'AGENT NETTOYAGE PARC CHARBON', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(104, NULL, 'ES-SAFSAFI', 'Mustapha', 'mustapha.es-safsafi@holcim.com', 'AGENT NETTOYAGE BROYAGE CIMENT', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(105, NULL, 'M\'JAHED', 'Slimane', 'slimane.mjahed@holcim.com', 'AGENT PONT BASCULE CLINKER', 'sous-traitant', NULL, 13, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(106, NULL, 'HAMZAOUI', 'Abdelelah', 'abdelelah.hamzaoui@holcim.com', 'ELECTRICIEN', 'sous-traitant', NULL, 3, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(107, NULL, 'CHANI', 'Ali', 'ali.chani@holcim.com', 'ELECTRICIEN', 'sous-traitant', NULL, 3, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(108, NULL, 'TALBI', 'El miloud', 'elmiloud.talbi@holcim.com', 'ELECTRICIEN', 'sous-traitant', NULL, 3, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(109, NULL, 'ABDELLAOUI', 'Mohammed', 'mohammed.abdellaoui@holcim.com', 'AGENT LABORATOIRE', 'sous-traitant', NULL, 29, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(110, NULL, 'FATHI', 'Jemaa', 'jemaa.fathi@holcim.com', 'FEMME DE MENAGE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(111, NULL, 'EL WALI', 'Aicha', 'aicha.elwali@holcim.com', 'FEMME DE MENAGE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(112, NULL, 'MAHFOUD', 'Abdelkader', 'abdelkader.mahfoud@holcim.com', 'JARDINIER', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(113, NULL, 'ES-SOUFI', 'El hassan', 'elhassan.es-soufi@holcim.com', 'JARDINIER', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(114, NULL, 'SOUYEH', 'Amine', 'amine.souyeh@holcim.com', 'SUPERVISEUR', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(115, NULL, 'AIT SALEM', 'Jamal', 'jamal.aitsalem@holcim.com', 'OPERATEUR CARRICAMAT', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(116, NULL, 'MOKHTARI', 'Abdelbasset', 'abdelbasset.mokhtari@holcim.com', 'OPERATEUR CARRICAMAT', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(117, NULL, 'NAJI', 'Aziz', 'aziz.naji@holcim.com', 'OPERATEUR CARRICAMAT', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(118, NULL, 'MAARAD', 'Mohammed', 'mohammed.maarad@holcim.com', 'ELECTROMECANICIEN', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:53:15', NULL),
(119, NULL, 'YOUSFI', 'Abdelkader', 'abdelkader.yousfi@holcim.com', 'CONDUCTEUR CHARIOT ELEVATEUR PALITISEUR', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(120, NULL, 'MAHFOUD', 'Tayeb', 'tayeb.mahfoud@holcim.com', 'CONDUCTEUR CHARIOT ELEVATEUR PALITISEUR', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(121, NULL, 'TAHRI', 'Yahya', 'yahya.tahri@holcim.com', 'GUIDEUR CHARGEUR', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(122, NULL, 'CHALIL', 'Brahim', 'brahim.chalil@holcim.com', 'GUIDEUR CHARGEUR', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(123, NULL, 'BERTAL', 'Mohammed', 'mohammed.bertal@holcim.com', 'MACHINISTE', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(124, NULL, 'CHARTI', 'Khalid', 'khalid.charti@holcim.com', 'MACHINISTE', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(125, NULL, 'AZLAF', 'Ahmed', 'ahmed.azlaf@holcim.com', 'MACHINISTE', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(126, NULL, 'ABDELLAOUI', 'Driss', 'driss.abdellaoui@holcim.com', 'MACHINISTE', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(127, NULL, 'GABLI', 'Fouad', 'fouad.gabli@holcim.com', 'MACHINISTE', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(128, NULL, 'LAKHDIM', 'El haj', 'elhaj.lakhdim@holcim.com', 'MACHINISTE', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(129, NULL, 'ERRASFA', 'Adil', 'adil.errasfa@holcim.com', 'MECANICIEN', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(130, NULL, 'ARIANI', 'Radoine', 'radoine.ariani@holcim.com', 'ELECTROMECANICIEN', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(131, NULL, 'LAMKADDEM', 'Amar', 'amar.lamkaddem@holcim.com', 'AGENT BACHAGE EXPEDITIONS', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(132, NULL, 'MAHDOUB', 'Rabah', 'rabah.mahdoub@holcim.com', 'AGENT BACHAGE EXPEDITIONS', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(133, NULL, 'MAHFOUD', 'Mohammed', 'mohammed.mahfoud@holcim.com', 'JARDINIER', 'sous-traitant', NULL, 33, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(134, NULL, 'ELLALI', 'Mostafa', 'mostafa.ellali@holcim.com', 'SUPERVISEUR', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(135, NULL, 'BOUDLAL', 'Hamid', 'hamid.boudlal@holcim.com', 'SURVEILLANCE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(136, NULL, 'RACHDI', 'El miloud', 'elmiloud.rachdi@holcim.com', 'SURVEILLANCE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(137, NULL, 'BENQEZZA', 'Abdellatif', 'abdellatif.benqezza@holcim.com', 'SURVEILLANCE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(138, NULL, 'HAJJI', 'Mohammed', 'mohammed.hajji@holcim.com', 'SURVEILLANCE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(139, NULL, 'MAHDOUB', 'Abdelkader', 'abdelkader.mahdoub@holcim.com', 'SURVEILLANCE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(140, NULL, 'KISSARI', 'Blal', 'blal.kissari@holcim.com', 'SURVEILLANCE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(141, NULL, 'QELLOUCH', 'Farid', 'farid.qellouch@holcim.com', 'SURVEILLANCE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(142, NULL, 'ZERIOUH', 'Abdennabi', 'abdennabi.zeriouh@holcim.com', 'SURVEILLANCE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(143, NULL, 'MEZIANE', 'Mouad', 'mouad.meziane@holcim.com', 'SURVEILLANCE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(144, NULL, 'HATRI', 'Mimoun', 'mimoun.hatri@holcim.com', 'SURVEILLANCE', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(145, NULL, 'MACHICHI', 'Abdelkrim', 'abdelkrim.machichi@holcim.com', 'MECANICIEN', 'sous-traitant', NULL, 10, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(146, NULL, 'RABIA', 'Fathi', 'fathi.rabia@holcim.com', 'MECANICIEN', 'sous-traitant', NULL, 10, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(147, NULL, 'SMAILI', 'Mohammed', 'mohammed.smaili@holcim.com', 'MECANICIEN', 'sous-traitant', NULL, 10, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(148, NULL, 'FOUNES', 'Otman', 'otman.founes@holcim.com', 'MECANICIEN', 'sous-traitant', NULL, 10, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(149, NULL, 'MARAR', 'Ibrahim', 'ibrahim.marar@holcim.com', 'MECANICIEN', 'sous-traitant', NULL, 10, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(150, NULL, 'DEROUICH', 'Jaouad', 'jaouad.derouich@holcim.com', 'MECANICIEN', 'sous-traitant', NULL, 10, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(151, NULL, 'ABDERHIM', 'Ali', 'ali.abderhim@holcim.com', 'AGENT LUBRIFICATION', 'sous-traitant', NULL, 20, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(152, NULL, 'TAHIRI', 'Omar', 'omar.tahiri@holcim.com', 'AGENT BANDE', 'sous-traitant', NULL, 10, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(153, NULL, 'EL ALI', 'Yassine', 'yassine.elali@holcim.com', 'MAGASINIER', 'sous-traitant', NULL, 20, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(154, NULL, 'BENLAFKIH', 'El hassan', 'elhassan.benlafkih@holcim.com', 'GERANT/SERVEUR', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(155, NULL, 'AYACH', 'Marouane', 'marouane.ayach@holcim.com', 'CUISINIER', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(156, NULL, 'EL KHAOULANI IDRISSI', 'Abdelilah', 'abdelilah.elkhaoulaniidrissi@holcim.com', 'SERVEUR', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(157, NULL, 'AJJOUR', 'Bilal', 'bilal.ajjour@holcim.com', 'SERVEUR', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(158, NULL, 'EL-BAGHAR', 'Mohammed', 'mohammed.el-baghar@holcim.com', 'PLONGEUR', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(159, NULL, 'MRIBIHA', 'Chafiq', 'chafiq.mribiha@holcim.com', 'Chaffeur Mini-Bus (Sidi-Yahya 1er et 2éme Poste)', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(160, NULL, 'BENAOUDA', 'Jamal', 'jamal.benaouda@holcim.com', 'Chaffeur Mini-Bus (Sidi-Yahya 3éme Poste)', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(161, NULL, 'SAOUD', 'Mohammed', 'mohammed.saoud@holcim.com', 'Chaffeur Mini-Bus (CGI 1er et 2éme Poste)', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(162, NULL, 'FILALI', 'Jalal', 'jalal.filali@holcim.com', 'Chaffeur Mini-Bus (CGI 3éme Poste)', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(163, NULL, 'BAHOUSSI', 'Abdellah', 'abdellah.bahoussi@holcim.com', 'Chaffeur Mini-Bus (El Aioun 1er 2éme et 3éme Poste)', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(164, NULL, 'LAHRICHI', 'Abdelmajid', 'abdelmajid.lahrichi@holcim.com', 'Chaffeur Mini-Bus (El Aioun 1er 2éme et 3éme Poste) Remplacent', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(165, NULL, 'HOUARI', 'Mohammed', 'mohammed.houari@holcim.com', 'Chaffeur Mini-Bus (Plan B)', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(166, NULL, 'BANNANI', 'Abdelmalek', 'abdelmalek.bannani@holcim.com', 'Superviseur', 'sous-traitant', NULL, 32, '2026-06-12 09:51:36', '2026-06-12 09:51:36', NULL),
(167, NULL, 'ZERROUDI', 'Elhoussine', 'elhoussine.zerroudi@holcim.com', 'OPERATEUR DE CHARGEMENT VRAC', 'sous-traitant', NULL, 34, '2026-06-12 09:53:15', '2026-06-12 09:53:15', NULL),
(168, NULL, 'MAKHOUKHI', 'El madani', 'elmadani.makhoukhi@holcim.com', 'OPERATEUR DE CHARGEMENT VRAC', 'sous-traitant', NULL, 34, '2026-06-12 09:53:15', '2026-06-12 09:53:15', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `employee_habilitations`
--

CREATE TABLE `employee_habilitations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `employee_id` bigint(20) UNSIGNED NOT NULL,
  `habilitation_id` bigint(20) UNSIGNED NOT NULL,
  `date_obtention` date NOT NULL,
  `date_expiration` date NOT NULL,
  `type` enum('initiale','recyclage') NOT NULL,
  `organisme_formation` varchar(150) NOT NULL,
  `date_aptitude_medicale` date NOT NULL,
  `statut` enum('valide','expirée') NOT NULL DEFAULT 'valide',
  `validation_statut` enum('non_soumis','en_cours','valide','refuse') NOT NULL DEFAULT 'non_soumis',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `employee_habilitations`
--

INSERT INTO `employee_habilitations` (`id`, `employee_id`, `habilitation_id`, `date_obtention`, `date_expiration`, `type`, `organisme_formation`, `date_aptitude_medicale`, `statut`, `validation_statut`, `created_at`, `updated_at`) VALUES
(63, 5, 18, '2026-06-08', '2029-06-08', 'initiale', 'NOTE', '2026-06-08', 'valide', 'non_soumis', '2026-06-08 10:12:25', '2026-06-08 10:12:25'),
(66, 83, 18, '2026-10-05', '2029-10-05', 'initiale', 'bbc', '2026-01-01', 'valide', 'non_soumis', '2026-06-10 09:34:40', '2026-06-10 09:34:40'),
(67, 41, 19, '2026-01-01', '2029-01-01', 'recyclage', 'hghg', '2026-01-02', 'valide', 'non_soumis', '2026-06-10 09:40:59', '2026-06-10 09:40:59'),
(68, 59, 19, '2026-01-01', '2029-01-01', 'recyclage', 'hghg', '2026-01-02', 'valide', 'non_soumis', '2026-06-10 09:41:01', '2026-06-10 09:41:01'),
(69, 76, 18, '2026-06-10', '2029-06-10', 'recyclage', 'aa', '2026-06-03', 'valide', 'non_soumis', '2026-06-10 12:54:06', '2026-06-10 12:54:06'),
(70, 83, 19, '2026-06-11', '2029-06-11', 'initiale', '333', '2026-06-11', 'valide', 'non_soumis', '2026-06-11 22:06:57', '2026-06-11 22:06:57');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `habilitations`
--

CREATE TABLE `habilitations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `detail_formation` text DEFAULT NULL,
  `texte_autorisation` varchar(255) DEFAULT NULL,
  `duree_formation_initiale` float NOT NULL,
  `duree_formation_initiale_unite` enum('heures','jours') NOT NULL,
  `duree_formation_recyclage` float NOT NULL,
  `duree_formation_recyclage_unite` enum('heures','jours') NOT NULL,
  `duree_de_validite` int(10) UNSIGNED NOT NULL,
  `volet_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `habilitations`
--

INSERT INTO `habilitations` (`id`, `nom`, `detail_formation`, `texte_autorisation`, `duree_formation_initiale`, `duree_formation_initiale_unite`, `duree_formation_recyclage`, `duree_formation_recyclage_unite`, `duree_de_validite`, `volet_id`, `created_at`, `updated_at`) VALUES
(8, 'Inspection Outillage', NULL, NULL, 2, 'heures', 2, 'heures', 3, 18, '2026-03-05 09:08:42', '2026-03-10 10:55:58'),
(9, 'Emetteur de permis de WaH', NULL, NULL, 1, 'jours', 4, 'heures', 1, 3, '2026-03-05 09:09:51', '2026-03-05 09:09:51'),
(10, 'Personne autorisée à travailler enhauteur et Porteur  et controleur du harnais', NULL, NULL, 3, 'jours', 2, 'heures', 1, 3, '2026-03-05 09:11:01', '2026-03-05 09:11:01'),
(11, 'Sauveteur WAH', NULL, 'test texte autorisation', 8, 'heures', 4, 'heures', 1, 3, '2026-03-05 09:11:37', '2026-03-31 12:12:50'),
(12, 'Montage/démontage  Echaffaudage', NULL, NULL, 2, 'jours', 2, 'jours', 3, 3, '2026-03-05 09:12:12', '2026-03-05 09:12:12'),
(13, 'Réception Echaffaudage', NULL, NULL, 4, 'heures', 4, 'heures', 1, 3, '2026-03-05 09:12:50', '2026-03-05 09:12:50'),
(14, 'Utilsation harnais sur plateforme sécurisé', NULL, NULL, 4, 'heures', 4, 'heures', 1, 3, '2026-03-05 09:13:25', '2026-03-05 09:13:25'),
(15, 'Controleur de consignation', NULL, NULL, 4, 'heures', 2, 'heures', 3, 6, '2026-03-05 09:14:40', '2026-03-05 09:14:40'),
(17, 'Porteur de cadenas', NULL, 'les Travaux en tant que Porteur de Cadenas', 2, 'heures', 2, 'heures', 3, 6, '2026-03-05 09:16:14', '2026-04-28 13:50:07'),
(18, 'Emetteur de permis', NULL, NULL, 8, 'heures', 2, 'heures', 3, 7, '2026-03-05 09:17:17', '2026-03-05 09:17:17'),
(19, 'Entrant  EC', NULL, NULL, 8, 'heures', 3, 'heures', 3, 7, '2026-03-05 09:17:56', '2026-03-05 09:17:56'),
(20, 'Surveillant EC', NULL, NULL, 8, 'heures', 3, 'heures', 3, 7, '2026-03-05 09:18:15', '2026-03-05 09:18:15'),
(21, 'Sauveteur en EC', NULL, NULL, 1, 'jours', 4, 'heures', 1, 7, '2026-03-05 09:18:49', '2026-03-05 09:18:49'),
(22, 'Conduite chargeuse et engins carrière', NULL, 'test text autoriation', 5, 'jours', 2, 'jours', 3, 8, '2026-03-05 09:19:51', '2026-03-31 12:13:53'),
(23, 'Conduite de grue', NULL, 'les travaux en tant que conducteur de grue', 15, 'jours', 5, 'jours', 3, 8, '2026-03-05 09:21:00', '2026-03-31 08:30:26'),
(24, 'Conduite chariot élévateur', NULL, NULL, 5, 'jours', 2, 'jours', 3, 8, '2026-03-05 09:21:38', '2026-03-31 06:56:02'),
(25, 'Habilitation conduite de la nacelle /PEMP', NULL, NULL, 2, 'jours', 2, 'jours', 3, 8, '2026-03-05 09:22:14', '2026-03-05 09:22:14');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `jobs`
--

INSERT INTO `jobs` (`id`, `queue`, `payload`, `attempts`, `reserved_at`, `available_at`, `created_at`) VALUES
(1, 'default', '{\"uuid\":\"b7a0cecb-aa26-4d78-ac64-a37bac41b473\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:6;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:7;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:13:\\\"rrh@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773062218,\"delay\":null}', 0, NULL, 1773062218, 1773062218),
(2, 'default', '{\"uuid\":\"d551d83a-7e6f-481d-ae31-75365a19804b\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:6;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:7;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:12:\\\"rh@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773062218,\"delay\":null}', 0, NULL, 1773062218, 1773062218),
(3, 'default', '{\"uuid\":\"1b8155ee-21fe-4c03-a16b-664697e22547\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:6;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:7;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:19:\\\"s.elfassi@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773062218,\"delay\":null}', 0, NULL, 1773062218, 1773062218),
(4, 'default', '{\"uuid\":\"a2f5e9dc-e808-4d79-8960-3f9ca74bf095\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:13:\\\"rrh@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773223779,\"delay\":null}', 0, NULL, 1773223779, 1773223779),
(5, 'default', '{\"uuid\":\"76caa15e-243b-4892-9223-f05d3fc7af14\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:12:\\\"rh@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773223779,\"delay\":null}', 0, NULL, 1773223779, 1773223779),
(6, 'default', '{\"uuid\":\"6f87d956-b2ac-44b7-a534-b0781d30160b\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:18:\\\"m.rachid@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773223779,\"delay\":null}', 0, NULL, 1773223779, 1773223779),
(7, 'default', '{\"uuid\":\"3b4cc877-99a6-48ad-ba3b-9fce27cbf07f\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:13:\\\"rrh@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773223801,\"delay\":null}', 0, NULL, 1773223801, 1773223801),
(8, 'default', '{\"uuid\":\"31f4c3ad-70bc-4f1b-bb6b-dd95f793e6dc\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:12:\\\"rh@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773223801,\"delay\":null}', 0, NULL, 1773223801, 1773223801),
(9, 'default', '{\"uuid\":\"36897b1e-37df-46a4-93a4-e78ca67a270e\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:18:\\\"m.rachid@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773223801,\"delay\":null}', 0, NULL, 1773223801, 1773223801),
(10, 'default', '{\"uuid\":\"a4b9b7ec-a806-4ab8-a7d8-181c9ec425b2\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:13:\\\"rrh@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773225315,\"delay\":null}', 0, NULL, 1773225315, 1773225315),
(11, 'default', '{\"uuid\":\"2641c995-bb85-4211-bf76-c605ec0864fd\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:12:\\\"rh@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773225315,\"delay\":null}', 0, NULL, 1773225315, 1773225315),
(12, 'default', '{\"uuid\":\"4b8872e6-ab44-48c8-bbe1-66658c42048a\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:18:\\\"m.rachid@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773225315,\"delay\":null}', 0, NULL, 1773225315, 1773225315),
(13, 'default', '{\"uuid\":\"90c53c24-3a3a-417f-88ff-865a4f2062be\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:13:\\\"rrh@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773226049,\"delay\":null}', 0, NULL, 1773226049, 1773226049),
(14, 'default', '{\"uuid\":\"d191ed2e-b8b0-416e-b785-f08b42c216c1\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:12:\\\"rh@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773226049,\"delay\":null}', 0, NULL, 1773226049, 1773226049),
(15, 'default', '{\"uuid\":\"2767f81c-6bd8-4734-ae66-305523670f69\",\"displayName\":\"App\\\\Mail\\\\HabilitationExpirationMail\",\"job\":\"Illuminate\\\\Queue\\\\CallQueuedHandler@call\",\"maxTries\":null,\"maxExceptions\":null,\"failOnTimeout\":false,\"backoff\":null,\"timeout\":null,\"retryUntil\":null,\"data\":{\"commandName\":\"Illuminate\\\\Mail\\\\SendQueuedMailable\",\"command\":\"O:34:\\\"Illuminate\\\\Mail\\\\SendQueuedMailable\\\":17:{s:8:\\\"mailable\\\";O:35:\\\"App\\\\Mail\\\\HabilitationExpirationMail\\\":4:{s:2:\\\"eh\\\";O:45:\\\"Illuminate\\\\Contracts\\\\Database\\\\ModelIdentifier\\\":5:{s:5:\\\"class\\\";s:31:\\\"App\\\\Models\\\\EmployeeHabilitation\\\";s:2:\\\"id\\\";i:15;s:9:\\\"relations\\\";a:3:{i:0;s:8:\\\"employee\\\";i:1;s:12:\\\"habilitation\\\";i:2;s:18:\\\"habilitation.volet\\\";}s:10:\\\"connection\\\";s:5:\\\"mysql\\\";s:15:\\\"collectionClass\\\";N;}s:10:\\\"joursAvant\\\";i:0;s:2:\\\"to\\\";a:1:{i:0;a:2:{s:4:\\\"name\\\";N;s:7:\\\"address\\\";s:18:\\\"m.rachid@holcim.ma\\\";}}s:6:\\\"mailer\\\";s:4:\\\"smtp\\\";}s:5:\\\"tries\\\";N;s:7:\\\"timeout\\\";N;s:13:\\\"maxExceptions\\\";N;s:17:\\\"shouldBeEncrypted\\\";b:0;s:10:\\\"connection\\\";N;s:5:\\\"queue\\\";N;s:12:\\\"messageGroup\\\";N;s:12:\\\"deduplicator\\\";N;s:5:\\\"delay\\\";N;s:11:\\\"afterCommit\\\";N;s:10:\\\"middleware\\\";a:0:{}s:7:\\\"chained\\\";a:0:{}s:15:\\\"chainConnection\\\";N;s:10:\\\"chainQueue\\\";N;s:19:\\\"chainCatchCallbacks\\\";N;s:3:\\\"job\\\";N;}\",\"batchId\":null},\"createdAt\":1773226049,\"delay\":null}', 0, NULL, 1773226049, 1773226049);

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `total_jobs` int(11) NOT NULL,
  `pending_jobs` int(11) NOT NULL,
  `failed_jobs` int(11) NOT NULL,
  `failed_job_ids` longtext NOT NULL,
  `options` mediumtext DEFAULT NULL,
  `cancelled_at` int(11) DEFAULT NULL,
  `created_at` int(11) NOT NULL,
  `finished_at` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000001_create_cache_table', 1),
(2, '0001_01_01_000002_create_jobs_table', 1),
(3, '2026_02_26_114022_create_departments_table', 1),
(4, '2026_02_26_114023_create_services_table', 1),
(5, '2026_02_26_114023_create_users_table', 1),
(6, '2026_02_26_114039_create_employees_table', 1),
(7, '2026_02_26_114040_add_responsable_id_to_services_table', 1),
(8, '2026_02_26_114048_create_volets_table', 1),
(9, '2026_02_26_114054_create_habilitations_table', 1),
(10, '2026_02_26_114102_create_employee_habilitations_table', 1),
(11, '2026_02_26_114111_create_documents_table', 1),
(12, '2026_02_26_114120_create_alerts_table', 1),
(13, '2026_02_26_134629_create_personal_access_tokens_table', 1),
(14, '2026_02_27_103925_fix_jours_avant_expiration_column_in_alerts_table', 1),
(15, '2026_03_03_092718_add_medical_fields_to_employee_habilitations_table', 1),
(16, '2026_03_03_092754_create_settings_table', 1),
(17, '2026_03_04_131009_add_type_societe_to_employees_table', 2),
(18, '2026_03_05_111742_change_type_duree_of_habilitations_table', 3),
(19, '2026_03_09_120502_add_email_sent_at_to_alerts_table', 4),
(20, '2026_03_10_143603_add_acknowledged_at_to_employee_habilitations_table', 5),
(21, '2026_03_11_115442_make_matricule_nullable_in_employees_table', 6),
(22, '2026_03_13_092206_user_attributes_changes', 7),
(23, '2026_03_13_093523_user_attributes_changes', 8),
(24, '2026_03_13_093640_user_attributes_changes', 9),
(25, '2026_03_13_105530_add_responsable_service', 10),
(26, '2026_03_13_110349_add_responsable_column', 11),
(27, '2026_03_27_094455_unique_doc_name', 12),
(28, '2026_03_27_132703_update_type', 13),
(29, '2026_03_30_075306_update_email_s_t', 14),
(30, '2026_03_30_081007_add_soft_delete_to_employees', 15),
(31, '2026_03_30_110959_remove_is_standard_from_habilitations', 16),
(32, '2026_03_31_075052_add_autorisation_to_habilitations', 17),
(33, '2026_04_01_102955_add_signatory_emails_to_parametres', 18),
(34, '2026_04_01_103542_add_resp_emails_to_servicess', 19),
(35, '2026_04_01_111454_add_resp_emails_to_departements', 19),
(36, '2026_04_01_130503_create_attribution_validations_table', 20),
(37, '2026_04_01_130807_add_validation_statut_to_employee_habilitations', 20),
(38, '2026_04_07_080016_create_sessions_table', 21),
(39, '2026_04_16_142019_add_archived_at_to_documents', 22),
(40, '2026_04_21_075410_remove_unnecessary_columns', 22),
(41, '2026_04_29_142726_update_documents_table_for_note_type', 23),
(42, '2026_05_19_075556_update_alerts_table_status_values', 24),
(43, '2026_05_19_112019_add_archived_at_to_documents', 25),
(44, '2026_05_20_075556_update_alerts_table_status_values', 26);

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` text NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(268, 'App\\Models\\User', 1, 'auth_token', 'c041b965109171df72e39c8d7dde59e1a3da822f8d49664d3ce0d04940b1fc66', '[\"*\"]', NULL, NULL, '2026-04-22 10:26:29', '2026-04-22 10:26:29'),
(269, 'App\\Models\\User', 3, 'auth_token', 'a7c4376c91af9ec5274b18402e95a2c0da23c5e026d9f33d99da91872e6bf702', '[\"*\"]', NULL, NULL, '2026-04-22 10:26:38', '2026-04-22 10:26:38'),
(273, 'App\\Models\\User', 2, 'auth_token', '1e98a966e690591c76b82aeba8133202263de559142c7c146d6b22675f2f8a81', '[\"*\"]', NULL, NULL, '2026-04-22 10:32:30', '2026-04-22 10:32:30'),
(400, 'App\\Models\\User', 1, 'auth_token', 'b76f561bdb75e4e6a8be4d2377802d88b1c448385efd61f3799dc60fcdec2372', '[\"*\"]', NULL, NULL, '2026-06-01 09:43:50', '2026-06-01 09:43:50'),
(401, 'App\\Models\\User', 1, 'auth_token', '115d93a83497aa9b026b5214b518774a4a99cb8b71a8d11644ddf205ce124398', '[\"*\"]', '2026-06-01 13:55:39', NULL, '2026-06-01 13:54:03', '2026-06-01 13:55:39'),
(402, 'App\\Models\\User', 3, 'auth_token', 'c82e7389a50411accbdafaa46d7bdfa2fd3cd7c747bd7b9755f67b19eb0b7e2a', '[\"*\"]', NULL, NULL, '2026-06-01 13:57:38', '2026-06-01 13:57:38'),
(403, 'App\\Models\\User', 3, 'auth_token', '3988a29bd14e93efd8c35c5b3b133db85feac4e56562b98e90f14df2aaecd62a', '[\"*\"]', '2026-06-01 14:03:15', NULL, '2026-06-01 14:00:35', '2026-06-01 14:03:15'),
(407, 'App\\Models\\User', 1, 'auth_token', 'd19a700ef6f144aa2efa635932456dde9c809a20b5e56b8f4b07a47024e1a4bc', '[\"*\"]', NULL, NULL, '2026-06-08 12:39:54', '2026-06-08 12:39:54'),
(409, 'App\\Models\\User', 1, 'auth_token', '5bde192cadcc5b2555e214367d35265eda4568998ae30d3ddc1c6990049e1494', '[\"*\"]', '2026-06-08 13:04:14', NULL, '2026-06-08 13:04:11', '2026-06-08 13:04:14'),
(410, 'App\\Models\\User', 1, 'auth_token', 'd47822713f9bca342013353452914f9c48f7a358e2dbe0fa9fbcd8d5eef41f8a', '[\"*\"]', '2026-06-08 13:04:18', NULL, '2026-06-08 13:04:16', '2026-06-08 13:04:18'),
(411, 'App\\Models\\User', 1, 'auth_token', 'a6666b8447486adc8552c5f4ac4c98379eacbbef34db89224b22e714536c8f16', '[\"*\"]', '2026-06-08 13:04:22', NULL, '2026-06-08 13:04:20', '2026-06-08 13:04:22'),
(412, 'App\\Models\\User', 1, 'auth_token', '1ed461aa453d43146441f22d616356e601201c72c1f5d392ec4f1ada468c9e12', '[\"*\"]', '2026-06-08 13:04:25', NULL, '2026-06-08 13:04:23', '2026-06-08 13:04:25'),
(413, 'App\\Models\\User', 1, 'auth_token', '0ebaee8f0e30d38e3f373e8cf3175f7101bc034ae6122138b5670f5793a39329', '[\"*\"]', '2026-06-08 13:04:29', NULL, '2026-06-08 13:04:27', '2026-06-08 13:04:29'),
(414, 'App\\Models\\User', 1, 'auth_token', '21650556efae8041365852b0ce3f8f2ed149f585139d0d1508efba08909afc10', '[\"*\"]', '2026-06-08 13:04:32', NULL, '2026-06-08 13:04:31', '2026-06-08 13:04:32'),
(415, 'App\\Models\\User', 1, 'auth_token', 'e3efb81639479f20841cef2fd073ac4709c73b137a99d3f195396d2bd8e9d4a5', '[\"*\"]', '2026-06-08 13:04:36', NULL, '2026-06-08 13:04:34', '2026-06-08 13:04:36'),
(416, 'App\\Models\\User', 1, 'auth_token', '8437049ccdb9b66096f26ca852597bf3b792bc0a9be3b3f8d84868c10796b2f9', '[\"*\"]', '2026-06-08 13:04:40', NULL, '2026-06-08 13:04:38', '2026-06-08 13:04:40'),
(417, 'App\\Models\\User', 1, 'auth_token', '814d717accb215b68bacfa4ad9ca7d4040aa1cb54aa8eba84a4a0fcd5563c5ca', '[\"*\"]', '2026-06-08 13:04:44', NULL, '2026-06-08 13:04:42', '2026-06-08 13:04:44'),
(418, 'App\\Models\\User', 1, 'auth_token', '3ceb3852a882ff3a92816d4d242c0917a8e08e0546dc354b085ec183bf76e850', '[\"*\"]', '2026-06-08 13:04:48', NULL, '2026-06-08 13:04:46', '2026-06-08 13:04:48'),
(419, 'App\\Models\\User', 1, 'auth_token', '56c313a5737a1a6701b9361adbeccd310407e9f38596b26cc645854948a8ba3a', '[\"*\"]', '2026-06-08 13:04:52', NULL, '2026-06-08 13:04:50', '2026-06-08 13:04:52'),
(420, 'App\\Models\\User', 1, 'auth_token', '0e388ab411cbe3cc36ab734d616d87f47a93de0b44d4856f434ebc2718b19836', '[\"*\"]', '2026-06-08 13:04:56', NULL, '2026-06-08 13:04:54', '2026-06-08 13:04:56'),
(421, 'App\\Models\\User', 1, 'auth_token', '6e2e63199b3f8bfe1cc4554d9126cafcd0968f1333a3526120a2be9a6212be56', '[\"*\"]', '2026-06-08 13:05:00', NULL, '2026-06-08 13:04:58', '2026-06-08 13:05:00'),
(422, 'App\\Models\\User', 1, 'auth_token', '5fe979978d83094fa20847fc479d843971d192c2d8962a870fb2560d7ca1bece', '[\"*\"]', '2026-06-08 13:05:03', NULL, '2026-06-08 13:05:01', '2026-06-08 13:05:03'),
(423, 'App\\Models\\User', 1, 'auth_token', 'd909dfb47ba092727d40fddf892c29fa0aab3a425089a441cae27fd602accdee', '[\"*\"]', '2026-06-08 13:05:07', NULL, '2026-06-08 13:05:05', '2026-06-08 13:05:07'),
(424, 'App\\Models\\User', 1, 'auth_token', '74042a7e3997f710e04ee5b78076f00331d79f688d7477d81cd7e532858c129d', '[\"*\"]', '2026-06-08 13:05:11', NULL, '2026-06-08 13:05:09', '2026-06-08 13:05:11'),
(425, 'App\\Models\\User', 1, 'auth_token', 'caea916549e851c2183dfbdfa6b263fb3d80ae718d82437707cda93a366810bb', '[\"*\"]', '2026-06-08 13:05:15', NULL, '2026-06-08 13:05:13', '2026-06-08 13:05:15'),
(426, 'App\\Models\\User', 1, 'auth_token', '33c086e55d5c6717de6a1e56ae6b1fd474c0ba64159f4ffe20ca06aa51b7e2f9', '[\"*\"]', '2026-06-08 13:05:19', NULL, '2026-06-08 13:05:17', '2026-06-08 13:05:19'),
(427, 'App\\Models\\User', 1, 'auth_token', 'ab34af3b11cb7a3d143d228dd929bf04800899aefc63709b4d8e695027d3427b', '[\"*\"]', '2026-06-08 13:05:23', NULL, '2026-06-08 13:05:21', '2026-06-08 13:05:23'),
(428, 'App\\Models\\User', 1, 'auth_token', 'aed9723dfb17f2cca5eb0ac123bd53dfb2fc248d930512e16c676d415a996b01', '[\"*\"]', '2026-06-08 13:05:27', NULL, '2026-06-08 13:05:25', '2026-06-08 13:05:27'),
(429, 'App\\Models\\User', 1, 'auth_token', 'b1a58a65e73543d8d0edeb157d6be5267725661afa7c092c93eba25aeab11da7', '[\"*\"]', '2026-06-08 13:05:31', NULL, '2026-06-08 13:05:29', '2026-06-08 13:05:31'),
(430, 'App\\Models\\User', 1, 'auth_token', '74f3c0f43585b1817a9ac6e6a8a196d1f3949567a89a602ddcefdfdd00e20049', '[\"*\"]', '2026-06-08 13:05:35', NULL, '2026-06-08 13:05:33', '2026-06-08 13:05:35'),
(431, 'App\\Models\\User', 1, 'auth_token', '2f46f0fd2754f73d35788f0e6be09563b7403a698e3acf06c5b980cd3ac7c994', '[\"*\"]', '2026-06-08 13:05:39', NULL, '2026-06-08 13:05:37', '2026-06-08 13:05:39'),
(432, 'App\\Models\\User', 1, 'auth_token', '24289880d97f33e8a3ed69875502998ca98190fcbe9947f8492a0da4efd0029e', '[\"*\"]', '2026-06-08 13:05:43', NULL, '2026-06-08 13:05:41', '2026-06-08 13:05:43'),
(433, 'App\\Models\\User', 1, 'auth_token', '4c002fb1fd69f01321f896b475d29a9dcf898feb2e38ec6a05f96e0174a5f76e', '[\"*\"]', '2026-06-08 13:05:47', NULL, '2026-06-08 13:05:45', '2026-06-08 13:05:47'),
(434, 'App\\Models\\User', 1, 'auth_token', '8922a25f47d448dc93f5bd6210b53c4effe1359824ce83a041264d4c4f915c03', '[\"*\"]', '2026-06-08 13:05:51', NULL, '2026-06-08 13:05:49', '2026-06-08 13:05:51'),
(435, 'App\\Models\\User', 1, 'auth_token', 'a1d37f8a02006686f7817eb475b15a19a26e9b01fc72aa5832355aa3e73fa0aa', '[\"*\"]', '2026-06-08 13:05:55', NULL, '2026-06-08 13:05:53', '2026-06-08 13:05:55'),
(436, 'App\\Models\\User', 1, 'auth_token', '865c0da6e8a10e610f25b99d57f3f75db437b091b8ab8fed46f2e6f9f9203926', '[\"*\"]', '2026-06-08 13:05:59', NULL, '2026-06-08 13:05:56', '2026-06-08 13:05:59'),
(437, 'App\\Models\\User', 1, 'auth_token', '049ad9b39eb2160675c572e1cca5a1efc989758580c302e4eefbb37da4f13434', '[\"*\"]', '2026-06-08 13:06:02', NULL, '2026-06-08 13:06:00', '2026-06-08 13:06:02'),
(438, 'App\\Models\\User', 1, 'auth_token', '3c046d802aed612a7a1978d1fc2760cc32ac7a64b0ade1d6fba6e28e2f485788', '[\"*\"]', '2026-06-08 13:06:06', NULL, '2026-06-08 13:06:04', '2026-06-08 13:06:06'),
(439, 'App\\Models\\User', 1, 'auth_token', '4a0285af170b3952f0c1a2f64e8b5270e21c2c9ed9767ad8bc186bfb14db80da', '[\"*\"]', '2026-06-08 13:06:10', NULL, '2026-06-08 13:06:08', '2026-06-08 13:06:10'),
(440, 'App\\Models\\User', 1, 'auth_token', '66e526a4a2c7ed5f3a5b59f2c3ecf6fff6e9c8f21c6968cdb1fe3db2114a60ef', '[\"*\"]', '2026-06-08 13:06:14', NULL, '2026-06-08 13:06:12', '2026-06-08 13:06:14'),
(441, 'App\\Models\\User', 1, 'auth_token', '9e081f7368e58bdd99a3e1c7d43a63806baaaaeb00e4afc2297497f3c6f7440d', '[\"*\"]', '2026-06-08 13:06:18', NULL, '2026-06-08 13:06:16', '2026-06-08 13:06:18'),
(442, 'App\\Models\\User', 1, 'auth_token', 'b6eaf01a5db4bc6d3875bb0621df720d0511bcc9724a003a755d008cba8b4308', '[\"*\"]', '2026-06-08 13:06:22', NULL, '2026-06-08 13:06:20', '2026-06-08 13:06:22'),
(443, 'App\\Models\\User', 1, 'auth_token', 'ca21f55f0173cafdb97cf392992b09797157477bb4e9bfe15b0c09511552625d', '[\"*\"]', '2026-06-08 13:06:26', NULL, '2026-06-08 13:06:24', '2026-06-08 13:06:26'),
(444, 'App\\Models\\User', 1, 'auth_token', '9e6609e52c3f07d11146e0e6e55028293f7aaa4eeb3a6390ff68d3bf3126ca3f', '[\"*\"]', '2026-06-08 13:06:30', NULL, '2026-06-08 13:06:28', '2026-06-08 13:06:30'),
(445, 'App\\Models\\User', 1, 'auth_token', '3b05acce7ca96c5ec6c54891d7e1fa2d999184de1b5724d0c683480b1403f0ac', '[\"*\"]', '2026-06-08 13:06:34', NULL, '2026-06-08 13:06:32', '2026-06-08 13:06:34'),
(446, 'App\\Models\\User', 1, 'auth_token', '98c3a0be32ab6edf8ca76584153bdd387a651e7c241521ec0a774aa8e41cc496', '[\"*\"]', '2026-06-08 13:06:38', NULL, '2026-06-08 13:06:36', '2026-06-08 13:06:38'),
(447, 'App\\Models\\User', 1, 'auth_token', 'ac56a5978f550ef520d6460449749c9251af79cc4f6e7d5e7519192f368a423f', '[\"*\"]', '2026-06-08 13:06:42', NULL, '2026-06-08 13:06:40', '2026-06-08 13:06:42'),
(448, 'App\\Models\\User', 1, 'auth_token', '2ba10b7560e721973c4bea53d70d400920891365e10707e1939b445628f54883', '[\"*\"]', '2026-06-08 13:06:46', NULL, '2026-06-08 13:06:44', '2026-06-08 13:06:46'),
(449, 'App\\Models\\User', 1, 'auth_token', '39469c1f5379c17dbb21f677da3dc11a0a2d268ad1d5efaeb1a1fd0bde32cd6e', '[\"*\"]', '2026-06-08 13:06:49', NULL, '2026-06-08 13:06:47', '2026-06-08 13:06:49'),
(450, 'App\\Models\\User', 1, 'auth_token', '34746ee70b041a4c8332d8300cd901c3c0448e91a1d7934e12d51c058045540c', '[\"*\"]', '2026-06-08 13:06:53', NULL, '2026-06-08 13:06:51', '2026-06-08 13:06:53'),
(451, 'App\\Models\\User', 1, 'auth_token', 'a6c811378b79ac9ac8565c7c3053f8cc30a735cefbbe4966f76341c248bd4204', '[\"*\"]', '2026-06-08 13:06:57', NULL, '2026-06-08 13:06:55', '2026-06-08 13:06:57'),
(452, 'App\\Models\\User', 1, 'auth_token', '425e2a35c4568bf04de85b1403be0169b9f98376ee754a0989b5f594d80a8d70', '[\"*\"]', '2026-06-08 13:07:00', NULL, '2026-06-08 13:06:58', '2026-06-08 13:07:00'),
(453, 'App\\Models\\User', 1, 'auth_token', '7126ac9785a992af4882c2e6727404cafeec0a0e4f4ce066605a666dcd5ed0c0', '[\"*\"]', '2026-06-08 13:07:04', NULL, '2026-06-08 13:07:02', '2026-06-08 13:07:04'),
(454, 'App\\Models\\User', 1, 'auth_token', '753710abb2cc3a171bb200c4ec3907b17407c27603bed4e71bb464f583a048d8', '[\"*\"]', '2026-06-08 13:07:08', NULL, '2026-06-08 13:07:06', '2026-06-08 13:07:08'),
(455, 'App\\Models\\User', 1, 'auth_token', '328be13930456ad6835fa7b74fadcfd48d0bb1a9f44b310cc4f4eab9dc5d486d', '[\"*\"]', '2026-06-08 13:07:10', NULL, '2026-06-08 13:07:10', '2026-06-08 13:07:10'),
(456, 'App\\Models\\User', 1, 'auth_token', 'b632cf926b43568c3063c61ad68b10cc10a34af891d35216ab7d698cbe03796b', '[\"*\"]', '2026-06-08 13:07:37', NULL, '2026-06-08 13:07:35', '2026-06-08 13:07:37'),
(457, 'App\\Models\\User', 1, 'auth_token', 'a835ba30fd1e330bcb00d4c0835e54f0b828e1ca9b28f53bfc4adec556531357', '[\"*\"]', '2026-06-08 13:07:41', NULL, '2026-06-08 13:07:39', '2026-06-08 13:07:41'),
(458, 'App\\Models\\User', 1, 'auth_token', '60c46b06343025dc6f764af99d0f8335ca867408783b5a935d4657b5ecd47f73', '[\"*\"]', '2026-06-08 13:07:45', NULL, '2026-06-08 13:07:43', '2026-06-08 13:07:45'),
(459, 'App\\Models\\User', 1, 'auth_token', '8bef45ed83ea1d00a12e0c905bca2a6b4cd023e696c9ff9dbf124a89c53567a8', '[\"*\"]', '2026-06-08 13:07:49', NULL, '2026-06-08 13:07:47', '2026-06-08 13:07:49'),
(460, 'App\\Models\\User', 1, 'auth_token', '8df8e1802f9550d3697a3af2509a3a9bcd64672ed402084e0855cb401b2ca3b6', '[\"*\"]', '2026-06-08 13:07:53', NULL, '2026-06-08 13:07:51', '2026-06-08 13:07:53'),
(461, 'App\\Models\\User', 1, 'auth_token', '9590fa3e93a532a28d1db230f611c62e6d9739bdeac6bfa8249900512a47f597', '[\"*\"]', '2026-06-08 13:07:57', NULL, '2026-06-08 13:07:55', '2026-06-08 13:07:57'),
(462, 'App\\Models\\User', 1, 'auth_token', 'b1a47b68959fc5cded6b4489d2f06c244137aceb0e1b072cf8f7bf9adc0241a4', '[\"*\"]', '2026-06-08 13:08:00', NULL, '2026-06-08 13:07:58', '2026-06-08 13:08:00'),
(463, 'App\\Models\\User', 1, 'auth_token', '5fb372b99ace2408022fede8cfe6dd0387eb0183649ba2d51e2595d90b3b9dde', '[\"*\"]', '2026-06-08 13:08:04', NULL, '2026-06-08 13:08:02', '2026-06-08 13:08:04'),
(464, 'App\\Models\\User', 1, 'auth_token', '41998ade6b7a4ba4c272636c8b8e96549b5c69a0b82baa6775a40a4860c4e499', '[\"*\"]', '2026-06-08 13:08:07', NULL, '2026-06-08 13:08:05', '2026-06-08 13:08:07'),
(465, 'App\\Models\\User', 1, 'auth_token', '347fec459ea253de47c2a359ac0c49274f3d2024493ab4710f17c85594a8ce2c', '[\"*\"]', '2026-06-08 13:08:11', NULL, '2026-06-08 13:08:09', '2026-06-08 13:08:11'),
(466, 'App\\Models\\User', 1, 'auth_token', '70783e117735eb6063fe1099871c885c35611bc1d09e2e5604a1a19b93b5d937', '[\"*\"]', '2026-06-08 13:08:15', NULL, '2026-06-08 13:08:13', '2026-06-08 13:08:15'),
(467, 'App\\Models\\User', 1, 'auth_token', '5fb82967162c848b72e3340bdf1b72e01607a4cbac627fccaa1bbdb7ffe8c0d3', '[\"*\"]', '2026-06-08 13:08:18', NULL, '2026-06-08 13:08:16', '2026-06-08 13:08:18'),
(468, 'App\\Models\\User', 1, 'auth_token', '04e6e3dfcebf8873900a96f8383d91896732d10844e3079a3ab4c6f0f5855865', '[\"*\"]', '2026-06-08 13:08:22', NULL, '2026-06-08 13:08:20', '2026-06-08 13:08:22'),
(469, 'App\\Models\\User', 1, 'auth_token', '29d49ebb0df0c816c003feb44f8952a15602e6aa759a88f7672b43682f044dac', '[\"*\"]', '2026-06-08 13:08:26', NULL, '2026-06-08 13:08:24', '2026-06-08 13:08:26'),
(470, 'App\\Models\\User', 1, 'auth_token', '52b07f9e805f913931a0e461ccb3c452a5ca27bcf832580564d0da9dbd3c108c', '[\"*\"]', '2026-06-08 13:08:30', NULL, '2026-06-08 13:08:27', '2026-06-08 13:08:30'),
(471, 'App\\Models\\User', 1, 'auth_token', 'c2e2801172da2b1b8f97e7d8fd441448cb45de3a9478719b1969a3d0f9a107f8', '[\"*\"]', '2026-06-08 13:08:33', NULL, '2026-06-08 13:08:31', '2026-06-08 13:08:33'),
(472, 'App\\Models\\User', 1, 'auth_token', '61f41173c67559d9c6c358bae6809e01e668d4d8eedba61dfce0ded5a7184a1a', '[\"*\"]', '2026-06-08 13:08:36', NULL, '2026-06-08 13:08:35', '2026-06-08 13:08:36'),
(473, 'App\\Models\\User', 1, 'auth_token', 'b9a543b172ee388d58117c93ec8aa910a4b2a859b92382aa8a40eeb718e2958a', '[\"*\"]', '2026-06-08 13:08:40', NULL, '2026-06-08 13:08:38', '2026-06-08 13:08:40'),
(474, 'App\\Models\\User', 1, 'auth_token', '5adb196823ab71967e113979562f474aebcfd25a02c7533264a21f2e24440ee2', '[\"*\"]', '2026-06-08 13:08:43', NULL, '2026-06-08 13:08:41', '2026-06-08 13:08:43'),
(475, 'App\\Models\\User', 1, 'auth_token', 'bf82eaed6c8d18047c333984a860183d10bce8c6f181f5e5e9bed068b6edf9f5', '[\"*\"]', '2026-06-08 13:08:48', NULL, '2026-06-08 13:08:45', '2026-06-08 13:08:48'),
(476, 'App\\Models\\User', 1, 'auth_token', 'b32b11c8c9eb467b68f9a9606e35a7184aa8f7bcff9d0700b2b4c8c7b9d88acd', '[\"*\"]', '2026-06-08 13:08:51', NULL, '2026-06-08 13:08:49', '2026-06-08 13:08:51'),
(477, 'App\\Models\\User', 1, 'auth_token', 'f024be642c3b7ff15fa93d785dec52287b7ad73877680158f9a29c70876aacd4', '[\"*\"]', '2026-06-08 13:08:55', NULL, '2026-06-08 13:08:53', '2026-06-08 13:08:55'),
(478, 'App\\Models\\User', 1, 'auth_token', '63bb4f3f6d064f9e26eecf2841798c99092c8faf5da9c1dc30bfba6a910bd2ca', '[\"*\"]', '2026-06-08 13:08:58', NULL, '2026-06-08 13:08:56', '2026-06-08 13:08:58'),
(479, 'App\\Models\\User', 1, 'auth_token', '556f2064ac0ae9fd7d36f6f8383ecf2a6fabd3b88db22da5e7e2d0044e932601', '[\"*\"]', '2026-06-08 13:09:02', NULL, '2026-06-08 13:09:00', '2026-06-08 13:09:02'),
(480, 'App\\Models\\User', 1, 'auth_token', '858677912dab5cfebb49e44ddcf8bae6c914fe14e6a0874449e4164fa73d4018', '[\"*\"]', '2026-06-08 13:09:05', NULL, '2026-06-08 13:09:03', '2026-06-08 13:09:05'),
(481, 'App\\Models\\User', 1, 'auth_token', '869717c79b13cdc0c99b3106822574e2323de971d32d5a3961f2249cebd2c60b', '[\"*\"]', '2026-06-08 13:09:08', NULL, '2026-06-08 13:09:07', '2026-06-08 13:09:08'),
(482, 'App\\Models\\User', 1, 'auth_token', '2f42af2c5ef44f1307af5299b30dedbe997ab5468fd34368ca36f2361d8b187d', '[\"*\"]', '2026-06-08 13:09:12', NULL, '2026-06-08 13:09:10', '2026-06-08 13:09:12'),
(483, 'App\\Models\\User', 1, 'auth_token', 'c2db688867236d6fc1eee5623e13674a2354569fbf3c1e65a9c07194bb83716a', '[\"*\"]', '2026-06-08 13:09:16', NULL, '2026-06-08 13:09:14', '2026-06-08 13:09:16'),
(484, 'App\\Models\\User', 1, 'auth_token', 'e0d61639828006dbc3cab8f46ae99fba9bfe60fc65d3fd1abfc9687d3e0f8c4e', '[\"*\"]', '2026-06-08 13:09:19', NULL, '2026-06-08 13:09:17', '2026-06-08 13:09:19'),
(485, 'App\\Models\\User', 1, 'auth_token', '111376312bebc565952874711ecc0105a23445718ea3c249ee7fbfb116dfb9f2', '[\"*\"]', '2026-06-08 13:09:23', NULL, '2026-06-08 13:09:21', '2026-06-08 13:09:23'),
(486, 'App\\Models\\User', 1, 'auth_token', 'ff3709ac65232156da1bab5cf7e1ee0a5d015018f3463d4b4b907cd1f5cab593', '[\"*\"]', '2026-06-08 13:09:26', NULL, '2026-06-08 13:09:24', '2026-06-08 13:09:26'),
(487, 'App\\Models\\User', 1, 'auth_token', 'ea9a939fe9aceb5956a63e26d2573ffb915376a3ea3889311d97eb43a043b326', '[\"*\"]', '2026-06-08 13:09:30', NULL, '2026-06-08 13:09:28', '2026-06-08 13:09:30'),
(488, 'App\\Models\\User', 1, 'auth_token', 'aa05c73b5325ba04da42aa5a0a2a315c6fc6643ee098120bcba1fcd806dfb4f6', '[\"*\"]', '2026-06-08 13:09:34', NULL, '2026-06-08 13:09:32', '2026-06-08 13:09:34'),
(489, 'App\\Models\\User', 1, 'auth_token', '1b23164629bc50bed368606b39e010534cc4d9bb052a42831865408a65a29a3f', '[\"*\"]', '2026-06-08 13:09:38', NULL, '2026-06-08 13:09:36', '2026-06-08 13:09:38'),
(490, 'App\\Models\\User', 1, 'auth_token', '6b7893c57596f973d4304d2d0c50b4b72546dbaddf08220422a3a62be043536d', '[\"*\"]', '2026-06-08 13:09:42', NULL, '2026-06-08 13:09:40', '2026-06-08 13:09:42'),
(491, 'App\\Models\\User', 1, 'auth_token', '04bd2bb279e9c1a4fee276ce295db9ac27dbeb49fe2ea354d553b44a86fdc4cc', '[\"*\"]', '2026-06-08 13:09:46', NULL, '2026-06-08 13:09:44', '2026-06-08 13:09:46'),
(492, 'App\\Models\\User', 1, 'auth_token', '3bd500137f2b914328e324a58b68ff63d0b09613d88a447df070fb566dbb3e17', '[\"*\"]', '2026-06-08 13:09:50', NULL, '2026-06-08 13:09:48', '2026-06-08 13:09:50'),
(493, 'App\\Models\\User', 1, 'auth_token', '20134fbedbfb91e30cf7d897614580b1d9f1a480ca1064c230da9a8e83d6d593', '[\"*\"]', '2026-06-08 13:09:54', NULL, '2026-06-08 13:09:51', '2026-06-08 13:09:54'),
(494, 'App\\Models\\User', 1, 'auth_token', '936c31284c275841aa4c418fd9a03355b608a1cf0cf8be48be9f610b790f47eb', '[\"*\"]', '2026-06-08 13:09:57', NULL, '2026-06-08 13:09:55', '2026-06-08 13:09:57'),
(495, 'App\\Models\\User', 1, 'auth_token', '7b50e929f83e9039111f72fc1b38dcf37bc610effa68ceb04471290d9002b4fd', '[\"*\"]', '2026-06-08 13:10:01', NULL, '2026-06-08 13:09:59', '2026-06-08 13:10:01'),
(496, 'App\\Models\\User', 1, 'auth_token', '7d9c838595337bd2455ee10d0b5e8e601b6da8ce7ebb8404e0d4a14cc08b7dda', '[\"*\"]', '2026-06-08 13:10:05', NULL, '2026-06-08 13:10:03', '2026-06-08 13:10:05'),
(497, 'App\\Models\\User', 1, 'auth_token', '91374056b0ea6613992d427c9ac24e94884ebd7d2d42c870933783bde23e393a', '[\"*\"]', '2026-06-08 13:10:08', NULL, '2026-06-08 13:10:06', '2026-06-08 13:10:08'),
(498, 'App\\Models\\User', 1, 'auth_token', '060d93dc6568f0bc063902e6e34880ad6e9416da24f5a1647ba0e2589c614683', '[\"*\"]', '2026-06-08 13:10:12', NULL, '2026-06-08 13:10:10', '2026-06-08 13:10:12'),
(499, 'App\\Models\\User', 1, 'auth_token', '4efc9393dfc675525be325a4d56bc62d16a2eb2ab289e64682189cf876720b78', '[\"*\"]', '2026-06-08 13:10:17', NULL, '2026-06-08 13:10:14', '2026-06-08 13:10:17'),
(500, 'App\\Models\\User', 1, 'auth_token', '217158576c8e208e92e584607bd01cc08b56c07d14f455dcee33730b415b9820', '[\"*\"]', '2026-06-08 13:10:20', NULL, '2026-06-08 13:10:18', '2026-06-08 13:10:20'),
(501, 'App\\Models\\User', 1, 'auth_token', 'e37d1b046a4e4d431eea1a42b94a77b564c837ae4b4245ee08aeb5a8ea88d06a', '[\"*\"]', '2026-06-08 13:10:24', NULL, '2026-06-08 13:10:22', '2026-06-08 13:10:24'),
(502, 'App\\Models\\User', 1, 'auth_token', '7393bca2609afe5c94dcddb784c9ea1910a17a42f66d4cff2e01b40e5a8c1d5a', '[\"*\"]', '2026-06-08 13:10:28', NULL, '2026-06-08 13:10:26', '2026-06-08 13:10:28'),
(503, 'App\\Models\\User', 1, 'auth_token', '2bd7205880c65eb97447ad2ee01d22489642084f9adee45e8a1321dab7da1aa2', '[\"*\"]', '2026-06-08 13:10:32', NULL, '2026-06-08 13:10:30', '2026-06-08 13:10:32'),
(504, 'App\\Models\\User', 1, 'auth_token', '7254ed6d1187bb8c7285fcf01647e81744a5d0848af3c242669f75770cac1808', '[\"*\"]', '2026-06-08 13:10:36', NULL, '2026-06-08 13:10:34', '2026-06-08 13:10:36'),
(505, 'App\\Models\\User', 1, 'auth_token', '58a712e104b953c5d8e9ee50aa700940b5f9a021902e99d0b96acd3157425e59', '[\"*\"]', '2026-06-08 13:10:40', NULL, '2026-06-08 13:10:38', '2026-06-08 13:10:40'),
(506, 'App\\Models\\User', 1, 'auth_token', '9a165661398c133398a05b22b75de95c0bd483f6ae09177307b96463182ee170', '[\"*\"]', '2026-06-08 13:14:27', NULL, '2026-06-08 13:14:25', '2026-06-08 13:14:27'),
(507, 'App\\Models\\User', 1, 'auth_token', 'ef86be94b802e7fc54396d6cfcdaee5a34cd50841c03e39e86dff6245169f867', '[\"*\"]', '2026-06-08 13:14:31', NULL, '2026-06-08 13:14:29', '2026-06-08 13:14:31'),
(508, 'App\\Models\\User', 1, 'auth_token', '628923afd55cbd7fb85f99413491b862c2de9ec5783bdfcca8bf9d1af7dcc516', '[\"*\"]', '2026-06-08 13:14:36', NULL, '2026-06-08 13:14:33', '2026-06-08 13:14:36'),
(509, 'App\\Models\\User', 1, 'auth_token', 'd23f82a45d3dd1a53c2542cc23f8a7adbe6012cb89ac41805da9751e0d520a09', '[\"*\"]', '2026-06-08 13:14:40', NULL, '2026-06-08 13:14:37', '2026-06-08 13:14:40'),
(510, 'App\\Models\\User', 1, 'auth_token', '94e34cbc6a3bcc61fe177d0745045025113a0eeb17aa4950650f5cdaac47da36', '[\"*\"]', '2026-06-08 13:14:44', NULL, '2026-06-08 13:14:42', '2026-06-08 13:14:44'),
(511, 'App\\Models\\User', 1, 'auth_token', '0a2a248844bbecbe050fea94da3e82c5f81fa665b6451dc3bcab033b8dfb68ca', '[\"*\"]', '2026-06-08 13:14:48', NULL, '2026-06-08 13:14:46', '2026-06-08 13:14:48'),
(512, 'App\\Models\\User', 1, 'auth_token', '5f270c201157c849c9d3d618bab72d8d1dad01b7ef4adbf04014d8beb2214a5f', '[\"*\"]', '2026-06-08 13:14:53', NULL, '2026-06-08 13:14:50', '2026-06-08 13:14:53'),
(513, 'App\\Models\\User', 1, 'auth_token', '7273721e1a73dcc44fb65f74d4992d068a9c50932a34484d67018e7dc125ed86', '[\"*\"]', '2026-06-08 13:14:57', NULL, '2026-06-08 13:14:54', '2026-06-08 13:14:57'),
(514, 'App\\Models\\User', 1, 'auth_token', '1247df49d8ec5feeb8fc9587d7622848b2f28f3521a0988f40b95950d1bf5979', '[\"*\"]', '2026-06-08 13:15:01', NULL, '2026-06-08 13:14:59', '2026-06-08 13:15:01'),
(515, 'App\\Models\\User', 1, 'auth_token', 'a763859a11082b6941e6c849e390de9e2834754924b8da05a18ac9adbe2a764a', '[\"*\"]', '2026-06-08 13:15:05', NULL, '2026-06-08 13:15:03', '2026-06-08 13:15:05'),
(516, 'App\\Models\\User', 1, 'auth_token', 'abae51e275063c5d7227ebf47ac9ac4cc05803f152e0172a3d7693b85f35d369', '[\"*\"]', '2026-06-08 13:15:09', NULL, '2026-06-08 13:15:07', '2026-06-08 13:15:09'),
(517, 'App\\Models\\User', 1, 'auth_token', '3bfbbfe0ce3c689bfd80cbf38ba911dd9d0602fb41bb9888a8946d8362da7331', '[\"*\"]', '2026-06-08 13:15:13', NULL, '2026-06-08 13:15:11', '2026-06-08 13:15:13'),
(518, 'App\\Models\\User', 1, 'auth_token', '585e00fc74a7628ecb064d1541eb56458b738aba02ef06b2f57fbbdc2ebdf550', '[\"*\"]', '2026-06-08 13:15:18', NULL, '2026-06-08 13:15:15', '2026-06-08 13:15:18'),
(519, 'App\\Models\\User', 1, 'auth_token', '66d50b4e7cffc37f7efa82201d74dd4880551718356decdeedf64546ff1f1d38', '[\"*\"]', '2026-06-08 13:15:22', NULL, '2026-06-08 13:15:20', '2026-06-08 13:15:22'),
(520, 'App\\Models\\User', 1, 'auth_token', '0f7980296997b1a8f0018db218828386080eb0aa98084fd883040611f732c116', '[\"*\"]', '2026-06-08 13:15:26', NULL, '2026-06-08 13:15:24', '2026-06-08 13:15:26'),
(521, 'App\\Models\\User', 1, 'auth_token', '43727e1cc5d5a1df912df4268c0f3386af8d721def0e8ff83294ec6e0a93fbf6', '[\"*\"]', '2026-06-08 13:15:30', NULL, '2026-06-08 13:15:28', '2026-06-08 13:15:30'),
(522, 'App\\Models\\User', 1, 'auth_token', '4237240fdc0b6441376cbcbac17e16773c7da2bbb2bc723afd625297452750d5', '[\"*\"]', '2026-06-08 13:15:34', NULL, '2026-06-08 13:15:32', '2026-06-08 13:15:34'),
(523, 'App\\Models\\User', 1, 'auth_token', '267b291e21d1292a28f3a3062386f61b90393334d7dcff810e73ede832dfa394', '[\"*\"]', '2026-06-08 13:15:38', NULL, '2026-06-08 13:15:36', '2026-06-08 13:15:38'),
(524, 'App\\Models\\User', 1, 'auth_token', '3d9276f8e03282878a2b6e34b66c995d04f96898937e963c2549ddb598e655ee', '[\"*\"]', '2026-06-08 13:15:43', NULL, '2026-06-08 13:15:40', '2026-06-08 13:15:43'),
(525, 'App\\Models\\User', 1, 'auth_token', 'dc40c501b9c61b2e5f25b0506f7131a967475c7ef8ab2905828e083b797fc3a3', '[\"*\"]', '2026-06-08 13:15:47', NULL, '2026-06-08 13:15:45', '2026-06-08 13:15:47'),
(526, 'App\\Models\\User', 1, 'auth_token', '6ae7492bfdd56309e1280f0d34687c4bbab5eb92718793d0d8b9356d64027117', '[\"*\"]', '2026-06-08 13:15:51', NULL, '2026-06-08 13:15:49', '2026-06-08 13:15:51'),
(527, 'App\\Models\\User', 1, 'auth_token', 'ab935b875ad3a631dcdbbd0b657268d05bdd74ad91a8ba0eefefc634de9b8e3a', '[\"*\"]', '2026-06-08 13:15:56', NULL, '2026-06-08 13:15:53', '2026-06-08 13:15:56'),
(528, 'App\\Models\\User', 1, 'auth_token', '36c615e99a6cb2c5629b31032515a4a7be0a6f2c8fd57a683c7103bbe74c43a0', '[\"*\"]', NULL, NULL, '2026-06-08 13:15:58', '2026-06-08 13:15:58'),
(529, 'App\\Models\\User', 1, 'auth_token', '1efd2a66538da4664322ff1e8e5eb3d7ee9cd940dbcd8257ffcbcd4ef13522fe', '[\"*\"]', '2026-06-08 13:16:30', NULL, '2026-06-08 13:16:28', '2026-06-08 13:16:30'),
(530, 'App\\Models\\User', 1, 'auth_token', '9e914513726be1d573fb3559d3695aec774d1bac78a673ed6c206d1a8385555e', '[\"*\"]', '2026-06-08 13:16:34', NULL, '2026-06-08 13:16:32', '2026-06-08 13:16:34'),
(531, 'App\\Models\\User', 1, 'auth_token', '16499aa85c31e4f7f9c4cb49daf4f7f802e08aecc9e78a44626919a41f6cafd7', '[\"*\"]', '2026-06-08 13:16:38', NULL, '2026-06-08 13:16:36', '2026-06-08 13:16:38'),
(532, 'App\\Models\\User', 1, 'auth_token', '7ee20be438963522f96ca88c10e7483ae52c1b8a2f8d90c11901771a1afa7388', '[\"*\"]', '2026-06-08 13:16:43', NULL, '2026-06-08 13:16:40', '2026-06-08 13:16:43'),
(533, 'App\\Models\\User', 1, 'auth_token', '23e4f18abdeef760bc225130e9633a56100db45ae2cacd9a0c9ea40136d4151a', '[\"*\"]', '2026-06-08 13:16:47', NULL, '2026-06-08 13:16:44', '2026-06-08 13:16:47'),
(534, 'App\\Models\\User', 1, 'auth_token', '87bd52a61acb7def8755a51a6e78f97a92bfd773578ff80f49f3cce13d657fe4', '[\"*\"]', '2026-06-08 13:16:51', NULL, '2026-06-08 13:16:49', '2026-06-08 13:16:51'),
(535, 'App\\Models\\User', 1, 'auth_token', 'b1392aa43c3c70a5f97c974c94a57d6edf76a9ed588761e7126f9180b89dc820', '[\"*\"]', '2026-06-08 13:16:55', NULL, '2026-06-08 13:16:53', '2026-06-08 13:16:55'),
(536, 'App\\Models\\User', 1, 'auth_token', 'fcba612c491c8fc6f3f75d1bc968cbc6d98869475b4800c15c1a74bc19ceaa36', '[\"*\"]', '2026-06-08 13:17:00', NULL, '2026-06-08 13:16:57', '2026-06-08 13:17:00'),
(537, 'App\\Models\\User', 1, 'auth_token', 'e2d6814777f123d3eefcd0cf4f938c721fd8a7f2c55ca17e72eb66fe2df8cb55', '[\"*\"]', '2026-06-08 13:17:05', NULL, '2026-06-08 13:17:02', '2026-06-08 13:17:05'),
(538, 'App\\Models\\User', 1, 'auth_token', '3df98bad237a3dbf93954d151a17a187bdb7df19852ef3b7ba4e69751632397e', '[\"*\"]', '2026-06-08 13:17:09', NULL, '2026-06-08 13:17:07', '2026-06-08 13:17:09'),
(539, 'App\\Models\\User', 1, 'auth_token', 'd52227533cb14482d5df654893cb49250697e99ced7e6c807c9c766728723e65', '[\"*\"]', NULL, NULL, '2026-06-08 13:17:11', '2026-06-08 13:17:11'),
(540, 'App\\Models\\User', 1, 'auth_token', 'e725fecdca8eee4d00a60429a5a8235ea0f632298a8a7129e2a686bbd7332fbe', '[\"*\"]', '2026-06-08 13:18:12', NULL, '2026-06-08 13:18:10', '2026-06-08 13:18:12'),
(541, 'App\\Models\\User', 1, 'auth_token', 'e7eb59087455a76d712c30cb320463b6077b8f04da621b8b383ae5e8c901ba42', '[\"*\"]', '2026-06-08 13:18:17', NULL, '2026-06-08 13:18:14', '2026-06-08 13:18:17'),
(542, 'App\\Models\\User', 1, 'auth_token', '45a235b1dfc68c4a8a950ed7ced7d30b10ef901a81b3a34ce64cc59c63d025d3', '[\"*\"]', '2026-06-08 13:18:20', NULL, '2026-06-08 13:18:18', '2026-06-08 13:18:20'),
(543, 'App\\Models\\User', 1, 'auth_token', 'fb528be95071047d2268e1acd0ac7ae77674d77ce52c30e73aeb478d71bf1c03', '[\"*\"]', '2026-06-08 13:18:25', NULL, '2026-06-08 13:18:22', '2026-06-08 13:18:25'),
(544, 'App\\Models\\User', 1, 'auth_token', '15b3574131b87d5763a0b83970d52fcf13dd9f4a657b98c5ee12cbcd2f5d350d', '[\"*\"]', '2026-06-08 13:18:29', NULL, '2026-06-08 13:18:26', '2026-06-08 13:18:29'),
(545, 'App\\Models\\User', 1, 'auth_token', 'efb8f71488c906eb1f8903df83e044f0adca6525b0d9c0766ca0baaf55fd9be3', '[\"*\"]', '2026-06-08 13:18:34', NULL, '2026-06-08 13:18:31', '2026-06-08 13:18:34'),
(546, 'App\\Models\\User', 1, 'auth_token', '2413692396d0ecc77a6a0064dd0f6162e512b3c2a6c115add5aa7de429ae7c86', '[\"*\"]', '2026-06-08 13:18:38', NULL, '2026-06-08 13:18:36', '2026-06-08 13:18:38'),
(547, 'App\\Models\\User', 1, 'auth_token', '39deb30f1240d1909274fcc3254cc08035706d8e56c2d44f09227b61056a0cb6', '[\"*\"]', '2026-06-08 13:18:42', NULL, '2026-06-08 13:18:40', '2026-06-08 13:18:42'),
(548, 'App\\Models\\User', 1, 'auth_token', '3bd7997fd6eaadcba274e559f03dafbff7593172b7044cf38b3f54d86cd18b73', '[\"*\"]', '2026-06-08 13:18:46', NULL, '2026-06-08 13:18:44', '2026-06-08 13:18:46'),
(549, 'App\\Models\\User', 1, 'auth_token', 'ea48434c9c90f688c23e9a12e1e8b4ab017000331896467b885bf4a6685cd4e5', '[\"*\"]', '2026-06-08 13:18:51', NULL, '2026-06-08 13:18:48', '2026-06-08 13:18:51'),
(550, 'App\\Models\\User', 1, 'auth_token', 'ab273b83e7fbe1f6a51fee5c34776950b14b79d3b5b098f4c861d5882c3e0921', '[\"*\"]', '2026-06-08 13:18:55', NULL, '2026-06-08 13:18:52', '2026-06-08 13:18:55'),
(551, 'App\\Models\\User', 1, 'auth_token', '23a0c8ff0cd4f6f120ad7bf68c016d7c51bc1b47707f57ce5e8744c2c9db5333', '[\"*\"]', '2026-06-08 13:18:59', NULL, '2026-06-08 13:18:57', '2026-06-08 13:18:59'),
(552, 'App\\Models\\User', 1, 'auth_token', 'b65517b8eda093af8a907fe13df78f0ef3c0140f94f7d9782a6043dff022dc70', '[\"*\"]', '2026-06-08 13:19:03', NULL, '2026-06-08 13:19:01', '2026-06-08 13:19:03'),
(553, 'App\\Models\\User', 1, 'auth_token', 'bf1715e73721857442453ffe9eb8c52f957a2140427802ac14b800d2b6f6f4fb', '[\"*\"]', '2026-06-08 13:19:09', NULL, '2026-06-08 13:19:05', '2026-06-08 13:19:09'),
(554, 'App\\Models\\User', 1, 'auth_token', '74e7cf9ee787f564bd1db73153f0eb767ab6c597db66d61eaa60f3a6d856784e', '[\"*\"]', '2026-06-08 13:19:15', NULL, '2026-06-08 13:19:12', '2026-06-08 13:19:15'),
(555, 'App\\Models\\User', 1, 'auth_token', '067f84780df7fc6389f094b0bace16c09dff4e299bff5ef8cb267a6a740f5a3b', '[\"*\"]', '2026-06-08 13:19:20', NULL, '2026-06-08 13:19:17', '2026-06-08 13:19:20'),
(556, 'App\\Models\\User', 1, 'auth_token', '065055777df055533e24982d93b33a8eb7f5149412c84e86fea2c0b43d030568', '[\"*\"]', '2026-06-08 13:19:27', NULL, '2026-06-08 13:19:22', '2026-06-08 13:19:27'),
(557, 'App\\Models\\User', 1, 'auth_token', '7488e5ac81e596696df3ebc159c2fcf51051882dfb6f395e6b3e3c824628bf56', '[\"*\"]', '2026-06-08 13:19:32', NULL, '2026-06-08 13:19:29', '2026-06-08 13:19:32'),
(558, 'App\\Models\\User', 1, 'auth_token', '5903f7750c5e9b812e503c151bb0ece586f080bb65eb7d0eb2d72baec407014a', '[\"*\"]', '2026-06-08 13:19:38', NULL, '2026-06-08 13:19:35', '2026-06-08 13:19:38'),
(559, 'App\\Models\\User', 1, 'auth_token', 'c3686eae84ef093a7e325b73cdd0eaacce6d08b34bec59208c7caece02989aa7', '[\"*\"]', '2026-06-08 13:19:44', NULL, '2026-06-08 13:19:40', '2026-06-08 13:19:44'),
(560, 'App\\Models\\User', 1, 'auth_token', 'fed782828a020d428a5328a606d06c5e71415188541fe9871f33cf88e896f534', '[\"*\"]', '2026-06-08 13:19:50', NULL, '2026-06-08 13:19:47', '2026-06-08 13:19:50'),
(561, 'App\\Models\\User', 1, 'auth_token', '31c59c99abce27015b0265d1e916a88221099ea5f3b5203a1d99369104078c79', '[\"*\"]', '2026-06-08 13:19:56', NULL, '2026-06-08 13:19:53', '2026-06-08 13:19:56'),
(562, 'App\\Models\\User', 1, 'auth_token', 'cffc250ac44580993de938d71b2dcfebd37d75de7d6b483b89771127748c2c90', '[\"*\"]', '2026-06-08 13:20:02', NULL, '2026-06-08 13:19:58', '2026-06-08 13:20:02'),
(563, 'App\\Models\\User', 1, 'auth_token', '5b43f1ad8a1300d0b9a5afc6550db4166a7c7425d92a5615d2a857d6caff29c2', '[\"*\"]', '2026-06-08 13:20:07', NULL, '2026-06-08 13:20:04', '2026-06-08 13:20:07'),
(564, 'App\\Models\\User', 1, 'auth_token', '5d77499e113a35c56963736cc799f7bd6999b73332bcd3a2312c9ae1ccf85758', '[\"*\"]', '2026-06-08 13:20:13', NULL, '2026-06-08 13:20:10', '2026-06-08 13:20:13'),
(565, 'App\\Models\\User', 1, 'auth_token', '4d1cd6cc168d0a92a7b4194c72c015d264cd3ac01f84be1e64bd377b91af1f5e', '[\"*\"]', '2026-06-08 13:20:20', NULL, '2026-06-08 13:20:17', '2026-06-08 13:20:20'),
(566, 'App\\Models\\User', 1, 'auth_token', 'c8c2cf1eda5ada548131c6dc7cca7cd4315d2efbf122239ab5367982646b54aa', '[\"*\"]', '2026-06-08 13:20:26', NULL, '2026-06-08 13:20:23', '2026-06-08 13:20:26'),
(567, 'App\\Models\\User', 1, 'auth_token', 'd874655edb2a310a5824c4eb7e59890c4215eca862b078363fee68133581fa63', '[\"*\"]', '2026-06-08 13:20:32', NULL, '2026-06-08 13:20:28', '2026-06-08 13:20:32'),
(568, 'App\\Models\\User', 1, 'auth_token', '8c93c886e2d3fc42cad8a7d68025e7fe830536f3cf9a8b4559d53436eca1675f', '[\"*\"]', '2026-06-08 13:20:38', NULL, '2026-06-08 13:20:35', '2026-06-08 13:20:38'),
(569, 'App\\Models\\User', 1, 'auth_token', '45a7dda78d2db44250c91e6ebabcf83bd1336eaa622b8873d2b268c0de09ef6b', '[\"*\"]', '2026-06-08 13:20:44', NULL, '2026-06-08 13:20:41', '2026-06-08 13:20:44'),
(570, 'App\\Models\\User', 1, 'auth_token', '27d54947e9a625683b2b1b844e982f825de2d6becd5df36910ecfa0c66329acf', '[\"*\"]', '2026-06-08 13:20:51', NULL, '2026-06-08 13:20:47', '2026-06-08 13:20:51'),
(571, 'App\\Models\\User', 1, 'auth_token', 'd9145be5e9867082fbb098668c67166222590e95188e757b07c97459ebadbea5', '[\"*\"]', '2026-06-08 13:20:57', NULL, '2026-06-08 13:20:54', '2026-06-08 13:20:57'),
(572, 'App\\Models\\User', 1, 'auth_token', '8873ed2db4733a0e298b8f4dc7c18028ab451dcc08999db13216c111bcdbde99', '[\"*\"]', '2026-06-08 13:21:02', NULL, '2026-06-08 13:21:00', '2026-06-08 13:21:02'),
(573, 'App\\Models\\User', 1, 'auth_token', '0015070209942c44d8bb8baf78dca4ba1bf05753f3ff4de105be5a5ded4b3437', '[\"*\"]', '2026-06-08 13:21:07', NULL, '2026-06-08 13:21:05', '2026-06-08 13:21:07'),
(574, 'App\\Models\\User', 1, 'auth_token', '15116cccc1a2c41236af4cb3c7443ff46b4836b6822eae601eb82a328c29f2fa', '[\"*\"]', '2026-06-08 13:21:12', NULL, '2026-06-08 13:21:10', '2026-06-08 13:21:12'),
(575, 'App\\Models\\User', 1, 'auth_token', '5f0eab60576cb7657a706bc6116f1b3888b67f219c8978dfab39d6e92016613c', '[\"*\"]', '2026-06-08 13:21:16', NULL, '2026-06-08 13:21:14', '2026-06-08 13:21:16'),
(576, 'App\\Models\\User', 1, 'auth_token', '4f9a7fbd6a341678319c6f3d8559a204e9f7f2b3b60b8bd84b3f57eac3c88c75', '[\"*\"]', '2026-06-08 13:21:20', NULL, '2026-06-08 13:21:18', '2026-06-08 13:21:20'),
(577, 'App\\Models\\User', 1, 'auth_token', '2ee5c0fc34ca92003b96078589f71748c4b6fcddb1b2cb1b43fc6742ee9a2955', '[\"*\"]', '2026-06-08 13:21:24', NULL, '2026-06-08 13:21:22', '2026-06-08 13:21:24'),
(578, 'App\\Models\\User', 1, 'auth_token', 'ca556c48e3b1c7bf0bbb25226d8203068b6a321f1cc9b100213eccb7d5c55a87', '[\"*\"]', '2026-06-08 13:22:33', NULL, '2026-06-08 13:22:30', '2026-06-08 13:22:33'),
(579, 'App\\Models\\User', 1, 'auth_token', 'a7f3f6912e564f826c87f8fcefb80add27254cc3ff2ef0c2bca97417155e7c77', '[\"*\"]', '2026-06-08 13:22:37', NULL, '2026-06-08 13:22:35', '2026-06-08 13:22:37'),
(580, 'App\\Models\\User', 1, 'auth_token', '1086233fa9ec3796ed050ee21cffd3054b0ec944aafe80c264b3efe8d1802789', '[\"*\"]', '2026-06-08 13:22:41', NULL, '2026-06-08 13:22:39', '2026-06-08 13:22:41'),
(581, 'App\\Models\\User', 1, 'auth_token', 'f68f741753fea2a3f6b0dcc61b772ed502100156177399e7d0e5f4dd14d3956f', '[\"*\"]', '2026-06-08 13:22:45', NULL, '2026-06-08 13:22:43', '2026-06-08 13:22:45'),
(582, 'App\\Models\\User', 1, 'auth_token', '2dd5411b2835367ccfd15c7a2fbd95e6aa58a0ba99dd5057c338ac5d148680ce', '[\"*\"]', '2026-06-08 13:22:49', NULL, '2026-06-08 13:22:47', '2026-06-08 13:22:49'),
(583, 'App\\Models\\User', 1, 'auth_token', '3620995b3bb23708c61c0b58ea6993a54b66c3bccaf5bdbe213e551061ec958d', '[\"*\"]', '2026-06-08 13:22:54', NULL, '2026-06-08 13:22:51', '2026-06-08 13:22:54'),
(584, 'App\\Models\\User', 1, 'auth_token', '24344d74059dcd05507eb74443e4fd08da8993b1020682e3dce4b0442104d4ba', '[\"*\"]', '2026-06-08 13:22:58', NULL, '2026-06-08 13:22:56', '2026-06-08 13:22:58'),
(585, 'App\\Models\\User', 1, 'auth_token', 'e7cad2a424a8e4ecdbabc846da12373a598f92a2c3761bfdc9dc74d7767b1cbe', '[\"*\"]', '2026-06-08 13:23:02', NULL, '2026-06-08 13:23:00', '2026-06-08 13:23:02'),
(586, 'App\\Models\\User', 1, 'auth_token', 'c6eeb7569c0ff0a280b5877db4d74d61c0732ccc5c7ab417643959344d57b592', '[\"*\"]', '2026-06-08 13:23:06', NULL, '2026-06-08 13:23:04', '2026-06-08 13:23:06'),
(587, 'App\\Models\\User', 1, 'auth_token', 'ade2dd6675042bce8645cfc52128ce935d36133897bf8b576893dfede1381687', '[\"*\"]', '2026-06-08 13:23:10', NULL, '2026-06-08 13:23:08', '2026-06-08 13:23:10'),
(588, 'App\\Models\\User', 1, 'auth_token', 'd7025e6fe285afcc979bccf9ebf7af981dea6c8b60d171201737691b030bc50b', '[\"*\"]', '2026-06-08 13:23:15', NULL, '2026-06-08 13:23:12', '2026-06-08 13:23:15'),
(589, 'App\\Models\\User', 1, 'auth_token', '6638212270990f3e5b270e49d12d9112d85aa85664eef4a17c4c9bd9a242092f', '[\"*\"]', '2026-06-08 13:23:19', NULL, '2026-06-08 13:23:17', '2026-06-08 13:23:19'),
(590, 'App\\Models\\User', 1, 'auth_token', '1f699a24c1fd90322e31e31a44c585e7deb300c88ef6c48f1fa8572deed13353', '[\"*\"]', '2026-06-08 13:23:23', NULL, '2026-06-08 13:23:21', '2026-06-08 13:23:23'),
(591, 'App\\Models\\User', 1, 'auth_token', 'f3afe4a1fb9626bd0ad06cd9554a0079994e54f4807a1842bbdb4538c8dce45a', '[\"*\"]', '2026-06-08 13:23:28', NULL, '2026-06-08 13:23:26', '2026-06-08 13:23:28'),
(592, 'App\\Models\\User', 1, 'auth_token', '268cef3d22dd60b218bde0f47c1ab3227639dc6412ef329dd383f74483a8c167', '[\"*\"]', '2026-06-08 13:23:32', NULL, '2026-06-08 13:23:30', '2026-06-08 13:23:32'),
(593, 'App\\Models\\User', 1, 'auth_token', 'e3fdadebfaa63b23b0602dd63ff091e400b4252e51fccb3495f0247367973e55', '[\"*\"]', '2026-06-08 13:23:36', NULL, '2026-06-08 13:23:34', '2026-06-08 13:23:36'),
(594, 'App\\Models\\User', 1, 'auth_token', '5a8a7d3f435bf44d8efe8d1272b962ea0c8836f1eff2bad52760b29641a3222f', '[\"*\"]', '2026-06-08 13:23:41', NULL, '2026-06-08 13:23:38', '2026-06-08 13:23:41'),
(595, 'App\\Models\\User', 1, 'auth_token', 'daefb1b3301b4205428d826bcbcaaa09d8b73e745cd172bcc8d8e1edce407758', '[\"*\"]', '2026-06-08 13:23:45', NULL, '2026-06-08 13:23:43', '2026-06-08 13:23:45'),
(596, 'App\\Models\\User', 1, 'auth_token', '82d96dcb25f6d150d77c806d7b3455d494d73ac75e22e8c373c236865961d20a', '[\"*\"]', '2026-06-08 13:23:49', NULL, '2026-06-08 13:23:47', '2026-06-08 13:23:49'),
(597, 'App\\Models\\User', 1, 'auth_token', '8e0ed1cb9b3e9701a4b3f72cd6ed41e3ed5e5fa81facc4b338c3d93a58578561', '[\"*\"]', '2026-06-08 13:23:54', NULL, '2026-06-08 13:23:51', '2026-06-08 13:23:54'),
(598, 'App\\Models\\User', 1, 'auth_token', 'afdcf80d58e7321c02f441a1f336b14be6de2ef7703a281b2d5ba9d708542498', '[\"*\"]', '2026-06-08 13:24:01', NULL, '2026-06-08 13:23:57', '2026-06-08 13:24:01'),
(599, 'App\\Models\\User', 1, 'auth_token', 'a443d426fcc00eaed87bf36af21fefbf396bfb24e41717bafefb8dca4ff257c2', '[\"*\"]', '2026-06-08 13:24:06', NULL, '2026-06-08 13:24:03', '2026-06-08 13:24:06'),
(600, 'App\\Models\\User', 1, 'auth_token', '2dfbeb9598d851241a87333bbceca67ac06ed8c5cce0c4309ed7766efcf8807d', '[\"*\"]', '2026-06-08 13:24:13', NULL, '2026-06-08 13:24:09', '2026-06-08 13:24:13'),
(601, 'App\\Models\\User', 1, 'auth_token', 'ac65c6383d2d4d42c65e6ee3b8992eec3e89dd7c665ee208d9b3e057735752b6', '[\"*\"]', '2026-06-08 13:24:19', NULL, '2026-06-08 13:24:15', '2026-06-08 13:24:19'),
(602, 'App\\Models\\User', 1, 'auth_token', 'a4d54da288ea75a3a929bad1a5a2cbd90a1d9eb95bfcaf46acebabb114b904b6', '[\"*\"]', '2026-06-08 13:24:26', NULL, '2026-06-08 13:24:21', '2026-06-08 13:24:26'),
(603, 'App\\Models\\User', 1, 'auth_token', '038bd27efce9e8963cbdef26c71048b0f81d2774f1724b09d2038de4e46ff28b', '[\"*\"]', '2026-06-08 13:24:32', NULL, '2026-06-08 13:24:28', '2026-06-08 13:24:32'),
(604, 'App\\Models\\User', 1, 'auth_token', '647ac1180f4397a10ea2758efefb244430c22b4f90d90ca4ffa5d8a53dce59e1', '[\"*\"]', '2026-06-08 13:24:38', NULL, '2026-06-08 13:24:35', '2026-06-08 13:24:38'),
(605, 'App\\Models\\User', 1, 'auth_token', '315d9359c6023c195f64531a79c41a5747470d918d9c547c9d2f3b5f4d42d815', '[\"*\"]', '2026-06-08 13:24:46', NULL, '2026-06-08 13:24:42', '2026-06-08 13:24:46'),
(606, 'App\\Models\\User', 1, 'auth_token', '260df0fa13a0c0b5bb1f7a86d8defd272be8cfb02a4ecf727593dd33ba0ffa35', '[\"*\"]', '2026-06-08 13:24:52', NULL, '2026-06-08 13:24:48', '2026-06-08 13:24:52'),
(607, 'App\\Models\\User', 1, 'auth_token', 'c4688b76d69fb42611066c1c529003d1855ee62df177cf304078368c4f60d68d', '[\"*\"]', '2026-06-08 13:24:59', NULL, '2026-06-08 13:24:56', '2026-06-08 13:24:59'),
(608, 'App\\Models\\User', 1, 'auth_token', '2c14c9fbfbc11157746a31a18de4f6defd152e19e3f8251a90959b947f0af21a', '[\"*\"]', '2026-06-08 13:25:04', NULL, '2026-06-08 13:25:01', '2026-06-08 13:25:04'),
(609, 'App\\Models\\User', 1, 'auth_token', '8cbf5bcd07c6dc54569a390b6796ea4e3e7b246a92de48acf2ec0e05ddb38055', '[\"*\"]', '2026-06-08 13:25:11', NULL, '2026-06-08 13:25:08', '2026-06-08 13:25:11'),
(610, 'App\\Models\\User', 1, 'auth_token', '880bcf156e1dd2863f5e28a94996cf4dcc4079d7982fb1cbd733b5493a44a4ab', '[\"*\"]', '2026-06-08 13:25:16', NULL, '2026-06-08 13:25:13', '2026-06-08 13:25:16'),
(611, 'App\\Models\\User', 1, 'auth_token', '475ede67b7c2e65da396a8cd000f53101421cfa0ac9fe0822e50c72c0aa8b724', '[\"*\"]', '2026-06-08 13:25:23', NULL, '2026-06-08 13:25:18', '2026-06-08 13:25:23'),
(612, 'App\\Models\\User', 1, 'auth_token', 'cb24b4436c5f33260d5bf744bf52ecdec84121feb84663df6b34c3be78c4253f', '[\"*\"]', '2026-06-08 13:25:29', NULL, '2026-06-08 13:25:25', '2026-06-08 13:25:29'),
(613, 'App\\Models\\User', 1, 'auth_token', 'dcbffee6450b16780d2fa41738d182428571de77e63071d2edb1f167be4ee4a7', '[\"*\"]', '2026-06-08 13:25:36', NULL, '2026-06-08 13:25:31', '2026-06-08 13:25:36'),
(614, 'App\\Models\\User', 1, 'auth_token', '2755f11e612cc30f08c6c76f3118b48a295e847ed9717672154b8fecc2dbad23', '[\"*\"]', '2026-06-08 13:25:40', NULL, '2026-06-08 13:25:38', '2026-06-08 13:25:40'),
(615, 'App\\Models\\User', 1, 'auth_token', '8ac8a1dfb181c56429ca377c13a54e8a48a53183c662c7855884982baeb2fd81', '[\"*\"]', '2026-06-08 13:25:45', NULL, '2026-06-08 13:25:42', '2026-06-08 13:25:45'),
(616, 'App\\Models\\User', 1, 'auth_token', '81d3697b937def4b3eb4586974f8044c120846752b894efd75f2c81727cd8369', '[\"*\"]', '2026-06-08 13:25:49', NULL, '2026-06-08 13:25:47', '2026-06-08 13:25:49'),
(617, 'App\\Models\\User', 1, 'auth_token', 'c06498ff895aa20aefc0037a1106fb5ad33c0a7a2fb5cb2b9c9fc016dc25476b', '[\"*\"]', '2026-06-08 13:25:53', NULL, '2026-06-08 13:25:51', '2026-06-08 13:25:53'),
(618, 'App\\Models\\User', 1, 'auth_token', '285c9f0b6b726ad5e173aba1dcad209c130f0653cb05e437474ed06b70a1a245', '[\"*\"]', '2026-06-08 13:25:57', NULL, '2026-06-08 13:25:55', '2026-06-08 13:25:57'),
(619, 'App\\Models\\User', 1, 'auth_token', 'b987d25aa7ca3d10145c2bc61cd47ab57fb15c376dfee6f2a6122c62e7dc15a2', '[\"*\"]', '2026-06-08 13:26:01', NULL, '2026-06-08 13:25:59', '2026-06-08 13:26:01'),
(620, 'App\\Models\\User', 1, 'auth_token', 'ca964b06f5894f9a4a985506726fa8e6f4396a51390552bd95086859f90ebaaa', '[\"*\"]', '2026-06-08 13:26:06', NULL, '2026-06-08 13:26:03', '2026-06-08 13:26:06'),
(621, 'App\\Models\\User', 1, 'auth_token', '10367194c73e40703dd3eda2f6aed1b587ff51543c6d10aa17d776bd770ec82a', '[\"*\"]', '2026-06-08 13:26:10', NULL, '2026-06-08 13:26:08', '2026-06-08 13:26:10'),
(622, 'App\\Models\\User', 1, 'auth_token', '079d064e4aee13d37616f1ea53ba323574596e85030a9d7346a915319c5fd7a5', '[\"*\"]', '2026-06-08 13:26:14', NULL, '2026-06-08 13:26:12', '2026-06-08 13:26:14'),
(623, 'App\\Models\\User', 1, 'auth_token', '80a8b90a8931717f9e1e5b07de690d6d4ed891f7d84f38b26ffc94a4cd515e74', '[\"*\"]', '2026-06-08 13:26:18', NULL, '2026-06-08 13:26:16', '2026-06-08 13:26:18'),
(624, 'App\\Models\\User', 1, 'auth_token', 'd7d9e7b159a052511805bbf693daafac74fbc2fd1a2f301958d15f7d4fd970c3', '[\"*\"]', '2026-06-08 13:26:22', NULL, '2026-06-08 13:26:20', '2026-06-08 13:26:22'),
(625, 'App\\Models\\User', 1, 'auth_token', '381916436c525dd1362355b5148f19212f9bd836016f4977a9d7fc20ad98f2bf', '[\"*\"]', '2026-06-08 13:26:26', NULL, '2026-06-08 13:26:24', '2026-06-08 13:26:26'),
(626, 'App\\Models\\User', 1, 'auth_token', '6c664d90c25d5cac1c30c75579b24214e0030c912476fd8eaa3db41d7b019079', '[\"*\"]', '2026-06-08 13:26:30', NULL, '2026-06-08 13:26:28', '2026-06-08 13:26:30'),
(627, 'App\\Models\\User', 1, 'auth_token', '83e89d42397d2e916589fc7d0f9a74275b2cbd600a907f6f178781808b32a9bb', '[\"*\"]', '2026-06-08 13:26:35', NULL, '2026-06-08 13:26:32', '2026-06-08 13:26:35'),
(674, 'App\\Models\\User', 1, 'auth_token', 'd18ef6109c8e1778039fa443ced03cc38f7d53503041165abca66d8d0017477c', '[\"*\"]', NULL, NULL, '2026-06-12 09:31:00', '2026-06-12 09:31:00');

-- --------------------------------------------------------

--
-- Table structure for table `services`
--

CREATE TABLE `services` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `responsable` varchar(150) DEFAULT NULL,
  `responsable_email` varchar(255) DEFAULT NULL,
  `departement_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `services`
--

INSERT INTO `services` (`id`, `nom`, `responsable`, `responsable_email`, `departement_id`, `created_at`, `updated_at`) VALUES
(3, 'Maintenance Électrique', 'Marouane BENJANA', 'azzichaimae710@hotmail.com', 2, '2026-03-03 09:48:09', '2026-06-10 08:41:47'),
(10, 'Maintenance Mécanique', 'Taha EDQIOUAQ', NULL, 2, '2026-06-09 12:31:17', '2026-06-10 08:42:04'),
(11, 'Broyage Ciment', 'Nourdine TLAGHI', NULL, 1, '2026-06-09 12:31:35', '2026-06-10 08:17:03'),
(13, 'Cuisson et Broyage Cru', 'Ayoub GHEZOUTI', NULL, 1, '2026-06-09 12:41:43', '2026-06-10 08:16:15'),
(20, 'Bureau Méthode et Travaux Neufs', 'Hassan ARROUBIOU', NULL, 2, '2026-06-09 12:48:16', '2026-06-10 08:37:49'),
(21, 'Ressources Humaines', 'Mounia AIT BRAHIM', NULL, 5, '2026-06-09 12:52:32', '2026-06-10 08:35:50'),
(29, 'Controle Qualité et Système de Management Intégré', 'Laila RABHI', NULL, 9, '2026-06-09 13:39:21', '2026-06-10 08:40:44'),
(31, 'Santé & Sécurité & Environnement', 'Fatima-zahra CHARRIK', NULL, 5, '2026-06-10 08:34:33', '2026-06-10 08:34:33'),
(32, 'RSE & Moyens Généraux', NULL, NULL, 5, '2026-06-10 08:36:50', '2026-06-10 08:36:50'),
(33, 'Expeditions Sacs', NULL, NULL, 1, '2026-06-12 07:58:50', '2026-06-12 07:58:50'),
(34, 'Expeditions VRAC', NULL, NULL, 1, '2026-06-12 09:53:01', '2026-06-12 09:53:01');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('2vGMnVf7lzNhGfwP4s7t1nBc45DLbmdxunkA8r1V', NULL, '172.16.16.246', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWEc4U2tqdG1RcXRaa0lOcnF1aDk3dU5CV1U1bWd0RExmV3JuZmtXbSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1776261244),
('3ZENdwNk6TthexkVNXGR51540EyzB8Pf5McBzWvQ', NULL, '172.16.16.246', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWVNlUE5Ca0xuSDhUak02THBCRWY2Z1hXQ2VRelprWE5seVg1YzRmWSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1776327454),
('77oZgxXoYzR6PMGETIjKeISJ3VeuCR9LXCi0HtA4', NULL, '172.16.16.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiRVFJenYyb3RRdmhCYk9xeEJEajRNeW9iSjhQNnFBR3lzQmFuOE5jWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1776679564),
('7uZTpOfUJqR3OCtZDKQ00sYZO2kwKUPFXC8Ui242', NULL, '172.16.16.188', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVGdseUlzWGFYT3ZCRTNrOEFYNEJSTk5aTHpjZDdjVU5FVnRBalRJZyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1779183195),
('8w4FlRcquFGw6HPRQd4ASp7KOHdZLIayhHkaajqy', NULL, '172.16.16.246', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36 Edg/146.0.0.0', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoieE9qdGF4ZHJMMnN3YmVRQmpqQWVvRk1NMEtNWElDekdqYnQxbjdKRiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1776161903),
('L75oCGPKGvwEJmQ2qSQd3pZfiQRhcM9DPwMl0W4i', NULL, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoia01wUk83VWRWSmNqd29mc21DdkxqcGhINloxNTZtV3RRM2FzellXWiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6Mjc6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMC9sb2dpbiI7czo1OiJyb3V0ZSI7Tjt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319fQ==', 1775551131),
('lV0RaZJQ7TSY0Mc4HrvQSUBjEH3ma5zl0g7wc1SF', NULL, '172.16.16.165', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiMmRxYWxXd0lZSk04cVdtWWFob0tNV0JrcGRicUVHekcwYVc3UjlGMCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1777886551),
('lwXZlfBVgqXsV9B7M0wqobnrSUbG7mItQPCnqxwP', NULL, '172.16.16.165', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiVmhkRUFqcmtuYmpCTmRhNXZPTFhTVXdnRU9WVUZ6Z0l3eFBXNUZ5UiI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1778076768),
('MWHzHeLd6YAXZm0Ag78xpvrDZhSecrzv2YpgetdL', NULL, '172.16.16.224', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiSmVtRzFWQXZIU1ZIQldwMzI0ZmVnRXcyQmM1bGg2RVVpUUUwczQ2cyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1781004371),
('NAkk52hZiIYvgJjELZqFto7nAshgrRrbJ2xLtqVi', NULL, '172.16.16.224', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiV1NCWEY0aFM5UGtLSGUwS2tYM0laaFpiaWJTdGF1Vk5kcDkyM1hONyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1781187102),
('OdqxiT3E2pqI6uNuv5grvUsILZYiQt31fUQEZVkO', NULL, '172.16.16.224', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiWWZESHdDOGt4eXNKRkRaS0lpb0lkNVdORTNvZHZ2UmZKaHp6OUhkcCI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1781083166),
('V1fd2fkYwJAH1QvQQLdpC3vDOMo3sWpsvQ7zJCkR', NULL, '172.16.16.246', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiZ1pGN1VXUVk3ZkpEUVFRUkxaOGpBcEZkSjJyMnhJSDFFaVBSNVpNMyI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1776439263),
('VFrZFKdO56JJsoovpnpHK76wUSAkgcesbQSoPDD4', NULL, '172.16.16.135', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoid3hBbTBMVHNjU3pOUldvdmRxMUpRZ3JrVkFwVlI0WHAzQVJoRTRCMSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1777030206),
('xm8XeGYEBipRFSDoVY0vNlWHwJbNl10girLMhdrJ', NULL, '172.16.16.224', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'YTozOntzOjY6Il90b2tlbiI7czo0MDoiTzFNVlR4ZVNGeG5ReldPbEVYVzJDZU1ZUlVCYThwVmZiT1pXMGhZQSI7czo5OiJfcHJldmlvdXMiO2E6Mjp7czozOiJ1cmwiO3M6MjU6Imh0dHA6Ly9ob2xjaW0ubG9jYWwvbG9naW4iO3M6NToicm91dGUiO047fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=', 1780906169);

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `directeur_usine` varchar(150) NOT NULL,
  `email_directeur` varchar(255) DEFAULT NULL,
  `titre_directeur` varchar(150) NOT NULL DEFAULT 'Directeur d''Usine',
  `site` varchar(150) NOT NULL,
  `societe` varchar(150) NOT NULL DEFAULT 'LafargeHolcim Maroc',
  `resp_sante_securite` varchar(150) NOT NULL,
  `email_resp_sante_securite` varchar(255) DEFAULT NULL,
  `medecin` varchar(150) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `directeur_usine`, `email_directeur`, `titre_directeur`, `site`, `societe`, `resp_sante_securite`, `email_resp_sante_securite`, `medecin`, `created_at`, `updated_at`) VALUES
(1, 'Chakib EL OUDGHIRI', 'chaymaeazzi2407@gmail.com', 'Directeur d\'Usine', 'Holcim d\'Oujda', 'Holcim Maroc', 'Fatima Zahra CHARRIK', 'azzichaimae710@hotmail.com', 'Abdelhamid BENDAHA', '2026-03-03 09:48:10', '2026-06-11 22:01:14');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `prenom` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('RRH','RH','Manager') NOT NULL,
  `service_id` bigint(20) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `nom`, `prenom`, `email`, `password`, `role`, `service_id`, `created_at`, `updated_at`) VALUES
(1, 'AIT BRAHIM', 'Mounia', 'azzichaimae710@hotmail.com', '$2y$12$KLohsllnLFmpW75WkvKtZeQlg.fWY1GzjbcmAd24t0Q1HGwHSTInG', 'RRH', 21, '2026-03-03 09:48:10', '2026-06-09 12:55:51'),
(2, 'BOURKENE', 'Wassif', 'chaymaeazzi2407@gmail.com', '$2y$12$0lbk2MZhOlC47eDwnMH3L.J8p7dk1sTS4hH.ujTCON//l6x9oByDO', 'RH', 21, '2026-03-03 09:48:10', '2026-06-09 12:55:40'),
(5, 'Azzi', 'Chaymae', 'm.manager@holcim.ma', '$2y$12$9ENy.kuzhU7K6W.Rn79oIeo09uhMgYVuGwwo7rssOvziHdg2HP1xO', 'Manager', 3, '2026-03-16 09:33:18', '2026-04-07 13:32:58');

-- --------------------------------------------------------

--
-- Table structure for table `volets`
--

CREATE TABLE `volets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `nom` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `volets`
--

INSERT INTO `volets` (`id`, `nom`, `description`, `created_at`, `updated_at`) VALUES
(1, 'Sécurité Incendie', 'Habilitations liées à la prévention et lutte contre l\'incendie', '2026-03-03 09:48:10', '2026-03-03 09:48:10'),
(3, 'Travail en Hauteur', 'Habilitations pour les interventions en hauteur', '2026-03-03 09:48:10', '2026-03-03 09:48:10'),
(4, 'Conduite d\'Engins', 'Habilitations pour la conduite de chariots et engins de chantier', '2026-03-03 09:48:10', '2026-03-03 09:48:10'),
(6, 'Isolation énergétique', NULL, '2026-03-05 08:54:09', '2026-03-05 08:54:09'),
(7, 'Espace confiné', NULL, '2026-03-05 08:54:49', '2026-03-05 08:54:49'),
(8, 'Equipements mobiles', NULL, '2026-03-05 08:55:48', '2026-03-05 08:55:48'),
(9, 'Sécurité électrique', NULL, '2026-03-05 08:56:08', '2026-03-05 08:56:08'),
(10, 'Travail à chaud', NULL, '2026-03-05 08:57:24', '2026-03-05 08:57:24'),
(11, 'Travaux à la tour de préchauffage', NULL, '2026-03-05 08:58:30', '2026-03-05 08:58:30'),
(12, 'Levage et support de charges', NULL, '2026-03-05 08:58:48', '2026-03-05 08:58:48'),
(13, 'Gestion d\'urgence', NULL, '2026-03-05 08:59:21', '2026-03-05 08:59:21'),
(14, 'Minage et forage', NULL, '2026-03-05 09:00:38', '2026-03-05 09:00:38'),
(15, 'ATEX', NULL, '2026-03-05 09:01:03', '2026-03-05 09:01:03'),
(17, 'Santé', NULL, '2026-03-05 09:01:34', '2026-03-05 09:01:34'),
(18, 'Outillage', NULL, '2026-03-05 09:07:41', '2026-03-05 09:07:41');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `alerts`
--
ALTER TABLE `alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `alerts_employee_habilitation_id_foreign` (`employee_habilitation_id`);

--
-- Indexes for table `attribution_validations`
--
ALTER TABLE `attribution_validations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `attribution_validations_token_unique` (`token`),
  ADD KEY `attribution_validations_employee_habilitation_id_foreign` (`employee_habilitation_id`);

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `departements`
--
ALTER TABLE `departements`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `departements_nom_unique` (`nom`);

--
-- Indexes for table `documents`
--
ALTER TABLE `documents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `documents_employee_habilitation_id_foreign` (`employee_habilitation_id`),
  ADD KEY `documents_habilitation_id_foreign` (`habilitation_id`);

--
-- Indexes for table `employees`
--
ALTER TABLE `employees`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `employees_matricule_unique` (`matricule`),
  ADD UNIQUE KEY `employees_email_pro_unique` (`email_pro`),
  ADD KEY `employees_service_id_foreign` (`service_id`);

--
-- Indexes for table `employee_habilitations`
--
ALTER TABLE `employee_habilitations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `employee_habilitations_employee_id_foreign` (`employee_id`),
  ADD KEY `employee_habilitations_habilitation_id_foreign` (`habilitation_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `habilitations`
--
ALTER TABLE `habilitations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `habilitations_volet_id_foreign` (`volet_id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  ADD KEY `personal_access_tokens_expires_at_index` (`expires_at`);

--
-- Indexes for table `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`id`),
  ADD KEY `services_departement_id_foreign` (`departement_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`),
  ADD KEY `users_service_id_foreign` (`service_id`);

--
-- Indexes for table `volets`
--
ALTER TABLE `volets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `volets_nom_unique` (`nom`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `alerts`
--
ALTER TABLE `alerts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `attribution_validations`
--
ALTER TABLE `attribution_validations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `departements`
--
ALTER TABLE `departements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `documents`
--
ALTER TABLE `documents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;

--
-- AUTO_INCREMENT for table `employees`
--
ALTER TABLE `employees`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=169;

--
-- AUTO_INCREMENT for table `employee_habilitations`
--
ALTER TABLE `employee_habilitations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=71;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `habilitations`
--
ALTER TABLE `habilitations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=37;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=679;

--
-- AUTO_INCREMENT for table `services`
--
ALTER TABLE `services`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `volets`
--
ALTER TABLE `volets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `alerts`
--
ALTER TABLE `alerts`
  ADD CONSTRAINT `alerts_employee_habilitation_id_foreign` FOREIGN KEY (`employee_habilitation_id`) REFERENCES `employee_habilitations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `attribution_validations`
--
ALTER TABLE `attribution_validations`
  ADD CONSTRAINT `attribution_validations_employee_habilitation_id_foreign` FOREIGN KEY (`employee_habilitation_id`) REFERENCES `employee_habilitations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `documents`
--
ALTER TABLE `documents`
  ADD CONSTRAINT `documents_employee_habilitation_id_foreign` FOREIGN KEY (`employee_habilitation_id`) REFERENCES `employee_habilitations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `documents_habilitation_id_foreign` FOREIGN KEY (`habilitation_id`) REFERENCES `habilitations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `employees`
--
ALTER TABLE `employees`
  ADD CONSTRAINT `employees_service_id_foreign` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `employee_habilitations`
--
ALTER TABLE `employee_habilitations`
  ADD CONSTRAINT `employee_habilitations_employee_id_foreign` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `employee_habilitations_habilitation_id_foreign` FOREIGN KEY (`habilitation_id`) REFERENCES `habilitations` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `habilitations`
--
ALTER TABLE `habilitations`
  ADD CONSTRAINT `habilitations_volet_id_foreign` FOREIGN KEY (`volet_id`) REFERENCES `volets` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `services`
--
ALTER TABLE `services`
  ADD CONSTRAINT `services_departement_id_foreign` FOREIGN KEY (`departement_id`) REFERENCES `departements` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_service_id_foreign` FOREIGN KEY (`service_id`) REFERENCES `services` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
