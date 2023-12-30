import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Album>> fetchAlbum() async {
  final response =
      await http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums'));

  if (response.statusCode == 200) {
    List<dynamic> data = jsonDecode(response.body);
    List<Album> albums = data.map((item) => Album.fromJson(item)).toList();
    return albums;
  } else {
    throw Exception('Failed to load album');
  }
}

Future<void> addAlbum(String title) async {
  final response = await http.post(
    Uri.parse('https://jsonplaceholder.typicode.com/albums'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'title': title,
      'userId': 1,
    }),
  );

  if (response.statusCode == 201) {
    print('ALBUM CREATED');
  } else {
    throw Exception('Failed to add album');
  }
}

Future<void> deleteAlbum(int id) async {
  final response = await http.delete(
    Uri.parse('https://jsonplaceholder.typicode.com/albums/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );

  if (response.statusCode == 200) {
    print('Album deleted successfully');
  } else {
    throw Exception('Failed to delete album');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Album>> futureAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Album- Networking Data',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Album- Networking Data'),
        ),
        body: Center(
          child: FutureBuilder<List<Album>>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Column(
                        children: [
                          Text("ID : ${snapshot.data![index].id.toString()}"),
                          Text(
                            snapshot.data![index].title,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      titleTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _showDeleteConfirmationDialog(
                              context, snapshot.data![index].id);
                        },
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const CircularProgressIndicator();
            },
          ),
        ),
        floatingActionButton: Builder(
          builder: (BuildContext context) {
            return FloatingActionButton(
              onPressed: () {
                _showAddAlbumDialog(context);
              },
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }

  void _showAddAlbumDialog(BuildContext context) {
    TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Album'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  await addAlbum(titleController.text);
                  setState(() {
                    futureAlbum = fetchAlbum();
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Album'),
          content: const Text('Are you sure you want to delete this album?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await deleteAlbum(id);
                setState(() {
                  futureAlbum = fetchAlbum();
                });
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
