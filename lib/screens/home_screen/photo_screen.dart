// import 'dart:io';
// import 'dart:typed_data';
// import 'package:chronogram/app_helper/mobile_mask/mobile_mask.dart';
// import 'package:chronogram/screens/home_screen/profile_screen.dart';
// import 'package:chronogram/screens/splash_screen/splash_screen.dart';
// import 'package:chronogram/service/api_service.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
// import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
// import 'package:chronogram/modal/user_detail_modal.dart';
// import 'package:intl/intl.dart';

// class PhotoScreen extends StatefulWidget {
//   final UserDetailModal? user;
//   final String? userName;
//   const PhotoScreen({super.key, this.user, this.userName});
//   @override
//   State<PhotoScreen> createState() => _PhotoScreenState();
// }

// class _PhotoScreenState extends State<PhotoScreen> with WidgetsBindingObserver {
//   // ── Folder state ──

//   bool isUploading = false;

//   String _selectedFolderName = "Select a Folder";
//   String? _selectedDirectoryPath;
//   bool _isSynced = false;
//   int _syncedItemCount = 0;

//   // ── File mode ──
//   List<String> _filePathList = [];
//   bool _isFileMode = false;

//   // ── Selection mode ──
//   bool _isSelectionMode = false;
//   Set<String> _selectedPaths = {};

//   // ── Original gallery ──
//   List<AssetEntity> _mediaList = [];
//   List<String> _groupOrder = [];
//   Map<String, List<AssetEntity>> _groupedMedia = {};
//   bool _isLoading = true;
//   bool _isFetchingMore = false;
//   int _currentPage = 0;
//   final int _pageSize = 80;
//   bool _hasMore = true;
//   bool _permissionDenied = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _fetchPhotos();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed && _permissionDenied) {
//       _fetchPhotos();
//     }
//   }

//   Future<void> _fetchPhotos() async {
//     if (_currentPage == 0) {
//       if (mounted) {
//         setState(() {
//           _isLoading = true;
//           _permissionDenied = false;
//         });
//       }
//     } else {
//       if (mounted) setState(() => _isFetchingMore = true);
//     }

//     try {
//       final PermissionState ps = await PhotoManager.requestPermissionExtend()
//           .timeout(
//             const Duration(seconds: 15),
//             onTimeout: () => PermissionState.denied,
//           );

//       if (ps.isAuth) {
//         if (mounted) setState(() => _permissionDenied = false);

//         final filterOption = FilterOptionGroup(
//           orders: [
//             const OrderOption(type: OrderOptionType.createDate, asc: false),
//           ],
//         );

//         final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
//           type: RequestType.image,
//           onlyAll: true,
//           filterOption: filterOption,
//         );

//         if (paths.isNotEmpty) {
//           final List<AssetEntity> entities = await paths[0].getAssetListPaged(
//             page: _currentPage,
//             size: _pageSize,
//           );

//           if (mounted) {
//             setState(() {
//               if (_currentPage == 0) {
//                 _mediaList = entities;
//               } else {
//                 _mediaList.addAll(entities);
//               }
//               _hasMore = entities.length == _pageSize;
//               _groupPhotosByDate(_mediaList);
//               _isLoading = false;
//               _isFetchingMore = false;
//             });
//           }
//         } else {
//           if (mounted) {
//             setState(() {
//               _isLoading = false;
//               _isFetchingMore = false;
//               _hasMore = false;
//               _groupedMedia = {};
//             });
//           }
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//             _isFetchingMore = false;
//             _permissionDenied = true;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _isFetchingMore = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchPhotosFromPath(String dirPath) async {
//     setState(() => _isLoading = true);

//     try {
//       final dir = Directory(dirPath);
//       final List<String> imagePaths = [];

//       await for (final entity in dir.list(recursive: false)) {
//         if (entity is File) {
//           final ext = entity.path.toLowerCase();
//           if (ext.endsWith('.jpg') ||
//               ext.endsWith('.jpeg') ||
//               ext.endsWith('.png') ||
//               ext.endsWith('.webp') ||
//               ext.endsWith('.gif') ||
//               ext.endsWith('.heic') ||
//               ext.endsWith('.bmp')) {
//             imagePaths.add(entity.path);
//           }
//         }
//       }

//       imagePaths.sort((a, b) {
//         final aTime = File(a).lastModifiedSync();
//         final bTime = File(b).lastModifiedSync();
//         return bTime.compareTo(aTime);
//       });

//       if (mounted) {
//         setState(() {
//           _filePathList = imagePaths;
//           _isFileMode = true;
//           _isLoading = false;
//           _isSelectionMode = false;
//           _selectedPaths = {};
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   // ── Folder select — sirf naam update ──
//   void _showFolderPicker() async {
//     try {
//       final String? selectedDirectory = await FilePicker.platform
//           .getDirectoryPath();
//       if (selectedDirectory == null) return;
//       final folderName = selectedDirectory
//           .split('/')
//           .where((p) => p.isNotEmpty)
//           .last;
//       setState(() {
//         _selectedFolderName = folderName;
//         _selectedDirectoryPath = selectedDirectory;
//         _isSynced = false;
//         _isFileMode = false;
//         _isSelectionMode = false;
//         _selectedPaths = {};
//         _syncedItemCount = 0;
//       });
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Failed to open folder: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   // ── Sync button ──
//   void _onSyncPressed() async {
//     if (_selectedDirectoryPath == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Select a folder first!"),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     // Agar selection mode mein hain aur kuch select hai
//     final int itemsToSync = _isSelectionMode && _selectedPaths.isNotEmpty
//         ? _selectedPaths.length
//         : _filePathList.isNotEmpty
//         ? _filePathList.length
//         : 0;

//     setState(() {
//       _isSynced = true;
//       _syncedItemCount = itemsToSync;
//       _isSelectionMode = false;
//     });

//     await Future.delayed(const Duration(seconds: 3));
//     if (mounted) setState(() => _isSynced = false);
//     if (!_isFileMode) {
//       _fetchPhotosFromPath(_selectedDirectoryPath!);
//     }
//   }

//   void _groupPhotosByDate(List<AssetEntity> list) {
//     if (_currentPage == 0) {
//       _groupedMedia.clear();
//       _groupOrder.clear();
//     }

//     list.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final lastWeek = today.subtract(const Duration(days: 7));
//     final lastMonth = today.subtract(const Duration(days: 30));

//     for (var asset in list) {
//       final date = asset.createDateTime.toLocal();
//       final assetDate = DateTime(date.year, date.month, date.day);
//       String group;
//       if (assetDate == today) {
//         group = "TODAY";
//       } else if (assetDate == yesterday) {
//         group = "YESTERDAY";
//       } else if (assetDate.isAfter(lastWeek)) {
//         group = "LAST WEEK";
//       } else if (assetDate.isAfter(lastMonth)) {
//         group = "LAST MONTH";
//       } else {
//         group = DateFormat('MMMM yyyy').format(date).toUpperCase();
//       }
//       if (!_groupedMedia.containsKey(group)) {
//         _groupedMedia[group] = [];
//         _groupOrder.add(group);
//       }
//       _groupedMedia[group]!.add(asset);
//     }
//   }

