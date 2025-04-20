import 'package:flutter/material.dart';
import 'package:test/big_model.dart';
import 'package:provider/provider.dart';

// Favorite Routes Page
class FavoritePage extends StatelessWidget {
  FavoritePage({super.key});
  late List<Map<String, String>> favoriteRoute = [];

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<BigModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Routes'),
        backgroundColor: Colors.redAccent,
        elevation: 0,
      ),
      body:
          model.favorites.isEmpty
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
                itemCount: model.favorites.length,
                itemBuilder: (context, index) {
                  final route = model.favorites[index];
                  return FavoriteRouteCard(route: route, index: index);
                },
              ),
      // },
      // ),
    );
  }
}

class FavoriteRouteCard extends StatefulWidget {
  final Map<String, String> route;
  final int index;

  FavoriteRouteCard({required this.route, required this.index});

  @override
  _FavoriteRouteCardState createState() => _FavoriteRouteCardState();
}

class _FavoriteRouteCardState extends State<FavoriteRouteCard> {
  bool isFavorite = true;
  late BigModel _bigModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bigModel = Provider.of<BigModel>(context, listen: true);
    isFavorite = _bigModel.isFavorite(widget.route['name']!);
  }

  void toggleFavorite() {
    _bigModel.removeFavorite(widget.route['name']!);
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
