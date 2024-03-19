import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab9_642021157/models/producttype.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddProductModal extends StatefulWidget {
  const AddProductModal({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddProductModalState createState() => _AddProductModalState();
}

class _AddProductModalState extends State<AddProductModal> {
  String? userToken;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<ListProductType> dropdownItems = ListProductType.getListProductType();
  late List<DropdownMenuItem<ListProductType>> dropdownMenuItems;
  int? selectedProductType;

  @override
  void initState() {
    super.initState();
    getUserToken();
  }

  Future<void> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('userToken');
    });
  }

  @override
  void dispose() {
    productNameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> addProductToApi() async {
    final productname = productNameController.text;
    final producttype = selectedProductType;
    double? price = double.tryParse(priceController.text);

    http.Response? response;

    try {
      response = await http.post(
        Uri.parse('https://642021157.pungpingcoding.online/api/products'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $userToken',
        },
        body: jsonEncode({
          "product_name": productname,
          "product_type": producttype,
          "price": price,
        }),
      );

      if (response.statusCode == 200) {
        print("เพิ่มข้อมูลสินค้าสำเร็จ");
      } else {
        final responseData = json.decode(response.body);
        print(response.statusCode);
        print(responseData['message'] ??
            'ไม่สามารถเพิ่มข้อมูลสินค้าได้ กรุณาลองใหม่');
      }
    } catch (e) {
      print('Error during add product: $e');
    } finally {
      // Cleanup code, if necessary
      if (response != null) {
        print('HTTP status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: GestureDetector(
        onTap: () {
          // Do nothing when tapped outside the modal
        },
        child: AlertDialog(
          title: const Text('เพิ่มข้อมูลสินค้า'),
          content: Form(
            key: _formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: [
                  TextFormField(
                    controller: productNameController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อสินค้า',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อสินค้า';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ราคา',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกราคา';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    value: selectedProductType,
                    items:
                        ListProductType.getListProductType().map((productType) {
                      return DropdownMenuItem<int>(
                        value: productType.value,
                        child: Text(productType.name!),
                      );
                    }).toList(),
                    onChanged: (int? value) {
                      setState(() {
                        selectedProductType = value;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'ประเภทสินค้า',
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'กรุณาเลือกประเภทสินค้า';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 196, 63, 63)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'ยกเลิก',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    const Color.fromARGB(255, 77, 196, 81)),
              ),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  // Call the API to add the product
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.success,
                    text: 'เพิ่มข้อมูลสำเร็จ!',
                    confirmBtnText: 'ตกลง',
                    showConfirmBtn: false,
                    autoCloseDuration: const Duration(seconds: 3),
                  ).then((value) async {
                    // Close the modal
                    Navigator.of(context).pop();
                    await addProductToApi();
                  });
                } else {
                  QuickAlert.show(
                    context: context,
                    type: QuickAlertType.error,
                    text: 'ไม่สามารถเพิ่มข้อมูลได้ กรุณาลองใหม่!',
                    confirmBtnText: 'ตกลง',
                    showConfirmBtn: true,
                  );
                }
              },
              child: const Text(
                'บันทึก',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
