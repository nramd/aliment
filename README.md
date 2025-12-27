# 🥗 Aliment

<p align="center">
  <img src="assets/images/aliment_logo.png" alt="Aliment Logo" width="120"/>
</p>

<p align="center">
  <strong>Kelola Makanan Cerdas, Kurangi Limbah Pangan</strong>
</p>

<p align="center">
  <a href="#tentang">Tentang</a> •
  <a href="#fitur">Fitur</a> •
  <a href="#screenshots">Screenshots</a> •
  <a href="#teknologi">Teknologi</a> •
  <a href="#instalasi">Instalasi</a> •
  <a href="#struktur-projek">Struktur</a> •
  <a href="#kontributor">Kontributor</a>
</p>

---

## 📖 Tentang

**Aliment** adalah aplikasi mobile yang membantu pengguna mengelola bahan makanan di rumah dan mengurangi limbah pangan (food waste). Aplikasi ini memungkinkan pengguna untuk: 

- Mencatat dan memantau bahan makanan beserta tanggal kadaluarsanya
- Mendapatkan notifikasi pengingat sebelum makanan kadaluarsa
- Berbagi makanan berlebih dengan orang lain di sekitar
- Belajar tentang pengelolaan makanan melalui konten edukasi

### 🎯 Latar Belakang

Food waste merupakan masalah global yang serius.  Di Indonesia, sekitar 48 juta ton makanan terbuang setiap tahunnya.  Aliment hadir sebagai solusi untuk membantu mengurangi limbah pangan dimulai dari rumah tangga.

---

## ✨ Fitur

### 🏠 Beranda (Home)
- **Etalase Makanan** - Tampilan daftar makanan dengan status kadaluarsa
- **Kategori Makanan** - Protein, Sayuran, Buah, Dairy, dll.
- **Quick Actions** - Akses cepat ke fitur utama
- **Notifikasi Badge** - Indikator makanan yang akan segera kadaluarsa

### 📦 Manajemen Etalase
- **Tambah Makanan** - Input makanan baru dengan foto, kategori, jumlah, dan tanggal kadaluarsa
- **Edit & Hapus** - Kelola makanan yang sudah ada
- **Status Otomatis** - Indikator warna berdasarkan kedekatan tanggal kadaluarsa: 
  - 🟢 **Aman** - Lebih dari 3 hari
  - 🟡 **Segera** - 1-3 hari
  - 🔴 **Hari Ini / Kadaluarsa**

### 🤝 Fitur Berbagi
- **Jelajahi** - Temukan makanan yang dibagikan orang lain di sekitar
- **Bagikan Makanan** - Share makanan dari etalase ke komunitas
- **Sistem Antrian** - Request makanan dengan posisi antrian yang visible
- **Lokasi GPS** - Tentukan titik pengambilan dengan GPS atau alamat manual
- **Accept/Reject** - Pemberi bebas memilih penerima dari antrian
- **Auto-Reject** - Permintaan lain otomatis ditolak saat satu diterima
- **Link Google Maps** - Navigasi ke lokasi pengambilan
- **Riwayat** - Lacak histori berbagi dan menerima makanan

### 🔔 Notifikasi
- **Pengingat Kadaluarsa** - Notifikasi H-3, H-1, dan hari-H
- **Daftar Notifikasi** - Tampilan semua item yang perlu perhatian
- **Pengaturan Notifikasi** - Kustomisasi preferensi reminder

### 📚 Edukasi
- **Artikel** - Konten edukatif tentang pengelolaan makanan
- **Kategori Artikel** - Nutrisi, Penyimpanan, Limbah, Resep
- **Featured Articles** - Carousel artikel pilihan
- **Detail Artikel** - Tampilan lengkap dengan views dan likes

### 👤 Profil
- **Informasi Pengguna** - Nama dan email
- **Statistik Realtime** - Total makanan, kadaluarsa, dan segera expired
- **Pengaturan** - Notifikasi, bantuan, dan tentang aplikasi

---

## 📱 Screenshots

<p align="center">
  <img src="screenshots/home. png" width="200" alt="Home"/>
  <img src="screenshots/share.png" width="200" alt="Share"/>
  <img src="screenshots/education.png" width="200" alt="Education"/>
  <img src="screenshots/profile.png" width="200" alt="Profile"/>
