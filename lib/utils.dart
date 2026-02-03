import 'package:uuid/uuid.dart';

final _uuid = Uuid();

String uuid4() => _uuid.v4();
