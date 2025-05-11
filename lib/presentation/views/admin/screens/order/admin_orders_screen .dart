import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbor/core/app_colors.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders Management'),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var order = snapshot.data!.docs[index];
              var orderData = order.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${orderData['orderId']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(orderData['status']),
                    ],
                  ),
                  subtitle: Text(
                    '${orderData['customerName']} - ${orderData['orderDate']}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer Info
                          _buildDetailRow(
                              'Customer:', orderData['customerName']),
                          _buildDetailRow('Email:', orderData['customerEmail']),
                          _buildDetailRow('Phone:', orderData['customerPhone']),
                          _buildDetailRow(
                              'Address:', orderData['deliveryAddress']),
                          const SizedBox(height: 16),

                          // Order Items
                          const Text('Items:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          ...orderData['items']
                              .map<Widget>((item) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            item['image'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              width: 50,
                                              height: 50,
                                              color: Colors.grey[200],
                                              child: const Icon(
                                                  Icons.image_not_supported),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(item['name'],
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500)),
                                              Text(
                                                  'Qty: ${item['quantity']} × \$${item['price'].toStringAsFixed(2)}'),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                          const SizedBox(height: 16),

                          // Order Summary
                          const Divider(),
                          _buildDetailRow('Subtotal:',
                              '\$${orderData['subtotal'].toStringAsFixed(2)}'),
                          _buildDetailRow('Shipping:',
                              '\$${orderData['shippingCost'].toStringAsFixed(2)}'),
                          _buildDetailRow('Tax:',
                              '\$${orderData['tax'].toStringAsFixed(2)}'),
                          _buildDetailRow(
                            'Total:',
                            '\$${orderData['total'].toStringAsFixed(2)}',
                            isBold: true,
                            valueColor: AppColors.blue,
                          ),
                          const SizedBox(height: 16),

                          // Status Update
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Update Status:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              _buildStatusDropdown(
                                  order.id, orderData['status']),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    switch (status.toLowerCase()) {
      case 'processing':
        chipColor = Colors.orange;
      case 'shipped':
        chipColor = Colors.blue;
      case 'delivered':
        chipColor = Colors.green;
      case 'cancelled':
        chipColor = Colors.red;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: chipColor,
    );
  }

  Widget _buildStatusDropdown(String orderId, String currentStatus) {
    final statuses = ['Processing', 'Shipped', 'Delivered', 'Cancelled'];

    return DropdownButton<String>(
      value: currentStatus,
      icon: const Icon(Icons.arrow_drop_down),
      style: const TextStyle(color: Colors.black),
      underline: Container(height: 1, color: Colors.grey),
      onChanged: (String? newValue) {
        if (newValue != null) {
          FirebaseFirestore.instance
              .collection('orders')
              .doc(orderId)
              .update({'status': newValue.toLowerCase()});
        }
      },
      items: statuses.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value.toLowerCase(),
          child: Text(value),
        );
      }).toList(),
    );
  }
}
