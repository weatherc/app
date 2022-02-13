import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_icons/weather_icons.dart';

class Coords {
  static double lat = 60.25;
  static double lng = 23.24;
}

void main() async { 
    FlutterNativeSplash.removeAfter(initialization);
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setEnabledSystemUIOverlays([]);
    await loadPrefs();
    runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('fi', ''),
        Locale('sv', ''),
      ],
      home: WebViewExample()
    ));
}

void initialization(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 2));
}

loadPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Coords.lat = (prefs.getDouble('lat') ?? 60.25);
  Coords.lng = (prefs.getDouble('lng') ?? 23.24);
  print("prefs loaded");

  Position? position = await Geolocator.getLastKnownPosition();
  if (position?.latitude != null && position?.longitude != null) {
    Coords.lat = position!.latitude!;
    Coords.lng = position!.longitude!;
    prefs.setDouble('lat', position!.latitude!);
    prefs.setDouble('lng', position!.longitude!);
    print("from flutter last known geo");
  }
}

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  late WebViewController myController;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    Locale myLocale = Localizations.localeOf(context);;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xff424242),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
      ),
      body: Builder(builder: (BuildContext context) {
        return WebView(
          initialUrl: 'https://nordicweather.net/flutter/index.php?lang=$myLocale&lat=${Coords.lat}&lon=${Coords.lng}',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller.complete(webViewController);
            myController = webViewController;
          },
          javascriptChannels: <JavascriptChannel>{
            _toasterJavascriptChannel(context),
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          gestureNavigationEnabled: true,
          backgroundColor: Color(0xff424242),
        );
      }),
      endDrawer: Sidebar(),
    );
  }

  Widget Sidebar() {
    String myLocale = Localizations.localeOf(context).toString();
    Map Lang = {};
    Map Langs = {
      'en': {
        'tracker': 'Stormtracker',
        'rradar': 'Rainradar',
        'frc': 'Forecast',
        'frcmap': 'Forecastmaps',
        'road': 'Roadconditions',
        'temps': 'Temperature',
      },
      'fi': {
        'tracker': 'Ukkostutka',
        'rradar': 'Sadetutka',
        'frc': 'Ennuste',
        'frcmap': 'Ennustekartat',
        'road': 'Tiesää',
        'temps': 'Lämpötila',
      },
      'sv': {
        'tracker': 'Åskradar',
        'rradar': 'Regnradar',
        'frc': 'Prognos',
        'frcmap': 'Prognoskartor',
        'road': 'Vägväder',
        'temps': 'Temperatur',
      },
    };
    if (myLocale == 'fi') { Lang = Langs['fi'];}
    else if (myLocale == 'sv') { Lang = Langs['sv'];}
    else { Lang = Langs['en'];}
    return Drawer(
      child: Column(
        children: <Widget>[
          SizedBox(
          height: 150.0,
          child: DrawerHeader(
            child: Center(
              child: Text('',textAlign: TextAlign.center,style: TextStyle(color: Colors.white, fontSize: 25),),
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('img/unsplash_small.png')),
            ),
          )),
          ListTile(
            leading: BoxedIcon(WeatherIcons.lightning),
            title: Text(Lang['tracker'], style: TextStyle(fontSize: 16)),
            onTap: () => {
                myController.loadUrl('https://nordicweather.net/flutter/index.php?lang=$myLocale&lat=${Coords.lat}&lon=${Coords.lng}'),
                Navigator.of(context).pop(),
              },
          ),
          ListTile(
            leading: BoxedIcon(WeatherIcons.raindrop),
            title: Text(Lang['rradar'], style: TextStyle(fontSize: 16)),
            onTap: () => {
                myController.loadUrl('https://nordicweather.net/flutter/radar.php?lang=$myLocale&lat=${Coords.lat}&lon=${Coords.lng}'),
                Navigator.of(context).pop(),
              },
          ),
          ListTile(
            leading: BoxedIcon(WeatherIcons.thermometer),
            title: Text(Lang['temps'], style: TextStyle(fontSize: 16)),
            onTap: () => {
                myController.loadUrl('https://nordicweather.net/flutter/temps.php?lang=$myLocale&lat=${Coords.lat}&lon=${Coords.lng}'),
                Navigator.of(context).pop(),
              },
          ),
          ListTile(
            leading: BoxedIcon(WeatherIcons.day_sprinkle),
            title: Text(Lang['frc'], style: TextStyle(fontSize: 16)),
            onTap: () => {
                myController.loadUrl('https://nordicweather.net/flutter/frc.php?lang=$myLocale&lat=${Coords.lat}&lon=${Coords.lng}'),
                Navigator.of(context).pop(),
              },
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text(Lang['frcmap'], style: TextStyle(fontSize: 16)),
            onTap: () => {
                myController.loadUrl('https://nordicweather.net/flutter/maps.php?lang=$myLocale&lat=${Coords.lat}&lon=${Coords.lng}'),
                Navigator.of(context).pop(),
              },
          ),
          ListTile(
            leading: Icon(Icons.drive_eta),
            title: Text(Lang['road'], style: TextStyle(fontSize: 16)),
            onTap: () => {
                myController.loadUrl('https://nordicweather.net/flutter/road.php?lang=$myLocale&lat=${Coords.lat}&lon=${Coords.lng}'),
                Navigator.of(context).pop(),
              },
          ),
        ],
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  getCurrentLocation() async {
    Position currentPosition;
    bool serviceEnabled;
    LocationPermission permission;
    SharedPreferences prefs = await SharedPreferences.getInstance();

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    } 

    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 250,
    );

    StreamSubscription positionStream = Geolocator
      .getPositionStream(locationSettings: locationSettings)
      .listen((Position position) {
        setState(() {
          currentPosition = position;
          Coords.lat = position.latitude;
          Coords.lng = position.longitude;
          prefs.setDouble('lat', position.latitude);
          prefs.setDouble('lng', position.longitude);
          myController.evaluateJavascript('console.log("from flutter geo");from_flutter(${position.latitude},${position.latitude})');
        });
      });
  }

  /*
  getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition.latitude,
        currentPosition.longitude
      );

      Placemark place = placemarks[0];

      setState(() {
        currentAddress = "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }*/

}

