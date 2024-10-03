import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> foodItems;
  late Function onQuantityChanged;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    foodItems = List<Map<String, dynamic>>.from(args['foodItems']);
    onQuantityChanged = args['onQuantityChanged'] as Function;
  }

  // Method to calculate total cost of items in the cart
  double _calculateTotalCost() {
    return foodItems.fold(
        0, (total, item) => total + (item['price'] * item['quantity']));
  }

  void _increaseQuantity(int index) {
    setState(() {
      foodItems[index]['quantity']++;
    });
    onQuantityChanged(); // Notifies parent to rebuild
  }

  void _decreaseQuantity(int index) {
    setState(() {
      if (foodItems[index]['quantity'] > 0) {
        foodItems[index]['quantity']--;
      }
    });
    onQuantityChanged(); // Notifies parent to rebuild
  }

  @override
  Widget build(BuildContext context) {
    double totalCost = _calculateTotalCost(); // Calculate total cost

    // Check if the cart is empty (all quantities are zero)
    bool isCartEmpty = foodItems.every((item) => item['quantity'] == 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: isCartEmpty
          ? Center(
              child: Text(
                'Your cart is empty, please add some food items to checkout.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                if (foodItems[index]['quantity'] > 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: ListTile(
                        title: Text(foodItems[index]['name']),
                        subtitle: Text('Price: ₹${foodItems[index]['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () => _decreaseQuantity(index),
                            ),
                            Text('${foodItems[index]['quantity']}'),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () => _increaseQuantity(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  return SizedBox.shrink(); // Skip items with quantity 0
                }
              },
            ),
      bottomNavigationBar: isCartEmpty
          ? null
          : BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ₹$totalCost',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Handle checkout logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Checkout button pressed!')),
                        );
                      },
                      child: Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
