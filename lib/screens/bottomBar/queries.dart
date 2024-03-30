import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../constants.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:translator/translator.dart';

var lst = [];

class AudioInput extends StatefulWidget {
  const AudioInput({super.key});

  @override
  State<AudioInput> createState() => _AudioInputState();
}

class _AudioInputState extends State<AudioInput>
    with SingleTickerProviderStateMixin {
  int maxDuration = 10;

  double deviceHeight = Constants().deviceHeight,
      deviceWidth = Constants().deviceWidth;

  late AnimationController _controller;

  final recorder = FlutterSoundRecorder();
  final player = FlutterSoundPlayer();

  bool isRecorderReady = false, gotSomeTextYo = false, isPlaying = false;
  String TTSLocaleID = 'en-IN';
  String _secondLanguage = 'English';
  String ngrokurl = Constants().ngrokurl;
  final translator = GoogleTranslator();

  Future record() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

  Future stop() async {
    if (!isRecorderReady) return;
    String? path = await recorder.stopRecorder();
    File audioPath = await saveAudioPermanently(path!);
    if (kDebugMode) {
      print('Recorded audio: $path');
    }
    lst = await sendAudio(audioPath);
    if (kDebugMode) {
      print(lst);
    }
    if (true) {
      gotSomeTextYo = true;
      setState(() {
        maxDuration = maxDuration;
      });
    }
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    await recorder.openRecorder();
    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  @override
  void initState() {
    super.initState();
    // initTTS();

    _controller = AnimationController(
        vsync: this, duration: Duration(seconds: maxDuration))
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          isPlaying = false;
        }
      });

    initRecorder();

    player.openPlayer().then((value) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    recorder.closeRecorder();
    player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[900]!,
                Colors.black,
                Colors.grey[900]!,
              ]),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 20 * (height / deviceHeight),
                ),
                SizedBox(
                  width: 400 * (width / deviceWidth),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: DropdownButtonFormField(
                      itemHeight: null,
                      isExpanded: true,
                      hint: Text(
                        _secondLanguage,
                        style: const TextStyle(
                          fontFamily: "productSansReg",
                          overflow: TextOverflow.ellipsis,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                      ),
                      onChanged: (v) => setState(() {
                        _secondLanguage = Constants()
                            .TTSDisplay[Constants().TTSLocaleIDS.indexOf(v!)];
                        TTSLocaleID = v;
                      }),
                      items: Constants().TTSLocaleIDS.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: SizedBox(
                            width: width * (75 / 340),
                            child: Text(
                              Constants().TTSDisplay[
                                  Constants().TTSLocaleIDS.indexOf(e)],
                              style: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontFamily: "productSansReg",
                                  color: Colors.black,
                                  fontSize: 15),
                            ),
                          ),
                        );
                      }).toList(),
                      style: const TextStyle(
                          fontFamily: "productSansReg",
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15),
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(13),
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7.0),
                              borderSide: BorderSide.none)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    AppLocalizations.of(context)!.speakMic,
                    style: TextStyle(
                        fontFamily: "productSansReg",
                        color: Colors.cyan[500],
                        fontWeight: FontWeight.w700,
                        fontSize: 25),
                  ),
                ),
                SizedBox(
                  height: 30 * (height / deviceHeight),
                ),
                StreamBuilder<RecordingDisposition>(
                    stream: recorder.onProgress,
                    builder: (context, snapshot) {
                      final duration = snapshot.hasData
                          ? snapshot.data!.duration
                          : Duration.zero;
                      String twoDigits(int n) => n.toString().padLeft(2, '0');
                      final twoDigitMinutes =
                          twoDigits(duration.inMinutes.remainder(60));
                      final twoDigitSeconds =
                          twoDigits(duration.inSeconds.remainder(60));
                      return Text(
                        "$twoDigitMinutes:$twoDigitSeconds s",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan[500],
                          fontFamily: "productSansReg",
                        ),
                      );
                    }),
                SizedBox(
                  height: 40 * (height / deviceHeight),
                ),
                if (isPlaying)
                  Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.cyan[500]!,
                    size: 20 * (height / deviceHeight),
                  )),
                if (!isPlaying)
                  SizedBox(
                    height: 60 * (height / deviceHeight),
                    child: gotSomeTextYo
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "random",
                              style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: "productSansReg",
                                  color: Color(0xFF009CFF)),
                            ),
                          )
                        : const Padding(
                            padding: EdgeInsets.all(8.0),
                          ),
                  ),
                if (!isPlaying)
                  SizedBox(
                    height: 50 * (height / deviceHeight),
                  ),
                if (isPlaying)
                  SizedBox(
                    height: 80 * (height / deviceHeight),
                  ),
                Container(
                  alignment: Alignment.center,
                  height: 40 * (height / deviceHeight),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                      shape: BoxShape.circle),
                  child: GestureDetector(
                    onTap: () async {
                      if (recorder.isRecording) {
                        isPlaying = false;
                        await stop();
                        _controller.reset();
                        Translation x = await translator.translate("hello",
                            from: 'en', to: TTSLocaleID.substring(0, 2));
                        if (kDebugMode) {
                          print("After translation:${x.text}");
                        }
                      } else {
                        isPlaying = true;
                        await record();
                        _controller.reset();
                        _controller.forward();
                      }
                      setState(() {});
                    },
                    child: AnimatedContainer(
                      height: isPlaying
                          ? 10 * (height / deviceHeight)
                          : 25 * (height / deviceHeight),
                      width: isPlaying
                          ? 10 * (height / deviceHeight)
                          : 25 * (height / deviceHeight),
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(isPlaying ? 6 : 60),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20 * (height / deviceHeight),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Object?>> sendAudio(File? audioPath) async {
    List<Object?> lst = [];
    var response = http.MultipartRequest(
      'POST',
      Uri.parse('$ngrokurl/transcribe'),
    );
    response.files.add(http.MultipartFile(
        'audio', audioPath!.readAsBytes().asStream(), audioPath.lengthSync(),
        filename: basename(audioPath.path),
        contentType: MediaType('application', 'octet-stream')));
    var res = await response.send();
    var responseBody = await res.stream.bytesToString();
    if (kDebugMode) {
      print(responseBody);
      print(res.statusCode);
    }
    return lst;
  }

  Future<File> saveAudioPermanently(String path) async {
    final directory = await getApplicationDocumentsDirectory();
    final name = basename(path);
    final audio = File('${directory.path}/$name');
    return File(path).copy(audio.path);
  }
}
