import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final LocalStorage storage = new LocalStorage('myFile');

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<String> readContent() async {
    try {
      final file = await _localFile;
      // Read the file
      String contents = await file.readAsString();
      // Returning the contents of the file
      return contents;
    } catch (e) {
      // If encountering an error, return
      return 'Error!';
    }
  }

  Future<File> writeContent(data) async {
    final file = await _localFile;
    return file.writeAsString(data);
  }

  Future<dynamic> getData() async {
    var url = Uri.parse("https://countriesnow.space/api/v0.1/countries");
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse =
          convert.jsonDecode(response.body) as Map<String, dynamic>;
      var itemCount = jsonResponse['data'];
      print(response);
      print('Number of books about http: $itemCount.');
      return itemCount;
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  void initState() {
    super.initState();
    //writeContent();
    readContent().then((String value) {
      if (value == "" || value == null) {
        print("value is null");
      } else {
        print("not null");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Size constraints
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var safeBodyHeight = height - MediaQuery.of(context).padding.top;

    return SafeArea(
      child: Scaffold(
          body: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: width * 0.05, vertical: safeBodyHeight * 0.05),
              height: safeBodyHeight,
              width: double.infinity,
              child: FutureBuilder(
                  future: getData(),
                  builder: (context, AsyncSnapshot snapshsotData) {
                    if (snapshsotData.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshsotData.connectionState ==
                        ConnectionState.done) {
                      if (snapshsotData.hasError) {
                        return const Text('Error');
                      } else if (snapshsotData.hasData) {
                        // write data into storage
                        writeContent(snapshsotData.data);
                        return mainUI(context, snapshsotData.data);
                      } else {
                        return const Text('Empty data');
                      }
                    } else {
                      return Text('State: ${snapshsotData.connectionState}');
                    }
                  }))
          // This trailing comma makes auto-formatting nicer for build methods.
          ),
    );
  }
}

Widget mainUI(context, dynamic data) {
  var height = MediaQuery.of(context).size.height;
  var width = MediaQuery.of(context).size.width;
  var safeBodyHeight = height - MediaQuery.of(context).padding.top;

  return ListView.builder(itemBuilder: (context, index) {
    return Container(
      height: safeBodyHeight * 0.08,
      width: double.infinity,
      margin: EdgeInsets.symmetric(
        vertical: 10,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.withOpacity(0.3)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Flag image
          Container(
            height: safeBodyHeight * 0.06,
            width: width * 0.2,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.red),
          ),

          // Country info
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(data[index]["country"] != null
                  ? data[index]["country"].toString()
                  : ""),
              Text("UTC 5"),
            ],
          ),

          //region info
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(data[index]["cities"][0] != null
                    ? data[index]["cities"][0].toString()
                    : ""),
              ),
              Flexible(
                child: Text(data[index]["cities"][1] != null
                    ? data[index]["cities"][1].toString()
                    : ""),
              ),
            ],
          )
        ],
      ),
    );
  });
}
