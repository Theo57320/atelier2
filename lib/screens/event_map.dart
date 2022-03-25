import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:marker_icon/marker_icon.dart';
import 'package:provider/provider.dart';
import 'package:reunionou/data/users_collection.dart';
import 'package:reunionou/data/api_call.dart';

const maxMarkersCount = 5000;

class EventMap extends StatefulWidget {
  EventMap({Key? key}) : super(key: key);
  final latLng = LatLng(51.5, -0.09);

  @override
  _ManyMarkersPageState createState() => _ManyMarkersPageState();
}

class _ManyMarkersPageState extends State<EventMap> {
  List<Marker> allMarkers = [];
  List<ListTile> allMessages = [];
  String libelle = '';
  double doubleInRange(Random source, num start, num end) =>
      source.nextDouble() * (end - start) + start;

  generateComments() {
    Future.microtask(() {
      for (var element in UserCollection.messages) {
        allMessages.add(
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Map'),
          ),
        );
      }
    });
  }

  @override
  void initState() {
    generateComments();
    Future.microtask(() {
      for (var element in UserCollection.marker) {
        print('test');
        allMarkers.add(
          Marker(
              point: LatLng(
                  double.parse(element['lat']), double.parse(element['long'])),
              builder: (BuildContext ctx) {
                return Consumer<UserCollection>(
                  builder: (context, userCollection, child) {
                    return GestureDetector(
                      onTap: () {
                        hideWidget();
                        userCollection.setLibelleLieu(element['libelle_lieu']);
                        userCollection
                            .setlibelleEvent(element['libelle_event']);
                        userCollection.setHoraireEvent(element['horaire']);
                        userCollection.setDateEvent(element['date']);
                        userCollection.setIdEvent(element['id']);
                        ApiCall.getComment(userCollection.id_event)
                            .then((value) {
                          print(value);
                        });
                      },
                      child: Icon(
                        Icons.circle,
                        color: Colors.red,
                        size: 12.0,
                      ),
                    );
                  },
                );
              }),
        );
        print(allMarkers);
      }
      setState(() {});
    });
  }

  bool _canShowButton = false;
  void hideWidget() {
    setState(() {
      _canShowButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserCollection>(builder: (context, userCollection, child) {
      return Scaffold(
          appBar: AppBar(title: Text(userCollection.title)),
          body: Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                Expanded(
                    child: Container(
                        width: double.infinity,
                        height: 300,
                        child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(50.5, -0.09),
                              zoom: 5.0,
                            ),
                            layers: [
                              TileLayerOptions(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c'],
                              ),
                              MarkerLayerOptions(
                                markers: allMarkers,
                              )
                            ]))),
                Container(
                    alignment: Alignment.center,
                    color: Colors.blue,
                    child: Column(children: <Widget>[
                      !_canShowButton
                          ? const SizedBox.shrink()
                          : Text(
                              userCollection.libelleLieu +
                                  "\n" +
                                  userCollection.libelle_event +
                                  "\n" +
                                  userCollection.horaire +
                                  "\n" +
                                  userCollection.date,
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontWeight: FontWeight.bold),
                            ),
                      !_canShowButton
                          ? const SizedBox.shrink()
                          : ElevatedButton(
                              onPressed: () {
                                ApiCall.getVenir(userCollection.id_event);
                                //     .then((value) {

                                // });
                                // userCollection.setParticipe_event(
                                //     true, UserCollection.prenom);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                              ),
                              child: const Text('Je viens'),
                            ),
                      !_canShowButton
                          ? const SizedBox.shrink()
                          : ElevatedButton(
                              onPressed: () {
                                ApiCall.getVenir(UserCollection.id)
                                    .then((value) {
                                  print(value);
                                });

                                // userCollection.setParticipe_event(
                                //     false, UserCollection.prenom);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.red,
                              ),
                              child: const Text('désolé'),
                            ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/event_create');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                        child: const Text('Créer un event'),
                      ),
                    ])),
                // Expanded(
                //   child: ListView(
                //       scrollDirection: Axis.horizontal, children:const<Widget>[]),
                // ),
              ])));
    });
  }
}
