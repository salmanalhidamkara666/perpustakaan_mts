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