//   void _showFullScreenImage(AssetEntity asset) {
//     final int index = _mediaList.indexOf(asset);
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => FullScreenImageViewer(
//           assets: _mediaList,
//           initialIndex: index < 0 ? 0 : index,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildPremiumHeader(),
//             const Divider(color: Colors.white12, height: 1),
//             _buildSubHeader(),
//             // ── Banner message ──
//             _buildBanner(),
//             Expanded(
//               child: _isLoading
//                   ? const Center(
//                       child: CircularProgressIndicator(color: Colors.orange),
//                     )
//                   : _permissionDenied
//                   ? _buildPermissionDeniedView()
//                   : _isFileMode
//                   ? _buildFileGrid()
//                   : _groupedMedia.isEmpty
//                   ? _buildNoMediaView()
//                   : NotificationListener<ScrollNotification>(
//                       onNotification: (ScrollNotification scrollInfo) {
//                         if (!_isFetchingMore &&
//                             _hasMore &&
//                             scrollInfo.metrics.pixels >=
//                                 scrollInfo.metrics.maxScrollExtent - 300) {
//                           _currentPage++;
//                           _fetchPhotos();
//                         }
//                         return true;
//                       },
//                       child: CustomScrollView(
//                         slivers: [
//                           ..._groupOrder.map((groupKey) {
//                             final assets = _groupedMedia[groupKey]!;
//                             return SliverMainAxisGroup(
//                               slivers: [
//                                 SliverToBoxAdapter(
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                       left: 15,
//                                       top: 25,
//                                       bottom: 12,
//                                     ),
//                                     child: Text(
//                                       groupKey,
//                                       style: const TextStyle(
//                                         color: Colors.orange,
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w800,
//                                         letterSpacing: 1.5,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SliverPadding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                   ),
//                                   sliver: SliverGrid(
//                                     gridDelegate:
//                                         const SliverGridDelegateWithFixedCrossAxisCount(
//                                           crossAxisCount: 4,
//                                           crossAxisSpacing: 5,
//                                           mainAxisSpacing: 5,
//                                         ),
//                                     delegate: SliverChildBuilderDelegate((
//                                       context,
//                                       index,
//                                     ) {
//                                       final asset = assets[index];
//                                       return _SmoothClick(
//                                         onTap: () =>
//                                             _showFullScreenImage(asset),
//                                         child: Stack(
//                                           fit: StackFit.expand,
//                                           children: [
//                                             ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               child: _AssetThumbnail(
//                                                 asset: asset,
//                                               ),
//                                             ),
//                                             if (asset.type == AssetType.video)
//                                               const Positioned(
//                                                 right: 4,
//                                                 top: 4,
//                                                 child: Icon(
//                                                   Icons.play_circle_fill,
//                                                   color: Colors.white,
//                                                   size: 16,
//                                                 ),
//                                               ),
//                                           ],
//                                         ),
//                                       );
//                                     }, childCount: assets.length),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           }).toList(),
//                           if (_isFetchingMore)
//                             const SliverToBoxAdapter(
//                               child: Padding(
//                                 padding: EdgeInsets.all(25),
//                                 child: Center(
//                                   child: CircularProgressIndicator(
//                                     color: Colors.orange,
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           const SliverToBoxAdapter(
//                             child: SizedBox(height: 100),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),
//       // ── Selection mode bottom bar ──
//       bottomNavigationBar: _isSelectionMode && _selectedPaths.isNotEmpty
//           ? _buildSelectionBottomBar()
//           : null,
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(bottom: 10, right: 5),
//         child: FloatingActionButton(
//           onPressed: () {},
//           backgroundColor: Colors.orange,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(30),
//           ),
//           child: const Icon(Icons.more_vert, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   // ── Banner ──
//   Widget _buildBanner() {
//     // Folder select hua hai, sync nahi hua
//     if (_selectedDirectoryPath != null && !_isSynced && !_isFileMode) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         color: Colors.orange.withOpacity(0.12),
//         child: Row(
//           children: [
//             const Icon(Icons.info_outline, color: Colors.orange, size: 16),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 "You have selected '${_selectedFolderName} Folder' for syncing. Start sync!",
//                 style: const TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     // File mode — selection chal raha hai
//     if (_isFileMode && _isSelectionMode) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         color: Colors.blue.withOpacity(0.12),
//         child: Row(
//           children: [
//             const Icon(
//               Icons.check_circle_outline,
//               color: Colors.blue,
//               size: 16,
//             ),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 _selectedPaths.isEmpty
//                     ? 'Select photos to sync.'
//                     : 'You have selected ${_selectedPaths.length} items to sync.',
//                 style: const TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//             if (_selectedPaths.isNotEmpty)
//               GestureDetector(
//                 onTap: () => setState(() => _selectedPaths = {}),
//                 child: const Text(
//                   'Clear',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       );
//     }

//     // Sync hua hai — result dikhao
//     if (_isFileMode && !_isSelectionMode && _syncedItemCount > 0) {
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
//         color: Colors.green.withOpacity(0.12),
//         child: Row(
//           children: [
//             const Icon(Icons.check_circle, color: Colors.green, size: 16),
//             const SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 '$_syncedItemCount items synced from ‘$_selectedFolderName’. ',
//                 style: const TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     return const SizedBox.shrink();
//   }

//   // ── File grid with selection support ──
//   Widget _buildFileGrid() {
//     if (_filePathList.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.photo_library_outlined,
//               color: Colors.white12,
//               size: 60,
//             ),
//             const SizedBox(height: 15),
//             const Text(
//               "This folder has no images.",
//               style: TextStyle(color: Colors.white38, fontSize: 16),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: _showFolderPicker,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.orange,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(25),
//                 ),
//               ),
//               child: const Text("Select another folder."),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.fromLTRB(15, 16, 15, 10),
//           child: Row(
//             children: [
//               Text(
//                 "${_filePathList.length} PHOTOS — $_selectedFolderName",
//                 style: const TextStyle(
//                   color: Colors.orange,
//                   fontSize: 13,
//                   fontWeight: FontWeight.w800,
//                   letterSpacing: 1.5,
//                 ),
//               ),
//               const Spacer(),
//               // Select All / Cancel
//               GestureDetector(
//                 onTap: () {
//                   setState(() {
//                     if (_isSelectionMode) {
//                       _isSelectionMode = false;
//                       _selectedPaths = {};
//                     } else {
//                       _isSelectionMode = true;
//                     }
//                   });
//                 },
//                 child: Text(
//                   _isSelectionMode ? "Cancel" : "Select",
//                   style: TextStyle(
//                     color: _isSelectionMode ? Colors.red : Colors.orange,
//                     fontSize: 13,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         Expanded(
//           child: GridView.builder(
//             padding: const EdgeInsets.symmetric(horizontal: 10),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4,
//               crossAxisSpacing: 5,
//               mainAxisSpacing: 5,
//             ),
//             itemCount: _filePathList.length,
//             itemBuilder: (context, index) {
//               final path = _filePathList[index];
//               final isSelected = _selectedPaths.contains(path);

//               return _SmoothClick(
//                 onTap: () {
//                   if (_isSelectionMode) {
//                     setState(() {
//                       if (isSelected) {
//                         _selectedPaths.remove(path);
//                       } else {
//                         _selectedPaths.add(path);
//                       }
//                     });
//                   } else {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => _FileImageViewer(
//                           paths: _filePathList,
//                           initialIndex: index,
//                         ),
//                       ),
//                     );
//                   }
//                 },
//                 onLongPress: () {
//                   if (!_isSelectionMode) {
//                     setState(() {
//                       _isSelectionMode = true;
//                       _selectedPaths.add(path);
//                     });
//                   }
//                 },
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.file(
//                         File(path),
//                         fit: BoxFit.cover,
//                         cacheWidth: 150,
//                         errorBuilder: (_, __, ___) => Container(
//                           color: const Color(0xff1A1A1A),
//                           child: const Center(
//                             child: Icon(
//                               Icons.broken_image_outlined,
//                               color: Colors.white24,
//                               size: 22,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Selection overlay
//                     if (_isSelectionMode)
//                       Positioned.fill(
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: Container(
//                             color: isSelected
//                                 ? Colors.blue.withOpacity(0.35)
//                                 : Colors.black.withOpacity(0.15),
//                           ),
//                         ),
//                       ),
//                     // Checkbox
//                     if (_isSelectionMode)
//                       Positioned(
//                         top: 5,
//                         right: 5,
//                         child: Container(
//                           width: 20,
//                           height: 20,
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: isSelected
//                                 ? Colors.blue
//                                 : Colors.white.withOpacity(0.3),
//                             border: Border.all(
//                               color: isSelected ? Colors.blue : Colors.white,
//                               width: 1.5,
//                             ),
//                           ),
//                           child: isSelected
//                               ? const Icon(
//                                   Icons.check,
//                                   color: Colors.white,
//                                   size: 12,
//                                 )
//                               : null,
//                         ),
//                       ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   // ── Selection bottom bar ──
//   Widget _buildSelectionBottomBar() {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(15, 10, 15, 20),
//       color: const Color(0xff1A1A1A),
//       child: Row(
//         children: [
//           // Select All
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 if (_selectedPaths.length == _filePathList.length) {
//                   _selectedPaths = {};
//                 } else {
//                   _selectedPaths = Set.from(_filePathList);
//                 }
//               });
//             },
//             child: Text(
//               _selectedPaths.length == _filePathList.length
//                   ? "Deselect All"
//                   : "Select All",
//               style: const TextStyle(
//                 color: Colors.orange,
//                 fontSize: 13,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           const Spacer(),
//           Text(
//             "${_selectedPaths.length} selected",
//             style: const TextStyle(color: Colors.white54, fontSize: 13),
//           ),
//           const SizedBox(width: 15),
//           // Sync selected
//           ElevatedButton.icon(
//             onPressed: _onSyncPressed,
//             icon: const Icon(Icons.sync, size: 16),
//             label: const Text("Sync"),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPremiumHeader() {
//     String name = widget.userName ?? "User";
//     return Container(
//       padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
//       decoration: BoxDecoration(
//         color: Colors.black,
//         border: Border(
//           bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.orange.withOpacity(0.5),
//                     width: 1.5,
//                   ),
//                   color: Colors.white.withOpacity(0.05),
//                 ),
//                 child: Center(
//                   child: Text(
//                     _getInitials(name),
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 15),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       name,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Text(
//                       "My Gallery",
//                       style: TextStyle(color: Colors.white54, fontSize: 13),
//                     ),
//                   ],
//                 ),
//               ),
//               // ── Sync button ──
//               GestureDetector(
//                 onTap: _onSyncPressed,
//                 child: AnimatedContainer(
//                   duration: const Duration(milliseconds: 300),
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 10,
//                     vertical: 5,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _isSynced
//                         ? Colors.green.withOpacity(0.15)
//                         : Colors.orange.withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: _isSynced
//                           ? Colors.green.withOpacity(0.3)
//                           : Colors.orange.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 300),
//                         width: 6,
//                         height: 6,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: _isSynced ? Colors.green : Colors.orange,
//                         ),
//                       ),
//                       const SizedBox(width: 6),
//                       AnimatedDefaultTextStyle(
//                         duration: const Duration(milliseconds: 300),
//                         style: TextStyle(
//                           color: _isSynced ? Colors.green : Colors.orange,
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         child: Text(_isSynced ? "Synced ✓" : "Sync now"),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),

//             //  ── Refresh ──
//               IconButton(
//                 onPressed: () {
//                   setState(() {
//                     _isSynced = false;
//                     _isFileMode = false;
//                   //  _selectedFolderName = "Select a Folder";
//                     _selectedDirectoryPath = null;
//                     _filePathList = [];
//                     _isSelectionMode = false;
//                     _selectedPaths = {};
//                     _syncedItemCount = 0;
//                     _currentPage = 0;
//                   });
//                   _fetchPhotos();
//                 },
//                 icon: const Icon(Icons.refresh, color: Colors.white70, size: 22),
//                 constraints: const BoxConstraints(),
//                 padding: EdgeInsets.zero,
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSubHeader() {
//     return Padding(
//       padding: const EdgeInsets.all(18),
//       child: Row(
//         children: [
//           const Icon(
//             Icons.folder_open_outlined,
//             color: Colors.orange,
//             size: 20,
//           ),
//           const SizedBox(width: 10),

//           InkWell(
//             onTap: _showFolderPicker,
//             borderRadius: BorderRadius.circular(6),
//             child: Text(
//               _selectedFolderName,
//               style: const TextStyle(
//                 color: Colors.orange,
//                 fontSize: 13,
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//           ),
//           SizedBox(width: 10),
//           if (_selectedDirectoryPath != null) ...[
//             InkWell(
//               onTap: _showFolderPicker,
//               child: Text(
//                 'Change Folder',
//                 style: TextStyle(
//                   fontSize: 12,
//                   fontWeight: FontWeight.w800,
//                   color: Colors.white54,
//                 ),
//               ),
//             ),
//           ],
//           Spacer(),
//           if (_isFileMode)
//             GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _isFileMode = false;
//                   _isSynced = false;
//                   _isSelectionMode = false;
//                   _selectedPaths = {};
//                   _currentPage = 0;
//                   // ← folder naam wahi rahega
//                 });
//                 _fetchPhotos();
//               },
//               child: const Row(
//                 children: [
//                   Icon(Icons.arrow_back_ios, color: Colors.white38, size: 12),
//                   Text(
//                     " All Photos",
//                     style: TextStyle(color: Colors.white38, fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPermissionDeniedView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.lock_outline, color: Colors.white24, size: 60),
//           const SizedBox(height: 20),
//           const Text(
//             "Gallery Access Denied",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Please grant permissions to see your media",
//             style: TextStyle(color: Colors.white54),
//           ),
//           const SizedBox(height: 30),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   _currentPage = 0;
//                   _fetchPhotos();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white10,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                 ),
//                 child: const Text("Try Again"),
//               ),
//               const SizedBox(width: 15),
//               ElevatedButton(
//                 onPressed: () => PhotoManager.openSetting(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 25,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                 ),
//                 child: const Text("Open Settings"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoMediaView() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.photo_library_outlined, color: Colors.white12, size: 60),
//           SizedBox(height: 15),
//           Text(
//             "No Photos Found",
//             style: TextStyle(color: Colors.white38, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getInitials(String name) {
//     if (name.trim().isEmpty) return "U";
//     List<String> parts = name.trim().split(RegExp(r'\s+'));
//     if (parts.length == 1) return parts[0][0].toUpperCase();
//     return (parts[0][0] + parts[1][0]).toUpperCase();
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // SmoothClick with longPress support
// // ─────────────────────────────────────────────────────────────────────────────
// class _SmoothClick extends StatefulWidget {
//   final Widget child;
//   final VoidCallback? onTap;
//   final VoidCallback? onLongPress;
//   const _SmoothClick({required this.child, this.onTap, this.onLongPress});
//   @override
//   State<_SmoothClick> createState() => _SmoothClickState();
// }

// class _SmoothClickState extends State<_SmoothClick> {
//   bool _isPressed = false;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _isPressed = true),
//       onTapUp: (_) => setState(() => _isPressed = false),
//       onTapCancel: () => setState(() => _isPressed = false),
//       onTap: widget.onTap,
//       onLongPress: widget.onLongPress,
//       child: AnimatedScale(
//         scale: _isPressed ? 0.95 : 1.0,
//         duration: const Duration(milliseconds: 100),
//         child: widget.child,
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _AssetThumbnail extends StatefulWidget {
//   final AssetEntity asset;
//   const _AssetThumbnail({required this.asset});
//   @override
//   State<_AssetThumbnail> createState() => _AssetThumbnailState();
// }

// class _AssetThumbnailState extends State<_AssetThumbnail> {
//   late final Future<Uint8List?> _thumbFuture;
//   @override
//   void initState() {
//     super.initState();
//     _thumbFuture = widget.asset
//         .thumbnailDataWithSize(
//           const ThumbnailSize.square(150),
//           format: ThumbnailFormat.jpeg,
//           quality: 60,
//         )
//         .timeout(const Duration(seconds: 10), onTimeout: () => null);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Uint8List?>(
//       future: _thumbFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState != ConnectionState.done) {
//           return Container(
//             color: const Color(0xff1A1A1A),
//             child: const Center(
//               child: Icon(
//                 Icons.image_outlined,
//                 color: Colors.white24,
//                 size: 22,
//               ),
//             ),
//           );
//         }
//         final data = snapshot.data;
//         if (data == null || data.isEmpty) {
//           return Container(
//             color: const Color(0xff1A1A1A),
//             child: const Center(
//               child: Icon(
//                 Icons.broken_image_outlined,
//                 color: Colors.white24,
//                 size: 22,
//               ),
//             ),
//           );
//         }
//         return Image.memory(
//           data,
//           fit: BoxFit.cover,
//           cacheWidth: 150,
//           errorBuilder: (_, __, ___) => Container(
//             color: const Color(0xff1A1A1A),
//             child: const Center(
//               child: Icon(
//                 Icons.broken_image_outlined,
//                 color: Colors.white24,
//                 size: 22,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _FileImageViewer extends StatefulWidget {
//   final List<String> paths;
//   final int initialIndex;
//   const _FileImageViewer({required this.paths, required this.initialIndex});
//   @override
//   State<_FileImageViewer> createState() => _FileImageViewerState();
// }

// class _FileImageViewerState extends State<_FileImageViewer> {
//   late final PageController _pageController;
//   late int _currentIndex;
//   bool _showAppBar = true;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final path = widget.paths[_currentIndex];
//     final file = File(path);
//     final fileName = path.split('/').last;
//     DateTime? fileDate;
//     try {
//       fileDate = file.lastModifiedSync();
//     } catch (_) {}

//     return Scaffold(
//       backgroundColor: Colors.black,
//       extendBodyBehindAppBar: true,
//       appBar: _showAppBar
//           ? AppBar(
//               backgroundColor: Colors.black.withOpacity(0.45),
//               iconTheme: const IconThemeData(color: Colors.white),
//               elevation: 0,
//               title: Column(
//                 children: [
//                   Text(
//                     fileName,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   if (fileDate != null)
//                     Text(
//                       DateFormat('dd MMM yyyy  hh:mm a').format(fileDate),
//                       style: const TextStyle(
//                         color: Colors.white54,
//                         fontSize: 11,
//                       ),
//                     ),
//                 ],
//               ),
//               centerTitle: true,
//             )
//           : null,
//       body: PageView.builder(
//         controller: _pageController,
//         itemCount: widget.paths.length,
//         onPageChanged: (index) => setState(() => _currentIndex = index),
//         itemBuilder: (context, index) {
//           return _FileZoomablePage(
//             path: widget.paths[index],
//             onTap: () => setState(() => _showAppBar = !_showAppBar),
//           );
//         },
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _FileZoomablePage extends StatefulWidget {
//   final String path;
//   final VoidCallback onTap;
//   const _FileZoomablePage({required this.path, required this.onTap});
//   @override
//   State<_FileZoomablePage> createState() => _FileZoomablePageState();
// }

// class _FileZoomablePageState extends State<_FileZoomablePage>
//     with SingleTickerProviderStateMixin {
//   final TransformationController _transformationController =
//       TransformationController();
//   late AnimationController _animController;
//   Animation<Matrix4>? _zoomAnimation;
//   Offset _doubleTapPosition = Offset.zero;

//   @override
//   void initState() {
//     super.initState();
//     _animController =
//         AnimationController(
//           vsync: this,
//           duration: const Duration(milliseconds: 200),
//         )..addListener(() {
//           if (_zoomAnimation != null) {
//             _transformationController.value = _zoomAnimation!.value;
//           }
//         });
//   }

//   @override
//   void dispose() {
//     _transformationController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   bool get _isZoomed =>
//       _transformationController.value.getMaxScaleOnAxis() > 1.01;

//   void _handleDoubleTap() {
//     final Matrix4 targetMatrix;
//     if (_isZoomed) {
//       targetMatrix = Matrix4.identity();
//     } else {
//       const double scale = 3.0;
//       final x = _doubleTapPosition.dx;
//       final y = _doubleTapPosition.dy;
//       targetMatrix = Matrix4.identity()
//         ..translate(-x * (scale - 1.0), -y * (scale - 1.0))
//         ..scale(scale);
//     }
//     _zoomAnimation = Matrix4Tween(
//       begin: _transformationController.value,
//       end: targetMatrix,
//     ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
//     _animController.forward(from: 0.0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Listener(
//       onPointerDown: (e) => _doubleTapPosition = e.localPosition,
//       child: GestureDetector(
//         onTap: widget.onTap,
//         onDoubleTap: _handleDoubleTap,
//         child: InteractiveViewer(
//           transformationController: _transformationController,
//           minScale: 0.5,
//           maxScale: 6.0,
//           clipBehavior: Clip.none,
//           panEnabled: true,
//           onInteractionEnd: (_) => setState(() {}),
//           child: SizedBox(
//             width: size.width,
//             height: size.height,
//             child: Image.file(
//               File(widget.path),
//               fit: BoxFit.contain,
//               errorBuilder: (_, __, ___) => const Center(
//                 child: Icon(
//                   Icons.broken_image_outlined,
//                   color: Colors.white38,
//                   size: 60,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class FullScreenImageViewer extends StatefulWidget {
//   final List<AssetEntity> assets;
//   final int initialIndex;
//   const FullScreenImageViewer({
//     super.key,
//     required this.assets,
//     required this.initialIndex,
//   });
//   @override
//   State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
// }

// class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
//   late final PageController _pageController;
//   late int _currentIndex;
//   bool _showAppBar = true;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final asset = widget.assets[_currentIndex];
//     final date = asset.createDateTime.toLocal();
//     final formattedDate = DateFormat('dd MMM yyyy').format(date);
//     final formatTimes = DateFormat('hh:mm a').format(date);
//     return Scaffold(
//       backgroundColor: Colors.black,
//       extendBodyBehindAppBar: true,
//       appBar: _showAppBar
//           ? AppBar(
//               backgroundColor: Colors.black.withOpacity(0.45),
//               iconTheme: const IconThemeData(color: Colors.white),
//               elevation: 0,
//               title: Column(
//                 children: [
//                   Text(
//                     formattedDate,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     formatTimes,
//                     style: const TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                 ],
//               ),
//               centerTitle: true,
//               actions: [
//                 PopupMenuButton(
//                   icon: const Icon(Icons.more_vert, color: Colors.white),
//                   color: Colors.black,
//                   onSelected: (value) {
//                     if (value == 'Details') {
//                       _showPhotoDetails(widget.assets[_currentIndex]);
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     const PopupMenuItem(
//                       value: 'Details',
//                       child: Text(
//                         'More Details',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             )
//           : null,
//       body: PageView.builder(
//         controller: _pageController,
//         itemCount: widget.assets.length,
//         onPageChanged: (index) => setState(() => _currentIndex = index),
//         itemBuilder: (context, index) {
//           return _ZoomablePage(
//             asset: widget.assets[index],
//             onTap: () => setState(() => _showAppBar = !_showAppBar),
//           );
//         },
//       ),
//     );
//   }

//   void _showPhotoDetails(AssetEntity asset) async {
//     final file = await asset.file;
//     int fileSize = 0;
//     String filePath = "Unavailable";
//     if (file != null) {
//       fileSize = await file.length();
//       filePath = file.path;
//     }
//     final date = asset.createDateTime.toLocal();
//     final formattedDate = DateFormat('dd MMM yyyy').format(date);
//     final formattedTime = DateFormat('hh:mm a').format(date);
//     final fileName = asset.title ?? "Unknown";
//     final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.black,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) => Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Center(
//               child: Text(
//                 "Photo Details",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             detailRow("Name:", fileName),
//             detailRow("Date:", formattedDate),
//             detailRow("Time:", formattedTime),
//             detailRow("Dimension:", "${asset.width} × ${asset.height}"),
//             detailRow("Size:", "$sizeMB MB"),
//             detailRow("Path:", filePath),
//             const SizedBox(height: 10),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget detailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 90,
//             child: Text(title, style: const TextStyle(color: Colors.white54)),
//           ),
//           Expanded(
//             child: Text(value, style: const TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _ZoomablePage extends StatefulWidget {
//   final AssetEntity asset;
//   final VoidCallback onTap;
//   const _ZoomablePage({required this.asset, required this.onTap});
//   @override
//   State<_ZoomablePage> createState() => _ZoomablePageState();
// }

// class _ZoomablePageState extends State<_ZoomablePage>
//     with SingleTickerProviderStateMixin {
//   Uint8List? _imageData;
//   bool _loading = true;
//   bool _error = false;
//   final TransformationController _transformationController =
//       TransformationController();
//   late AnimationController _animController;
//   Animation<Matrix4>? _zoomAnimation;
//   Offset _doubleTapPosition = Offset.zero;

//   @override
//   void initState() {
//     super.initState();
//     _animController =
//         AnimationController(
//           vsync: this,
//           duration: const Duration(milliseconds: 200),
//         )..addListener(() {
//           if (_zoomAnimation != null) {
//             _transformationController.value = _zoomAnimation!.value;
//           }
//         });
//     _loadImage();
//   }

//   @override
//   void dispose() {
//     _transformationController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadImage() async {
//     try {
//       final data = await widget.asset
//           .thumbnailDataWithSize(
//             const ThumbnailSize(1080, 1920),
//             format: ThumbnailFormat.jpeg,
//             quality: 92,
//           )
//           .timeout(const Duration(seconds: 20), onTimeout: () => null);
//       if (mounted) {
//         setState(() {
//           _imageData = data;
//           _loading = false;
//           _error = data == null || data.isEmpty;
//         });
//       }
//     } catch (_) {
//       if (mounted)
//         setState(() {
//           _loading = false;
//           _error = true;
//         });
//     }
//   }

//   bool get _isZoomed =>
//       _transformationController.value.getMaxScaleOnAxis() > 1.01;

//   void _handleDoubleTap() {
//     final Matrix4 targetMatrix;
//     if (_isZoomed) {
//       targetMatrix = Matrix4.identity();
//     } else {
//       const double scale = 3.0;
//       final x = _doubleTapPosition.dx;
//       final y = _doubleTapPosition.dy;
//       targetMatrix = Matrix4.identity()
//         ..translate(-x * (scale - 1.0), -y * (scale - 1.0))
//         ..scale(scale);
//     }

//     _zoomAnimation = Matrix4Tween(
//       begin: _transformationController.value,
//       end: targetMatrix,
//     ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
//     _animController.forward(from: 0.0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     if (_loading) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.orange),
//       );
//     }
//     if (_error) {
//       return const Center(
//         child: Icon(
//           Icons.broken_image_outlined,
//           color: Colors.white38,
//           size: 60,
//         ),
//       );
//     }
//     return Listener(
//       onPointerDown: (event) => _doubleTapPosition = event.localPosition,
//       child: GestureDetector(
//         onTap: widget.onTap,
//         onDoubleTap: _handleDoubleTap,
//         child: InteractiveViewer(
//           transformationController: _transformationController,
//           minScale: 0.5,
//           maxScale: 6.0,
//           clipBehavior: Clip.none,
//           panEnabled: true,
//           onInteractionEnd: (_) => setState(() {}),
//           child: SizedBox(
//             width: size.width,
//             height: size.height,
//             child: Image.memory(
//               _imageData!,
//               fit: BoxFit.contain,
//               width: size.width,
//               height: size.height,
//               errorBuilder: (_, __, ___) => const Center(
//                 child: Icon(
//                   Icons.broken_image_outlined,
//                   color: Colors.white38,
//                   size: 60,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



//============= 2

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:chronogram/app_helper/mobile_mask/mobile_mask.dart';
// import 'package:chronogram/screens/home_screen/profile_screen.dart';
// import 'package:chronogram/screens/splash_screen/splash_screen.dart';
// import 'package:chronogram/service/api_service.dart';
// import 'package:flutter/material.dart';
// import 'package:photo_manager/photo_manager.dart';
// import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:chronogram/screens/login/login_provider/login_screen_provider.dart';
// import 'package:chronogram/screens/sign_up/sign_up_provider/sign_up_screen_provider.dart';
// import 'package:chronogram/modal/user_detail_modal.dart';
// import 'package:intl/intl.dart';

// class PhotoScreen extends StatefulWidget {
//   final UserDetailModal? user;
//   final String? userName;
//   const PhotoScreen({super.key, this.user, this.userName});
//   @override
//   State<PhotoScreen> createState() => _PhotoScreenState();
// }

// class _PhotoScreenState extends State<PhotoScreen> with WidgetsBindingObserver {
//   List<AssetEntity> _mediaList = [];
//   List<String> _groupOrder = [];
//   Map<String, List<AssetEntity>> _groupedMedia = {};
//   bool _isLoading = true;
//   bool _isFetchingMore = false;
//   int _currentPage = 0;
//   final int _pageSize = 80;
//   bool _hasMore = true;
//   bool _permissionDenied = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _fetchPhotos();
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed && _permissionDenied) {
//       _fetchPhotos();
//     }
//   }

//   Future<void> _fetchPhotos() async {
//     if (_currentPage == 0) {
//       if (mounted) {
//         setState(() {
//           _isLoading = true;
//           _permissionDenied = false;
//         });
//       }
//     } else {
//       if (mounted) setState(() => _isFetchingMore = true);
//     }

//     try {
//       final PermissionState ps = await PhotoManager.requestPermissionExtend()
//           .timeout(
//             const Duration(seconds: 15),
//             onTimeout: () => PermissionState.denied,
//           );

//       if (ps.isAuth) {
//         if (mounted) setState(() => _permissionDenied = false);

//         final filterOption = FilterOptionGroup(
//           orders: [
//             const OrderOption(type: OrderOptionType.createDate, asc: false),
//           ],
//         );

//         final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
//           type: RequestType.image,
//           onlyAll: true,
//           filterOption: filterOption,
//         );

//         if (paths.isNotEmpty) {
//           final List<AssetEntity> entities = await paths[0].getAssetListPaged(
//             page: _currentPage,
//             size: _pageSize,
//           );

//           if (mounted) {
//             setState(() {
//               if (_currentPage == 0) {
//                 _mediaList = entities;
//               } else {
//                 _mediaList.addAll(entities);
//               }
//               _hasMore = entities.length == _pageSize;
//               _groupPhotosByDate(_mediaList);
//               _isLoading = false;
//               _isFetchingMore = false;
//             });
//           }
//         } else {
//           if (mounted) {
//             setState(() {
//               _isLoading = false;
//               _isFetchingMore = false;
//               _hasMore = false;
//               _groupedMedia = {};
//             });
//           }
//         }
//       } else {
//         if (mounted) {
//           setState(() {
//             _isLoading = false;
//             _isFetchingMore = false;
//             _permissionDenied = true;
//           });
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _isFetchingMore = false;
//         });
//       }
//     }
//   }

//   void _groupPhotosByDate(List<AssetEntity> list) {
//     if (_currentPage == 0) {
//       _groupedMedia.clear();
//       _groupOrder.clear();
//     }

//     list.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final lastWeek = today.subtract(const Duration(days: 7));
//     final lastMonth = today.subtract(const Duration(days: 30));

//     for (var asset in list) {
//       final date = asset.createDateTime.toLocal();
//       final assetDate = DateTime(date.year, date.month, date.day);

//       String group;
//       if (assetDate == today) {
//         group = "TODAY";
//       } else if (assetDate == yesterday) {
//         group = "YESTERDAY";
//       } else if (assetDate.isAfter(lastWeek)) {
//         group = "LAST WEEK";
//       } else if (assetDate.isAfter(lastMonth)) {
//         group = "LAST MONTH";
//       } else {
//         group = DateFormat('MMMM yyyy').format(date).toUpperCase();
//       }

//       if (!_groupedMedia.containsKey(group)) {
//         _groupedMedia[group] = [];
//         _groupOrder.add(group);
//       }
//       _groupedMedia[group]!.add(asset);
//     }
//   }

//   // ── CHANGED: pass full list + index so viewer can swipe ──
//   void _showFullScreenImage(AssetEntity asset) {
//     final int index = _mediaList.indexOf(asset);
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => FullScreenImageViewer(
//           assets: _mediaList,
//           initialIndex: index < 0 ? 0 : index,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildPremiumHeader(),
//             const Divider(color: Colors.white12, height: 1),
//             //    _buildSubHeader(),
//             Expanded(
//               child: _isLoading
//                   ? const Center(
//                       child: CircularProgressIndicator(color: Colors.orange),
//                     )
//                   : _permissionDenied
//                   ? _buildPermissionDeniedView()
//                   : _groupedMedia.isEmpty
//                   ? _buildNoMediaView()
//                   : NotificationListener<ScrollNotification>(
//                       onNotification: (ScrollNotification scrollInfo) {
//                         if (!_isFetchingMore &&
//                             _hasMore &&
//                             scrollInfo.metrics.pixels >=
//                                 scrollInfo.metrics.maxScrollExtent - 300) {
//                           _currentPage++;
//                           _fetchPhotos();
//                         }
//                         return true;
//                       },
//                       child: CustomScrollView(
//                         slivers: [
//                           ..._groupOrder.map((groupKey) {
//                             final assets = _groupedMedia[groupKey]!;
//                             return SliverMainAxisGroup(
//                               slivers: [
//                                 SliverToBoxAdapter(
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(
//                                       left: 15,
//                                       top: 25,
//                                       bottom: 12,
//                                     ),
//                                     child: Text(
//                                       groupKey,
//                                       style: const TextStyle(
//                                         color: Colors.orange,
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.w800,
//                                         letterSpacing: 1.5,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SliverPadding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                   ),
//                                   sliver: SliverGrid(
//                                     gridDelegate:
//                                         const SliverGridDelegateWithFixedCrossAxisCount(
//                                           crossAxisCount: 4,
//                                           crossAxisSpacing: 5,
//                                           mainAxisSpacing: 5,
//                                         ),
//                                     delegate: SliverChildBuilderDelegate((
//                                       context,
//                                       index,
//                                     ) {
//                                       final asset = assets[index];
//                                       return _SmoothClick(
//                                         onTap: () =>
//                                             _showFullScreenImage(asset),
//                                         child: Stack(
//                                           fit: StackFit.expand,
//                                           children: [
//                                             ClipRRect(
//                                               borderRadius:
//                                                   BorderRadius.circular(10),
//                                               child: _AssetThumbnail(
//                                                 asset: asset,
//                                               ),
//                                             ),
//                                             if (asset.type == AssetType.video)
//                                               const Positioned(
//                                                 right: 4,
//                                                 top: 4,
//                                                 child: Icon(
//                                                   Icons.play_circle_fill,
//                                                   color: Colors.white,
//                                                   size: 16,
//                                                 ),
//                                               ),
//                                           ],
//                                         ),
//                                       );
//                                     }, childCount: assets.length),
//                                   ),
//                                 ),
//                               ],
//                             );
//                           }).toList(),
//                           if (_isFetchingMore)
//                             const SliverToBoxAdapter(
//                               child: Padding(
//                                 padding: EdgeInsets.all(25),
//                                 child: Center(
//                                   child: CircularProgressIndicator(
//                                     color: Colors.orange,
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           const SliverToBoxAdapter(
//                             child: SizedBox(height: 100),
//                           ),
//                         ],
//                       ),
//                     ),
//             ),
//           ],
//         ),
//       ),

//       // floatingActionButton: Padding(
//       //   padding: const EdgeInsets.only(bottom: 10, right: 5),
//       //   child: FloatingActionButton(
//       //     onPressed: () {},
//       //     backgroundColor: Colors.orange,
//       //     shape: RoundedRectangleBorder(
//       //       borderRadius: BorderRadius.circular(30),
//       //     ),
//       //     child: const Icon(Icons.more_vert, color: Colors.white),
//       //   ),
//       // ),
//     );
//   }

//   Widget _buildPremiumHeader() {
//     String name = widget.userName ?? "User";
//     return Container(
//       padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
//       decoration: BoxDecoration(
//         color: Colors.black,
//         border: Border(
//           bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 50,
//             height: 50,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Colors.orange.withOpacity(0.5),
//                 width: 1.5,
//               ),
//               color: Colors.white.withOpacity(0.05),
//             ),
//             child: Center(
//               child: Text(
//                 _getInitials(name),
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Text(
//                   "My Gallery",
//                   style: TextStyle(color: Colors.white54, fontSize: 13),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: Colors.orange.withOpacity(0.15),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: Colors.orange.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: const Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircleAvatar(radius: 3, backgroundColor: Colors.orange),
//                 SizedBox(width: 6),
//                 Text(
//                   "Synced",
//                   style: TextStyle(
//                     color: Colors.orange,
//                     fontSize: 11,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 15),
//           IconButton(
//             onPressed: () {
//               _currentPage = 0;
//               _fetchPhotos();
//             },
//             icon: const Icon(Icons.refresh, color: Colors.white70, size: 22),
//             constraints: const BoxConstraints(),
//             padding: EdgeInsets.zero,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPermissionDeniedView() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.lock_outline, color: Colors.white24, size: 60),
//           const SizedBox(height: 20),
//           const Text(
//             "Gallery Access Denied",
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Please grant permissions to see your media",
//             style: TextStyle(color: Colors.white54),
//           ),
//           const SizedBox(height: 30),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   _currentPage = 0;
//                   _fetchPhotos();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white10,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                 ),
//                 child: const Text("Try Again"),
//               ),
//               const SizedBox(width: 15),
//               ElevatedButton(
//                 onPressed: () => PhotoManager.openSetting(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.orange,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 25,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(25),
//                   ),
//                 ),
//                 child: const Text("Open Settings"),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildSubHeader() {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
//   //     child: Row(
//   //       children:  [
//   //         Icon(Icons.folder_open_outlined, color: Colors.orange, size: 20),
//   //         SizedBox(width: 10),
//   //         InkWell(

//   //           child: Text(
//   //             "Select Folder for Sync",
//   //             style: TextStyle(
//   //               color: Colors.orange,
//   //               fontSize: 13,
//   //               fontWeight: FontWeight.w800,
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _buildNoMediaView() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.photo_library_outlined, color: Colors.white12, size: 60),
//           SizedBox(height: 15),
//           Text(
//             "No Photos Found",
//             style: TextStyle(color: Colors.white38, fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }

//   String _getInitials(String name) {
//     if (name.trim().isEmpty) return "U";
//     List<String> parts = name.trim().split(RegExp(r'\s+'));
//     if (parts.length == 1) return parts[0][0].toUpperCase();
//     return (parts[0][0] + parts[1][0]).toUpperCase();
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// class _SmoothClick extends StatefulWidget {
//   final Widget child;
//   final VoidCallback? onTap;
//   const _SmoothClick({required this.child, this.onTap});
//   @override
//   State<_SmoothClick> createState() => _SmoothClickState();
// }

// class _SmoothClickState extends State<_SmoothClick> {
//   bool _isPressed = false;
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapDown: (_) => setState(() => _isPressed = true),
//       onTapUp: (_) => setState(() => _isPressed = false),
//       onTapCancel: () => setState(() => _isPressed = false),
//       onTap: widget.onTap,
//       child: AnimatedScale(
//         scale: _isPressed ? 0.95 : 1.0,
//         duration: const Duration(milliseconds: 100),
//         child: widget.child,
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────

// class _AssetThumbnail extends StatefulWidget {
//   final AssetEntity asset;
//   const _AssetThumbnail({required this.asset});
//   @override
//   State<_AssetThumbnail> createState() => _AssetThumbnailState();
// }

// class _AssetThumbnailState extends State<_AssetThumbnail> {
//   late final Future<Uint8List?> _thumbFuture;
//   @override
//   void initState() {
//     super.initState();
//     _thumbFuture = widget.asset
//         .thumbnailDataWithSize(
//           const ThumbnailSize.square(150),
//           format: ThumbnailFormat.jpeg,
//           quality: 60,
//         )
//         .timeout(const Duration(seconds: 10), onTimeout: () => null);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Uint8List?>(
//       future: _thumbFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState != ConnectionState.done) {
//           return Container(
//             color: const Color(0xff1A1A1A),
//             child: const Center(
//               child: Icon(
//                 Icons.image_outlined,
//                 color: Colors.white24,
//                 size: 22,
//               ),
//             ),
//           );
//         }
//         final data = snapshot.data;
//         if (data == null || data.isEmpty) {
//           return Container(
//             color: const Color(0xff1A1A1A),
//             child: const Center(
//               child: Icon(
//                 Icons.broken_image_outlined,
//                 color: Colors.white24,
//                 size: 22,
//               ),
//             ),
//           );
//         }
//         return Image.memory(
//           data,
//           fit: BoxFit.cover,
//           cacheWidth: 150,
//           errorBuilder: (_, __, ___) => Container(
//             color: const Color(0xff1A1A1A),
//             child: const Center(
//               child: Icon(
//                 Icons.broken_image_outlined,
//                 color: Colors.white24,
//                 size: 22,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // FullScreenImageViewer  —  LEFT / RIGHT swipe + double-tap zoom
// // ─────────────────────────────────────────────────────────────────────────────

// class FullScreenImageViewer extends StatefulWidget {
//   /// Full list of photos (same order as gallery)
//   final List<AssetEntity> assets;

//   /// Which photo to open first
//   final int initialIndex;

//   const FullScreenImageViewer({
//     super.key,
//     required this.assets,
//     required this.initialIndex,
//   });
//   @override
//   State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
// }

// class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
//   late final PageController _pageController;
//   late int _currentIndex;
//   bool _showAppBar = true;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: widget.initialIndex);
//   }

//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final asset = widget.assets[_currentIndex];
//     final date = asset.createDateTime.toLocal();
//     final formattedDate = DateFormat('dd MMM yyyy').format(date);
//     final formatTimes = DateFormat('hh:mm a').format(date);
//     return Scaffold(
//       backgroundColor: Colors.black,
//       extendBodyBehindAppBar: true,
//       appBar: _showAppBar
//           ? AppBar(
//               backgroundColor: Colors.black.withOpacity(0.45),
//               iconTheme: const IconThemeData(color: Colors.white),
//               elevation: 0,
//               title: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   Text(
//                     formattedDate,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 2),
//                   Text(
//                     formatTimes,
//                     style: TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                 ],
//               ),
//               centerTitle: true,
//               actions: [

//                 PopupMenuButton(
//                   icon: Icon(Icons.more_vert, color: Colors.white),
//                   color: Colors.black,
//                   onSelected: (value) {
//                     if (value == 'Details') {
//                       _showPhotoDetails(widget.assets[_currentIndex]);
//                     }
//                   },
//                   itemBuilder: (context) => [
//                     PopupMenuItem(
//                       value: 'Details',
//                       child: Text(
//                         'More Details',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),                    
//                   ],
//                 ),
                
//               ],
//             )
//           : null,
//       body: PageView.builder(
//         controller: _pageController,
//         itemCount: widget.assets.length,
//         // Disable PageView scroll while user is zoomed in on a photo
//         // (handled per-page via physics override in _ZoomablePage)
//         onPageChanged: (index) {
//           setState(() => _currentIndex = index);
//         },
//         itemBuilder: (context, index) {
//           return _ZoomablePage(
//             asset: widget.assets[index],
//             onTap: () => setState(() => _showAppBar = !_showAppBar),
//           );
//         },
//       ),
//     );
//   }

//   void _showPhotoDetails(AssetEntity asset) async {
//     print('=== DETAILS OPENED ===');
    
//     final file = await asset.file;
//     int fileSize = 0;
//     String filePath = "Unavailable";

//     if (file != null) {
//       fileSize = await file.length();
//       filePath = file.path;
//       print('=== FILE PATH: $filePath ==='); // YE BHI ADD KAR
//     }else{
//       print('=== FILE IS NULL ==='); // NULL CHECK
//     }

//     final date = asset.createDateTime.toLocal();
//     final formattedDate = DateFormat('dd MMM yyyy').format(date);
//     final formattedTime = DateFormat('hh:mm a').format(date);
//     final fileName = asset.title ?? "Unknown";
//     final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.black,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Center(
//                 child: Text(
//                   "Photo Details",
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               detailRow("Name:", fileName),
//               detailRow("Date:", formattedDate),
//               detailRow("Time:", formattedTime),
//               detailRow("Dimension:", "${asset.width} × ${asset.height}"),
//               detailRow("Size:", "$sizeMB MB"),
//               detailRow("Source:", _getPhotoSource(filePath)), // ye add kar 
//               detailRow("Path:", filePath),

//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
      
//   }

//    // Ye helper function add kar class ke andar
//     String _getPhotoSource(String path) {
//       final p = path.toLowerCase();
//       if (p.contains('whatsapp')) return '💬 WhatsApp';
//       if (p.contains('telegram')) return '✈️ Telegram';
//       if (p.contains('instagram')) return '📸 Instagram';
//       if (p.contains('screenshot')) return '📷 Screenshot';
//       if (p.contains('download')) return '🌐 Downloaded';
//       if (p.contains('dcim/camera')) return '📹 Camera';
//       if (p.contains('dcim')) return '📹 Camera Roll';
//       if (p.contains('snapchat')) return '👻 Snapchat';
//       return '📁 Other';
//     }



//   Widget detailRow(String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 90,
//             child: Text(title, style: const TextStyle(color: Colors.white54)),
//           ),
//           Expanded(
//             child: Text(value, style: const TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // _ZoomablePage  —  one page inside PageView; handles zoom + double-tap
// // Swipe left/right only works when image is NOT zoomed in (scale == 1).
// // When zoomed, horizontal pan stays inside InteractiveViewer.
// // ─────────────────────────────────────────────────────────────────────────────
// class _ZoomablePage extends StatefulWidget {
//   final AssetEntity asset;
//   final VoidCallback onTap;

//   const _ZoomablePage({required this.asset, required this.onTap});
//   @override
//   State<_ZoomablePage> createState() => _ZoomablePageState();
// }

// class _ZoomablePageState extends State<_ZoomablePage>
//     with SingleTickerProviderStateMixin {
//   Uint8List? _imageData;
//   bool _loading = true;
//   bool _error = false;

//   final TransformationController _transformationController =
//       TransformationController();

//   late AnimationController _animController;
//   Animation<Matrix4>? _zoomAnimation;

//   Offset _doubleTapPosition = Offset.zero;

//   @override
//   void initState() {
//     super.initState();

//     _animController =
//         AnimationController(
//           vsync: this,
//           duration: const Duration(milliseconds: 200),
//         )..addListener(() {
//           if (_zoomAnimation != null) {
//             _transformationController.value = _zoomAnimation!.value;
//           }
//         });

//     _loadImage();
//   }

//   @override
//   void dispose() {
//     _transformationController.dispose();
//     _animController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadImage() async {
//     try {
//       final data = await widget.asset
//           .thumbnailDataWithSize(
//             const ThumbnailSize(1080, 1920),
//             format: ThumbnailFormat.jpeg,
//             quality: 92,
//           )
//           .timeout(const Duration(seconds: 20), onTimeout: () => null);
//       if (mounted) {
//         setState(() {
//           _imageData = data;
//           _loading = false;
//           _error = data == null || data.isEmpty;
//         });
//       }
//     } catch (_) {
//       if (mounted)
//         setState(() {
//           _loading = false;
//           _error = true;
//         });
//     }
//   }

//   bool get _isZoomed =>
//       _transformationController.value.getMaxScaleOnAxis() > 1.01;

//   void _handleDoubleTap() {
//     final Matrix4 targetMatrix;

//     if (_isZoomed) {
//       targetMatrix = Matrix4.identity();
//     } else {
//       const double scale = 3.0;
//       final x = _doubleTapPosition.dx;
//       final y = _doubleTapPosition.dy;
//       targetMatrix = Matrix4.identity()
//         ..translate(-x * (scale - 1.0), -y * (scale - 1.0))
//         ..scale(scale);
//     }

//     _zoomAnimation = Matrix4Tween(
//       begin: _transformationController.value,
//       end: targetMatrix,
//     ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

//     _animController.forward(from: 0.0);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;

//     if (_loading) {
//       return const Center(
//         child: CircularProgressIndicator(color: Colors.orange),
//       );
//     }

//     if (_error) {
//       return const Center(
//         child: Icon(
//           Icons.broken_image_outlined,
//           color: Colors.white38,
//           size: 60,
//         ),
//       );
//     }

//     return Listener(
//       onPointerDown: (event) {
//         _doubleTapPosition = event.localPosition;
//       },
//       child: GestureDetector(
//         onTap: widget.onTap,
//         onDoubleTap: _handleDoubleTap,
//         child: InteractiveViewer(
//           transformationController: _transformationController,
//           minScale: 0.5,
//           maxScale: 6.0,
//           clipBehavior: Clip.none,
//           // When zoomed, lock PageView scrolling so pan works freely
//           panEnabled: true,
//           onInteractionEnd: (_) => setState(() {}), // refresh _isZoomed
//           child: SizedBox(
//             width: size.width,
//             height: size.height,
//             child: Image.memory(
//               _imageData!,
//               fit: BoxFit.contain,
//               width: size.width,
//               height: size.height,
//               errorBuilder: (_, __, ___) => const Center(
//                 child: Icon(
//                   Icons.broken_image_outlined,
//                   color: Colors.white38,
//                   size: 60,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

  
// }


import 'dart:io';
import 'dart:typed_data';
import 'package:chronogram/screens/home_screen/profile_screen.dart';
import 'package:chronogram/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:chronogram/modal/user_detail_modal.dart';
import 'package:intl/intl.dart';

class PhotoScreen extends StatefulWidget {
  final UserDetailModal? user;
  final String? userName;
  const PhotoScreen({super.key, this.user, this.userName});
  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> with WidgetsBindingObserver {
  // ── Gallery state ──
  List<AssetEntity> _mediaList = [];
  List<String> _groupOrder = [];
  Map<String, List<AssetEntity>> _groupedMedia = {};
  bool _isLoading = true;
  bool _isFetchingMore = false;
  int _currentPage = 0;
  final int _pageSize = 80;
  bool _hasMore = true;
  bool _permissionDenied = false;

  // ── Selection & Upload state ──
  bool _isSelectionMode = false;
  Set<int> _selectedIndexes = {};
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchPhotos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _permissionDenied) {
      _fetchPhotos();
    }
  }

  // ── Fetch Photos ──
  Future<void> _fetchPhotos() async {
    if (_currentPage == 0) {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _permissionDenied = false;
        });
      }
    } else {
      if (mounted) setState(() => _isFetchingMore = true);
    }

    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend()
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => PermissionState.denied,
          );

      if (ps.isAuth) {
        if (mounted) setState(() => _permissionDenied = false);

        final filterOption = FilterOptionGroup(
          orders: [
            const OrderOption(type: OrderOptionType.createDate, asc: false),
          ],
        );

        final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
          type: RequestType.image,
          onlyAll: true,
          filterOption: filterOption,
        );

        if (paths.isNotEmpty) {
          final List<AssetEntity> entities = await paths[0].getAssetListPaged(
            page: _currentPage,
            size: _pageSize,
          );

          if (mounted) {
            setState(() {
              if (_currentPage == 0) {
                _mediaList = entities;
              } else {
                _mediaList.addAll(entities);
              }
              _hasMore = entities.length == _pageSize;
              _groupPhotosByDate(_mediaList);
              _isLoading = false;
              _isFetchingMore = false;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _isFetchingMore = false;
              _hasMore = false;
              _groupedMedia = {};
            });
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isFetchingMore = false;
            _permissionDenied = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isFetchingMore = false;
        });
      }
    }
  }

  // ── Group by Date ──
  void _groupPhotosByDate(List<AssetEntity> list) {
    if (_currentPage == 0) {
      _groupedMedia.clear();
      _groupOrder.clear();
    }

    list.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));
    final lastMonth = today.subtract(const Duration(days: 30));

    for (var asset in list) {
      final date = asset.createDateTime.toLocal();
      final assetDate = DateTime(date.year, date.month, date.day);

      String group;
      if (assetDate == today) {
        group = "TODAY";
      } else if (assetDate == yesterday) {
        group = "YESTERDAY";
      } else if (assetDate.isAfter(lastWeek)) {
        group = "LAST WEEK";
      } else if (assetDate.isAfter(lastMonth)) {
        group = "LAST MONTH";
      } else {
        group = DateFormat('MMMM yyyy').format(date).toUpperCase();
      }

      if (!_groupedMedia.containsKey(group)) {
        _groupedMedia[group] = [];
        _groupOrder.add(group);
      }
      _groupedMedia[group]!.add(asset);
    }
  }

  // ── Open Full Screen ──
  void _showFullScreenImage(AssetEntity asset) {
    final int index = _mediaList.indexOf(asset);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenImageViewer(
          assets: _mediaList,
          initialIndex: index < 0 ? 0 : index,
        ),
      ),
    );
  }

  // ── Upload Selected Photos ──
  Future<void> _uploadSelectedPhotos() async {
    if (_selectedIndexes.isEmpty) return;

    setState(() => _isUploading = true);

    try {
      // AssetEntity → File convert karo
      List<File> filesToUpload = [];
      for (final idx in _selectedIndexes) {
        final asset = _mediaList[idx];
        final file = await asset.file;
        if (file != null) filesToUpload.add(file);
      }

      if (filesToUpload.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koi file nahi mili upload ke liye!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final result = await ApiService.uploadImages(
        imageFiles: filesToUpload,
        type: 'personal',
      );

      if (result['status'] == 'success') {
        final List images = result['images'] ?? [];
        setState(() {
          _isSelectionMode = false;
          _selectedIndexes = {};
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${images.length} photos sync ho gayi!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? result['error'] ?? 'Upload failed!',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong!'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildPremiumHeader(),
            const Divider(color: Colors.white12, height: 1),

            // ── Selection mode banner ──
            if (_isSelectionMode) _buildSelectionBanner(),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
                  : _permissionDenied
                  ? _buildPermissionDeniedView()
                  : _groupedMedia.isEmpty
                  ? _buildNoMediaView()
                  : NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isFetchingMore &&
                            _hasMore &&
                            scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 300) {
                          _currentPage++;
                          _fetchPhotos();
                        }
                        return true;
                      },
                      child: CustomScrollView(
                        slivers: [
                          ..._groupOrder.map((groupKey) {
                            final assets = _groupedMedia[groupKey]!;
                            return SliverMainAxisGroup(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 15,
                                      top: 25,
                                      bottom: 12,
                                    ),
                                    child: Text(
                                      groupKey,
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  sliver: SliverGrid(
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 4,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 5,
                                        ),
                                    delegate: SliverChildBuilderDelegate((
                                      context,
                                      index,
                                    ) {
                                      final asset = assets[index];
                                      final globalIdx = _mediaList.indexOf(asset);
                                      final isSelected = _selectedIndexes.contains(globalIdx);

                                      return _SmoothClick(
                                        onTap: () {
                                          if (_isSelectionMode) {
                                            // Toggle selection
                                            setState(() {
                                              if (isSelected) {
                                                _selectedIndexes.remove(globalIdx);
                                                if (_selectedIndexes.isEmpty) {
                                                  _isSelectionMode = false;
                                                }
                                              } else {
                                                _selectedIndexes.add(globalIdx);
                                              }
                                            });
                                          } else {
                                            _showFullScreenImage(asset);
                                          }
                                        },
                                        onLongPress: () {
                                          if (!_isSelectionMode) {
                                            setState(() {
                                              _isSelectionMode = true;
                                              _selectedIndexes.add(globalIdx);
                                            });
                                          }
                                        },
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: _AssetThumbnail(asset: asset),
                                            ),
                                            if (asset.type == AssetType.video)
                                              const Positioned(
                                                right: 4,
                                                top: 4,
                                                child: Icon(
                                                  Icons.play_circle_fill,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            // Selection overlay
                                            if (_isSelectionMode)
                                              Positioned.fill(
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Container(
                                                    color: isSelected
                                                        ? Colors.blue.withOpacity(0.35)
                                                        : Colors.black.withOpacity(0.15),
                                                  ),
                                                ),
                                              ),
                                            // Checkbox
                                            if (_isSelectionMode)
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: Container(
                                                  width: 20,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: isSelected
                                                        ? Colors.blue
                                                        : Colors.white.withOpacity(0.3),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? Colors.blue
                                                          : Colors.white,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: isSelected
                                                      ? const Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 12,
                                                        )
                                                      : null,
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }, childCount: assets.length),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                          if (_isFetchingMore)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(25),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.orange,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),

      // ── Bottom bar — only in selection mode ──
      bottomNavigationBar: _isSelectionMode
          ? Container(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 30),
              color: const Color(0xff1A1A1A),
              child: Row(
                children: [
                  // Cancel button
                  GestureDetector(
                    onTap: () => setState(() {
                      _isSelectionMode = false;
                      _selectedIndexes = {};
                    }),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_selectedIndexes.length} selected',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  const SizedBox(width: 15),
                  // Sync/Upload button
                  ElevatedButton.icon(
                    onPressed: _isUploading ? null : _uploadSelectedPhotos,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.cloud_upload, size: 16),
                    label: Text(_isUploading ? 'Uploading...' : 'Sync'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  // ── Selection Banner ──
  Widget _buildSelectionBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      color: Colors.blue.withOpacity(0.12),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.blue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _selectedIndexes.isEmpty
                  ? 'Photos select karo sync ke liye'
                  : '${_selectedIndexes.length} photos selected',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          if (_selectedIndexes.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _selectedIndexes = {}),
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Premium Header ──
  Widget _buildPremiumHeader() {
    String name = widget.userName ?? "User";
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.orange.withOpacity(0.5),
                width: 1.5,
              ),
              color: Colors.white.withOpacity(0.05),
            ),
            child: Center(
              child: Text(
                _getInitials(name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "My Gallery",
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 3, backgroundColor: Colors.orange),
                SizedBox(width: 6),
                Text(
                  "Synced",
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          IconButton(
            onPressed: () {
              _currentPage = 0;
              _fetchPhotos();
            },
            icon: const Icon(Icons.refresh, color: Colors.white70, size: 22),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // ── Permission Denied ──
  Widget _buildPermissionDeniedView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline, color: Colors.white24, size: 60),
          const SizedBox(height: 20),
          const Text(
            "Gallery Access Denied",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please grant permissions to see your media",
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _currentPage = 0;
                  _fetchPhotos();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white10,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text("Try Again"),
              ),
              const SizedBox(width: 15),
              ElevatedButton(
                onPressed: () => PhotoManager.openSetting(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text("Open Settings"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── No Media ──
  Widget _buildNoMediaView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, color: Colors.white12, size: 60),
          SizedBox(height: 15),
          Text(
            "No Photos Found",
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SmoothClick — with longPress support
// ─────────────────────────────────────────────────────────────────────────────
class _SmoothClick extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const _SmoothClick({required this.child, this.onTap, this.onLongPress});
  @override
  State<_SmoothClick> createState() => _SmoothClickState();
}

class _SmoothClickState extends State<_SmoothClick> {
  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Asset Thumbnail
// ─────────────────────────────────────────────────────────────────────────────
class _AssetThumbnail extends StatefulWidget {
  final AssetEntity asset;
  const _AssetThumbnail({required this.asset});
  @override
  State<_AssetThumbnail> createState() => _AssetThumbnailState();
}

class _AssetThumbnailState extends State<_AssetThumbnail> {
  late final Future<Uint8List?> _thumbFuture;
  @override
  void initState() {
    super.initState();
    _thumbFuture = widget.asset
        .thumbnailDataWithSize(
          const ThumbnailSize.square(150),
          format: ThumbnailFormat.jpeg,
          quality: 60,
        )
        .timeout(const Duration(seconds: 10), onTimeout: () => null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: _thumbFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Container(
            color: const Color(0xff1A1A1A),
            child: const Center(
              child: Icon(Icons.image_outlined, color: Colors.white24, size: 22),
            ),
          );
        }
        final data = snapshot.data;
        if (data == null || data.isEmpty) {
          return Container(
            color: const Color(0xff1A1A1A),
            child: const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 22),
            ),
          );
        }
        return Image.memory(
          data,
          fit: BoxFit.cover,
          cacheWidth: 150,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xff1A1A1A),
            child: const Center(
              child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 22),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FullScreenImageViewer
// ─────────────────────────────────────────────────────────────────────────────
class FullScreenImageViewer extends StatefulWidget {
  final List<AssetEntity> assets;
  final int initialIndex;
  const FullScreenImageViewer({
    super.key,
    required this.assets,
    required this.initialIndex,
  });
  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  bool _showAppBar = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.assets[_currentIndex];
    final date = asset.createDateTime.toLocal();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    final formatTimes = DateFormat('hh:mm a').format(date);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showAppBar
          ? AppBar(
              backgroundColor: Colors.black.withOpacity(0.45),
              iconTheme: const IconThemeData(color: Colors.white),
              elevation: 0,
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatTimes,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
              centerTitle: true,
              actions: [
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  color: Colors.black,
                  onSelected: (value) {
                    if (value == 'Details') {
                      _showPhotoDetails(widget.assets[_currentIndex]);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'Details',
                      child: Text(
                        'More Details',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            )
          : null,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.assets.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return _ZoomablePage(
            asset: widget.assets[index],
            onTap: () => setState(() => _showAppBar = !_showAppBar),
          );
        },
      ),
    );
  }

  void _showPhotoDetails(AssetEntity asset) async {
    final file = await asset.file;
    int fileSize = 0;
    String filePath = "Unavailable";

    if (file != null) {
      fileSize = await file.length();
      filePath = file.path;
    }

    final date = asset.createDateTime.toLocal();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);
    final fileName = asset.title ?? "Unknown";
    final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(2);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Photo Details",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _detailRow("Name:", fileName),
              _detailRow("Date:", formattedDate),
              _detailRow("Time:", formattedTime),
              _detailRow("Dimension:", "${asset.width} × ${asset.height}"),
              _detailRow("Size:", "$sizeMB MB"),
              _detailRow("Source:", _getPhotoSource(filePath)),
              _detailRow("Path:", filePath),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  String _getPhotoSource(String path) {
    final p = path.toLowerCase();
    if (p.contains('whatsapp')) return '💬 WhatsApp';
    if (p.contains('telegram')) return '✈️ Telegram';
    if (p.contains('instagram')) return '📸 Instagram';
    if (p.contains('screenshot')) return '📷 Screenshot';
    if (p.contains('download')) return '🌐 Downloaded';
    if (p.contains('dcim/camera')) return '📹 Camera';
    if (p.contains('dcim')) return '📹 Camera Roll';
    if (p.contains('snapchat')) return '👻 Snapchat';
    return '📁 Other';
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(title, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ZoomablePage
// ─────────────────────────────────────────────────────────────────────────────
class _ZoomablePage extends StatefulWidget {
  final AssetEntity asset;
  final VoidCallback onTap;
  const _ZoomablePage({required this.asset, required this.onTap});
  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage>
    with SingleTickerProviderStateMixin {
  Uint8List? _imageData;
  bool _loading = true;
  bool _error = false;

  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _animController;
  Animation<Matrix4>? _zoomAnimation;
  Offset _doubleTapPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        if (_zoomAnimation != null) {
          _transformationController.value = _zoomAnimation!.value;
        }
      });
    _loadImage();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    try {
      final data = await widget.asset
          .thumbnailDataWithSize(
            const ThumbnailSize(1080, 1920),
            format: ThumbnailFormat.jpeg,
            quality: 92,
          )
          .timeout(const Duration(seconds: 20), onTimeout: () => null);
      if (mounted) {
        setState(() {
          _imageData = data;
          _loading = false;
          _error = data == null || data.isEmpty;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = true;
        });
      }
    }
  }

  bool get _isZoomed =>
      _transformationController.value.getMaxScaleOnAxis() > 1.01;

  void _handleDoubleTap() {
    final Matrix4 targetMatrix;
    if (_isZoomed) {
      targetMatrix = Matrix4.identity();
    } else {
      const double scale = 3.0;
      final x = _doubleTapPosition.dx;
      final y = _doubleTapPosition.dy;
      targetMatrix = Matrix4.identity()
        ..translate(-x * (scale - 1.0), -y * (scale - 1.0))
        ..scale(scale);
    }

    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: targetMatrix,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.orange),
      );
    }

    if (_error) {
      return const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 60),
      );
    }

    return Listener(
      onPointerDown: (event) => _doubleTapPosition = event.localPosition,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: _handleDoubleTap,
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 6.0,
          clipBehavior: Clip.none,
          panEnabled: true,
          onInteractionEnd: (_) => setState(() {}),
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Image.memory(
              _imageData!,
              fit: BoxFit.contain,
              width: size.width,
              height: size.height,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white38,
                  size: 60,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}