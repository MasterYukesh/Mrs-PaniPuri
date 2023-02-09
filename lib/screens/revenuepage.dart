import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/bill.dart';
import '../model/firebasehelper.dart';

class RevenuePage extends StatefulWidget {
  const RevenuePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RevenuePage();
  }
}

class _RevenuePage extends State<RevenuePage> {
  DateFormat formatter = DateFormat("d-M-y");
  Map<String, List> dtlist =
      {}; // date is the key , this [cost,total revenue,cashCount,UPIcount] list is the value
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            shadowColor: Colors.white,
            backgroundColor: Colors.black,
            title: const Text('Revenue'),
          ),
          body: StreamBuilder<List<Bill>>(
            stream: FirebaseHelper.readBills(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final billList = snapshot.data!;
                //sorting the bills according wrt date(latest first)
                billList.sort((a, b) => DateTime.parse(b.dateTime)
                    .compareTo(DateTime.parse(a.dateTime)));
                // adding the bill dates (as key) and [cost,number,cash revenue,UPI revenue] as value in the Map
                for (var item in billList) {
                  String date = formatter.format(DateTime.parse(item.dateTime));
                  // incase if it is not the 1rst bill of the given date.
                  if (dtlist.keys.contains(date)) {
                    // updating the total revenue for that day and the number of bills for that day.
                    dtlist[date]![1] += 1;
                    dtlist[date]![0] += item.cost;
                    if (item.paymentMode == "Cash") {
                      dtlist[date]![2] += item.cost;
                    } else {
                      dtlist[date]![3] += item.cost;
                    }
                  }
                  // if it is the first bill of the day (according to the sorted data)
                  else {
                    double x = 0;
                    double y = 0;
                    if (item.paymentMode == "Cash") {
                      x += item.cost;
                    } else {
                      y += item.cost;
                    }
                    dtlist.addAll({
                      date: [item.cost, 1, x, y]
                    });
                  }
                }
                return ListView(
                  shrinkWrap: true,
                  children: dtlist.keys
                      .map((bill) => Padding(
                          padding: const EdgeInsets.all(10),
                          child: ListTile(
                            shape: const RoundedRectangleBorder(
                                side: BorderSide(color: Colors.orange),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            title: Text(
                              bill,
                              style: const TextStyle(
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "No. Of Orders : ${dtlist[bill]![1].toString()} \n Cash : ${dtlist[bill]![2]}   UPI : ${dtlist[bill]![3]} ",
                              style:const TextStyle(color: Colors.grey),
                            ),
                            trailing: Text(
                              "\u20B9 ${dtlist[bill]![0]}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                          )))
                      .toList(),
                );
              } else {
                return Container();
              }
            },
          )),
    );
  }
}
