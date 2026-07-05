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
