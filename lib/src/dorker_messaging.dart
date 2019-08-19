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

  String toString() =>
      'Request\nCommand: $command\nParam: $params\nTracking: $trackingId';
}

class Respond {
  final String command;
  final bool isError;
  final bool isEvent;
  final dynamic params;
  final String trackingId;

  Respond(this.command,
      {this.isError, this.isEvent, this.params, this.trackingId});

  factory Respond.to(Request request, {dynamic params}) {
    return Respond(request.command,
        isError: false,
        isEvent: false,
        params: params,
        trackingId: request.trackingId);
  }

  factory Respond.error(Request request, {dynamic params}) {
    return Respond(request.command,
        isError: true,
        isEvent: false,
        params: params,
        trackingId: request.trackingId);
  }

  factory Respond.sendEvent(dynamic params) {
    return Respond(null, isError: false, isEvent: true, params: params);
  }

  factory Respond.fromPayload(List<dynamic> payload) {
    return Respond(payload[0],
        isError: payload[1],
        isEvent: payload[2],
        params: json.decode(payload[3]),
        trackingId: payload[4]);
  }

  void sendThrough(Dorker dorker) {
    dorker.postMessage.add(_toPayload());
  }

  List<dynamic> _toPayload() =>
      [command, isError, isEvent, json.encode(params), trackingId];

  String toString() =>
      'Respond ${isError ? 'ERROR' : ''}\nCommand: $command\nParam: $params';
}
