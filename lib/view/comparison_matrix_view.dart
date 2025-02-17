// lib/view/matrix_view.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MatrixScreen extends StatelessWidget {
  const MatrixScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> features = const [
    {
      'category': 'Initial Consent Process',
      'items': [
        'Risk Disclosure Panel',
        'Explicit Agreement Required',
        'Mutual Confirmation',
        'Permission Configuration',
      ]
    },
    {
      'category': 'Permission Controls',
      'items': [
        'Time Limits',
        'Saving Controls',
        'Forwarding Controls',
        'Content Protection',
      ]
    },
    {
      'category': 'Post-Sharing Controls',
      'items': [
        'Consent Modification',
        'Access Revocation',
        'Periodic Review',
        'Setting Adjustments',
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison Matrix'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildComparisonTable(),
                ),
              ),
            ),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    final models = [
      'Informed Consent',
      'Affirmative Consent',
      'Dynamic Consent',
      'Granular Consent',
      'Implied Consent'
    ];

    final supportMatrix = {
      'Informed Consent': [
        true, true, false, false,
        false, false, false, false,
        false, false, false, false
      ],
      'Affirmative Consent': [
        true, true, true, false,
        false, false, false, false,
        false, false, false, false
      ],
      'Dynamic Consent': [
        false, true, false, false,
        false, false, false, true,
        true, true, true, false
      ],
      'Granular Consent': [
        false, true, false, true,
        true, true, true, true,
        true, true, false, true
      ],
      'Implied Consent': [
        false, false, false, false,
        false, false, false, false,
        false, false, false, false
      ]
    };

    return Table(
      defaultColumnWidth: const FixedColumnWidth(130),
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
          ),
          children: [
            const TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Features',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ...models.map((model) => TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  model,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            )),
          ],
        ),
        // Feature rows
        for (var feature in features)
          ..._buildFeatureRows(feature, models, supportMatrix),
      ],
    );
  }

  List<TableRow> _buildFeatureRows(Map<String, dynamic> feature, List<String> models, Map<String, List<bool>> supportMatrix) {
    List<TableRow> rows = [];
    
    // Category header
    rows.add(
      TableRow(
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
        ),
        children: [
          ...List.generate(models.length + 1, (index) => TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: index == 0 ? Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                feature['category'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ) : const SizedBox(),
          )),
        ],
      ),
    );

    var itemIndex = features.indexOf(feature) * 4;
    
    for (var i = 0; i < feature['items'].length; i++) {
      rows.add(
        TableRow(
          children: [
            TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(feature['items'][i]),
              ),
            ),
            ...models.map((model) => TableCell(
              verticalAlignment: TableCellVerticalAlignment.middle,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    supportMatrix[model]![itemIndex + i] ? Icons.check_circle : Icons.cancel,
                    color: supportMatrix[model]![itemIndex + i] ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
              ),
            )),
          ],
        ),
      );
    }

    return rows;
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 6,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 4),
          Text('Feature supported'),
          SizedBox(width: 16),
          Icon(Icons.cancel, color: Colors.red, size: 16),
          SizedBox(width: 4),
          Text('Feature not supported'),
        ],
      ),
    );
  }
}