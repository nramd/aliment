class FoodSuggestion {
  final String foodName;
  final String category;
  final List<String> cookingSuggestions;
  final String storageTip;

  const FoodSuggestion({
    required this.foodName,
    required this.category,
    required this.cookingSuggestions,
    required this.storageTip,
  });

  static FoodSuggestion getSuggestion(String foodName, String category) {
    // Exact match
    final exactMatch = _suggestionDatabase[foodName.toLowerCase()];
    if (exactMatch != null) {
      return FoodSuggestion(
        foodName: foodName,
        category: category,
        cookingSuggestions: List<String>.from(exactMatch['cooking']),
        storageTip: exactMatch['storage'] as String,
      );
    }

    // Partial match
    for (var entry in _suggestionDatabase.entries) {
      if (foodName.toLowerCase().contains(entry.key) ||
          entry.key.contains(foodName.toLowerCase())) {
        return FoodSuggestion(
          foodName: foodName,
          category: category,
          cookingSuggestions: List<String>.from(entry.value['cooking']),
          storageTip: entry.value['storage'] as String,
        );
      }
    }

    // Category match
    final categoryMatch = _categoryDefaultSuggestions[category.toLowerCase()];
    if (categoryMatch != null) {
      return FoodSuggestion(
        foodName: foodName,
        category: category,
        cookingSuggestions:
            _generateDynamicSuggestions(foodName, category, categoryMatch),
        storageTip: categoryMatch['storage'] as String,
      );
    }

    // Default suggestion (if no match found)
    return FoodSuggestion(
      foodName: foodName,
      category: category,
      cookingSuggestions: [
        'Segera olah $foodName agar tidak terbuang sia-sia',
        'Kombinasikan $foodName dengan bahan lain untuk variasi menu',
        'Cek kondisi $foodName sebelum diolah',
      ],
      storageTip:
          'Simpan $foodName di tempat yang sesuai dan perhatikan tanggal kadaluarsa.',
    );
  }

  // Generate saran dinamis dengan menyertakan nama makanan
  static List<String> _generateDynamicSuggestions(
      String foodName, String category, Map<String, dynamic> categoryData) {
    final baseSuggestions = List<String>.from(categoryData['cooking']);

    // Personalisasi dengan nama makanan
    return baseSuggestions.map((suggestion) {
      // Tambahkan nama makanan di awal jika belum ada
      if (!suggestion.toLowerCase().contains(foodName.toLowerCase())) {
        return 'Olah $foodName:  ${suggestion.substring(0, 1).toLowerCase()}${suggestion.substring(1)}';
      }
      return suggestion;
    }).toList();
  }

  // DATABASE SARAN MAKANAN

  static final Map<String, Map<String, dynamic>> _suggestionDatabase = {
    // PROTEIN
    'dada ayam': {
      'cooking': [
        'Tumis dada ayam dengan sayuran untuk makan siang cepat',
        'Panggang dengan bumbu sederhana untuk makan malam sehat',
        'Rebus dan gunakan sebagai topping sup atau salad',
      ],
      'storage':
          'Simpan di dalam wadah tertutup dan pastikan suhu kulkas < 4°C agar tetap segar lebih lama.',
    },
    'ayam': {
      'cooking': [
        'Goreng dengan bumbu kuning untuk ayam goreng klasik',
        'Buat sop ayam hangat dengan sayuran',
        'Panggang dengan kecap dan madu',
      ],
      'storage': 'Simpan di kulkas (1-2 hari) atau freezer (hingga 3 bulan).',
    },
    'daging sapi': {
      'cooking': [
        'Olah menjadi rendang atau semur untuk hidangan spesial',
        'Iris tipis untuk tumis daging sayuran',
        'Buat bakso atau burger patty homemade',
      ],
      'storage':
          'Simpan di freezer jika tidak digunakan dalam 2 hari.  Cairkan di kulkas sebelum dimasak.',
    },
    'daging': {
      'cooking': [
        'Tumis dengan bumbu dan sayuran',
        'Buat sup atau soto daging',
        'Panggang dengan bumbu BBQ',
      ],
      'storage': 'Simpan di freezer untuk penyimpanan jangka panjang.',
    },
    'ikan': {
      'cooking': [
        'Kukus dengan bumbu sederhana untuk menu sehat',
        'Goreng tepung untuk lauk makan siang',
        'Pepes atau bakar untuk variasi rasa',
      ],
      'storage':
          'Bungkus rapat dan simpan di freezer. Gunakan dalam 1-2 hari jika di kulkas.',
    },
    'telur': {
      'cooking': [
        'Buat telur dadar atau omelette untuk sarapan',
        'Rebus untuk camilan protein tinggi',
        'Gunakan untuk bahan kue atau pancake',
      ],
      'storage': 'Simpan di rak kulkas (bukan di pintu) dengan suhu stabil.',
    },
    'tahu': {
      'cooking': [
        'Goreng crispy sebagai lauk atau camilan',
        'Tumis dengan sayuran dan saus tiram',
        'Kukus dan sajikan dengan sambal kecap',
      ],
      'storage':
          'Rendam dalam air bersih dan simpan di kulkas.  Ganti air setiap hari.',
    },
    'tempe': {
      'cooking': [
        'Goreng dengan tepung untuk tempe mendoan',
        'Bacem dan goreng untuk lauk tahan lama',
        'Tumis dengan kecap dan cabai',
      ],
      'storage': 'Bungkus dengan daun pisang atau kertas dan simpan di kulkas.',
    },
    'udang': {
      'cooking': [
        'Tumis dengan bawang putih dan mentega',
        'Goreng tepung untuk udang crispy',
        'Buat sup udang atau tom yum',
      ],
      'storage': 'Simpan di freezer dalam wadah kedap udara.',
    },
    'cumi': {
      'cooking': [
        'Tumis dengan saus padang',
        'Goreng tepung untuk cumi goreng',
        'Bakar dengan bumbu kecap',
      ],
      'storage': 'Bersihkan dan simpan di freezer.',
    },

    // SAYURAN
    'bayam': {
      'cooking': [
        'Buat sayur bening dengan jagung manis',
        'Tumis dengan bawang putih sebagai lauk cepat',
        'Blender jadi smoothie hijau bergizi',
      ],
      'storage':
          'Jangan cuci sebelum disimpan. Bungkus dengan tisu dapur dan masukkan plastik.',
    },
    'kangkung': {
      'cooking': [
        'Tumis kangkung dengan terasi dan cabai',
        'Plecing kangkung dengan sambal matah',
        'Cah kangkung saus tiram',
      ],
      'storage':
          'Simpan dalam wadah kedap udara di kulkas.  Gunakan dalam 2-3 hari.',
    },
    'wortel': {
      'cooking': [
        'Iris untuk campuran sup atau capcay',
        'Parut untuk isian risoles atau martabak',
        'Jus wortel untuk minuman sehat',
      ],
      'storage': 'Potong daun hijau dan simpan di plastik berlubang di kulkas.',
    },
    'brokoli': {
      'cooking': [
        'Tumis dengan bawang putih dan saus tiram',
        'Kukus sebagai pendamping steak',
        'Campurkan dalam sup krim',
      ],
      'storage':
          'Jangan cuci sebelum disimpan. Bungkus longgar dengan plastik.',
    },
    'tomat': {
      'cooking': [
        'Buat sambal tomat segar',
        'Iris untuk salad atau sandwich',
        'Masak jadi saus pasta homemade',
      ],
      'storage':
          'Simpan di suhu ruang jika belum matang.  Masukkan kulkas jika sudah matang.',
    },
    'cabai': {
      'cooking': [
        'Buat sambal ulek segar',
        'Iris untuk tumisan atau masakan pedas',
        'Keringkan untuk cabai kering',
      ],
      'storage': 'Simpan di kulkas dalam wadah kedap udara.',
    },
    'bawang': {
      'cooking': [
        'Gunakan sebagai bumbu dasar masakan',
        'Goreng untuk taburan makanan',
        'Tumis untuk aroma masakan',
      ],
      'storage': 'Simpan di tempat kering dan sejuk, hindari kelembaban.',
    },
    'kentang': {
      'cooking': [
        'Goreng untuk french fries atau kentang goreng',
        'Buat perkedel atau kroket',
        'Rebus untuk salad kentang',
      ],
      'storage': 'Simpan di tempat gelap dan sejuk. Jangan di kulkas.',
    },
    'sawi': {
      'cooking': [
        'Tumis dengan bawang putih',
        'Buat bakso kuah dengan sawi',
        'Campuran mie atau kwetiau',
      ],
      'storage': 'Simpan di kulkas dalam plastik berlubang.',
    },

    // BUAH
    'pisang': {
      'cooking': [
        'Olah menjadi pisang goreng, banana bread, atau smoothie',
        'Bekukan untuk es krim pisang sehat',
        'Buat pancake pisang untuk sarapan',
      ],
      'storage':
          'Simpan di suhu ruang.  Pisahkan dari buah lain agar tidak cepat matang.',
    },
    'apel': {
      'cooking': [
        'Makan langsung sebagai camilan sehat',
        'Buat apple pie atau apple crumble',
        'Jus apel segar atau campuran smoothie',
      ],
      'storage':
          'Simpan di kulkas dalam plastik berlubang untuk kesegaran maksimal.',
    },
    'jeruk': {
      'cooking': [
        'Peras untuk jus jeruk segar',
        'Gunakan kulitnya untuk aroma kue',
        'Campurkan dalam salad buah',
      ],
      'storage': 'Simpan di suhu ruang 1 minggu atau kulkas hingga 2 minggu.',
    },
    'alpukat': {
      'cooking': [
        'Buat jus alpukat dengan susu dan gula',
        'Guacamole untuk pendamping nachos',
        'Tambahkan ke salad atau sandwich',
      ],
      'storage': 'Simpan di suhu ruang hingga matang, lalu masukkan kulkas.',
    },
    'mangga': {
      'cooking': [
        'Makan langsung atau buat jus mangga',
        'Buat rujak atau salad buah',
        'Campuran smoothie atau es buah',
      ],
      'storage': 'Simpan di suhu ruang hingga matang, lalu kulkas.',
    },
    'pepaya': {
      'cooking': [
        'Makan langsung sebagai pencuci mulut',
        'Buat jus pepaya segar',
        'Campuran salad buah',
      ],
      'storage': 'Simpan di kulkas setelah matang.',
    },
    'semangka': {
      'cooking': [
        'Potong dan makan langsung',
        'Buat jus semangka segar',
        'Es buah atau cocktail buah',
      ],
      'storage': 'Simpan di kulkas setelah dipotong.',
    },
    'melon': {
      'cooking': [
        'Potong untuk camilan segar',
        'Buat jus melon',
        'Campuran es buah',
      ],
      'storage': 'Simpan di kulkas setelah dipotong.',
    },
    'anggur': {
      'cooking': [
        'Makan langsung sebagai camilan',
        'Bekukan untuk snack segar',
        'Campuran salad buah',
      ],
      'storage': 'Simpan di kulkas tanpa dicuci terlebih dahulu.',
    },
    'strawberry': {
      'cooking': [
        'Makan langsung atau dengan cokelat',
        'Buat smoothie atau jus',
        'Topping untuk pancake atau waffle',
      ],
      'storage': 'Simpan di kulkas tanpa dicuci.  Cuci sebelum dimakan.',
    },

    // DAIRY
    'susu': {
      'cooking': [
        'Gunakan untuk membuat smoothie, puding, atau campuran kopi',
        'Buat susu jahe hangat',
        'Campuran sereal sarapan',
      ],
      'storage': 'Selalu simpan di kulkas dan tutup rapat setelah dibuka.',
    },
    'yogurt': {
      'cooking': [
        'Makan langsung dengan topping buah',
        'Campuran smoothie bowl',
        'Buat frozen yogurt homemade',
      ],
      'storage':
          'Selalu simpan di kulkas dan konsumsi sebelum tanggal kedaluwarsa.',
    },
    'keju': {
      'cooking': [
        'Parut untuk topping pasta atau pizza',
        'Isi sandwich atau burger',
        'Lelehkan untuk saus keju',
      ],
      'storage':
          'Bungkus dengan kertas lilin lalu plastik. Simpan di bagian terdingin kulkas.',
    },
    'mentega': {
      'cooking': [
        'Gunakan untuk menumis atau menggoreng',
        'Olesan roti atau pancake',
        'Bahan dasar kue dan cookies',
      ],
      'storage': 'Simpan di kulkas dalam wadah tertutup.',
    },

    // MAKANAN KALENG
    'sarden': {
      'cooking': [
        'Siapkan hidangan lezat seperti pasta sarden atau nasi goreng sarden',
        'Buat perkedel sarden',
        'Sandwich sarden untuk bekal',
      ],
      'storage':
          'Setelah dibuka, pindahkan ke wadah kaca dan simpan di kulkas maks 2 hari.',
    },
    'kornet': {
      'cooking': [
        'Tumis dengan kentang untuk sarapan',
        'Isi roti atau sandwich',
        'Campuran nasi goreng',
      ],
      'storage': 'Setelah dibuka, simpan di wadah kedap udara di kulkas.',
    },
    'tuna': {
      'cooking': [
        'Buat sandwich tuna mayo',
        'Campuran salad sayuran',
        'Pasta tuna dengan saus tomat',
      ],
      'storage': 'Setelah dibuka, pindahkan ke wadah dan simpan di kulkas.',
    },

    // ROTI & BAKERY
    'roti': {
      'cooking': [
        'Buat sandwich dengan berbagai isian',
        'French toast untuk sarapan',
        'Panggang dengan mentega dan selai',
      ],
      'storage':
          'Simpan di suhu ruang dalam kemasan tertutup.  Bekukan jika tidak habis dalam 3 hari.',
    },
    'kue': {
      'cooking': [
        'Sajikan sebagai camilan atau dessert',
        'Hangatkan sebelum disajikan',
        'Kombinasikan dengan es krim',
      ],
      'storage': 'Simpan di wadah kedap udara di suhu ruang atau kulkas.',
    },

    // FROZEN
    'nugget': {
      'cooking': [
        'Goreng atau panggang untuk lauk praktis',
        'Potong untuk campuran nasi goreng',
        'Bento box untuk bekal anak',
      ],
      'storage':
          'Selalu simpan di freezer.  Jangan bekukan ulang setelah dicairkan.',
    },
    'sosis': {
      'cooking': [
        'Goreng atau bakar untuk camilan',
        'Campuran mie atau nasi goreng',
        'Tusuk sate untuk pesta',
      ],
      'storage': 'Simpan di freezer.  Cairkan di kulkas sebelum dimasak.',
    },
    'bakso': {
      'cooking': [
        'Buat kuah bakso dengan mie',
        'Goreng untuk camilan',
        'Campuran sup atau soto',
      ],
      'storage': 'Simpan di freezer dalam wadah kedap udara.',
    },

    // MINUMAN
    'jus': {
      'cooking': [
        'Minum langsung sebagai minuman segar',
        'Campuran smoothie atau cocktail',
        'Buat es loli homemade',
      ],
      'storage': 'Simpan di kulkas dan konsumsi dalam 3-5 hari setelah dibuka.',
    },
    'kopi': {
      'cooking': [
        'Seduh untuk minuman hangat atau dingin',
        'Buat coffee latte atau cappuccino',
        'Campuran untuk baking',
      ],
      'storage': 'Simpan di tempat kering dan kedap udara.',
    },
    'teh': {
      'cooking': [
        'Seduh untuk minuman hangat atau dingin',
        'Buat es teh manis atau lemon tea',
        'Thai tea atau teh tarik',
      ],
      'storage': 'Simpan di tempat kering dan kedap udara.',
    },

    // BUMBU & REMPAH
    'bawang merah': {
      'cooking': [
        'Iris untuk bumbu dasar masakan',
        'Goreng untuk bawang goreng',
        'Buat sambal bawang',
      ],
      'storage': 'Simpan di tempat kering dan berventilasi baik.',
    },
    'bawang putih': {
      'cooking': [
        'Cincang atau geprek untuk bumbu masakan',
        'Goreng untuk garlic oil',
        'Buat garlic bread',
      ],
      'storage': 'Simpan di tempat kering dan sejuk.',
    },
    'jahe': {
      'cooking': [
        'Buat wedang jahe hangat',
        'Bumbu masakan tumis atau sup',
        'Campuran jamu atau minuman herbal',
      ],
      'storage': 'Simpan di kulkas atau freezer untuk jangka panjang.',
    },
    'kunyit': {
      'cooking': [
        'Bumbu dasar untuk gulai atau kari',
        'Buat jamu kunyit asam',
        'Pewarna alami makanan',
      ],
      'storage': 'Simpan di tempat kering atau freezer.',
    },
    'lengkuas': {
      'cooking': [
        'Bumbu untuk soto atau rawon',
        'Campuran bumbu rendang',
        'Aroma untuk sayur asem',
      ],
      'storage': 'Simpan di kulkas atau freezer.',
    },
    'serai': {
      'cooking': [
        'Bumbu untuk soto atau tom yum',
        'Buat teh serai',
        'Aroma untuk masakan berkuah',
      ],
      'storage': 'Simpan di kulkas dalam plastik.',
    },

    // SNACK & LAINNYA
    'mie instan': {
      'cooking': [
        'Masak sesuai petunjuk kemasan',
        'Buat mie goreng dengan tambahan sayuran',
        'Campuran telur dan sayuran untuk mie tek-tek',
      ],
      'storage': 'Simpan di tempat kering dan sejuk.',
    },
    'nasi': {
      'cooking': [
        'Buat nasi goreng dengan telur dan sayuran',
        'Onigiri atau rice ball',
        'Bubur ayam atau bubur manis',
      ],
      'storage': 'Simpan di kulkas maks 3 hari atau freezer untuk lebih lama.',
    },
  };

  // ==================== DEFAULT SUGGESTIONS PER KATEGORI ====================

  static final Map<String, Map<String, dynamic>> _categoryDefaultSuggestions = {
    'protein': {
      'cooking': [
        'Tumis dengan sayuran untuk hidangan sehat',
        'Panggang atau kukus dengan bumbu sederhana',
        'Olah menjadi sup atau soto',
      ],
      'storage': 'Simpan di kulkas (1-2 hari) atau freezer (hingga 3 bulan).',
    },
    'sayuran': {
      'cooking': [
        'Tumis dengan bawang putih dan saus tiram',
        'Buat sup sayuran bergizi',
        'Kukus sebagai pendamping makanan',
      ],
      'storage':
          'Simpan di kulkas dalam wadah kedap udara atau plastik berlubang.',
    },
    'buah': {
      'cooking': [
        'Makan langsung sebagai camilan sehat',
        'Buat jus atau smoothie',
        'Campurkan dalam salad buah',
      ],
      'storage': 'Simpan di kulkas untuk kesegaran lebih lama.',
    },
    'dairy': {
      'cooking': [
        'Gunakan untuk campuran minuman atau masakan',
        'Buat puding atau dessert',
        'Tambahkan dalam adonan kue',
      ],
      'storage': 'Selalu simpan di kulkas dan tutup rapat.',
    },
    'makanan kaleng': {
      'cooking': [
        'Panaskan dan sajikan dengan nasi',
        'Campurkan dalam tumisan atau nasi goreng',
        'Buat sandwich atau isian roti',
      ],
      'storage':
          'Setelah dibuka, pindahkan ke wadah lain dan simpan di kulkas.',
    },
    'minuman': {
      'cooking': [
        'Minum langsung atau campuran minuman lain',
        'Gunakan sebagai bahan smoothie',
        'Buat es atau minuman dingin',
      ],
      'storage': 'Simpan di kulkas setelah dibuka.',
    },
    'bumbu': {
      'cooking': [
        'Gunakan untuk bumbu masakan sehari-hari',
        'Buat sambal atau saus',
        'Campuran marinasi daging',
      ],
      'storage': 'Simpan di tempat kering dan sejuk.',
    },
    'roti': {
      'cooking': [
        'Panggang dengan mentega untuk sarapan',
        'Buat sandwich atau burger',
        'French toast atau bread pudding',
      ],
      'storage': 'Simpan di suhu ruang atau bekukan untuk jangka panjang.',
    },
    'frozen': {
      'cooking': [
        'Goreng atau panggang sesuai petunjuk kemasan',
        'Campurkan dalam masakan tumis',
        'Sajikan sebagai lauk praktis',
      ],
      'storage':
          'Selalu simpan di freezer.  Jangan bekukan ulang setelah dicairkan.',
    },
    'lainnya': {
      'cooking': [
        'Olah sesuai dengan jenis makanan',
        'Kombinasikan dengan bahan lain',
        'Cek kondisi sebelum diolah',
      ],
      'storage': 'Simpan di tempat yang sesuai dengan jenis makanan.',
    },
  };
}
