import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:mrs_panipuri/model/bill.dart';
import 'package:mrs_panipuri/model/firebasehelper.dart';
import '../model/product.dart';
import 'package:flutter/services.dart';

class BillPage extends StatefulWidget {
  final Bill? bill;
  const BillPage({Key? key, this.bill}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BillPage();
  }
}

class _BillPage extends State<BillPage> {
  //to store the quantity of each product added in the bill
  List<Product> productList = [];
  // to store the textEditingController of each product's quantity
  //List<TextEditingController> quantity = [];
  double cost = 0; // total bill cost
  Bill currentbill = Bill(
      products: [],
      dateTime: DateTime.now().toString(),
      cost: 0,
      paymentMode: '');
  bool toUpdate =
      true; // visibility variable for the showing the updating bill features
  bool billgenerated = false;
  bool enableUpdate = false; // To enable and disable the update option
  String mop = ""; // mode of payment

  List<Product> prodlist = [];
  Product?
      currentProduct; // used to store quantity of the current product being added/updated
  // cant change the value fo prodvalue, cuz it affects the dropdownMenu's list of items

  Product? productValue; // stores the product value for the dropdown menu
  TextEditingController quantity = TextEditingController();

  @override
  void initState() {
    if (widget.bill != null) {
      // initialise all the local bill properties with the bill we have got (only if it is not null)
      currentbill = widget.bill!;
      productList = [...currentbill.products];
      mop = currentbill.paymentMode;
      billgenerated = true;
      enableUpdate = false;
      toUpdate =
          false; // since we already have a bill no need to display the update features
      for (var item in productList) {
        cost = cost + item.price * item.quantity!;
      }
    } else {
      toUpdate =
          true; //since this is to create a new bill , display the update/insert  features.
      billgenerated = false;
      enableUpdate = false;
    }
    getProducts();
    super.initState();
  }

  getProducts() async {
    prodlist =
        await FirebaseHelper.readProductsAsList(FirebaseHelper.readProducts());
    setState(() {});
  }

