import 'dart:async';

import 'package:binance/binance.dart';
import 'package:binania/services/BinanceService.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';
import 'package:binania/utils/utils.dart';

abstract class Alg{

  String symbol;
  double midLine;
  double topLine;
  double bottomLine;
  int actualIteration;
  RangeType rangeType;

  BinanceService binanceService;
  Stream<WsAggregatedTrade> tradeStream;
  StreamSubscription<WsAggregatedTrade> tradeSubscription;

  /// Init the algorithm
  void init();

  /// Prints the actual state of the algorithm
  void printActualState();

  /// Handle each trade with the price change
  void handleTrades(WsAggregatedTrade trade);

  /// Calculates the top line from the middle line in [range]
  void calculateTopLine(double range){
    switch(rangeType){
      case RangeType.target:
        topLine = midLine + range;
        break;
      case RangeType.percentage:
        topLine = midLine + Utils.getTargetFromPercentage(midLine, range);
        break;
    }
  }

  /// Calculates the bottom line from the middle line in [range]
  void calculateBottomLine(double range){
    switch(rangeType){
      case RangeType.target:
        bottomLine = midLine - range;
        break;
      case RangeType.percentage:
        bottomLine = midLine - Utils.getTargetFromPercentage(midLine, range);
    }
  }


}