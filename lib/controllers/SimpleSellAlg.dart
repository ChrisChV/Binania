import 'package:binania/algorithms/PibotSell.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';

class SimpleSellAlg{

  AlgSellType algSellType;
  String symbol;

  SimpleSellAlg(
    this.symbol,
    this.algSellType,
  );

  /// Runs the algorithm
  void runAlg(
    double buyedPrice,
    RangeType rangeType,
    double initialLose,
    double initialEarns,
    double loseRange,
    double earnRange, {
    Function(Map<String, dynamic>) onSell  
  }){
    switch(algSellType){
      case AlgSellType.pibotSell:
        PibotSell alg = PibotSell(
          symbol: symbol,
          buyedPrice: buyedPrice,
          rangeType: rangeType,
          initialLose: initialLose,
          initialEarn: initialEarns,
          loseRange: loseRange,
          earnRange: earnRange,
          onSell: onSell,
        );
        alg.init();
    }
  }

}