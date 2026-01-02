import 'package:flutter/material.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/feature/ble_menu.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/feature/wifi_menu.dart';
import 'package:flutter_xiao_nrf52840_nus_mon/screen/com/com_port_screen.dart';
import 'package:getwidget/components/tabs/gf_tabbar_view.dart';
import 'package:getwidget/components/tabs/gf_tabs.dart';

class TabMenuScreen extends StatefulWidget {
  const TabMenuScreen({super.key});

  @override
  State<TabMenuScreen> createState() => _TabMenuScreenState();
}

class _TabMenuScreenState extends State<TabMenuScreen>
    with SingleTickerProviderStateMixin {
  late final TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GFTabs(
      controller: tabController,
      length: 3,
      tabBarHeight: 30,
      tabs: <Widget>[
        Tab(icon: Icon(Icons.link)),
        Tab(icon: Icon(Icons.bluetooth_outlined)),
        Tab(icon: Icon(Icons.wifi)),
      ],
      tabBarView: GFTabBarView(
        controller: tabController,
        children: <Widget>[
          KeepAliveWrapper(child: ComScreen()),
          KeepAliveWrapper(child: BleMenu()),
          KeepAliveWrapper(child: WiFiMenu()),
        ],
      ),
    );
  }
}

// 2026-01-02 17:31, Louiey.
// whenever switch tab, it lost state so added keep alive wrapper to keep state alive
// so when i open com port and switch to ble tab, com tab disposed so com closed and need to reopen again and again
class KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const KeepAliveWrapper({super.key, required this.child});

  @override
  State<KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
