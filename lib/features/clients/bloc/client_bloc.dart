import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoicepatch_contractor/shared/repositories/client_repository.dart';
import 'package:invoicepatch_contractor/shared/models/client.dart';
import 'client_event.dart';
import 'client_state.dart';

class ClientBloc extends Bloc<ClientEvent, ClientState> {
  final ClientRepository _clientRepository;

  ClientBloc({required ClientRepository clientRepository})
      : _clientRepository = clientRepository,
        super(const ClientInitial()) {
    // Register event handlers
    on<ClientLoadRequested>(_onClientLoadRequested);
    on<ClientCreateRequested>(_onClientCreateRequested);
    on<ClientUpdateRequested>(_onClientUpdateRequested);
    on<ClientDeleteRequested>(_onClientDeleteRequested);
    on<ClientSearchRequested>(_onClientSearchRequested);
    on<ClientRateUpdateRequested>(_onClientRateUpdateRequested);
  }

  Future<void> _onClientLoadRequested(
    ClientLoadRequested event,
    Emitter<ClientState> emit,
  ) async {
    emit(const ClientLoading());
    try {
      final clients = await _clientRepository.getAll();
      emit(ClientLoaded(clients: clients));
    } catch (e) {
      emit(ClientFailure(message: 'Failed to load clients: [${e.toString()}'));
    }
  }

  Future<void> _onClientCreateRequested(
    ClientCreateRequested event,
    Emitter<ClientState> emit,
  ) async {
    emit(const ClientSaving());
    try {
      final createdClient = await _clientRepository.create(event.client);
      emit(ClientSaved(
        savedClient: createdClient,
        message: 'Client created successfully',
      ));
      // Reload clients to show updated list
      add(const ClientLoadRequested());
    } catch (e) {
      emit(ClientFailure(message: 'Failed to create client: [${e.toString()}'));
    }
  }

  Future<void> _onClientUpdateRequested(
    ClientUpdateRequested event,
    Emitter<ClientState> emit,
  ) async {
    emit(const ClientSaving());
    try {
      final updatedClient = await _clientRepository.update(event.client);
      emit(ClientSaved(
        savedClient: updatedClient,
        message: 'Client updated successfully',
      ));
      // Reload clients to show updated list
      add(const ClientLoadRequested());
    } catch (e) {
      emit(ClientFailure(message: 'Failed to update client: [${e.toString()}'));
    }
  }

  Future<void> _onClientDeleteRequested(
    ClientDeleteRequested event,
    Emitter<ClientState> emit,
  ) async {
    try {
      await _clientRepository.delete(event.clientId);
      emit(ClientDeleted(
        clientId: event.clientId,
        message: 'Client deleted successfully',
      ));
      // Reload clients to show updated list
      add(const ClientLoadRequested());
    } catch (e) {
      emit(ClientFailure(message: 'Failed to delete client: [${e.toString()}'));
    }
  }

  Future<void> _onClientSearchRequested(
    ClientSearchRequested event,
    Emitter<ClientState> emit,
  ) async {
    emit(const ClientLoading());
    try {
      List<Client> clients;
      if (event.query.trim().isEmpty) {
        // If search query is empty, load all clients
        clients = await _clientRepository.getAll();
        emit(ClientLoaded(clients: clients));
      } else {
        // Search for clients matching the query
        clients = await _clientRepository.searchClients(event.query);
        emit(ClientSearchResults(
          clients: clients,
          query: event.query,
        ));
      }
    } catch (e) {
      emit(ClientFailure(message: 'Failed to search clients: [${e.toString()}'));
    }
  }

  Future<void> _onClientRateUpdateRequested(
    ClientRateUpdateRequested event,
    Emitter<ClientState> emit,
  ) async {
    try {
      await _clientRepository.updateClientRate(event.clientId, event.newRate);
      emit(const ClientOperationSuccess(
        message: 'Client rate updated successfully',
        clients: [], // Will be updated by reload
      ));
      // Reload clients to show updated list
      add(const ClientLoadRequested());
    } catch (e) {
      emit(ClientFailure(message: 'Failed to update client rate: [${e.toString()}'));
    }
  }
} 