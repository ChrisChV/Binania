import 'dart:io';

import 'package:binania/algorithms/PibotSell.dart';
import 'package:binania/controllers/MultipleAlg.dart';
import 'package:binania/services/BinanceService.dart';
import 'package:binania/utils/enums/AlgEnums.dart';
import 'package:binania/utils/enums/PibotEnums.dart';
import 'package:get_it/get_it.dart';

Future<void> main(List<String> arguments) async{

  Set<String> tt = Set();
  tt.add("aa");
  tt.add("aa");
  print(tt);

  /*
  GetIt.I.registerSingleton<BinanceService>(BinanceService());
  await GetIt.I<BinanceService>().init(
    
  );
  MultipleAlg multipleAlg = MultipleAlg(
    "SUSHIUSDT",
    AlgBuyType.dynamicPibotBuy,
    AlgSellType.dynamicPibotSell,
  );

/*
  multipleAlg.runSellFirst(
    RangeType.percentage,
    60,
    321312312312, // Buyed price
    null,
    null,
    null,
    null,
    null,
    null,
    312321321, /// Lose Range,
    null,
    null,
    null,
    null,
    1212122, /// Top Range,
  );
  */

  multipleAlg.runBuyFirst(
    RangeType.percentage,
    60,
    null,
    null,
    null,
    null,
    null,
    null,
    null,
    2.5, /// Top range
    null,
    null,
    2.0, /// lose range,
    null,
    selledPrice: 17.350
  );




  /*
  MultipleAlg multipleAlg = MultipleAlg(
    "SUSHIUSDT",
    AlgBuyType.pibotBuy,
    AlgSellType.pibotSell,
  );


  multipleAlg.runSellFirst(
    RangeType.target,
    60,
    17.758,
    0.150,
    0.473,
    0.199,
    0.341,
    0.150,
    0.473,
    0.199,
    0.341,
    0.243,
    0.297,
    0.251,
    0.320,
  );


  multipleAlg.runBuyFirst(
    RangeType.target,
    60,
    0.448,
    0.465,
    0.398,
    0.499,
    0.243,
    0.297,
    0.251,
    0.320,
    0.150,
    0.473,
    0.199,
    0.341,
    selledPrice: 17.840
  );
  */
  */

}
