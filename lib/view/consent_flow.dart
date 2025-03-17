import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Visualises consent model features as an expandable step-by-step flow
class ConsentFlowVisualization extends StatefulWidget {
  final String modelName;
  final List<ConsentStep> steps;

  const ConsentFlowVisualization({
    super.key,
    required this.modelName,
    required this.steps,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ConsentFlowVisualizationState createState() => _ConsentFlowVisualizationState();
}

class _ConsentFlowVisualizationState extends State<ConsentFlowVisualization> {
  int? expandedStepIndex; // Tracks which step is currently expanded, null if none

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display the model name as a header
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            widget.modelName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
         // Display steps vertically with connector lines between them
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.steps.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                StepCard(
                  step: widget.steps[index],
                  isExpanded: expandedStepIndex == index,
                  onTap: () => setState(() {
                    // Toggle expansion of the tapped step
                    expandedStepIndex = expandedStepIndex == index ? null : index;
                  }),
                ),
                // Add connector line between steps, except after the last step
                if (index < widget.steps.length - 1)
                  const ConnectorLine(),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Visual connector between step cards to represent flow/sequence
class ConnectorLine extends StatelessWidget {
  const ConnectorLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.3),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withOpacity(0.5),
            AppTheme.primaryColor.withOpacity(0.2),
          ],
        ),
      ),
    );
  }
}

/// Individual expandable card representing a consent model feature or step
class StepCard extends StatelessWidget {
  final ConsentStep step;
  final bool isExpanded;
  final VoidCallback onTap;

  const StepCard({
    super.key,
    required this.step,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isExpanded ? AppTheme.primaryColor : Colors.grey[300]!,
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isExpanded ? 8 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        step.icon,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ),
                if (isExpanded) ...[
                  const SizedBox(height: 16),
                  ...step.details.map((detail) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                              "•", // Unicode bullet point
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            detail,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ConsentStep {
  final String title;
  final IconData icon;
  final List<String> details;

  ConsentStep({
    required this.title,
    required this.icon,
    required this.details,
  });
}