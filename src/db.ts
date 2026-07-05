export const initDB = () => {
  if (!localStorage.getItem('users')) {
    localStorage.setItem('users', JSON.stringify([
      { id: 1, nama: 'Admin Perpus', username: 'admin', password: '123', role: 'admin' },
      { id: 2, nama: 'Kepala Madrasah', username: 'kepala', password: '123', role: 'kepala' },
      { id: 3, nama: 'Ahmad Rizki', username: 'siswa', password: '123', role: 'siswa' }
    ]));
  }
  if (!localStorage.getItem('buku')) {
    localStorage.setItem('buku', JSON.stringify([
      { kode_buku: 'B001', judul: 'Pemrograman Web Dasar', pengarang: 'Ahmad Rizki', penerbit: 'Informatika', tahun_terbit: 2021, kategori: 'Teknologi', stok: 5 },
      { kode_buku: 'B002', judul: 'Sejarah Indonesia', pengarang: 'Siti Aisyah', penerbit: 'Erlangga', tahun_terbit: 2020, kategori: 'Sejarah', stok: 3 },
      { kode_buku: 'B003', judul: 'Matematika untuk SMA', pengarang: 'Budi Santoso', penerbit: 'BSE', tahun_terbit: 2019, kategori: 'Matematika', stok: 10 }
    ]));
  }
  if (!localStorage.getItem('anggota')) {
    localStorage.setItem('anggota', JSON.stringify([
      { nis: '1001', nama: 'Ahmad Rizki', jenis_kelamin: 'L', kelas: 'VII A', id_user: 3 },
      { nis: '1002', nama: 'Siti Aisyah', jenis_kelamin: 'P', kelas: 'VIII B', id_user: null }
    ]));
  }
  if (!localStorage.getItem('peminjaman')) {
    localStorage.setItem('peminjaman', JSON.stringify([
      { id_peminjaman: 1, nis: '1001', kode_buku: 'B001', tanggal_pinjam: '2024-05-20', batas_kembali: '2024-05-27', tanggal_kembali: null, status: 'Dipinjam', denda: 0 },
      { id_peminjaman: 2, nis: '1002', kode_buku: 'B002', tanggal_pinjam: '2024-05-12', batas_kembali: '2024-05-19', tanggal_kembali: '2024-05-19', status: 'Dikembalikan', denda: 0 },
      { id_peminjaman: 3, nis: '1001', kode_buku: 'B003', tanggal_pinjam: '2024-05-10', batas_kembali: '2024-05-17', tanggal_kembali: null, status: 'Terlambat', denda: 15000 }
    ]));
  }
};

export const getDB = (key: string) => {
  return JSON.parse(localStorage.getItem(key) || '[]');
};

export const setDB = (key: string, data: any) => {
  localStorage.setItem(key, JSON.stringify(data));
};
