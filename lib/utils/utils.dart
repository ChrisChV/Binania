import 'dart:io';

import 'package:process_run/shell.dart';

class Utils{

  /// Get the target of a [basePrice] based on [percentage]
  static double getTargetFromPercentage(double basePrice, double percentage){
    return (percentage * basePrice) / 100;
  }

  /// Runs a command
  static Future<List<ProcessResult>> runCommand(
    String command, {
    bool verbose = false,  
  }){ 
    final shell = Shell(verbose: verbose);
    return shell.run(command);
  }

}