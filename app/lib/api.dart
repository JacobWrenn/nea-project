import 'dart:convert';

import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart';
import 'package:jwt_decode/jwt_decode.dart';

class Api {
  // use factory constructors to create a singleton
  static final Api _api = Api._internal();

  factory Api() {
    return _api;
  }

  Api._internal();

  final String server = "http://localhost:8080";
  String token = "";

  Future<String> restore() async {
    String token = await FlutterKeychain.get(key: "intelligentlogin");
    if (token != null) {
      this.token = token;
      Map<String, dynamic> parsed = Jwt.parseJwt(token);
      return parsed["accesslevel"];
    }
    return "";
  }

  Future<String> login() async {
    String url = await FlutterWebAuth.authenticate(
        url: "$server/auth/login?redirect=intelligentlogin://auth",
        callbackUrlScheme: "intelligentlogin");
    return await checkAuth(url);
  }

  Future<String> register() async {
    String url = await FlutterWebAuth.authenticate(
        url: "$server/auth/register?redirect=intelligentlogin://auth",
        callbackUrlScheme: "intelligentlogin");
    return await checkAuth(url);
  }

  Future<String> checkAuth(String url) async {
    // use the built-in url parser to extract the JWT from the url
    String token = Uri.parse(url).queryParameters["token"];
    this.token = token;
    await FlutterKeychain.put(key: "intelligentlogin", value: token);
    return Jwt.parseJwt(token)["accesslevel"];
  }

  Future logout() async {
    await FlutterKeychain.clear();
    this.token = "";
  }

  Future makeGet(String url, Map<String, String> headers) async {
    // use the spread syntax to combine specified headers with the auth token
    Response res = await get(Uri.parse("$server$url"),
        headers: {"token": this.token, ...headers});
    return jsonDecode(res.body);
  }

  Future makePost(String url, Map<String, String> headers,
      Map<String, dynamic> body) async {
    Response res = await post(Uri.parse("$server$url"),
        headers: {
          "token": this.token,
          // content-type must be set to JSON for express to parse body correctly
          "content-type": "application/json",
          ...headers
        },
        body: jsonEncode(body));
    return jsonDecode(res.body);
  }

  Future makeDelete(String url, Map<String, String> headers,
      Map<String, dynamic> body) async {
    Response res = await delete(Uri.parse("$server$url"),
        headers: {
          "token": this.token,
          "content-type": "application/json",
          ...headers
        },
        body: jsonEncode(body));
    return jsonDecode(res.body);
  }
}
