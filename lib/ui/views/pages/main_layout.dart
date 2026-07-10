// lib/ui/views/layouts/main_layout.dart

import 'package:flutter/material.dart';
import 'package:mmac/core/constants/app_fonts.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/ui/views/pages/home.dart';
import 'package:mmac/ui/views/pages/new_application/new_application_page.dart';
import 'package:mmac/ui/views/pages/new_application/residency_layout.dart';
import 'package:mmac/ui/views/pages/faqs.dart';
//import 'package:mmac/ui/views/pages/qr_scan_page.dart';
import 'package:mmac/ui/views/pages/update_application.dart';
import 'package:mmac/ui/views/pages/notice_page.dart';
import 'package:mmac/ui/views/widgets/national_header.dart';
import 'package:mmac/utils/form_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedResidency;
  Key _formKey = const ValueKey('form_start');
  SubmitRequestModel? _fetchedUpdateData;
  bool _isSessionLoading = true;
  bool _isMenuExpanded = false;
  bool _hasAcceptedNotice = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    _tabController.addListener(() async {
      if (mounted) setState(() {});

      if (!_tabController.indexIsChanging) {
        if (mounted) setState(() => _fetchedUpdateData = null);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_active_tab', _tabController.index);
      }
    });

    _checkActiveSessionOnLoad();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _checkActiveSessionOnLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int savedTabIndex = prefs.getInt('last_active_tab') ?? 0;
      final bool noticeAccepted = prefs.getBool('hasAcceptedNotice') ?? false;

      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _tabController.index = savedTabIndex;
          setState(() => _hasAcceptedNotice = noticeAccepted);
        });
      }

      if (savedTabIndex == 1 || savedTabIndex == 2) {
        final bool isUpdate = savedTabIndex == 2;
        final sessionData = await FormSessionService.loadDraft(
          isUpdateMode: isUpdate,
        );

        if (sessionData != null && mounted) {
          final values = sessionData['values'] as Map<String, dynamic>?;
          if (values != null && values['residencyType'] != null) {
            _selectedResidency = values['residencyType'];
          }
        }
      }
    } catch (e) {
      debugPrint("Session check error on load: $e");
    } finally {
      if (mounted) setState(() => _isSessionLoading = false);
    }
  }

  Future<void> _resumeOrStartNew(int targetTabIndex) async {
    final bool isUpdate = targetTabIndex == 2;
    final sessionData = await FormSessionService.loadDraft(
      isUpdateMode: isUpdate,
    );

    setState(() {
      if (sessionData != null &&
          sessionData['values']?['residencyType'] != null) {
        _selectedResidency = sessionData['values']['residencyType'];
      } else {
        _selectedResidency = null;
      }
    });
  }

  Future<void> _handleResidencySelection(String newResidency) async {
    final bool isUpdate = _tabController.index == 2;

    if (_selectedResidency != null && _selectedResidency != newResidency) {
      final bool? confirmReset = await _showWarningDialog(
        title: 'Change Residency Type?',
        message:
            'Changing your residency type will clear all the data you have filled so far. Are you sure you want to proceed?',
        confirmText: 'Yes, Clear Data',
      );

      if (confirmReset != true) return;
      await FormSessionService.clearDraft(isUpdateMode: isUpdate);
    }

    setState(() {
      _selectedResidency = newResidency;
      _formKey = UniqueKey();
      _fetchedUpdateData = null;
    });
  }

  Future<void> _goBackToResidency() async {
    final bool isUpdate = _tabController.index == 2;

    final bool? confirmReset = await _showWarningDialog(
      title: 'Go Back & Clear Data?',
      message:
          'Going back to change your residency will clear all the data you have filled so far. Are you sure?',
      confirmText: 'Yes, Go Back',
    );

    if (confirmReset == true) {
      await FormSessionService.clearDraft(isUpdateMode: isUpdate);
      setState(() {
        _selectedResidency = null;
        _formKey = UniqueKey();
        _fetchedUpdateData = null;
      });
    }
  }

  Future<bool?> _showWarningDialog({
    required String title,
    required String message,
    required String confirmText,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.only(
            top: 24,
            left: 24,
            right: 24,
            bottom: 16,
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: SizedBox(
            width: 320,
            child: Text(
              message,
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
          actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade700,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                confirmText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNewApplicationTab() {
    if (!_hasAcceptedNotice) {
      return NoticePage(
        onAccepted: () {
          setState(() {
            _hasAcceptedNotice = true;
          });
        },
      );
    }
    if (_selectedResidency == null) {
      return ResidencyLayout(onResidencySelected: _handleResidencySelection);
    }
    return NewApplication(
      key: _formKey,
      initialCountry: _selectedResidency,
      onBackPressed: _goBackToResidency,
    );
  }

  Widget _buildUpdateApplicationTab() {
    if (_selectedResidency == null) {
      return ResidencyLayout(onResidencySelected: _handleResidencySelection);
    }

    if (_fetchedUpdateData == null) {
      return UpdateApplication(
        onBackPressed: () {
          setState(() {
            _selectedResidency = null;
            _formKey = UniqueKey();
            _fetchedUpdateData = null;
          });
        },
        initialCountry: _selectedResidency,
        onApplicationFetched: (SubmitRequestModel data) {
          setState(() => _fetchedUpdateData = data);
        },
        onStartNewApplication: () {
          _handleTabTap(1);
        },
      );
    }

    return NewApplication(
      key: ValueKey('update_form_${_fetchedUpdateData.hashCode}'),
      initialCountry: _selectedResidency,
      isUpdateMode: true,
      initialData: _fetchedUpdateData,
      onBackPressed: () {
        setState(() => _fetchedUpdateData = null);
      },
    );
  }

  Future<void> _handleTabTap(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_active_tab', index);
    if (index == 1 || index == 2) {
      await _resumeOrStartNew(index);
    } else {
      setState(() => _selectedResidency = null);
    }
    _tabController.animateTo(index);
    if (mounted) setState(() {});
  }

  Widget _buildExpandableMenuItem(String title, int index) {
    final isActive = _tabController.index == index;
    return InkWell(
      onTap: () {
        _handleTabTap(index);
        setState(() {
          _isMenuExpanded = false;
        });
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: isActive ? const Color.fromRGBO(9, 156, 244, 1) : Colors.white,
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    // Auto-close menu if we resize back to desktop
    if (!isMobile && _isMenuExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _isMenuExpanded = false);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isSessionLoading
          ? const Center(child: CircularProgressIndicator())
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 44,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color.fromRGBO(9, 156, 244, 1),
                          ),
                        ),
                        const NationalHeader(),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFE5E7EB),
                        ),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyNavBarDelegate(
                      currentHeight: isMobile
                          ? (_isMenuExpanded ? 50.0 + (5 * 48.0) : 50.0)
                          : 50.0,

                      child: Column(
                        children: [
                          Container(
                            color: Colors.white,
                            height: 50.0,
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 1200,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 5,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (isMobile)
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          alignment: Alignment.centerLeft,
                                          icon: Icon(
                                            _isMenuExpanded
                                                ? Icons.close
                                                : Icons.menu,
                                            color: Colors.black87,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _isMenuExpanded =
                                                  !_isMenuExpanded;
                                            });
                                          },
                                        )
                                      else
                                        Row(
                                          children: [
                                            _CustomTabItem(
                                              label: "HOME",
                                              isActive:
                                                  _tabController.index == 0,
                                              onTap: () => _handleTabTap(0),
                                            ),
                                            const SizedBox(width: 5),
                                            _CustomTabItem(
                                              label: "NEW APPLICATION",
                                              isActive:
                                                  _tabController.index == 1,
                                              onTap: () => _handleTabTap(1),
                                            ),
                                            const SizedBox(width: 5),
                                            _CustomTabItem(
                                              label: "UPDATE APPLICATION",
                                              isActive:
                                                  _tabController.index == 2,
                                              onTap: () => _handleTabTap(2),
                                            ),
                                            const SizedBox(width: 5),
                                            _CustomTabItem(
                                              label: "FAQ",
                                              isActive:
                                                  _tabController.index == 3,
                                              onTap: () => _handleTabTap(3),
                                            ),

                                            // To be implemented in the future
                                            // const SizedBox(width: 5),
                                            // _CustomTabItem(
                                            //   label: "QrScan",
                                            //   isActive:
                                            //       _tabController.index == 4,
                                            //   onTap: () => _handleTabTap(4),
                                            // ),
                                          ],
                                        ),
                                      const Text(
                                        "Official Myanmar eArrival Card",
                                        style: TextStyle(
                                          fontFamily: AppFonts.primaryFont,
                                          fontSize: 21,
                                          fontWeight: FontWeight.w600,
                                          color: Color.fromRGBO(9, 156, 244, 1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (isMobile && _isMenuExpanded)
                            Expanded(
                              child: Container(
                                color: Colors.white,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildExpandableMenuItem("HOME", 0),
                                    _buildExpandableMenuItem(
                                      "NEW APPLICATION",
                                      1,
                                    ),
                                    _buildExpandableMenuItem(
                                      "UPDATE APPLICATION",
                                      2,
                                    ),
                                    _buildExpandableMenuItem("FAQS", 3),
                                   // _buildExpandableMenuItem("QRSCAN", 4),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // 1. HOME PAGE
                  Home(
                    onStartNewApplication: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('last_active_tab', 1);
                      await _resumeOrStartNew(1);
                      _tabController.animateTo(1);
                    },
                    onStartUpdateWorkflow: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setInt('last_active_tab', 2);
                      await _resumeOrStartNew(2);
                      _tabController.animateTo(2);
                    },
                  ),
                  // 2. NEW APPLICATION OR RESIDENCY
                  _buildNewApplicationTab(),
                  // 3. UPDATE APPLICATION PAGE
                  _buildUpdateApplicationTab(),
                  // 4. FAQS PAGE
                  FAQS(onReturnHome: () => _tabController.animateTo(0)),
                  // 5. QR SCAN PAGE
                  //const QrScanPage(),  To be implemented in the future
                ],
              ),
            ),
    );
  }
}

class _StickyNavBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double currentHeight;

  _StickyNavBarDelegate({required this.child, required this.currentHeight});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, height: currentHeight, child: child);
  }

  @override
  double get maxExtent => currentHeight;

  @override
  double get minExtent => currentHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}

class _CustomTabItem extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CustomTabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_CustomTabItem> createState() => _CustomTabItemState();
}

class _CustomTabItemState extends State<_CustomTabItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: widget.isActive
                ? const Color.fromRGBO(9, 156, 244, 1)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: _isHovered && !widget.isActive
                    ? const Color.fromRGBO(1, 156, 244, 1)
                    : Colors.transparent,
                width: 3.0,
              ),
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: widget.isActive
                  ? Colors.white
                  : (_isHovered ? const Color(0xFFB4CEF5) : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
