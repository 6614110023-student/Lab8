import 'dart:io';
import 'package:flutter/material.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const MovieRankerApp());

class Movie {
  String name;
  String description;
  String? imagePath;

  Movie({required this.name, required this.description, this.imagePath});
}

class MovieRankerApp extends StatelessWidget {
  const MovieRankerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.redAccent, brightness: Brightness.dark),
        useMaterial3: true,
      ),
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

  // Dialog for Adding/Editing
  void _showMovieDialog({Movie? movie, int? index}) {
    final nameController = TextEditingController(text: movie?.name ?? "");
    final descController = TextEditingController(text: movie?.description ?? "");
    String? selectedPath = movie?.imagePath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(movie == null ? "Add Movie" : "Edit Details"),
          content: SizedBox(
            width: 350,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Movie Title")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
                const SizedBox(height: 20),
                DropTarget(
                  onDragDone: (detail) => setDialogState(() => selectedPath = detail.files.first.path),
                  child: GestureDetector(
                    onTap: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
                      if (result != null) setDialogState(() => selectedPath = result.files.single.path);
                    },
                    child: Container(
                      height: 150,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        border: Border.all(color: Colors.redAccent, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: selectedPath == null
                          ? const Icon(Icons.add_a_photo, size: 30)
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(File(selectedPath!), fit: BoxFit.cover),
                            ),
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
                  final m = Movie(name: nameController.text, description: descController.text, imagePath: selectedPath);
                  movie == null ? _movies.add(m) : _movies[index!] = m;
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
        title: const Text("MOVIE RANKINGS"),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _movies.clear()),
            icon: const Icon(Icons.clear_all, color: Colors.white),
            label: const Text("Clear List", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            direction: DismissDirection.endToStart,
            onDismissed: (_) => setState(() => _movies.removeAt(index)),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete_sweep, size: 30),
            ),
            child: Card(
              key: ValueKey(movie),
              margin: const EdgeInsets.only(bottom: 15),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Large Poster Image on Left
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 90,
                          height: 130,
                          color: Colors.black38,
                          child: movie.imagePath != null
                              ? Image.file(File(movie.imagePath!), fit: BoxFit.cover)
                              : const Icon(Icons.movie, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Movie Details
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "#${index + 1} ${movie.name}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                          const SizedBox(height: 5),
                          Text(movie.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    // Action Buttons (Edit & Remove)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showMovieDialog(movie: movie, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            setState(() => _movies.removeAt(index));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${movie.name} deleted")),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.drag_handle, color: Colors.white24),
                    const SizedBox(width: 10),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMovieDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}