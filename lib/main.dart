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
        scaffoldBackgroundColor: const Color(0xFF060B14),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      home: const PokemonPage(),
    );
  }
}

// ── Type color map ─────────────────────────────────────────────────────────────
Color typeColor(String type) {
  const colors = {
    'fire': Color(0xFFFF6B35),
    'water': Color(0xFF00B4D8),
    'grass': Color(0xFF57CC99),
    'electric': Color(0xFFFFD60A),
    'psychic': Color(0xFFFF477E),
    'ice': Color(0xFF90E0EF),
    'dragon': Color(0xFF7B2FBE),
    'dark': Color(0xFF3D405B),
    'fairy': Color(0xFFFF85A1),
    'normal': Color(0xFF9B9B7A),
    'fighting': Color(0xFFD62828),
    'flying': Color(0xFF89C2D9),
    'poison': Color(0xFF9B5DE5),
    'ground': Color(0xFFE9C46A),
    'rock': Color(0xFFA49966),
    'bug': Color(0xFF80B918),
    'ghost': Color(0xFF560BAD),
    'steel': Color(0xFF8ECAE6),
  };
  return colors[type] ?? const Color(0xFF6B7280);
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> pokemons = [];
  int offset = 0;
  bool isLoading = false;

  // ── Search state ─────────────────────────────────────────────────────────────
  Map<String, dynamic>? _searchResult;
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    loadMorePokemons();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        loadMorePokemons();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Load list (infinite scroll, 5 by 5) ─────────────────────────────────────
  Future<void> loadMorePokemons() async {
    if (isLoading) return;
    setState(() => isLoading = true);

    for (int i = offset + 1; i <= offset + 5; i++) {
      final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$i'),
      );
      if (response.statusCode == 200) {
        pokemons.add(jsonDecode(response.body));
      }
    }
    offset += 5;
    setState(() => isLoading = false);
  }

  // ── Search by name ────────────────────────────────────────────────────────────
  Future<void> searchPokemon() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResult = null;
      _searchError = null;
    });

    try {
      final url = Uri.parse(
        'https://pokeapi.co/api/v2/pokemon/${name.toLowerCase()}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _searchResult = jsonDecode(response.body);
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchError = 'Pokémon "$name" no encontrado';
          _isSearching = false;
        });
      }
    } catch (_) {
      setState(() {
        _searchError = 'Error de conexión';
        _isSearching = false;
      });
    }
  }

  void clearSearch() {
    _controller.clear();
    setState(() {
      _searchResult = null;
      _searchError = null;
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────
  String spriteUrl(Map<String, dynamic> pokemon) {
    return pokemon['sprites']['other']['official-artwork']['front_default'] ??
        pokemon['sprites']['front_default'] ??
        '';
  }

  List<String> types(Map<String, dynamic> pokemon) {
    return (pokemon['types'] as List)
        .map((t) => t['type']['name'] as String)
        .toList();
  }

  // ── Stat bar ──────────────────────────────────────────────────────────────────
  Widget _statBar(String label, int value, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              label,
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 36,
            child: Text(
              value.toString(),
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (value / 255).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.white10,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search result card ────────────────────────────────────────────────────────
  Widget _searchCard(Map<String, dynamic> pokemon) {
    final pokemonTypes = types(pokemon);
    final primaryType = pokemonTypes.isNotEmpty ? pokemonTypes[0] : 'normal';
    final accent = typeColor(primaryType);
    final stats = pokemon['stats'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            accent.withOpacity(0.18),
            const Color(0xFF0D1B2A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent, width: 1.5),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(0.3), blurRadius: 20, spreadRadius: 2),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                // Image
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withOpacity(0.12),
                  ),
                  child: Image.network(spriteUrl(pokemon), fit: BoxFit.contain),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${pokemon['id'].toString().padLeft(3, '0')}',
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        (pokemon['name'] as String).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: pokemonTypes.map((t) {
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: typeColor(t).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: typeColor(t).withOpacity(0.6)),
                            ),
                            child: Text(
                              t.toUpperCase(),
                              style: TextStyle(
                                color: typeColor(t),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _infoChip(
                              '⚖ ${(pokemon['weight'] / 10).toStringAsFixed(1)} kg',
                              accent),
                          const SizedBox(width: 8),
                          _infoChip(
                              '📏 ${(pokemon['height'] / 10).toStringAsFixed(1)} m',
                              accent),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BASE STATS',
                  style: TextStyle(
                    color: accent,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...stats.map((s) => _statBar(
                      (s['stat']['name'] as String)
                          .replaceAll('special-', 'sp.')
                          .toUpperCase(),
                      s['base_stat'] as int,
                      accent,
                    )),
              ],
            ),
          ),
          // Close button
          TextButton(
            onPressed: clearSearch,
            child: Text(
              '← VOLVER AL LISTADO',
              style: TextStyle(
                color: accent,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _infoChip(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
    );
  }

  // ── List card ─────────────────────────────────────────────────────────────────
  Widget _listCard(Map<String, dynamic> pokemon) {
    final pokemonTypes = types(pokemon);
    final primaryType = pokemonTypes.isNotEmpty ? pokemonTypes[0] : 'normal';
    final accent = typeColor(primaryType);

    return GestureDetector(
      onTap: () {
        _controller.text = pokemon['name'];
        searchPokemon();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              accent.withOpacity(0.10),
              const Color(0xFF0D1B2A),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border.all(color: accent.withOpacity(0.4), width: 1),
        ),
        child: Row(
          children: [
            // Sprite
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.10),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
              child: Image.network(spriteUrl(pokemon), fit: BoxFit.contain),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '#${pokemon['id'].toString().padLeft(3, '0')}',
                    style: TextStyle(
                      color: accent,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    (pokemon['name'] as String).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: pokemonTypes.map((t) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor(t).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: typeColor(t).withOpacity(0.5), width: 1),
                        ),
                        child: Text(
                          t.toUpperCase(),
                          style: TextStyle(
                            color: typeColor(t),
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.chevron_right, color: accent.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF060B14),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.redAccent.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.catching_pokemon, color: Colors.redAccent, size: 28),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.redAccent, Colors.amberAccent],
              ).createShader(bounds),
              child: const Text(
                'POKÉDEX',
                style: TextStyle(
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF060B14), Color(0xFF0D1B2A), Color(0xFF060B14)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            children: [
              // ── Search bar ──────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.redAccent.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Buscar por nombre...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 14,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    prefixIcon: const Icon(Icons.search, color: Colors.redAccent),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: Colors.white38, size: 18),
                            onPressed: clearSearch,
                          ),
                        IconButton(
                          icon: _isSearching
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.amberAccent,
                                  ),
                                )
                              : const Icon(Icons.arrow_forward,
                                  color: Colors.amberAccent),
                          onPressed: _isSearching ? null : searchPokemon,
                        ),
                      ],
                    ),
                  ),
                  onSubmitted: (_) => searchPokemon(),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 16),

              // ── Content ─────────────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _searchResult != null || _searchError != null
                      ? (_searchResult != null ? 1 : 1)
                      : pokemons.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Search result or error
                    if (_searchResult != null) {
                      return _searchCard(_searchResult!);
                    }
                    if (_searchError != null) {
                      return _errorCard(_searchError!);
                    }

                    // Loader
                    if (index >= pokemons.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              CircularProgressIndicator(
                                color: Colors.redAccent,
                                strokeWidth: 2,
                              ),
                              SizedBox(height: 10),
                              Text(
                                'CARGANDO...',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 10,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return _listCard(pokemons[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorCard(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
        color: Colors.redAccent.withOpacity(0.08),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: clearSearch,
            child: const Text(
              '← VOLVER',
              style: TextStyle(
                color: Colors.redAccent,
                letterSpacing: 2,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}