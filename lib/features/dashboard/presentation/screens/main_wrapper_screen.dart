import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({Key? key}) : super(key: key);
  
  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    _PlaceholderScreen(label: 'Time Tracking'),
    _PlaceholderScreen(label: 'Invoice Simulation'),
    _PlaceholderScreen(label: 'Expense Tracking'),
    _PlaceholderScreen(label: 'Receipt Camera'),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentIndex = index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF50C878),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.layoutDashboard, size: 22),
              activeIcon: Icon(LucideIcons.layoutDashboard, size: 24),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.clock, size: 22),
              activeIcon: Icon(LucideIcons.clock, size: 24),
              label: 'Time',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.fileText, size: 22),
              activeIcon: Icon(LucideIcons.fileText, size: 24),
              label: 'Invoices',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.dollarSign, size: 22),
              activeIcon: Icon(LucideIcons.dollarSign, size: 24),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.camera, size: 22),
              activeIcon: Icon(LucideIcons.camera, size: 24),
              label: 'Camera',
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String label;
  const _PlaceholderScreen({required this.label});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$label Screen Coming Soon',
        style: const TextStyle(fontSize: 22, color: Colors.grey),
      ),
    );
  }
}

// Haptic Feedback Mixin
mixin HapticFeedbackMixin {
  void lightImpact() {
    HapticFeedback.lightImpact();
  }
  void mediumImpact() {
    HapticFeedback.mediumImpact();
  }
  void heavyImpact() {
    HapticFeedback.heavyImpact();
  }
  void selectionClick() {
    HapticFeedback.selectionClick();
  }
}

enum HapticImpact { light, medium, heavy, selection }

// Enhanced button with haptic feedback
class HapticButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final HapticImpact impact;
  final ButtonStyle? style;
  const HapticButton({
    Key? key,
    required this.child,
    required this.onPressed,
    this.impact = HapticImpact.light,
    this.style,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Trigger haptic feedback
        switch (impact) {
          case HapticImpact.light:
            HapticFeedback.lightImpact();
            break;
          case HapticImpact.medium:
            HapticFeedback.mediumImpact();
            break;
          case HapticImpact.heavy:
            HapticFeedback.heavyImpact();
            break;
          case HapticImpact.selection:
            HapticFeedback.selectionClick();
            break;
        }
        onPressed();
      },
      style: style,
      child: child,
    );
  }
} 