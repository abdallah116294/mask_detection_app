import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mask_detection_app/main.dart';
import 'package:tflite/tflite.dart';
//import 'package:tflite/tflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController cameraController;
  late CameraImage cameraImage;
  bool isWorking = false;
  String result = '';
  intCamera() {
    cameraController = CameraController(cameras[0], ResolutionPreset.max);
    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        cameraController.startImageStream((image) => {
              if (!isWorking)
                {
                  isWorking = true,
                  cameraImage = image,
                  // there we add function to add the model
                  runModelOnFrame()
                }
            });
      });
    });
  }

  Future loadModel() async {
    Tflite.close();
    try {
      var response = await Tflite.loadModel(
          model: 'assets/model.tflite', labels: 'assets/labels.txt');
      print(response);
    } catch (e) {
      print(e);
    }
  }

  runModelOnFrame() async {
    if (cameraImage != null) {
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: cameraImage.planes.map((e) {
            return e.bytes;
          }).toList(),
          imageHeight: cameraImage.height,
          imageWidth: cameraImage.width,
          imageMean: 127.5,
          imageStd: 127.5,
          threshold: 0.4);
      result = '';
      recognitions!.forEach((element) {
        result += element["label"] + '\n';
      });
      setState(() {
        result;
      });

       isWorking = false;
      // setState(() {
      //   cameraImage;
      // });
    }
  }

  @override
  void initState() {
    super.initState();
    intCamera();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:  Padding(
          padding:const EdgeInsets.only(top: 40),
          child: Center(
            child: Text(result,style: const TextStyle(color: Colors.white,fontSize: 30),),
          ),
        ),
      ),
      body: Column(children: [
        Positioned(
          top: 0,
          left: 0,
          width: size.width,
          height: size.height - 100,
          child: Container(
            height: size.height - 100,
            child: (!cameraController.value.isInitialized)
                ? Container()
                : AspectRatio(
                    aspectRatio: cameraController.value.aspectRatio,
                    child: CameraPreview(cameraController),
                  ),
          ),
        )
      ]),
    ));
  }
}
