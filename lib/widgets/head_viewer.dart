import 'package:flutter/material.dart';
import 'package:flutter_cube/flutter_cube.dart';

class HeadViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("3D Head Viewer")),
      body: Cube(
        onSceneCreated: (Scene scene) {
          scene.world.add(Object(
            fileName: 'assets/models/human_head.obj', // or .glb
          ));
          scene.camera.zoom = 10;
        },
      ),
    );
  }
}