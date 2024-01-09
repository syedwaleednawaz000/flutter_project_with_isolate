import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiProvider extends ChangeNotifier {
  static const String _apiUrl = 'https://jsonplaceholder.typicode.com/posts';
  List<String> _apiResponse = [];
  List<String> get apiResponse => _apiResponse;

  Future<void> fetchData() async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_fetchDataIsolate, receivePort.sendPort);
    SendPort sendPort = await receivePort.first;
    List<String> result = await _sendReceive(sendPort, 'fetchData');
    _apiResponse = result;
    notifyListeners();
  }

  static void _fetchDataIsolate(SendPort sendPort) async {
    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (var msg in receivePort) {
      SendPort replyTo = msg[0];
      String command = msg[1];
      if (command == 'fetchData') {
        List<String> data = await _fetchData();
        replyTo.send(data);
      }
    }
  }

  static Future<List<String>> _fetchData() async {
    final response = await http.get(Uri.parse(_apiUrl));
    if (response.statusCode == 200) {
      dynamic decodedData = jsonDecode(response.body);

      // Check if the decoded data is a list
      if (decodedData is List) {
        List<String> result = decodedData.map((item) => item.toString()).toList();
        return result;
      } else {
        throw Exception('Invalid data type. Expected List.');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<String>> _sendReceive(SendPort sendPort, String command) async {
    ReceivePort response = ReceivePort();
    sendPort.send([response.sendPort, command]);

    dynamic result = await response.first;

    if (result is List<String>) {
      return result;
    } else {
      throw Exception('Invalid response type');
    }
  }
//Todo by posting
  Future<void> postData(Map<String, dynamic> data) async {
    ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(_postDataIsolate, [receivePort.sendPort, data]);

    SendPort sendPort = await receivePort.first;
    List<String> result = await _sendReceive(sendPort, 'postData');

    _apiResponse = result;
    notifyListeners();
  }

  static void _postDataIsolate(List<dynamic> args) async {
    SendPort sendPort = args[0];
    Map<String, dynamic> data = args[1];

    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    await for (var msg in receivePort) {
      SendPort replyTo = msg[0];
      String command = msg[1];

      if (command == 'postData') {
        List<String> response = await _postData(data);
        replyTo.send(response);
      }
    }
  }

  static Future<List<String>> _postData(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(_apiUrl),
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      dynamic decodedData = jsonDecode(response.body);

      // Check if the decoded data is a list
      if (decodedData is List) {
        List<String> result = decodedData.map((item) => item.toString()).toList();
        return result;
      } else {
        throw Exception('Invalid data type. Expected List.');
      }
    } else {
      throw Exception('Failed to post data');
    }
  }

  //Todo timer value
  int _timerValue = 0;
  int get timerValue => _timerValue;

  late Isolate _isolate;
  late ReceivePort _receivePort;

  void startTimer() async {
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_timerIsolate, _receivePort.sendPort);
    _receivePort.listen((message) {
      if (message is int) {
        _timerValue = message;
        notifyListeners();
      }
    });
  }

  static void _timerIsolate(SendPort sendPort) {
    int timerValue = 0;

    const duration = Duration(milliseconds: 1);
    Timer.periodic(duration, (Timer timer) {
      timerValue += 1;
      sendPort.send(timerValue);
    });
  }

  void stopTimer() {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
    _timerValue = 0;
    notifyListeners();
  }
}
