import 'package:chronogram/service/api_client.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});
  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  double used = 0, limit = 10, photos = 0, videos = 0;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    loadStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final fraction = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final isWarning = (used / limit) >= 0.9;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Storage",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.orange))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Column(
                children: [
                  /// Storage Usage Overview
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xff121212),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xff3B260D),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.sd_storage_outlined,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Storage Usage",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "${used.toStringAsFixed(1)} GB of ${limit.toStringAsFixed(0)} GB used",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 15),
                              Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.white12,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  FractionallySizedBox(
                                    widthFactor: fraction,
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: isWarning
                                            ? Colors.redAccent
                                            : Colors.orange,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Breakdown
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff121212),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        _buildStorageItem(
                          "Photos",
                          '${photos.toStringAsFixed(1)} GB',
                          limit > 0 ? (photos / limit).clamp(0.0, 1.0) : 0.0,
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        _buildStorageItem(
                          "Videos",
                          '${videos.toStringAsFixed(1)} GB',
                          limit > 0 ? (videos / limit).clamp(0.0, 1.0) : 0.0,
                        ),
                        //  Divider(color: Colors.white12, height: 1),
                        // _buildStorageItem("Documents", "0.5 GB", 0.05),
                      ],
                    ),
                  ),

                  // const SizedBox(height: 30),
                  // /// Manage Storage Button
                  // SizedBox(
                  //   width: double.infinity,
                  //   height: 55,
                  //   child: ElevatedButton(
                  //     onPressed: () {},
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: const Color(0xffFF8C00),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //     ),
                  //     child: const Text(
                  //       "Manage Storage",
                  //       style: TextStyle(
                  //         color: Colors.white,
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ),
                  // ),
              
                ],
              ),
            ),
    );
  }

  Widget _buildStorageItem(String title, String size, double fraction) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                size,
                style: const TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.white12,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),

              FractionallySizedBox(
                widthFactor: fraction,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> loadStorage() async {
    final results = await Future.wait([
      ApiService.getStorageUsage(),
      ApiService.getStorageDetails(),
    ]);
    final usage = results[0];
    final details = results[1];

    ///// Debug 
    
  print("USAGE RESPONSE: $usage");
  print("DETAILS RESPONSE: $details");

    setState(() {
      if (usage['status'] == 'success') {
        used = (usage['used'] as num).toDouble();
        limit = (usage['limit'] as num).toDouble();
      }
      if (details['status'] == 'success') {
        photos = (details['photos'] as num).toDouble();
        videos = (details['videos'] as num).toDouble();
      }
      isLoading = false;
    });
  }
}
