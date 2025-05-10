import 'dart:io';

import 'package:ai_therapy/NavPage.dart';
import 'package:ai_therapy/constants/inappPurchase/inAppPurchase.dart';
import 'package:ai_therapy/onBoardingPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:onepref/onepref.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initPlatformState();
  await dotenv.load(fileName: ".env");
  await OnePref.init();
  //  IAPConnection.instance = TestIAPConnection();
  runApp(const MyApp());
}

Future<void> initPlatformState() async {
  await Purchases.setDebugLogsEnabled(true);

  // PurchasesConfiguration configuration;
  // if (Platform.isAndroid) {
  //   configuration = PurchasesConfiguration('goog_SOVOhpSRFzefFivgzfzJYhVkUzs');
  //   // if (buildingForAmazon) {
  //   //   // use your preferred way to determine if this build is for Amazon store
  //   //   // checkout our MagicWeather sample for a suggestion
  //   //   configuration = AmazonConfiguration(<revenuecat_project_amazon_api_key>);
  //   // }
  // } else if (Platform.isIOS) {
  //   configuration = PurchasesConfiguration('appl_uUYxLHNWotdZanfeLacuDxAWgSq');
  // }

  //TODO: Add your API key here
  // await Purchases.configure(
  //   Platform.isIOS
  //       ? PurchasesConfiguration('appl_qnvzQyewXfTKkLFIMiPwwcsNkAT')
  //       : PurchasesConfiguration(''),
  // );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serenity AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: OnBoardingPage(),
    );
  }
}


/*
echo "# serenity-Ai" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/nestsoft-dev/serenity-Ai.git
git push -u origin main
*/