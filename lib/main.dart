import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void drawContent(Canvas canvas) {
  final paint = Paint()..color = const Color(0xFFFF0000);
  canvas.drawCircle(const Offset(100, 100), 90, paint);
  canvas.drawImageRect(
    image,
    const Offset(0, 0) & Size(image.width.toDouble(), image.height.toDouble()),
    const Offset(0, 0) & const Size(100, 100),
    paint,
  );

  var vertices = ui.Vertices(
    VertexMode.triangles,
    const [
      Offset(0, 0),
      Offset(100, 0),
      Offset(100, 100),
      Offset(0, 100),
    ],
    textureCoordinates: [
      const Offset(0, 0),
      Offset(image.width.toDouble(), 0),
      Offset(image.width.toDouble(), image.height.toDouble()),
      Offset(0, image.height.toDouble()),
    ],
    indices: [
      0,
      1,
      2,
      2,
      3,
      0,
    ],
  );
  var identity = Float64List.fromList(
    [
      1, 0, 0, 0, // row
      0, 1, 0, 0, // row
      0, 0, 1, 0, // row
      0, 0, 0, 1, // your boat
    ],
  );
  canvas.save();
  canvas.translate(100, 0);
  canvas.drawVertices(
    vertices,
    BlendMode.srcOver,
    Paint()
      ..shader = ImageShader(
        image,
        TileMode.clamp,
        TileMode.clamp,
        identity,
      ),
  );
  canvas.restore();
}

ui.Picture makePicture() {
  final recorder = ui.PictureRecorder();
  drawContent(Canvas(recorder));
  return recorder.endRecording();
}

late ui.Image image;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var bytes = await rootBundle.load('assets/bee.jpg');

  var codec = await ui.instantiateImageCodec(bytes.buffer.asUint8List());
  var frameInfo = await codec.getNextFrame();
  image = frameInfo.image;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Picture Test',
      home: MyHomePage(title: 'Picture Test'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ui.Image? _image;

  _MyHomePageState() {
    makePicture().toImage(200, 200).then((img) {
      setState(() {
        _image = img;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: CustomPaint(
          size: Size.infinite,
          painter: MyPainter(_image),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final ui.Image? _image;

  MyPainter(ui.Image? img) : _image = img;

  void drawImg(Canvas canvas) {
    final paint = Paint();
    canvas.drawImage(_image!, Offset(0, 0), paint);
  }

  ui.Picture makePic() {
    final recorder = ui.PictureRecorder();
    drawImg(Canvas(recorder));
    return recorder.endRecording();
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (_image != null) {
      drawImg(canvas);
      canvas.translate(210, 0);
      canvas.drawPicture(makePic());
    }
  }

  //Called when CustomPainter is rebuilt.
  //Returning true because we want canvas to be rebuilt to reflect new changes.
  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}
