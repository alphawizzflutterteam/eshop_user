import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:tlkmartuser/Screen/HomePage.dart';
import '../Helper/AppBtn.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';
import '../Helper/Session.dart';
import '../Helper/String.dart';
import '../Model/Transaction_Model.dart';

class MyLoyalityHistoryWidget extends StatefulWidget {
  @override
  _MyLoyalityHistoryWidgetState createState() =>
      _MyLoyalityHistoryWidgetState();
}

class _MyLoyalityHistoryWidgetState extends State<MyLoyalityHistoryWidget>
    with TickerProviderStateMixin {
  bool _isNetworkAvail = true;
  List<TransactionModel> tranList = [];
  int offset = 0;
  int total = 0;
  bool isLoadingmore = true;
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Animation? buttonSqueezeanimation;
  AnimationController? buttonController;
  ScrollController controller = new ScrollController();
  List<TransactionModel> tempList = [];
  StateSetter? dialogState;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  TextEditingController amtC = new TextEditingController();
  @override
  void initState() {
    getLoyalty();
    controller.addListener(_scrollListener);

    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth! * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController!,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
    super.initState();
  }

  @override
  void dispose() {
    buttonController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * .296,
              width: double.maxFinite,
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/Login.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.1),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Stack(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 1,
                          child: SvgPicture.asset(
                            'assets/images/Loyalty.svg',
                            fit: BoxFit.fill,
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.height * 0.26,
                          ),
                        ),

                        Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.08),
                          padding: EdgeInsets.symmetric(horizontal: 25),
                          child: Column(
                            children: [
                              Text(
                                'Coin Balance',
                                style:
                                Theme.of(context).textTheme.headlineSmall,
                              ),
                              Text(
                                '${CUR_CURRENCY} $total',
                                style:
                                Theme.of(context).textTheme.headlineSmall,
                              )
                            ],
                          ),
                        )
                        // SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getNormalAppBar("CONIS", context),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .25,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'History',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        InkWell(
                          onTap: () {
                            if (total > 0) {
                              _showDialog();
                            } else {
                              setSnackbar('No available coins', context);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              'Reedem',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  _isNetworkAvail
                      ? _isLoading
                      ? shimmer(context)
                      : showContent()
                      : noInternet(context),
                ],
              ),
            )
          ],
        ),
      ),
    );
    // return SafeArea(
    //   child:

    //    Stack(children: [

    //     Container(
    //               height: MediaQuery.of(context).size.height * .296,
    //               width: double.maxFinite,
    //               alignment: Alignment.topLeft,
    //               decoration: BoxDecoration(
    //                 image: DecorationImage(
    //                   image: AssetImage("assets/images/Login.png"),
    //                   fit: BoxFit.contain,
    //                 ),
    //               ),

    //             ),

    //      Container(
    //       padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.1),
    //        child: Stack(
    //          children: [
    //            ClipRRect(
    //              borderRadius: BorderRadius.circular(60),
    //              child: Column(
    //                crossAxisAlignment: CrossAxisAlignment.start,
    //                children: [
    //                  SvgPicture.asset(
    //                    'assets/images/Loyalty.svg',
    //                    fit: BoxFit.fill,
    //                  ),
    //                  // SizedBox(height: 10),

    //                ],
    //              ),
    //            ),
    //          ],
    //        ),
    //      ),
    //     // Scaffold(
    //     //   backgroundColor: Colors.transparent,
    //     //   key: _scaffoldKey,
    //     //   appBar: getNormalAppBar("CONIS", context),
    //     //   body: _isNetworkAvail
    //     //       ? _isLoading
    //     //           ? shimmer(context)
    //     //           : showContent()
    //     //       : noInternet(context),)

    //           ,],),
    // );
  }

  Widget noInternet(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          noIntImage(),
          noIntText(context),
          noIntDec(context),
          AppBtn(
            title: getTranslated(context, 'TRY_AGAIN_INT_LBL'),
            btnAnim: buttonSqueezeanimation,
            btnCntrl: buttonController,
            onBtnSelected: () async {
              _playAnimation();

              Future.delayed(Duration(seconds: 2)).then((_) async {
                _isNetworkAvail = await isNetworkAvailable();
                if (_isNetworkAvail) {
                  getLoyalty();
                } else {
                  await buttonController!.reverse();
                  setState(() {});
                }
              });
            },
          )
        ]),
      ),
    );
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController!.forward();
    } on TickerCanceled {}
  }

  Future<Null> getLoyalty() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {"type": "credit", 'transaction_type': "loyality"};

        if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
        //   if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
        print("loyalty is $parameter");
        Response response =
        await post(getWalTranApi, headers: headers, body: parameter)
            .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          // String msg = getdata["message"];

          if (!error) {
            total = double.parse(getdata["balance"] ?? '0').toInt();

            if ((offset) < total) {
              tempList.clear();
              var data = getdata["data"];
              tempList = (data as List)
                  .map((data) => new TransactionModel.fromJson(data))
                  .toList();
              tranList.addAll(tempList);
              offset = offset + perPage;
            }
          } else {
            isLoadingmore = false;
          }
        }
        if (mounted)
          setState(() {
            _isLoading = false;
          });
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!, context);

        setState(() {
          _isLoading = false;
          isLoadingmore = false;
        });
      }
    } else
      setState(() {
        _isNetworkAvail = false;
      });

    return null;
  }

  // setSnackbar(String msg) {
  //   ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
  //     content: new Text(
  //       msg,
  //       textAlign: TextAlign.center,
  //       style: TextStyle(color: Theme.of(context).colorScheme.black),
  //     ),
  //     backgroundColor: Theme.of(context).colorScheme.white,
  //     elevation: 1.0,
  //   ));
  // }

  showContent() {
    // return Stack(
    //   children: [
    //     Align(
    //       alignment: Alignment.topCenter,
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           // Container(
    //           //   height: MediaQuery.of(context).size.height * .296,
    //           //   width: double.maxFinite,
    //           //   alignment: Alignment.topLeft,
    //           //   decoration: BoxDecoration(
    //           //     image: DecorationImage(
    //           //       image: AssetImage("assets/images/Login.png"),
    //           //       fit: BoxFit.contain,
    //           //     ),
    //           //   ),
    //           //   child: Row(
    //           //     children: [
    //           //       IconButton(
    //           //         onPressed: () {},
    //           //         icon: Icon(
    //           //           Icons.arrow_back,
    //           //           color: colors.whiteTemp,
    //           //         ),
    //           //       ),
    //           //       Spacer(),
    //           //       Text(
    //           //         "Coins",
    //           //         style: TextStyle(fontSize: 18, color: colors.whiteTemp),
    //           //       ),
    //           //       Spacer(),
    //           //       IconButton(
    //           //         onPressed: () {},
    //           //         icon: Icon(
    //           //           Icons.favorite_border,
    //           //           color: colors.whiteTemp,
    //           //         ),
    //           //       ),
    //           //       IconButton(
    //           //         onPressed: () {},
    //           //         icon: Icon(
    //           //           Icons.notifications_none,
    //           //           color: colors.whiteTemp,
    //           //         ),
    //           //       ),
    //           //     ],
    //           //   ),
    //           // ),
    //         ],
    //       ),
    //     ),
    //     // Positioned(
    //     //   top: MediaQuery.of(context).size.height * .1,
    //     //   left: 5,
    //     //   right: 5,
    //     //   child: ClipRRect(
    //     //     borderRadius: BorderRadius.circular(60),
    //     //     child: Column(
    //     //       crossAxisAlignment: CrossAxisAlignment.start,
    //     //       children: [
    //     //         SvgPicture.asset(
    //     //           'assets/images/Loyalty.svg',
    //     //           fit: BoxFit.fill,
    //     //         ),
    //     //         // SizedBox(height: 10),
    //     //         Text(
    //     //           'History',
    //     //           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    //     //         ),
    //     //         SizedBox(height: 20),
    //     //         Text(
    //     //           ' Anshul Sharma',
    //     //           style: TextStyle(fontSize: 18),
    //     //         ),
    //     //         Text('02'),
    //     //       ],
    //     //     ),
    //     //   ),
    //     // ),
    //   ],
    // );

    return tranList.length == 0
        ? Container(
        height: MediaQuery.of(context).size.height * 0.2,
        child: getNoItem(context))
        : Expanded(
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _refresh,
        child: ListView.builder(
          shrinkWrap: true,
          controller: controller,
          itemCount: tranList.length,
          //       1, //(offset < total) ? tranList.length + 1 : tranList.length,
          physics: AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return (index == tranList.length && isLoadingmore)
                ? Center(child: CircularProgressIndicator())
                : listItem(index);
          },
        ),
      ),
    );
  }

  listItem(int index) {
    Color back;
    if (tranList[index].status!.toLowerCase().contains("success")) {
      back = Colors.green;
    } else if (tranList[index].status!.toLowerCase().contains("failure"))
      back = Colors.red;
    else
      back = Colors.orange;
    return Card(
      elevation: 0,
      margin: EdgeInsets.all(5.0),
      child: InkWell(
          borderRadius: BorderRadius.circular(4),
          child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            getTranslated(context, 'AMOUNT')! +
                                " : " +
                                CUR_CURRENCY! +
                                " " +
                                tranList[index].amt!,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.fontColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(tranList[index].date!),
                      ],
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          // Expanded(
                          //   child: Text(
                          //       getTranslated(context, 'ORDER_ID_LBL')! +
                          //           " : " +
                          //           tranList[index].orderId!),
                          // ),
                          Container(
                            margin: EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                                color: back,
                                borderRadius: new BorderRadius.all(
                                    const Radius.circular(4.0))),
                            child: Text(
                              tranList[index].status!,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.white),
                            ),
                          )
                        ],
                      ),
                    ),
                    tranList[index].type != null &&
                        tranList[index].type!.isNotEmpty
                        ? Text(getTranslated(context, 'PAYMENT_METHOD_LBL')! +
                        " : " +
                        tranList[index].type!)
                        : Container(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: tranList[index].msg != null &&
                          tranList[index].msg!.isNotEmpty
                          ? Text(getTranslated(context, 'MSG')! +
                          " : " +
                          tranList[index].msg!)
                          : Container(),
                    ),
                    tranList[index].txnID != null &&
                        tranList[index].txnID!.isNotEmpty
                        ? Text(getTranslated(context, 'Txn_id')! +
                        " : " +
                        tranList[index].txnID!)
                        : Container(),
                  ]))),
    );
  }

  _scrollListener() {
    if (controller.offset >= controller.position.maxScrollExtent &&
        !controller.position.outOfRange) {
      if (this.mounted) {
        if (mounted)
          setState(() {
            isLoadingmore = true;

            if (offset < total) getLoyalty();
          });
      }
    }
  }

  Future _refresh() {
    return getLoyalty();
  }

  _showDialog() async {
    await dialogAnimate(context,
        StatefulBuilder(builder: (BuildContext context, StateSetter setStater) {
          dialogState = setStater;
          return AlertDialog(
            contentPadding: const EdgeInsets.all(0.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 20.0, 0, 2.0),
                    child: Text(
                      'Reedem Coin',
                      style: Theme.of(this.context)
                          .textTheme
                          .subtitle1!
                          .copyWith(color: Theme.of(context).colorScheme.fontColor),
                    ),
                  ),
                  Divider(color: Theme.of(context).colorScheme.lightBlack),
                  Form(
                    key: _formkey,
                    child: Flexible(
                      child: SingleChildScrollView(
                          child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Padding(
                                    padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      validator: (val) => validateField(val!,
                                          getTranslated(context, 'FIELD_REQUIRED')),
                                      autovalidateMode:
                                      AutovalidateMode.onUserInteraction,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.fontColor,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: getTranslated(context, "AMOUNT"),
                                        hintStyle: Theme.of(this.context)
                                            .textTheme
                                            .subtitle1!
                                            .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .lightBlack,
                                            fontWeight: FontWeight.normal),
                                      ),
                                      controller: amtC,
                                    )),
                                Divider(),
                              ])),
                    ),
                  )
                ]),
            actions: <Widget>[
              new TextButton(
                  child: Text(
                    "Redeem",
                    style: Theme.of(this.context).textTheme.subtitle2!.copyWith(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    final form = _formkey.currentState!;
                    if (form.validate() && amtC!.text != '0') {
                      form.save();

                      if (total > int.parse(amtC.text ?? '0')) {
                        reedenCoinItem(Coin: amtC.text);
                      } else {
                        setSnackbar('please enter valid number', context);
                      }
                    }
                  })
            ],
          );
        }));
  }

  void reedenCoinItem({required String Coin}) {
    Map<String, String> parameter = {
      "coin": Coin,
    };
    if (CUR_USERID != null) parameter[USER_ID] = CUR_USERID!;
    apiBaseHelper.postAPICall(convertWalletProduct, parameter).then(
            (getdata) async {
          bool error = getdata["error"];
          String? msg = getdata["message"];
          if (!error) {
            setSnackbar(msg!, context);
          } else {
            setSnackbar(msg!, context);
          }
        }, onError: (error) {
      setSnackbar(error.toString(), context);
    });
  }
}
