import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(EPDMApp());
}

class EPDMApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mesure EPDM',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: EPDMHomePage(),
    );
  }
}

class EPDMHomePage extends StatefulWidget {
  @override
  _EPDMHomePageState createState() => _EPDMHomePageState();
}

class _EPDMHomePageState extends State<EPDMHomePage> {
  final TextEditingController _speedController = TextEditingController();
  final TextEditingController _initialWeightController = TextEditingController();
  final TextEditingController _currentWeightController = TextEditingController();

  DateTime? _lastTopTime;
  double? _lastWeight;
  List<Map<String, dynamic>> _measures = [];

  void _recordTopTime() {
    setState(() {
      _lastTopTime = DateTime.now();
      _lastWeight = double.tryParse(_currentWeightController.text);
    });
  }

  void _addMeasure() {
    if (_lastTopTime == null || _lastWeight == null) return;

    final currentTime = DateTime.now();
    final currentWeight = double.tryParse(_currentWeightController.text);
    final speed = double.tryParse(_speedController.text);

    if (currentWeight == null || speed == null) return;

    final duration = currentTime.difference(_lastTopTime!);
    final seconds = duration.inSeconds;
    final consumedWeight = _lastWeight! - currentWeight;
    final meters = speed * seconds / 60;
    final consumptionPerMeter = meters > 0 ? consumedWeight / meters : 0;

    setState(() {
      _measures.add({
        'duration': seconds,
        'consumed': consumedWeight,
        'consumptionPerMeter': consumptionPerMeter,
        'time': DateFormat.Hms().format(currentTime),
      });
      _lastTopTime = currentTime;
      _lastWeight = currentWeight;
    });
  }

  void _removeMeasure(int index) {
    setState(() {
      _measures.removeAt(index);
    });
  }

  double _averageConsumption() {
    if (_measures.isEmpty) return 0;
    final valid = _measures.map((m) => m['consumptionPerMeter'] as double).toList();
    return valid.reduce((a, b) => a + b) / valid.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mesure EPDM')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(children: [
          TextField(
            controller: _speedController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Vitesse de ligne (m/min)'),
          ),
          TextField(
            controller: _initialWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Poids initial de la palette (kg)'),
          ),
          TextField(
            controller: _currentWeightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Poids actuel de la palette (kg)'),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _recordTopTime,
            child: Text('TOP TEMPS'),
          ),
          if (_lastTopTime != null)
            Text('Dernier TOP: ${DateFormat.Hms().format(_lastTopTime!)}'),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addMeasure,
            child: Text('AJOUTER MESURE'),
          ),
          SizedBox(height: 20),
          Text('Mesures enregistrées:', style: TextStyle(fontWeight: FontWeight.bold)),
          ..._measures.asMap().entries.map((entry) {
            final i = entry.key;
            final m = entry.value;
            return ListTile(
              title: Text('Mesure ${i + 1} - ${m['time']}'),
              subtitle: Text(
                  'Durée: ${m['duration']}s, Consommé: ${m['consumed'].toStringAsFixed(2)}kg, ${m['consumptionPerMeter'].toStringAsFixed(2)} g/m'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => _removeMeasure(i),
              ),
            );
          }),
          SizedBox(height: 10),
          Text('Consommation moyenne: ${_averageConsumption().toStringAsFixed(2)} g/m'),
        ]),
      ),
    );
  }
}
