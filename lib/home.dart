import 'dart:io';
import 'package:stats/stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    loadModel(9474).then((_) {
      Tflite.runModelOnImage(
        path: image.path,
        numResults: 3,
        threshold: 1.0 / 3,
        imageMean: 0.0,
        imageStd: 1.0,
      ).then((forthOutput) {
        loadModel(9513).then((_) {
          Tflite.runModelOnImage(
            path: image.path,
            numResults: 3,
            threshold: 1.0 / 3,
            imageMean: 0.0,
            imageStd: 1.0,
          ).then((secondOutput) {
            loadModel(9401).then((_) {
              Tflite.runModelOnImage(
                path: image.path,
                numResults: 3,
                threshold: 1.0 / 3,
                imageMean: 0.0,
                imageStd: 1.0,
              ).then((thirdOutput) {
                loadModel(9690).then((_) {
                  Tflite.runModelOnImage(
                    path: image.path,
                    numResults: 3,
                    threshold: 1.0 / 3,
                    imageMean: 127.5,
                    imageStd: 127.5,
                  ).then((firstOutput) {
                    if (thirdOutput[0]['index'] == 1 ||
                        secondOutput[0]['index'] == 1) {
                      setState(() {
                        _output = firstOutput;
                        _loading = false;
                      });
                    } else {
                      var output1;
                      var output2;
                      loadModel(9398).then((_) {
                        Tflite.runModelOnImage(
                          path: image.path,
                          numResults: 3,
                          threshold: 1.0 / 3,
                          imageMean: 0.0,
                          imageStd: 1.0,
                        ).then((fifthOutput) {
                          loadModel(9399).then((_) {
                            Tflite.runModelOnImage(
                              path: image.path,
                              numResults: 3,
                              threshold: 1.0 / 3,
                              imageMean: 0.0,
                              imageStd: 1.0,
                            ).then((sixthOutput) {
                              var cumulativeManIndex =
                                  (-firstOutput[0]['index'] / 2).floor() +
                                      (-secondOutput[0]['index'] / 2).floor() +
                                      (-thirdOutput[0]['index'] / 2).floor() +
                                      (-forthOutput[0]['index'] / 2).floor() +
                                      (-fifthOutput[0]['index'] / 2).floor() +
                                      5;
                              var manConfidence = 0.0;
                              if (firstOutput[0]['index'] == 0 &&
                                  firstOutput[0]['confidence'] >
                                      manConfidence) {
                                manConfidence = firstOutput[0]['confidence'];
                                output1 = firstOutput;
                              }
                              if (secondOutput[0]['index'] == 0 &&
                                  secondOutput[0]['confidence'] >
                                      manConfidence) {
                                manConfidence = secondOutput[0]['confidence'];
                                output1 = secondOutput;
                              }
                              if (thirdOutput[0]['index'] == 0 &&
                                  thirdOutput[0]['confidence'] >
                                      manConfidence) {
                                manConfidence = thirdOutput[0]['confidence'];
                                output1 = thirdOutput;
                              }
                              if (forthOutput[0]['index'] == 0 &&
                                  forthOutput[0]['confidence'] >
                                      manConfidence) {
                                manConfidence = forthOutput[0]['confidence'];
                                output1 = forthOutput;
                              }
                              if (fifthOutput[0]['index'] == 0 &&
                                  fifthOutput[0]['confidence'] >
                                      manConfidence) {
                                manConfidence = fifthOutput[0]['confidence'];
                                output1 = fifthOutput;
                              }
                              var womanConfidence = 0.0;
                              if (secondOutput[0]['index'] == 2 &&
                                  secondOutput[0]['confidence'] >
                                      womanConfidence) {
                                womanConfidence = secondOutput[0]['confidence'];
                                output2 = secondOutput;
                              }
                              if (firstOutput[0]['index'] == 2 &&
                                  firstOutput[0]['confidence'] >
                                      womanConfidence) {
                                womanConfidence = firstOutput[0]['confidence'];
                                output2 = firstOutput;
                              }
                              if (fifthOutput[0]['index'] == 2 &&
                                  fifthOutput[0]['confidence'] >
                                      womanConfidence) {
                                womanConfidence = fifthOutput[0]['confidence'];
                                output2 = fifthOutput;
                              }
                              if (forthOutput[0]['index'] == 2 &&
                                  forthOutput[0]['confidence'] >
                                      womanConfidence) {
                                womanConfidence = forthOutput[0]['confidence'];
                                output2 = forthOutput;
                              }
                              if (thirdOutput[0]['index'] == 2 &&
                                  thirdOutput[0]['confidence'] >
                                      womanConfidence) {
                                womanConfidence = thirdOutput[0]['confidence'];
                                output2 = thirdOutput;
                              }

                              if ((cumulativeManIndex > 3)) {
                                setState(() {
                                  _output = firstOutput[0]['index'] == 0
                                      ? firstOutput
                                      : secondOutput;
                                  _loading = false;
                                });
                              } else if (cumulativeManIndex == 3) {
                                setState(() {
                                  _output = output1;
                                  _loading = false;
                                });
                              } else if (cumulativeManIndex == 2 &&
                                  sixthOutput[0]['index'] == 0 &&
                                  sixthOutput[0]['confidence'] > 0.8) {
                                setState(() {
                                  _output = sixthOutput;
                                  _loading = false;
                                });
                              } else {
                                var outputs = [
                                  firstOutput,
                                  secondOutput,
                                  thirdOutput,
                                  forthOutput,
                                  fifthOutput,
                                ];
                                var confidenceLevels = outputs
                                        .where((e) => e[0]['index'] == 2)
                                        .map(
                                            (e) => e[0]['confidence'] as double)
                                        .toList() +
                                    [sixthOutput[0]['confidence']];
                                var mu =
                                    Stats.fromData(confidenceLevels).average;
                                var std = Stats.fromData(confidenceLevels).standardDeviation;
                               var max = Stats.fromData(confidenceLevels).max;
                               var min = Stats.fromData(confidenceLevels).min;
                                var isNotTooLargeOutlier = true;
                                var isSmallOutlier = false;
                                for (var i = 0;
                                    i < confidenceLevels.length;
                                    i++) {
                                  if (absVal(confidenceLevels[i] - mu) >
                                      std * 1.5) {
                                    isSmallOutlier = true;
                                  }
                                  if (absVal(confidenceLevels[i] - mu) >
                                      std * 3) {
                                    isNotTooLargeOutlier = false;
                                  }
                                }
                                if (cumulativeManIndex == 1 &&
                                    sixthOutput[0]['index'] == 0) {
                                  // print('------------------------');
                                  setState(() {
                                    _output = sixthOutput;
                                    _loading = false;
                                  });
                                } else if (cumulativeManIndex == 0 &&
                                    sixthOutput[0]['index'] == 0 &&
                                    isSmallOutlier && isNotTooLargeOutlier && max - min < 0.4) {
                                  // print('xxxxxxxxxxxxxxxxxxxxxxx');
                                  setState(() {
                                    _output = sixthOutput;
                                    _loading = false;
                                  });
                                } else {
                                  setState(() {
                                    _output = output2;
                                    _loading = false;
                                  });
                                }
                              }
                            }).catchError((_) {
                              setState(() {
                                _output = forthOutput;
                                _loading = false;
                              });
                            });
                          });
                        }).catchError((_) {
                          setState(() {
                            _output = forthOutput;
                            _loading = false;
                          });
                        });
                        ;
                      });
                    }
                  }).catchError((_) {
                    setState(() {
                      _output = forthOutput;
                      _loading = false;
                    });
                  }).catchError((_) {
                    setState(() {
                      _output = forthOutput;
                      _loading = false;
                    });
                  });
                });
              }).catchError((_) {
                setState(() {
                  _output = forthOutput;
                  _loading = false;
                });
              });
            });
          }).catchError((_) {});
        });
      });
    });
  }

  absVal(double v) {
    return v >= 0 ? v : -v;
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
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

// List _modelList = [9474, 9513, 9690, 9398, 9401, 9399];
// List _possibleOutputs = ['Man', 'None', 'Woman'];
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
//   int _selectedValue = 9519;
//
//   classifyImage(File image) async {
//     var output = await Tflite.runModelOnImage(
//       path: image.path,
//       numResults: 3,
//       threshold: 1.0 / 3,
//       imageMean: 0.5 * (_selectedValue != 9690 ? 0 : 255.0),
//       imageStd: 0.5 * (_selectedValue != 9690 ? 2 : 255.0),
//     );
//     setState(() {
//       _output = output;
//       _loading = false;
//     });
//   }
//
//   loadModel() async {
//     await Tflite.loadModel(
//       model: 'assets/model_MobileNetV2_v$_selectedValue.tflite',
//       // Todo: change the model here
//       labels: 'assets/labels_3.txt',
//     );
//   }
//
//   pickImage(String option) async {
//     var image = await picker.getImage(
//         source: option == 'camera' ? ImageSource.camera : ImageSource.gallery);
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
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: <Widget>[
//             // SizedBox(height: 30),
//             Text(
//               'Classify Men & Women',
//               style: TextStyle(
//                   color: Color(0xFFE99600),
//                   fontWeight: FontWeight.w500,
//                   fontSize: 28),
//             ),
//             // SizedBox(
//             //   height: 20,
//             // ),
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
//                           SizedBox(height: 10),
//                           _output != null
//                               ? Column(
//                                   children: [
//                                     Text(
//                                         'Identified Gender: ${_possibleOutputs[_output[0]['index']]}',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 20,
//                                         )),
//                                     SizedBox(height: 10),
//                                     Text(
//                                         'Confidence Level: ${(_output[0]['confidence'] * 100).toString().substring(0, 5)}%',
//                                         style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 20,
//                                         )),
//                                     SizedBox(height: 10),
//                                   ],
//                                 )
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
//                     onTap: () {
//                       pickImage('camera');
//                     },
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
//                     onTap: () {
//                       pickImage('gallery');
//                     },
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
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: _modelList
//                         .map(
//                           (e) => ListTile(
//                             title: Text('Model 0.' + e.toString(),
//                                 style: TextStyle(color: Colors.white)),
//                             leading: Radio(
//                               value: e,
//                               groupValue: _selectedValue,
//                               onChanged: (value) {
//                                 setState(() {
//                                   _selectedValue = value;
//                                 });
//                                 loadModel();
//                                 if (_image != null) {
//                                   classifyImage(_image);
//                                 }
//                               },
//                               activeColor: Color(0xFFE99600),
//                             ),
//                           ),
//                         )
//                         .toList(),
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

/*classifyImage(File image) {
  loadModel(9690).then((_) {
    Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.333,
      imageMean: 127.5,
      imageStd: 127.5,
    ).then((firstOutput) {
      if (firstOutput[0]['index'] == 0) {
        loadModel(9400).then((_) {
          Tflite.runModelOnImage(
            path: image.path,
            numResults: 3,
            threshold: 0.333,
            imageMean: 0.5,
            imageStd: 0.5,
          ).then((secondOutput) {
            if (secondOutput[0]['index'] == 2 ||
                secondOutput[0]['index'] == 1) {
              setState(() {
                _output = firstOutput;
                _loading = false;
              });
            } else {
              // recalibration start
              // var maxOutput = firstOutput;
              // if (secondOutput[0]['confidence'] >
              //     firstOutput[0]['confidence']) {
              //   maxOutput = secondOutput;
              // }
              // if (maxOutput[0]['confidence'] < 0.75) {
              //   loadModel(9530).then((_) {
              //     Tflite.runModelOnImage(
              //       path: image.path,
              //       numResults: 3,
              //       threshold: 0.333,
              //       imageMean: 0.5,
              //       imageStd: 0.5,
              //     ).then((fifthOutput) {
              //       if (fifthOutput[0]['index'] == 2) {
              //         setState(() {
              //           _output = fifthOutput;
              //           _loading = false;
              //         });
              //       } else {
              //         setState(() {
              //           _output = maxOutput;
              //           _loading = false;
              //         });
              //       }
              //     }).catchError((_) {
              //       setState(() {
              //         _output = maxOutput;
              //         _loading = false;
              //       });
              //     });
              //   });
              // }
              // recalibration end
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
            numResults: 3,
            threshold: 0.333,
            imageMean: 0.5,
            imageStd: 0.5,
          ).then((secondOutput) {
            if (secondOutput[0]['index'] == 0) {
              loadModel(9396).then((_) {
                Tflite.runModelOnImage(
                  path: image.path,
                  numResults: 3,
                  threshold: 0.333,
                  imageMean: 0.5,
                  imageStd: 0.5,
                ).then((thirdOutput) {
                  if (thirdOutput[0]['index'] == 0) {
                    setState(() {
                      _output = secondOutput;
                      _loading = false;
                    });
                  } else {
                    setState(() {
                      _output = firstOutput;
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
              // recalibration start
              // if (secondOutput[0]['index'] == 2 &&
              //     ((secondOutput[0]['confidence'] > 0.75 &&
              //             firstOutput[0]['confidence'] < 0.75) ||
              //         (firstOutput[0]['confidence'] > 0.75 &&
              //             secondOutput[0]['confidence'] < 0.75)) &&
              //     ((secondOutput[0]['confidence'] -
              //                 firstOutput[0]['confidence'])
              //             .abs() >
              //         0.1)) {
              //   loadModel(9399).then((_) {
              //     Tflite.runModelOnImage(
              //       path: image.path,
              //       numResults: 3,
              //       threshold: 0.333,
              //       imageMean: 0.5,
              //       imageStd: 0.5,
              //     ).then((forthOutput) {
              //       if (forthOutput[0]['index'] == 0) {
              //         setState(() {
              //           _output = forthOutput;
              //           _loading = false;
              //         });
              //       } else {
              //         setState(() {
              //           _output = firstOutput;
              //           _loading = false;
              //         });
              //       }
              //     }).catchError((_) {
              //       setState(() {
              //         _output = firstOutput;
              //         _loading = false;
              //       });
              //     });
              //   });
              // recalibration end
              // } else {
              setState(() {
                _output = firstOutput[0]['confidence'] >
                    secondOutput[0]['confidence']
                    ? firstOutput
                    : secondOutput;
                _loading = false;
              });
              // }
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
            numResults: 3,
            threshold: 0.333,
            imageMean: 0.5,
            imageStd: 0.5,
          ).then((secondOutput) {
            setState(() {
              _output =
              firstOutput[0]['confidence'] > secondOutput[0]['confidence']
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
          numResults: 3,
          threshold: 0.333,
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
              numResults: 3,
              threshold: 0.333,
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
}*/

//////////////////////////////////////////////////////////////////////////////////////

/*
classifyImage(File image) {
  loadModel(9690).then((_) {
    Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.333,
      imageMean: 127.5,
      imageStd: 127.5,
    ).then((firstOutput) {
      if (firstOutput[0]['index'] != 1) {
        num oppositeResult = 2 - firstOutput[0]['index'];
        loadModel(9398).then((_) {
          Tflite.runModelOnImage(
            path: image.path,
            numResults: 3,
            threshold: 0.333,
            imageMean: 0.5,
            imageStd: 0.5,
          ).then((secondOutput) {
            if (secondOutput[0]['index'] == oppositeResult &&
                secondOutput[0]['confidence'] > 0.55) {
              loadModel(9474).then((_) {
                Tflite.runModelOnImage(
                  path: image.path,
                  numResults: 3,
                  threshold: 0.333,
                  imageMean: 0.5,
                  imageStd: 0.5,
                ).then((thirdOutput) {
                  if (thirdOutput[0]['index'] == oppositeResult &&
                      thirdOutput[0]['confidence'] > 0.7) {
                    setState(() {
                      _output = thirdOutput[0]['confidence'] >
                          secondOutput[0]['confidence']
                          ? thirdOutput
                          : secondOutput;
                      _loading = false;
                    });
                  } else if (thirdOutput[0]['index'] ==
                      firstOutput[0]['index']) {
                    loadModel(9396).then((_) {
                      Tflite.runModelOnImage(
                        path: image.path,
                        numResults: 3,
                        threshold: 0.333,
                        imageMean: 0.5,
                        imageStd: 0.5,
                      ).then((forthOutput) {
                        if (forthOutput[0]['index'] == oppositeResult &&
                            forthOutput[0]['confidence'] > 0.65 &&
                            firstOutput[0]['confidence'] < 0.55) {
                          setState(() {
                            _output = forthOutput[0]['confidence'] >
                                secondOutput[0]['confidence']
                                ? forthOutput
                                : secondOutput;
                            _loading = false;
                          });
                        } else {
                          setState(() {
                            _output = firstOutput;
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
                    setState(() {
                      _output = firstOutput;
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
              if (secondOutput[0]['index'] == firstOutput[0]['index']) {
                setState(() {
                  _output = firstOutput[0]['confidence'] >
                      secondOutput[0]['confidence']
                      ? firstOutput
                      : secondOutput;
                  _loading = false;
                });
              } else {
                setState(() {
                  _output = firstOutput;
                  _loading = false;
                });
              }
            }
          }).catchError((_) {
            setState(() {
              _output = firstOutput;
              _loading = false;
            });
          });
        });
      } else {
        setState(() {
          _output = firstOutput;
          _loading = false;
        });
      }
    }).catchError((_) {
      loadModel(9474).then((_) {
        Tflite.runModelOnImage(
          path: image.path,
          numResults: 3,
          threshold: 0.333,
          imageMean: 0.5,
          imageStd: 0.5,
        ).then((secondOutput) {
          setState(() {
            _output = secondOutput;
            _loading = false;
          });
        }).catchError((_) {
          loadModel(9398).then((_) {
            Tflite.runModelOnImage(
              path: image.path,
              numResults: 3,
              threshold: 0.333,
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
}*/

////////////////////////////////////////////////////////////////////////////////////

/*classifyImage(File image) {
  loadModel(9690).then((_) {
    Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.333,
      imageMean: 127.5,
      imageStd: 127.5,
    ).then((firstOutput) {
      if (firstOutput[0]['index'] != 1) {
        num oppositeResult = 2 - firstOutput[0]['index'];
        loadModel(9398).then((_) {
          Tflite.runModelOnImage(
            path: image.path,
            numResults: 3,
            threshold: 0.333,
            imageMean: 0.5,
            imageStd: 0.5,
          ).then((secondOutput) {
            if (secondOutput[0]['index'] == oppositeResult &&
                secondOutput[0]['confidence'] > 0.55) {
              loadModel(9474).then((_) {
                Tflite.runModelOnImage(
                  path: image.path,
                  numResults: 3,
                  threshold: 0.333,
                  imageMean: 0.5,
                  imageStd: 0.5,
                ).then((thirdOutput) {
                  if (thirdOutput[0]['index'] == oppositeResult &&
                      thirdOutput[0]['confidence'] > 0.7) {
                    setState(() {
                      _output = thirdOutput[0]['confidence'] >
                          secondOutput[0]['confidence']
                          ? thirdOutput
                          : secondOutput;
                      _loading = false;
                    });
                  } else if (thirdOutput[0]['index'] ==
                      firstOutput[0]['index']) {
                    loadModel(9401).then((_) {
                      Tflite.runModelOnImage(
                        path: image.path,
                        numResults: 3,
                        threshold: 0.333,
                        imageMean: 0.5,
                        imageStd: 0.5,
                      ).then((forthOutput) {
                        if (forthOutput[0]['index'] == oppositeResult &&
                            forthOutput[0]['confidence'] > 0.65 &&
                            firstOutput[0]['confidence'] < 0.65) {
                          setState(() {
                            _output = forthOutput[0]['confidence'] >
                                secondOutput[0]['confidence']
                                ? forthOutput
                                : secondOutput;
                            _loading = false;
                          });
                        } else {
                          setState(() {
                            _output = firstOutput;
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
                    setState(() {
                      _output = firstOutput;
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
              if (secondOutput[0]['index'] == firstOutput[0]['index']) {
                setState(() {
                  _output = firstOutput[0]['confidence'] >
                      secondOutput[0]['confidence']
                      ? firstOutput
                      : secondOutput;
                  _loading = false;
                });
              } else {
                setState(() {
                  _output = firstOutput;
                  _loading = false;
                });
              }
            }
          }).catchError((_) {
            setState(() {
              _output = firstOutput;
              _loading = false;
            });
          });
        });
      } else {
        setState(() {
          _output = firstOutput;
          _loading = false;
        });
      }
    }).catchError((_) {
      loadModel(9474).then((_) {
        Tflite.runModelOnImage(
          path: image.path,
          numResults: 3,
          threshold: 0.333,
          imageMean: 0.5,
          imageStd: 0.5,
        ).then((secondOutput) {
          setState(() {
            _output = secondOutput;
            _loading = false;
          });
        }).catchError((_) {
          loadModel(9398).then((_) {
            Tflite.runModelOnImage(
              path: image.path,
              numResults: 3,
              threshold: 0.333,
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
}*/

/*
classifyImage(File image) {
  loadModel(9690).then((_) {
    Tflite.runModelOnImage(
      path: image.path,
      numResults: 3,
      threshold: 0.333,
      imageMean: 127.5,
      imageStd: 127.5,
    ).then((firstOutput) {
      if (firstOutput[0]['index'] != 1) {
        loadModel(9580).then((_) {
          Tflite.runModelOnImage(
            path: image.path,
            numResults: 3,
            threshold: 0.333,
            imageMean: 0.5,
            imageStd: 0.5,
          ).then((secondOutput) {
            loadModel(9401).then((_) {
              Tflite.runModelOnImage(
                path: image.path,
                numResults: 3,
                threshold: 0.333,
                imageMean: 0.5,
                imageStd: 0.5,
              ).then((thirdOutput) {
                if (thirdOutput[0]['index'] == 0 &&
                    secondOutput[0]['index'] == 0) {
                  setState(() {
                    _output = thirdOutput[0]['confidence'] >
                        secondOutput[0]['confidence']
                        ? thirdOutput
                        : secondOutput;
                    _loading = false;
                  });
                }else if (thirdOutput[0]['index'] == 1 ||
                    secondOutput[0]['index'] == 1) {
                  setState(() {
                    _output = firstOutput;
                    _loading = false;
                  });
                } else {
                  loadModel(9474).then((_) {
                    Tflite.runModelOnImage(
                      path: image.path,
                      numResults: 3,
                      threshold: 0.333,
                      imageMean: 0.5,
                      imageStd: 0.5,
                    ).then((forthOutput) {
                      loadModel(9398).then((_) {
                        Tflite.runModelOnImage(
                          path: image.path,
                          numResults: 3,
                          threshold: 0.333,
                          imageMean: 0.5,
                          imageStd: 0.5,
                        ).then((fifthOutput) {
                          var cumulativeManIndex =
                              (-firstOutput[0]['index'] / 2).floor() +
                                  (-secondOutput[0]['index'] / 2).floor() +
                                  (-thirdOutput[0]['index'] / 2).floor() +
                                  (-forthOutput[0]['index'] / 2).floor() +
                                  (-fifthOutput[0]['index'] / 2).floor() +
                                  5;
                          var genderConfidence = 0;
                          if (cumulativeManIndex >= 3) {
                            if (firstOutput[0]['index'] == 0 &&
                                firstOutput[0]['confidence'] >
                                    genderConfidence) {
                              genderConfidence = firstOutput[0]['confidence'];
                              _output = firstOutput;
                            }
                            if (secondOutput[0]['index'] == 0 &&
                                secondOutput[0]['confidence'] >
                                    genderConfidence) {
                              genderConfidence = secondOutput[0]['confidence'];
                              _output = secondOutput;
                            }
                            if (thirdOutput[0]['index'] == 0 &&
                                thirdOutput[0]['confidence'] >
                                    genderConfidence) {
                              genderConfidence = thirdOutput[0]['confidence'];
                              _output = thirdOutput;
                            }
                            if (forthOutput[0]['index'] == 0 &&
                                forthOutput[0]['confidence'] >
                                    genderConfidence) {
                              genderConfidence = forthOutput[0]['confidence'];
                              _output = forthOutput;
                            }
                            if (fifthOutput[0]['index'] == 0 &&
                                fifthOutput[0]['confidence'] >
                                    genderConfidence) {
                              genderConfidence = fifthOutput[0]['confidence'];
                              _output = fifthOutput;
                            }
                          } else {
                            if (firstOutput[0]['index'] == 2 &&
                                firstOutput[0]['confidence'] >
                                    genderConfidence) {
                              genderConfidence = firstOutput[0]['confidence'];
                              _output = firstOutput;
                            }
                            if (secondOutput[0]['index'] == 2 &&
                                secondOutput[0]['confidence'] >
                                    genderConfidence) {
                              genderConfidence = secondOutput[0]['confidence'];
                              _output = secondOutput;
                            }
                            if (thirdOutput[0]['index'] == 2 &&
                                thirdOutput[0]['confidence'] >
                                    genderConfidence) {
                              genderConfidence = thirdOutput[0]['confidence'];
                              _output = thirdOutput;
                            }
                            if (forthOutput[0]['index'] == 2 &&
                                forthOutput[0]['confidence'] >
                                    genderConfidence) {
                              genderConfidence = forthOutput[0]['confidence'];
                              _output = forthOutput;
                            }
                            if (fifthOutput[0]['index'] == 2 &&
                                fifthOutput[0]['confidence'] >
                                    genderConfidence) {
                              genderConfidence = fifthOutput[0]['confidence'];
                              _output = fifthOutput;
                            }
                            var cumulativeManIndex =
                                (firstOutput[0]['index'] ~/ 2 +
                                    secondOutput[0]['index'] ~/ 2 +
                                    thirdOutput[0]['index'] ~/ 2 +
                                    forthOutput[0]['index'] ~/ 2 +
                                    fifthOutput[0]['index'] ~/ 2) +
                                    5;

                            if (cumulativeManIndex >= 3) {
                              if (genderConfidence > 0.8) {
                                setState(() {
                                  _output = _output;
                                  _loading = false;
                                });
                              } else {
                                if (firstOutput[0]['index'] == 0 &&
                                    firstOutput[0]['confidence'] >
                                        genderConfidence) {
                                  genderConfidence = firstOutput[0]['confidence'];
                                  _output = firstOutput;
                                }
                                if (secondOutput[0]['index'] == 0 &&
                                    secondOutput[0]['confidence'] >
                                        genderConfidence) {
                                  genderConfidence = secondOutput[0]['confidence'];
                                  _output = secondOutput;
                                }
                                if (thirdOutput[0]['index'] == 0 &&
                                    thirdOutput[0]['confidence'] >
                                        genderConfidence) {
                                  genderConfidence = thirdOutput[0]['confidence'];
                                  _output = thirdOutput;
                                }
                                if (forthOutput[0]['index'] == 0 &&
                                    forthOutput[0]['confidence'] >
                                        genderConfidence) {
                                  genderConfidence = forthOutput[0]['confidence'];
                                  _output = forthOutput;
                                }
                                if (fifthOutput[0]['index'] == 0 &&
                                    fifthOutput[0]['confidence'] >
                                        genderConfidence) {
                                  genderConfidence = fifthOutput[0]['confidence'];
                                  _output = fifthOutput;
                                }
                                setState(() {
                                  _output = _output;
                                  _loading = false;
                                });
                              }
                            } else {
                              setState(() {
                                _output = firstOutput;
                                _loading = false;
                              });
                            }
                          }
                        }).catchError((_) {
                          setState(() {
                            _output = firstOutput;
                            _loading = false;
                          });
                        });
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
                setState(() {
                  _output = firstOutput;
                  _loading = false;
                });
              });
            });
          }).catchError((_) {
            setState(() {
              _output = firstOutput;
              _loading = false;
            });
          });
        });
      } else {
        setState(() {
          _output = firstOutput;
          _loading = false;
        });
      }
    }).catchError((_) {
      loadModel(9474).then((_) {
        Tflite.runModelOnImage(
          path: image.path,
          numResults: 3,
          threshold: 0.333,
          imageMean: 0.5,
          imageStd: 0.5,
        ).then((secondOutput) {
          setState(() {
            _output = secondOutput;
            _loading = false;
          });
        }).catchError((_) {
          loadModel(9398).then((_) {
            Tflite.runModelOnImage(
              path: image.path,
              numResults: 3,
              threshold: 0.333,
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
}*/
