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
