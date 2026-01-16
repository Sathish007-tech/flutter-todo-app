import 'package:flutter/material.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatefulWidget{

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  String displayText= "No Text Data";

  List<String> tasklist=[];

  TextEditingController textController= TextEditingController();

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("ToDo App"),
          backgroundColor: Colors.grey,
          centerTitle: true,
        ),
        body: Column(
          children: [

            Row(
              children: [
                Expanded(child:
                Container(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Enter Your task"),
                    ),
                  ),
                ),
                ),
                MaterialButton(
                  color: Colors.white,
                  height: 50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () {
                    setState(() {
                      tasklist.add(textController.text);
                      textController.clear();
                    });
                  },
                  child: Text("Add Task"),
                ),



              ],
            ),
            Flexible(
              child: ListView.builder(
                itemCount: tasklist.length,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text(tasklist[index]),
                          ),
                        ),
                        MaterialButton(
                          onPressed: () {
                            setState(() {
                              tasklist.removeAt(index);
                            });
                          },
                          child: Icon(Icons.delete, color: Colors.black87,),
                        )
                      ]);
                    },
                  ),
            ),
          ],
        )),
    );
  }
}