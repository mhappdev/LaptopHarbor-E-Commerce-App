import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_product_screen.dart';
import 'product_list_screen.dart';

class AnimatedSidebarLayout extends StatefulWidget {
  final Widget body;
  const AnimatedSidebarLayout({super.key, required this.body});

  @override
  State<AnimatedSidebarLayout> createState() => _AnimatedSidebarLayoutState();
}

class _AnimatedSidebarLayoutState extends State<AnimatedSidebarLayout> {


  bool isSidebarOpen = false;
  final Duration _duration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: Stack(
        children: [
          // Sidebar
          AnimatedPositioned(
            duration: _duration,
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -250,
            child: SizedBox(
              width: 250,
              child: Drawer(
                child: Column(
                  children: [
                    const DrawerHeader(
                      decoration: BoxDecoration(color: Colors.indigo),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          'Admin Panel',
                          style: TextStyle(color: Colors.white, fontSize: 24),
                        ),
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.list),
                      title: const Text('Product List'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnimatedSidebarLayout(
                                body: ProductListScreen()),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: const Text('Add Product'),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnimatedSidebarLayout(
                                body: AddProductScreen()),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: () {
                        // signOutUser(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Body + AppBar
          AnimatedContainer(
            duration: _duration,
            transform: Matrix4.translationValues(
                isSidebarOpen && isMobile ? 200 : 0, 0, 0),
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.indigo,
                title: const Text("LaptopHarbour Admin"),
                leading: IconButton(
                  icon: AnimatedIcon(
                    icon: AnimatedIcons.menu_close,
                    progress: AlwaysStoppedAnimation(isSidebarOpen ? 1.0 : 0.0),
                  ),
                  onPressed: () {
                    setState(() {
                      isSidebarOpen = !isSidebarOpen;
                    });
                  },
                ),
              ),
              body: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}
