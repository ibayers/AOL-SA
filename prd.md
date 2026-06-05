# 📄 PRODUCT REQUIREMENT DOCUMENT (PRD)

## Personal Finance Tracker App

## 1. 📌 Product Overview

**Nama Produk:** Moni
**Platform:** Mobile (Android & iOS - Flutter)

### Deskripsi:

Aplikasi personal finance tracker untuk membantu pengguna mencatat, mengelola, dan menganalisis pengeluaran serta pemasukan secara sederhana dan fleksibel.

---

## 2. 🎯 Problem Statement

Banyak individu:

- Tidak tahu uang mereka habis ke mana
- Menggunakan banyak metode pembayaran (cash, e-wallet, bank)
- Tidak memiliki insight terhadap kebiasaan belanja
- Kesulitan melacak pengeluaran secara konsisten

---

## 3. 💡 Solution

Aplikasi yang memungkinkan user:

- Mencatat transaksi dengan cepat
- Mengelompokkan pengeluaran berdasarkan metode pembayaran
- Melihat laporan keuangan (report + history)
- Menyimpan wishlist barang
- Mendapat insight sederhana dari kebiasaan belanja

---

## 4. 🎯 Goals & Success Metrics

### Goals:

- Mempermudah pencatatan transaksi harian
- Memberikan insight keuangan yang berguna
- Meningkatkan awareness user terhadap pengeluaran

### Success Metrics:

- ≥ 1 transaksi/hari per user aktif
- Retention mingguan meningkat
- ≥ 60% user membuka halaman Report setiap minggu

---

## 5. 👤 Target User

- Mahasiswa / pekerja (18–35 tahun)
- Aktif menggunakan:
  - E-wallet (GoPay, dll)
  - Cash
  - Bank

- Ingin tracking keuangan tanpa ribet

---

## 6. 🧭 Navigation Structure

Bottom Navigation:

1. 🏠 Home
2. ➕ Add Transaction
3. 📊 Report (Summary + History)
4. ❤️ Wishlist
5. 👤 Profile

---

## 7. 🧩 Features & Requirements

---

## 7.1 🏠 Home (Dashboard)

### Deskripsi:

Menampilkan ringkasan kondisi keuangan user.

### Fitur:

- Total pengeluaran minggu ini
- Total pemasukan minggu ini
- Net balance (income - expense)
- Breakdown:
  - Berdasarkan metode pembayaran
  - Berdasarkan kategori

- Insight:
  - Pengeluaran terbesar
  - Kategori paling boros

### Optional:

- Mini chart (pie/bar)

---

## 7.2 ➕ Add Transaction

### Deskripsi:

Menambahkan transaksi baru.

### Input Field:

- Nominal (required)
- Tipe:
  - Income
  - Expense

- Kategori (required)
- Metode pembayaran (required)
- Tanggal (default: hari ini)
- Catatan (optional)
- Feeling (optional):
  - 😊 Puas
  - 😐 Biasa
  - 😢 Menyesal

### Requirement:

- Maksimal 3–4 tap untuk submit
- UX cepat & sederhana

---

## 7.3 📊 Report (Merged with History)

### Deskripsi:

Menampilkan analisis keuangan sekaligus riwayat transaksi.

---

### 🔝 Section 1: Summary

- Total income
- Total expense
- Net balance

---

### 📅 Section 2: Filter

User dapat memilih:

- Mingguan
- Bulanan
- Tahunan
- (Optional) Custom date

---

### 📊 Section 3: Analytics

- Grafik tren pengeluaran
- Breakdown:
  - Per kategori
  - Per metode pembayaran

### Insight:

- Kategori paling boros
- Hari paling banyak pengeluaran
- Rata-rata pengeluaran

---

### 📜 Section 4: Transaction History

List transaksi:

- Sorted by tanggal
- Infinite scroll / pagination

### Fitur:

- Search transaksi
- Filter:
  - Kategori
  - Metode pembayaran
  - Tanggal

### Item:

- Kategori
- Nominal
- Metode pembayaran
- Tanggal

### Detail:

- Semua field transaksi

---

### UI Recommendation:

Gunakan segmented control:

```text
[ Summary | History ]
```

---

## 7.4 ❤️ Wishlist

### Deskripsi:

Daftar barang yang ingin dibeli.

### Fitur:

- Tambah item:
  - Nama
  - Harga target

- Status:
  - Belum beli
  - Sudah beli

### Additional:

- Convert ke transaksi saat dibeli

---

## 7.5 👤 Profile

### Deskripsi:

Pengaturan user.

### Fitur:

- Nama user
- Target pengeluaran mingguan
- Reset data
- Export data (optional)

---

## 7.6 💳 Payment Method Management

### Fitur:

- Tambah metode pembayaran
- Edit
- Hapus

Contoh:

- Cash
- GoPay
- Bank

---

## 7.7 🗂️ Category Management

### Fitur:

- Tambah kategori
- Edit
- Hapus
- Icon / warna (optional)

---

## 7.8 🎯 Budgeting (Optional)

### Fitur:

- Set budget:
  - Mingguan
  - Bulanan

