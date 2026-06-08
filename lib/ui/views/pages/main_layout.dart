// lib/ui/views/layouts/main_layout.dart

import 'package:flutter/material.dart';
import 'package:mmac/ui/views/pages/new_application/new_application_page.dart';
import 'package:mmac/ui/views/pages/home.dart';
import 'package:mmac/ui/views/pages/update_application.dart';
import 'package:mmac/ui/views/pages/faqs.dart';
import 'package:mmac/ui/views/widgets/national_header.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. Change to 'late' so we can initialize it after the TabController
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // 2. Initialize the pages here, passing the controller logic to Home
    _pages = [
      Home(
        onStartNewApplication: () {
          _tabController.animateTo(1);
        },
      ),
      const NewApplication(),
      const UpdateApplication(),
      FAQS(
        onReturnHome: () {
          // Index 0 is the "Home" tab
          _tabController.animateTo(0);
        },
      ),
    ];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ... Keep your _buildCustomTab and build methods exactly as they are ...

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
                      // ဘယ်ဘက်ခြမ်း Title စာသား
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
                            width: isMobile
                                ? null
                                : 700, // Desktop တွင် သင့်မူလ 700 width အတိုင်း ပေါ်ပါမည်
                            child: TabBar(
                              controller: _tabController,
                              // 💡 Mobile တွင် စာသားများ အစုံအလင်ပေါ်စေရန် scroll ဆွဲနိုင်အောင် true ပေးပြီး Desktop တွင် အညီအမျှဖြစ်အောင် false ပေးထားပါသည်
                              isScrollable: isMobile,
                              dividerColor: Colors.transparent,
                              labelColor: Colors.blue.shade800,
                              unselectedLabelColor: Colors.grey.shade600,
                              labelStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              tabs: [
                                _buildCustomTab("Home"),
                                _buildCustomTab("New Application"),
                                _buildCustomTab("Update Application"),
                                _buildCustomTab("FAQs"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ───────────────────────────────────────────────────────────────────────
              ],
            ),
          ),
        ),
      ),

      body: TabBarView(controller: _tabController, children: _pages),
    );
  }
}
