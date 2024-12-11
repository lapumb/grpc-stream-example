# gRPC Stream Example

This repository is intended to showcase the erroneous behavior when streams are actively running when the client channel connection timeout is reached.

## Running

To run the example:

- In one terminal, run the server:

```bash
[fvm] dart bin/server.dart
```

- In another terminal, run the client:

```bash
[fvm] dart bin/client.dart
```

>Note: this is a quick demo and is setup that the server **must** be started before the client.

## Expected Behavior

The client will receive messages every minute _until_ a ping is sent after the connection timeout is reached. Once the ping is sent, the server will silently cancel the stream while the client continues listening indefinitely.
