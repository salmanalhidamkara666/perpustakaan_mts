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
