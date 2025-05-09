import 'package:flutter/material.dart';

class Faqs extends StatefulWidget {
  const Faqs({super.key});

  @override
  State<Faqs> createState() => _FaqsState();
}

class _FaqsState extends State<Faqs> {
  final List<Map<String, String>> faqs = [
    {
      'question': 'What is the purpose of the LaptopHarbor app?',
      'answer':
          'LaptopHarbor is designed to streamline the laptop shopping experience by offering a wide range of models, specs, and prices in a user-friendly interface.'
    },
    {
      'question': 'Do I need to create an account to use the app?',
      'answer':
          'Yes, you need to create an account to access features such as order tracking, wish lists, and product reviews.'
    },
    {
      'question': 'Can I compare different laptop models?',
      'answer':
          'Yes, the app allows you to compare laptop models by specifications, brands, and prices.'
    },
    {
      'question': 'How secure is my personal information?',
      'answer':
          'The app uses secure login mechanisms and encryption to ensure your data is safe.'
    },
    {
      'question': 'Is there a way to track my orders?',
      'answer':
          'Yes, real-time order tracking and notifications are available through the app.'
    },
    {
      'question': 'What if I need help with my order or the app?',
      'answer':
          'You can contact our customer support via the in-app feedback or contact form.'
    },
    {
      'question': 'Can I leave a review for a product?',
      'answer':
          'Yes, after purchasing a product, you can rate and review it on its product page.'
    },
    {
      'question': 'What platforms is the app available on?',
      'answer':
          'LaptopHarbor is available on Android and will be launched on iOS in the near future.'
    },
    {
      'question': 'Can I use the app without an internet connection?',
      'answer':
          'Some features may be limited offline. For full functionality, an active internet connection is required.'
    },
    {
      'question': 'How do I update my profile or change my password?',
      'answer':
          'Go to the user profile section where you can update your information and change your password securely.'
    },
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredFaqs = faqs.where((faq) {
      final query = searchQuery.toLowerCase();
      return faq['question']!.toLowerCase().contains(query) ||
          faq['answer']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
        backgroundColor: const Color(0xff037EEE),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search FAQs...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredFaqs.isEmpty
                ? const Center(child: Text('No FAQs match your search.'))
                : ListView.builder(
                    itemCount: filteredFaqs.length,
                    itemBuilder: (context, index) {
                      final faq = filteredFaqs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              faq['question']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(faq['answer']!),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
