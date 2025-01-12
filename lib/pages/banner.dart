import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase SDK
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore package

class BannerImage extends StatefulWidget {
  const BannerImage({super.key});

  @override
  State<BannerImage> createState() => _BannerImage();
}

class _BannerImage extends State<BannerImage> {
  Map<String, dynamic>? editingBanner;
  Set<String> selectedBanners = {};
  bool isCreatingBanner = false;
  Uint8List? selectedImageBytes;
  String? uploadedImageUrl;
  List<Map<String, dynamic>> banners = [];

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadBannersFromFirestore();
  }

  Future<void> _loadBannersFromFirestore() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('banners').get();

      setState(() {
        banners = querySnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'url': data['url'] ?? '',
            'active': data['active'] ?? true,
          };
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load banners: $e')),
      );
    }
  }

  Future<void> _saveBannerToFirestore(String url, bool active) async {
    try {
      final docRef = await FirebaseFirestore.instance.collection('banners').add({
        'url': url,
        'active': active,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        banners.add({
          'id': docRef.id,
          'url': url,
          'active': active,
        });

        isCreatingBanner = false;
        selectedImageBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banner created successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save banner: $e')),
      );
    }
  }

  Future<void> selectImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final Uint8List imageBytes = await image.readAsBytes();

      setState(() {
        selectedImageBytes = imageBytes;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selected successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image selected')),
      );
    }
  }

Future<void> uploadImage() async {
  if (selectedImageBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No image selected to upload')),
    );
    return;
  }

  try {
    // Define the folder name and construct the file path
    const folderName = 'banner/';
    final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final filePath = '$folderName$fileName';

    // Upload the image to the specified folder
    await supabase.storage.from('Balungao NHS').uploadBinary(
          filePath,
          selectedImageBytes!,
        );

    // Retrieve the public URL of the uploaded image
    final downloadUrl = supabase.storage.from('Balungao NHS').getPublicUrl(filePath);

    // Save the URL and additional information to Firestore
    await _saveBannerToFirestore(downloadUrl, true);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image uploaded successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to upload image: $e')),
    );
  }
}


