import 'dart:convert';
import 'dart:ffi';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mktransfert/src/contant/constant.dart';
import 'package:mktransfert/src/page/navigation.dart';
import 'package:mktransfert/src/page/pagePrincipale.dart';
import 'package:mktransfert/src/page/transaction.dart';
import 'package:mktransfert/src/utils/oval-right-clipper.dart';
import 'package:mktransfert/src/widget/round_button.dart';
import 'package:mktransfert/src/widget/round_corner_button.dart';
import 'package:mktransfert/src/widget/round_corner_image.dart';
import 'package:http/http.dart' as http;
import '../../recipients_provider.dart';
import 'AccueilBottomBar.dart';
import 'transfertRecap.dart';

class PaymentsScreen extends StatefulWidget {
  @override
  _PaymentsScreenState createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String displayUser_last_name;
  String displayUser_first_name;
  String displayUser_email;
  int amount = 10;
  double amountWaitted=10;
  double amountTotal;
  double commission;
  int _beneficiaireID;
  int _mySelectionPointRetrait;
  String _senderCurrency="";
  String _senderCurrencySymbole="";
  String _receiverCurrency;
  double _convertResult;
  int maxSlider=9999;
  double _stripeAmount;

  double _taux;
  double _conversion_eur;
  double _conversion_usd;

  var country_isdisponible;

