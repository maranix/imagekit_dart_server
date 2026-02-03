import 'dart:io';

import 'package:args/args.dart';
import 'package:imagekit_dart_server/generate_signature.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

final _app = Router();
final _parser = ArgParser()
  ..addOption('private_key')
  ..addOption('address', abbr: 'a', defaultsTo: InternetAddress.anyIPv4.host)
  ..addOption('port', abbr: 'p', defaultsTo: '8080');

void main(List<String> args) async {
  final result = _parser.parse(args);
  final pk =
      result.option('private_key') ??
      Platform.environment['IMAGEKIT_PRIVATE_KEY'] ??
      const String.fromEnvironment('IMAGEKIT_PRIVATE_KEY');

  if (pk.isEmpty) {
    print("Error: Invalid ImageKit private key");
    exit(1);
  }

  print('Setting up server....');

  _app.post('/', (req) => generateSignature(req, pk));
  final handler = Pipeline().addMiddleware(logRequests()).addHandler(_app.call);

  print('Starting up server....');

  final server = await io.serve(
    handler,
    result.option('address')!,
    int.parse(result.option('port')!),
  );

  print('Server running at http://${server.address.host}:${server.port}');
}
