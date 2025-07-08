import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoicepatch_contractor/features/daily_logs/bloc/daily_log_bloc.dart';
import 'package:invoicepatch_contractor/features/daily_logs/bloc/daily_log_event.dart';
import 'package:invoicepatch_contractor/features/daily_logs/bloc/daily_log_state.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_bloc.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_event.dart';
import 'package:invoicepatch_contractor/features/clients/bloc/client_state.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'package:invoicepatch_contractor/shared/models/address.dart';
import 'package:invoicepatch_contractor/shared/models/billing_preferences.dart';
import 'package:invoicepatch_contractor/shared/models/enums/billing_method.dart';
import 'package:invoicepatch_contractor/core/routing/app_router.dart';
import 'package:invoicepatch_contractor/features/invoice_simulation/presentation/screens/invoice_creation_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:invoicepatch_contractor/features/analytics/presentation/screens/analytics_dashboard_screen.dart';
import 'package:invoicepatch_contractor/features/invoice_management/presentation/screens/invoice_history_screen.dart';
import 'package:invoicepatch_contractor/features/dashboard/presentation/widgets/welcome_header.dart';
import 'package:invoicepatch_contractor/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:invoicepatch_contractor/features/dashboard/presentation/widgets/action_card.dart';
import 'package:invoicepatch_contractor/features/dashboard/presentation/widgets/animated_dashboard_card.dart';
import 'package:invoicepatch_contractor/features/dashboard/presentation/widgets/slide_page_route.dart';

const emeraldGreen = Color(0xFF50C878);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    context.read<DailyLogBloc>().add(DailyLogLoadRequested());
    context.read<ClientBloc>().add(ClientLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(
                  page: const AnalyticsDashboardScreen(),
                  direction: SlideDirection.left,
                ),
              );
            },
            icon: const Icon(LucideIcons.barChart3, color: emeraldGreen),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(
                  page: const InvoiceHistoryScreen(),
                  direction: SlideDirection.left,
                ),
              );
            },
            icon: const Icon(LucideIcons.fileText, color: emeraldGreen),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              AnimatedDashboardCard(
                index: 0,
                child: const WelcomeHeader(),
              ),
              const SizedBox(height: 24),

              // Smart Insights
              AnimatedDashboardCard(
                index: 1,
                child: _buildSmartInsights(),
              ),
              const SizedBox(height: 24),

              // Quick Stats
              AnimatedDashboardCard(
                index: 2,
                child: _buildQuickStats(),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              AnimatedDashboardCard(
                index: 3,
                child: _buildQuickActions(),
              ),
              const SizedBox(height: 24),

              // Bottom Section
              Row(
                children: [
                  Expanded(
                    child: AnimatedDashboardCard(
                      index: 4,
                      child: _buildRecentActivity(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnimatedDashboardCard(
                      index: 5,
                      child: _buildWeekSummary(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartInsights() {
    return BlocBuilder<DailyLogBloc, DailyLogState>(
      builder: (context, logState) {
        if (logState is DailyLogLoaded) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInsightRow(
                  icon: Icons.lightbulb,
                  text: 'You\'re averaging ${_getAverageHours(logState.logs)} hours per day',
                  color: emeraldGreen,
                ),
                const SizedBox(height: 8),
                _buildInsightRow(
                  icon: Icons.trending_up,
                  text: 'Monthly revenue is ${_getMonthlyGrowth(logState.logs)}% higher than last month',
                  color: emeraldGreen,
                ),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildQuickStats() {
    return BlocBuilder<DailyLogBloc, DailyLogState>(
      builder: (context, logState) {
        double monthlyRevenue = 0;
        double upToDateRevenue = 0;
        if (logState is DailyLogLoaded) {
          final now = DateTime.now();
          monthlyRevenue = logState.logs
              .where((log) => log.date.year == now.year && log.date.month == now.month)
              .fold(0.0, (sum, log) => sum + (log.totalAmount ?? 0));
          upToDateRevenue = logState.logs.fold(0.0, (sum, log) => sum + (log.totalAmount ?? 0));
        }
        return Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Monthly Revenue',
                value: logState is DailyLogLoaded
                    ? '\$${monthlyRevenue.toStringAsFixed(0)}'
                    : '--',
                subtitle: 'Tap for month graph',
                icon: Icons.bar_chart,
                color: emeraldGreen,
                onTap: () => _showMonthlyRevenueGraph(context, logState),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StatCard(
                title: 'Up to Date Revenue',
                value: logState is DailyLogLoaded
                    ? '\$${upToDateRevenue.toStringAsFixed(0)}'
                    : '--',
                subtitle: 'Total earned to date',
                icon: Icons.trending_up,
                color: emeraldGreen,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ActionCard(
                title: 'Create Invoice',
                subtitle: 'Generate new invoice',
                icon: Icons.receipt,
                color: emeraldGreen,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InvoiceCreationScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ActionCard(
                title: 'Add Client',
                subtitle: 'Create new client',
                icon: Icons.person_add,
                color: emeraldGreen,
                onTap: () {
                  // Navigate to client creation
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            icon: Icons.work,
            title: 'Logged 8 hours',
            subtitle: 'Today',
            color: emeraldGreen,
          ),
          _buildActivityItem(
            icon: Icons.person,
            title: 'Added new client',
            subtitle: '2 days ago',
            color: Colors.blue,
          ),
          _buildActivityItem(
            icon: Icons.receipt,
            title: 'Invoice generated',
            subtitle: '5 days ago',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSummary() {
    return BlocBuilder<DailyLogBloc, DailyLogState>(
      builder: (context, logState) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This Week',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (logState is DailyLogLoaded)
                ..._buildWeeklyStats(logState.logs)
              else
                const Text('Loading...'),
            ],
          ),
        );
      },
    );
  }

  // Helper methods
  Widget _buildInsightRow({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeeklyStats(List<dynamic> logs) {
    // Add your week summary logic here
    return [
      Text('Hours: ${_getWeeklyHours(logs)}'),
      Text('Revenue: \$${_getWeeklyRevenue(logs)}'),
      Text('Days worked: ${_getWeeklyDaysWorked(logs)}'),
    ];
  }

  String _getAverageHours(List<dynamic> logs) {
    // Calculate average hours
    return '7.5';
  }

  String _getMonthlyGrowth(List<dynamic> logs) {
    // Calculate monthly growth
    return '15';
  }

  String _getWeeklyHours(List<dynamic> logs) {
    // Calculate weekly hours
    return '40';
  }

  String _getWeeklyRevenue(List<dynamic> logs) {
    // Calculate weekly revenue
    return '3000';
  }

  String _getWeeklyDaysWorked(List<dynamic> logs) {
    // Calculate weekly days worked
    return '5';
  }

  void _showMonthlyRevenueGraph(BuildContext context, DailyLogState logState) {
    // Show monthly revenue graph
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monthly Revenue'),
        content: const Text('Monthly revenue graph would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}