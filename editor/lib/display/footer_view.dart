import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/services/io.dart';
import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

/// The footer line for the application that contains the buttons for layers.
class FooterView extends StatelessWidget {
  /// The configurations for the application.
  final Map appConfigs;

  /// The controller for the particle system.
  final ParticularController controller;

  /// Creates a footer view.
  const FooterView(
      {super.key, required this.appConfigs, required this.controller});

  /// Creates a footer view.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.getNotifier(NotifierType.layer),
      builder: (context, child) {
        return Container(
          color: Colors.white10,
          height: appConfigs["footerHeight"],
          child: Row(children: [
            _footerItem(Icons.refresh, () => controller.resetTick()),
            SizedBox(width: appConfigs["timeline"]["sideWidth"] - 40),
            _footerItem(Icons.add, () => controller.addParticleSystem()),
            _footerItem(Icons.file_open, () async {
              final configs = await browseConfigs(["json"]);
              controller.addParticleSystem(configs: configs);
            }),
            _footerItem(Icons.save_alt, _exportConfigs),
          ]),
        );
      },
    );
  }

  /// This function creates an [IconButton] widget for the footer of the
  /// screen. The icon button represents an action and when pressed, it
  /// executes the provided function [onPressed].
  Widget _footerItem(IconData icon, Function() onPressed) {
    return IconButton(
      padding: const EdgeInsets.all(2),
      icon: Icon(icon, size: 12),
      onPressed: () => onPressed(),
    );
  }

  void _exportConfigs() {
    var layersConfigs = [];
    for (var i = 0; i < controller.layers.length; i++) {
      layersConfigs.add(controller.layers[i].getConfigs());
    }
    saveConfigs(configs: layersConfigs);
  }
}
