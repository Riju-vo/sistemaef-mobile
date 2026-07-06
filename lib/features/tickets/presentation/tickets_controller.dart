import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tickets_repository.dart';
import '../domain/ticket_models.dart';

final ticketsQueryProvider = StateProvider<TicketsQuery>((ref) {
  return const TicketsQuery();
});

final ticketsListProvider = FutureProvider.autoDispose<TicketsListResponse>((ref) async {
  final query = ref.watch(ticketsQueryProvider);
  final repository = ref.watch(ticketsRepositoryProvider);
  final result = await repository.listTickets(query);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.failure?.message ?? 'No se pudo cargar tickets');
});

final ticketDetailProvider =
    FutureProvider.autoDispose.family<TicketItem, String>((ref, ticketId) async {
  final repository = ref.watch(ticketsRepositoryProvider);
  final result = await repository.getTicket(ticketId);

  if (result.isSuccess && result.data != null) {
    return result.data!;
  }

  throw Exception(result.failure?.message ?? 'No se pudo cargar el ticket');
});