Future<void> saveChanges() async {
  if (editingBanner == null) return;

  try {
    String? newImageUrl = editingBanner!['url'];
    String? oldImageUrl = editingBanner!['url'];

    if (selectedImageBytes != null) {
      // Remove old image from Supabase Storage
      if (oldImageUrl != null) {
        final oldFilePath = oldImageUrl.replaceFirst(
          supabase.storage.from('Balungao NHS').getPublicUrl(''),
          '',
        );
        await supabase.storage.from('Balungao NHS').remove([oldFilePath]);
      }

      // Upload new image
      final fileName = 'banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
      const folderName = 'banner/';
      final filePath = '$folderName$fileName';

      await supabase.storage.from('Balungao NHS').uploadBinary(
            filePath,
            selectedImageBytes!,
          );

      // Retrieve the public URL of the uploaded image
      newImageUrl = supabase.storage.from('Balungao NHS').getPublicUrl(filePath);
    }

    // Update Firestore with new image URL
    await FirebaseFirestore.instance
        .collection('banners')
        .doc(editingBanner!['id'])
        .update({
      'url': newImageUrl,
      'active': editingBanner!['active'],
    });

    // Update the local state
    setState(() {
      final index = banners.indexWhere((banner) => banner['id'] == editingBanner!['id']);
      if (index != -1) {
        banners[index]['url'] = newImageUrl;
      }
      isCreatingBanner = false;
      editingBanner = null;
      selectedImageBytes = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Banner updated successfully!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update banner: $e')),
    );
  }
}

  Future<void> deleteBanner(String id, String imageUrl, int index) async {
    try {
      final filePath = imageUrl.replaceFirst(
        supabase.storage.from('Balungao NHS').getPublicUrl(''),
        '',
      );

      await supabase.storage.from('Balungao NHS').remove([filePath]);
      await FirebaseFirestore.instance.collection('banners').doc(id).delete();

      setState(() {
        banners.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Banner deleted successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete banner: $e')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isCreatingBanner ? _buildCreateBannerUI() : _buildMainUI(),
      ),
    );
  }
  // Main UI
// Main UI
Widget _buildMainUI() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Banner',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () {
          setState(() {
            isCreatingBanner = true;
          });
        },
        child: const Text('Create New Banner'),
      ),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: const [
            SizedBox(width: 50),
            Expanded(
              flex: 1,
              child: Text(
                'Banner',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(
                'Active',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: Text(
                'Action',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      banners.isEmpty
          ? Expanded(
              child: Center(
                child: Container(
                  height: 200,
                  alignment: Alignment.center,
                  color: Colors.grey[200], // Placeholder background
                  child: const Text(
                    'No Banners Available',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          : Expanded(
              child: ListView.builder(
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Checkbox(
                            value: selectedBanners.contains(banner['id']),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedBanners.add(banner['id']); // Add to selection
                                } else {
                                  selectedBanners.remove(banner['id']); // Remove from selection
                                }
                              });
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Card(
                            elevation: 4, // Adds shadow to the card
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: banner['url'].isNotEmpty
                                ? Image.network(
                                    banner['url'],
                                    height: 160,
                                    width: 80,
                                    fit: BoxFit.cover, // Fills the card while keeping aspect ratio
                                  )
                                : Center(
                                    child: Text(
                                      'No Image',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            onPressed: () async {
                              // Toggle the 'active' status
                              bool newStatus = !banner['active'];
                              setState(() {
                                banners[index]['active'] = newStatus;
                              });

                              // Update Firestore
                              if (banner.containsKey('id')) {
                                await FirebaseFirestore.instance
                                    .collection('banners')
                                    .doc(banner['id'])
                                    .update({'active': newStatus});
                              }
                            },
                            icon: Icon(
                              banner['active'] ? Iconsax.eye_copy : Iconsax.eye_slash_copy,
                              color: banner['active'] ? Colors.green : Colors.red,
                              size: 24,
                            ),
                            tooltip: banner['active'] ? 'Deactivate' : 'Activate',
                            splashColor: Colors.transparent, // No splash effect
                            highlightColor: Colors.transparent, // No highlight effect
                            hoverColor: Colors.transparent, // No hover color effect
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    editingBanner = banner; // Set the banner being edited
                                    isCreatingBanner = true; // Switch to "Create Banner" UI
                                    selectedImageBytes = null; // Clear new image if any
                                  });
                                },
                                icon: const Icon(
                                  Iconsax.edit_copy,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(
                                  Iconsax.trash_copy,
                                  color: Colors.blue,
                                ),
                                onPressed: () => deleteBanner(
                                  banner['id'],
                                  banner['url'],
                                  index,
                                ),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    ],
  );
}



  // Create Banner UI
  Widget _buildCreateBannerUI() {
  final isEditing = editingBanner != null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        isEditing ? 'Edit Banner' : 'Create Banner',
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: isEditing
            ? null // Disable tap if in editing mode; use the "Change Image" button
            : selectImage,
        child: FractionallySizedBox(
          widthFactor: 0.4, // 80% of the parent's width
          child: Card(
            elevation: 4, // Adds shadow to the card
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              height: 160, // Set height to 160 pixels
              child: selectedImageBytes != null
                  ? Image.memory(
                      selectedImageBytes!,
                      fit: BoxFit.cover,
                    )
                  : editingBanner != null
                      ? Image.network(
                          editingBanner!['url'],
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Text(
                            'Select Image',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
            ),
          ),
        ),
      ),
              const SizedBox(height: 10),
              if (isEditing)
                ElevatedButton(
                  onPressed: selectImage, // Allow changing the image
                  child: const Text('Change Image'),
                ),
              const SizedBox(height: 20),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: isEditing ? saveChanges : uploadImage,
                    child: Text(isEditing ? 'Save Changes' : 'Create Banner'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isCreatingBanner = false;
                        editingBanner = null; // Reset editing state
                        selectedImageBytes = null;
                        uploadedImageUrl = null;
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          );
        }

}
