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
        <div class="flex-grow-1 bg-[#f8fafc]" style="min-width: 0;">
            <nav class="navbar navbar-expand-lg navbar-light bg-white border border-slate-200 shadow-sm rounded-xl px-4 py-3 d-print-none">
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
