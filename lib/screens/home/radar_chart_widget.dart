import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';


class RadarChartExtend extends StatefulWidget {
  final List<String> skillNames;
  final List<double> skillLevels;

  const RadarChartExtend({
    Key? key,
    required this.skillLevels,
    required this.skillNames,
  }) : super(key: key);

  @override
  _RadarChartExtendState createState() => _RadarChartExtendState();
}

class _RadarChartExtendState extends State<RadarChartExtend> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      margin: EdgeInsets.symmetric(horizontal: 50),
      // Padding à gauche et à droite
      padding: EdgeInsets.symmetric(vertical: 20),
      // Padding à gauche et à droite
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(50), // Bords arrondis
      ),
      child: SizedBox(
        height: 200,
        child: RadarChart(
          ticks: [5, 10, 15],
          features: widget.skillNames,
          data: [widget.skillLevels],
          sides: widget.skillNames.length,
          outlineColor: Theme.of(context).colorScheme.secondary,
          graphColors: [
            Colors.white30,
          ],
          featuresTextStyle: TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}