import 'package:consent_visualisation_tool/controller/home_controller.dart';
import 'package:consent_visualisation_tool/model/home_model.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart'; // Ensure you have this import

class HomeScreen extends StatelessWidget {
  final HomeController controller = HomeController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSection(context),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: controller.homeScreenModel.menuItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.homeScreenModel.menuItems[index];
                    return _buildModeCard(context, item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Consent Visualisation Tool', 
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 10),
        Text(
          'Explore and understand consent models in the context of digital intimate image exchanges',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildModeCard(BuildContext context, HomeMenuItem item) {
    return Card(
      child: InkWell(
        onTap: () => controller.navigateToSection(context, item.routeName),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: 30,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}