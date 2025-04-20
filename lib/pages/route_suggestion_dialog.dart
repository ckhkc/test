import 'package:flutter/material.dart';
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

class _RouteSuggestionDialogState extends State<RouteSuggestionDialog> {
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
                      onPressed:
                          () =>
                              model
                                  .goBackStaticPoints(), // <- Uses the new callback
                    ),

                    // Title (now centered with Expanded)
                    Expanded(
                      // <- Wrapped in Expanded
                      child: Consumer<BigModel>(
                        builder:
                            (context, model, child) => Text(
                              'The ${model.staticPointsList.length}-th activity',
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
                        : ListView.builder(
                          itemCount: model.staticPointsList.last.length,
                          itemBuilder: (context, index) {
                            final itemText = model.staticPointsList.last[index];
                            return _buildMenuItem(
                              icon: Icons.category,
                              title: itemText['location'] as String,
                              onTap: () {
                                debugPrint("Clicked: $itemText");
                                model.addStaticPoints(
                                  model.staticPointsList.last,
                                );
                              },
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
}
