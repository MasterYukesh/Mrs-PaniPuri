import 'package:flutter/material.dart';
import 'package:mrs_panipuri/model/firebasehelper.dart';
import 'package:mrs_panipuri/screens/sidebar.dart';
import 'package:mrs_panipuri/screens/billpage.dart';
import '../model/bill.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  //this property is used to check whether the signed in user is an admin or not.
  final bool isAdmin;
  const HomePage({Key? key, required this.isAdmin}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  //List datelist = [];
  DateFormat formatter = DateFormat("d/M/y").add_jm();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        drawer: SideBar(
          isAdmin: widget.isAdmin,
        ),
        appBar: AppBar(
          title: const Text('Mrs Pani Puri',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body:
            //Always specify the data type while building streams
            StreamBuilder<List<Bill>>(
                stream: FirebaseHelper.readBills(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    throw (snapshot.error.toString());
                  }
                  if (snapshot.hasData) {
                    //create a bill List that contains all the bill data
                    final billList = snapshot.data!;
                    // sorting the list wrt time [latest first]
                    billList.sort((a, b) => DateTime.parse(b.dateTime)
                        .compareTo(DateTime.parse(a.dateTime)));
                    return ListView(
                        shrinkWrap: true,
                        children: billList
                            .map(
                              (bill) => Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        title: RichText(
                                            text: TextSpan(
                                                text: 'Bill',
                                                style: const TextStyle(
                                                    color: Colors.deepPurple,
                                                    fontSize: 20),
                                                children: [
                                              TextSpan(
                                                  text:
                                                      ' #  ${billList.length - billList.indexOf(bill)}',
                                                  style: const TextStyle(
                                                      color: Colors.purple,
                                                      fontSize: 23,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ])),
                                        subtitle: Text(
                                          formatter.format(
                                              DateTime.parse(bill.dateTime)),
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                        trailing: Text(
                                          "\u20B9 ${bill.cost.toString()}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      BillPage(bill: bill)));
                                        },
                                      ),
                                      const Divider(color: Colors.grey)
                                    ],
                                  )),
                            )
                            .toList());
                  } else {
                    return Container();
                    // return Center(child: Column(
                    //   children: const[ SizedBox(height: 300,),
                    //     Text('No Bill\'s found! :(',textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 30),),
                    //   ],
                    // ));
                  }
                }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightBlue,
          child: const Icon(
            Icons.add,
            color: Colors.yellow,
          ),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BillPage(
                        bill:
                            null, // indicating that a new bill is to be generated.
                      ))),
        ),
      ),
    );
  }
}
