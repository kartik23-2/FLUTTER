import 'package:flutter/material.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  final List<String> filters = const[
    'All',
    'Sneakers',
    'Boots',
    'Sandals'
  ];

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      // Handle menu button press
                    },
                  ),
                  Spacer(),
                  Text(
                    'Shopping App',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      // Handle shopping cart button press
                    },
                  ),
                ], 
              ),
              Row(
                children: [
                  Text('Shoes\nCollection', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Spacer(),
                  SizedBox(
                    width: 250,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ], 
              ),
              SizedBox(height: 20),
              Text('Explore our products and enjoy shopping!'),
            ],
          ),
        
      ),
      );
  }
}