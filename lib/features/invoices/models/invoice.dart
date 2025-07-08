// Invoice model
import 'package:flutter/material.dart';

class Invoice {
  final String id;
  final String clientName;
  final String clientAddress;
  final DateTime deliveryDate;
  final String contractorName;
  final String contractorAddress;
  final DateTime payPeriodStart;
  final DateTime payPeriodEnd;
  final String invoiceNumber;
  final String clientInvoiceNumber;
  final String companyName;
  final String payType; // 'hourly' or 'daily'
  final double rate;
  final double dailySubsistence;
  final List<DailyEntry> dailyEntries;
  final double truckRate;
  final double kmsRate;
  final double otherCharges;
  final double subtotal;
  final double gst;
  final double totalSubsistence;
  final double grandTotal;

  Invoice({
    required this.id,
    required this.clientName,
    required this.clientAddress,
    required this.deliveryDate,
    required this.contractorName,
    required this.contractorAddress,
    required this.payPeriodStart,
    required this.payPeriodEnd,
    required this.invoiceNumber,
    required this.clientInvoiceNumber,
    required this.companyName,
    required this.payType,
    required this.rate,
    required this.dailySubsistence,
    required this.dailyEntries,
    required this.truckRate,
    required this.kmsRate,
    required this.otherCharges,
    required this.subtotal,
    required this.gst,
    required this.totalSubsistence,
    required this.grandTotal,
  });
}

class DailyEntry {
  final int dayNumber;
  final DateTime date;
  final String description;
  final double hours;
  final double rate;
  final double truckRate;
  final double kmsDriven;
  final double kmsRate;
  final double otherCharges;
  final String location;
  final String ticketNumber;
  final double dailyTotal;
  final bool worked;

  DailyEntry({
    required this.dayNumber,
    required this.date,
    required this.description,
    required this.hours,
    required this.rate,
    required this.truckRate,
    required this.kmsDriven,
    required this.kmsRate,
    required this.otherCharges,
    required this.location,
    required this.ticketNumber,
    required this.dailyTotal,
    required this.worked,
  });
} 