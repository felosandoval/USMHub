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
      appBar: AppBar(title: Text('Ranking de sitios')),
      body: ListView.builder(
        itemCount: sortedSites.length,
        itemBuilder: (context, index) {
          final site = sortedSites[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 15, horizontal: 35),
            child: ListTile(
              title: Text(
                '${index + 1}. ${site.name}', // Texto en mayúsculas
                style: TextStyle(
                  fontSize: 18, // Ajusta el tamaño según lo que necesites
                  fontWeight: FontWeight.bold, // Opcional: añade grosor al texto
                ),
              ),
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
