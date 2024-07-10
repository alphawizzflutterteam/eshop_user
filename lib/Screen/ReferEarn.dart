import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:tlkmartuser/Helper/AppBtn.dart';
import 'package:tlkmartuser/Helper/Session.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share/share.dart';
import 'package:tlkmartuser/Model/Transaction_Model.dart';
import 'package:tlkmartuser/Provider/HomeProvider.dart';
import '../Helper/Color.dart';
import '../Helper/SimBtn.dart';
import '../Helper/Constant.dart';
import '../Helper/String.dart';

class ReferEarn extends StatefulWidget {
  @override
  _ReferEarnState createState() => _ReferEarnState();
}

class _ReferEarnState extends State<ReferEarn> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _isNetworkAvail = true;
  List<TransactionModel> tranList = [];
  int total = 0;

  @override
  void initState() {
    // TODO: implement initState

    getTransaction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: getSimpleAppBar(getTranslated(context, 'REFEREARN')!, context),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.1,
                child: SvgPicture.asset(
                  "assets/images/refer.svg",color: colors.primary,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  getTranslated(context, 'REFEREARN')!,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Theme.of(context).colorScheme.fontColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  getTranslated(context, 'REFER_TEXT')!,
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  getTranslated(context, 'YOUR_CODE')!,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Theme.of(context).colorScheme.fontColor),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: new BoxDecoration(
                    border: Border.all(
                      width: 1,
                      style: BorderStyle.solid,
                      color: colors.secondary,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      REFER_CODE!,
                      style: Theme.of(context).textTheme.subtitle1!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor),
                    ),
                  ),
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.lightWhite,
                      borderRadius:
                          new BorderRadius.all(const Radius.circular(4.0))),
                  child: Text(
                    getTranslated(context, 'TAP_TO_COPY')!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.button!.copyWith(
                          color: Theme.of(context).colorScheme.fontColor,
                        ),
                  ),
                ),
                onPressed: () {
                  Clipboard.setData(new ClipboardData(text: REFER_CODE ?? ""));
                  // setSnackbar('Refercode Copied to clipboard');
                  Fluttertoast.showToast(
                      msg: 'Refercode Copied to clipboard',
                      backgroundColor: colors.primary);
                },
              ),
              SimBtn(
                size: 0.8,
                title: getTranslated(context, "SHARE_APP"),
                onBtnSelected: () {
                  var str =
                      "$appName\nRefer Code:$REFER_CODE\n${getTranslated(context, 'APPFIND')}$androidLink$packageName\n\n${getTranslated(context, 'IOSLBL')}\n$iosLink$iosPackage";
                  Share.share(str);
                },
              ),
              Container(
                child: Text(
                  'Referral Member & Amount',
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(color: Theme.of(context).colorScheme.fontColor),
                ),
              ),
              Selector<HomeProvider, bool>(
                selector: (_, homeProvider) => homeProvider.referralLoading,
                builder: (context, value, child) {
                  return _isNetworkAvail
                      ? value
                          ? shimmer(context)
                          : showContent()
                      : Container();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  showContent() {
    return tranList.length == 0
        ? Container(
            height: MediaQuery.of(context).size.height * 0.2,
            child: getNoItem(context))
        : ListView.builder(
            shrinkWrap: true,
            itemCount: tranList.length,
            physics: AlwaysScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return listItem(index);
            },
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
                          Expanded(
                            child: Text(
                                getTranslated(context, 'ORDER_ID_LBL')! +
                                    " : " +
                                    tranList[index].orderId!),
                          ),
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

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      new SnackBar(
        content: new Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.black),
        ),
        backgroundColor: Theme.of(context).colorScheme.white,
        elevation: 1.0,
      ),
    );
  }

  Future<Null> getTransaction() async {
    _isNetworkAvail = await isNetworkAvailable();
    if (_isNetworkAvail) {
      try {
        var parameter = {
          USER_ID: CUR_USERID,
          "type": "credit",
          "transaction_type": "refferal"
        };

        Response response =
            await post(getWalTranApi, headers: headers, body: parameter)
                .timeout(Duration(seconds: timeOut));

        if (response.statusCode == 200) {
          var getdata = json.decode(response.body);
          bool error = getdata["error"];
          String msg = getdata["message"];

          if (!error) {
            total = int.parse(getdata["total"]);
            var data = getdata["data"];
            tranList = (data as List)
                .map((data) => new TransactionModel.fromJson(data))
                .toList();
          } else {
            setSnackbar(msg);
          }
        } else {
          setSnackbar(getTranslated(context, 'somethingMSg')!);
        }
        context.read<HomeProvider>().setReferralLoading(false);
      } on TimeoutException catch (_) {
        setSnackbar(getTranslated(context, 'somethingMSg')!);
        context.read<HomeProvider>().setReferralLoading(false);
      }
    } else
      setSnackbar('NO INTERNET CONNECTION');
    context.read<HomeProvider>().setReferralLoading(false);
    return null;
  }
}
