CREATE USER 'git'@'localhost' IDENTIFIED BY '$password';
SET storage_engine=INNODB;
CREATE DATABASE IF NOT EXISTS `gitlabhq_production` DEFAULT CHARACTER SET `utf8` COLLATE `utf8_unicode_ci`;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, LOCK TABLES ON `gitlabhq_production`.* TO 'git'@'localhost';