import 'dart:isolate';
import '../../lib/src/egb_library.dart';

import '../../lib/src/egb_runner.dart';

import '../../lib/src/egb_interface.dart';

import '../../lib/src/egb_interface_html.dart';


// this will be rewritten with the actual file
import '/Users/filiph/Programs/egamebook/dart/test/files/full_project.dart';


void main() {
  // create [ReceivePort] for this isolate
  ReceivePort receivePort = new ReceivePort();
  // create the isolate
  SendPort scripterPort = spawnFunction(createScripter);
  // create the interface
  EgbInterface interface = new HtmlInterface();
  
  new EgbRunner(receivePort, scripterPort, interface).run();
}

/**
  Top-level function which spawns the isolate containing the Scripter 
  instance (i.e. the actual egamebook).
  */
void createScripter() {
  new ScripterImpl();
}
