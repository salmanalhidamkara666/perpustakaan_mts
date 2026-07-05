mkdir -p php-app

cat << 'INNER_EOF' > php-app/koneksi.php
<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "perpustakaan_mts";

$conn = mysqli_connect($host, $user, $pass, $db);

if (!$conn) {
    die("Koneksi database gagal: " . mysqli_connect_error());
}
?>
INNER_EOF

cat << 'INNER_EOF' > php-app/database.sql
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
INNER_EOF

cat << 'INNER_EOF' > php-app/index.php
<?php
session_start();
if(isset($_SESSION['role'])) {
    if($_SESSION['role'] == 'siswa') header("Location: katalog.php");
    else header("Location: dashboard.php");
    exit;
}
include 'koneksi.php';

$error = '';
if(isset($_POST['login'])) {
    $username = mysqli_real_escape_string($conn, $_POST['username']);
    $password = md5($_POST['password']);
    
    $query = mysqli_query($conn, "SELECT * FROM users WHERE username='$username' AND password='$password'");
    if(mysqli_num_rows($query) > 0) {
        $data = mysqli_fetch_assoc($query);
        $_SESSION['id_user'] = $data['id_user'];
        $_SESSION['nama'] = $data['nama'];
        $_SESSION['role'] = $data['role'];
        
        if($data['role'] == 'siswa') {
            // Ambil NIS untuk siswa
            $q_anggota = mysqli_query($conn, "SELECT nis FROM anggota WHERE id_user='".$data['id_user']."'");
            if($r_anggota = mysqli_fetch_assoc($q_anggota)) {
                $_SESSION['nis'] = $r_anggota['nis'];
            }
            header("Location: katalog.php");
        } else {
            header("Location: dashboard.php");
        }
        exit;
    } else {
        $error = 'Username atau Password salah!';
    }
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - SIPERPustakaan</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #f8f9fa; }
        .login-card { max-width: 400px; margin: 100px auto; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); background: #fff; }
    </style>
</head>
<body>
    <div class="container">
        <div class="login-card text-center border-top border-primary border-4">
            <h4 class="mb-4 text-primary fw-bold">SIPERPustakaan</h4>
            <p class="text-muted">Silakan login untuk melanjutkan</p>
            <?php if($error): ?>
                <div class="alert alert-danger"><?= $error ?></div>
            <?php endif; ?>
            <form method="POST">
                <div class="mb-3 text-start">
                    <label class="form-label text-secondary fw-semibold">Username</label>
                    <input type="text" name="username" class="form-control" required placeholder="Masukkan username">
                </div>
                <div class="mb-4 text-start">
                    <label class="form-label text-secondary fw-semibold">Password</label>
                    <input type="password" name="password" class="form-control" required placeholder="Masukkan password">
                </div>
                <button type="submit" name="login" class="btn btn-primary w-100 fw-bold py-2">Login</button>
            </form>
            <div class="mt-4 text-muted small">
                &copy; <?= date('Y') ?> Sistem Informasi Perpustakaan.
            </div>
        </div>
    </div>
</body>
</html>
INNER_EOF

cat << 'INNER_EOF' > php-app/logout.php
<?php
session_start();
session_destroy();
header("Location: index.php");
?>
INNER_EOF

cat << 'INNER_EOF' > php-app/header.php
<?php
session_start();
if(!isset($_SESSION['role'])) {
    header("Location: index.php");
    exit;
}
include 'koneksi.php';
$role = $_SESSION['role'];
?>
<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sistem Manajemen Perpustakaan</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        .sidebar { min-height: 100vh; background: #0f172a; color: white; }
        .sidebar h5 { color: #f8fafc; font-weight: 700; letter-spacing: 0.5px; }
        .sidebar a { color: #94a3b8; text-decoration: none; padding: 12px 20px; display: block; border-radius: 8px; margin-bottom: 5px; font-weight: 500; transition: all 0.2s; }
        .sidebar a:hover, .sidebar a.active { background: #1e293b; color: #fff; }
        .sidebar a i { margin-right: 10px; font-size: 1.1rem; }
        .content { padding: 30px; }
        .card { border-radius: 10px; border: none; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .navbar { box-shadow: 0 1px 2px rgba(0,0,0,0.05); }
    </style>
</head>
<body>
    <div class="d-flex">
        <!-- Sidebar -->
        <div class="sidebar p-3 d-print-none" style="width: 260px;">
            <div class="d-flex align-items-center mb-4 px-2 mt-2">
                <i class="bi bi-book-half fs-3 text-primary me-2"></i>
                <h5 class="mb-0">SIPERPustakaan</h5>
            </div>
            
            <?php if($role == 'admin' || $role == 'kepala'): ?>
                <a href="dashboard.php" class="<?= basename($_SERVER['PHP_SELF']) == 'dashboard.php' ? 'active' : '' ?>"><i class="bi bi-grid-1x2"></i> Dashboard</a>
            <?php endif; ?>
            
            <?php if($role == 'admin'): ?>
                <a href="buku.php" class="<?= basename($_SERVER['PHP_SELF']) == 'buku.php' ? 'active' : '' ?>"><i class="bi bi-book"></i> Data Buku</a>
                <a href="anggota.php" class="<?= basename($_SERVER['PHP_SELF']) == 'anggota.php' ? 'active' : '' ?>"><i class="bi bi-people"></i> Data Anggota</a>
                <a href="peminjaman.php" class="<?= basename($_SERVER['PHP_SELF']) == 'peminjaman.php' ? 'active' : '' ?>"><i class="bi bi-arrow-up-right-square"></i> Peminjaman</a>
                <a href="pengembalian.php" class="<?= basename($_SERVER['PHP_SELF']) == 'pengembalian.php' ? 'active' : '' ?>"><i class="bi bi-arrow-down-left-square"></i> Pengembalian</a>
            <?php endif; ?>

            <?php if($role == 'siswa'): ?>
                <a href="katalog.php" class="<?= basename($_SERVER['PHP_SELF']) == 'katalog.php' ? 'active' : '' ?>"><i class="bi bi-search"></i> Katalog Buku</a>
                <a href="riwayat.php" class="<?= basename($_SERVER['PHP_SELF']) == 'riwayat.php' ? 'active' : '' ?>"><i class="bi bi-clock-history"></i> Riwayat Pinjam</a>
            <?php endif; ?>

            <?php if($role == 'admin' || $role == 'kepala'): ?>
                <a href="laporan.php" class="<?= basename($_SERVER['PHP_SELF']) == 'laporan.php' ? 'active' : '' ?>"><i class="bi bi-file-earmark-text"></i> Laporan</a>
            <?php endif; ?>

            <hr class="border-secondary my-4">
            <a href="logout.php" class="text-danger"><i class="bi bi-box-arrow-right"></i> Logout</a>
        </div>
        
        <!-- Main Content -->
        <div class="flex-grow-1 bg-light" style="min-width: 0;">
            <nav class="navbar navbar-expand-lg navbar-light bg-white px-4 py-3 d-print-none">
                <div class="container-fluid">
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse" id="navbarNav">
                        <ul class="navbar-nav ms-auto align-items-center">
                            <li class="nav-item">
                                <span class="nav-link text-dark">
                                    <i class="bi bi-person-circle fs-5 me-2 align-middle"></i>
                                    <span class="fw-medium"><?= htmlspecialchars($_SESSION['nama']) ?></span> 
                                    <span class="badge bg-secondary ms-1"><?= ucfirst($role) ?></span>
                                </span>
                            </li>
                        </ul>
                    </div>
                </div>
            </nav>
            <div class="content">
INNER_EOF

cat << 'INNER_EOF' > php-app/footer.php
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
INNER_EOF

cat << 'INNER_EOF' > php-app/dashboard.php
<?php
include 'header.php';
if($role == 'siswa') { header("Location: katalog.php"); exit; }

// Update status denda otomatis (Hanya menghitung keterlambatan untuk yg statusnya Dipinjam)
mysqli_query($conn, "UPDATE peminjaman SET status='Terlambat', denda = DATEDIFF(CURDATE(), batas_kembali) * 500 WHERE status='Dipinjam' AND CURDATE() > batas_kembali");
// Update denda berjalan untuk yang sudah Terlambat tapi belum dikembalikan
mysqli_query($conn, "UPDATE peminjaman SET denda = DATEDIFF(CURDATE(), batas_kembali) * 500 WHERE status='Terlambat' AND tanggal_kembali IS NULL");

$total_buku = mysqli_fetch_assoc(mysqli_query($conn, "SELECT COUNT(*) as total FROM buku"))['total'];
$total_anggota = mysqli_fetch_assoc(mysqli_query($conn, "SELECT COUNT(*) as total FROM anggota"))['total'];
$buku_dipinjam = mysqli_fetch_assoc(mysqli_query($conn, "SELECT COUNT(*) as total FROM peminjaman WHERE status='Dipinjam' OR status='Terlambat'"))['total'];
$total_denda = mysqli_fetch_assoc(mysqli_query($conn, "SELECT SUM(denda) as total FROM peminjaman WHERE status='Terlambat' OR status='Dikembalikan'"))['total'];
?>
<div class="d-flex justify-content-between align-items-end mb-4">
    <div>
        <h3 class="fw-bold mb-1">Dashboard</h3>
        <p class="text-muted mb-0">Selamat datang kembali, ringkasan data perpustakaan hari ini.</p>
    </div>
</div>

<div class="row g-4 mb-5">
    <div class="col-md-3">
        <div class="card bg-white border-0 shadow-sm h-100">
            <div class="card-body p-4 d-flex align-items-center">
                <div class="bg-primary bg-opacity-10 p-3 rounded-3 me-3 text-primary">
                    <i class="bi bi-book fs-3"></i>
                </div>
                <div>
                    <p class="text-muted mb-1 small fw-bold text-uppercase">Total Buku</p>
                    <h3 class="mb-0 fw-bold"><?= $total_buku ?></h3>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-white border-0 shadow-sm h-100">
            <div class="card-body p-4 d-flex align-items-center">
                <div class="bg-success bg-opacity-10 p-3 rounded-3 me-3 text-success">
                    <i class="bi bi-people fs-3"></i>
                </div>
                <div>
                    <p class="text-muted mb-1 small fw-bold text-uppercase">Anggota Aktif</p>
                    <h3 class="mb-0 fw-bold"><?= $total_anggota ?></h3>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-white border-0 shadow-sm h-100">
            <div class="card-body p-4 d-flex align-items-center">
                <div class="bg-warning bg-opacity-10 p-3 rounded-3 me-3 text-warning">
                    <i class="bi bi-arrow-left-right fs-3"></i>
                </div>
                <div>
                    <p class="text-muted mb-1 small fw-bold text-uppercase">Buku Dipinjam</p>
                    <h3 class="mb-0 fw-bold"><?= $buku_dipinjam ?></h3>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-white border-0 shadow-sm h-100">
            <div class="card-body p-4 d-flex align-items-center">
                <div class="bg-danger bg-opacity-10 p-3 rounded-3 me-3 text-danger">
                    <i class="bi bi-cash-coin fs-3"></i>
                </div>
                <div>
                    <p class="text-muted mb-1 small fw-bold text-uppercase">Total Denda</p>
                    <h4 class="mb-0 fw-bold">Rp <?= number_format($total_denda ?: 0, 0, ',', '.') ?></h4>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-header bg-white py-3 border-bottom">
        <div class="d-flex justify-content-between align-items-center">
            <h6 class="mb-0 fw-bold">Riwayat Transaksi Terbaru</h6>
            <?php if($role == 'admin' || $role == 'kepala'): ?>
                <a href="laporan.php" class="btn btn-sm btn-light">Lihat Semua</a>
            <?php endif; ?>
        </div>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th class="ps-4 py-3">ID TRX</th>
                        <th>Nama Anggota</th>
                        <th>Buku</th>
                        <th>Tanggal Pinjam</th>
                        <th>Status</th>
                        <th class="pe-4">Denda</th>
                    </tr>
                </thead>
                <tbody class="border-top-0">
                    <?php
                    $q = mysqli_query($conn, "SELECT p.*, a.nama, b.judul FROM peminjaman p JOIN anggota a ON p.nis=a.nis JOIN buku b ON p.kode_buku=b.kode_buku ORDER BY p.id_peminjaman DESC LIMIT 5");
                    while($r = mysqli_fetch_assoc($q)):
                        $badge = $r['status'] == 'Dipinjam' ? 'bg-primary' : ($r['status'] == 'Dikembalikan' ? 'bg-success' : 'bg-danger');
                    ?>
                    <tr>
                        <td class="ps-4"><span class="text-muted fw-medium">TRX-<?= sprintf('%04d', $r['id_peminjaman']) ?></span></td>
                        <td class="fw-medium"><?= htmlspecialchars($r['nama']) ?></td>
                        <td class="text-secondary"><?= htmlspecialchars($r['judul']) ?></td>
                        <td><?= date('d M Y', strtotime($r['tanggal_pinjam'])) ?></td>
                        <td><span class="badge <?= $badge ?> rounded-pill px-3"><?= $r['status'] ?></span></td>
                        <td class="pe-4 text-danger fw-medium"><?= $r['denda'] > 0 ? 'Rp '.number_format($r['denda'], 0, ',', '.') : '-' ?></td>
                    </tr>
                    <?php endwhile; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php include 'footer.php'; ?>
INNER_EOF

cat << 'INNER_EOF' > php-app/buku.php
<?php
include 'header.php';
if($role != 'admin') { header("Location: dashboard.php"); exit; }

// Tambah Buku
if(isset($_POST['tambah'])) {
    $kode = mysqli_real_escape_string($conn, $_POST['kode_buku']);
    $judul = mysqli_real_escape_string($conn, $_POST['judul']);
    $pengarang = mysqli_real_escape_string($conn, $_POST['pengarang']);
    $penerbit = mysqli_real_escape_string($conn, $_POST['penerbit']);
    $tahun = (int)$_POST['tahun_terbit'];
    $kategori = mysqli_real_escape_string($conn, $_POST['kategori']);
    $stok = (int)$_POST['stok'];
    
    $q = mysqli_query($conn, "INSERT INTO buku VALUES ('$kode', '$judul', '$pengarang', '$penerbit', '$tahun', '$kategori', '$stok')");
    if($q) echo "<div class='alert alert-success alert-dismissible fade show'>Buku berhasil ditambahkan!<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
    else echo "<div class='alert alert-danger alert-dismissible fade show'>Gagal menambahkan buku! Kode buku mungkin sudah ada.<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
}

// Hapus Buku
if(isset($_GET['hapus'])) {
    $kode = mysqli_real_escape_string($conn, $_GET['hapus']);
    mysqli_query($conn, "DELETE FROM buku WHERE kode_buku='$kode'");
    echo "<script>window.location='buku.php';</script>";
}

$cari = isset($_GET['cari']) ? mysqli_real_escape_string($conn, $_GET['cari']) : '';
?>
<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold mb-0">Manajemen Buku</h3>
    <button class="btn btn-primary fw-medium" data-bs-toggle="modal" data-bs-target="#modalTambah">
        <i class="bi bi-plus-lg me-1"></i> Tambah Buku
    </button>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-4">
        <form class="mb-4" method="GET">
            <div class="input-group" style="max-width: 400px;">
                <input type="text" name="cari" class="form-control" placeholder="Cari kode, judul, atau pengarang..." value="<?= htmlspecialchars($cari) ?>">
                <button class="btn btn-outline-secondary" type="submit"><i class="bi bi-search"></i></button>
            </div>
        </form>

        <div class="table-responsive">
            <table class="table table-bordered table-hover align-middle">
                <thead class="table-light">
                    <tr>
                        <th>Kode</th>
                        <th>Judul Buku</th>
                        <th>Pengarang</th>
                        <th>Penerbit</th>
                        <th>Tahun</th>
                        <th>Kategori</th>
                        <th class="text-center">Stok</th>
                        <th class="text-center">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $where = "";
                    if($cari) {
                        $where = "WHERE kode_buku LIKE '%$cari%' OR judul LIKE '%$cari%' OR pengarang LIKE '%$cari%'";
                    }
                    $q = mysqli_query($conn, "SELECT * FROM buku $where ORDER BY kode_buku DESC");
                    if(mysqli_num_rows($q) > 0):
                        while($r = mysqli_fetch_assoc($q)):
                    ?>
                    <tr>
                        <td class="fw-medium text-primary"><?= htmlspecialchars($r['kode_buku']) ?></td>
                        <td class="fw-medium"><?= htmlspecialchars($r['judul']) ?></td>
                        <td><?= htmlspecialchars($r['pengarang']) ?></td>
                        <td class="text-muted"><?= htmlspecialchars($r['penerbit']) ?></td>
                        <td><?= $r['tahun_terbit'] ?></td>
                        <td><span class="badge bg-secondary bg-opacity-10 text-secondary border"><?= htmlspecialchars($r['kategori']) ?></span></td>
                        <td class="text-center fw-bold <?= $r['stok'] > 0 ? 'text-success' : 'text-danger' ?>"><?= $r['stok'] ?></td>
                        <td class="text-center">
                            <a href="?hapus=<?= $r['kode_buku'] ?>" class="btn btn-sm btn-outline-danger" onclick="return confirm('Yakin ingin menghapus buku ini? Semua data peminjaman terkait mungkin akan terpengaruh.')"><i class="bi bi-trash"></i></a>
                        </td>
                    </tr>
                    <?php 
                        endwhile;
                    else:
                        echo "<tr><td colspan='8' class='text-center text-muted py-4'>Tidak ada data buku ditemukan.</td></tr>";
                    endif;
                    ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal Tambah -->
<div class="modal fade" id="modalTambah" tabindex="-1">
  <div class="modal-dialog">
    <form method="POST" class="modal-content">
      <div class="modal-header border-bottom-0">
        <h5 class="modal-title fw-bold">Tambah Buku Baru</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body py-0">
        <div class="mb-3">
            <label class="form-label fw-medium text-muted small">Kode Buku</label>
            <input type="text" name="kode_buku" class="form-control" required placeholder="Contoh: B005">
        </div>
        <div class="mb-3">
            <label class="form-label fw-medium text-muted small">Judul Buku</label>
            <input type="text" name="judul" class="form-control" required>
        </div>
        <div class="row">
            <div class="col-md-6 mb-3">
                <label class="form-label fw-medium text-muted small">Pengarang</label>
                <input type="text" name="pengarang" class="form-control" required>
            </div>
            <div class="col-md-6 mb-3">
                <label class="form-label fw-medium text-muted small">Penerbit</label>
                <input type="text" name="penerbit" class="form-control" required>
            </div>
        </div>
        <div class="row">
            <div class="col-md-4 mb-3">
                <label class="form-label fw-medium text-muted small">Tahun Terbit</label>
                <input type="number" name="tahun_terbit" class="form-control" required min="1900" max="<?= date('Y') ?>">
            </div>
            <div class="col-md-4 mb-3">
                <label class="form-label fw-medium text-muted small">Kategori</label>
                <input type="text" name="kategori" class="form-control" required>
            </div>
            <div class="col-md-4 mb-3">
                <label class="form-label fw-medium text-muted small">Stok</label>
                <input type="number" name="stok" class="form-control" required min="0">
            </div>
        </div>
      </div>
      <div class="modal-footer border-top-0 pt-0">
        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Batal</button>
        <button type="submit" name="tambah" class="btn btn-primary px-4">Simpan Buku</button>
      </div>
    </form>
  </div>
</div>
<?php include 'footer.php'; ?>
INNER_EOF

cat << 'INNER_EOF' > php-app/anggota.php
<?php
include 'header.php';
if($role != 'admin') { header("Location: dashboard.php"); exit; }

// Tambah Anggota
if(isset($_POST['tambah'])) {
    $nis = mysqli_real_escape_string($conn, $_POST['nis']);
    $nama = mysqli_real_escape_string($conn, $_POST['nama']);
    $jk = mysqli_real_escape_string($conn, $_POST['jenis_kelamin']);
    $kelas = mysqli_real_escape_string($conn, $_POST['kelas']);
    $username = mysqli_real_escape_string($conn, $_POST['username']);
    $password = md5($_POST['password']);
    
    // Mulai transaksi untuk membuat user dan anggota sekaligus
    mysqli_begin_transaction($conn);
    try {
        // Cek username apakah sudah ada
        $cek_user = mysqli_query($conn, "SELECT username FROM users WHERE username='$username'");
        if(mysqli_num_rows($cek_user) > 0) {
            throw new Exception("Username sudah digunakan!");
        }

        // Buat akun user
        mysqli_query($conn, "INSERT INTO users (nama, username, password, role) VALUES ('$nama', '$username', '$password', 'siswa')");
        $id_user = mysqli_insert_id($conn);
        
        // Buat data anggota
        mysqli_query($conn, "INSERT INTO anggota (nis, nama, jenis_kelamin, kelas, id_user) VALUES ('$nis', '$nama', '$jk', '$kelas', '$id_user')");
        
        mysqli_commit($conn);
        echo "<div class='alert alert-success alert-dismissible fade show'>Anggota dan Akun berhasil dibuat!<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
    } catch(Exception $e) {
        mysqli_rollback($conn);
        echo "<div class='alert alert-danger alert-dismissible fade show'>Gagal: " . $e->getMessage() . "<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
    }
}

$cari = isset($_GET['cari']) ? mysqli_real_escape_string($conn, $_GET['cari']) : '';
?>
<div class="d-flex justify-content-between align-items-center mb-4">
    <h3 class="fw-bold mb-0">Manajemen Anggota</h3>
    <button class="btn btn-primary fw-medium" data-bs-toggle="modal" data-bs-target="#modalTambah">
        <i class="bi bi-person-plus me-1"></i> Tambah Anggota
    </button>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-body p-4">
        <form class="mb-4" method="GET">
            <div class="input-group" style="max-width: 400px;">
                <input type="text" name="cari" class="form-control" placeholder="Cari NIS atau Nama..." value="<?= htmlspecialchars($cari) ?>">
                <button class="btn btn-outline-secondary" type="submit"><i class="bi bi-search"></i></button>
            </div>
        </form>

        <div class="table-responsive">
            <table class="table table-bordered table-hover align-middle">
                <thead class="table-light">
                    <tr>
                        <th>NIS</th>
                        <th>Nama Anggota</th>
                        <th>L/P</th>
                        <th>Kelas</th>
                        <th>Akun (Username)</th>
                        <th class="text-center">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $where = "";
                    if($cari) {
                        $where = "WHERE a.nis LIKE '%$cari%' OR a.nama LIKE '%$cari%'";
                    }
                    $q = mysqli_query($conn, "SELECT a.*, u.username FROM anggota a LEFT JOIN users u ON a.id_user = u.id_user $where ORDER BY a.nis ASC");
                    if(mysqli_num_rows($q) > 0):
                        while($r = mysqli_fetch_assoc($q)):
                    ?>
                    <tr>
                        <td class="fw-medium"><?= htmlspecialchars($r['nis']) ?></td>
                        <td class="fw-bold"><?= htmlspecialchars($r['nama']) ?></td>
                        <td><?= $r['jenis_kelamin'] ?></td>
                        <td><span class="badge bg-info bg-opacity-10 text-info border border-info border-opacity-25"><?= htmlspecialchars($r['kelas']) ?></span></td>
                        <td>
                            <?php if($r['username']): ?>
                                <span class='badge bg-success bg-opacity-10 text-success border border-success border-opacity-25'><i class="bi bi-check-circle me-1"></i> <?= htmlspecialchars($r['username']) ?></span>
                            <?php else: ?>
                                <span class='badge bg-secondary bg-opacity-10 text-secondary border'>Tidak ada</span>
                            <?php endif; ?>
                        </td>
                        <td class="text-center">
                            <button class="btn btn-sm btn-outline-secondary" onclick="alert('Fitur edit & hapus bisa dikembangkan lebih lanjut.')"><i class="bi bi-three-dots"></i></button>
                        </td>
                    </tr>
                    <?php 
                        endwhile; 
                    else:
                        echo "<tr><td colspan='6' class='text-center text-muted py-4'>Tidak ada data anggota.</td></tr>";
                    endif;
                    ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<!-- Modal Tambah -->
<div class="modal fade" id="modalTambah" tabindex="-1">
  <div class="modal-dialog">
    <form method="POST" class="modal-content">
      <div class="modal-header border-bottom-0">
        <h5 class="modal-title fw-bold">Tambah Anggota & Akun Baru</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body py-0">
        <h6 class="text-primary mb-3">Biodata Anggota</h6>
        <div class="row">
            <div class="col-md-6 mb-3">
                <label class="form-label fw-medium text-muted small">NIS</label>
                <input type="text" name="nis" class="form-control" required>
            </div>
            <div class="col-md-6 mb-3">
                <label class="form-label fw-medium text-muted small">Kelas</label>
                <input type="text" name="kelas" class="form-control" required placeholder="Misal: VII A">
            </div>
        </div>
        <div class="mb-3">
            <label class="form-label fw-medium text-muted small">Nama Lengkap</label>
            <input type="text" name="nama" class="form-control" required>
        </div>
        <div class="mb-4">
            <label class="form-label fw-medium text-muted small">Jenis Kelamin</label>
            <select name="jenis_kelamin" class="form-select" required>
                <option value="L">Laki-laki (L)</option>
                <option value="P">Perempuan (P)</option>
            </select>
        </div>
        
        <hr class="border-secondary border-opacity-25">
        <h6 class="text-primary mb-3">Informasi Login Siswa</h6>
        <div class="mb-3">
            <label class="form-label fw-medium text-muted small">Username Login</label>
            <input type="text" name="username" class="form-control" required>
        </div>
        <div class="mb-3">
            <label class="form-label fw-medium text-muted small">Password Default</label>
            <input type="password" name="password" class="form-control" required>
        </div>
      </div>
      <div class="modal-footer border-top-0 pt-3">
        <button type="button" class="btn btn-light" data-bs-dismiss="modal">Batal</button>
        <button type="submit" name="tambah" class="btn btn-primary px-4">Simpan Data</button>
      </div>
    </form>
  </div>
</div>
<?php include 'footer.php'; ?>
INNER_EOF

cat << 'INNER_EOF' > php-app/peminjaman.php
<?php
include 'header.php';
if($role != 'admin') { header("Location: dashboard.php"); exit; }

if(isset($_POST['pinjam'])) {
    $nis = mysqli_real_escape_string($conn, $_POST['nis']);
    $kode_buku = mysqli_real_escape_string($conn, $_POST['kode_buku']);
    $tgl_pinjam = date('Y-m-d');
    $bts_kembali = date('Y-m-d', strtotime('+7 days')); // Setelan default PKL: 7 hari

    // Validasi
    $cek_stok = mysqli_fetch_assoc(mysqli_query($conn, "SELECT stok, judul FROM buku WHERE kode_buku='$kode_buku'"));
    $cek_anggota = mysqli_fetch_assoc(mysqli_query($conn, "SELECT nama FROM anggota WHERE nis='$nis'"));

    if(!$cek_anggota) {
        echo "<div class='alert alert-danger alert-dismissible fade show'>Gagal: NIS tidak terdaftar di sistem!<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
    } elseif(!$cek_stok) {
        echo "<div class='alert alert-danger alert-dismissible fade show'>Gagal: Kode buku tidak ditemukan!<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
    } elseif($cek_stok['stok'] <= 0) {
        echo "<div class='alert alert-warning alert-dismissible fade show'>Gagal: Stok buku '{$cek_stok['judul']}' sedang kosong!<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
    } else {
        mysqli_begin_transaction($conn);
        try {
            mysqli_query($conn, "INSERT INTO peminjaman (nis, kode_buku, tanggal_pinjam, batas_kembali) VALUES ('$nis', '$kode_buku', '$tgl_pinjam', '$bts_kembali')");
            $id_peminjaman = mysqli_insert_id($conn);
            mysqli_query($conn, "UPDATE buku SET stok = stok - 1 WHERE kode_buku='$kode_buku'");
            mysqli_commit($conn);
            echo "<div class='alert alert-success alert-dismissible fade show'>Transaksi berhasil! Buku dipinjam oleh {$cek_anggota['nama']}. Batas kembali: ".date('d M Y', strtotime($bts_kembali)).".<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
        } catch (Exception $e) {
            mysqli_rollback($conn);
            echo "<div class='alert alert-danger'>Terjadi kesalahan sistem.</div>";
        }
    }
}
?>
<h3 class="fw-bold mb-4">Sirkulasi Peminjaman</h3>

<div class="row g-4">
    <!-- Form Peminjaman -->
    <div class="col-md-4">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-primary text-white py-3">
                <h6 class="mb-0 fw-bold"><i class="bi bi-journal-arrow-up me-2"></i>Form Peminjaman</h6>
            </div>
            <div class="card-body p-4">
                <form method="POST">
                    <div class="mb-4">
                        <label class="form-label fw-medium text-muted small">Nomor Induk Siswa (NIS)</label>
                        <input type="text" name="nis" class="form-control form-control-lg fs-6" required placeholder="Masukkan NIS Anggota">
                        <div class="form-text">Pastikan NIS terdaftar aktif.</div>
                    </div>
                    <div class="mb-4">
                        <label class="form-label fw-medium text-muted small">Kode Buku</label>
                        <input type="text" name="kode_buku" class="form-control form-control-lg fs-6" required placeholder="Masukkan Kode Buku">
                    </div>
                    <div class="alert alert-info py-2 small border-0 bg-info bg-opacity-10">
                        <i class="bi bi-info-circle me-1"></i> Lama peminjaman default adalah 7 hari. Stok otomatis berkurang.
                    </div>
                    <button type="submit" name="pinjam" class="btn btn-primary w-100 py-2 fw-medium mt-2">Proses Peminjaman</button>
                </form>
            </div>
        </div>
    </div>
    
    <!-- Daftar Sedang Dipinjam -->
    <div class="col-md-8">
        <div class="card border-0 shadow-sm h-100">
            <div class="card-header bg-white py-3 border-bottom">
                <h6 class="mb-0 fw-bold text-dark">Daftar Buku Sedang Dipinjam</h6>
            </div>
            <div class="card-body p-0">
                <div class="table-responsive" style="max-height: 500px;">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light sticky-top">
                            <tr>
                                <th class="ps-4">ID TRX</th>
                                <th>Nama Peminjam</th>
                                <th>Judul Buku</th>
                                <th>Batas Kembali</th>
                                <th class="pe-4">Status</th>
                            </tr>
                        </thead>
                        <tbody class="border-top-0">
                            <?php
                            $q = mysqli_query($conn, "SELECT p.id_peminjaman, a.nama, b.judul, p.batas_kembali, p.status FROM peminjaman p JOIN anggota a ON p.nis=a.nis JOIN buku b ON p.kode_buku=b.kode_buku WHERE p.status='Dipinjam' OR p.status='Terlambat' ORDER BY p.batas_kembali ASC");
                            if(mysqli_num_rows($q) > 0):
                                while($r = mysqli_fetch_assoc($q)):
                                    $badge = $r['status'] == 'Dipinjam' ? 'bg-primary' : 'bg-danger';
                                    $hari_ini = date('Y-m-d');
                                    $tgl_bts = $r['batas_kembali'];
                                    
                                    $info_waktu = "";
                                    if($r['status'] == 'Terlambat') {
                                        $diff = round((strtotime($hari_ini) - strtotime($tgl_bts)) / (60 * 60 * 24));
                                        $info_waktu = "<br><small class='text-danger'>Lewat $diff hari</small>";
                                    }
                            ?>
                            <tr>
                                <td class="ps-4 fw-medium text-muted">TRX-<?= sprintf('%04d', $r['id_peminjaman']) ?></td>
                                <td class="fw-bold"><?= htmlspecialchars($r['nama']) ?></td>
                                <td class="text-secondary"><?= htmlspecialchars($r['judul']) ?></td>
                                <td><?= date('d/m/Y', strtotime($r['batas_kembali'])) . $info_waktu ?></td>
                                <td class="pe-4"><span class="badge <?= $badge ?> rounded-pill"><?= $r['status'] ?></span></td>
                            </tr>
                            <?php 
                                endwhile; 
                            else:
                            ?>
                            <tr><td colspan="5" class="text-center py-5 text-muted">Tidak ada transaksi peminjaman aktif saat ini.</td></tr>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<?php include 'footer.php'; ?>
INNER_EOF

cat << 'INNER_EOF' > php-app/pengembalian.php
<?php
include 'header.php';
if($role != 'admin') { header("Location: dashboard.php"); exit; }

if(isset($_POST['kembali'])) {
    $id_trx_raw = mysqli_real_escape_string($conn, $_POST['id_peminjaman']);
    // Ekstrak angka jika input mengandung TRX-
    $id_trx = preg_replace('/[^0-9]/', '', $id_trx_raw);
    
    $tgl_kembali = date('Y-m-d');
    
    $cek = mysqli_query($conn, "SELECT p.*, a.nama, b.judul FROM peminjaman p JOIN anggota a ON p.nis=a.nis JOIN buku b ON p.kode_buku=b.kode_buku WHERE p.id_peminjaman='$id_trx' AND (p.status='Dipinjam' OR p.status='Terlambat')");
    
    if(mysqli_num_rows($cek) > 0) {
        $data = mysqli_fetch_assoc($cek);
        $kode_buku = $data['kode_buku'];
        
        // Perhitungan denda (Rp 500 / hari keterlambatan)
        $denda = 0;
        $bts = strtotime($data['batas_kembali']);
        $kmb = strtotime($tgl_kembali);
        if($kmb > $bts) {
            $diff = round(($kmb - $bts) / (60 * 60 * 24));
            $denda = $diff * 500;
        }

        mysqli_begin_transaction($conn);
        try {
            mysqli_query($conn, "UPDATE peminjaman SET tanggal_kembali='$tgl_kembali', status='Dikembalikan', denda='$denda' WHERE id_peminjaman='$id_trx'");
            mysqli_query($conn, "UPDATE buku SET stok = stok + 1 WHERE kode_buku='$kode_buku'");
            mysqli_commit($conn);
            
            $msg = "Berhasil! Buku '{$data['judul']}' telah dikembalikan oleh {$data['nama']}.";
            if($denda > 0) {
                $msg .= " <br><strong>Terdapat denda keterlambatan sebesar Rp ".number_format($denda,0,',','.')."</strong>";
            }
            echo "<div class='alert alert-success alert-dismissible fade show'>$msg<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
        } catch(Exception $e) {
            mysqli_rollback($conn);
            echo "<div class='alert alert-danger'>Terjadi kesalahan sistem.</div>";
        }
    } else {
        echo "<div class='alert alert-danger alert-dismissible fade show'>Gagal: ID Transaksi tidak ditemukan, atau buku sudah dikembalikan sebelumnya!<button type='button' class='btn-close' data-bs-dismiss='alert'></button></div>";
    }
}
?>
<h3 class="fw-bold mb-4">Sirkulasi Pengembalian</h3>

<div class="row">
    <div class="col-md-5">
        <div class="card border-0 shadow-sm">
            <div class="card-header bg-success text-white py-3">
                <h6 class="mb-0 fw-bold"><i class="bi bi-journal-arrow-down me-2"></i>Form Pengembalian</h6>
            </div>
            <div class="card-body p-4">
                <form method="POST">
                    <div class="mb-4">
                        <label class="form-label fw-medium text-muted small">Masukkan ID Transaksi (TRX)</label>
                        <input type="text" name="id_peminjaman" class="form-control form-control-lg fs-6" required placeholder="Contoh: 1 atau TRX-0001" autofocus>
                        <div class="form-text mt-2">Anda dapat melihat ID Transaksi pada menu Peminjaman atau Laporan.</div>
                    </div>
                    
                    <div class="alert bg-light border p-3 rounded mb-4">
                        <h6 class="fw-bold text-dark mb-2"><i class="bi bi-info-circle text-primary me-2"></i>Info Sistem Denda:</h6>
                        <ul class="mb-0 small text-muted ps-3">
                            <li>Dihitung otomatis jika melebihi batas waktu.</li>
                            <li>Tarif denda: <strong>Rp 500 / hari</strong> keterlambatan.</li>
                            <li>Stok buku akan dikembalikan secara otomatis.</li>
                        </ul>
                    </div>

                    <button type="submit" name="kembali" class="btn btn-success w-100 py-2 fw-medium">Proses Pengembalian</button>
                </form>
            </div>
        </div>
    </div>
</div>
<?php include 'footer.php'; ?>
INNER_EOF

cat << 'INNER_EOF' > php-app/laporan.php
<?php
include 'header.php';
if($role == 'siswa') { header("Location: katalog.php"); exit; }

$bulan = isset($_GET['bulan']) ? $_GET['bulan'] : date('m');
$tahun = isset($_GET['tahun']) ? $_GET['tahun'] : date('Y');
?>
<div class="d-flex justify-content-between align-items-center mb-4 d-print-none">
    <h3 class="fw-bold mb-0">Laporan Perpustakaan</h3>
    <button onclick="window.print()" class="btn btn-primary fw-medium shadow-sm">
        <i class="bi bi-printer me-2"></i> Cetak Laporan
    </button>
</div>

<div class="card border-0 shadow-sm mb-4 d-print-none">
    <div class="card-body p-4">
        <form class="row g-3 align-items-end" method="GET">
            <div class="col-md-4">
                <label class="form-label fw-medium text-muted small">Pilih Bulan</label>
                <select name="bulan" class="form-select">
                    <?php 
                    $nm_bulan = ['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
                    for($i=1; $i<=12; $i++): 
                        $val = sprintf('%02d', $i);
                    ?>
                        <option value="<?= $val ?>" <?= $bulan == $val ? 'selected' : '' ?>><?= $nm_bulan[$i-1] ?></option>
                    <?php endfor; ?>
                </select>
            </div>
            <div class="col-md-4">
                <label class="form-label fw-medium text-muted small">Pilih Tahun</label>
                <select name="tahun" class="form-select">
                    <?php for($i=2023; $i<=date('Y'); $i++): ?>
                        <option value="<?= $i ?>" <?= $tahun == $i ? 'selected' : '' ?>><?= $i ?></option>
                    <?php endfor; ?>
                </select>
            </div>
            <div class="col-md-4">
                <button type="submit" class="btn btn-secondary w-100 fw-medium">Filter Data</button>
            </div>
        </form>
    </div>
</div>

<div class="card border-0 shadow-sm print-area">
    <div class="card-body p-4">
        <!-- Header Laporan (Khusus Print) -->
        <div class="text-center mb-4 pb-3 border-bottom border-dark print-header">
            <h4 class="fw-bold text-uppercase mb-1">MTs Nurul Hidayah</h4>
            <p class="mb-0">Laporan Transaksi Perpustakaan</p>
            <p class="mb-0 text-muted small">Periode: <?= $nm_bulan[(int)$bulan-1] ?> <?= $tahun ?></p>
        </div>

        <div class="table-responsive">
            <table class="table table-bordered table-striped align-middle">
                <thead class="table-dark">
                    <tr>
                        <th class="text-center">No</th>
                        <th>ID TRX</th>
                        <th>Nama Peminjam</th>
                        <th>Judul Buku</th>
                        <th>Tgl Pinjam</th>
                        <th>Tgl Kembali</th>
                        <th>Status</th>
                        <th class="text-end">Denda</th>
                    </tr>
                </thead>
                <tbody>
                    <?php
                    $q = mysqli_query($conn, "SELECT p.*, a.nama, b.judul FROM peminjaman p JOIN anggota a ON p.nis=a.nis JOIN buku b ON p.kode_buku=b.kode_buku WHERE MONTH(p.tanggal_pinjam)='$bulan' AND YEAR(p.tanggal_pinjam)='$tahun' ORDER BY p.tanggal_pinjam ASC");
                    $total_denda = 0;
                    $no = 1;
                    if(mysqli_num_rows($q) > 0):
                        while($r = mysqli_fetch_assoc($q)):
                            $total_denda += $r['denda'];
                    ?>
                    <tr>
                        <td class="text-center"><?= $no++ ?></td>
                        <td>TRX-<?= sprintf('%04d', $r['id_peminjaman']) ?></td>
                        <td><?= htmlspecialchars($r['nama']) ?></td>
                        <td><?= htmlspecialchars($r['judul']) ?></td>
                        <td><?= date('d/m/Y', strtotime($r['tanggal_pinjam'])) ?></td>
                        <td><?= $r['tanggal_kembali'] ? date('d/m/Y', strtotime($r['tanggal_kembali'])) : '-' ?></td>
                        <td><?= $r['status'] ?></td>
                        <td class="text-end">Rp <?= number_format($r['denda'], 0, ',', '.') ?></td>
                    </tr>
                    <?php 
                        endwhile; 
                    else:
                    ?>
                    <tr><td colspan="8" class="text-center py-4">Tidak ada data transaksi pada periode ini.</td></tr>
                    <?php endif; ?>
                </tbody>
                <tfoot>
                    <tr class="fw-bold bg-light">
                        <td colspan="7" class="text-end py-3">Total Akumulasi Denda:</td>
                        <td class="text-end text-danger fs-5 py-3">Rp <?= number_format($total_denda, 0, ',', '.') ?></td>
                    </tr>
                </tfoot>
            </table>
        </div>
        
        <!-- Kolom Tanda Tangan (Khusus Print) -->
        <div class="row mt-5 d-none d-print-flex">
            <div class="col-8"></div>
            <div class="col-4 text-center">
                <p class="mb-5">Mengetahui,<br>Kepala Perpustakaan</p>
                <p class="fw-bold mb-0">( ..................................... )</p>
            </div>
        </div>
    </div>
</div>

<style>
@media print {
    body { background: white !important; }
    .sidebar, .navbar, .d-print-none { display: none !important; }
    .content { padding: 0 !important; width: 100% !important; margin: 0 !important; }
    .card { box-shadow: none !important; border: none !important; }
    .print-header { display: block !important; }
    .table-dark { color: black !important; background-color: #f8f9fa !important; border-color: #dee2e6 !important; }
    .table-dark th { color: black !important; background-color: #e9ecef !important; border-color: #dee2e6 !important; }
}
.print-header { display: none; }
</style>
<?php include 'footer.php'; ?>
INNER_EOF

cat << 'INNER_EOF' > php-app/katalog.php
<?php
include 'header.php';
if($role != 'siswa') { header("Location: dashboard.php"); exit; }
$cari = isset($_GET['cari']) ? mysqli_real_escape_string($conn, $_GET['cari']) : '';
?>
<div class="d-flex justify-content-between align-items-end mb-4">
    <div>
        <h3 class="fw-bold mb-1">Katalog Buku Digital</h3>
        <p class="text-muted mb-0">Cari dan temukan buku favoritmu di perpustakaan kami.</p>
    </div>
</div>

<div class="card border-0 shadow-sm mb-4 bg-primary text-white overflow-hidden position-relative">
    <div class="card-body p-4 p-md-5 position-relative" style="z-index: 2;">
        <div class="row justify-content-center">
            <div class="col-md-8 text-center">
                <h4 class="fw-bold mb-3">Pencarian Koleksi</h4>
                <form method="GET">
                    <div class="input-group input-group-lg shadow-sm">
                        <span class="input-group-text bg-white border-0 text-muted"><i class="bi bi-search"></i></span>
                        <input type="text" name="cari" class="form-control border-0" placeholder="Ketik judul buku, pengarang, atau kategori..." value="<?= htmlspecialchars($cari) ?>">
                        <button class="btn btn-light fw-bold px-4" type="submit">Cari</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <i class="bi bi-book-half position-absolute opacity-10" style="font-size: 15rem; right: -20px; top: -50px; transform: rotate(15deg); z-index: 1;"></i>
</div>

<div class="row g-4">
    <?php
    $query = "SELECT * FROM buku WHERE judul LIKE '%$cari%' OR pengarang LIKE '%$cari%' OR kategori LIKE '%$cari%'";
    $result = mysqli_query($conn, $query);
    if(mysqli_num_rows($result) > 0):
        while($r = mysqli_fetch_assoc($result)):
    ?>
    <div class="col-xl-3 col-lg-4 col-md-6">
        <div class="card h-100 border-0 shadow-sm book-card transition-hover">
            <div class="card-body text-center p-4">
                <div class="mb-4 bg-light rounded-3 py-4 position-relative">
                    <i class="bi bi-book text-primary opacity-75" style="font-size: 4rem;"></i>
                    <?php if($r['stok'] > 0): ?>
                        <span class="position-absolute top-0 end-0 badge bg-success m-2 shadow-sm">Tersedia <?= $r['stok'] ?></span>
                    <?php else: ?>
                        <span class="position-absolute top-0 end-0 badge bg-danger m-2 shadow-sm">Kosong</span>
                    <?php endif; ?>
                </div>
                <h6 class="fw-bold mb-1 text-truncate" title="<?= htmlspecialchars($r['judul']) ?>"><?= htmlspecialchars($r['judul']) ?></h6>
                <p class="text-muted small mb-2"><?= htmlspecialchars($r['pengarang']) ?></p>
                
                <div class="d-flex justify-content-center gap-2 mt-3">
                    <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25"><?= htmlspecialchars($r['kategori']) ?></span>
                    <span class="badge bg-secondary bg-opacity-10 text-secondary border border-secondary border-opacity-25"><?= $r['tahun_terbit'] ?></span>
                </div>
            </div>
        </div>
    </div>
    <?php 
        endwhile;
    else:
        echo "<div class='col-12'><div class='alert alert-warning border-0 shadow-sm text-center py-4'><i class=".'bi bi-exclamation-circle-fill text-warning fs-3 d-block mb-2'."></i>Buku yang kamu cari tidak ditemukan.</div></div>";
    endif;
    ?>
</div>

<style>
.book-card { transition: transform 0.2s, box-shadow 0.2s; }
.book-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.1) !important; }
</style>
<?php include 'footer.php'; ?>
INNER_EOF

cat << 'INNER_EOF' > php-app/riwayat.php
<?php
include 'header.php';
if($role != 'siswa') { header("Location: dashboard.php"); exit; }
$nis = $_SESSION['nis'];
?>
<h3 class="fw-bold mb-4">Riwayat Peminjaman Saya</h3>

<div class="card border-0 shadow-sm">
    <div class="card-header bg-white py-3 border-bottom">
        <h6 class="mb-0 fw-bold text-dark"><i class="bi bi-clock-history me-2 text-primary"></i>Catatan Transaksi</h6>
    </div>
    <div class="card-body p-0">
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                    <tr>
                        <th class="ps-4">ID Transaksi</th>
                        <th>Judul Buku</th>
                        <th>Tanggal Pinjam</th>
                        <th>Batas Kembali</th>
                        <th>Status</th>
                        <th class="pe-4">Tagihan Denda</th>
                    </tr>
                </thead>
                <tbody class="border-top-0">
                    <?php
                    // Update the running fine logic for visualization for student
                    mysqli_query($conn, "UPDATE peminjaman SET status='Terlambat', denda = DATEDIFF(CURDATE(), batas_kembali) * 500 WHERE status='Dipinjam' AND CURDATE() > batas_kembali AND nis='$nis'");
                    mysqli_query($conn, "UPDATE peminjaman SET denda = DATEDIFF(CURDATE(), batas_kembali) * 500 WHERE status='Terlambat' AND tanggal_kembali IS NULL AND nis='$nis'");

                    $q = mysqli_query($conn, "SELECT p.*, b.judul FROM peminjaman p JOIN buku b ON p.kode_buku=b.kode_buku WHERE p.nis='$nis' ORDER BY p.id_peminjaman DESC");
                    if(mysqli_num_rows($q) > 0):
                        while($r = mysqli_fetch_assoc($q)):
                            $badge = $r['status'] == 'Dipinjam' ? 'bg-primary' : ($r['status'] == 'Dikembalikan' ? 'bg-success' : 'bg-danger');
                    ?>
                    <tr>
                        <td class="ps-4"><span class="text-muted fw-medium">TRX-<?= sprintf('%04d', $r['id_peminjaman']) ?></span></td>
                        <td class="fw-bold"><?= htmlspecialchars($r['judul']) ?></td>
                        <td><?= date('d M Y', strtotime($r['tanggal_pinjam'])) ?></td>
                        <td><?= date('d M Y', strtotime($r['batas_kembali'])) ?></td>
                        <td><span class="badge <?= $badge ?> rounded-pill px-3"><?= $r['status'] ?></span></td>
                        <td class="pe-4 text-danger fw-medium"><?= $r['denda'] > 0 ? 'Rp '.number_format($r['denda'], 0, ',', '.') : '-' ?></td>
                    </tr>
                    <?php 
                        endwhile; 
                    else:
                        echo "<tr><td colspan='6' class='text-center py-5 text-muted'>Belum ada riwayat peminjaman. Ayo pinjam buku pertamamu!</td></tr>";
                    endif;
                    ?>
                </tbody>
            </table>
        </div>
    </div>
</div>
<?php include 'footer.php'; ?>
INNER_EOF
