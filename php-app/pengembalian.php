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
