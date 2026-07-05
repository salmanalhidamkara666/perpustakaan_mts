/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
 */

import React, { useState, useEffect } from 'react';
import { 
  LayoutDashboard, Book, Users, ArrowRightLeft, 
  CornerDownLeft, FileText, LogOut, Search, 
  Plus, Edit, Trash2, CheckCircle, 
  MoreVertical, Clock
} from 'lucide-react';
import { initDB, getDB, setDB } from './db';

export default function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [currentUser, setCurrentUser] = useState<any>(null);
  
  useEffect(() => {
    initDB();
    const storedUser = localStorage.getItem('currentUser');
    if (storedUser) {
      setCurrentUser(JSON.parse(storedUser));
      setIsLoggedIn(true);
    }
  }, []);

  const handleLogin = (user: any) => {
    setCurrentUser(user);
    setIsLoggedIn(true);
    localStorage.setItem('currentUser', JSON.stringify(user));
  };

  const handleLogout = () => {
    setCurrentUser(null);
    setIsLoggedIn(false);
    localStorage.removeItem('currentUser');
  };
  
  if (!isLoggedIn) {
    return <LoginScreen onLogin={handleLogin} />;
  }

  return <DashboardLayout user={currentUser} onLogout={handleLogout} />;
}

function LoginScreen({ onLogin }: { onLogin: (user: any) => void }) {
  const [username, setUsername] = useState('admin');
  const [password, setPassword] = useState('123');
  const [error, setError] = useState('');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const users = getDB('users');
    const user = users.find((u: any) => u.username === username && u.password === password);
    if (user) {
      onLogin(user);
    } else {
      setError('Username atau password salah!');
    }
  };

  return (
    <div className="min-h-screen bg-[#f8fafc] flex items-center justify-center p-6">
      <div className="w-full max-w-md bg-white p-8 rounded-2xl border border-slate-200 shadow-xl">
        <div className="flex justify-center mb-6">
          <div className="w-16 h-16 bg-blue-600 rounded-2xl flex items-center justify-center text-white font-bold text-3xl shadow-lg shadow-blue-500/30">
            NH
          </div>
        </div>
        <h1 className="text-2xl font-bold text-center text-slate-800 mb-2">Perpustakaan MTs</h1>
        <p className="text-center text-slate-500 mb-8 text-sm">Masuk untuk mengelola sistem perpustakaan</p>

        {error && <div className="mb-4 p-3 bg-red-50 text-red-600 rounded-lg text-sm">{error}</div>}

        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label className="block text-xs font-semibold text-slate-600 uppercase tracking-wide mb-1">Username</label>
            <input 
              type="text" 
              value={username}
              onChange={(e) => setUsername(e.target.value)}
              className="w-full bg-slate-50 border border-slate-200 rounded-lg px-4 py-2.5 text-slate-800 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold text-slate-600 uppercase tracking-wide mb-1">Password</label>
            <input 
              type="password" 
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className="w-full bg-slate-50 border border-slate-200 rounded-lg px-4 py-2.5 text-slate-800 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition-all"
            />
          </div>
          <button 
            type="submit"
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-2.5 rounded-lg shadow-sm transition-all mt-4"
          >
            Masuk ke Dashboard
          </button>
        </form>
        
        <div className="mt-8 p-4 bg-blue-50 border border-blue-200 rounded-lg text-xs text-blue-700 text-center">
          <strong>Aplikasi Siap Vercel!</strong> Database telah dipindahkan ke <em>Local Storage</em> sehingga langsung berjalan di Vercel tanpa XAMPP.
        </div>
      </div>
    </div>
  );
}

