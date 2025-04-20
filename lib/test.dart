import 'package:flutter/material.dart';

// Favorites Model to manage favorite routes
class FavoritesModel extends ChangeNotifier {
  List<Map<String, String>> _favorites = [];

  List<Map<String, String>> get favorites => _favorites;

  void addFavorite(Map<String, String> route) {
    if (!_favorites.any((r) => r['name'] == route['name'])) {
      _favorites.add(Map.from(route));
      notifyListeners();
    }
  }

  void removeFavorite(String routeName) {
    _favorites.removeWhere((r) => r['name'] == routeName);
    notifyListeners();
  }

  bool isFavorite(String routeName) {
    return _favorites.any((r) => r['name'] == routeName);
  }
}

// Main app
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FavoritesModel favoritesModel = FavoritesModel();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: Colors.yellow[50],
      ),
      home: HomePage(favoritesModel: favoritesModel),
    );
  }
}

// Home page with navigation
class HomePage extends StatefulWidget {
  final FavoritesModel favoritesModel;

  HomePage({required this.favoritesModel});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      RouteHistoryPage(favoritesModel: widget.favoritesModel),
      FavoriteRoutesPage(favoritesModel: widget.favoritesModel),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.orange[300],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

// Route History Page
class RouteHistoryPage extends StatelessWidget {
  final FavoritesModel favoritesModel;

  RouteHistoryPage({required this.favoritesModel});

  // Mock data for route history
  final List<Map<String, String>> routeHistory = [
    {
      'name': 'Office Trip',
      'destination': 'City Center',
      'duration': '25 min',
      'date': '2025-04-18'
    },
    {
      'name': 'Grocery Run',
      'destination': 'Mall',
      'duration': '15 min',
      'date': '2025-04-17'
    },
    {
      'name': 'Evening Walk',
      'destination': 'Park',
      'duration': '40 min',
      'date': '2025-04-16'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Route History'),
        backgroundColor: Colors.orange[700],
        elevation: 0,
      ),
      body: routeHistory.isEmpty
          ? Center(
              child: Text(
                'No route history yet!',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.red[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: routeHistory.length,
              itemBuilder: (context, index) {
                final route = routeHistory[index];
                return HistoryRouteCard(
                  route: route,
                  index: index,
                  favoritesModel: favoritesModel,
                );
              },
            ),
    );
  }
}

class HistoryRouteCard extends StatefulWidget {
  final Map<String, String> route;
  final int index;
  final FavoritesModel favoritesModel;

  HistoryRouteCard({
    required this.route,
    required this.index,
    required this.favoritesModel,
  });

  @override
  _HistoryRouteCardState createState() => _HistoryRouteCardState();
}

class _HistoryRouteCardState extends State<HistoryRouteCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.favoritesModel.isFavorite(widget.route['name']!);
    widget.favoritesModel.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    widget.favoritesModel.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    setState(() {
      isFavorite = widget.favoritesModel.isFavorite(widget.route['name']!);
    });
  }

  void toggleFavorite() {
    if (isFavorite) {
      widget.favoritesModel.removeFavorite(widget.route['name']!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.route['name']} removed from favorites')),
      );
    } else {
      widget.favoritesModel.addFavorite(widget.route);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.route['name']} added to favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot and line
          Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.redAccent,
                ),
              ),
              Container(
                width: 2,
                height: 100,
                color: Colors.orange[300],
              ),
            ],
          ),
          SizedBox(width: 16),
          // Route details
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RouteDetailsPage(route: widget.route),
                  ),
                );
              },
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.yellow[200]!, Colors.orange[300]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.route['name']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: Colors.redAccent,
                            ),
                            onPressed: toggleFavorite,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'To: ${widget.route['destination']}',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        'Date: ${widget.route['date']}',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      Text(
                        'Duration: ${widget.route['duration']}',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Favorite Routes Page
class FavoriteRoutesPage extends StatelessWidget {
  final FavoritesModel favoritesModel;

  FavoriteRoutesPage({required this.favoritesModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Routes'),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: favoritesModel,
        builder: (context, _) {
          return favoritesModel.favorites.isEmpty
              ? Center(
                  child: Text(
                    'No favorite routes yet!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: favoritesModel.favorites.length,
                  itemBuilder: (context, index) {
                    final route = favoritesModel.favorites[index];
                    return FavoriteRouteCard(
                      route: route,
                      favoritesModel: favoritesModel,
                    );
                  },
                );
        },
      ),
    );
  }
}

class FavoriteRouteCard extends StatefulWidget {
  final Map<String, String> route;
  final FavoritesModel favoritesModel;

  FavoriteRouteCard({required this.route, required this.favoritesModel});

  @override
  _FavoriteRouteCardState createState() => _FavoriteRouteCardState();
}

class _FavoriteRouteCardState extends State<FavoriteRouteCard> {
  bool isFavorite = true;

  void toggleFavorite() {
    widget.favoritesModel.removeFavorite(widget.route['name']!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.route['name']} removed from favorites')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RouteDetailsPage(route: widget.route),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[300]!, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.route['name']!,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'To: ${widget.route['destination']}',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  Text(
                    'Duration: ${widget.route['duration']}',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                ),
                onPressed: toggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Route Details Page (Placeholder)
class RouteDetailsPage extends StatelessWidget {
  final Map<String, String> route;

  RouteDetailsPage({required this.route});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${route['name']} Details'),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Text(
          'Details for ${route['name']} to ${route['destination']}',
          style: TextStyle(fontSize: 18, color: Colors.black87),
        ),
      ),
    );
  }
}