- Progress penggunaan

---

## 8. 🗄️ Data Model (High-Level)

### Transaction

```
id
amount
type (income/expense)
category_id
payment_method_id
note
date
feeling
```

### Category

```
id
name
icon
```

### Payment Method

```
id
name
```

### Wishlist

```
id
name
price
status
```

---

## 9. ⚙️ Non-Functional Requirements

- App harus:
  - Cepat (< 1 detik untuk aksi utama)
  - Ringan
  - Offline-first

- UI harus:
  - Clean
  - Mudah digunakan (≤ 3 tap untuk input)

---

## 10. 🚀 MVP Scope

Fitur wajib:

- Home (basic summary)
- Add Transaction
- Report (basic + history)
- Wishlist
- Profile
- Payment Method
- Category

---

## 11. 🔮 Future Enhancements

- Cloud sync
- Multi-device support
- Notifikasi reminder input transaksi
- AI Insight:
  - Prediksi pengeluaran

- Dark mode
- Export ke Excel

---

## 12. ⚠️ Risks & Mitigation

### Risk:

User malas input transaksi

### Mitigation:

- UX super cepat
- Default value otomatis
- Reminder harian

---

## 13. 🧱 Technical Suggestion

- Framework: Flutter
- State Management: Riverpod / Provider
- Database:
  - Hive (recommended)
  - SQLite (optional)

- Chart: fl_chart

---

Mantap—kalau kamu mau pakai **Flutter + Supabase**, itu sudah level production-ready 👍
Aku update bagian **Technical Suggestion** jadi lebih relevan + sekalian kasih struktur arsitektur yang proper.

---

# 🧱 13. Technical Architecture (Updated: Flutter + Supabase)

## 📱 Frontend

- Framework: Flutter
- State Management:
  - **Riverpod (recommended)** → scalable & clean
  - (alternatif: Provider kalau mau simpel)

---

## ☁️ Backend (BaaS)

### 🔥 Supabase

Menggantikan:

- Hive / SQLite (local DB)
- Firebase (alternatif)

### Fitur yang dipakai:

- **PostgreSQL Database**
- **Auth (optional)**
- **Realtime (optional, future)**
- **Storage (optional)**

---

## 🗄️ Database Design (Supabase PostgreSQL)

### 1. `transactions`

```
id (uuid, pk)
user_id (uuid)
amount (numeric)
type (income/expense)
category_id (uuid)
payment_method_id (uuid)
note (text)
date (timestamp)
feeling (text)
created_at (timestamp)
```

---

### 2. `categories`

```
id (uuid, pk)
user_id (uuid)
name (text)
icon (text)
created_at
```

---

### 3. `payment_methods`

```
id (uuid, pk)
user_id (uuid)
name (text)
created_at
```

---

### 4. `wishlist`

```
id (uuid, pk)
user_id (uuid)
name (text)
price (numeric)
status (pending/completed)
created_at
```

---

### 5. `profiles`

```
id (uuid, pk) = user_id
name (text)
weekly_budget (numeric)
created_at
```

---

## 🔐 Authentication (Optional tapi Recommended)

Gunakan Supabase Auth:

- Email & Password
- atau Google login (future)

👉 Benefit:

- Data user aman
- Bisa multi-device

---

## 🔄 Data Flow (Simplified)

Flutter App
⬇
Supabase Client (API)
⬇
PostgreSQL Database

---

## 📦 Flutter Packages

Wajib:

```yaml
supabase_flutter
flutter_riverpod
```

Optional:

```yaml
fl_chart
intl
uuid
```

---

## 🧠 State Management Structure (Riverpod)

Contoh layer:

```
presentation/
  screens/
  widgets/

application/
  providers/

domain/
  models/

data/
  repositories/
  datasource (supabase)
```

---

## 🔌 Repository Pattern (Recommended)

Contoh:

```
TransactionRepository
  - getTransactions()
  - addTransaction()
  - deleteTransaction()
```

👉 Supaya:

- Clean architecture
- Mudah testing
- Bisa ganti backend kalau perlu

---

## 📊 Report Processing

### ✅ Opsi 1

Hitung di Flutter:

- Lebih fleksibel
- Lebih cepat dev

## 🌐 Offline Strategy (Penting)

Supabase = online-first, jadi:

### Solusi:

- Cache data di memory
- (Optional advanced) pakai local DB:
  - Hive untuk caching

---

## 🔒 Security (Supabase RLS)

Aktifkan:
**Row Level Security (RLS)**

Contoh rule:

```sql
user_id = auth.uid()
```

👉 User hanya bisa akses data sendiri

---

## 🚀 Deployment

- Supabase: Cloud (langsung)
- Flutter:
  - Android APK / Play Store
  - iOS (optional)

---

# ⚠️ Catatan Penting

Karena app kamu:

- Banyak filter
- Banyak report

👉 **Supabase (PostgreSQL) = pilihan sangat tepat**

---

# 💡 Saran Arsitektur Final

- Flutter (UI)
- Riverpod (state)
- Supabase (backend + DB)
- Repository pattern
