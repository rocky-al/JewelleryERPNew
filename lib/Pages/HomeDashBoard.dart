import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import '../Constants/Functions.dart';
import '../Constants/StaticConstant.dart';

class HomeDashBoard extends StatefulWidget {
  String keyName = "";
  String data = "";

  HomeDashBoard({required this.keyName, required this.data});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeDashBoard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String imageUrl = "";

  Constans constans = Constans();

  bool loaderStatus = false;
  bool showBox = false;
  List<dynamic> productList = [];

  final List<String> _items = [
    "SKU",
    "OrderDate [A-Z]",
    "OrderDate [Z-A]",
    "Del.Date [A-Z]",
    "Del.Date [Z-A]"
  ];

  @override
  void initState() {
    super.initState();

    homeApi("SKU");
  }

  Future<void> homeApi(String sortby) async {
    String? userData = await Constans().getData(StaticConstant.userData);

    Map<String, dynamic> userDataMap = jsonDecode(userData!);
    imageUrl =
        "https://digicat.in/webroot/uploads/erp/${userDataMap['companyid']}/";
    var formData = {
      'companyid': userDataMap['companyid'],
      'username': userDataMap['username'],
      'sortby': sortby,
      widget.keyName: widget.data
    };

    String response =
        await constans.callApi(formData, StaticUrl.productListUrl);
    print("responseData $formData $response");

    Map<String, dynamic> responseData = json.decode(response);

    setState(() {
      productList = responseData['response'];
      // print("productList - productList ${productList.length}");
    });
  }

  String getDate(String dateStr) {
    try {
      final DateTime date =
          DateTime.parse(dateStr); // Parse the input date string
      final DateFormat formatter =
          DateFormat('dd-MMM-yyyy'); // Define the output format
      return formatter.format(date); // Format the date
    } catch (e) {
      return 'Invalid Date'; // Handle invalid date inputs
    }
  }

