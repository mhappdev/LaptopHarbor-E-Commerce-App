import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/presentation/views/home/home.dart';
import 'package:laptop_harbor/presentation/views/order/orders_history_screen.dart';
import 'package:laptop_harbor/presentation/views/support/chat_page.dart';
import 'package:laptop_harbor/presentation/views/wishlist/wishlist.dart';

class NavigationWrapper extends StatefulWidget {
  const NavigationWrapper({super.key});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;
  bool _showOrderBadge = false;
  StreamSubscription<QuerySnapshot>? _orderStatusSubscription;

  final List<Widget> _pages = [
    Home(),
    Wishlist(),
    OrdersHistoryScreen(),
    ChatPage(),
  ];

  @override
  void initState() {
    super.initState();
    setupOrderBadgeListener();
  }

  void setupOrderBadgeListener() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _orderStatusSubscription = FirebaseFirestore.instance
        .collection('orders')
        .where('uid', isEqualTo: user.uid)
        .where('statusChanged', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _showOrderBadge = snapshot.docs.isNotEmpty;
        });
      }
    });
  }

  Future<void> clearOrderStatusChanged() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('uid', isEqualTo: user.uid)
        .where('statusChanged', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.update({'statusChanged': false});
    }
  }

  void _onTabTapped(int index) async {
    if (index == 2 && _showOrderBadge) {
      await clearOrderStatusChanged();
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void dispose() {
    _orderStatusSubscription?.cancel(); // important!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              spreadRadius: 1,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(16)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.white,
            unselectedItemColor: AppColors.white.withOpacity(0.7),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.normal),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: [
              const BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: 'Home'),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Wish List'),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.inventory),
                    if (_showOrderBadge)
                      Positioned(
                        right: -4,
                        top: -2,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                  icon: Icon(Icons.support_agent), label: 'Support'),
            ],
          ),
        ),
      ),
    );
  }
}
