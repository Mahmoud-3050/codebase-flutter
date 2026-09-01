import 'dart:io';

class RequestFiles {
  final File entity;
  final File model;
  final File useCase;
  final File cubit;
  final File cubitStates;
  final File cubitTest;
  final File useCaseTest;
  final File repositoryTest;
  final File datasourceTest;
  final File? blocConsumer;

  const RequestFiles({
    required this.entity,
    required this.model,
    required this.useCase,
    required this.cubit,
    required this.cubitStates,
    required this.cubitTest,
    required this.useCaseTest,
    required this.repositoryTest,
    required this.datasourceTest,
    this.blocConsumer,
  });
}
