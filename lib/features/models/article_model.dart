import 'package:intl/intl.dart';

class ArticleModel {
  final String id;
  final String title;
  final String category;
  final String author;
  final String authorAvatar;
  final DateTime publishedDate;
  final String imageUrl;
  final String content;
  final int views;
  final int likes;

  ArticleModel({
    required this.id,
    required this.title,
    required this. category,
    required this.author,
    required this.authorAvatar,
    required String publishedDateStr, // Terima sebagai String
    required this.imageUrl,
    required this.content,
    required this.views,
    required this.likes,
  }) : publishedDate = DateTime.parse(publishedDateStr); // Convert ke DateTime
}

// Database artikel statis
class ArticleData {
  static final List<ArticleModel> articles = [
    // NUTRISI 
    ArticleModel(
      id: 'nutrisi_1',
      title: 'Panduan Makan Seimbang dalam 1 Piring',
      category: 'Nutrisi',
      author:  'Dina Kusuma',
      authorAvatar:  'DK',
      publishedDateStr: '2025-01-24',
      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
      views: 920,
      likes: 410,
      content: '''
Makan seimbang adalah kunci untuk menjaga kesehatan tubuh.  Konsep "Isi Piringku" dari Kementerian Kesehatan Indonesia memberikan panduan sederhana untuk memenuhi kebutuhan gizi harian. 

## Pembagian Porsi Ideal

**🥗 Sayuran (35%)**
Isi sepertiga lebih piring dengan berbagai sayuran.  Pilih sayuran berwarna-warni untuk mendapatkan berbagai vitamin dan mineral.

**🍚 Karbohidrat (35%)**
Sepertiga piring untuk sumber karbohidrat seperti nasi, kentang, atau roti. Pilih karbohidrat kompleks untuk energi yang lebih tahan lama.

**🍗 Protein (15%)**
Seperempat piring untuk sumber protein seperti ikan, ayam, telur, tahu, atau tempe. 

**🍎 Buah (15%)**
Lengkapi dengan buah-buahan segar sebagai sumber vitamin dan serat.

## Tips Praktis

1. **Variasikan warna makanan** - Semakin berwarna, semakin beragam nutrisinya
2. **Kurangi garam dan gula** - Batasi penggunaan penyedap buatan
3. **Minum air putih** - Minimal 8 gelas per hari
4. **Makan teratur** - 3 kali makan utama dan 2 kali snack sehat

## Manfaat Makan Seimbang

- Menjaga berat badan ideal
- Meningkatkan energi dan konsentrasi
- Memperkuat sistem imun
- Mencegah penyakit kronis

Mulailah dari perubahan kecil dan konsisten. Kesehatan adalah investasi jangka panjang! 
''',
    ),
    ArticleModel(
      id: 'nutrisi_2',
      title: 'Kenali Vitamin & Mineral Penting untuk Imunitas',
      category: 'Nutrisi',
      author: 'Sari Oktavia',
      authorAvatar: 'SO',
      publishedDateStr: '2025-02-01',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
      views: 502,
      likes: 213,
      content: '''
Sistem imun yang kuat adalah pertahanan terbaik tubuh melawan penyakit. Beberapa vitamin dan mineral berperan penting dalam menjaga imunitas.

## Vitamin Penting untuk Imunitas

**🍊 Vitamin C**
- Sumber: Jeruk, jambu biji, paprika, brokoli
- Fungsi: Meningkatkan produksi sel darah putih
- Kebutuhan harian: 75-90 mg

**☀️ Vitamin D**
- Sumber: Sinar matahari, ikan berlemak, telur
- Fungsi:  Mengaktifkan sel imun
- Kebutuhan harian:  600-800 IU

**🥜 Vitamin E**
- Sumber:  Kacang-kacangan, alpukat, minyak zaitun
- Fungsi: Antioksidan kuat
- Kebutuhan harian: 15 mg

## Mineral Penting

**🦪 Zinc**
- Sumber: Daging merah, kerang, kacang-kacangan
- Fungsi:  Perkembangan sel imun

**🌿 Selenium**
- Sumber: Kacang Brazil, ikan, telur
- Fungsi:  Mencegah kerusakan sel

## Tips Meningkatkan Imunitas

1. Konsumsi makanan bervariasi
2. Tidur cukup 7-8 jam
3. Olahraga teratur
4. Kelola stres dengan baik
5. Hindari rokok dan alkohol

Dengan pola hidup sehat dan asupan nutrisi yang tepat, sistem imun Anda akan bekerja optimal! 
''',
    ),
    ArticleModel(
      id:  'nutrisi_3',
      title: 'Fakta Tentang Lemak Sehat:  Alpukat, Ikan, dan Kacang',
      category: 'Nutrisi',
      author: 'Naufal Febrianto',
      authorAvatar: 'NF',
      publishedDateStr: '2025-05-05',
      imageUrl: 'https://images.unsplash.com/photo-1523049673857-eb18f1d7b578?w=800',
      views: 1500,
      likes: 723,
      content: '''
Lemak sering kali mendapat reputasi buruk dalam dunia kesehatan, padahal tidak semua lemak diciptakan sama. Ada jenis lemak yang justru penting bagi tubuh, yaitu lemak sehat. 

## 🥑 Alpukat: Kaya Akan Lemak Tak Jenuh Tunggal

Alpukat mengandung lemak tak jenuh tunggal yang dapat membantu menurunkan kolesterol jahat (LDL) dan meningkatkan kolesterol baik (HDL).

**Manfaat Alpukat:**
- Kaya akan potasium (lebih dari pisang!)
- Tinggi serat untuk pencernaan sehat
- Mengandung vitamin E dan K
- Membantu penyerapan nutrisi dari makanan lain

## 🐟 Ikan:  Sumber Omega-3 Terbaik

Ikan berlemak seperti salmon, makarel, dan sarden kaya akan asam lemak omega-3 yang sangat bermanfaat untuk kesehatan otak dan jantung.

**Manfaat Omega-3:**
- Mengurangi peradangan
- Menjaga kesehatan otak
- Menurunkan risiko penyakit jantung
- Mendukung kesehatan mata

## 🥜 Kacang-kacangan: Snack Sehat Bernutrisi

Kacang seperti almond, walnut, dan kacang mete mengandung lemak sehat, protein, dan serat yang membuat Anda kenyang lebih lama.

**Tips:**
Konsumsi segenggam (sekitar 30 gram) per hari sebagai snack sehat. 

## Kesimpulan

Lemak sehat adalah bagian penting dari diet seimbang. Dengan memilih sumber lemak yang tepat, Anda dapat menikmati makanan lezat sambil menjaga kesehatan tubuh. 
''',
    ),

    // PENYIMPANAN 
    ArticleModel(
      id: 'penyimpanan_1',
      title: 'Cara Menyimpan Sayuran Agar Tahan Lama',
      category: 'Penyimpanan',
      author: 'Rina Wati',
      authorAvatar: 'RW',
      publishedDateStr: '2025-01-15',
      imageUrl:  'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=800',
      views: 1250,
      likes: 567,
      content: '''
Menyimpan sayuran dengan benar dapat memperpanjang kesegarannya dan mengurangi food waste. 

## 🥬 Sayuran Daun

**Bayam, Kangkung, Sawi:**
- Jangan cuci sebelum disimpan
- Bungkus dengan tisu dapur untuk menyerap kelembaban
- Masukkan ke dalam plastik berlubang
- Simpan di bagian crisper kulkas
- Tahan:  3-5 hari

## 🥕 Sayuran Akar

**Wortel:**
- Potong bagian hijau (daun)
- Simpan dalam plastik berlubang
- Letakkan di bagian bawah kulkas
- Tahan:  2-3 minggu

**Kentang:**
- JANGAN simpan di kulkas
- Letakkan di tempat gelap dan sejuk
- Jauhkan dari bawang
- Tahan: 2-3 minggu

## Tips Umum

1. **Pisahkan berdasarkan jenis** - Beberapa sayuran mengeluarkan etilen
2. **Jangan overcrowd** - Beri ruang agar udara bersirkulasi
3. **Cek secara berkala** - Buang yang sudah rusak
4. **Gunakan wadah yang tepat** - Plastik berlubang atau wadah khusus

Dengan penyimpanan yang tepat, sayuran Anda bisa tahan lebih lama! 
''',
    ),
    ArticleModel(
      id:  'penyimpanan_2',
      title: 'Panduan Menyimpan Daging dan Protein',
      category: 'Penyimpanan',
      author: 'Ahmad Hidayat',
      authorAvatar: 'AH',
      publishedDateStr: '2025-02-10',
      imageUrl: 'https://images.unsplash.com/photo-1607623814075-e51df1bdc82f?w=800',
      views: 890,
      likes: 412,
      content: '''
Daging dan protein adalah bahan makanan yang mudah rusak. Penyimpanan yang benar sangat penting. 

## 🥩 Daging Sapi & Kambing

**Di Kulkas (0-4°C):**
- Daging giling:  1-2 hari
- Potongan steak: 3-5 hari

**Di Freezer (-18°C):**
- Daging giling: 3-4 bulan
- Potongan steak: 4-12 bulan

## 🍗 Ayam & Unggas

**Di Kulkas:**
- Ayam utuh: 1-2 hari
- Potongan ayam: 1-2 hari

**Di Freezer:**
- Ayam utuh: 12 bulan
- Potongan ayam: 9 bulan

## Tips Penting

1. **Bekukan dalam porsi kecil** - Mudah saat mencairkan
2. **Gunakan wadah kedap udara** - Mencegah freezer burn
3. **Label dengan tanggal** - FIFO (First In, First Out)
4. **Cairkan di kulkas** - Jangan di suhu ruang
5. **Jangan bekukan ulang** - Setelah dicairkan, harus segera dimasak
''',
    ),
    ArticleModel(
      id: 'penyimpanan_3',
      title: 'Teknik Penyimpanan Buah yang Benar',
      category: 'Penyimpanan',
      author: 'Maya Sari',
      authorAvatar:  'MS',
      publishedDateStr: '2025-03-05',
      imageUrl: 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=800',
      views: 678,
      likes: 289,
      content: '''
Setiap jenis buah memiliki cara penyimpanan yang berbeda. 

## 🍌 Buah yang Disimpan di Suhu Ruang

**Pisang:**
- Simpan terpisah dari buah lain
- Gantung agar tidak memar
- Masukkan kulkas jika sudah matang

**Alpukat & Mangga:**
- Simpan di suhu ruang hingga matang
- Setelah matang, masukkan kulkas

## 🍎 Buah yang Harus di Kulkas

**Apel:**
- Simpan di crisper drawer
- Jauhkan dari sayuran
- Tahan: 4-6 minggu

**Berry (Strawberry, Blueberry):**
- Jangan cuci sebelum disimpan
- Lapisi wadah dengan tisu
- Tahan: 3-5 hari

## Tips Penting

1. **Jangan campur buah klimakterik dengan non-klimakterik**
2. **Cuci hanya sebelum dikonsumsi**
3. **Periksa secara berkala** dan buang yang rusak
4. **Bekukan buah matang** untuk smoothie
''',
    ),

    // LIMBAH 
    ArticleModel(
      id: 'limbah_1',
      title:  'Gunakan Ulang Kulit Buah:  3 Ide Kreatif & Bergizi',
      category: 'Limbah',
      author: 'Lina Permata',
      authorAvatar: 'LP',
      publishedDateStr: '2025-01-20',
      imageUrl: 'https://images.unsplash.com/photo-1457296898342-cdd24f29b5c0?w=800',
      views: 1100,
      likes: 534,
      content: '''
Kulit buah sering dibuang, padahal banyak yang masih bisa dimanfaatkan. 

## 🍊 Kulit Jeruk

**1. Pembersih Alami**
- Rendam kulit jeruk dalam cuka selama 2 minggu
- Saring dan gunakan sebagai pembersih serbaguna

**2. Pewangi Ruangan**
- Keringkan kulit jeruk
- Tambahkan kayu manis dan cengkeh

**3. Zest untuk Masakan**
- Parut kulit jeruk (bagian orange saja)
- Tambahkan ke kue, salad, atau marinasi

## 🍌 Kulit Pisang

**1. Pupuk Tanaman**
- Potong kecil dan kubur di tanah
- Kaya akan potasium untuk tanaman

**2. Poles Sepatu**
- Gosokkan bagian dalam kulit ke sepatu kulit
- Lap dengan kain bersih

## Tips Umum

1. **Pilih buah organik** atau cuci bersih
2. **Keringkan dengan benar** untuk mencegah jamur
3. **Simpan di wadah kedap udara**
''',
    ),
    ArticleModel(
      id: 'limbah_2',
      title: 'Kompos dari Sisa Makanan:  Panduan Pemula',
      category: 'Limbah',
      author: 'Budi Santoso',
      authorAvatar: 'BS',
      publishedDateStr: '2025-02-15',
      imageUrl: 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800',
      views: 756,
      likes: 312,
      content: '''
Kompos adalah cara terbaik untuk mengolah sisa makanan menjadi pupuk organik. 

## ✅ Bahan yang Bisa Dikompos

**Bahan Hijau (Nitrogen):**
- Sisa sayuran dan buah
- Ampas kopi dan teh
- Kulit telur (dihancurkan)

**Bahan Coklat (Karbon):**
- Daun kering
- Kardus dan kertas
- Serbuk gergaji

## ❌ Bahan yang Tidak Boleh

- Daging dan tulang
- Produk susu
- Minyak dan lemak

## 📦 Cara Membuat Kompos

1. **Siapkan Wadah** - Ember bekas atau bin khusus
2. **Lapisan Dasar** - Bahan coklat 10-15 cm
3. **Perawatan** - Aduk seminggu sekali
4. **Panen** - Kompos siap dalam 2-3 bulan

## Manfaat Kompos

1.  Mengurangi sampah ke TPA
2. Pupuk gratis untuk tanaman
3. Menyuburkan tanah secara alami
''',
    ),
    ArticleModel(
      id: 'limbah_3',
      title: 'Zero Waste Kitchen: Tips Mengurangi Sampah Dapur',
      category: 'Limbah',
      author:  'Dewi Lestari',
      authorAvatar: 'DL',
      publishedDateStr: '2025-03-10',
      imageUrl: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800',
      views: 920,
      likes: 445,
      content: '''
Zero waste bukan berarti nol sampah, tapi meminimalkan limbah sebanyak mungkin.

## 🛒 Saat Berbelanja

1. **Bawa Tas Belanja Sendiri**
2. **Beli Secukupnya** - Buat daftar belanjaan
3. **Pilih Tanpa Kemasan** - Belanja di pasar tradisional

## 🏠 Di Dapur

1. **Penyimpanan yang Benar** - Gunakan wadah kaca
2. **Masak dengan Bijak** - Gunakan semua bagian sayuran
3. **Olah Limbah** - Kompos sisa organik

## 📊 Fakta Menarik

- 1/3 makanan dunia terbuang sia-sia
- Indonesia:  48 juta ton food waste per tahun

Perubahan kecil dari setiap rumah tangga bisa membuat dampak besar! 
''',
    ),

    // RESEP 
    ArticleModel(
      id: 'resep_1',
      title:  'Resep Smoothie Bowl Sehat untuk Sarapan',
      category: 'Resep',
      author: 'Chef Andi',
      authorAvatar: 'CA',
      publishedDateStr: '2025-01-18',
      imageUrl: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=800',
      views: 1350,
      likes: 678,
      content: '''
Smoothie bowl adalah pilihan sarapan sehat yang lezat dan instagramable.

## 🍌 Resep Dasar:  Tropical Smoothie Bowl

**Bahan Smoothie:**
- 1 buah pisang beku
- 1/2 cup mangga beku
- 1/2 cup susu almond
- 1 sdm madu

**Topping:**
- Granola
- Potongan buah segar
- Chia seeds
- Kelapa parut

**Cara Membuat:**
1. Blender semua bahan smoothie hingga kental
2. Tuang ke mangkuk
3. Tata topping dengan cantik
4. Sajikan segera

## Tips Sukses

1. **Gunakan buah beku** untuk tekstur kental
2. **Tambahkan cairan sedikit demi sedikit**
3. **Jangan over-blend** agar tidak terlalu cair
4. **Sajikan segera** sebelum mencair
''',
    ),
    ArticleModel(
      id: 'resep_2',
      title: '5 Resep Makanan dari Sisa Nasi',
      category: 'Resep',
      author: 'Bu Rina',
      authorAvatar: 'BR',
      publishedDateStr:  '2025-02-08',
      imageUrl: 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?w=800',
      views: 1890,
      likes: 892,
      content: '''
Nasi sisa sering dibuang, padahal bisa diolah menjadi hidangan lezat.

## 🍳 1. Nasi Goreng Kampung

**Bahan:**
- 2 piring nasi sisa (dingin lebih baik)
- 2 butir telur
- 3 siung bawang merah
- 2 siung bawang putih
- Kecap manis, garam

**Cara:**
1. Haluskan bumbu, tumis hingga harum
2. Masukkan telur, orak-arik
3. Tambahkan nasi, aduk rata
4. Bumbui dengan kecap dan garam

## 🍙 2. Onigiri (Nasi Kepal Jepang)

**Cara:**
1. Basahi tangan dengan air garam
2. Ambil nasi, pipihkan
3. Isi dengan filling
4. Bentuk segitiga
5. Balut dengan nori

## Tips

- Nasi dingin lebih baik untuk nasi goreng
- Nasi hangat lebih baik untuk onigiri
- Simpan nasi di kulkas maksimal 3 hari
''',
    ),
    ArticleModel(
      id: 'resep_3',
      title: 'Meal Prep: Siapkan Makan Seminggu dalam 2 Jam',
      category:  'Resep',
      author: 'Fitri Handayani',
      authorAvatar: 'FH',
      publishedDateStr: '2025-03-01',
      imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=800',
      views: 2100,
      likes: 956,
      content: '''
Meal prep adalah kunci untuk makan sehat dan hemat waktu.

## 📋 Persiapan

**Menu Minggu Ini:**
- Protein:  Ayam panggang bumbu, Telur rebus
- Karbohidrat: Nasi merah, Kentang panggang
- Sayuran:  Brokoli, Wortel, Buncis

## ⏰ Timeline 2 Jam

**00-15 menit:** Persiapan - Cuci dan potong semua bahan
**15-45 menit:** Memasak Batch 1 - Panggang ayam, rebus telur
**45-75 menit:** Memasak Batch 2 - Kukus sayuran, panggang kentang
**75-105 menit:** Assembly - Bagi ke wadah
**105-120 menit:** Bersih-bersih

## 📦 Penyimpanan

**Di Kulkas (3-4 hari):** Menu Senin - Kamis
**Di Freezer (hingga 3 bulan):** Menu Jumat - Minggu

## Tips Sukses

1. Pilih resep sederhana
2. Gunakan satu jenis protein
3. Variasikan dengan saus
4. Mulai dari 3 hari dulu

Dengan meal prep, Anda menghemat waktu, uang, dan makan lebih sehat!
''',
    ),
  ];

  // Filter artikel berdasarkan kategori
  static List<ArticleModel> getByCategory(String category) {
    return articles.where((a) => a.category == category).toList();
  }

  // Get featured articles (untuk carousel)
  static List<ArticleModel> getFeatured() {
    return articles.take(3).toList();
  }

  // Get artikel by ID
  static ArticleModel?  getById(String id) {
    try {
      return articles.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  // Categories
  static const List<Map<String, dynamic>> categories = [
    {'name': 'Nutrisi', 'icon': '❤️', 'color': 0xFFE57373},
    {'name': 'Penyimpanan', 'icon':  '🗄️', 'color': 0xFF81C784},
    {'name':  'Limbah', 'icon': '♻️', 'color': 0xFF64B5F6},
    {'name': 'Resep', 'icon': '🍳', 'color': 0xFFFFB74D},
  ];
}