import 'package:equatable/equatable.dart';

class Invoice extends Equatable {
  final int id;
  final String title;
  final double amount;

  const Invoice({required this.id, required this.title, required this.amount});

  @override
  List<Object?> get props => [id, title, amount];
} 