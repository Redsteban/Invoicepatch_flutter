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

const emeraldGreen = Color(0xFF50C878);

// --- Animated Page Route for Transitions ---
enum SlideDirection { left, right, up, down }

class SlidePageRoute extends PageRouteBuilder {
  final Widget page;
  final SlideDirection direction;
  SlidePageRoute({
    required this.page,
    this.direction = SlideDirection.right,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 400),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin;
      switch (direction) {
        case SlideDirection.right:
          begin = const Offset(1.0, 0.0);
          break;
        case SlideDirection.left:
          begin = const Offset(-1.0, 0.0);
          break;
        case SlideDirection.up:
          begin = const Offset(0.0, 1.0);
          break;
        case SlideDirection.down:
          begin = const Offset(0.0, -1.0);
          break;
      }
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      var fadeTween = Tween(begin: 0.0, end: 1.0);
      var fadeAnimation = animation.drive(fadeTween);
      return SlideTransition(
        position: offsetAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      );
    },
  );
}

// --- Animated Dashboard Card ---
class AnimatedDashboardCard extends StatefulWidget {
  final Widget child;
  final int index;
  const AnimatedDashboardCard({Key? key, required this.child, required this.index}) : super(key: key);
  @override
  State<AnimatedDashboardCard> createState() => _AnimatedDashboardCardState();
}
class _AnimatedDashboardCardState extends State<AnimatedDashboardCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6),
    ));
    _controller.forward();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

