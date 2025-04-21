import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:test/big_model.dart';

class RouteSuggestionDialog extends StatefulWidget {
  // late BigModel model;
  bool isVisible;
  final VoidCallback onClose;

  RouteSuggestionDialog({
    Key? key,
    required this.isVisible,
    required this.onClose,
  }) : super(key: key);

  @override
  State<RouteSuggestionDialog> createState() => _RouteSuggestionDialogState();
}

class _RouteSuggestionDialogState extends State<RouteSuggestionDialog>
    with TickerProviderStateMixin {
  late AnimationController _enterController;
  late AnimationController _showController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Now 'this' is a valid TickerProvider
    _enterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this, // This now works correctly
    );

    _showController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this, // This now works correctly
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _enterController.dispose();
    _showController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<BigModel>(context);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: widget.isVisible ? 0 : -300,
      top: 0,
      bottom: 0,
      width: 300,
      child: Material(
        elevation: 8,
        color: Colors.white,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // New Back Button (conditionally shown)
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.black54,
                        ), // <- New icon
                        onPressed: () {
                          model.goBackStaticPoints();
                        },
                      ),

                      // Title (now centered with Expanded)
                      Expanded(
                        // <- Wrapped in Expanded
                        child: Consumer<BigModel>(
                          builder:
                              (context, model, child) =>
                                  model.curK > model.totalK
                                      ? Text(
                                        'Completed all ${model.totalK} steps! Time left (mins): ${(model.timeCredit / 60).toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ), // Optional styling
                                      )
                                      : Text(
                                        // Default text
                                        'The ${model.curK}-th step, with ${(model.timeCredit / 60).toStringAsFixed(2)} mins.',
                                      ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                ),
                // Scrollable Content
                Expanded(
                  child:
                      model.staticPointsList.isEmpty
                          ? const Center(child: Text("No items available"))
                          : model.curK > model.totalK
                          ? Center(
                            child: Column(
                              children: [
                                Text(
                                  "The Travel is planned, please enjoy it!.",
                                ),
                                SizedBox(height: 18),
                                ElevatedButton(
                                  onPressed: () => model.onAccept(),
                                  child: Text("Accept"),
                                ),
                              ],
                            ),
                          )
                          : model.staticPointsList.last.isEmpty
                          ? Center(
                            child: Text(
                              textAlign: TextAlign.center,
                              'You may want to reduce no. of steps, or increase time budget......',
                            ),
                          )
                          : ListView.builder(
                            itemCount: model.staticPointsList.last.length,
                            itemBuilder: (context, index) {
                              final itemText =
                                  model.staticPointsList.last[index];
                              return _buildMenuItem(
                                icon: Icons.category,
                                title: itemText['location'] as String,
                                onTap: () async {
                                  debugPrint("Clicked: $itemText");
                                  _navigateForward();
                                  String district = itemText['location'];

                                  final loadingCompleter = Completer<void>();
                                  late BuildContext loadingContext;

                                  // Show loading indicator
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      loadingContext = context;
                                      loadingCompleter.complete();
                                      return AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 16),
                                            Text(
                                              'Finding reachable locations...',
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  // Wait for dialog to be fully shown
                                  await loadingCompleter.future;

                                  try {
                                    // Prepare request data
                                    final requestData = {'district': district};

                                    // Create the HTTP request future
                                    final requestFuture = http.post(
                                      Uri.parse(
                                        'http://localhost:5000/restaurants',
                                      ), // Use 10.0.2.2 for Android emulator
                                      headers: {
                                        'Content-Type': 'application/json',
                                      },
                                      body: json.encode(requestData),
                                    );

                                    // Create timeout future
                                    final timeoutFuture = Future.delayed(
                                      Duration(seconds: 3),
                                    ).then((_) {
                                      throw TimeoutException(
                                        'Request timed out after 3 seconds',
                                      );
                                    });

                                    // Race the request against timeout
                                    final response = await Future.any([
                                      requestFuture,
                                      timeoutFuture,
                                    ]);

                                    // Close loading dialog
                                    if (Navigator.of(loadingContext).canPop()) {
                                      Navigator.of(loadingContext).pop();
                                    }

                                    // Process successful response
                                    if (response.statusCode == 200) {
                                      model.selectedSP.add(district);
                                      final dynamic decodedJson = json.decode(
                                        response.body,
                                      );
                                      final List<dynamic> restaurants =
                                          decodedJson['restaurants'] as List? ??
                                          [];

                                      if (restaurants.isEmpty) {
                                        showDialog(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: Text('Error'),
                                                content: Text(
                                                  'This $district is not currently available.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(),
                                                    child: Text('OK'),
                                                  ),
                                                ],
                                              ),
                                        );
                                      } else {
                                        final List<Map<String, dynamic>>
                                        restaurantList =
                                            restaurants
                                                .cast<Map<dynamic, dynamic>>()
                                                .map(
                                                  (e) =>
                                                      e.cast<String, dynamic>(),
                                                )
                                                .toList();
                                        // print(restaurants);
                                        // print(restaurantList);
                                        model.setRestaurants(restaurantList);
                                        model.showRestaurants();
                                      }
                                    } else {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              title: Text('Error'),
                                              content: Text(
                                                'Server returned error: ${response.statusCode} ${response.body}',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () =>
                                                          Navigator.of(
                                                            context,
                                                          ).pop(),
                                                  child: Text('OK'),
                                                ),
                                              ],
                                            ),
                                      );
                                    }
                                  } on TimeoutException {
                                    if (Navigator.of(loadingContext).canPop()) {
                                      Navigator.of(loadingContext).pop();
                                    }
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text('Timeout'),
                                            content: Text(
                                              'Request timed out after 3 seconds',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                    );
                                  } catch (e) {
                                    if (Navigator.of(loadingContext).canPop()) {
                                      Navigator.of(loadingContext).pop();
                                    }
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: Text('Error'),
                                            content: Text(
                                              'An error occurred: ${e.toString()}',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.of(
                                                          context,
                                                        ).pop(),
                                                child: Text('OK'),
                                              ),
                                            ],
                                          ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateForward() async {
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _enterController, curve: Curves.easeInOut),
    );

    _enterController.reset();
    await _enterController.forward();
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      hoverColor: Colors.grey[100],
    );
  }

  Future<void> sendRestaurantRequest(String district) async {
    // Create a Completer to track when loading dialog is shown
    // final model = Provider.of<BigModel>(context);
  }
}
