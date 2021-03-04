import 'package:binania/algorithms/PibotBuy.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';

class SimpleBuyAlg{

  AlgBuyType algBuyType;
  String symbol;

  SimpleBuyAlg(
    this.symbol,
    this.algBuyType,
  );

  /// Runs the algorithm
  void runAlg(
    double quoteBuyAmount,
    RangeType rangeType,
    double initialBottom,
    double initialTop,
    double bottomRange,
    double topRange,
    double selledPrice,
    Function(Map<String, dynamic>) onBuy
  ){
    switch(algBuyType){
      case AlgBuyType.pibotBuy:
        PibotBuy pibotBuy = PibotBuy(
          symbol: symbol,
          quoteBuyAmout: quoteBuyAmount,
          rangeType: rangeType,
          initialBottom: initialBottom,
          initialTop: initialTop,
          bottomRange: bottomRange,
          topRange: topRange,
          selledPrice: selledPrice,
          onBuy: onBuy,
        );
        break;
    }    
  }


}