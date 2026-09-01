import '../files/request_buffers.dart';

class RequestBuffers {
  final BaseRequestBuffers datasource;
  final BaseRequestBuffers repository;
  final BaseRequestBuffers repositoryImpl;
  final BaseRequestBuffers entity;
  final BaseRequestBuffers model;
  final BaseRequestBuffers useCase;
  final BaseRequestBuffers cubit;
  final BaseRequestBuffers cubitStates;
  final BaseRequestBuffers cubitTest;
  final BaseRequestBuffers useCaseTest;
  final BaseRequestBuffers repositoryTest;
  final BaseRequestBuffers datasourceTest;
  final BaseRequestBuffers? blocConsumer;
  final BaseRequestBuffers injection;

  const RequestBuffers({
    required this.datasource,
    required this.repository,
    required this.repositoryImpl,
    required this.entity,
    required this.model,
    required this.useCase,
    required this.cubit,
    required this.cubitStates,
    required this.cubitTest,
    required this.useCaseTest,
    required this.repositoryTest,
    required this.datasourceTest,
    required this.injection,
    this.blocConsumer,
  });
}
