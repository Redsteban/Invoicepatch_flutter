import 'package:flutter/material.dart';

class NotificationPreferences {
  final TimeOfDay? dailyLogReminderTime;
  final bool invoiceDueAlerts;
  final bool weeklySummary;
  final bool taxDeadlineReminders;

  NotificationPreferences({
    this.dailyLogReminderTime,
    this.invoiceDueAlerts = true,
    this.weeklySummary = true,
    this.taxDeadlineReminders = true,
  });
} 