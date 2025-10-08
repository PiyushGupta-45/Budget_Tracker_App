import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/expense_notifier.dart';
import 'widgets/analytics_view.dart';
import 'widgets/controls_section.dart';
import 'widgets/expense_list.dart';

void main() {
  // Wrap the entire application with the ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
      ),
      home: const ExpenseTrackerScreen(),
    );
  }
}

// FIX: Converted to a StatelessWidget. It now relies entirely on Provider for state.
class ExpenseTrackerScreen extends StatelessWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch only the minimal state properties needed to decide the main content display.
    final isLoading = context.select((ExpenseNotifier n) => n.isLoading);
    final viewMode = context.select((ExpenseNotifier n) => n.viewMode);

    if (isLoading) {
      return const LoadingView();
    }

    Widget contentWidget;
    switch (viewMode) {
      case 'chart':
        contentWidget = const ExpenseDistributionView();
        break;
      case 'analytics':
        contentWidget = const AdvancedAnalyticsView();
        break;
      case 'list':
      default:
        contentWidget = const ExpenseListView();
        break;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              title: const Text(
                'Expense Tracker',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const StatsCards(),
                    const SizedBox(height: 16.0),
                    const ControlsSection(), // Rebuilds when viewMode/filters change
                    const SizedBox(height: 16.0),

                    contentWidget, // Only this single widget is rebuilt based on viewMode

                    const SizedBox(height: 30.0),
                    const Footer(),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// --- Loading View ---
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Loading Expense Tracker...',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Footer ---
class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          Text(
            'Expense Tracker Pro - Built with Flutter/Provider',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            'Your financial data is stored locally using SharedPreferences.',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
