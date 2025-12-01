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

class ReportScreen extends StatefulWidget {
  final List<double> values;
  final Map<int, Map<String, int>> rollCombinations;
  final Map<Color, Map<int, int>> playerHits;
  final Map<Color, List<int>> players;
  final List<Color> availableColors;
  final List<String> colorNames;

  ReportScreen({required this.values, required this.rollCombinations, required this.playerHits, required this.players, required this.availableColors, required this.colorNames});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedReport = 'Players';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedReport == 'Players' ? null : () => setState(() => selectedReport = 'Players'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedReport == 'Players' ? Colors.blue : null,
                    ),
                    child: Text('Players'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedReport == 'Dice Results' ? null : () => setState(() => selectedReport = 'Dice Results'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedReport == 'Dice Results' ? Colors.blue : null,
                    ),
                    child: Text('Dice Results'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedReport == 'Players' ? _buildPlayersReport() : _buildDiceResultsReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersReport() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[300],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: _buildPlayerBarChart(),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.availableColors.map((color) {
                String name = widget.colorNames[widget.availableColors.indexOf(color)];
                int hits = widget.playerHits[color]?.values.fold<int>(0, (int sum, int count) => sum + count) ?? 0;
                List<int> playerNumbers = widget.players[color] ?? [];
                
                if (playerNumbers.isEmpty) return SizedBox.shrink();
                
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ActionChip(
                      avatar: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: color,
                          border: Border.all(color: Colors.grey[800]!, width: 1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      label: Text('$name: ${playerNumbers.length} numbers, $hits hits'),
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerHitsDetailScreen(playerName: name, playerColor: color, playerNumbers: playerNumbers, playerHits: widget.playerHits, rollCombinations: widget.rollCombinations))),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerBarChart() {
    List<BarChartGroupData> barGroups = [];
    
    for (int sum = 2; sum <= 12; sum++) {
      if (sum == 7) continue;
      
      List<BarChartRodData> rods = [];
      List<MapEntry<Color, int>> playerHitsForSum = [];
      
      for (var entry in widget.players.entries) {
        if (entry.value.contains(sum)) {
          int hits = widget.playerHits[entry.key]?[sum] ?? 0;
          playerHitsForSum.add(MapEntry(entry.key, hits));
        }
      }
      
      playerHitsForSum.sort((a, b) => b.value.compareTo(a.value));
      
      for (int i = 0; i < playerHitsForSum.length; i++) {
        rods.add(BarChartRodData(
          toY: playerHitsForSum[i].value.toDouble(),
          color: playerHitsForSum[i].key,
          width: 8,
        ));
      }
      
      if (rods.isNotEmpty) {
        barGroups.add(BarChartGroupData(x: sum, barRods: rods));
      }
    }
    
    return barGroups.isEmpty ? Center(child: Text('No player data')) : BarChart(
      BarChartData(
        barGroups: barGroups,
        groupsSpace: 4,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}'),
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }

  Widget _buildDiceResultsReport() {
    return ListView.builder(
      itemCount: 11,
      itemBuilder: (context, index) {
        int sum = index + 2;
        int total = widget.values[index].toInt();
        return ListTile(
          leading: ElevatedButton(
            onPressed: total > 0 ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => CombinationDetailScreen(sum: sum, combinations: widget.rollCombinations[sum] ?? {}))) : null,
            child: Text('$sum'),
          ),
          title: Text('Total: $total'),
        );
      },
    );
  }
}

class PlayerScreen extends StatelessWidget {
  final Map<Color, List<int>> players;
  final List<Color> availableColors;
  final List<String> colorNames;
  final Function(Map<Color, List<int>>) onUpdate;

  PlayerScreen({required this.players, required this.availableColors, required this.colorNames, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    Map<Color, List<int>> tempPlayers = {};
    for (var entry in players.entries) {
      tempPlayers[entry.key] = List.from(entry.value);
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Players'),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: () {
              onUpdate(tempPlayers);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: StatefulBuilder(
        builder: (context, setState) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: availableColors.length,
                itemBuilder: (context, index) {
                  Color color = availableColors[index];
                  String name = colorNames[index];
                  List<int> sums = tempPlayers[color] ?? [];
                  
                  return ExpansionTile(
                    leading: Container(width: 30, height: 30, color: color),
                    title: Text('$name (${sums.length} numbers)'),
                    initiallyExpanded: index < 4,
                    children: [
                      Column(
                        children: [
                          Row(
                            children: [2, 3, 4, 5, 6].map((sum) {
                              bool isSelected = sums.contains(sum);
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (isSelected) {
                                          tempPlayers[color]?.remove(sum);
                                          if (tempPlayers[color]?.isEmpty == true) {
                                            tempPlayers.remove(color);
                                          }
                                        } else {
                                          tempPlayers.putIfAbsent(color, () => []);
                                          tempPlayers[color]!.add(sum);
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected ? color : Colors.grey[300],
                                      side: BorderSide(color: Colors.grey[800]!, width: 1),
                                    ),
                                    child: Text('$sum'),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Row(
                            children: [8, 9, 10, 11, 12].map((sum) {
                              bool isSelected = sums.contains(sum);
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(2),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (isSelected) {
                                          tempPlayers[color]?.remove(sum);
                                          if (tempPlayers[color]?.isEmpty == true) {
                                            tempPlayers.remove(color);
                                          }
                                        } else {
                                          tempPlayers.putIfAbsent(color, () => []);
                                          tempPlayers[color]!.add(sum);
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isSelected ? color : Colors.grey[300],
                                      side: BorderSide(color: Colors.grey[800]!, width: 1),
                                    ),
                                    child: Text('$sum'),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class PlayerHitsDetailScreen extends StatelessWidget {
  final String playerName;
  final Color playerColor;
  final List<int> playerNumbers;
  final Map<Color, Map<int, int>> playerHits;
  final Map<int, Map<String, int>> rollCombinations;

  PlayerHitsDetailScreen({required this.playerName, required this.playerColor, required this.playerNumbers, required this.playerHits, required this.rollCombinations});

  @override
  Widget build(BuildContext context) {
    List<int> numbers = List.from(playerNumbers);
    numbers.sort();
    List<double> hits = numbers.map((num) {
      return (playerHits[playerColor]?[num] ?? 0).toDouble();
    }).toList();
    
    return Scaffold(
      appBar: AppBar(title: Text('$playerName Hits')),
      body: Container(
        color: Colors.grey[300],
        child: Padding(
          padding: EdgeInsets.all(16),
          child: numbers.isEmpty ? Center(child: Text('No numbers assigned')) : BarChart(
            BarChartData(
              barGroups: List.generate(numbers.length, (index) => 
                BarChartGroupData(
                  x: index,
                  barRods: [BarChartRodData(toY: hits[index], color: Colors.blue)],
                )
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) => Text('${numbers[value.toInt()]}'),
                  ),
                ),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
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
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 1)),
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
  Map<Color, List<int>> players = {};
  Map<Color, Map<int, int>> playerHits = <Color, Map<int, int>>{};
  int? selectedRow1;
  int? selectedRow2;
  
  final List<Color> availableColors = [Colors.white, Colors.red, Colors.blue, Colors.yellow, Colors.green, Colors.purple];
  final List<String> colorNames = ['White', 'Red', 'Blue', 'Yellow', 'Green', 'Purple'];
  
  Color _getColorForSum(int sum) {
    for (var entry in players.entries) {
      if (entry.value.contains(sum)) return entry.key;
    }
    return Colors.blue;
  }

  void addResult() {
    if (selectedRow1 != null && selectedRow2 != null) {
      int sum = selectedRow1! + selectedRow2!;
      if (sum >= 2 && sum <= 12) {
        String combo = '${selectedRow1!},${selectedRow2!}';
        setState(() {
          values[sum - 2]++;
          rollCombinations.putIfAbsent(sum, () => {});
          rollCombinations[sum]![combo] = (rollCombinations[sum]![combo] ?? 0) + 1;
          
          // Track player hits
          for (var entry in players.entries) {
            if (entry.value.contains(sum)) {
              playerHits.putIfAbsent(entry.key, () => {});
              playerHits[entry.key]![sum] = (playerHits[entry.key]![sum] ?? 0) + 1;
            }
          }
          
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
      players.clear();
      playerHits.clear();
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
              child: Column(
                children: [
                  Expanded(
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
                  Padding(
                    padding: EdgeInsets.only(left: 36, right: 13),
                    child: Row(
                      children: List.generate(11, (index) {
                      int sum = index + 2;
                      List<Color> sumColors = [];
                      List<String> sumNames = [];
                      
                      for (var entry in players.entries) {
                        if (entry.value.contains(sum)) {
                          sumColors.add(entry.key);
                          int colorIndex = availableColors.indexOf(entry.key);
                          if (colorIndex != -1) sumNames.add(colorNames[colorIndex][0]);
                        }
                      }
                      
                      if (sumColors.isEmpty) {
                        sumColors.add(Colors.grey);
                        sumNames.add('');
                      }
                      
                      return Expanded(
                        child: Center(
                          child: sumColors.length == 1 
                            ? Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: sumColors[0],
                                  border: Border.all(color: Colors.grey[800]!, width: 1),
                                ),
                                child: Center(
                                  child: Text(
                                    sumNames[0],
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                children: sumColors.map((color) {
                                  int idx = sumColors.indexOf(color);
                                  return Container(
                                    width: 20,
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color: color,
                                      border: Border.all(color: Colors.grey[800]!, width: 1),
                                    ),
                                    child: Center(
                                      child: Text(
                                        sumNames[idx],
                                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                        ),
                      );
                      }),
                    ),
                  ),
                ],
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
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(onPressed: addResult, child: Text('Submit Roll')),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(players: players, availableColors: availableColors, colorNames: colorNames, onUpdate: (newPlayers) => setState(() => players = newPlayers)))),
                      child: Text('Players'),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 1), child: ElevatedButton(onPressed: clearSelection, child: Text('Clear')))),
                    Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 1), child: ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ReportScreen(values: values, rollCombinations: rollCombinations, playerHits: playerHits, players: players, availableColors: availableColors, colorNames: colorNames))), child: Text('Report')))),
                    Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 1), child: ElevatedButton(onPressed: reset, child: Text('Reset')))),
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