  String _mySelectionCountry;
  var receiver_point_retait = List();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:
        IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PagePrincipale()))
        ),
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          "Envoyer de l'argent",
        ),
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: kPrimaryColor,
      body: _buildBody(),

      bottomNavigationBar: _buildButtonsSection(),
    );
  }
  displayUserInfo() async {
    var jwt = await storage.read(key: "userInfo");

    Map<String, dynamic> responseStorageUser = json.decode(jwt);
    /*editUser_first_name.text = responseStorageUser["first_name"];
    editUser_last_name.text = responseStorageUser["last_name"];
    editUser_email.text = responseStorageUser["email"];
    editUser_phone.text = responseStorageUser["phone"];
    editUser_country.text = responseStorageUser["country"];

    user_id_profil=responseStorageUser["user_id_profil"];*/

    displayUser_first_name = responseStorageUser["first_name"];
    displayUser_last_name = responseStorageUser["last_name"];
    displayUser_email = responseStorageUser["email"];
    print(displayUser_first_name);
/*    displayUser_phone = responseStorageUser["phone"];
    displayUser_country = responseStorageUser["country"];*/
  }
  _buildDrawer() {

    return ClipPath(
      clipper: OvalRightBorderClipper(),
      child: Drawer(
        child: Container(
          padding: const EdgeInsets.only(left: 16.0, right: 40),
          decoration: BoxDecoration(
              color: primary, boxShadow: [BoxShadow(color: Colors.black45)]),
          width: 300,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.power_settings_new,
                        color: active,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  Container(
                    height: 90,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [Colors.blue, Colors.deepOrange])
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage('https://firebasestorage.googleapis.com/v0/b/mktransfert-d6990.appspot.com/o/Me.png?alt=media&token=044e199c-908b-4d22-9a2c-a720e4a6c6f3'),
                    ),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    "Cephas ZOUBGA",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "cephaszoubga@gmail.com",
                    style: TextStyle(color: active, fontSize: 16.0),
                  ),
                  SizedBox(height: 30.0),
                  // _buildRow(Icons.home, "Accueil"),
                  _buildDivider(),
                  _buildRow(Icons.person_pin, "Mon profil",
                    '/existing-cards'
                  ),
                  _buildDivider(),
                  // _buildRow(Icons.message, "Messages", showBadge: true),*/
                  // _buildDivider(),
                  _buildRow(Icons.settings, "Reglages",'/existing-cards'),
                  _buildDivider(),
                  _buildRow(Icons.email, "Nous contacter",'/existing-cards'),
                  //  _buildDivider(),
                  //  _buildRow(Icons.info_outline, "Aide"),
                  _buildDivider(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Divider _buildDivider() {
    final Color divider = Colors.grey.shade600;
    return Divider(
      color: divider,
    );
  }

  Widget _buildRow(IconData icon,
      String route ,
      String title, {bool showBadge = false}) {
    final TextStyle tStyle = TextStyle(color: active, fontSize: 16.0);
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child:GestureDetector(
          onTap:()=> {
          Navigator.pushNamed(context, route),
          },
          child: Row(children: [
            Icon(
              icon,
              color: active,
            ),
            SizedBox(width: 10.0),
            Text(
              title,
              style: tStyle,
            ),
            Spacer(),
          ]),
        )
    );
  }

  Future<AlertDialog> maxAlert(BuildContext context) {
    return showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: EdgeInsets.all(8.0),
            child: Form(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                      'Pour ce montant merci de contacter MK Tranfert pour effectuer votre opération  Numéros de téléphone 0033760562143 et 0033661217174 '
                  )
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Ok"))
          ],
        );
      },
    );
  }
  displayPaymentInfo() async {
    var jwt = await storage.read(key: "jwt");
    Map<String, dynamic> responseJson = json.decode(jwt);
    String token = responseJson["access_token"];
    int user_id = responseJson["user_id"];
    var res = await http.get(
        Uri.encodeFull(
            'https://www.mktransfert.com/api/payment/' +
                '$user_id'),
        headers: {
          "Accept": "application/json",
          'Authorization': 'Bearer $token',
        }).then((value) => {
          if (value.statusCode==200){
            _senderCurrency = json.decode(value.body)['API_transac_data']['devise_sender'],
             _taux=json.decode(value.body)['API_transac_data']['taux'],
            _conversion_eur=json.decode(value.body)['API_transac_data']['conversion_eur'],
            _conversion_usd=json.decode(value.body)['API_transac_data']['conversion_usd'],
            json.decode(value.body)['point_retait']?.forEach((k, v) {
                  receiver_point_retait.add(v[0]);
                }),
              },}
              ).catchError((erreur)=>print(erreur));

            if(_senderCurrency=='eur'){
             setState(() {
               _dropdownMenuItemsReceiver.add(
                   DropdownMenuItem(
                     child: Row(
                       children: <Widget>[
                         Text('EUR'),
                         Image.asset("assets/Image/eu.png", width: 20),
                       ],
                     ),
                     value:  ListItemReceiver("assets/Image/eu.png", "EUR",2),
                   ));
               _doConversionEur();
               this._senderCurrencySymbole='€';
             });
            }
    if(_senderCurrency=='usd'){
      _dropdownMenuItemsReceiver.add(
          DropdownMenuItem(
            child: Row(
              children: <Widget>[
                Text('EUR'),
                Image.asset("assets/Image/eu.png", width: 30),
              ],
            ),
            value:  ListItemReceiver("assets/Image/us.png", "USD",2),
          ));
      this._senderCurrencySymbole='\$';
    }
  }
  @override
  Future<void> initState()  {
    super.initState();
    this.displayPaymentInfo();
    _dropdownMenuItemsReceiver = buildDropDownMenuItemsReceiver(_dropdownItemsReceiver);
    _selectedItemReceiver = _dropdownMenuItemsReceiver[0].value;
    displayUserInfo();
  }
  List<ListItemReceiver> _dropdownItemsReceiver = [
    ListItemReceiver("assets/Image/gnf.png", "GNF",1),
  /*  ListItemReceiver("assets/Image/eu.png", "EUR",2),
    ListItemReceiver("assets/Image/us.png", "USD",3),*/
  ];

  List<DropdownMenuItem<ListItemReceiver>> _dropdownMenuItemsReceiver;
  ListItemReceiver _selectedItemReceiver;

  List<DropdownMenuItem<ListItemReceiver>> buildDropDownMenuItemsReceiver(
      List listItems) {
    List<DropdownMenuItem<ListItemReceiver>> items = List();
    for (ListItemReceiver listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Row(
            children: <Widget>[
              Text(listItem.name,style: TextStyle(fontSize: 10)),
              Image.asset(listItem.imageReceiver, width: 20),
            ],
          ),
          value: listItem,
        ),
      );
    }
    return items;
  }
  Future<double> _doConversionEur() async {
    this.amountWaitted=this.amount*this._conversion_eur;
    this.commission=this.amount*this._taux;
    this.amountTotal=this.amount+this.commission;
  }
  Widget _buildBody() {
    return Container(
      margin: EdgeInsets.only(top: 50),
      height: double.maxFinite,
      width: double.maxFinite,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(48),
          topLeft: Radius.circular(48),
        ),
        color: Colors.white,
      ),
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 28,
            ),
            child: Text(
              "Combien souhaitez-vous envoyer",
              textAlign: TextAlign.center,
              style: kTextStyle.copyWith(color: Colors.grey.shade700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 50,right: 50,top: 0,bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: kAmounts.map((amount) {
                return RoundCornerButton(
                  text: amount,
                  onTap: () {
                    setState(() {
                      if (_selectedItemReceiver.name!='GNF'){
                        this.amount = int.parse(amount);
                        this.amountWaitted=this.amount.toDouble();
                        this.commission=this.amount*this._taux;
                      }
                      if (_selectedItemReceiver.name=='GNF'){
                        this.amount = int.parse(amount);
                        _doConversionEur();
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Divider(),
          _buildAmountSection(),
          _taux != null?_buildRecepientsSection():Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('En cours'),
                  CircularProgressIndicator()
                ],
              )
          ),
        ],
      ),
    );
  }
  Widget _buildDropButtonTo() {
    return Row(
      children: <Widget>[
        DropdownButtonHideUnderline(
          child: DropdownButton(
              value: _selectedItemReceiver,
              items: _dropdownMenuItemsReceiver,
              onChanged: (value) {
                setState(() {
                  _selectedItemReceiver = value;
                  if (_selectedItemReceiver.name!='GNF'){
                    this.amountWaitted=this.amount.toDouble();
                    this.commission=this.amount*this._taux;
                    this.amountTotal=this.amount+this.commission;
                  }
                  if (_selectedItemReceiver.name=='GNF'){
                    _doConversionEur();
                  }
                });
              }),
        )
      ],
    );
  }
  Widget _buildAmountSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 30,right: 30,top: 0,bottom: 0),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              RoundButton(
                onTap: () {
                  setState(() {
                    if (_selectedItemReceiver.name!='GNF'){
                      amount--;
                      this.amountWaitted=this.amount.toDouble();
                      this.commission=this.amount*this._taux;
                      this.amountTotal=this.amount+this.commission;
                    }
                    if (_selectedItemReceiver.name=='GNF'){
                      amount--;
                      _doConversionEur();
                    }
                  });
                },
                icon: Icons.remove,
              ),
              Text(
                this._senderCurrencySymbole+" "+"$amount",
                style: TextStyle(
                  color: kPrimaryColor,
                  fontSize: 40,
                ),
              ),
              RoundButton(
                onTap: () {
                  setState(() {
                    if (_selectedItemReceiver.name!='GNF'){
                      amount++;
                      if (amount>9999){
                        this.maxAlert(context);
                        amount=9999;
                      }
                      this.amountWaitted=this.amount.toDouble();
                      this.commission=this.amount*this._taux;
                      this.amountTotal=this.amount+this.commission;
                    }
                    if (_selectedItemReceiver.name=='GNF'){
                      amount++;
                      if (amount>9999){
                        this.maxAlert(context);
                        amount=9999;
                      }
                      _doConversionEur();
                    }
                  });
                },
                icon: Icons.add,
              ),
            ],
          ),
          Slider(
            value: amount.toDouble(),
            onChanged: (newValue) {
              _doConversionEur();
              setState(() {
                if (_selectedItemReceiver.name!='GNF'){
                  this.amountWaitted=this.amount.toDouble();
                  this.commission=this.amount*this._taux;
                  amount = newValue.toInt();
                }
                if (_selectedItemReceiver.name=='GNF'){
                  amount = newValue.toInt();
                  _doConversionEur();
                }
              });
            },
            min: 10,
            max: maxSlider.toDouble(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 2),
                child: Row(
                  children: <Widget>[
                    Text(
                      "$amountWaitted",
                      style: TextStyle(
                        color: kPrimaryColor,
                        fontSize: 35,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    _buildDropButtonTo()
                  ],
                ),
              )
            ],
          ),
          Divider(),
        ],
      ),
    );
  }

  Widget _buildRecepientsSection() {
    return
    Container (
      color: kBackgroundWhiteColor,
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(width: 10.0, color: kPrimaryColor),
              ),
            ),
            height: 60,
            child: Card(
              color: Theme.of(context).primaryColor,
              elevation: 3.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: ListTile(
                          leading: Text(
                            "Montant à recevoir",
                            style: TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(this.amountWaitted.toString()+'•'+_selectedItemReceiver.name,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500)),
                        )),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            margin: EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                    width: 10.0, color: Colors.black54),
              ),
            ),
            height: 60,
            child: Card(
              color: kBackgroundBorderCommissionColor,
              elevation: 3.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: ListTile(
                          leading: Text(
                            "Montant commission",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(this.commission.toString(),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500)),
                        )),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Container(
            margin: EdgeInsets.only(left: 10),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(
                    width: 10.0, color: Colors.red),
              ),
            ),
            height: 60,
            child: Card(
              color: kBackgroundBorderCommissionColor,
              elevation: 3.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: ListTile(
                          leading: Text(
                            "Montant total à payer",
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.w500),
                          ),
                          trailing: Text(this.amountTotal.toString()+'•'+_senderCurrencySymbole,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500)),
                        )),
                  )
                ],
              ),
            ),
          ),
        ],

      ),
    );

