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
