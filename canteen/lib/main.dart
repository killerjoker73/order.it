import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'PhoneAuthScreen.dart';
import 'cart.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CanteenApp());
}

class CanteenApp extends StatelessWidget {
  const CanteenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canteen App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => PhoneAuthScreen(),
        '/menu': (context) => const FoodMenuScreen(),
        '/cart': (context) => CartScreen(),
      },
    );
  }
}

class FoodMenuScreen extends StatefulWidget {
  const FoodMenuScreen({super.key});

  @override
  _FoodMenuScreenState createState() => _FoodMenuScreenState();
}

class _FoodMenuScreenState extends State<FoodMenuScreen> {
  final List<Map<String, dynamic>> foodItems = [
    {
      'name': 'Pizza',
      'description': 'Delicious cheese pizza with a crispy crust.',
      'price': 99,
      'image': 'assets/pizza.jpg',
      'quantity': 0,
    },
    {
      'name': 'Cold Coffee',
      'description': 'Chilled cold coffee topped with whipped cream.',
      'price': 50,
      'image': 'assets/cold_coffee.jpg',
      'quantity': 0,
    },
  ];

  void _addToCart(int index) {
    setState(() {
      foodItems[index]['quantity']++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${foodItems[index]['name']} added to cart!')),
    );
  }

  void _goToCart() {
    Navigator.pushNamed(
      context,
      '/cart',
      arguments: {
        'foodItems': foodItems,
        'onQuantityChanged': () {
          setState(() {});
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _goToCart,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Column(
                children: <Widget>[
                  Image.asset(
                    foodItems[index]['image'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  ListTile(
                    title: Text(foodItems[index]['name']),
                    subtitle: Text(foodItems[index]['description']),
                    trailing: Text('₹${foodItems[index]['price']}'),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => _addToCart(index),
                        child: const Text('Add to Cart'),
                      ),
                      Text('Quantity: ${foodItems[index]['quantity']}'),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