// --- Animated Counter Widget ---
class AnimatedCounter extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final Duration duration;
  const AnimatedCounter({
    Key? key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 1000),
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Text(
          '$prefix${value.toStringAsFixed(0)}$suffix',
          style: style,
        );
      },
    );
  }
}

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

  void _createTestData() {
    // Create test clients with different billing methods
    final testClients = [
      Client(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'John Smith',
        company: 'ABC Construction Ltd.',
        email: 'john@abcconstruction.com',
        phone: '(403) 555-0123',
        address: const Address(
          street: '123 Main Street',
          city: 'Calgary',
          province: 'Alberta',
          postalCode: 'T2P 1J9',
          country: 'Canada',
        ),
        billingPreferences: BillingPreferences(
          primaryMethod: BillingMethod.hourly,
          defaultHourlyRate: 75.0,
          defaultOvertimeRate: 112.5,
          clientSpecificRates: {},
        ),
        rateHistory: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Client(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        name: 'Sarah Johnson',
        company: 'XYZ Developments Inc.',
        email: 'sarah@xyzdevelopments.com',
        phone: '(403) 555-0456',
        address: const Address(
          street: '456 Business Ave',
          city: 'Edmonton',
          province: 'Alberta',
          postalCode: 'T5K 2M5',
          country: 'Canada',
        ),
        billingPreferences: BillingPreferences(
          primaryMethod: BillingMethod.dayRate,
          defaultDayRate: 600.0,
          clientSpecificRates: {},
        ),
        rateHistory: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Client(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        name: 'Mike Wilson',
        company: 'CityBuilder Corp.',
        email: 'mike@citybuilder.com',
        phone: '(403) 555-0789',
        address: const Address(
          street: '789 Industrial Blvd',
          city: 'Calgary',
          province: 'Alberta',
          postalCode: 'T2E 3K1',
          country: 'Canada',
        ),
        billingPreferences: BillingPreferences(
          primaryMethod: BillingMethod.mixed,
          defaultDayRate: 550.0,
          defaultOvertimeRate: 85.0,
          clientSpecificRates: {},
        ),
        rateHistory: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    // Add all test clients
    for (final client in testClients) {
      context.read<ClientBloc>().add(ClientCreateRequested(client: client));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test data created! 3 clients with different billing methods added.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _loadDashboardData() {
    // Load recent logs for this week
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));
    
    context.read<DailyLogBloc>().add(DailyLogLoadRequested.range(
      startDate: weekStart,
      endDate: weekEnd,
    ));
    context.read<ClientBloc>().add(const ClientLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.black,
        foregroundColor: const Color(0xFF50C878),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _showMenuDrawer(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadDashboardData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              _buildWelcomeHeader(),
              const SizedBox(height: 16),
              // Smart Insights Section
              BlocBuilder<DailyLogBloc, DailyLogState>(
                builder: (context, logState) {
                  final now = DateTime.now();
                  final currentPeriodStart = now.subtract(Duration(days: now.day - 1));
                  final currentPeriodEnd = currentPeriodStart.add(const Duration(days: 13));
                  final daysInPeriod = 14;
                  final daysCompleted = now.difference(currentPeriodStart).inDays + 1;
                  final percentComplete = (daysCompleted / daysInPeriod * 100).clamp(0, 100).toDouble();
                  double periodEarnings = 0;
                  double projectedEarnings = 0;
                  if (logState is DailyLogLoaded) {
                    final logs = logState.logs.where((log) =>
                      !log.date.isBefore(currentPeriodStart) && !log.date.isAfter(currentPeriodEnd)
                    ).toList();
                    periodEarnings = logs.where((log) => !log.date.isAfter(now)).fold<num>(0.0, (sum, log) => sum + (log.totalAmount ?? 0)).toDouble();
                    final avgPerDay = daysCompleted > 0 ? periodEarnings / daysCompleted : 0;
                    projectedEarnings = (avgPerDay * daysInPeriod).toDouble();
                  }
                  return Column(
                    children: [
                      _buildSmartInsights(
                        daysCompleted: daysCompleted.toDouble(),
                        daysInPeriod: daysInPeriod.toDouble(),
                        percentComplete: percentComplete,
                        periodEarnings: periodEarnings,
                        projectedEarnings: projectedEarnings,
                      ),
                      const SizedBox(height: 16),
                      AnimatedGradientButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const InvoiceCreationScreen(),
                            ),
                          );
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.add, color: Colors.white, size: 24),
                            SizedBox(width: 10),
                            Text(
                              'Create Invoice',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              // Quick Stats Row
              _buildQuickStats(),
              const SizedBox(height: 24),
              
              // Quick Actions Grid
              _buildQuickActions(),
              const SizedBox(height: 24),
              
              // Recent Activity Section
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Daily Logs',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                ),
              ),
              // Invoice Summary at the end
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: _buildWeekSummary(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF01C38D), // Emerald green
            Color(0xFF50C878), // Lighter emerald green
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's track your work and grow your business",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business_center,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
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
              child: GestureDetector(
                onTap: () => _showMonthlyRevenueGraph(context, logState),
                child: _buildStatCard(
                  title: 'Monthly Revenue',
                  value: logState is DailyLogLoaded
                      ? '\$${monthlyRevenue.toStringAsFixed(0)}'
                      : '--',
                  subtitle: 'Tap for month graph',
                  icon: Icons.bar_chart,
                  color: emeraldGreen,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
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

  void _showMonthlyRevenueGraph(BuildContext context, DailyLogState logState) {
    if (logState is! DailyLogLoaded) return;
    final now = DateTime.now();
    final Map<String, double> monthTotals = {};
    for (var log in logState.logs) {
      final key = '${log.date.year}-${log.date.month.toString().padLeft(2, '0')}';
      monthTotals[key] = (monthTotals[key] ?? 0) + (log.totalAmount ?? 0);
    }
    final sortedKeys = monthTotals.keys.toList()..sort();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Month vs Month Revenue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                width: 320,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final key in sortedKeys)
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: (monthTotals[key]! / (monthTotals.values.isEmpty ? 1 : monthTotals.values.reduce((a, b) => a > b ? a : b))) * 120,
                              width: 18,
                              decoration: BoxDecoration(
                                color: emeraldGreen,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              key,
                              style: const TextStyle(fontSize: 12, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
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
              child: _buildActionCard(
                title: 'Log Work',
                subtitle: 'Add daily log entry',
                icon: Icons.add_circle,
                color: emeraldGreen,
                onTap: () {
                  context.router.push(DailyLogEntryRoute(existingLog: null));
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Add Client',
                subtitle: 'Create new client',
                icon: Icons.person_add,
                color: emeraldGreen,
                onTap: () {
                  context.router.push(ClientEntryRoute(existingClient: null));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                title: 'View Logs',
                subtitle: 'Manage daily logs',
                icon: Icons.list_alt,
                color: emeraldGreen,
                onTap: () {
                  context.router.push(DailyLogListRoute());
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                title: 'Clients',
                subtitle: 'Manage clients',
                icon: Icons.business,
                color: emeraldGreen,
                onTap: () {
                  context.router.push(ClientListRoute());
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AnimatedDashboardCard(
                index: 4,
                child: _buildActionCard(
                  title: 'P&L Analytics',
                  subtitle: 'View insights',
                  icon: LucideIcons.barChart3,
                  color: Colors.purple,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: const AnalyticsDashboardScreen(),
                        direction: SlideDirection.right,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedDashboardCard(
                index: 5,
                child: _buildActionCard(
                  title: 'Past Invoices',
                  subtitle: 'View history',
                  icon: LucideIcons.history,
                  color: Colors.indigo,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      SlidePageRoute(
                        page: const InvoiceHistoryScreen(),
                        direction: SlideDirection.right,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                context.router.push(DailyLogListRoute());
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<DailyLogBloc, DailyLogState>(
          builder: (context, state) {
            if (state is DailyLogLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DailyLogLoaded) {
              if (state.logs.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.work_outline, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'No activity this week',
                          style: TextStyle(color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              // Show latest 3 logs
              final recentLogs = state.logs.take(3).toList();
              return Column(
                children: recentLogs.map((log) => _buildActivityItem(log)).toList(),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem(dynamic log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: emeraldGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.work, color: emeraldGreen, size: 20),
        ),
        title: Text('Work logged'),
        subtitle: Text('${log.date.day}/${log.date.month}/${log.date.year}'),
        trailing: Text(
          '\$${log.totalAmount.toStringAsFixed(0)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: emeraldGreen,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekSummary() {
    return BlocBuilder<DailyLogBloc, DailyLogState>(
      builder: (context, state) {
        if (state is DailyLogLoaded && state.logs.isNotEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'This Week Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryItem(
                          'Total Earned',
                          '\$${state.totalAmount.toStringAsFixed(2)}',
                          Icons.attach_money,
                          emeraldGreen,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryItem(
                          'Work Days',
                          '${state.logs.length}',
                          Icons.calendar_today,
                          emeraldGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSmartInsights({
    required double daysCompleted,
    required double daysInPeriod,
    required double percentComplete,
    required double periodEarnings,
    required double projectedEarnings,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF50C878),
            const Color(0xFF50C878).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF50C878).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pay Period Insights',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Day $daysCompleted of $daysInPeriod',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${percentComplete.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentComplete / 100,
                backgroundColor: Colors.white.withOpacity(0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Insights Grid
          Row(
            children: [
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.calendar_today,
                  label: 'Days Left',
                  value: '${(daysInPeriod - daysCompleted).toInt()}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.attach_money,
                  label: 'Earned',
                  value: '\$${periodEarnings.toStringAsFixed(0)}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInsightItem(
                  icon: Icons.trending_up,
                  label: 'Projected',
                  value: '\$${projectedEarnings.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF50C878)),
              title: const Text('Update Profile'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement navigation to Profile
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile screen coming soon')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF50C878)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement navigation to Settings
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings screen coming soon')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help, color: Color(0xFF50C878)),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement navigation to Help
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help screen coming soon')));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual logout logic
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out (feature coming soon)')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}

class AnimatedGradientButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final EdgeInsets? padding;
  
  const AnimatedGradientButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.padding,
  }) : super(key: key);
  
  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _animation.value, -1.0),
              end: Alignment(1.0 + _animation.value, 1.0),
              colors: const [
                Color(0xFF50C878),
                Color(0xFF3FA65F),
                Color(0xFF50C878),
                Color(0xFF6FD896),
                Color(0xFF50C878),
              ],
              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF50C878).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: widget.onPressed,
              child: Padding(
                padding: widget.padding ?? const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
} 