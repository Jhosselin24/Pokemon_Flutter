import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex Gamer',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        useMaterial3: true,
      ),
      home: const PokemonPage(),
    );
  }
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();

}

class _PokemonPageState extends State<PokemonPage> {
  final TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> pokemons = [];
  int offset = 0;
  bool isLoading = false;

  final ScrollController _scrollController = ScrollController();

  @override
void initState() {
  super.initState();

  loadMorePokemons();

  _scrollController.addListener(() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      loadMorePokemons();
    }
  });
}

  Future<void> loadMorePokemons() async {
  if (isLoading) return;

  setState(() {
    isLoading = true;
  });

  for (int i = offset + 1; i <= offset + 5; i++) {
    final response = await http.get(
      Uri.parse('https://pokeapi.co/api/v2/pokemon/$i'),
    );

    if (response.statusCode == 200) {
      pokemons.add(jsonDecode(response.body));
    }
  }

  offset += 5;

  setState(() {
    isLoading = false;
  });
}


  Future<Map<String, dynamic>> fetchPokemon(String name) async {
    final url = Uri.parse(
      'https://pokeapi.co/api/v2/pokemon/${name.toLowerCase()}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Pokémon no encontrado');
    }
  }

  void searchPokemon() {
    final name = _controller.text.trim();

    if (name.isEmpty) return;

    setState(() {
      _pokemonFuture = fetchPokemon(name);
    });
  }

  Widget infoRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.catching_pokemon,
              color: Colors.amber,
              size: 32,
            ),
            SizedBox(width: 10),
            Text(
              'POKÉDEX',
              style: TextStyle(
                letterSpacing: 3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.redAccent,
                    width: 2,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Buscar Pokémon...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    contentPadding: const EdgeInsets.all(18),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.amber,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Colors.redAccent,
                      ),
                      onPressed: searchPokemon,
                    ),
                  ),
                  onSubmitted: (_) => searchPokemon(),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
  child: ListView.builder(
    controller: _scrollController,
    itemCount: pokemons.length + (isLoading ? 1 : 0),
    itemBuilder: (context, index) {

      if (index >= pokemons.length) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final pokemon = pokemons[index];

      final name = pokemon['name'];
      final image =
          pokemon['sprites']['other']['official-artwork']
              ['front_default'];

      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A),
            ],
          ),
          border: Border.all(
            color: Colors.redAccent,
            width: 2,
          ),
        ),
        child: ListTile(
          leading: Image.network(
            image,
            width: 70,
          ),
          title: Text(
            name.toUpperCase(),
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            "ID: ${pokemon['id']}",
          ),
        ),
      );
    },
  ),
),  
            ],
          ),
        ),
      ),
    );
  }
}