import 'package:flutter/material.dart';
import '../model/firebasehelper.dart';
import '../model/user.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AccountPage();
  }
}

class _AccountPage extends State<AccountPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  // this is used to tell whether the user is an admin or not
  bool admin = false;
  ScrollController alcontroller = ScrollController();
  bool adduser =
      false; // to make the entries Visible when you want to add/modify user details.
  bool delButton = false;
  String addUpdate = '';
  bool isPassword = true;
  // used to store the username before updating it, so we can find the data from the firebase inorder to update it.
  String currentusername = "";
  Stream productlist = const Stream.empty();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: const Text(
            'Users',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ),
        body: ListView(shrinkWrap: true, controller: alcontroller, children: [
          Visibility(
              visible: adduser,
              child: Center(
                  child: Column(children: [
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                      controller: username,
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.account_circle),
                          hintText: 'Username',
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))))),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    obscureText: isPassword,
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.password),
                        suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isPassword = !isPassword;
                              });
                            },
                            icon: isPassword
                                ? const Icon(Icons.visibility_off)
                                : const Icon(Icons.visibility)),
                        hintText: 'Password',
                        border: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10)))),
                    controller: password,
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Admin : '),
                    Radio<bool>(
                        value: true,
                        groupValue: admin,
                        onChanged: (value) => setState(() {
                              admin = true;
                            })),
                    const Text('Yes'),
                    Radio<bool>(
                        value: false,
                        groupValue: admin,
                        onChanged: (value) => setState(() {
                              admin = false;
                            })),
                    const Text('No'),
                  ],
                ),
                Row(children: [
                  const SizedBox(
                    width: 100,
                  ),
                  ElevatedButton(
                      onPressed: () => setState(() {
                            if (password.text.isNotEmpty &&
                                username.text.isNotEmpty) {
                              if (addUpdate == 'Add') {
                                FirebaseHelper.insertUser(
                                    username.text, password.text, admin);
                              } else if (addUpdate == 'Update') {
                                FirebaseHelper.updateUser(currentusername,
                                    username.text, password.text, admin);
                              }
                            }
                            username.text = "";
                            password.text = '';
                            // making the adding/updating details invisible
                            adduser = !adduser;
                            currentusername = "";
                            isPassword = true;
                            admin = false;
                          }),
                      child: Text(addUpdate)),
                  const SizedBox(
                    width: 50,
                  ),
                  ElevatedButton(
                      onPressed: () => setState(() {
                            // making the adding/updating details invisible
                            adduser = !adduser;
                            username.text = "";
                            password.text = '';
                            currentusername = "";
                            isPassword = true;
                            admin = false;
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
                                              'Are you sure you want to delete the selected User?'),
                                          actions: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel')),
                                            ElevatedButton(
                                                onPressed: () {
                                                  setState(() {
                                                    FirebaseHelper.deleteUser(
                                                        currentusername);
                                                    Navigator.pop(context);
                                                    delButton = false;
                                                    adduser = false;
                                                    username.text = "";
                                                    password.text = '';
                                                    currentusername = "";
                                                    isPassword = false;
                                                    admin = false;
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
            children: const [
              SizedBox(
                height: 60,
                width: 10,
              ),
              Text(
                'S.No',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(
                width: 50,
              ),
              Text('Username',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              SizedBox(
                width: 120,
              ),
              Text('Admin',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
            ],
          ),
          StreamBuilder<List<User>>(
              stream: FirebaseHelper.readUsers(),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  final products = snapshot.data!;
                  return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: products.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.teal,thickness: 1.5,),
                      itemBuilder: ((context, index) => ListTile(
                            title: Text(
                              products[index].username,
                              style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold),
                            ),
                            leading: Text(
                              "${index + 1}.",
                              style: const TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold),
                            ),
                            trailing: Visibility(
                              visible: products[index].isAdmin,
                              child: Text(
                                products[index].isAdmin.toString(),
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            onTap: () {
                              if (!adduser) {
                                setState(() {
                                  addUpdate = 'Update';
                                  adduser = !adduser;
                                  username.text = products[index].username;
                                  password.text = products[index].password;
                                  delButton = true;
                                  admin = products[index].isAdmin;
                                  currentusername = products[index].username;
                                });
                                setState(() {
                                  alcontroller.animateTo(
                                      alcontroller.position.minScrollExtent,
                                      duration:
                                          const Duration(milliseconds: 50),
                                      curve: Curves.ease);
                                });
                              } else {
                                setState(() {
                                  addUpdate = 'Update';
                                  username.text = products[index].username;
                                  password.text = products[index].password;
                                  currentusername = products[index].username;
                                  admin = products[index].isAdmin;
                                  delButton = true;
                                });
                              }
                            },
                          )));
                } else {
                  return const Center();
                }
              })),
        ]),
        floatingActionButton: FloatingActionButton(
            onPressed: () => setState(() {
                  if (!adduser) {
                    adduser = !adduser;
                    delButton = false;
                    addUpdate = 'Add';
                    admin = false;
                    isPassword = true;
                    currentusername = "";
                  }
                }),
            backgroundColor: Colors.green,
            child: const Icon(Icons.add)),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
