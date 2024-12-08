import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class FAQAdminPage extends StatefulWidget {
  const FAQAdminPage({Key? key}) : super(key: key);

  @override
  State<FAQAdminPage> createState() => _FAQAdminPageState();
}

class _FAQAdminPageState extends State<FAQAdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool showCreateFAQUI = false;
  List<Map<String, dynamic>> faqList = [];
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();
  String? editingFAQId;

  @override
  void initState() {
    super.initState();
    _fetchFAQs();
  }

  Future<void> _fetchFAQs() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('FAQs').get();
      setState(() {
        faqList = snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'question': doc['question'],
            'answer': doc['answer'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching FAQs: $e');
    }
  }

  Future<void> _saveFAQ() async {
    final String question = _questionController.text.trim();
    final String answer = _answerController.text.trim();

    if (question.isEmpty || answer.isEmpty) {
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
      if (editingFAQId == null) {
        await _firestore.collection('FAQs').add({'question': question, 'answer': answer});
      } else {
        await _firestore.collection('FAQs').doc(editingFAQId).update({'question': question, 'answer': answer});
      }

      _questionController.clear();
      _answerController.clear();
      setState(() {
        showCreateFAQUI = false;
        editingFAQId = null;
      });
      _fetchFAQs();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
            Text(editingFAQId == null ? 'FAQ created successfully' : 'FAQ updated successfully'),
          ],
        )),
      );
    } catch (e) {
      print('Error saving FAQ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Row(
          children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
            Text('Failed to save FAQ: $e'),
          ],
        )),
      );
    }
  }

  Future<void> _deleteFAQ(String faqId) async {
    try {
      await _firestore.collection('FAQs').doc(faqId).delete();
      setState(() {
        faqList.removeWhere((faq) => faq['id'] == faqId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Row(
           children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
             Text('FAQ deleted successfully'),
           ],
         )),
      );
    } catch (e) {
      print('Error deleting FAQ: $e');
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Row(
           children: [
            Image.asset('PBMA.png', scale: 40),
                      SizedBox(width: 10),
             Text('Failed to delete FAQ'),
           ],
         )),
      );
    }
  }

  void _cancelCreateFAQ() {
    _questionController.clear();
    _answerController.clear();
    setState(() {
      showCreateFAQUI = false;
      editingFAQId = null;
    });
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
              showCreateFAQUI ? 'Create FAQ' : 'Manage FAQs',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            const SizedBox(height: 10),
            showCreateFAQUI ? buildCreateFAQUI() : buildMainUI(),
          ],
        ),
      ),
    );
  }

 Widget buildMainUI() {
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              showCreateFAQUI = true;
            });
          },
          icon: const Icon(Icons.add),
          label: const Text("Create FAQ"),
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
                'Moderator',
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
          child: faqList.isEmpty
              ? const Center(
                  child: Text(
                    'No FAQs available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: faqList.length,
                  itemBuilder: (context, index) {
                    final faq = faqList[index];
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
                                    Text(
                                      faq['question'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      faq['answer'],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _questionController.text = faq['question'];
                                      _answerController.text = faq['answer'];
                                      showCreateFAQUI = true;
                                      editingFAQId = faq['id'];
                                    });
                                  },
                                  icon: const Icon(Iconsax.edit_copy, color: Colors.blue),
                                  tooltip: "Edit",
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  onPressed: () {
                                    _deleteFAQ(faq['id']);
                                  },
                                  icon: const Icon(Iconsax.trash_copy, color: Colors.red),
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


  Widget buildCreateFAQUI() {
    return Column(
      children: [
        Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            height: 300,
            width: 750,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(labelText: 'Question'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _answerController,
                  decoration: const InputDecoration(labelText: 'Answer'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: _cancelCreateFAQ, child: const Text('Cancel')),
            ElevatedButton(
              onPressed: _saveFAQ,
              child: Text(editingFAQId == null ? 'Save' : 'Update'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
