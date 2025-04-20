import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPage();
}

class _HistoryPage extends State<HistoryPage> {
  // Sample data for the table
  final List<Map<String, String>> tableData = [
    {
      'starting': 'New York',
      'destination': 'Boston',
      'timeCost': '4h 30m',
      'staging': 'Direct',
    },
    {
      'starting': 'Chicago',
      'destination': 'Miami',
      'timeCost': '6h 15m',
      'staging': '1 Stop',
    },
    {
      'starting': 'Los Angeles',
      'destination': 'Seattle',
      'timeCost': '2h 45m',
      'staging': 'Direct',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: MediaQuery.of(context).size.width, // Span full screen width
        child: DataTable(
          // Define column headers
          columns: const [
            DataColumn(
              label: Text(
                'Starting',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Destination',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Time Cost',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Staging',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          // Define rows from sample data
          rows:
              tableData
                  .map(
                    (data) => DataRow(
                      cells: [
                        DataCell(Text(data['starting']!)),
                        DataCell(Text(data['destination']!)),
                        DataCell(Text(data['timeCost']!)),
                        DataCell(Text(data['staging']!)),
                      ],
                    ),
                  )
                  .toList(),
          // Optional styling
          columnSpacing: 20.0,
          dataRowHeight: 50.0,
          headingRowColor: MaterialStateProperty.all(Colors.blue[100]),
          border: TableBorder.all(color: Colors.grey, width: 1.0),
        ),
      ),
    );
  }
}
