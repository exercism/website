# Exercism

This is the WIP website for Exercism v3.

### Configure the database

Running these commands inside a mysql console will get a working database setup:

```bash
CREATE USER 'exercism_v3'@'localhost' IDENTIFIED BY 'exercism_v3';
CREATE DATABASE exercism_v3_development;
ALTER DATABASE exercism_v3_development CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON exercism_v3_development.* TO 'exercism_v3'@'localhost';
```

For the test database, tests are parallelized, so you you need a db per processor. This example sets up two databases.

```bash
CREATE DATABASE `exercism_v3_test-0`;
ALTER DATABASE `exercism_v3_test-0` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `exercism_v3_test-0`.* TO 'exercism_v3'@'localhost';

CREATE DATABASE `exercism_v3_test-1`;
ALTER DATABASE `exercism_v3_test-1` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `exercism_v3_test-1`.* TO 'exercism_v3'@'localhost';
```

I've also found that you need a general one too:

```bash
CREATE DATABASE `exercism_v3_test`;
ALTER DATABASE `exercism_v3_test` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON `exercism_v3_test`.* TO 'exercism_v3'@'localhost';
```
