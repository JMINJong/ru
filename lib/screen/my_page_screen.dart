import 'package:flutter/material.dart';
import 'package:runnin_us/const/color.dart';
import 'package:runnin_us/const/dummy.dart';

class MyPageScreen extends StatelessWidget {
  MyPageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: renderPageList(list: myPageList, index: 0));
  }

  Widget renderPageList({
    required List list,
    required int index,
  }) {
    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.all(30.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: MINT_COLOR.withOpacity(0.7))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${myPageList[index]['name']}'),
          ]),
        ),
        Container(
          margin: const EdgeInsets.all(30.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: MINT_COLOR.withOpacity(0.7))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${myPageList[index]['age']}'),
          ]),
        ),
        Container(
          margin: const EdgeInsets.all(30.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: MINT_COLOR.withOpacity(0.7))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${myPageList[index]['location']}'),
          ]),
        ),
        Container(
          margin: const EdgeInsets.all(30.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: MINT_COLOR.withOpacity(0.7))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${myPageList[index]['level']}'),
          ]),
        ),
        Container(
          margin: const EdgeInsets.all(30.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: MINT_COLOR.withOpacity(0.7))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${myPageList[index]['score']}'),
          ]),
        ),
        Container(
          margin: const EdgeInsets.all(30.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: MINT_COLOR.withOpacity(0.7))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${myPageList[index]['recent']}'),
          ]),
        ),
        Container(
          margin: const EdgeInsets.all(30.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              border: Border.all(color: MINT_COLOR.withOpacity(0.7))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text('${myPageList[index]['point']}'),
          ]),
        )
      ],
    ));
  }
}
