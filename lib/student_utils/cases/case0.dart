import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:pbma_portal/pages/views/chatbot/chatbot.dart';

class Case0 extends StatefulWidget {
  const Case0({super.key});

  @override
  State<Case0> createState() => _Case0State();
}

class _Case0State extends State<Case0> {
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentIndex = 0;
  List<String> _images = [];
  List<Map<String, dynamic>> _newsList = [];
  bool _isLoading = true;
  bool _isAutoPlay = true;
  List<bool> _isExpanded = [];

  @override
  void initState() {
    super.initState();
    _fetchBanners();
    _fetchNews();
  }

  Future<void> _fetchBanners() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('banners')
          .where('active', isEqualTo: true)
          .get();

      setState(() {
        _images = querySnapshot.docs
            .map((doc) => doc.data()['url'] as String)
            .toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load banners: $e')),
      );
    }
  }

  Future<void> _fetchNews() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('News')
          .where('status', isEqualTo: 'Active')
          .get();

      setState(() {
        _newsList = querySnapshot.docs.map((doc) {
          return {
            'title': doc['title'],
            'description': doc['description'],
          };
        }).toList();
        _isExpanded = List<bool>.filled(_newsList.length, false);
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load news: $e')),
      );
    }
  }

  int _getCrossAxisCount(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 1200) return 4; // 4 columns for large screens
  if (screenWidth > 800) return 3; // 3 columns for tablets
  return 1; // Full-width cards on cellphones
}
  double _getChildAspectRatio(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;
  if (screenWidth > 1200) return 1.5; // Taller cards for larger screens
  if (screenWidth > 800) return 1; // Medium ratio for tablets
  return 0.8; // Compact ratio for cellphones
}

// Fetch FAQs from Firestore
  Future<List<Map<String, String>>> _fetchFAQs() async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('FAQs')
        .get();

    // Explicitly cast values to String
    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'question': data['question']?.toString() ?? '',
        'answer': data['answer']?.toString() ?? '',
      };
    }).toList();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch FAQs: $e')),
    );
    return [];
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 1, 93, 168),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Carousel Slider Section
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      CarouselSlider.builder(
                        itemCount: _images.length,
                        itemBuilder: (context, index, realIndex) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors.grey.shade300, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(_images[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                        carouselController: _carouselController,
                        options: CarouselOptions(
                          height: 200.0,
                          enlargeCenterPage: true,
                          autoPlay: _isAutoPlay,
                          autoPlayInterval: const Duration(seconds: 2),
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentIndex = index;
                              if (index == _images.length - 1) {
                                _isAutoPlay = false;
                              }
                            });
                          },
                        ),
                      ),
                      // Dots Indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _images.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () =>
                                _carouselController.animateToPage(entry.key),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(
                                        _currentIndex == entry.key ? 0.9 : 0.4),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // News and Updates Section
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          "News and Updates",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'T',
                          ),
                        ),
                        const SizedBox(height: 20),
                        // News Cards
                        GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: _getCrossAxisCount(context),
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 16,
                            childAspectRatio: _getChildAspectRatio(context),
                          ),
                          itemCount: _newsList.length,
                          itemBuilder: (context, index) {
                            final news = _newsList[index];
                            final isExpanded = _isExpanded[index];

                            return Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title section
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 1, 93, 168),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        news['title'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.white,
                                          fontFamily: 'R'
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Description section
                                    Expanded(
                                    child: _isExpanded[index]
                                        ? SingleChildScrollView(
                                            child: Text(
                                              news['description'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                          )
                                        : Text(
                                              news['description'],
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                              ),
                                            ),
                                  ),
                                  const SizedBox(height: 8),
                                  // See More / See Less Button
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _isExpanded[index] = !_isExpanded[index];
                                      });
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _isExpanded[index] ? "See Less" : "See More",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.yellow.shade700,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          _isExpanded[index]
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: Colors.yellow,
                                        ),
                                      ],
                                    ),
                                  ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    
                  ),

                ],
                
              ),
              
            ),
            floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                final double screenWidth = MediaQuery.of(context).size.width;
                double heightFactor;
                double widthFactor;

                if (screenWidth >= 1024) {
                  // Web/Desktop
                  heightFactor = 0.75;
                  widthFactor = 0.3;
                } else if (screenWidth >= 600) {
                  // Tablet
                  heightFactor = 0.7;
                  widthFactor = 0.5;
                } else {
                  // Mobile
                  heightFactor = 0.6;
                  widthFactor = 0.9;
                }

                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: MediaQuery.of(context).size.width * widthFactor,
                    height: MediaQuery.of(context).size.height * heightFactor,
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ChatBotUI(),
                  ),
                );
              },
            );
          },
          backgroundColor: Colors.blue,
          child: const Icon(Iconsax.message_copy, color: Colors.white,),
          tooltip: 'FAQs',
        ),

    );
    
  }
}
