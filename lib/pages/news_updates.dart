import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class NewsUpdates extends StatefulWidget {
  const NewsUpdates({super.key});

  @override
  State<NewsUpdates> createState() => _NewsUpdatesState();
}

class _NewsUpdatesState extends State<NewsUpdates> {
  bool showCreateNewsUI = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> newsList = [];
  String? editingNewsId;
  List<bool> isExpandedList = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  // Fetch news from Firestore
  Future<void> _fetchNews() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('News').get();
      final List<Map<String, dynamic>> fetchedNews = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Store the document ID
          'title': doc['title'],
          'description': doc['description'],
          'status': doc['status'],
        };
      }).toList();

      setState(() {
        newsList = fetchedNews;
        isExpandedList = List<bool>.filled(newsList.length, false); 
      });
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  // Save news to Firestore
  Future<void> _saveNews() async {
    final String title = _titleController.text.trim();
    final String description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
            Text('Both fields are required'),
          ],
        )),
      );
      return;
    }

    try {
      await _firestore.collection('News').add({
        'title': title,
        'description': description,
        'status': 'Active', // Default to 'Active'
        'createdAt': DateTime.now(),
      });

      _titleController.clear();
      _descriptionController.clear();

      setState(() {
        showCreateNewsUI = false;
      });

      _fetchNews();

      ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
            Text('News created successfully'),
          ],
        )),
      );
    } catch (e) {
      print('Error saving news: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
            Text('Failed to create news'),
          ],
        )),
      );
    }
  }

  // Toggle Active/Inactive status
  Future<void> _toggleActiveStatus(String newsId, String currentStatus) async {
    try {
      String newStatus = (currentStatus == 'Active') ? 'Inactive' : 'Active';
      await _firestore.collection('News').doc(newsId).update({
        'status': newStatus,
      });

      setState(() {
        // Update the status in the list to reflect the toggle
        newsList = newsList.map((news) {
          if (news['id'] == newsId) {
            news['status'] = newStatus;
          }
          return news;
        }).toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
            Text('Status updated to $newStatus'),
          ],
        )),
      );
    } catch (e) {
      print('Error updating status: $e');
    }
  }
  void _cancelCreateNews() {
  // Clear the text fields
  _titleController.clear();
  _descriptionController.clear();

  // Hide the Create News UI
  setState(() {
    showCreateNewsUI = false;
  });
}

Future<void> _updateNews() async {
  final String title = _titleController.text.trim();
  final String description = _descriptionController.text.trim();

  if (title.isEmpty || description.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Row(
        children: [
          Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
          Text('Both fields are required'),
        ],
      )),
    );
    return;
  }

  try {
    await _firestore.collection('News').doc(editingNewsId).update({
      'title': title,
      'description': description,
    });

    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      showCreateNewsUI = false;
      editingNewsId = null;
    });

    _fetchNews(); // Refresh the list

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Row(
        children: [
          Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
          Text('News updated successfully'),
        ],
      )),
    );
  } catch (e) {
    print('Error updating news: $e');
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Row(
        children: [
          Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
          Text('Failed to update news'),
        ],
      )),
    );
  }
}

Future<void> _deleteNews(String newsId) async {
  try {
    // Delete the document from Firestore
    await _firestore.collection('News').doc(newsId).delete();

    setState(() {
      // Remove the deleted news from the local list
      newsList.removeWhere((news) => news['id'] == newsId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
   SnackBar(content: Row(
        children: [
          Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
          Text('News deleted successfully'),
        ],
      )),
    );
  } catch (e) {
    print('Error deleting news: $e');
    ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Row(
        children: [
          Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
          Text('Failed to delete news'),
        ],
      )),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              showCreateNewsUI ? 'Create News' : 'News and Updates',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 10),
            showCreateNewsUI ? buildCreateNewsUI() : buildMainUI(),
          ],
        ),
      ),
    );
  }

  // Main UI (News and Updates)
  Widget buildMainUI() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                showCreateNewsUI = true;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text("Create News"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Expanded(
                flex: 2,
                child: Text(
                  'News',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Action',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const Divider(thickness: 1, color: Colors.black26),
          const SizedBox(height: 10),
          Expanded(
            child: newsList.isEmpty
                ? const Center(
                    child: Text(
                      'No Announcement',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: newsList.length,
                    itemBuilder: (context, index) {
                      final news = newsList[index];
                      final isExpanded = isExpandedList[index]; 
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          news['title'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        news['description'],
                                        maxLines: isExpanded ? null : 3, // Show full text if expanded
                                        overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Icon(
                                            isExpanded
                                                ? Icons.keyboard_arrow_up
                                                : Icons.keyboard_arrow_down,
                                            color: Colors.amber,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isExpandedList[index] = !isExpanded; // Toggle expanded state
                                              });
                                            },
                                            child: Text(
                                              isExpanded ? 'See Less' : 'See More',
                                              style: const TextStyle(
                                                color: Colors.amber,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 1,
                              child: MouseRegion(
                                onEnter: (_) => setState(() {}),
                                onExit: (_) => setState(() {}),
                                child: IconButton(
                                  onPressed: () {
                                    _toggleActiveStatus(
                                      news['id'],
                                      news['status'],
                                    );
                                  },
                                  icon: Icon(
                                    news['status'] == 'Active'
                                        ? Iconsax.eye_copy
                                        : Iconsax.eye_slash_copy,
                                    color: news['status'] == 'Active'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  tooltip: news['status'] == 'Active'
                                      ? 'Deactivate'
                                      : 'Activate',
                                  splashColor: Colors.transparent, // No splash effect
                                  highlightColor: Colors.transparent, // No highlight effect
                                  hoverColor: Colors.transparent, // No hover effect color change
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                  onPressed: () {
                                    setState(() {
                                      // Populate the text fields with the selected news details
                                      _titleController.text = news['title'];
                                      _descriptionController.text = news['description'];
                                      showCreateNewsUI = true;
                                      editingNewsId = news['id']; // Set the ID of the news being edited
                                    });
                                  },
                                  icon: const Icon(
                                    Iconsax.edit_copy,
                                    color: Colors.blue,
                                  ),
                                  tooltip: "Edit",
                                ),
                                  const SizedBox(width: 4), // Reduced spacing
                                  IconButton(
                                  onPressed: () async {
                                    final bool? confirm = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Delete'),
                                          content: const Text('Are you sure you want to delete this news?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Delete'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm == true) {
                                      _deleteNews(news['id']);
                                    }
                                  },
                                  icon: const Icon(
                                    Iconsax.trash_copy,
                                    color: Colors.red,
                                  ),
                                  tooltip: "Delete",
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
      ),
    );
  }

  // Create News UI
  Widget buildCreateNewsUI() {
  return Column(
    children: [
      // Card for Create News
      Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 500,
          height: 350,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
      const SizedBox(height: 10),
      // Save and Cancel Buttons at the bottom of the card
      Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: _cancelCreateNews,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
          onPressed: () {
            if (editingNewsId == null) {
              // Call save function if creating new news
              _saveNews();
            } else {
              // Call update function if editing existing news
              _updateNews();
            }
          },
          child: Text(editingNewsId == null ? 'Save' : 'Update'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.purpleAccent,
          ),
        ),

        ],
      ),
    ],
  );
}

}
