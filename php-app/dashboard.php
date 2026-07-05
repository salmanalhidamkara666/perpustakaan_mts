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
        <div class="card bg-white border border-slate-200 shadow-sm rounded-xl h-100">
            <div class="card-body p-4 d-flex align-items-center">
                <div class="bg-primary bg-opacity-10 p-3 rounded-3 me-3 text-primary">
                    <i class="bi bi-book fs-3"></i>
                </div>
                <div>
                    <p class="text-slate-500 text-xs font-medium uppercase tracking-tight mb-1">Total Buku</p>
                    <h3 class="mb-0 fw-bold"><?= $total_buku ?></h3>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-white border border-slate-200 shadow-sm rounded-xl h-100">
            <div class="card-body p-4 d-flex align-items-center">
                <div class="bg-success bg-opacity-10 p-3 rounded-3 me-3 text-success">
                    <i class="bi bi-people fs-3"></i>
                </div>
                <div>
                    <p class="text-slate-500 text-xs font-medium uppercase tracking-tight mb-1">Anggota Aktif</p>
                    <h3 class="mb-0 fw-bold"><?= $total_anggota ?></h3>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-white border border-slate-200 shadow-sm rounded-xl h-100">
            <div class="card-body p-4 d-flex align-items-center">
                <div class="bg-warning bg-opacity-10 p-3 rounded-3 me-3 text-warning">
                    <i class="bi bi-arrow-left-right fs-3"></i>
                </div>
                <div>
                    <p class="text-slate-500 text-xs font-medium uppercase tracking-tight mb-1">Buku Dipinjam</p>
                    <h3 class="mb-0 fw-bold"><?= $buku_dipinjam ?></h3>
                </div>
            </div>
        </div>
    </div>
    <div class="col-md-3">
        <div class="card bg-white border border-slate-200 shadow-sm rounded-xl h-100">
            <div class="card-body p-4 d-flex align-items-center">
                <div class="bg-danger bg-opacity-10 p-3 rounded-3 me-3 text-danger">
                    <i class="bi bi-cash-coin fs-3"></i>
                </div>
                <div>
                    <p class="text-slate-500 text-xs font-medium uppercase tracking-tight mb-1">Total Denda</p>
                    <h4 class="mb-0 fw-bold">Rp <?= number_format($total_denda ?: 0, 0, ',', '.') ?></h4>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="card border-0 shadow-sm">
    <div class="card-header bg-white px-6 py-4 border-b border-slate-200">
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
