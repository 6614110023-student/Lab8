import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const MovieRankerApp());

class Movie {
  String name;
  String description;
  String? imagePath; // Local file path

  Movie({required this.name, required this.description, this.imagePath});
}

class MovieRankerApp extends StatelessWidget {
  const MovieRankerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});
  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final List<Movie> _movies = [];

  void _showMovieDialog({Movie? movie, int? index}) {
    final nameController = TextEditingController(text: movie?.name ?? "");
    final descController = TextEditingController(text: movie?.description ?? "");
    String? selectedPath = movie?.imagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder( // StatefulBuilder allows updating dialog UI
        builder: (context, setDialogState) => AlertDialog(
          title: Text(movie == null ? "Add Movie" : "Edit Movie"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Movie Name")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
                const SizedBox(height: 20),
                
                // Drag and Drop Zone
                DropTarget(
                  onDragDone: (detail) {
                    setDialogState(() => selectedPath = detail.files.first.path);
                  },
                  child: GestureDetector(
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null) {
                        setDialogState(() => selectedPath = result.files.single.path);
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.blueAccent, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedPath == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Icon(Icons.upload_file), Text("Drag & Drop or Click to Upload")],
                            )
                          : Image.file(File(selectedPath!), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  final newMovie = Movie(name: nameController.text, description: descController.text, imagePath: selectedPath);
                  if (movie == null) {
                    _movies.add(newMovie);
                  } else {
                    _movies[index!] = newMovie;
                  }
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Windows Movie Ranker"),
        actions: [IconButton(icon: const Icon(Icons.delete_forever), onPressed: () => setState(() => _movies.clear()))],
      ),
      body: ReorderableListView.builder(
        itemCount: _movies.length,
        onReorder: (oldIdx, newIdx) {
          setState(() {
            if (newIdx > oldIdx) newIdx -= 1;
            _movies.insert(newIdx, _movies.removeAt(oldIdx));
          });
        },
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return Dismissible(
            key: ValueKey(movie.name + index.toString()),
            background: Container(color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
            onDismissed: (_) => setState(() => _movies.removeAt(index)),
            child: Card(
              key: ValueKey(movie),
              child: ListTile(
                leading: CircleAvatar(child: Text("${index + 1}")),
                title: Text(movie.name),
                subtitle: Text(movie.description),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      if (movie.imagePath != null) 
                        Image.file(File(movie.imagePath!), width: 40, height: 40, fit: BoxFit.cover)
                      else 
                        const Icon(Icons.image_not_supported),
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => _showMovieDialog(movie: movie, index: index)),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showMovieDialog(), child: const Icon(Icons.add)),
    );
  }
}