import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lab9_642021157/pages/addproductpage.dart';
import 'package:lab9_642021157/pages/editproduct.dart';
import 'package:lab9_642021157/pages/login.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Product welcomeFromJson(String str) => Product.fromJson(json.decode(str));

String welcomeToJson(Product data) => json.encode(data.toJson());

class Product {
  String productName;
  int productType;
  int price;
  int id;

  Product({
    required this.productName,
    required this.productType,
    required this.price,
    required this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"],
        productName: json["product_name"],
        productType: json["product_type"],
        price: json["price"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "product_name": productName,
        "product_type": productType,
        "price": price,
      };
}

class Showproduct extends StatefulWidget {
  const Showproduct({super.key});

  @override
  State<Showproduct> createState() => _ShowproductState();
}

class _ShowproductState extends State<Showproduct>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Product> products = [];
  String? userToken;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    getList();
    getUserToken();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('userToken');
    });
  }

  Future<String?> getList() async {
    products = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    var url = Uri.parse('http://642021157.pungpingcoding.online/api/products');

    var response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $userToken',
    });
    if (response.statusCode == 200) {
      var jsonString = jsonDecode(response.body);
      products = jsonString['payload']
          .map<Product>((json) => Product.fromJson(json))
          .toList();
    } else {
      // Handle other status codes
      print('Failed to load products: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Show Products'),
        actions: [
          IconButton(
            onPressed: () async {
              QuickAlert.show(
                onCancelBtnTap: () {
                  Navigator.pop(context);
                },
                context: context,
                type: QuickAlertType.confirm,
                title: 'แน่ใจ??',
                text: 'คุณต้องการที่จะออกจากระบบ??',
                titleAlignment: TextAlign.center,
                textAlignment: TextAlign.center,
                confirmBtnText: 'ตกลง',
                cancelBtnText: 'ยกเลิก',
                confirmBtnColor: const Color.fromARGB(255, 185, 37, 37),
                backgroundColor: Colors.white,
                headerBackgroundColor: Colors.grey,
                confirmBtnTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                ),
                barrierColor: const Color.fromARGB(139, 46, 46, 46),
                titleColor: const Color.fromARGB(255, 1, 1, 1),
                textColor: const Color.fromARGB(255, 1, 1, 1),
                cancelBtnTextStyle: const TextStyle(
                  color: Color.fromARGB(255, 33, 33, 33),
                  fontWeight: FontWeight.bold,
                ),
                onConfirmBtnTap: () async {
                  Navigator.pop(context); // Close the confirmation dialog
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.success,
                    text: 'ออกจากระบบสำเร็จ!',
                    showConfirmBtn: false,
                    autoCloseDuration: const Duration(seconds: 3),
                  ).then((value) async {
                    await logout(context); // Delete the product
                  });
                },
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        children: [
          showButton(),
          showList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddProductModal(),
              )).then((value) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget showButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {});
      },
      child: const Text('แสดงรายการ'),
    );
  }

  Widget showList() {
    return FutureBuilder(
      future: getList(),
      builder: (context, snapshot) {
        List<Widget> myList;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('ข้อผิดพลาด: ${snapshot.error}'),
                ),
              ],
            ),
          );
        } else {
          myList = [
            Column(
              children: products.map((item) {
                return Card(
                  child: ListTile(
                    onTap: () {
                      // Navigate to Edit Product
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProduct(productId: item.id),
                        ),
                      );
                    },
                    title: Text(item.productName),
                    subtitle: Text(item.price.toString() + " บาท"),
                    trailing: IconButton(
                      onPressed: () {
                        QuickAlert.show(
                          onCancelBtnTap: () {
                            Navigator.pop(context);
                          },
                          context: context,
                          type: QuickAlertType.confirm,
                          title: 'ต้องการลบ??',
                          text:
                              'หากดำเนินการลบข้อมูลแล้ว ข้อมูลจะไม่สามารถกู้ได้อีก!!',
                          titleAlignment: TextAlign.center,
                          textAlignment: TextAlign.center,
                          confirmBtnText: 'ตกลง',
                          cancelBtnText: 'ยกเลิก',
                          confirmBtnColor:
                              const Color.fromARGB(255, 185, 37, 37),
                          backgroundColor: Colors.white,
                          headerBackgroundColor: Colors.grey,
                          confirmBtnTextStyle: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.bold,
                          ),
                          barrierColor: const Color.fromARGB(139, 46, 46, 46),
                          titleColor: const Color.fromARGB(255, 1, 1, 1),
                          textColor: const Color.fromARGB(255, 1, 1, 1),
                          cancelBtnTextStyle: const TextStyle(
                            color: Color.fromARGB(255, 33, 33, 33),
                            fontWeight: FontWeight.bold,
                          ),
                          onConfirmBtnTap: () async {
                            Navigator.pop(
                                context); // Close the confirmation dialog
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.success,
                              text: 'ดำเนินการลบข้อมูลสำเร็จ!',
                              showConfirmBtn: false,
                              autoCloseDuration: const Duration(seconds: 3),
                            ).then((value) async {
                              await deleteProduct(
                                  item.id); // Delete the product
                            });
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ];
        }
        return Center(
          child: Column(
            children: myList,
          ),
        );
      },
    );
  }

  Future<void> deleteProduct(int id) async {
    var url =
        Uri.parse('https://642021157.pungpingcoding.online/api/product/$id');

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userToken = prefs.getString('userToken');

      var response = await http.delete(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        // Product deleted successfully, refresh the list
        await getList();
        setState(() {
          // Trigger a rebuild to show the updated list
        });
        print('Product deleted successfully');
      } else {
        // Handle other status codes
        print('Failed to delete product: ${response.statusCode}');
      }
    } catch (error) {
      print('Error deleting product: $error');
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userToken = prefs.getString('userToken');

    var url = Uri.parse('https://642021157.pungpingcoding.online/api/logout');

    try {
      var response = await http.post(
        url,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $userToken',
        },
      );

      if (response.statusCode == 200) {
        // Show confirmation dialog using QuickAlert

        // Remove user-related information from SharedPreferences
        await prefs.remove('userToken');
        await prefs.remove('username');

        // Navigate to the LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );

        print("ออกจากระบบสำเร็จ!");
      } else {
        print("token : $userToken");
        print("Logout failed. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error during logout: $e");
    }
  }
}
