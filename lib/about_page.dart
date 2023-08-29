import 'package:flutter/material.dart';

// imports for the settings global state
import 'package:provider/provider.dart';
import 'util/settings_provider.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
  }

  class _AboutPageState extends State<AboutPage> {
    var settingsModel;

    @override
    void initState() {
      super.initState();
    }

    @override
    void didChangeDependencies() {
      settingsModel = Provider.of<SettingsModel>(context);
      super.didChangeDependencies();
    }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/802.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.8),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Stack(
                      children: [
                        Text(
                          settingsModel.internationalLanguage ? 'Weather App' : 'Väder App',
                          style: TextStyle(
                            fontFamily: 'MrsSaintDelafield',
                            fontSize: 80,
                            fontWeight: FontWeight.w900,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = Colors.white70,
                            shadows: const [
                               Shadow(
                                blurRadius: 5.0,
                                color: Colors.blueAccent,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          settingsModel.internationalLanguage ? 'Weather App' : 'Väder App',
                          style: const TextStyle(
                            fontFamily: 'MrsSaintDelafield',
                            fontSize: 80,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    ),
                    Text(
                      settingsModel.internationalLanguage ? 'is a project during the course 1DV535.\nThe app is built with Flutter and uses OpenWeatherMap API.\nDeveloped by Jimmy Karlsson' : 'är ett projekt i kursen 1DV535.\nAppen är byggd med Flutter och använder OpenWeatherMap API.\nUtvecklad av Jimmy Karlsson',
                      textAlign: TextAlign.center,
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 15,
                      indent: 50,
                      endIndent: 50
                    ),
                    const Text(
                      'Kodsmed.se',
                      style: TextStyle(
                        fontFamily: 'SourceCodePro',
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                    Image.asset(
                      'assets/images/codesmith.png',
                      fit: BoxFit.scaleDown,
                    ),
                    const Text(
                      'Jimmy Carlsson',
                      style: TextStyle(
                        fontFamily: 'MrsSaintDelafield',
                        fontSize: 40,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      settingsModel.internationalLanguage ? 'Codesmith - Apprentice grade' : 'Kodsmed - Lärlingsgrad',
                       style: const TextStyle(
                          fontFamily: 'SourceCodePro',
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                    ),
                    Text(
                      settingsModel.internationalLanguage ? 'Linnaeus University' : 'Linnéuniversitetet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'SourceCodePro',
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w100,
                        fontStyle: FontStyle.italic
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 1,
                      height: 15,
                      indent: 50,
                      endIndent: 50
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  }
}
