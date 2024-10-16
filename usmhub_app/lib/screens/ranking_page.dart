import 'package:flutter/material.dart';
import '../models/subsystem.dart';

class RankingsPage extends StatefulWidget {
  final List<Subsystem> sites;

  RankingsPage({required this.sites});

  @override
  _RankingsPageState createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  @override
  Widget build(BuildContext context) {
    // Ordena los sitios antes de construir la UI
    List<Subsystem> sortedSites = List.from(widget.sites);
    sortedSites.sort((a, b) => b.averageRating.compareTo(a.averageRating));

    return Scaffold(
      appBar: AppBar(title: Text('Ranking')),
      body: ListView.builder(
        itemCount: sortedSites.length,
        itemBuilder: (context, index) {
          final site = sortedSites[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('${index + 1}. ${site.name}'),
              subtitle: Text(
                site.averageRating == 0
                  ? 'Sin valoraciones'
                  : 'Valoración promedio: ${site.averageRating.toStringAsFixed(1)}',
              ),
              trailing: Icon(Icons.star, color: Colors.amber),
            ),
          );
        },
      ),
    );
  }
}
