import 'dart:async';
import 'dart:io';

import 'package:grpc/grpc.dart';
import 'package:grpc_stream_example/grpc_stream_example.dart';

const Duration connectionTimeout = Duration(seconds: 30);

late final ClientChannel _clientChannel;
late final ExampleServiceClient _exampleStub;
late final StreamSubscription<ExampleMessage> _streamSubscription;
late final StreamSubscription<List<int>> _stdinSubscription;

void main() async {
  _setupConnection();
  _startConnectionTimeoutTimer();
  _listenForPingRequest();

  // Start listening for messages from the server.
  DateTime lastMessageTime = DateTime.now();
  _streamSubscription = _exampleStub.serverToClientStream(Empty()).listen(
        (final ExampleMessage message) async {
          lastMessageTime = DateTime.now();
          print('Received message: ${message.value} at $lastMessageTime');
        },
        cancelOnError: true,
        onError: (final Object error) async {
          print('Canceling _streamSubscription due to error: $error');
          await _streamSubscription.cancel();
        },
        onDone: () async {
          print(
            'Canceling _streamSubscription due to server closing the stream',
          );
          await _streamSubscription.cancel();
        },
      );

  _listenForSigInt(() async {
    print('Stopping client...');

    await _streamSubscription.cancel();
    await _clientChannel.shutdown();
    await _stdinSubscription.cancel();

    print('Client stopped');
  });

  await _superLoop(() => lastMessageTime);
}

/// Setup the gRPC client channel.
void _setupConnection() {
  _clientChannel = ClientChannel(
    'localhost',
    port: 8080,
    options: const ChannelOptions(
      credentials: ChannelCredentials.insecure(),
      connectionTimeout: connectionTimeout,
    ),
  );

  _exampleStub = ExampleServiceClient(_clientChannel);
}

/// Start a timer to give the user feedback that the connection timeout should
/// have occurred.
void _startConnectionTimeoutTimer() {
  Timer(connectionTimeout, () async {
    print('-' * 80);
    print(
      'It has been $connectionTimeout, the connection timeout should have taken effect!',
    );
    print(
      'Try pinging the server (by typing \'s\') to see if the connection is still active.',
    );
    print('-' * 80);
  });
}

/// Listen for SIGINT (Ctrl+C) to stop the gRPC server and clean up.
void _listenForSigInt(final Future<void> Function() onSignal) {
  late final StreamSubscription<ProcessSignal> subscription;
  subscription =
      ProcessSignal.sigint.watch().listen((final ProcessSignal signal) async {
    print('Received signal $signal...');

    await onSignal();

    await subscription.cancel();

    exit(0);
  });
}

/// Listen for the 's' key to be tapped to ping the server.
void _listenForPingRequest() {
  stdin.echoMode = false;
  stdin.lineMode = false;
  _stdinSubscription = stdin.listen((final List<int> data) async {
    if (data.isNotEmpty && data.first == 115) {
      print('Sending ping...');
      await _exampleStub.pingServer(Empty());
    }
  });
}

/// The super loop that keeps the application running.
Future<void> _superLoop(final DateTime Function() lastMessageTime) async {
  while (true) {
    // Detect if any messages have been received in the last [timeoutInMinutes] + 1 minutes.
    // If not, we have likely lost communications silently with the server.
    final int timeoutInMinutes = messageFrequencyMinutes + 1;
    if (DateTime.now().difference(lastMessageTime()) >
        Duration(minutes: timeoutInMinutes)) {
      print(
        'No messages received in the last $timeoutInMinutes minutes',
      );
    }

    await Future<void>.delayed(const Duration(seconds: 30));
  }
}
