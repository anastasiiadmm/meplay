import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../utils/settings.dart';
import '../models.dart';
import '../theme.dart';
import 'circle.dart';


class PacketCarousel extends StatefulWidget {
  final List<Packet> packets;
  final void Function(Packet packet) connect;
  final void Function(Packet packet) disconnect;
  final int activeId;
  final void Function(int id) onChange;

  static const double bannerHeight = 164;
  static const double topShadowPadding = 20;
  static const double bottomShadowPadding = 20;
  static const double dotsHeight = 28;
  static const totalHeight = bannerHeight + topShadowPadding
      + bottomShadowPadding + dotsHeight;

  PacketCarousel({
    Key key,
    @required this.packets,
    this.connect,
    this.disconnect,
    this.activeId: 0,
    this.onChange
  }): assert(packets.length > 0),
        super(key: key);

  @override
  _PacketCarouselState createState() => _PacketCarouselState();
}


class _PacketCarouselState extends State<PacketCarousel> {
  int _activeId;
  CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
    _activeId = widget.activeId;
  }

  void _switchTo(int id) {
    _controller.animateToPage(id);
  }

  void _pageChanged(int id, CarouselPageChangedReason reason) {
    if(widget.onChange != null) widget.onChange(id); 
    setState(() { _activeId = id; });
  }

  Widget _dot(id) {
    Widget dot;
    if (id == _activeId) {
      dot = Circle.dot(
        color: AppColorsV2.purple,
        radius: 4,
      );
    } else {
      dot = GestureDetector(
        onTap: () => _switchTo(id),
        child: Circle.dot(
          color: AppColorsV2.decorativeGray,
          radius: 4,
        ),
      );
    }
    if (id > 0) {
      dot = Padding(
        padding: EdgeInsets.only(left: 8),
        child: dot,
      );
    }
    return dot;
  }

  Widget get _dots {
    List<Widget> items = [];
    for(int id = 0; id < widget.packets.length; id++) {
      items.add(_dot(id));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: items,
    );
  }

  // Widget get _confirmButton =>

  Widget _packet(int id) {
    Packet packet = widget.packets[id];
    AppLocalizations l = locale(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, PacketCarousel.topShadowPadding,
        16, PacketCarousel.bottomShadowPadding + PacketCarousel.dotsHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppColorsV2.decorativeGray,
          boxShadow: [
            BoxShadow(
              color: AppColorsV2.darkShadow,
              offset: Offset(0, 10),
              blurRadius: 35,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 68, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l.packet} ${packet.name}',
                    style: AppFontsV2.blockTitle,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      packet.priceLabel,
                      style: AppFontsV2.itemTextPrimary,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      packet.channelDisplay,
                      style: AppFontsV2.itemTextSecondary,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: packet.isActive
                            ? AppColorsV2.red
                            : AppColorsV2.green,
                      ),
                      child: GestureDetector(
                        onTap: packet.isActive
                            ? () => widget.disconnect(packet)
                            : () => widget.connect(packet),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 6, 16, 10),
                          child: Text(
                            packet.isActive ? l.packetDisable : l.packetEnable,
                            style: AppFontsV2.smallButton,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if(packet.isActive) Positioned(
              top: 12,
              right: 12,
              child: Circle(
                radius: 20,
                padding: EdgeInsets.all(8),
                child: AppIconsV2.check,
                color: AppColorsV2.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget get _packetCarousel {
    List<Widget> items = [];
    for(int id = 0; id < widget.packets.length; id++) {
      items.add(_packet(id));
    }
    return CarouselSlider(
      carouselController: _controller,
      items: items,
      options: CarouselOptions(
        viewportFraction: 1,
        height: PacketCarousel.totalHeight,
        autoPlay: false,
        onPageChanged: _pageChanged,
        disableCenter: true,
        initialPage: _activeId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _packetCarousel,
        Positioned(
          left: 0,
          right: 0,
          bottom: PacketCarousel.bottomShadowPadding,
          child: _dots,
        ),
      ],
    );
  }
}
