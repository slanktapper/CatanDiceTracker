import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bar Graph 2-12',
      home: BarGraphScreen(),
    );
  }
}

class ReportScreen extends StatelessWidget {
  final List<double> values;
  final Map<int, Map<String, int>> rollCombinations;

  ReportScreen({required this.values, required this.rollCombinations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report')),
      body: ListView.builder(
        itemCount: 11,
        itemBuilder: (context, index) {
          int sum = index + 2;
          int total = values[index].toInt();
          return ListTile(
            leading: ElevatedButton(
              onPressed: total > 0 ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => CombinationDetailScreen(sum: sum, combinations: rollCombinations[sum] ?? {}))) : null,
              child: Text('$sum'),
            ),
            title: Text('Total: $total'),
          );
        },
      ),
    );
  }
}

class CombinationDetailScreen extends StatelessWidget {
  final int sum;
  final Map<String, int> combinations;

  CombinationDetailScreen({required this.sum, required this.combinations});

  @override
  Widget build(BuildContext context) {
    List<String> combos = combinations.keys.toList();
    List<double> counts = combinations.values.map((e) => e.toDouble()).toList();
    
    return Scaffold(
      appBar: AppBar(title: Text('Sum $sum Combinations')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: combos.isEmpty ? Center(child: Text('No data')) : BarChart(
          BarChartData(
            barGroups: List.generate(combos.length, (index) => 
              BarChartGroupData(
                x: index,
                barRods: [BarChartRodData(toY: counts[index], color: Colors.green)],
              )
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Text(combos[value.toInt()]),
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
          ),
        ),
      ),
    );
  }
}

class BarGraphScreen extends StatefulWidget {
  @override
  _BarGraphScreenState createState() => _BarGraphScreenState();
}

class _BarGraphScreenState extends State<BarGraphScreen> {
  List<double> values = List.filled(11, 0);
  Map<int, Map<String, int>> rollCombinations = {};
  int? selectedRow1;
  int? selectedRow2;

  void addResult() {
    if (selectedRow1 != null && selectedRow2 != null) {
      int sum = selectedRow1! + selectedRow2!;
      if (sum >= 2 && sum <= 12) {
        String combo = '${selectedRow1!},${selectedRow2!}';
        setState(() {
          values[sum - 2]++;
          rollCombinations.putIfAbsent(sum, () => {});
          rollCombinations[sum]![combo] = (rollCombinations[sum]![combo] ?? 0) + 1;
          selectedRow1 = null;
          selectedRow2 = null;
        });
      }
    }
  }

  void clearSelection() {
    setState(() {
      selectedRow1 = null;
      selectedRow2 = null;
    });
  }

  void reset() {
    setState(() {
      values = List.filled(11, 0);
      rollCombinations.clear();
      selectedRow1 = null;
      selectedRow2 = null;
    });
  }

  Widget buildDiceRow(int? selected, Function(int) onSelect) {
    return Row(
      children: List.generate(6, (index) {
        int value = index + 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2),
            child: ElevatedButton(
              onPressed: () => setState(() => onSelect(value)),
              style: ElevatedButton.styleFrom(
                backgroundColor: selected == value ? Colors.blue : null,
              ),
              child: Text('$value'),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Catan Dice Tracker')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: BarChart(
                BarChartData(
                  barGroups: List.generate(11, (index) => 
                    BarChartGroupData(
                      x: index + 2,
                      barRods: [BarChartRodData(toY: values[index], color: Colors.blue)],
                    )
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                buildDiceRow(selectedRow1, (value) => selectedRow1 = value),
                SizedBox(height: 8),
                buildDiceRow(selectedRow2, (value) => selectedRow2 = value),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: addResult, child: Text('Add')),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: ElevatedButton(onPressed: clearSelection, child: Text('Clear')))),
                    Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReportScreen(values: values, rollCombinations: rollCombinations))), child: Text('Report')))),
                    Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 2), child: ElevatedButton(onPressed: reset, child: Text('Reset')))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}