import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aliment/core/theme/app_colors.dart';
import 'package:aliment/features/services/auth_service.dart';
import 'package:aliment/features/services/food_service.dart';
import 'package:aliment/features/models/food_item_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final FoodService _foodService = FoodService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.light,
      appBar: AppBar(
        backgroundColor: AppColors.normal,
        elevation: 0,
        title: const Text(
          "Etalase Saya",
          style: TextStyle(
            fontFamily: 'Gabarito',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                context.go('/getStarted');
              }
            },
          ),
        ],
      ),
      // Tombol Tambah Makanan
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkActive,
        onPressed: () {
          // TODO: Arahkan ke halaman tambah makanan (AddFoodPage)
          // context.push('/addFood');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Fitur Tambah Makanan akan dibuat selanjutnya"),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Halo, ${user.displayName ?? 'User'}! 👋",
              style: TextStyle(
                fontFamily: 'Gabarito',
                fontSize: 20,
                color: AppColors.darker,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "Jangan lupa cek kadaluarsa makananmu.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // DAFTAR MAKANAN
            Expanded(
              child: StreamBuilder<List<FoodItemModel>>(
                stream: _foodService.getFoodItems(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: AppColors.normal),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.kitchen_outlined,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Belum ada makanan tersimpan",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  final foods = snapshot.data!;

                  return ListView.builder(
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      final food = foods[index];
                      return _buildFoodCard(food);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Kartu Makanan
  Widget _buildFoodCard(FoodItemModel food) {
    final String formattedDate = DateFormat(
      'dd MMM yyyy',
    ).format(food.expiryDate);

    // Logic warna indikator (Merah jika sudah dekat expired < 3 hari)
    final int daysUntilExpiry = food.expiryDate
        .difference(DateTime.now())
        .inDays;
    final Color statusColor = daysUntilExpiry < 3 ? Colors.red : Colors.green;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.light,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.normal.withOpacity(0.3)),
          ),
          child: Icon(Icons.fastfood, color: AppColors.normal),
        ),
        title: Text(
          food.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: 'Gabarito',
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("${food.quantity} ${food.unit} • ${food.storageLocation}"),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: statusColor),
                const SizedBox(width: 4),
                Text(
                  "Exp: $formattedDate",
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _foodService.deleteFoodItem(food.id);
            } else if (value == 'consumed') {
              _foodService.updateFoodStatus(food.id, 'consumed');
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'consumed',
              child: Text('Tandai Habis (Dimakan)'),
            ),
            const PopupMenuItem<String>(
              value: 'delete',
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
