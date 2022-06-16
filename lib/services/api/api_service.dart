import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:tare/exceptions/api_connection_exception.dart';
import 'package:workmanager/workmanager.dart';

class ApiService {
  var box = Hive.box('unTaReBox');
  late String? token;
  late String? baseUrl;

  ApiService() {
    token = box.get('token');
    baseUrl = box.get('url');
  }

  Future httpGet(String url) async {
    Request request = prepareRequest('get', url);
    return sendRequest(request);
  }

  Future httpPost(String url, data) async {
    Request request = prepareRequest('post', url, jsonBody: data);
    return sendRequest(request);
  }

  Future httpPut(String url, data) async {
    Request request = prepareRequest('put', url, jsonBody: data);
    return sendRequest(request);
  }

  Future httpPatch(String url, data) async {
    Request request = prepareRequest('patch', url, jsonBody: data);
    return sendRequest(request);
  }

  Future httpDelete(String url) async {
    Request request = prepareRequest('delete', url);
    return sendRequest(request);
  }

  Future httpPutImage(String url, image) async {
    Map<String, String> headers = getHeaders();

    File file = File(image.path);

    var request = MultipartRequest('put', Uri.parse(baseUrl! + url));
    request.files.add(new MultipartFile('image', file.readAsBytes().asStream(), file.lengthSync(), filename: image.path.split('/').last));
    request.headers.addAll(headers);

    return sendRequest(request);
  }

  Map<String, String> getHeaders() {
    Map<String, String> headers = {
      'content-type': 'application/json',
      'authorization': 'token ' + (token ?? ''),
      'charset': 'UTF-8'
    };

    return headers;
  }

  Request prepareRequest(String method, String url, {Map<String, dynamic>? jsonBody}) {
    Map<String, String> headers = getHeaders();

    Request request = Request(method, Uri.parse(baseUrl! + url));

    request.headers.addAll(headers);

    if (jsonBody != null) {
      request.body = jsonEncode(jsonBody);
    }

    return request;
  }

  Future sendRequest(BaseRequest request) async {
    try {
      Response response = await Response.fromStream(await request.send());

      if (response.statusCode == 401) {
        box.clear();
      }

      return response;
    } catch (e) {
      // On connection issue, save request to queue and retry later. Exclude get requests
      // @todo handle image
      if (e is HandshakeException || e is SocketException || e is HttpException) {
        if (request.method != 'get' && request is Request) {
          Workmanager().registerOneOffTask(
            'retryFailedRequestTask',
            'retryFailedRequestTask',
            inputData: {
              'method': request.method,
              'url': request.url.toString(),
              'jsonBody': (request.body != '') ? request.body : null
            },
            constraints: Constraints(networkType: NetworkType.connected),
            existingWorkPolicy: ExistingWorkPolicy.append,
            initialDelay: Duration(minutes: 1)
          );
        }

        throw new ApiConnectionException();
      } else {
        throw e;
      }
    }
  }

  Future retryRequest(Map<String, dynamic> requestData) async {
    Map<String, String> headers = getHeaders();

    // Build and retry request
    Request request = Request(requestData['method'], Uri.parse(requestData['url']));
    request.headers.addAll(headers);

    if (requestData['jsonBody'] != null) {
      request.body = requestData['jsonBody'];
    }

    try {
      await sendRequest(request);
    } catch(e){
      // Ignore error
    }
  }
}