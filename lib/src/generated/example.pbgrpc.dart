// coverage:ignore-file
//
//  Generated code. Do not modify.
//  source: example.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'example.pb.dart' as $0;

export 'example.pb.dart';

@$pb.GrpcServiceName('Example')
class ExampleClient extends $grpc.Client {
  static final _$serverToClientStream =
      $grpc.ClientMethod<$0.Empty, $0.ExampleMessage>(
          '/Example/ServerToClientStream',
          ($0.Empty value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $0.ExampleMessage.fromBuffer(value));

  ExampleClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseStream<$0.ExampleMessage> serverToClientStream($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createStreamingCall(
        _$serverToClientStream, $async.Stream.fromIterable([request]),
        options: options);
  }
}

@$pb.GrpcServiceName('Example')
abstract class ExampleServiceBase extends $grpc.Service {
  $core.String get $name => 'Example';

  ExampleServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.ExampleMessage>(
        'ServerToClientStream',
        serverToClientStream_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.ExampleMessage value) => value.writeToBuffer()));
  }

  $async.Stream<$0.ExampleMessage> serverToClientStream_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async* {
    yield* serverToClientStream(call, await request);
  }

  $async.Stream<$0.ExampleMessage> serverToClientStream(
      $grpc.ServiceCall call, $0.Empty request);
}
