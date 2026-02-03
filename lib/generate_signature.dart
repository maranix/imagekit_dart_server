import 'dart:convert' as convert;

import 'package:crypto/crypto.dart' as crypto;
import 'package:shelf/shelf.dart' show Response, Request;
import 'package:imagekit_dart_server/utils.dart';

Response generateSignature(Request request, String imgKitPK) {
  if (imgKitPK.isEmpty) {
    return Response.internalServerError(body: 'Invalid private key');
  }

  final token = request.url.queryParameters['token'] ?? uuid4();
  final expire =
      request.url.queryParameters['expire'] ??
      ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1800).toString();

  final signatureData = "$token$expire";

  final hmac = crypto.Hmac(crypto.sha1, convert.utf8.encode(imgKitPK));
  final signature = hmac.convert(convert.utf8.encode(signatureData)).toString();

  return Response.ok(
    convert.jsonEncode({
      'token': token,
      'expire': expire,
      'signature': signature,
    }),
  );
}
