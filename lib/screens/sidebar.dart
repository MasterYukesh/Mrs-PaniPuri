import 'package:flutter/material.dart';
import 'package:mrs_panipuri/screens/accountspage.dart';
import 'package:mrs_panipuri/screens/productspage.dart';
import 'package:mrs_panipuri/screens/revenuepage.dart';
import 'frontpage.dart';
import 'homepage.dart';

class SideBar extends StatefulWidget {
  final bool isAdmin;
  const SideBar({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SiderBar();
  }
}

class _SiderBar extends State<SideBar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.blue,
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text(
              'Home',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => HomePage(
                          isAdmin: widget.isAdmin,
                        )),
              );
            },
          ),
          Visibility(
              visible: widget.isAdmin,
              child: const Divider(
                thickness: 2,
                color: Colors.lightBlue,
              )),
          ListTile(
            leading: const Icon(
              Icons.view_list_sharp,
            ),
            title: const Text('Manage Products',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const ProductsPage()));
            },
          ),
          Visibility(
              visible: widget.isAdmin,
              child: const Divider(
                thickness: 2,
                color: Colors.lightBlue,
              )),
          Visibility(
            visible: widget.isAdmin,
            child: ListTile(
              leading: const Icon(Icons.manage_accounts),
              title: const Text('Manage Accounts',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AccountPage()));
              },
            ),
          ),
          const Divider(
            thickness: 2,
            color: Colors.lightBlue,
          ),
          ListTile(
            leading: const Icon(Icons.currency_rupee),
            title: const Text('Revenue',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RevenuePage()));
            },
          ),
          const Divider(
            thickness: 2,
            color: Colors.lightBlue,
          ),
          const SizedBox(
            height: 100,
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log out',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FrontPage()),
              );
            },
          ),
          const Divider(thickness: 2,color: Colors.lightBlue,)
        ],
      ),
    );
  }
}
