import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:mktransfert/core/presentation/res/assets.dart';
import 'package:mktransfert/network_image.dart';
import 'package:mktransfert/src/contant/constant.dart';
import 'package:mktransfert/src/page/loginPage.dart';


class AccueilPage extends StatefulWidget {
  static final String path = "lib/src/pages/onboarding/intro6.dart";
  @override
  _AccueilPageState createState() => _AccueilPageState();
}

class _AccueilPageState extends State<AccueilPage> {
  SwiperController _controller = SwiperController();
  int _currentIndex = 0;
  final List<String> titles = [
    "Bienvenu",
    "Transfert d'argent",
    "Mk transfert mobile",
  ];
  final List<String> subtitles = [
    "L'application mobile de transfert",
    "Envoyez de l'argent partout en Guinée",
    "Avec des taux défiants toutes concurrences."
  ];
  final List<Color> colors = [
     kPrimaryColor,
    Colors.blue.shade300,
    Colors.indigo.shade300,
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Swiper(
            loop: false,
            index: _currentIndex,
            onIndexChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            controller: _controller,
            pagination: SwiperPagination(
              builder: DotSwiperPaginationBuilder(
                activeColor: Colors.red,
                activeSize: 20.0,
              ),
            ),
            itemCount: 3,
            itemBuilder: (context, index) {
              return IntroItem(
                title: titles[index],
                subtitle: subtitles[index],
                bg: colors[index],
                imageUrl: introIllus[index],
              );
            },
          ),
         Container(
           margin: EdgeInsets.only(top: 30),
           child: Column(
             mainAxisAlignment:
             MainAxisAlignment.spaceBetween,
             crossAxisAlignment: CrossAxisAlignment.stretch,
             children: [
               Align(
                 alignment: Alignment.topRight,
                 child: RaisedButton(
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(20.0),
                   ),
                   child: SizedBox(
                      width: 50,
                      child: Row(
                        children: [
                          Text("Accueil", style: TextStyle(
                              color: Colors.white))
                        ],
                      ),
                   ),
                   onPressed: () {
                     Navigator.push(context, MaterialPageRoute(
                         builder: (context) => LoginPage())
                     );
                   },
                   color: Colors.white70,
                 ),
               ),
               Align(
                 alignment: Alignment.topRight,
                 child: Container(
                   child: IconButton(
                     icon:
                     Icon(_currentIndex == 2 ? Icons.check : Icons.arrow_forward),
                     onPressed: () {
                       if (_currentIndex != 2) _controller.next();
                       else    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()),);
                     },
                   ),
                 ),
               )
             ],
           ),
         )
        ],
      ),
    );
  }
}

class IntroItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color bg;
  final String imageUrl;

  const IntroItem(
      {Key key, @required this.title, this.subtitle, this.bg, this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg ?? Theme.of(context).primaryColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 40),
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35.0,
                    color: Colors.white),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 20.0),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white, fontSize: 24.0),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40.0),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 70),
                  width: double.infinity,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Material(
                      elevation: 4.0,
                      child: Image.asset(
                        imageUrl,
                        fit: BoxFit.cover,
                      ),),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
