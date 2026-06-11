# 📱 Pokédex Gamer — Flutter App

Una aplicación móvil construida con **Flutter** que consume la [PokéAPI](https://pokeapi.co/) para explorar el mundo Pokémon.

---

## 🖼️ Vista general

La app presenta un listado infinito de Pokémon con sus sprites oficiales, tipos coloreados y estadísticas base. El usuario puede buscar cualquier Pokémon por nombre para ver su ficha completa.

<img width="715" height="1600" alt="WhatsApp Image 2026-06-11 at 3 42 22 PM" src="https://github.com/user-attachments/assets/90cacc56-cb21-4ab4-9961-2c94553bd384" />

<img width="715" height="1600" alt="WhatsApp Image 2026-06-11 at 3 42 25 PM" src="https://github.com/user-attachments/assets/fd5a2fdf-14fc-4966-ae6a-1d01b95d65b6" />

---

## ✅ Funcionalidades implementadas

| # | Funcionalidad | Estado |
|---|---|---|
| 1 | Listado de al menos 10 Pokémon | ✅ |
| 2 | Infinite scrolling (carga de 5 en 5) | ✅ |
| 3 | Búsqueda por nombre | ✅ |
| 4 | Ficha detallada con stats | ✅ |
| 5 | Colores por tipo de Pokémon | ✅ |

---

## 🚀 Cómo ejecutar el proyecto

### Requisitos previos

- [Flutter SDK](https://flutter.dev/docs/get-started/install) `^3.12.1`
- Dart SDK (incluido con Flutter)
- Android Studio o VS Code con extensión de Flutter
- Un emulador Android/iOS o dispositivo físico conectado

## 📁 Estructura del proyecto

```
pokedex-gamer/
├── android/                        # Configuración nativa Android
│   ├── app/
│   │   ├── build.gradle.kts        # Config de build Android
│   │   └── src/
│   │       ├── main/
│   │       │   ├── AndroidManifest.xml
│   │       │   └── kotlin/.../MainActivity.kt
│   │       ├── debug/AndroidManifest.xml
│   │       └── profile/AndroidManifest.xml
│   ├── build.gradle.kts
│   ├── gradle.properties
│   └── settings.gradle.kts
├── lib/
│   └── main.dart                   # ⭐ Código principal de la app
├── web/
│   ├── index.html
│   └── manifest.json
├── test/
│   └── widget_test.dart
├── pubspec.yaml                    # Dependencias del proyecto
└── README.md
```

---

## 🧩 Arquitectura

La app usa una arquitectura simple de **StatefulWidget** en un único archivo `main.dart`, organizada en las siguientes responsabilidades:

```
PokemonApp (StatelessWidget)
└── MaterialApp
    └── PokemonPage (StatefulWidget)
        └── _PokemonPageState
            ├── Estado
            │   ├── pokemons[]         → lista acumulada del scroll infinito
            │   ├── offset             → cursor de paginación
            │   ├── isLoading          → loader del scroll
            │   ├── _searchResult      → resultado de búsqueda activo
            │   ├── _isSearching       → spinner de búsqueda
            │   └── _searchError       → mensaje de error
            ├── Métodos
            │   ├── loadMorePokemons() → carga 5 pokémon desde la API
            │   ├── searchPokemon()    → busca por nombre
            │   └── clearSearch()      → vuelve al listado
            └── Widgets
                ├── _listCard()        → tarjeta del listado
                ├── _searchCard()      → ficha de detalle
                ├── _statBar()         → barra de estadística
                ├── _infoChip()        → chip de peso/altura
                └── _errorCard()       → pantalla de error
```

---

## 🌐 API utilizada

**[PokéAPI](https://pokeapi.co/)** — API REST pública, gratuita y sin autenticación.

### Endpoints consumidos

| Propósito | Endpoint |
|---|---|
| Cargar Pokémon por ID | `GET https://pokeapi.co/api/v2/pokemon/{id}` |
| Buscar Pokémon por nombre | `GET https://pokeapi.co/api/v2/pokemon/{name}` |

### Campos utilizados de la respuesta

```json
{
  "id": 25,
  "name": "pikachu",
  "height": 4,
  "weight": 60,
  "types": [{ "type": { "name": "electric" } }],
  "stats": [{ "base_stat": 35, "stat": { "name": "hp" } }],
  "sprites": {
    "other": {
      "official-artwork": {
        "front_default": "https://..."
      }
    }
  }
}
```

---

## ♾️ Infinite Scrolling

La carga paginada funciona así:

1. Al iniciar la app, `loadMorePokemons()` carga los Pokémon con IDs del 1 al 5.
2. El `ScrollController` detecta cuando el usuario llega a 300px del final de la lista.
3. Se llama automáticamente `loadMorePokemons()`, que carga los siguientes 5 (IDs 6–10, luego 11–15, etc.).
4. Un indicador de carga (`CircularProgressIndicator`) aparece al final mientras se espera la respuesta.

```dart
_scrollController.addListener(() {
  if (_scrollController.position.pixels >=
      _scrollController.position.maxScrollExtent - 300) {
    loadMorePokemons();
  }
});
```

---

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.6.0              # Peticiones HTTP a PokéAPI

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

---
