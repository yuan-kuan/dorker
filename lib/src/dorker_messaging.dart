import 'dart:convert' show json;

import 'dorker_base.dart';

class Request {
  final String command;
  final dynamic params;
  final String trackingId;

  Request(this.command, {this.params, this.trackingId});

  factory Request.fromPayload(List<dynamic> payload) {
    return Request(payload[0],
        params: json.decode(payload[1]), trackingId: payload[2]);
  }

  void sendThrough(Dorker dorker) {
    dorker.postMessage.add(_toPayload());
  }

  List<dynamic> _toPayload() => [command, json.encode(params), trackingId];

  String toString() => 'Request\nCommand: $command\nParam: $params';
}

class Respond {
  final String command;
  final bool isError;
  final dynamic params;
  final String trackingId;

  Respond(this.command, this.isError, {this.params, this.trackingId});

  factory Respond.to(Request request, {dynamic params}) {
    return Respond(request.command, false,
        params: params, trackingId: request.trackingId);
  }

  factory Respond.error(Request request, {dynamic params}) {
    return Respond(request.command, true,
        params: params, trackingId: request.trackingId);
  }

  factory Respond.fromPayload(List<dynamic> payload) {
    return Respond(payload[0], payload[1],
        params: json.decode(payload[2]), trackingId: payload[3]);
  }

  void sendThrough(Dorker dorker) {
    dorker.postMessage.add(_toPayload());
  }

  List<dynamic> _toPayload() =>
      [command, isError, json.encode(params), trackingId];

  String toString() =>
      'Respond ${isError ? 'ERROR' : ''}\nCommand: $command\nParam: $params';
}
