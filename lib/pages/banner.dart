import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore package

class BannerImage extends StatefulWidget {
  const BannerImage({super.key});

  @override
  State<BannerImage> createState() => _BannerImage();
}

class _BannerImage extends State<BannerImage> {
  Map<String, dynamic>? editingBanner; // Tracks the current banner being edited
  Set<String> selectedBanners = {};
  bool isCreatingBanner = false;
  Uint8List? selectedImageBytes;
  String? uploadedImageUrl;
  List<Map<String, dynamic>> banners = [];

  @override
  void initState() {
    super.initState();
    _loadBannersFromFirestore(); // Load banners when the widget initializes
  }

  // Load banners from Firestore
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

  // Save banner to Firestore
  Future<void> _saveBannerToFirestore(String url, bool active) async {
  try {
    // Add the banner to Firestore and get the generated document reference
    final docRef = await FirebaseFirestore.instance.collection('banners').add({
      'url': url,
      'active': active,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Retrieve the document ID and add it to the local list
    setState(() {
      banners.add({
        'id': docRef.id, // Add the Firestore document ID
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


  // Select an image
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

  // Upload image to Firebase and save the banner to Firestore
 Future<void> uploadImage() async {
  if (selectedImageBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No image selected to upload')),
    );
    return;
  }

  try {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('banner/${DateTime.now().millisecondsSinceEpoch}.jpg');
    await storageRef.putData(selectedImageBytes!);
    final downloadUrl = await storageRef.getDownloadURL();

    // Save banner to Firestore using the updated method
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

    // If a new image was selected, upload it
    if (selectedImageBytes != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('banner/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putData(selectedImageBytes!);
      newImageUrl = await storageRef.getDownloadURL();
    }

    // Update the banner in Firebase
    await FirebaseFirestore.instance
        .collection('banners')
        .doc(editingBanner!['id'])
        .update({
      'url': newImageUrl,
      'active': editingBanner!['active'], // Preserve active status
    });

    // Update the local list
    setState(() {
      final index = banners.indexWhere((banner) => banner['id'] == editingBanner!['id']);
      if (index != -1) {
        banners[index]['url'] = newImageUrl;
      }
      isCreatingBanner = false;
      editingBanner = null;
      selectedImageBytes = null;
      uploadedImageUrl = null;
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
                child: Text(
                  'No Banners Available',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
                            child: Image.network(
                              banner['url'],
                              height:160,
                              width: 80,
                              fit: BoxFit.cover, // Fills the card while keeping aspect ratio
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
                                onPressed: () async {
                                  final storageRef = FirebaseStorage.instance
                                      .refFromURL(banner['url']); // Reference to the Firebase Storage file

                                  try {
                                    // Delete the image from Firebase Storage
                                    await storageRef.delete();

                                    // Delete the banner document from Firestore
                                    await FirebaseFirestore.instance
                                        .collection('banners')
                                        .doc(banner['id'])
                                        .delete();

                                    setState(() {
                                      banners.removeAt(index); // Remove the banner locally
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Banner deleted successfully!')),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to delete banner: $e')),
                                    );
                                  }
                                },
                                icon: const Icon(
                                  Iconsax.trash_copy,
                                  color: Colors.red,
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
