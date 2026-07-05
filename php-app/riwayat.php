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
