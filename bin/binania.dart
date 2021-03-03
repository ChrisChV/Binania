import 'dart:io';

import 'package:binania/algorithms/PibotSell.dart';
import 'package:binania/services/BinanceService.dart';
import 'package:binania/utils/enums/PibotEnums.dart';

void main(List<String> arguments) {
  PibotSell pibotSell = PibotSell(
    symbol: 'SUSHIUSDT',
    rangeType: RangeType.target,
    buyedPrice: 17.366,
    initialEarn: 1.122,
    initialLose: 0.640,
    earnRange: 0.721,
    loseRange: 0.509,
    onSell: (sellPrice){
      exit(0);
    }
  );
}
