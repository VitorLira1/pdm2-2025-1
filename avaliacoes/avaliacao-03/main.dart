import 'dart:async';
import 'dart:isolate';

void main() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(asyncGettingName, receivePort.sendPort);

  print('Iniciando outras tarefas...');
  await Future.delayed(Duration(seconds: 1));
  print('Continuando outras tarefas...');

  final result = await receivePort.first;
  print('Meu nome: $result');
}

void asyncGettingName(SendPort sendPort) async {
  Future.delayed(Duration(milliseconds: 500));
  final result = 'Vitor Adriano';
  sendPort.send(result);
}