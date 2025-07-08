import 'package:equatable/equatable.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';

abstract class ClientState extends Equatable {
  const ClientState();

  @override
  List<Object?> get props => [];
}

class ClientInitial extends ClientState {
  const ClientInitial();
}

class ClientLoading extends ClientState {
  const ClientLoading();
}

class ClientLoaded extends ClientState {
  final List<Client> clients;

  const ClientLoaded({required this.clients});

  @override
  List<Object> get props => [clients];

  ClientLoaded copyWith({List<Client>? clients}) {
    return ClientLoaded(clients: clients ?? this.clients);
  }
}

class ClientOperationSuccess extends ClientState {
  final String message;
  final List<Client> clients;

  const ClientOperationSuccess({
    required this.message,
    required this.clients,
  });

  @override
  List<Object> get props => [message, clients];
}

class ClientFailure extends ClientState {
  final String message;

  const ClientFailure({required this.message});

  @override
  List<Object> get props => [message];
}

class ClientSaving extends ClientState {
  const ClientSaving();
}

class ClientSaved extends ClientState {
  final Client savedClient;
  final String message;

  const ClientSaved({
    required this.savedClient,
    required this.message,
  });

  @override
  List<Object> get props => [savedClient, message];
}

class ClientDeleted extends ClientState {
  final String clientId;
  final String message;

  const ClientDeleted({
    required this.clientId,
    required this.message,
  });

  @override
  List<Object> get props => [clientId, message];
}

class ClientSearchResults extends ClientState {
  final List<Client> clients;
  final String query;

  const ClientSearchResults({
    required this.clients,
    required this.query,
  });

  @override
  List<Object> get props => [clients, query];
} 