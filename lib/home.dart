// import 'package:flutter/material.dart';
// import 'dart:io';
//
// import 'package:tflite/tflite.dart';
// import 'package:image_picker/image_picker.dart';
//
// class Home extends StatefulWidget {
//   @override
//   _HomeState createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//   bool _loading = true;
//   File _image;
//   List _output;
//   final picker = ImagePicker();
//
//   classifyImage(File image) async {
//     var output = await Tflite.runModelOnImage(
//       path: image.path,
//       numResults: 2,
//       threshold: 0.5,
//       imageMean: 127.5,
//       imageStd: 127.5,
//     );
//     setState(() {
//       _output = output;
//       _loading = false;
//     });
//   }
//
//   loadModel() async {
//     await Tflite.loadModel(
//       model: 'assets/model_MobileNetV2_v9500.tflite', // Todo: change the model here
//       labels: 'assets/labels_3.txt',
//     );
//   }
//
//   pickImage(String option) async {
//     var image = await picker.getImage(
//         source: option == 'camera' ? ImageSource.camera : ImageSource.gallery,
//         imageQuality: 100,
//     );
//
//     setState(() {
//       _image = File(image.path);
//     });
//     classifyImage(_image);
//   }
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     loadModel().then((value) {
//       setState(() {});
//     });
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     super.dispose();
//     Tflite.close();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF101010),
//       body: Container(
//         padding: EdgeInsets.symmetric(horizontal: 24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             SizedBox(
//               height: 50,
//             ),
//             Text(
//               'Created with TensorFlow',
//               style: TextStyle(
//                 color: Color(0xFFEEDA28),
//                 fontSize: 18,
//               ),
//             ),
//             SizedBox(height: 6),
//             Text(
//               'Classify Men & Women',
//               style: TextStyle(
//                   color: Color(0xFFE99600),
//                   fontWeight: FontWeight.w500,
//                   fontSize: 28),
//             ),
//             SizedBox(
//               height: 40,
//             ),
//             Center(
//               child: (_loading
//                   ? Container(
//                       width: 280,
//                       child: Column(
//                         children: <Widget>[
//                           Image.asset('assets/men_vs_women.png'),
//                           SizedBox(
//                             height: 85,
//                           )
//                         ],
//                       ),
//                     )
//                   : Container(
//                       child: Column(
//                         children: <Widget>[
//                           Container(height: 250, child: Image.file(_image)),
//                           SizedBox(height: 20),
//                           _output != null
//                               ? Text('${_output[0]}',
//                                   style: TextStyle(
//                                     color: Colors.white,
//                                     fontSize: 20,
//                                   ))
//                               : Container(),
//                         ],
//                       ),
//                     )),
//             ),
//             Container(
//               width: MediaQuery.of(context).size.width,
//               child: Column(
//                 children: <Widget>[
//                   GestureDetector(
//                     onTap: () {pickImage('camera');},
//                     child: Container(
//                       width: MediaQuery.of(context).size.width - 160,
//                       alignment: Alignment.center,
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 24, vertical: 17),
//                       decoration: BoxDecoration(
//                           color: Color(0xFFEE99600),
//                           borderRadius: BorderRadius.circular(6)),
//                       child: Text(
//                         'Take a photo',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                   SizedBox(
//                     height: 10,
//                   ),
//                   GestureDetector(
//                     onTap: () {pickImage('gallery');},
//                     child: Container(
//                       width: MediaQuery.of(context).size.width - 160,
//                       alignment: Alignment.center,
//                       padding:
//                           EdgeInsets.symmetric(horizontal: 24, vertical: 17),
//                       decoration: BoxDecoration(
//                           color: Color(0xFFEE99600),
//                           borderRadius: BorderRadius.circular(6)),
//                       child: Text(
//                         'Camera Roll',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// enum Model { lafayette, jefferson }
//
// class RadioButtonsList extends StatefulWidget {
//   @override
//   _RadioButtonsListState createState() => _RadioButtonsListState();
// }
//
// class _RadioButtonsListState extends State<RadioButtonsList> {
//   Model _character = Model.lafayette;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: <Widget>[
//         RadioListTile<Model>(
//           title: const Text('Lafayette'),
//           value: Model.lafayette,
//           groupValue: _character,
//           onChanged: (Model value) { setState(() { _character = value; }); },
//         ),
//         RadioListTile<Model>(
//           title: const Text('Thomas Jefferson'),
//           value: Model.jefferson,
//           groupValue: _character,
//           onChanged: (Model value) { setState(() { _character = value; }); },
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'dart:io';

import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';

List _possibleOutputs = ['Man', 'None', 'Woman'];

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _loading = true;
  File _image;
  List _output;
  final picker = ImagePicker();

  classifyImage(File image) {
    loadModel(9690).then((_){
          Tflite.runModelOnImage(
            path: image.path,
            numResults: 2,
            threshold: 0.5,
            imageMean: 127.5,
            imageStd: 127.5,
          ).then((firstOutput) {
            if (firstOutput[0]['index'] == 0) {
              loadModel(9400).then((_) {
                Tflite.runModelOnImage(
                  path: image.path,
                  numResults: 2,
                  threshold: 0.5,
                  imageMean: 0.5,
                  imageStd: 0.5,
                ).then((secondOutput) {
                  if (secondOutput[0]['index'] == 2 || secondOutput[0]['index'] == 1) {
                    setState(() {
                      _output = firstOutput;
                      _loading = false;
                    });
                  } else {
                    setState(() {
                      _output = firstOutput[0]['confidence'] >
                          secondOutput[0]['confidence']
                          ? firstOutput
                          : secondOutput;
                      _loading = false;
                    });
                  }
                }).catchError((_) {
                  setState(() {
                    _output = firstOutput;
                    _loading = false;
                  });
                });
              });
            } else if (firstOutput[0]['index'] == 2) {
              loadModel(9400).then((_) {
                Tflite.runModelOnImage(
                  path: image.path,
                  numResults: 2,
                  threshold: 0.5,
                  imageMean: 0.5,
                  imageStd: 0.5,
                ).then((secondOutput) {
                  if (secondOutput[0]['index'] == 0) {
                    loadModel(9396).then((_) {
                      Tflite.runModelOnImage(
                        path: image.path,
                        numResults: 2,
                        threshold: 0.5,
                        imageMean: 0.5,
                        imageStd: 0.5,
                      ).then((thirdOutput) {
                        if (thirdOutput[0]['index'] == 0) {
                          setState(() {
                            _output = secondOutput;
                            _loading = false;
                          });
                        }
                      }).catchError((_) {
                        setState(() {
                          _output = firstOutput;
                          _loading = false;
                        });
                      });
                      setState(() {
                        _output = firstOutput[0]['confidence'] >
                                secondOutput[0]['confidence']
                            ? firstOutput
                            : secondOutput;
                        _loading = false;
                      });
                    });
                  } else {
                    setState(() {
                      _output = firstOutput[0]['confidence'] >
                              secondOutput[0]['confidence']
                          ? firstOutput
                          : secondOutput;
                      _loading = false;
                    });
                  }
                }).catchError((_) {
                  setState(() {
                    _output = firstOutput;
                    _loading = false;
                  });
                });
              });
            } else {
              loadModel(9400).then((_) {
                Tflite.runModelOnImage(
                  path: image.path,
                  numResults: 2,
                  threshold: 0.5,
                  imageMean: 0.5,
                  imageStd: 0.5,
                ).then((secondOutput) {
                  setState(() {
                    _output = firstOutput[0]['confidence'] >
                            secondOutput[0]['confidence']
                        ? firstOutput
                        : secondOutput;
                    _loading = false;
                  });
                }).catchError((_) {
                  setState(() {
                    _output = firstOutput;
                    _loading = false;
                  });
                });
              });
            }
          }).catchError((_) {
            loadModel(9400).then((_) {
              Tflite.runModelOnImage(
                path: image.path,
                numResults: 2,
                threshold: 0.5,
                imageMean: 0.5,
                imageStd: 0.5,
              ).then((secondOutput) {
                setState(() {
                  _output = secondOutput;
                  _loading = false;
                });
              }).catchError((_) {
                loadModel(9396).then((_) {
                  Tflite.runModelOnImage(
                    path: image.path,
                    numResults: 2,
                    threshold: 0.5,
                    imageMean: 0.5,
                    imageStd: 0.5,
                  ).then((thirdOutput) {
                    setState(() {
                      _output = thirdOutput;
                      _loading = false;
                    });
                  }).catchError(() {
                    // error on all models..
                  });
                });
              });
            });
          });
        });
  }

  loadModel(selectedValue) async {
    await Tflite.loadModel(
      model: 'assets/model_MobileNetV2_v$selectedValue.tflite',
      // Todo: change the model here
      labels: 'assets/labels_3.txt',
    );
  }

  pickImage(String option) async {
    var image = await picker.getImage(
        source: option == 'camera' ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      _image = File(image.path);
    });
    classifyImage(_image);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    Tflite.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF101010),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 50),
            Text(
              'Classify Men & Women',
              style: TextStyle(
                  color: Color(0xFFE99600),
                  fontWeight: FontWeight.w500,
                  fontSize: 28),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: (_loading
                  ? Container(
                      width: 280,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/men_vs_women.png'),
                          SizedBox(
                            height: 85,
                          )
                        ],
                      ),
                    )
                  : Container(
                      child: Column(
                        children: <Widget>[
                          Container(height: 250, child: Image.file(_image)),
                          SizedBox(height: 10),
                          _output != null
                              ? Column(
                                  children: [
                                    Text(
                                        'Identified Gender: ${_possibleOutputs[_output[0]['index']]}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        )),
                                    SizedBox(height: 10),
                                    Text(
                                        'Confidence Level: ${(_output[0]['confidence'] * 100).toString().substring(0, 5)}%',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        )),
                                    SizedBox(height: 10),
                                  ],
                                )
                              : Container(),
                        ],
                      ),
                    )),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      pickImage('camera');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 160,
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                          color: Color(0xFFEE99600),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        'Take a photo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      pickImage('gallery');
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 160,
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                      decoration: BoxDecoration(
                          color: Color(0xFFEE99600),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        'Camera Roll',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
