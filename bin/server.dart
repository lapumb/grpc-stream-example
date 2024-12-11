import 'dart:async';
import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:grpc_stream_example/grpc_stream_example.dart';

class ExampleService extends ExampleServiceBase {
  @override
  Stream<ExampleMessage> serverToClientStream(
    final ServiceCall call,
    final Empty request,
  ) async* {
    final StreamController<ExampleMessage> controller =
        StreamController<ExampleMessage>();

    // Add an initial message to the stream.
    print('Yielding initial message at ${DateTime.now()}');
    int msgCount = 0;
    controller.add(ExampleMessage(value: msgCount));
    msgCount += 1;

    // Add a new message to the stream every [messageFrequencyMinutes] minutes.
    final Timer timer = Timer.periodic(
        Duration(minutes: messageFrequencyMinutes), (final _) async {
      print('Yielding message at ${DateTime.now()}');
      controller.add(ExampleMessage(value: msgCount));
      msgCount += 1;
    });

    // Clean up on client cancel.
    controller.onCancel = () async {
      timer.cancel();

      if (controller.hasListener) {
        await controller.close();
      }

      print('Client canceled the stream at ${DateTime.now()}');
    };

    // Yield the stream until the client cancels.
    try {
      yield* controller.stream;
    } finally {
      await controller.close();
      print('Stream ended (${DateTime.now()})');
    }
  }

  @override
  Future<Empty> pingServer(final ServiceCall call, final Empty request) async {
    print('Received ping from client at ${DateTime.now()}');
    return Empty();
  }
}

void main() async {
  final Server server = Server.create(services: <Service>[ExampleService()]);
  await server.serve(address: 'localhost', port: 8080);

  print('Server listening on port ${server.port}...');

  // Handle SIGINT (Ctrl+C) gracefully.
  ProcessSignal.sigint.watch().listen((final ProcessSignal signal) async {
    print('Received signal $signal, stopping gRPC server...');

    await server.shutdown();

    exit(0);
  });

  // Super-loop to keep the server running.
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 30));
  }
}
