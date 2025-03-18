import 'package:flutter/material.dart';

class PlayerPage extends StatefulWidget {
  const PlayerPage({super.key});

  @override
  PlayerPageState createState() => PlayerPageState();
}

class PlayerPageState extends State<PlayerPage> {
  bool _menuExpanded = false;
  double _seekingPos = 0;
  bool _seeking = false;

  @override
  Widget build(BuildContext context) {
    late final colorScheme = Theme.of(context).colorScheme;
    late final backgroundColor = Color.alphaBlend(
      colorScheme.primary,
      colorScheme.surface,
    );
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildPlayer(colorScheme),
                  ),
                ),
                _menuExpanded
                    ? Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SizedBox(
                          width: 300,
                          child: _buildSidePanel(colorScheme, backgroundColor),
                        ),
                      )
                    : const SizedBox(),
              ],
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 28,
            height: 30,
            child: Row(
              children: [
                Expanded(child: _buildSeekbar()),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: _buildControlbar(colorScheme),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  Widget _buildPlayer(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      child: Container(
        color: Colors.black,
        child: const SizedBox.expand(),
      ),
    );
  }

  Widget _buildSeekbar() {
    return SliderTheme(
      data: SliderThemeData(
        // ignore: deprecated_member_use

        trackHeight: 4,

        overlayShape: SliderComponentShape.noOverlay,
      ),
      child: Slider(
        max: 100,
        value: _seeking ? _seekingPos : 60,
        onChanged: (value) {
          setState(() {
            _seekingPos = value;
          });
        },
        onChangeStart: (value) {
          setState(() {
            _seeking = true;
          });
        },
        onChangeEnd: (value) {
          // seek then setstate
          setState(() {
            _seeking = false;
          });
        },
      ),
    );
  }

  Widget _buildSidePanel(ColorScheme colorScheme, Color backgroundColor) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(18)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('panel'),
        ),
      ),
    );
  }

  Widget _buildControlbar(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              const SizedBox(width: 16),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.volume_up),
              ),
              SizedBox(
                width: 100,
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: colorScheme.secondaryContainer,
                    thumbColor: colorScheme.onSecondaryContainer,
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    max: 100,
                    value: 30,
                    onChanged: (value) {},
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'openfile',
          icon: const Icon(Icons.file_open_outlined),
          onPressed: () {},
        ),
        const SizedBox(width: 10),
        IconButton.filled(
          tooltip: 'play or pause',
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          iconSize: 28,
          onPressed: () {},
          icon: const Icon(Icons.play_arrow_outlined),
        ),
        const SizedBox(width: 10),
        IconButton.filledTonal(
          tooltip: 'command',
          icon: const Icon(Icons.terminal),
          onPressed: () {},
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _menuExpanded = !_menuExpanded;
                  });
                },
                icon: const Icon(
                  Icons.menu,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
