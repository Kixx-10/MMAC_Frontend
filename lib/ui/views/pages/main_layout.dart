// lib/ui/views/layouts/main_layout.dart

import 'package:flutter/material.dart';
import 'package:mmac/ui/views/pages/new_application/new_application_page.dart';
import 'package:mmac/ui/views/pages/home.dart';
import 'package:mmac/ui/views/pages/new_application/residency_layout.dart';
import 'package:mmac/ui/views/pages/update_application.dart';
import 'package:mmac/ui/views/pages/faqs.dart';
import 'package:mmac/ui/views/widgets/national_header.dart';
import 'package:mmac/utils/form_session_service.dart';

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

  bool _isSessionLoading = true;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _checkActiveSessionOnLoad();
  }

  Future<void> _checkActiveSessionOnLoad() async {
    try {
      final sessionData = await FormSessionService.loadDraft();

      if (sessionData != null && mounted) {
        final values = sessionData['values'] as Map<String, dynamic>?;
        if (values != null && values['residencyType'] != null) {
          // Draft အဟောင်းရှိပါက Tab 1 (New App) သို့ ပြောင်းပြီး Residency ကို အသင့်ရွေးပေးထားမည်
          _tabController.index = 1;
          _selectedResidency = values['residencyType'];
        }
      }
    } catch (e) {
      debugPrint("Session check error on load: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSessionLoading = false;
        });
      }
    }
  }

  // Change the residency if user mistakenly choose it
  Future<void> _handleResidencySelection(String newResidency) async {
    // အရင်က ရွေးထားတာရှိပြီး၊ အခုရွေးတာနဲ့ မတူဘူးဆိုရင် (ဥပမာ - Native ကနေ Foreigner ပြောင်းတာ)
    if (_selectedResidency != null && _selectedResidency != newResidency) {
      // Warning Dialog ပြမယ်
      final bool? confirmReset = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Change Residency Type?'),
            content: const Text(
              'Changing your residency type will clear all the data you have filled so far. Are you sure you want to proceed?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(
                  context,
                ).pop(false), // Cancel နှိပ်ရင် false ပြန်မယ်
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(
                  context,
                ).pop(true), // Confirm နှိပ်ရင် true ပြန်မယ်
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Yes, Clear Data'),
              ),
            ],
          );
        },
      );

      // User က "Yes, Clear Data" ကို မနှိပ်ဘူးဆိုရင် ဘာမှမလုပ်ဘဲ ရပ်လိုက်မယ်
      if (confirmReset != true) return;

      // User က Confirm လုပ်တယ်ဆိုရင် Data အဟောင်းတွေကို ရှင်းထုတ်မယ်
      await FormSessionService.clearDraft();
    }

    // ဘာမှမရွေးရသေးတာပဲဖြစ်ဖြစ်၊ Data ရှင်းပြီးသွားတာပဲဖြစ်ဖြစ် State ကို အသစ်ချိန်းပေးမယ်
    setState(() {
      _selectedResidency = newResidency;
      _formKey = UniqueKey();
    });
  }

  // User က Form ဖြည့်နေရင်း နောက်ကို ပြန်ဆုတ်ချင်တဲ့အခါ
  Future<void> _goBackToResidency() async {
    final bool? confirmReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Go Back & Clear Data?'),
          content: const Text(
            'Going back to change your residency will clear all the data you have filled so far. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Yes, Go Back'),
            ),
          ],
        );
      },
    );

    if (confirmReset == true) {
      // Data တွေ ဖျက်မယ်
      await FormSessionService.clearDraft();

      // null ပြောင်းလိုက်ရင် ResidencyLayout ကြီး ပြန်ပေါ်လာလိမ့်မယ်
      setState(() {
        _selectedResidency = null;
        _formKey = UniqueKey();
      });
    }
  }

  // 🎯 Tab သို့မဟုတ် ခလုတ်နှိပ်လျှင် Draft ရှိမရှိ စစ်ဆေးပြီးမှ Residency ပြ/မပြ ဆုံးဖြတ်မည့် Logic
  Future<void> _resumeOrStartNew() async {
    final sessionData = await FormSessionService.loadDraft();
    if (sessionData != null &&
        sessionData['values'] != null &&
        sessionData['values']['residencyType'] != null) {
      setState(() {
        _selectedResidency = sessionData['values']['residencyType'];
      });
    } else {
      setState(() {
        _selectedResidency = null;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildCustomTab(String label) {
    return Tab(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontFamily: 'sans-serif'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        toolbarHeight: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(210),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const NationalHeader(),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE5E7EB),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(
                    right: isMobile ? 12 : 60,
                    left: isMobile ? 12 : 60,
                    bottom: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "MMAC",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: isMobile ? null : 700,
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: isMobile,
                              dividerColor: Colors.transparent,
                              labelColor: Colors.blue.shade800,
                              unselectedLabelColor: Colors.grey.shade600,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'sans-serif',
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              indicatorColor: Colors.blue.shade800,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              tabs: [
                                _buildCustomTab("Home"),
                                _buildCustomTab("New Application"),
                                _buildCustomTab("Update Application"),
                                _buildCustomTab("FAQs"),
                              ],
                              onTap: (index) {
                                if (index == 1) {
                                  _resumeOrStartNew(); // 🎯 ဇွတ် null မပေးတော့ဘဲ Draft ရှိရင် ပြန်ဆက်မည်
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // 🎯 Session ရှာနေတုန်း Body ကို အလွတ် (သို့ Loading) ပြထားမည်
      body: _isSessionLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // ၁။ HOME PAGE
                Home(
                  onStartNewApplication: () async {
                    // 🎯 ဒီမှာ Residency ကို အရင်စစ်မယ်၊ ပြီးမှ Tab ပြောင်းမယ်
                    await _resumeOrStartNew();

                    // 🎯 ပြီးမှ Tab 1 ကို ရွှေ့မယ်
                    _tabController.animateTo(1);
                  },
                  onStartUpdateWorkflow: () {
                    _tabController.animateTo(2);
                  },
                ),

                // ၂။ NEW APPLICATION OR RESIDENCY
                _selectedResidency == null
                    ? ResidencyLayout(
                        onResidencySelected: _handleResidencySelection,
                      )
                    : NewApplication(
                        key: _formKey,
                        initialCountry: _selectedResidency,
                        //Back လုပ်မယ့် Function ကို NewApplication ဆီ ထည့်မယ်
                        onBackPressed: _goBackToResidency,
                      ),

                // ၃။ UPDATE APPLICATION PAGE
                const UpdateApplication(),

                // ၄။ FAQS PAGE
                FAQS(
                  onReturnHome: () {
                    _tabController.animateTo(0);
                  },
                ),
              ],
            ),
    );
  }
}
