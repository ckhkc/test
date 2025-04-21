import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test/big_model.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  // Mock data for route history
  // List<Map<String, String>> routeHistory = [
  //   {
  //     'name': 'Office Trip',
  //     'destination': 'City Center',
  //     // 'duration': '25 min',
  //     // 'date': '2025-04-18',
  //   },
  //   {
  //     'name': 'Grocery Run',
  //     'destination': 'Mall',
  //     // 'duration': '15 min',
  //     // 'date': '2025-04-17',
  //   },
  //   {
  //     'name': 'Evening Walk',
  //     'destination': 'Park',
  //     // 'duration': '40 min',
  //     // 'date': '2025-04-16',
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<BigModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Route History'),
        backgroundColor: Colors.orange[700],
        elevation: 0,
      ),
      body:
          model.acceptHistory.isEmpty
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
                itemCount: model.acceptHistory.length,
                itemBuilder: (context, index) {
                  final route = model.acceptHistory[index];
                  return HistoryRouteCard(route: route, index: index);
                },
              ),
    );
  }
}

class HistoryRouteCard extends StatefulWidget {
  final Map<String, String> route;
  final int index;

  HistoryRouteCard({required this.route, required this.index});

  @override
  _HistoryRouteCardState createState() => _HistoryRouteCardState();
}

class _HistoryRouteCardState extends State<HistoryRouteCard> {
  late bool isFavorite;
  late BigModel _bigModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bigModel = Provider.of<BigModel>(context, listen: true);
    isFavorite = _bigModel.isFavorite(widget.route['name']!);
  }

  void toggleFavorite() {
    if (isFavorite) {
      _bigModel.removeFavorite(widget.route['name']!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.route['name']} removed from favorites'),
        ),
      );
    } else {
      _bigModel.addFavorite(widget.route);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.route['name']} added to favorites')),
      );
    }
    // No need for setState - the provider will trigger rebuild
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<BigModel>(context);
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
              Container(width: 2, height: 100, color: Colors.orange[300]),
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
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => {toggleFavorite()},
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text('details: ${model.acceptHistory}'),
                      // Text(
                      //   'To: ${widget.route['destination']}',
                      //   style: TextStyle(fontSize: 14, color: Colors.black87),
                      // ),
                      // Text(
                      //   'Date: ${widget.route['date']}',
                      //   style: TextStyle(fontSize: 14, color: Colors.black87),
                      // ),
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
