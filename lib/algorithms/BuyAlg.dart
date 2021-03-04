import 'package:binania/algorithms/Alg.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';

abstract class BuyAlg extends Alg{

  double quoteBuyAmout;
  double selledPrice;
  double initialBottom;
  double initialTop;
  double bottomRange;
  double topRange;
  AlgBuyType algBuyType;


  Function(Map<String, dynamic>) onBuy;

  /// Inits the buy algorythm
  @override
  void init({
    double quoteBuyAmout,
    RangeType rangeType,
    double initialBottom,
    double initialTop,
    double bottomRange,
    double topRange,
    double selledPrice,
  });

  /// Prints the actual state of this algorithm
  @override
  void printActualState(){
    print('=========================================================');
    print('Buy state at [' + DateTime.now().toString() + ']');
    print('Symbol: ' + symbol);
    print('Selled Price: ' + selledPrice.toString());
    print('Top line: ' + topLine.toString());
    print('Mid line: ' + midLine.toString());
    print('Bottom line: ' + bottomLine.toString());
  }


}