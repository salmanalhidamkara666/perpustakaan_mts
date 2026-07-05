-- Database: `perpustakaan_mts`
CREATE DATABASE IF NOT EXISTS `perpustakaan_mts`;
USE `perpustakaan_mts`;

CREATE TABLE `users` (
  `id_user` int(11) NOT NULL AUTO_INCREMENT,
  `nama` varchar(100) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','kepala','siswa') NOT NULL,
  PRIMARY KEY (`id_user`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `anggota` (
  `nis` varchar(20) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `jenis_kelamin` enum('L','P') NOT NULL,
  `kelas` varchar(20) NOT NULL,
  `id_user` int(11) DEFAULT NULL,
  PRIMARY KEY (`nis`),
  KEY `id_user` (`id_user`),
  CONSTRAINT `anggota_ibfk_1` FOREIGN KEY (`id_user`) REFERENCES `users` (`id_user`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `buku` (
  `kode_buku` varchar(20) NOT NULL,
  `judul` varchar(200) NOT NULL,
  `pengarang` varchar(100) NOT NULL,
  `penerbit` varchar(100) NOT NULL,
  `tahun_terbit` year(4) NOT NULL,
  `kategori` varchar(50) NOT NULL,
  `stok` int(11) NOT NULL,
  PRIMARY KEY (`kode_buku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `peminjaman` (
  `id_peminjaman` int(11) NOT NULL AUTO_INCREMENT,
  `nis` varchar(20) NOT NULL,
  `kode_buku` varchar(20) NOT NULL,
  `tanggal_pinjam` date NOT NULL,
  `batas_kembali` date NOT NULL,
  `tanggal_kembali` date DEFAULT NULL,
  `status` enum('Dipinjam','Dikembalikan','Terlambat') DEFAULT 'Dipinjam',
  `denda` int(11) DEFAULT 0,
  PRIMARY KEY (`id_peminjaman`),
  KEY `nis` (`nis`),
  KEY `kode_buku` (`kode_buku`),
  CONSTRAINT `peminjaman_ibfk_1` FOREIGN KEY (`nis`) REFERENCES `anggota` (`nis`),
  CONSTRAINT `peminjaman_ibfk_2` FOREIGN KEY (`kode_buku`) REFERENCES `buku` (`kode_buku`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data Dummy
INSERT INTO `users` (`id_user`, `nama`, `username`, `password`, `role`) VALUES
(1, 'Admin Perpus', 'admin', md5('admin123'), 'admin'),
(2, 'Kepala Madrasah', 'kepala', md5('kepala123'), 'kepala'),
(3, 'Ahmad Rizki', 'siswa', md5('siswa123'), 'siswa');

INSERT INTO `anggota` (`nis`, `nama`, `jenis_kelamin`, `kelas`, `id_user`) VALUES
('1001', 'Ahmad Rizki', 'L', 'VII A', 3),
('1002', 'Siti Aisyah', 'P', 'VIII B', NULL);

INSERT INTO `buku` (`kode_buku`, `judul`, `pengarang`, `penerbit`, `tahun_terbit`, `kategori`, `stok`) VALUES
('B001', 'Pemrograman Web Dasar', 'Ahmad Rizki', 'Informatika', 2021, 'Teknologi', 5),
('B002', 'Sejarah Indonesia', 'Siti Aisyah', 'Erlangga', 2020, 'Sejarah', 3),
('B003', 'Matematika untuk SMA', 'Budi Santoso', 'BSE', 2019, 'Matematika', 10);

INSERT INTO `peminjaman` (`id_peminjaman`, `nis`, `kode_buku`, `tanggal_pinjam`, `batas_kembali`, `tanggal_kembali`, `status`, `denda`) VALUES
(1, '1001', 'B001', '2024-05-20', '2024-05-27', NULL, 'Dipinjam', 0),
(2, '1002', 'B002', '2024-05-12', '2024-05-19', '2024-05-19', 'Dikembalikan', 0),
(3, '1001', 'B003', '2024-05-10', '2024-05-17', NULL, 'Terlambat', 15000);
