import 'dart:io';
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
          loadModel(9400).then((_) {
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
            loadModel(9400).then((_) {
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

// List _modelList = [9400,9396, 9690];
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
//   int _selectedValue = 9400;
//
//   classifyImage(File image) async {
//     var output = await Tflite.runModelOnImage(
//       path: image.path,
//       numResults: 2,
//       threshold: 0.5,
//       imageMean: 0.5 * (_selectedValue != 9690 ? 1 : 255.0),
//       imageStd: 0.5 * (_selectedValue != 9690 ? 1 : 255.0),
//     );
//     setState(() {
//       _output = output;
//       _loading = false;
//     });
//   }
//
//   loadModel() async {
//     await Tflite.loadModel(
//       model: 'assets/model_MobileNetV2_v$_selectedValue.tflite', // Todo: change the model here
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
//             SizedBox(height: 30),
//             Text(
//               'Classify Men & Women',
//               style: TextStyle(
//                   color: Color(0xFFE99600),
//                   fontWeight: FontWeight.w500,
//                   fontSize: 28),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Center(
//               child: (_loading
//                   ? Container(
//                 width: 280,
//                 child: Column(
//                   children: <Widget>[
//                     Image.asset('assets/men_vs_women.png'),
//                     SizedBox(
//                       height: 85,
//                     )
//                   ],
//                 ),
//               )
//                   : Container(
//                 child: Column(
//                   children: <Widget>[
//                     Container(height: 250, child: Image.file(_image)),
//                     SizedBox(height: 10),
//                     _output != null
//                         ? Column(
//                       children: [
//                         Text('Identified Gender: ${_possibleOutputs[_output[0]['index']]}',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                             )),
//                         SizedBox(height: 10),
//                         Text('Confidence Level: ${(_output[0]['confidence']*100).toString().substring(0,5)}%',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                             )),
//                         SizedBox(height: 10),
//                       ],
//                     )
//
//                         : Container(),
//                   ],
//                 ),
//               )),
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
//                       EdgeInsets.symmetric(horizontal: 24, vertical: 17),
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
//                       EdgeInsets.symmetric(horizontal: 24, vertical: 17),
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
//                         title: Text('Model 0.'+e.toString(), style: TextStyle(color: Colors.white)),
//                         leading: Radio(
//                           value: e,
//                           groupValue: _selectedValue,
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedValue = value;
//                             });
//                             loadModel();
//                             if (_image != null) {
//                               classifyImage(_image);
//                             }
//                           },
//                           activeColor: Color(0xFFE99600),
//                         ),
//                       ),
//                     )
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
//       crossAxisAlignment: CrossAxisAlignment.center,
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
