import 'package:equatable/equatable.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';

abstract class ClientEvent extends Equatable {
  const ClientEvent();

  @override
  List<Object?> get props => [];
}

class ClientLoadRequested extends ClientEvent {
  const ClientLoadRequested();
}

class ClientCreateRequested extends ClientEvent {
  final Client client;

  const ClientCreateRequested({required this.client});

  @override
  List<Object> get props => [client];
}

class ClientUpdateRequested extends ClientEvent {
  final Client client;

  const ClientUpdateRequested({required this.client});

  @override
  List<Object> get props => [client];
}

class ClientDeleteRequested extends ClientEvent {
  final String clientId;

  const ClientDeleteRequested({required this.clientId});

  @override
  List<Object> get props => [clientId];
}

class ClientSearchRequested extends ClientEvent {
  final String query;

  const ClientSearchRequested({required this.query});

  @override
  List<Object> get props => [query];
}

class ClientRateUpdateRequested extends ClientEvent {
  final String clientId;
  final double newRate;

  const ClientRateUpdateRequested({
    required this.clientId,
    required this.newRate,
  });

  @override
  List<Object> get props => [clientId, newRate];
} 