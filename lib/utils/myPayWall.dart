import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:onepref/onepref.dart';

class MyPayWall extends StatefulWidget {
  const MyPayWall({super.key});

  @override
  State<MyPayWall> createState() => _MyPayWallState();
}

class _MyPayWallState extends State<MyPayWall> {
  late final List<ProductDetails> _products = <ProductDetails>[];
  late final List<PurchaseDetails> _currentPurchaseDetails =
      <PurchaseDetails>[];

  // create a new instance of this class
  IApEngine iApEngine = IApEngine();
  bool isSubscribed = false;
  bool oneTimeProductPurchased = false;

  bool subExisting = false;

  //Use ProductId type to create product ids
  final List<ProductId> _productsIds = [
    ProductId(id: "monthly", isConsumable: false, isOneTimePurchase: true),
    ProductId(id: "yearly", isConsumable: false, isOneTimePurchase: true),
  ];

  @override
  void initState() {
    super.initState();

    isSubscribed = OnePref.getPremium()!;

    iApEngine.inAppPurchase.purchaseStream.listen(
      (purchaseDetailsList) {
        //listen to the purchases, it will be called everytime there's a purchase or restore purchase.
        if (purchaseDetailsList.isNotEmpty) {
          _currentPurchaseDetails.addAll(purchaseDetailsList);
          print(_currentPurchaseDetails[0].productID);
        }

        listener(purchaseDetailsList);
      },
      onDone: () {
        print("onDone");
      },
      onError: (Object error) {
        print("onError");
      },
    );

    //get products
    getProducts();
  }

  void listener(List<PurchaseDetails> purchaseDetailsList) async {
    //Add the purchaseListener function
    await iApEngine
        .purchaseListener(
          purchaseDetailsList: purchaseDetailsList,
          productsIds: _productsIds,
        )
        .then((value) {
          if (value == null) {
            return;
          }
          // Value will be a Map
          // key - message  = This explains the object
          // key - purchaseComplete: boolean = shows that the purchase has been purchased
          // key - purchaseRestore: boolean = shows that there was a subscription or one time purchase that is restore
          // key - purchaseConsumed: boolean = shows that the consumable item is consumed and ready to be bought again.
          // key - productId: String = The product Id purchased or restored

          // How to get the values using the keys
          // value['purchaseComplete'] = will result to either false or true

          if (value['purchaseRestore'] || value['purchaseComplete']) {
            subExisting = true;
            print("listener123: restored or purchased");
          }
        });
  }

  void getProducts() async {
    // This method will handle the query of products from the store.
    await iApEngine.getIsAvailable().then(
      (value) async => {
        if (value)
          {
            await iApEngine
                .queryProducts(_productsIds)
                .then(
                  (value) => {
                    setState(() {
                      _products.addAll(value.productDetails);
                    }),
                  },
                ),
          },
      },
    );

    print(_products.length.toString() + "hello----");
  }

  //added this function to handle the subscription and one timme purchase
  void updateOneTimePurchaseAndSubscritpion(var purchasedProductId) {
    //  get the ProductId Object from the productIds
    var productId =
        _productsIds.where((element) => element.id == purchasedProductId).first;

    if (productId.isOneTimePurchase ?? false) {
      setState(() {
        oneTimeProductPurchased = true;
        OnePref.setBool("oneTimePurchase", true);
      });
    } else if (productId.isSubscription ?? false) {
      setState(() {
        OnePref.setPremium(true); // activate the premium
        isSubscribed = OnePref.getPremium() ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * .85,
      width: size.width,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/theraphy.png',
            height: size.height * .2,
            width: size.width * .3,
          ),
          SizedBox(height: size.height * .02),
          Text(
            'AI Theraphy Pro Access',
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: size.height * .018,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * .02),
          Text(
            'AI Theraphy Pro has the following advantages;',
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: size.height * .018,
              fontWeight: FontWeight.bold,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '.ChatGPT 4 latest model access and more.',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: size.height * .018,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '.Full App full access.',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: size.height * .018,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '.Best Theraphy assist.',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: size.height * .018,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '.Full help and support.',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: size.height * .018,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '.Advance theraphist.',
                style: GoogleFonts.roboto(
                  color: Colors.black,
                  fontSize: size.height * .018,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * .02),
          Text(
            'AI Theraphy subcription plans',
            style: GoogleFonts.roboto(
              color: Colors.black,
              fontSize: size.height * .018,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: size.height * .02),
          SizedBox(
            height: size.height * .3,
            // color: Colors.green,
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (_, index) {
                final plan = _products[index];
                return Padding(
                  padding: EdgeInsets.all(3),
                  child: GestureDetector(
                    onTap:
                        () => iApEngine.handlePurchase(
                          _products[index],
                          _productsIds,
                        ),
                    child: Container(
                      height: size.height * .1,
                      padding: EdgeInsets.all(5),
                      width: size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                plan.description,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: size.height * .018,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                plan.price,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: size.height * .018,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                '.Powerful AI',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: size.height * .018,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '.Helpful AI',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: size.height * .018,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
