import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/Item.dart';


void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JoaoApp01',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = <Item>[];

  HomePage(){
    items = [];
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var txtCtrl = TextEditingController();

  void inserir_terefa(){
    if(txtCtrl.text.isNotEmpty){
      setState(() {
        widget.items.add(Item(title: txtCtrl.text, done: false));
      });
      txtCtrl.clear();
      salvarEstadoTarefas();
    }
  }
  
  void remover_tarefa(int index){
    setState(() {
      widget.items.removeAt(index);
      salvarEstadoTarefas();
    });
  }

  Future recuperarTarefas() async{
    var sharedP = await SharedPreferences.getInstance();
    var data = sharedP.getString('data');

    if (data != null){
      Iterable jsonDecod = jsonDecode(data);
      List<Item> resultado = jsonDecod.map((x) => Item.fromJson(x)).toList();
      setState(() {
        widget.items = resultado;
      });
    }
  }
  
  salvarEstadoTarefas() async{
    var sharedP = await SharedPreferences.getInstance();
    var data = sharedP.setString('data', jsonEncode(widget.items));
  }

  _HomePageState(){
    recuperarTarefas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          controller: txtCtrl,
          keyboardType: TextInputType.text,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: "Insira sua tarefa",
            hintStyle: TextStyle(
              color: Colors.white70
            ),
            labelText: "Nova tarefa",
            labelStyle: TextStyle(
              fontSize: 16,
              color: Colors.greenAccent,
            ),
            icon: Icon(
              Icons.add_alert_sharp,
              color: Colors.white70,
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctxt, int index){
          final item = widget.items[index];
          return Dismissible(
              key: Key(item.title as String),
              child: CheckboxListTile(
                  title: Text(item.title as String),
                  value: item.done,
                  onChanged: (value){
                    setState(() {
                      item.done = value;
                      salvarEstadoTarefas();
                    });
                  },
              ),
              background: Container(
                color: Colors.redAccent.withOpacity(0.8),
              ),
            onDismissed: (direction){
                remover_tarefa(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: inserir_terefa,
        child: Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
    );
  }
}