  int calculateDaysDifference(String deliveryDateStr) {
    // Parse the delivery date string into a DateTime object
    final DateTime deliveryDate = DateTime.parse(deliveryDateStr);

    // Get the current date
    final DateTime currentDate = DateTime.now();

    // Calculate the difference in days
    return deliveryDate.difference(currentDate).inDays;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // backgroundColor: Colors.white,
        // Replace with your color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: null,
        // Set to null to center the image
        backgroundColor: const Color(0xFF4C5564),
        flexibleSpace: Container(
          margin: const EdgeInsets.only(top: 35),
          child: Center(
            child: Image.asset(
              'assets/login_logo.jpeg', // Replace with your image path
              height: 30, // Adjust the height as needed
            ),
          ),
        ),
          // actions: [
          //
          //   IconButton(
          //     icon: const Icon(Icons.search, color: Colors.white),
          //     onPressed: () => Navigator.of(context).pop(),
          //   )
          //   // IconButton(
          //   //   icon: Image.asset(
          //   //       color: StaticColor.themeColor,
          //   //       'assets/search.png', // Replace with your image path
          //   //       height: 20, // Adjust the height as needed
          //   //       width: 20),
          //   //   onPressed: () {
          //   //     setState(() {
          //   //       // _isSearchVisible = true;
          //   //     });
          //   //   },
          //   // )
          // ]
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            margin: const EdgeInsets.only(bottom: 15, top: 1),
            color: const Color(0xFF4C5564), // Replace with your color
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // DropdownButton with reduced width
                SizedBox(
                  width: 130,
                  child: Container(
                    decoration: BoxDecoration(
                      color: StaticColor.lightGrey,
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            icon: const SizedBox.shrink(),
                            hint: Row(
                              children: [
                                Image.asset(
                                  'assets/sort.png',
                                  height: 24,
                                  width: 24,
                                  color: StaticColor.themeColor,
                                ),
                                const SizedBox(width: 18),
                                const Text(
                                  "Sort By",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                    color: StaticColor.themeColor,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Image.asset(
                                  'assets/down_1.png',
                                  height: 15,
                                  width: 15,
                                  color: StaticColor.themeColor,
                                ),
                              ],
                            ),
                            items: _items.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontFamily: 'Arial',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                print("newValues --   $newValue");

                                switch (newValue) {
                                  case "SKU":
                                    homeApi("sku");
                                  case "OrderDate [A-Z]":
                                    homeApi("orderDate");
                                  case "OrderDate [Z-A]":
                                    homeApi("OrderDate desc");
                                  case "Del.Date [A-Z]":
                                    homeApi("deldate");
                                  case "Del.Date [Z-A]":
                                    homeApi("deldate desc");
                                }

                                // Handle dropdown value change here
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expanded(
          //   child: GridView.count(
          //     crossAxisCount: 2,
          //     children: List.generate(productList.length, (index) {
          //       final item =
          //           productList[index]; // Accessing the item from the list
          //       // print(object)
          //       return Card(
          //         elevation: 4,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         child: Container(
          //           height: 400,
          //           margin: const EdgeInsets.all(5),
          //           decoration: BoxDecoration(
          //             border: Border.all(color: Colors.black.withOpacity(0.5), width: 1),
          //             borderRadius: BorderRadius.circular(4),
          //           ),
          //           child: Expanded( // Add this to make the column scrollable
          //             child: Column(
          //               children: [
          //                 Padding(
          //                   padding: const EdgeInsets.only(top: 10),
          //                   child: Text(
          //                     item['sku'],
          //                     style: const TextStyle(
          //                       color: Color(0xFFFFC107),
          //                       fontSize: 14,
          //                       fontFamily: 'PoppinsMedium',
          //                     ),
          //                   ),
          //                 ),
          //                 GestureDetector(
          //                   onTap: () => () {},
          //                   child: Image.network(
          //                     '$imageUrl${item['imagename']}',
          //                     fit: BoxFit.fitHeight,
          //                     errorBuilder: (context, error, stackTrace) {
          //                       return Image.asset('assets/placeholder.png',
          //                           fit: BoxFit.fitHeight);
          //                     },
          //                   ),
          //                 ),
          //                 const Divider(
          //                   color: Color(0xFF4C5564),
          //                   thickness: 1,
          //                   height: 5,
          //                 ),
          //                 Row(
          //                   children: [
          //                     Expanded(
          //                       child: Text(
          //                         'Order Date: ${getDate(item['orderdate'])}',
          //                         textAlign: TextAlign.center,
          //                         style: const TextStyle(
          //                           color: Color(0xFF4C5564),
          //                           fontSize: 10,
          //                           fontFamily: 'PoppinsMedium',
          //                         ),
          //                       ),
          //                     ),
          //                     Container(
          //                       width: 1,
          //                       height: 35,
          //                       color: const Color(0xFF4C5564),
          //                     ),
          //                     Expanded(
          //                       child: Text(
          //                         'Delivery Date: ${getDate(item['deldate'])}',
          //                         textAlign: TextAlign.center,
          //                         style: const TextStyle(
          //                           color: Color(0xFF4C5564),
          //                           fontSize: 10,
          //                           fontFamily: 'PoppinsMedium',
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //                 const Divider(
          //                   color: Color(0xFF4C5564),
          //                   thickness: 1,
          //                 ),
          //                 Row(
          //                   children: [
          //                     Expanded(
          //                       child: Text(
          //                         item['process'],
          //                         textAlign: TextAlign.center,
          //                         style: const TextStyle(
          //                           color: Color(0xFF4C5564),
          //                           fontSize: 10,
          //                           fontFamily: 'PoppinsMedium',
          //                         ),
          //                       ),
          //                     ),
          //                     Container(
          //                       width: 1,
          //                       height: 25,
          //                       color: const Color(0xFF4C5564),
          //                     ),
          //                     Expanded(
          //                       child: Text(
          //                         calculateDaysDifference(item['deldate']).toString(),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //                 const Divider(
          //                   color: Color(0xFF4C5564),
          //                   thickness: 1,
          //                 ),
          //                 Row(
          //                   children: [
          //                     Expanded(
          //                       child: Text(
          //                         item['item'] ?? '',
          //                         textAlign: TextAlign.center,
          //                         style: const TextStyle(
          //                           color: Color(0xFF4C5564),
          //                           fontSize: 10,
          //                           fontFamily: 'PoppinsMedium',
          //                         ),
          //                       ),
          //                     ),
          //                     Container(
          //                       width: 1,
          //                       height: 35,
          //                       color: const Color(0xFF4C5564),
          //                     ),
          //                     Expanded(
          //                       child: Text(
          //                         item['metal'],
          //                         textAlign: TextAlign.center,
          //                         style: const TextStyle(
          //                           color: Color(0xFF4C5564),
          //                           fontSize: 10,
          //                           fontFamily: 'PoppinsMedium',
          //                         ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //       );
          //     }),
          //   ),
          // ),
          Expanded(
            child: ResponsiveGridList(
              horizontalGridMargin: 10,
              verticalGridMargin: 10,
              minItemWidth: screenWidth / 3,
              children: List.generate(
                productList.length,
                (index) => Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          productList[index]['sku'],
                          style: const TextStyle(
                            color: Color(0xFFFFC107),
                            fontSize: 14,
                            fontFamily: 'PoppinsMedium',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => () {},
                          child: Image.network(
                            height: 150,
                            '$imageUrl${productList[index]['imagename']}',
                            fit: BoxFit.fitHeight,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/placeholder.png',
                                fit: BoxFit.fitHeight,
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFF4C5564),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Order Date: ${getDate(productList[index]['orderdate'])}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 35,
                            color: const Color(0xFF4C5564),
                          ),
                          Expanded(
                            child: Text(
                              'Delivery Date: ${getDate(productList[index]['deldate'])}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFF4C5564),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              productList[index]['process'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 25,
                            color: const Color(0xFF4C5564),
                          ),
                          Expanded(
                            child: Text(
                              calculateDaysDifference(
                                      productList[index]['deldate'])
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: double.infinity,
                        height: 1,
                        color: const Color(0xFF4C5564),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              productList[index]['item'] ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 35,
                            color: const Color(0xFF4C5564),
                          ),
                          Expanded(
                            child: Text(
                              productList[index]['metal'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF4C5564),
                                fontSize: 10,
                                fontFamily: 'PoppinsMedium',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Data {
  String productId;
  String itemData;

  Data({required this.productId, required this.itemData});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      productId: json['product_id'],
      itemData: json['item_data'],
    );
  }
}