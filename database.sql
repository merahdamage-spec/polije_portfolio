-- Import lewat phpMyAdmin (tab Import) atau jalankan di tab SQL.
CREATE DATABASE IF NOT EXISTS polije_portfolio
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE polije_portfolio;

CREATE TABLE IF NOT EXISTS portfolios (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  title       VARCHAR(150) NOT NULL,
  category    VARCHAR(50)  NOT NULL,
  technology  VARCHAR(50)  NOT NULL,
  description TEXT         NOT NULL,
  image_path  LONGTEXT     NULL,          -- gambar disimpan sebagai base64
  created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  DATETIME     NULL ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 5 karya contoh (ganti dengan karya aslimu lewat aplikasi)
INSERT INTO portfolios (title, category, technology, description, created_at) VALUES
('Aplikasi Portofolio POLIJE', 'Aplikasi Mobile', 'Flutter',
 'Aplikasi portofolio pribadi dengan CRUD, MySQL, dan informasi kampus POLIJE.', DATE_SUB(NOW(), INTERVAL 0 DAY)),
('Sistem Informasi Akademik', 'Website', 'Laravel',
 'Website pengelolaan nilai dan jadwal kuliah berbasis web dengan multi-role.', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('Redesign UI Aplikasi Kampus', 'Desain UI/UX', 'Figma',
 'Prototipe antarmuka aplikasi kampus yang lebih sederhana dan mudah dipakai.', DATE_SUB(NOW(), INTERVAL 14 DAY)),
('Monitoring Suhu Ruangan', 'IoT / Hardware', 'Arduino',
 'Alat pemantau suhu dan kelembapan ruangan menggunakan sensor DHT11.', DATE_SUB(NOW(), INTERVAL 21 DAY)),
('Prediksi Harga Komoditas', 'Data & AI', 'Python',
 'Analisis dan prediksi harga komoditas pertanian menggunakan regresi sederhana.', DATE_SUB(NOW(), INTERVAL 28 DAY));
