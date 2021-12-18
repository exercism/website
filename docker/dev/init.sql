CREATE USER IF NOT EXISTS 'exercism' IDENTIFIED BY 'exercism';

CREATE DATABASE IF NOT EXISTS `exercism_development`;
ALTER DATABASE `exercism_development` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `exercism_development`.* TO 'exercism';

CREATE DATABASE IF NOT EXISTS `exercism_dj_development`;
ALTER DATABASE `exercism_dj_development` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `exercism_dj_development`.* TO 'exercism';

CREATE DATABASE IF NOT EXISTS `exercism_test`;
ALTER DATABASE `exercism_test` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `exercism_test`.* TO 'exercism';