function DashboardLayout({ user, onLogout }: { user: any, onLogout: () => void }) {
  const [activeTab, setActiveTab] = useState('dashboard');

  const menuItems = [
    { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
    { id: 'buku', label: 'Data Buku', icon: Book },
    { id: 'anggota', label: 'Data Anggota', icon: Users },
    { id: 'peminjaman', label: 'Peminjaman', icon: ArrowRightLeft },
    { id: 'pengembalian', label: 'Pengembalian', icon: CornerDownLeft },
    { id: 'laporan', label: 'Laporan', icon: FileText },
  ];

  return (
    <div className="flex h-screen w-full bg-[#f8fafc] text-slate-800 font-sans overflow-hidden">
      {/* Sidebar Nav */}
      <aside className="w-64 bg-[#1e293b] flex flex-col shrink-0">
        <div className="p-6 flex items-center gap-3 border-b border-slate-700/50">
          <div className="w-10 h-10 bg-blue-600 rounded-lg flex items-center justify-center text-white font-bold text-xl shadow-lg shadow-blue-500/20">NH</div>
          <div>
            <h1 className="text-white font-bold leading-tight text-sm">Nurul Hidayah</h1>
            <p className="text-blue-400 text-[10px] uppercase tracking-wider font-semibold">Library System</p>
          </div>
        </div>
        
        <nav className="flex-1 p-4 space-y-1">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                onClick={() => setActiveTab(item.id)}
                className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg font-medium transition-all ${
                  isActive 
                    ? 'bg-blue-600/10 text-blue-400 border border-blue-500/20' 
                    : 'text-slate-400 hover:bg-slate-800/50 hover:text-white border border-transparent'
                }`}
              >
                <Icon size={20} />
                <span>{item.label}</span>
              </button>
            )
          })}
        </nav>

        <div className="p-4 border-t border-slate-700/50">
          <div className="bg-slate-800/50 p-3 rounded-lg flex items-center gap-3">
            <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center text-xs font-bold text-white">
              {user?.nama?.substring(0, 2).toUpperCase() || 'AD'}
            </div>
            <div className="flex-1 text-left">
              <p className="text-xs text-white font-semibold leading-none">{user?.nama || 'Admin Petugas'}</p>
              <p className="text-[10px] text-slate-400 mt-1 flex items-center gap-1 capitalize">
                <span className="w-1.5 h-1.5 rounded-full bg-green-500"></span> {user?.role || 'Online'}
              </p>
            </div>
            <button onClick={onLogout} className="text-slate-400 hover:text-red-400 transition-colors">
              <LogOut size={16} />
            </button>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <main className="flex-1 flex flex-col h-full overflow-hidden">
        {/* Header */}
        <header className="h-16 bg-white border-b border-slate-200 px-8 flex items-center justify-between shrink-0">
          <h2 className="text-lg font-bold text-slate-800 capitalize">
            {menuItems.find(m => m.id === activeTab)?.label || 'Dashboard'}
          </h2>
          <div className="flex items-center gap-4">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={14} />
              <input 
                type="text" 
                placeholder="Cari data..." 
                className="bg-slate-100 border-none rounded-full pl-9 pr-4 py-1.5 text-xs w-64 focus:ring-2 focus:ring-blue-500 outline-none" 
              />
            </div>
          </div>
        </header>

        {/* Scrollable content area */}
        <div className="flex-1 p-8 overflow-y-auto bg-[#f8fafc]">
          {activeTab === 'dashboard' && <DashboardView />}
          {activeTab === 'buku' && <DataBukuView />}
          {activeTab === 'anggota' && <DataAnggotaView />}
          {activeTab === 'peminjaman' && <PeminjamanView />}
          {activeTab === 'pengembalian' && <PengembalianView />}
          {activeTab === 'laporan' && <LaporanView />}
        </div>
      </main>
    </div>
  );
}

function DashboardView() {
  const [stats, setStats] = useState({ buku: 0, anggota: 0, peminjamanAktif: 0, totalDenda: 0 });
  const [recentTransactions, setRecentTransactions] = useState([]);

  useEffect(() => {
    const buku = getDB('buku');
    const anggota = getDB('anggota');
    const peminjaman = getDB('peminjaman');

    const aktif = peminjaman.filter((p: any) => p.status === 'Dipinjam' || p.status === 'Terlambat');
    const denda = peminjaman.reduce((sum: number, p: any) => sum + (p.denda || 0), 0);

    setStats({
      buku: buku.length,
      anggota: anggota.length,
      peminjamanAktif: aktif.length,
      totalDenda: denda
    });

    setRecentTransactions(peminjaman.slice(-5).reverse());
  }, []);

  return (
    <>
      {/* Stat Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-6 mb-8">
        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-slate-500 text-xs font-medium uppercase tracking-tight mb-1">Koleksi Buku</p>
              <h3 className="text-2xl font-bold text-slate-800">{stats.buku}</h3>
            </div>
            <div className="p-2 bg-blue-50 rounded-lg text-blue-600">
              <Book size={24} />
            </div>
          </div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-slate-500 text-xs font-medium uppercase tracking-tight mb-1">Total Anggota</p>
              <h3 className="text-2xl font-bold text-slate-800">{stats.anggota}</h3>
            </div>
            <div className="p-2 bg-purple-50 rounded-lg text-purple-600">
              <Users size={24} />
            </div>
          </div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-slate-500 text-xs font-medium uppercase tracking-tight mb-1">Aktif Pinjam</p>
              <h3 className="text-2xl font-bold text-slate-800">{stats.peminjamanAktif}</h3>
            </div>
            <div className="p-2 bg-emerald-50 rounded-lg text-emerald-600">
              <ArrowRightLeft size={24} />
            </div>
          </div>
        </div>

        <div className="bg-white p-5 rounded-xl border border-slate-200 shadow-sm">
          <div className="flex justify-between items-start">
            <div>
              <p className="text-slate-500 text-xs font-medium uppercase tracking-tight mb-1">Total Denda</p>
              <h3 className="text-2xl font-bold text-slate-800">Rp {stats.totalDenda.toLocaleString('id-ID')}</h3>
            </div>
            <div className="p-2 bg-red-50 rounded-lg text-red-600">
              <FileText size={24} />
            </div>
          </div>
        </div>
      </div>

      {/* Table Area */}
      <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
        <div className="px-6 py-4 border-b border-slate-200 flex justify-between items-center">
          <h4 className="font-bold text-slate-800">Transaksi Terakhir</h4>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full text-left">
            <thead className="bg-slate-50 text-[10px] uppercase text-slate-400 font-bold">
              <tr>
                <th className="px-6 py-3">ID Transaksi</th>
                <th className="px-6 py-3">NIS</th>
                <th className="px-6 py-3">Kode Buku</th>
                <th className="px-6 py-3">Tgl Pinjam</th>
                <th className="px-6 py-3">Status</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {recentTransactions.map((trx: any) => (
                <tr key={trx.id_peminjaman} className="hover:bg-slate-50/50 text-xs transition-colors">
                  <td className="px-6 py-4 font-mono text-slate-500">TRX-{(trx.id_peminjaman).toString().padStart(4, '0')}</td>
                  <td className="px-6 py-4 font-semibold text-slate-800">{trx.nis}</td>
                  <td className="px-6 py-4">{trx.kode_buku}</td>
                  <td className="px-6 py-4">{trx.tanggal_pinjam}</td>
                  <td className="px-6 py-4">
                    <span className={`px-2 py-1 rounded text-[10px] font-bold ${
                      trx.status === 'Dikembalikan' ? 'bg-emerald-100 text-emerald-700' :
                      trx.status === 'Terlambat' ? 'bg-red-100 text-red-700' :
                      'bg-blue-100 text-blue-700'
                    }`}>
                      {trx.status}
                    </span>
                  </td>
                </tr>
              ))}
              {recentTransactions.length === 0 && (
                <tr>
                  <td colSpan={5} className="px-6 py-8 text-center text-slate-500">Belum ada transaksi</td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </>
  );
}

function DataBukuView() {
  const [buku, setBuku] = useState([]);

  useEffect(() => {
    setBuku(getDB('buku'));
  }, []);

  return (
    <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
      <div className="px-6 py-4 border-b border-slate-200 flex justify-between items-center">
        <h4 className="font-bold text-slate-800">Daftar Buku</h4>
        <button className="bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-3 py-1.5 rounded-lg flex items-center gap-1 transition-all">
          <Plus size={14} /> Tambah Buku
        </button>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-left">
          <thead className="bg-slate-50 text-[10px] uppercase text-slate-400 font-bold">
            <tr>
              <th className="px-6 py-3">Kode Buku</th>
              <th className="px-6 py-3">Judul Buku</th>
              <th className="px-6 py-3">Pengarang</th>
              <th className="px-6 py-3">Penerbit</th>
              <th className="px-6 py-3">Stok</th>
              <th className="px-6 py-3 text-right">Aksi</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {buku.map((b: any) => (
              <tr key={b.kode_buku} className="hover:bg-slate-50/50 text-xs transition-colors">
                <td className="px-6 py-4 font-mono text-slate-500">{b.kode_buku}</td>
                <td className="px-6 py-4 font-semibold text-slate-800">{b.judul}</td>
                <td className="px-6 py-4">{b.pengarang}</td>
                <td className="px-6 py-4">{b.penerbit}</td>
                <td className="px-6 py-4"><span className="bg-slate-100 text-slate-700 px-2 py-1 rounded font-mono">{b.stok}</span></td>
                <td className="px-6 py-4 flex justify-end gap-2">
                  <button className="p-1.5 bg-blue-50 text-blue-600 rounded hover:bg-blue-100"><Edit size={14} /></button>
                  <button className="p-1.5 bg-red-50 text-red-600 rounded hover:bg-red-100"><Trash2 size={14} /></button>
                </td>
              </tr>
            ))}
            {buku.length === 0 && (
              <tr>
                <td colSpan={6} className="px-6 py-8 text-center text-slate-500">Belum ada buku</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function DataAnggotaView() {
  const [anggota, setAnggota] = useState([]);

  useEffect(() => {
    setAnggota(getDB('anggota'));
  }, []);

  return (
    <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
      <div className="px-6 py-4 border-b border-slate-200 flex justify-between items-center">
        <h4 className="font-bold text-slate-800">Daftar Anggota</h4>
        <button className="bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-3 py-1.5 rounded-lg flex items-center gap-1 transition-all">
          <Plus size={14} /> Tambah Anggota
        </button>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-left">
          <thead className="bg-slate-50 text-[10px] uppercase text-slate-400 font-bold">
            <tr>
              <th className="px-6 py-3">NIS</th>
              <th className="px-6 py-3">Nama Anggota</th>
              <th className="px-6 py-3">L/P</th>
              <th className="px-6 py-3">Kelas</th>
              <th className="px-6 py-3 text-right">Aksi</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {anggota.map((a: any) => (
              <tr key={a.nis} className="hover:bg-slate-50/50 text-xs transition-colors">
                <td className="px-6 py-4 font-mono text-slate-500">{a.nis}</td>
                <td className="px-6 py-4 font-semibold text-slate-800">{a.nama}</td>
                <td className="px-6 py-4">{a.jenis_kelamin}</td>
                <td className="px-6 py-4">{a.kelas}</td>
                <td className="px-6 py-4 flex justify-end gap-2">
                  <button className="p-1.5 bg-blue-50 text-blue-600 rounded hover:bg-blue-100"><Edit size={14} /></button>
                  <button className="p-1.5 bg-red-50 text-red-600 rounded hover:bg-red-100"><Trash2 size={14} /></button>
                </td>
              </tr>
            ))}
            {anggota.length === 0 && (
              <tr>
                <td colSpan={5} className="px-6 py-8 text-center text-slate-500">Belum ada anggota</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

function PeminjamanView() {
  return (
    <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
      <div className="px-6 py-4 border-b border-slate-200 flex justify-between items-center">
        <h4 className="font-bold text-slate-800">Transaksi Peminjaman</h4>
        <button className="bg-blue-600 hover:bg-blue-700 text-white text-xs font-bold px-3 py-1.5 rounded-lg flex items-center gap-1 transition-all">
          <Plus size={14} /> Transaksi Baru
        </button>
      </div>
      <div className="p-8 text-center text-slate-500">
        <ArrowRightLeft size={48} className="mx-auto text-slate-300 mb-4" />
        <p>Form dan tabel transaksi peminjaman akan ditampilkan di sini.</p>
      </div>
    </div>
  );
}

function PengembalianView() {
  return (
    <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
      <div className="px-6 py-4 border-b border-slate-200 flex justify-between items-center">
        <h4 className="font-bold text-slate-800">Proses Pengembalian</h4>
      </div>
      <div className="p-6">
        <div className="max-w-md bg-slate-50 p-6 rounded-xl border border-slate-200">
          <label className="block text-xs font-semibold text-slate-600 uppercase tracking-wide mb-2">Cari ID Transaksi / Scan Barcode</label>
          <div className="flex gap-2">
            <input 
              type="text" 
              placeholder="Contoh: TRX-00421" 
              className="flex-1 bg-white border border-slate-300 rounded-lg px-4 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
            />
            <button className="bg-slate-800 text-white px-4 py-2 rounded-lg font-bold text-sm">Cari</button>
          </div>
        </div>
      </div>
    </div>
  );
}

function LaporanView() {
  return (
    <div className="bg-white rounded-xl border border-slate-200 shadow-sm">
      <div className="px-6 py-4 border-b border-slate-200 flex justify-between items-center">
        <h4 className="font-bold text-slate-800">Laporan Perpustakaan</h4>
      </div>
      <div className="p-6 grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="border border-slate-200 rounded-xl p-5 hover:border-blue-400 transition-colors cursor-pointer group">
          <div className="w-10 h-10 bg-blue-50 text-blue-600 rounded-lg flex items-center justify-center mb-3 group-hover:bg-blue-600 group-hover:text-white transition-colors">
            <FileText size={20} />
          </div>
          <h5 className="font-bold text-slate-800 mb-1">Laporan Peminjaman</h5>
          <p className="text-xs text-slate-500">Cetak data peminjaman bulanan</p>
        </div>
        <div className="border border-slate-200 rounded-xl p-5 hover:border-blue-400 transition-colors cursor-pointer group">
          <div className="w-10 h-10 bg-green-50 text-green-600 rounded-lg flex items-center justify-center mb-3 group-hover:bg-green-600 group-hover:text-white transition-colors">
            <Book size={20} />
          </div>
          <h5 className="font-bold text-slate-800 mb-1">Katalog Buku</h5>
          <p className="text-xs text-slate-500">Cetak daftar ketersediaan buku</p>
        </div>
        <div className="border border-slate-200 rounded-xl p-5 hover:border-blue-400 transition-colors cursor-pointer group">
          <div className="w-10 h-10 bg-purple-50 text-purple-600 rounded-lg flex items-center justify-center mb-3 group-hover:bg-purple-600 group-hover:text-white transition-colors">
            <Users size={20} />
          </div>
          <h5 className="font-bold text-slate-800 mb-1">Laporan Anggota</h5>
          <p className="text-xs text-slate-500">Cetak data anggota perpustakaan</p>
        </div>
      </div>
    </div>
  );
}


