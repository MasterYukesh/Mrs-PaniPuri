import 'package:flutter/material.dart';
import 'package:mrs_panipuri/model/firebasehelper.dart';
import 'package:mrs_panipuri/model/product.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ProductsPage();
  }
}

class _ProductsPage extends State<ProductsPage> {
  TextEditingController productname = TextEditingController();
  TextEditingController productcost = TextEditingController();
  ScrollController plcontroller = ScrollController();
  bool addproduct = false;
  bool delButton = false;
  String addUpdate = '';
  String id = "";
  Stream productlist = const Stream.empty();
  @override
  void initState() {
    // initproducts();
    super.initState();
  }

  // void initproducts() async {
  //   productlist = await FirebaseHelper.read();
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white30,
          appBar: AppBar(
            backgroundColor: Colors.white30,
            title: const Text(
              'Menu',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            
          ),
          body: ListView(controller: plcontroller, children: [
            Visibility(
                visible: addproduct,
                child: Center(
                    child: Column(children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: productname,
                        style:const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.fastfood_rounded),
                            hintText: 'Product name',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))))),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(125.0, 8.0, 130, 8.0),
                    child: TextField(
                      style:const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.currency_rupee_sharp),
                          hintText: 'cost',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      controller: productcost,
                    ),
                  ),
                  Row(children: [
                    const SizedBox(
                      width: 100,
                    ),
                    ElevatedButton(
                        onPressed: () => setState(() {
                              if (productcost.text.isNotEmpty &&
                                  productname.text.isNotEmpty) {
                                if (addUpdate == 'Add') {
                                  FirebaseHelper.insertProduct(Product(
                                      id: null,
                                      name: productname.text,
                                      price: double.parse(productcost.text)));
                                } else if (addUpdate == 'Update') {
                                  FirebaseHelper.updateProduct(
                                      id,
                                      productname.text,
                                      double.parse(productcost.text));
                                }
                              }
                              productname.text = "";
                              productcost.text = '';
                              addproduct = !addproduct;
                              id = "";
                            }),
                        child: Text(addUpdate)),
                    const SizedBox(
                      width: 50,
                    ),
                    ElevatedButton(
                        onPressed: () => setState(() {
                              addproduct = !addproduct;
                              productname.text = "";
                              productcost.text = '';
                              id = "";
                            }),
                        child: const Text('Cancel')),
                  ]),
                  Row(children: [
                    const SizedBox(
                      width: 180,
                    ),
                    Visibility(
                        visible: delButton,
                        child: IconButton(
                            onPressed: () => setState(() {
                                  showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                            content: const Text(
                                                'Are you sure you want to delete the selected product?'),
                                            actions: [
                                              ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Cancel')),
                                              ElevatedButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      FirebaseHelper
                                                          .deleteProduct(id);
                                                      Navigator.pop(context);
                                                      delButton = false;
                                                      addproduct = false;
                                                      productname.text = "";
                                                      productcost.text = '';
                                                      id = "";
                                                    });
                                                  },
                                                  child: const Text('Yes')),
                                            ],
                                          ));
                                }),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            )))
                  ])
                ]))),
            Row(
              children:  [
                const Text(
                  'S.No',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.pink),
                ),
                const SizedBox(
                  width: 50,
                ),
                const Text('Food',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.pink)),
                const SizedBox(
                  width: 160,
                ),
                Text('Price (\u20B9)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.red.shade700))
              ],
            ),
            StreamBuilder<List<Product>>(
                stream: FirebaseHelper.readProducts(),
                builder: ((context, snapshot) {
                  if (snapshot.hasData) {
                    final products = snapshot.data!;
                    return Column(
                      children: products
                          .map((data) => ListTile(
                                title: Text(
                                  data.name,
                                  style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                                leading: Text(
                                  "${products.indexOf(data) + 1}.",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Text(
                                  data.price.toString(),
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.bold),
                                ),
                                onTap: () {
                                  if (!addproduct) {
                                    setState(() {
                                      addUpdate = 'Update';
                                      addproduct = !addproduct;
                                      productname.text = data.name;
                                      productcost.text = data.price.toString();
                                      delButton = true;
                                      id = data.id!;
                                    });
                                    setState(() {
                                      plcontroller.animateTo(
                                          plcontroller.position.minScrollExtent,
                                          duration:
                                              const Duration(milliseconds: 50),
                                          curve: Curves.ease);
                                    });
                                  } else {
                                    setState(() {
                                      addUpdate = 'Update';
                                      productname.text = data.name;
                                      productcost.text = data.price.toString();
                                      delButton = true;
                                      id = data.id!;
                                    });
                                  }
                                },
                              ))
                          .toList(),
                    );
                  } else {
                    return const Center();
                  }
                })),
          ]),
          floatingActionButton: FloatingActionButton(
              onPressed: () => setState(() {
                    if (!addproduct) {
                      addproduct = !addproduct;
                      delButton = false;
                      addUpdate = 'Add';
                    }
                  }),
              backgroundColor: Colors.green,
              child: const Icon(Icons.add)),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
      
    );
  }
}
