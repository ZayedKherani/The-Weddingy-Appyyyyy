import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'ThemeData.dart';
import 'eventData.dart';
import 'weddingPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: darkTheme,
      title: 'The Wedding App',
      theme: lightTheme,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _createEventController = TextEditingController();
  String eventNameText, eventName;

  double _screenWidth, _screenHeight;

  DateTime selectedDate = DateTime.now();

  List<EventData> eventData = [];

  void _addToList(String eventName) {
    setState(() {
      int eventNumber;

      if (eventData.isEmpty) {
        eventNumber = 1;
      } else {
        eventNumber = eventData.last.eventNumber + 1;
      }

      EventData currentEventData = EventData(
          eventNumber: eventNumber,
          eventName: eventName,
          eventDateTime: selectedDate);

      eventData.add(currentEventData);
    });
  }

  _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
    }
  }

  buildMaterialDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day),
      lastDate: DateTime(
          DateTime.now().year + 5, DateTime.now().month, DateTime.now().day),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Event Date',
      errorFormatText: 'Enter Valid Date',
      errorInvalidText: 'Enter Date in Valid Range',
      fieldLabelText: 'Event Date',
      fieldHintText: 'Month/Date/Year',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                if (picked != null && picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                  });
              },
              initialDateTime: selectedDate,
              minimumDate: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day),
              maximumDate: DateTime(DateTime.now().year + 5,
                  DateTime.now().month, DateTime.now().day),
            ),
          );
        });
  }

  Future<void> createEvent(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Create A New Event"),
          content: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    eventNameText = value;
                  });
                },
                controller: _createEventController,
                decoration: InputDecoration(
                  hintText: "Event Name",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text("${selectedDate.toLocal()}".split(" ")[0]),
              SizedBox(
                height: 20,
              ),
              TextButton(
                // onPressed: () => _selectDate(context),
                onPressed: () => _selectDate(context),
                child: Text('  Select Date  '),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.grey[400]),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("  CANCEL  "),
              onPressed: () {
                _createEventController.clear();
                Navigator.pop(context);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
            TextButton(
              child: Text("OK"),
              onPressed: () {
                setState(() {
                  eventName = eventNameText;
                });
                _createEventController.clear();
                Navigator.pop(context);
                _addToList(eventName);
              },
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  _readEvents() async {
    final prefs = await SharedPreferences.getInstance();

    int loopLength = prefs.getInt("numberOfEvents") ?? 0;

    for (int i = 0; i < loopLength; i++) {
      String jsonCurrentEventDataToRead = prefs.getString(i.toString()) ?? null;

      if (jsonCurrentEventDataToRead != null) {
        Map<String, dynamic> currentEventDataToRead =
            jsonDecode(jsonCurrentEventDataToRead);
        EventData currentEventData = EventData.fromMap(currentEventDataToRead);

        setState(() {
          eventData.add(currentEventData);
        });
      }
    }
  }

  _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();

    for (int i = 0; i < eventData.length; i++) {
      Map<String, dynamic> currentEventDataToSave = eventData[i].toMap();
      String jsonCurrentEventDataToSave = jsonEncode(currentEventDataToSave);

      prefs.setString(i.toString(), jsonCurrentEventDataToSave);
    }

    prefs.setInt("numberOfEvents", eventData.length);
  }

  @override
  void initState() {
    _readEvents();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _screenWidth = MediaQuery.of(context).size.width;
      _screenHeight = MediaQuery.of(context).size.height;
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Weddings"),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: _screenWidth / 2,
          mainAxisExtent: _screenHeight / 8,
          childAspectRatio: 3 / 2,
        ),
        itemCount: eventData.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.fromLTRB(15, 7.5, 15, 7.5),
            child: OpenContainer(
              closedBuilder: (context, animation) {
                return ListTile(
                  title: Text(eventData[index].eventName),
                );
              },
              openBuilder: (context, animation) {
                return WeddingHome(
                  currentWeddingData: eventData[index],
                );
              },
              closedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await createEvent(context);
          await _saveEvents();
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
