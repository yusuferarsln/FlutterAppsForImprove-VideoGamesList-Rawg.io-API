import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_games/models/description_model.dart';
import 'package:http/http.dart' as http;

class FavoritePage extends StatefulWidget {
  final String? id;
  const FavoritePage({Key? key, this.id}) : super(key: key);

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  Future<descriptionGenerated> apiCall() async {
    final response = await http.get(Uri.parse(
        'https://api.rawg.io/api/games/${widget.id}?key=5ac29048d12d45d0949c77038115cb56'));
    return descriptionGenerated.fromJson(jsonDecode(response.body));
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    CollectionReference gameRef = _firestore.collection('favGames');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              favoritesListTileBuilder(gameRef),
            ],
          ),
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> favoritesListTileBuilder(
      CollectionReference<Object?> gameRef) {
    return StreamBuilder<QuerySnapshot>(
      stream: gameRef.snapshots(),
      builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
        List<DocumentSnapshot> listofDocumentSnap = asyncSnapshot.data.docs;
        List list = listofDocumentSnap[0]['game'];
        List imageList = listofDocumentSnap[0]['image'];

        return ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('${list[index]}'),
              leading: CircleAvatar(
                  maxRadius: 30,
                  backgroundImage:
                      CachedNetworkImageProvider('${imageList[index]}')),
            );
          },
        );
      },
    );
  }
}
