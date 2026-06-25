// lib/ui/views/layouts/main_layout.dart

import 'package:flutter/material.dart';
import 'package:mmac/data/models/submit_request_model.dart';
import 'package:mmac/ui/views/pages/home.dart';
import 'package:mmac/ui/views/pages/new_application/new_application_page.dart';
import 'package:mmac/ui/views/pages/new_application/residency_layout.dart';
import 'package:mmac/ui/views/pages/faqs.dart';
import 'package:mmac/ui/views/pages/qr_scan_page.dart';
import 'package:mmac/ui/views/pages/update_application.dart';
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
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // 🎯 Tab ပြောင်းတိုင်း ဘယ် Tab ရောက်နေလဲဆိုတာကို မှတ်ထားမည် (Refresh လုပ်ရင် ပြန်သိအောင်)
    _tabController.addListener(() async {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _fetchedUpdateData = null;
        });
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_active_tab', _tabController.index);
      }
    });

    _checkActiveSessionOnLoad();
  }

  Future<void> _checkActiveSessionOnLoad() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int savedTabIndex = prefs.getInt('last_active_tab') ?? 0;

      if (mounted) {
        _tabController.index = savedTabIndex;
      }

      // 🎯 လက်ရှိရောက်နေသော Tab အလိုက် မှန်ကန်သော Session Key ကို ခေါ်ယူမည်
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
      if (mounted) {
        setState(() {
          _isSessionLoading = false;
        });
      }
    }
  }

  Future<void> _handleResidencySelection(String newResidency) async {
    final bool isUpdate = _tabController.index == 2; // 🎯 လက်ရှိ Tab ကို စစ်မည်

    if (_selectedResidency != null && _selectedResidency != newResidency) {
      final bool? confirmReset = await showDialog<bool>(
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
            title: const Text(
              'Change Residency Type?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: const SizedBox(
              width:
                  320, //  Box ကို ရှည်မထွက်သွားစေရန် အကျယ်ထိန်းပေးခြင်း (Square-ish Shape)
              child: Text(
                'Changing your residency type will clear all the data you have filled so far. Are you sure you want to proceed?',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
            actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
            actions: [
              // Form ထဲက Back ခလုတ်ပုံစံအတိုင်း
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
              // Form ထဲက Next ခလုတ်ပုံစံအတိုင်း (ဒေတာဖျက်မှာမို့ အရောင်ကို အနီရောင်သာ သုံးထားပါသည်)
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
                child: const Text(
                  'Yes, Clear Data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      );

      if (confirmReset != true) return;
      await FormSessionService.clearDraft(
        isUpdateMode: isUpdate,
      ); //  သက်ဆိုင်ရာ Tab ရဲ့ Data ကိုသာ ဖျက်မည်
    }

    setState(() {
      _selectedResidency = newResidency;
      _formKey = UniqueKey();
      _fetchedUpdateData = null;
    });
  }

  Future<void> _goBackToResidency() async {
    final bool isUpdate = _tabController.index == 2; //  လက်ရှိ Tab ကို စစ်မည်

    final bool? confirmReset = await showDialog<bool>(
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
          title: const Text(
            'Go Back & Clear Data?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const SizedBox(
            width: 320, //  Box ကို ရှည်မထွက်သွားစေရန် အကျယ်ထိန်းပေးခြင်း
            child: Text(
              'Going back to change your residency will clear all the data you have filled so far. Are you sure?',
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
          actionsPadding: const EdgeInsets.only(right: 20, bottom: 20),
          actions: [
            // Form ထဲက Back ခလုတ်ပုံစံအတိုင်း
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
            // Form ထဲက Next ခလုတ်ပုံစံအတိုင်း (ဒေတာဖျက်မှာမို့ အရောင်ကို အနီရောင်သာ သုံးထားပါသည်)
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
              child: const Text(
                'Yes, Go Back',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmReset == true) {
      await FormSessionService.clearDraft(
        isUpdateMode: isUpdate,
      ); //  သက်ဆိုင်ရာ Tab ရဲ့ Data ကိုသာ ဖျက်မည်
      setState(() {
        _selectedResidency = null;
        _formKey = UniqueKey();
        _fetchedUpdateData = null;
      });
    }
  }

  //  Parameter ထည့်ပြီး သက်ဆိုင်ရာ Tab ရဲ့ Session ကို စစ်ဆေးအောင် ပြင်ဆင်ထားသည်
  Future<void> _resumeOrStartNew(int targetTabIndex) async {
    final bool isUpdate = targetTabIndex == 2;
    final sessionData = await FormSessionService.loadDraft(
      isUpdateMode: isUpdate,
    );

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

  Widget _buildCustomTab(String label, bool isMobile) {
    return Tab(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isMobile ? const SizedBox() : const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isMobile ? 8 : 14,
              fontFamily: 'sans-serif',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 500;

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
                    mainAxisAlignment: isMobile
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: isMobile ? null : 700,
                            child: TabBar(
                              controller: _tabController,
                              isScrollable: isMobile,

                              dividerColor: Colors.transparent,
                              labelColor: Colors.blue.shade800,
                              unselectedLabelColor: Colors.black87,
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
                                _buildCustomTab("Home", isMobile),
                                _buildCustomTab("New Application", isMobile),
                                _buildCustomTab("Update Application", isMobile),
                                _buildCustomTab("FAQs", isMobile),
                                _buildCustomTab("QrScan", isMobile),
                              ],
                              onTap: (index) async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setInt('last_active_tab', index);

                                if (index == 1 || index == 2) {
                                  await _resumeOrStartNew(
                                    index,
                                  ); //  သက်ဆိုင်ရာ Session ကို ပြန်စစ်မည်
                                } else {
                                  setState(() {
                                    _selectedResidency = null;
                                  });
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
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('last_active_tab', 1);
                    await _resumeOrStartNew(1);
                    _tabController.animateTo(1);
                  },
                  onStartUpdateWorkflow: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setInt('last_active_tab', 2);
                    await _resumeOrStartNew(
                      2,
                    ); // 🎯 Update အတွက် Session မှန်ကန်စွာ စစ်မည်
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
                _selectedResidency == null
                    ? ResidencyLayout(
                        onResidencySelected: _handleResidencySelection,
                      )
                    : (_fetchedUpdateData == null
                          // အခြေအနေ (က) - ဒေတာမရှိသေးရင် Verification (ရှာဖွေရေးဖောင်) ကို ပြထားမည်
                          ? UpdateApplication(
                              onBackPressed: () {
                                setState(() {
                                  _selectedResidency = null;
                                  _formKey = UniqueKey();
                                  _fetchedUpdateData = null;
                                });
                              },

                              initialCountry: _selectedResidency,
                              onApplicationFetched: (SubmitRequestModel data) {
                                // ဒေတာရှာတွေ့တာနဲ့ ၎င်းဒေတာကို သိမ်းပြီး UI ကို Update ဖြစ်စေမည်
                                setState(() {
                                  _fetchedUpdateData = data;
                                });
                              },
                            )
                          //
                          : NewApplication(
                              key: ValueKey(
                                'update_form_${_fetchedUpdateData.hashCode}',
                              ),
                              initialCountry: _selectedResidency,
                              onBackPressed: () {
                                // Form ထဲကနေ နောက်ပြန်ဆုတ်ရင် ရှာဖွေရေးစာမျက်နှာဆီ ပြန်ပို့မည်
                                setState(() {
                                  _fetchedUpdateData = null;
                                });
                              },
                              isUpdateMode: true,
                              initialData: _fetchedUpdateData,
                            )),

                // ၄။ FAQS PAGE
                FAQS(
                  onReturnHome: () {
                    _tabController.animateTo(0);
                  },
                ),
                const QrScanPage(),
              ],
            ),
    );
  }
}
