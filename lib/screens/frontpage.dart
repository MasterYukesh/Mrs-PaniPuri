import 'package:flutter/material.dart';
import 'package:mrs_panipuri/model/firebasehelper.dart';

import 'homepage.dart';

class FrontPage extends StatefulWidget {
  const FrontPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FrontPage();
  }
}

class _FrontPage extends State<FrontPage> {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isPassword = true; //for Obscure text property of password textfield
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: ListView(
          shrinkWrap: true,
          reverse: false,
          children: [
            const SizedBox(
              height: 100,
            ),
            Image.asset(
              'lib/assets/images/logo-removebg-preview.png',
              height: 250,
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                cursorColor: Colors.red,
                controller: username,
                style:const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_circle_outlined),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Padding(
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                      width: 300,
                      child: TextField(
                        style:const TextStyle(fontWeight: FontWeight.bold),
                        cursorColor: Colors.red,
                        obscureText: isPassword,
                        controller: password,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.password_sharp),
                            //suffix: ,
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            labelText: 'Password',
                            labelStyle: TextStyle(color: Colors.black)),
                      ),
                    )),
                IconButton(
                  icon: isPassword
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.visibility),
                  onPressed: () => setState(() {
                    isPassword = !isPassword;
                  }),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(150, 10, 150, 10),
                child: ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.orange)),
                    onPressed: () => verifylogin(),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ))),
            const SizedBox(
              height: 10,
            ),
          ].toList(),
        ),
      ),
    );
  }

  verifylogin() async {
    if (username.text.isNotEmpty && password.text.isNotEmpty) {
      var res = await FirebaseHelper.readUser(username.text.trim());
      if (res?.password == password.text.trim()) {
        setState(() {
          username.text = "";
          password.text = "";
        });
        // unable to build widgets inside the async function hence a method
        if (res?.isAdmin == true) {
          navigate(true);
        } else {
          navigate(false);
        }
      } else {
        // unable to build widgets inside the async function hence a method
        showalert();
      }
    } else {
      alertBox(context, 'Please enter all the credentials');
    }
  }

  void showalert() {
    alertBox(context, 'Please enter valid credentials');
  }

  void alertBox(BuildContext context, String text) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(text),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ok'))
              ],
            ));
  }

  void navigate(bool isAdmin) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => HomePage(
                  isAdmin: isAdmin,
                ))));
  }
}
