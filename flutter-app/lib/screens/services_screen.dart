import 'package:flutter/material.dart';
import '../theme/luxury_theme.dart';
import '../widgets/luxury_components.dart';
import 'housing_list_screen.dart';
import 'finance_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GoldAppBar(
        title: 'Services',
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: LuxuryColors.primaryGold,
          indicatorWeight: 3,
          labelColor: LuxuryColors.primaryGold,
          unselectedLabelColor: LuxuryColors.mutedText,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.home_work),
              text: 'Housing',
            ),
            Tab(
              icon: Icon(Icons.trending_up),
              text: 'Finance',
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LuxuryColors.primaryGradient,
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            HousingListScreen(),
            FinanceScreen(),
          ],
        ),
      ),
    );
  }
}
