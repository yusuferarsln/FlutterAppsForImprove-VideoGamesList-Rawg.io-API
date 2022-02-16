import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_games/models/description_model.dart';

class DetailsPage extends StatefulWidget {
  final String id;
  final String page;
  const DetailsPage({Key? key, required this.id, required this.page})
      : super(key: key);

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

int slideractiveindex = 0;
var urlImages = [];
var game = [];
var gameImages = [];
bool liked = false;
var uniqueGames = [];
var uniqueImages = [];
String? gameN;
String? gameImage;

class _DetailsPageState extends State<DetailsPage> {
  Future<descriptionGenerated> apiCall() async {
    final response = await http.get(Uri.parse(
        'https://api.rawg.io/api/games/${widget.id}?key=5ac29048d12d45d0949c77038115cb56&${widget.page}'));
    return descriptionGenerated.fromJson(jsonDecode(response.body));
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    uniqueGames.clear();
    uniqueImages.clear();
    CollectionReference firestoreRef = _firestore.collection('favGames');

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: detailsFutureBuilder(),
      ),
    );
  }

  FutureBuilder<descriptionGenerated> detailsFutureBuilder() {
    return FutureBuilder<descriptionGenerated>(
        future: apiCall(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          descriptionGenerated? data = snapshot.data;
          String? image = data!.backgroundImage;

          gameN = data.name;
          game.add(data.name);
          gameImage = data.backgroundImage;
          gameImages.add(data.backgroundImage);

          uniqueImages = gameImages.toSet().toList();
          uniqueGames = game.toSet().toList();

          if (snapshot.hasData == false) {
            return CircularProgressIndicator();
          } else {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                        child: CachedNetworkImage(
                      imageUrl: image.toString(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      placeholder: (context, url) => Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )),
                    likeButton()
                  ],
                ),
                Card(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '${data.name}',
                          style: TextStyle(
                            fontSize: 30,
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Released Date : ${data.released}',
                            style: TextStyle(fontSize: 20),
                          )),
                      Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'Metacritic Rate : ${data.metacritic}',
                            style: TextStyle(fontSize: 16),
                          )),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${data.descriptionRaw}',
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }
        });
  }

  Positioned likeButton() {
    if (liked == false) {
      liked = false;
      return Positioned(
        child: InkWell(
          onTap: () {
            setState(() {
              liked = !liked;
              _firestore
                  .collection('favGames')
                  .doc('gameDetails')
                  .update({'game': uniqueGames, 'image': uniqueImages});
            });
          },
          child: Icon(
            Icons.favorite,
            size: 35,
            color: Colors.white,
          ),
        ),
        right: 20,
        bottom: 10,
      );
    } else {
      uniqueGames.remove(gameN);
      uniqueImages.remove(gameImage);
      return Positioned(
        child: InkWell(
          onTap: () {
            setState(() {
              liked = !liked;

              _firestore
                  .collection('favGames')
                  .doc('gameDetails')
                  .set({'game': uniqueGames, 'image': uniqueImages});
            });
          },
          child: Icon(
            Icons.favorite,
            size: 35,
            color: Colors.red,
          ),
        ),
        right: 20,
        bottom: 10,
      );
    }
  }
}

Widget buildImage(String? urlImage, int index) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 12),
    color: Colors.grey,
    child: Image.network(
      urlImage!,
      fit: BoxFit.cover,
    ),
  );
}

doNothing() {
  return null;
}
