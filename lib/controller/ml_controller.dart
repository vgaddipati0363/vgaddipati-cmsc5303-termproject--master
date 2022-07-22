import 'dart:io';

import 'package:google_ml_kit/google_ml_kit.dart';

class GoogleMLController {

  static const minConfidence = 0.6;


  
  static Future<List<dynamic>> getImageLabels({
    required File photo,
  }) async {
    try {
      var inputImage = InputImage.fromFile(photo);
      final ImageLabeler = GoogleMlKit.vision.imageLabeler();
      final List<ImageLabel> imageLabels = await ImageLabeler.processImage(
          inputImage);
      ImageLabeler.close();

      List<dynamic> results = [];
      for (var i in imageLabels) {
        if (i.confidence >= minConfidence) {
          results.add(i.label.toLowerCase());
        }
      }

      return results;
    }catch(e){
      print("error while getting labels");
      return [];
    }

  }
  static Future<List<dynamic>> getTextLables({
    required File photo,
  }) async {
    var inputImage = InputImage.fromFile(photo);
    final ImageLabeler = GoogleMlKit.vision.textRecognizer();
    RecognizedText  imageLabels = await ImageLabeler.processImage(inputImage);
    List<dynamic> results=imageLabels.text.split(' ');
    print("================text is ========================");
    print(imageLabels.text);
    print("================================================");
    ImageLabeler.close();
    print("result for text extraction is ${results}");
    return results;

  }
}