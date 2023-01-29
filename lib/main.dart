import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

String weekdayToString(int weekday) {
  switch (weekday) {
    case 1:
      {
        return "lundi";
      }
    case 2:
      {
        return "mardi";
      }
    case 3:
      {
        return "mercredi";
      }
    case 4:
      {
        return "jeudi";
      }
    case 5:
      {
        return "vendredi";
      }
    case 6:
      {
        return "samedi";
      }
    default:
      {
        return "dimanche";
      }
  }
}

String monthToString(int month) {
  switch (month) {
    case 1:
      {
        return "janvier";
      }
    case 2:
      {
        return "février";
      }
    case 3:
      {
        return "mars";
      }
    case 4:
      {
        return "avril";
      }
    case 5:
      {
        return "mai";
      }
    case 6:
      {
        return "juin";
      }
    case 7:
      {
        return "juillet";
      }
    case 8:
      {
        return "août";
      }
    case 9:
      {
        return "septembre";
      }
    case 10:
      {
        return "octobre";
      }
    case 11:
      {
        return "novembre";
      }
    default:
      {
        return "décembre";
      }
  }
}

String datetimeToString(DateTime date) {
  return weekdayToString(date.weekday) +
      " " +
      date.day.toString() +
      " " +
      monthToString(date.month);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emploi du temps EPSI',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Emploi du temps EPSI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<TableRow> _liste = [];
  TextEditingController _controleurIdentifiant = TextEditingController();
  double _taillePolice = 6.0;
  DateTime _date = DateTime.now();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Future<void> _envoyerRequete() async {
    final identifiant = _controleurIdentifiant.text;
    final dateAmericaine = _date.month.toString() +
        "/" +
        _date.day.toString() +
        "/" +
        _date.year.toString();
    final html = await http.get(Uri.parse(
        "https://edtmobiliteng.wigorservices.net//WebPsDyn.aspx?action=posEDTBEECOME&serverid=C&Tel=$identifiant&date=$dateAmericaine"));

    final parseurHtml = parse(html.body);
    parseurHtml
        .querySelectorAll(".Case .innerCase .BackGroundCase .TCase .TCase")
        .map((e) => e.text)
        .toList();
    final tableauNoms = [];
    final tableauProfs = [];
    final tableauHoraires = [];
    final tableauSalles = [];
    final tableauJours = [];
    final joursSemaine = [];
    List<double> tailles = [];
    for (int i = 1; i <= 7; i++) {
      joursSemaine.add(
          DateTime(_date.year, _date.month, _date.day - _date.weekday + i));
    }
    final listeCase = parseurHtml.querySelectorAll(".Case");
    listeCase.sublist(0, listeCase.length - 1).forEach((element) {
      final leftChaine = element.attributes["style"]?.split(";")[3];
      final chaineTaille = leftChaine?.substring(5, leftChaine.length - 1);
      final nombre = double.parse(chaineTaille == null ? '0.0' : chaineTaille);
      tailles.add(nombre);
    });
    tailles.sort((a, b) => (a - b).toInt());

    int i = 0;
    double comp = tailles[0];
    tailles.forEach((element) {
      if (element != comp) {
        comp = element;
        i++;
      }
      tableauJours.add(joursSemaine[i]);
    });
    tableauNoms.addAll(parseurHtml
        .querySelectorAll(".Case .innerCase .BackGroundCase .TCase .TCase")
        .map((e) => e.text));
    parseurHtml
        .querySelectorAll(".Case .innerCase .BackGroundCase .TCase .TCase");
    tableauProfs.addAll(parseurHtml
        .querySelectorAll(".Case .innerCase .BackGroundCase .TCase .TCProf")
        .map((e) => e.text));
    tableauHoraires.addAll(parseurHtml
        .querySelectorAll(".Case .innerCase .BackGroundCase .TCase .TChdeb")
        .map((e) => e.text));
    tableauSalles.addAll(parseurHtml
        .querySelectorAll(".Case .innerCase .BackGroundCase .TCase .TCSalle")
        .map((e) => e.text));
    setState(() {
      _liste = [];
      for (int i = 0; i < tableauNoms.length; i++) {
        _liste.add(TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoSizeText(datetimeToString(tableauJours[i]),
                style: TextStyle(fontSize: _taillePolice), maxLines: 2),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoSizeText(tableauHoraires[i],
                style: TextStyle(fontSize: _taillePolice), maxLines: 2),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoSizeText(tableauNoms[i],
                style: TextStyle(fontSize: _taillePolice), maxLines: 2),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoSizeText(tableauSalles[i],
                style: TextStyle(fontSize: _taillePolice), maxLines: 2),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AutoSizeText(tableauProfs[i],
                style: TextStyle(fontSize: _taillePolice), maxLines: 2),
          )
        ]));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
          child: (Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                  controller: _controleurIdentifiant,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'prenom.nom',
                  )),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                width: 250,
                height: 250,
                child: CalendarDatePicker(
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2022, 9, 1),
                  lastDate: DateTime(2023, 9, 1),
                  onDateChanged: (DateTime value) {
                    _date = value;
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: _envoyerRequete,
                tooltip: 'Recherche emploi du temps',
                child: const Icon(Icons.manage_search),
              ),
            ),
            Table(border: TableBorder.all(), children: _liste)
          ],
        ),
      ))),
    );
  }
}