</p>

---

## 🛠 Teknologi

### Framework & Language
| Teknologi | Versi | Keterangan |
|-----------|-------|------------|
| Flutter | 3.x | UI Framework |
| Dart | 3.x | Programming Language |

### Backend & Database
| Teknologi | Keterangan |
|-----------|------------|
| Firebase Auth | Autentikasi pengguna |
| Cloud Firestore | Database NoSQL realtime |
| Firebase Storage | Penyimpanan gambar |

### Packages Utama
```yaml
dependencies:
  # Firebase
  firebase_core: ^3.9.0
  firebase_auth: ^5.5.1
  cloud_firestore: ^5.6.5
  firebase_storage: ^12.4.4

  # State Management & Navigation
  go_router: ^14.8.1

  # UI Components
  flutter_svg: ^2.0.17
  carousel_slider: ^5.0.0
  shimmer: ^3.0.0

  # Utilities
  intl: ^0.20.2
  image_picker: ^1.1.2
  geolocator: ^13.0.2
  url_launcher: ^6.3.1

  # Local Notifications
  flutter_local_notifications: ^18.0.1
  timezone: ^0.10.0
```

---

## 🚀 Instalasi

### Prasyarat
- Flutter SDK (versi 3.x)
- Dart SDK (versi 3.x)
- Android Studio / VS Code
- Firebase Project

