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