  Future<List<Product>> getProducts2() async {
    var pl =
        await FirebaseHelper.readProductsAsList(FirebaseHelper.readProducts());
    return pl;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.teal,
        appBar: AppBar(
         backgroundColor: Colors.transparent, 
          title: const Text(
            'Bill Page',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode fsn = FocusScope.of(context);
            if (fsn.hasFocus) {
              fsn.unfocus();
            }
          },
          child: ListView(
            shrinkWrap: true,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                          height: 70,
                          width: 250,
                          child: Padding(
                              padding: const EdgeInsets.all(1),
                              child: DropdownSearch<Product>(
                                popupBackgroundColor: Colors.white,
                                mode: Mode.MENU,
                                itemAsString: (item) => item!.name,
                                enabled: true,
                                items: prodlist,
                                showClearButton: true,
                                showSearchBox: true,
                                onChanged: (value) {
                                  productValue = value;
                                },
                              ))),
                      const SizedBox(
                        width: 30,
                      ),
                      const Text('Q:'),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                          controller: quantity,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 100,
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green)),
                          onPressed: () {
                            if (productValue != null &&
                                quantity.text.isNotEmpty) {
                              int q = int.parse(quantity.text);
                              if (q != 0) {
                                int flag = 0;
                                int index = 0;
                                for (var item in productList) {
                                  //checking if the product is already there in the list
                                  if (item.name == productValue!.name) {
                                    flag = 1;
                                    index = productList.indexOf(item);
                                    break;
                                  }
                                }
                                if (flag == 0) {
                                  // if the item does not exist in the list
                                  if (q > 0) {
                                    setState(() {
                                      currentProduct = productValue;
                                      currentProduct =
                                          currentProduct!.copy(quantity: q);
                                      productList.add(currentProduct!);
                                      cost += productValue!.price * q;
                                      quantity.text = "";
                                      //productValue = null;
                                      enableUpdate = true;
                                    });
                                  } else {
                                    showpopup(context,
                                        'Products cannot be reduced if they are not added !');
                                  }
                                } else {
                                  // if the item is already there in the list
                                  currentProduct = productList[index];
                                  int updatedQuantity =
                                      currentProduct!.quantity! + q;
                                  if (updatedQuantity == 0) {
                                    setState(() {
                                      productList.remove(productList[index]);
                                      quantity.text = "";
                                      //productValue = null;
                                      enableUpdate = true;
                                    });
                                  } else if (updatedQuantity > 0) {
                                    setState(() {
                                      currentProduct = currentProduct!
                                          .copy(quantity: updatedQuantity);
                                      productList[index] = currentProduct!;
                                      cost += currentProduct!.price * q;
                                      quantity.text = "";
                                      //productValue = null;
                                      enableUpdate = true;
                                    });
                                  } else {
                                    showpopup(context,
                                        'There are only ${currentProduct!.quantity}  ${currentProduct!.name}s ! ');
                                  }
                                }
                                SystemChannels.textInput
                                    .invokeMethod('TextInput.hide');
                              } else {
                                showpopup(
                                    context, 'Please Enter a valid Quantity!');
                              }
                            } else {
                              showpopup(context,
                                  'Please Choose a Product and the quantity to be added! ');
                            }
                            if (FocusScope.of(context).hasFocus) {
                              FocusScope.of(context).unfocus();
                            }
                          },
                          child: const Text('+ Add',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      const SizedBox(
                        width: 100,
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.indigo)),
                          onPressed: () {
                            setState(() {
                              //productValue = null;
                              quantity.text = "";
                              if (FocusScope.of(context).hasFocus) {
                                FocusScope.of(context).unfocus();
                              }
                            });
                          },
                          child: const Text('Clear',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                  const SizedBox(
                    height: 50,
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                  child: Visibility(
                visible: productList.isNotEmpty,
                child: const Text(
                  'Bill',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )),
              ListView(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                children: productList
                    .map(
                      (element) => ListTile(
                        title: Text(element.name),
                        subtitle: Text(
                          "Q : ${element.quantity.toString()}\n \u20B9 ${(element.price * element.quantity!).toString()}",
                          style: const TextStyle(
                              color: Colors.white70),
                        ),
                        trailing: IconButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.cyan)),

                            // to delete the button.
                            onPressed: () => setState(() {
                                  cost =
                                      cost - element.price * element.quantity!;
                                  productList.remove(element);
                                  enableUpdate = true;
                                }),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 30,
                            )),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(
                height: 25,
              ),
              Visibility(
                visible: productList.isNotEmpty,
                child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        text: 'Total Cost \t',
                        style:
                            const TextStyle(fontSize: 25, color: Colors.black),
                        children: [
                          TextSpan(
                              text: '\u20B9 ${cost.toString()}',
                              style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))
                        ])),
              ),
              const SizedBox(
                height: 30,
              ),
              Visibility(
                  visible: productList.isNotEmpty,
                  child: Row(
                    children: [
                      const Text(
                        'Payment Mode: ',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(
                        width: 0,
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text(
                            'Cash',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: (mop == 'Cash'
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                          ),
                          onChanged: ((value) => setState(() {
                                mop = value!;
                                enableUpdate = true;
                              })),
                          groupValue: mop,
                          value: 'Cash',
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('UPI',
                              style: TextStyle(
                                  fontWeight: (mop == 'UPI'
                                      ? FontWeight.bold
                                      : FontWeight.normal))),
                          onChanged: ((value) => setState(() {
                                mop = value!;
                                enableUpdate = true;
                              })),
                          groupValue: mop,
                          value: 'UPI',
                        ),
                      ),
                    ],
                  )),
              const SizedBox(
                height: 50,
              ),
              Row(
                children: [
                  Visibility(
                    visible: productList.isNotEmpty && !billgenerated,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green)),
                            onPressed: () {
                              double total = 0;
                              for (var p in productList) {
                                total = total + (p.price * p.quantity!);
                              }
                              if (!billgenerated) {
                                if (mop.isNotEmpty) {
                                  insertBill(productList, total);
                                  setState(() {
                                    billgenerated = true;
                                    toUpdate = !toUpdate;
                                    enableUpdate = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        showsnackbar(
                                            'Bill has been Generated Successfully!'));
                                  });
                                } else {
                                  showpopup(context,
                                      'Please choose a payment option');
                                }
                              }
                            },
                            child: const Text(
                              'Generate Bill',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                      ),
                    ),
                  ),
                  Visibility(
                      visible: enableUpdate && billgenerated,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green)),
                            child: const Text('Update Bill',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              if (productList.isNotEmpty) {
                                double total = 0;
                                for (var p in productList) {
                                  total = total + (p.price * p.quantity!);
                                }
                                FirebaseHelper.updateBill(
                                    currentbill.id!,
                                    productList,
                                    total,
                                    DateTime.now().toString(),
                                    mop);
                                setState(() {
                                  billgenerated = true;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      showsnackbar(
                                          'Bill has been Updated Successfully!'));
                                  enableUpdate = false;
                                });
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          content: const Text(
                                              'The bill has no products in it. Updating it would delete the bill. Do you want to continue?'),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(ctx);
                                                },
                                                child: const Text('No')),
                                            ElevatedButton(
                                                onPressed: () {
                                                  FirebaseHelper.deleteBill(
                                                      currentbill.id!);
                                                  productList.clear();
                                                  billgenerated = false;
                                                  toUpdate = true;
                                                  Navigator.pop(ctx);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(showsnackbar(
                                                          'Bill has been Deleted Successfully!'));
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Yes'))
                                          ],
                                        ));
                              }
                            }),
                      )),
                  Visibility(
                      visible: billgenerated && productList.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red)),
                            child: const Text('Delete Bill',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                        content: const Text(
                                            'Do you want to delete the selected Bill?'),
                                        actions: [
                                          ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(ctx);
                                              },
                                              child: const Text('No')),
                                          ElevatedButton(
                                              onPressed: () {
                                                FirebaseHelper.deleteBill(
                                                    currentbill.id!);
                                                productList.clear();
                                                billgenerated = false;
                                                toUpdate = true;
                                                Navigator.pop(ctx);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(showsnackbar(
                                                        'Bill has been Deleted Successfully!'));
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Yes'))
                                        ],
                                      ));
                            }),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  insertBill(List<Product> pList, double total) async {
    String id = await FirebaseHelper.insertBill(
        pList, total, DateTime.now().toString(), mop);
    currentbill = currentbill.copy(id: id);
  }

  showsnackbar(String txt) {
    return SnackBar(
      content: Text(txt),
      duration: const Duration(seconds: 1),
    );
  }

  showpopup(BuildContext ctx, String txt) async {
    showDialog(
        context: ctx,
        builder: (ctx) => AlertDialog(
              content: Text(txt),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                    },
                    child: const Text('ok'))
              ],
            ));
  }

  // Widget getsearchabledropdown() {
  //   return SearchableDropdown(
  //       items: prodlist
  //           .map((e) => DropdownMenuItem(
  //                   child: ListTile(
  //                 title: Text(e.name),
  //               )))
  //           .toList(),
  //       onChanged: () {});
  // }
}
// DropdownButtonHideUnderline(
//                                 child: DropdownButton<Product>(
//                                   value: productValue,
//                                   items: prodlist
//                                       .map((prod) => DropdownMenuItem<Product>(
//                                           value: prod,
//                                           child: RichText(
//                                             text: TextSpan(
//                                                 text: prod.name[0],
//                                                 style: const TextStyle(color: Colors.black,
//                                                     fontWeight:
//                                                         FontWeight.bold),
//                                                 children: [
//                                                   TextSpan(
//                                                       text: prod.name
//                                                           .substring(1),
//                                                       style: const TextStyle(color: Colors.black,
//                                                           fontWeight: FontWeight
//                                                               .normal))
//                                                 ]),
//                                           )))
//                                       .toList(),
//                                   onChanged: ((value) => setState(() {
//                                         productValue = value;
//                                       })),
//                                 ),
//                               ),
