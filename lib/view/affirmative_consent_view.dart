// lib/widgets/affirmative_consent_panel.dart

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AffirmativeConsentPanel extends StatefulWidget {
  final Map<String, dynamic> pathways;

  const AffirmativeConsentPanel({
    Key? key,
    required this.pathways,
  }) : super(key: key);

  @override
  _AffirmativeConsentPanelState createState() => _AffirmativeConsentPanelState();
}

class _AffirmativeConsentPanelState extends State<AffirmativeConsentPanel> {
  bool isPath1Expanded = false;
  bool isPath2Expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPathwayCard(
          title: widget.pathways['pathway1']['title'],
          steps: widget.pathways['pathway1']['steps'],
          isExpanded: isPath1Expanded,
          onTap: () => setState(() => isPath1Expanded = !isPath1Expanded),
        ),
        SizedBox(height: 16),
        _buildPathwayCard(
          title: widget.pathways['pathway2']['title'],
          steps: widget.pathways['pathway2']['steps'],
          isExpanded: isPath2Expanded,
          onTap: () => setState(() => isPath2Expanded = !isPath2Expanded),
        ),
      ],
    );
  }

  Widget _buildPathwayCard({
    required String title,
    required List<String> steps,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.primaryColor,
                    ),
                    SizedBox(width: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                Divider(height: 1),
                Container(
                  padding: EdgeInsets.all(16),
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  child: Column(
                    children: steps.map((step) => _buildStep(step)).toList(),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String step) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6, right: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              step,
              style: TextStyle(
                color: AppTheme.textPrimaryColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}