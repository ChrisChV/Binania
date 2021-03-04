import 'package:binania/algorithms/Alg.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';

abstract class SellAlg extends Alg{

  double buyedPrice;
  double initialLose;
  double initialEarn;
  double loseRange;
  double earnRange;
  AlgSellType algSellType;

  Function(Map<String, dynamic>) onSell;

  /// Inits the sell algorythm
  @override
  void init({
    double buyedPrice,
    RangeType rangeType,
    double initialLose,
    double initialEarn,
    double loseRange,
    double earnRange,
  });
  
  /// Prints the actual state of this pibot sell
  @override
  void printActualState(){
    print('=========================================================');
    print('Sell state at [' + DateTime.now().toString() + ']');
    print('Symbol: ' + symbol);
    print('Buyed Price: ' + buyedPrice.toString());
    print('Top line: ' + topLine.toString());
    print('Mid line: ' + midLine.toString());
    print('Bottom line: ' + bottomLine.toString());
  }


}