### Langkah Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/nramd/aliment.git
   cd aliment
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Konfigurasi Firebase**
   - Buat project di [Firebase Console](https://console.firebase.google.com)
   - Tambahkan aplikasi Android & iOS
   - Download `google-services.json` (Android) dan `GoogleService-Info.plist` (iOS)
   - Tempatkan file konfigurasi di direktori yang sesuai

4. **Setup Firestore Indexes**
   
   Buat composite indexes berikut di Firebase Console → Firestore → Indexes: 
   
   | Collection | Fields | Query Scope |
   |------------|--------|-------------|
   | `food_items` | `userId` (Asc), `status` (Asc), `expiryDate` (Asc) | Collection |
   | `shared_foods` | `status` (Asc), `createdAt` (Desc) | Collection |
   | `shared_foods` | `ownerId` (Asc), `createdAt` (Desc) | Collection |
   | `food_requests` | `sharedFoodId` (Asc), `status` (Asc), `queuePosition` (Asc) | Collection |
   | `food_requests` | `requesterId` (Asc), `createdAt` (Desc) | Collection |
   | `food_requests` | `ownerId` (Asc), `status` (Asc), `createdAt` (Desc) | Collection |

5. **Run Aplikasi**
   ```bash
   flutter run
   ```

---

## 📁 Struktur Projek

```
lib/
├── core/
│   ├── navigation/
│   │   └── app_router.dart          # Routing configuration
│   └── theme/
│       └── app_colors.dart          # Color constants
│
├── features/
│   ├── models/
│   │   ├── user_model.dart          # User data model
│   │   ├── food_item_model.dart     # Food item model
│   │   ├── shared_food_model.dart   # Shared food model
│   │   ├── food_request_model. dart  # Food request model
│   │   └── article_model.dart       # Article model
│   │
│   ├── services/
│   │   ├── auth_service.dart        # Authentication service
│   │   ├── food_service.dart        # Food CRUD operations
│   │   ├── share_service.dart       # Share feature service
│   │   ├── location_service.dart    # GPS & Maps service
│   │   └── notification_service.dart # Notification service
│   │
│   └── screens/
│       ├── main_screen.dart         # Bottom navigation container
│       │
│       ├── # Authentication
│       ├── login_page.dart
│       ├── register_page.dart
│       │
│       ├── # Home Feature
│       ├── home_page.dart
│       ├── add_food_page.dart
│       ├── edit_food_page.dart
│       ├── food_detail_page.dart
│       ├── etalase_page.dart
│       │
│       ├── # Share Feature
│       ├── share_page.dart
│       ├── share_explore_tab.dart
│       ├── share_my_shares_tab.dart
│       ├── share_from_etalase_page.dart
│       ├── set_share_location_page.dart
│       ├── shared_food_detail_page.dart
│       ├── request_queue_page.dart
│       ├── share_history_page.dart
│       │
│       ├── # Education Feature
│       ├── education_page.dart
│       ├── category_page.dart
│       ├── article_detail_page.dart
│       │
│       ├── # Profile Feature
│       ├── profile_page.dart
│       │
│       └── # Notifications
│       ├── notifications_page.dart
│       └── notification_settings_page.dart
│
└── main.dart                        # App entry point
```

---

## 🗄 Database Schema

### Collections

#### `users`
```javascript
{
  id: string,
  email: string,
  displayName: string,
  createdAt: timestamp
}
```

#### `food_items`
```javascript
{
  id: string,
  userId: string,
  name: string,
  category: string,
  quantity: number,
  unit: string,
  expiryDate: timestamp,
  addedDate: timestamp,
  storageLocation: string,
  status: "available" | "consumed" | "expired" | "shared",
  imageUrl: string?,
  isShared: boolean,
  sharedFoodId: string?
}
```

#### `shared_foods`
```javascript
{
  id: string,
  foodId: string,
  ownerId: string,
  ownerName: string,
  name: string,
  description: string?,
  quantity: number,
  unit: string,
  category: string,
  imageUrl: string?,
  expiryDate: timestamp,
  location: geopoint?,
  address: string?,
  status: "available" | "reserved" | "completed" | "cancelled",
  selectedRequestId: string?,
  requestCount: number,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

#### `food_requests`
```javascript
{
  id: string,
  sharedFoodId: string,
  foodName: string,
  foodImageUrl: string?,
  requesterId: string,
  requesterName: string,
  ownerId: string,
  ownerName: string,
  note: string?,
  status: "pending" | "accepted" | "rejected" | "cancelled" | "completed",
  queuePosition: number,
  createdAt: timestamp,
  respondedAt: timestamp?,
  completedAt: timestamp?
}
```

---

## 🔄 Flow Aplikasi

### Flow Berbagi Makanan

```
┌─────────────────────────────────────────────────────────────┐
│                    FLOW BERBAGI MAKANAN                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PEMBERI:                                                    │
│  1. Pilih makanan dari Etalase                              │
│  2. Set lokasi (GPS/Manual)                                 │
│  3. Bagikan → Makanan muncul di "Jelajahi"                  │
│  4. Terima permintaan dari antrian                          │
│  5. Tandai "Sudah Diambil" → Selesai                        │
│                                                             │
│  PENERIMA:                                                   │
│  1. Jelajahi makanan di sekitar                             │
│  2. Lihat detail → Ajukan Permintaan                        │
│  3. Tunggu konfirmasi (lihat posisi antrian)                │
│  4. Jika diterima → Lihat lokasi di Maps                    │
│  5. Ambil makanan → Selesai                                 │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Flow Status Makanan

```
[Etalase]
    │
    ▼
[Dibagikan] ──────────────────┐
    │                         │
    ▼                         │
[Ada Request]                 │
    │                         │
    ▼                         │
[Direservasi] ◄── Terima ──┐  │
    │                      │  │
    ▼                      │  │
[Selesai]     [Ditolak] ◄──┘  │
                              │
[Dibatalkan] ◄────────────────┘
```

---

## 🎨 Design System

### Warna Utama
| Nama | Hex | Preview |
|------|-----|---------|
| Normal | `#6B7B3C` | 🟢 |
| Dark | `#5A6832` | 🟢 |
| Darker | `#3D4A1F` | 🟢 |
| Light | `#F5F5DC` | 🟡 |

### Typography
- **Font Family:** Gabarito
- **Headings:** Bold, 18-24px
- **Body:** Regular, 12-16px

---

## 📝 Lisensi

Projek ini dibuat untuk keperluan edukasi dan pengembangan. 

---

## 👨‍💻 Kontributor

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/nramd">
        <img src="https://github.com/nramd.png" width="100px;" alt=""/>
        <br />
        <sub><b>nramd</b></sub>
      </a>
    </td>
  </tr>
</table>

---

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - UI Framework
- [Firebase](https://firebase.google.com/) - Backend Services
- [Google Fonts](https://fonts.google.com/) - Typography
- Semua kontributor dan tester yang telah membantu

---

<p align="center">
  Made with ❤️ for reducing food waste
</p>

<p align="center">
  <strong>Aliment</strong> - Kelola Makanan Cerdas, Kurangi Limbah Pangan
</p>