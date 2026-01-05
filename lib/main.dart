import 'package:flutter/material.dart';

void main() {
  runApp(const MovieRankerApp());
}

class Movie {
  String name;
  String description;
  String imageUrl;

  Movie({required this.name, required this.description, required this.imageUrl});
}

class MovieRankerApp extends StatelessWidget {
  const MovieRankerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
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
  final List<Movie> _movies = [
    Movie(name: "Inception", description: "Dream within a dream.", imageUrl: "https://via.placeholder.com/150"),
    Movie(name: "Interstellar", description: "Space and time travel.", imageUrl: "https://via.placeholder.com/150"),
  ];

  // Function to show Add/Edit Dialog
  void _showMovieDialog({Movie? movie, int? index}) {
    final nameController = TextEditingController(text: movie?.name ?? "");
    final descController = TextEditingController(text: movie?.description ?? "");
    final imgController = TextEditingController(text: movie?.imageUrl ?? "https://via.placeholder.com/150");

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(movie == null ? "Add New Movie" : "Edit Movie"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Movie Name")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: imgController, decoration: const InputDecoration(labelText: "Image URL")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (movie == null) {
                  _movies.add(Movie(name: nameController.text, description: descController.text, imageUrl: imgController.text));
                } else {
                  _movies[index!] = Movie(name: nameController.text, description: descController.text, imageUrl: imgController.text);
                }
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movie Rankings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => setState(() => _movies.clear()),
            tooltip: "Clear All",
          )
        ],
      ),
      body: _movies.isEmpty
          ? const Center(child: Text("No movies in the list. Add some!"))
          : ReorderableListView.builder(
              itemCount: _movies.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _movies.removeAt(oldIndex);
                  _movies.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final movie = _movies[index];
                return Dismissible(
                  key: ValueKey(movie.name + index.toString()),
                  background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                  onDismissed: (direction) {
                    setState(() => _movies.removeAt(index));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${movie.name} removed")));
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Text("#${index + 1}", style: const TextStyle(color: Colors.white)),
                      ),
                      title: Text(movie.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(movie.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.network(movie.imageUrl, width: 40, errorBuilder: (c, e, s) => const Icon(Icons.movie)),
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _showMovieDialog(movie: movie, index: index)),
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