/*      Container(
      color: kBackgroundWhiteColor,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Text("Choisissez un destinataire",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600
              ),
            ),
          ),
          CarouselSlider(
            enableInfiniteScroll: true,
            items: RecipientsProvider.recipients.map((recipient) {
              return
               SingleChildScrollView(
                 child:  Column(
                   mainAxisSize: MainAxisSize.min,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   mainAxisAlignment: MainAxisAlignment.start,
                   children: <Widget>[
                     RoundCornerImage(
                       imageUrl: recipient.imageUrl,
                     ),
                     SizedBox(
                       height: 4,
                     ),
                     Text(
                       recipient.name,
                       style: TextStyle(
                         color: Theme.of(context).primaryColor,
                         fontSize: 12,
                         fontWeight: FontWeight.w600,
                       ),
                     ),
                   ],
                 ),
               );
            }).toList(),
            initialPage: 0,
            height: 150,
            viewportFraction: 0.3,
            enlargeCenterPage: true,
            scrollDirection: Axis.horizontal,
          )
        ],
      ),
    );*/
  }

  Widget _buildButtonsSection() {
    return Container(
      color: kBackgroundWhiteColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: <Widget>[
         /*   Expanded(
              child: RaisedButton(
                onPressed: () {},
                color: Colors.grey.shade300,
                textColor: Colors.grey.shade600,
                child: Text(
                  "Annuler",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(
                  8,
                ))),
              ),
            ),*/
            /*SizedBox(
              width: 16,
            ),*/
            Expanded(
              child: RaisedButton(
                onPressed: () {
                  storage.write(key: "transactionResume", value: json.encode([
                    {
                      "montant_send":this.amount,
                      "montant_receive":this.amountWaitted,
                      "transac_commission":this._taux,
                      "transac_total":this.amountTotal,
                      "devise_send":_senderCurrency,
                      "devise_send_symbol":_senderCurrencySymbole,
                      "devise_receive":_selectedItemReceiver.name
                    }
                  ]));
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ExpenseTrackerApp()),
                  );
                },
                color: kPrimaryColor,
                textColor: Colors.white,
                child: Text(
                  "Envoyer",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(
                  8,
                ))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
