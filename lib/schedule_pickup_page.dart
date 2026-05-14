import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'api_service.dart';
import 'pickups_page.dart';

class SchedulePickupPage extends StatefulWidget {
  final String? userAddress;
  final String token;
  final String? username;

  const SchedulePickupPage({
    super.key,
    this.userAddress,
    required this.token,
    this.username,
  });

  @override
  State<SchedulePickupPage> createState() => SchedulePickupPageState();
}

class SchedulePickupPageState extends State<SchedulePickupPage> {
  String? selectedManpower;

  /// Stores full date like "2026-01-08"
  String? selectedDate;

  String? selectedTimeSlot; // backend value: "10-2pm" or "5-8pm"
  String? selectedWeight;

  String? userAddress;
  String? userPincode;

  final List<String> selectedCategories = [];
  final TextEditingController addressController = TextEditingController();
  final ApiService api = ApiService();

  /// dateOptions item:
  /// { "day": "Wed", "date": "8", "full": "2026-01-08" }
  final List<Map<String, String>> dateOptions = [];

  // Photo Upload state
  final ImagePicker picker = ImagePicker();
  XFile? pickupPhoto;
  File? pickupPhotoFile;

  bool isSubmitting = false;

  final List<String> categories = [
    "Paper",
    "Metals",
    "Big Appliances",
    "E-Waste",
    "Cartons & Plastics",
    "Others",
  ];

  final List<String> weightOptions = [
    "0-10 Kgs",
    "10-30 Kgs",
    "30-50 Kgs",
    "50-200 Kgs",
    "More than 200 Kgs",
  ];

  // ------------------ TIME ------------------
  // Backend values
  static const String slot10to2Value = "10-2pm";
  static const String slot5to8Value = "5-8pm";

  // UI labels
  static const String slot10to2Label = "10:00 AM - 2:00 PM";
  static const String slot5to8Label = "5:00 PM - 8:00 PM";

  // ------------------ MANPOWER ------------------
  // Backend values (sent to API)
  static const String manpowerLessThanFourValue = "less than four";
  static const String manpowerMoreThanFourValue = "more than four";

  // UI labels
  static const String manpowerLessThanFourLabel = "Less than four";
  static const String manpowerMoreThanFourLabel = "More than four";

  @override
  void initState() {
    super.initState();
    generateDateOptions();
    loadUserAddress();
  }

  // ---------- Time/date rules ----------
  DateTime todayAt(int hour, int minute) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  DateTime? getSelectedDateAsDateTime() {
    if (selectedDate == null) return null;

    // selectedDate is "YYYY-MM-DD"
    final parts = selectedDate!.split('-');
    if (parts.length != 3) return null;

    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;

    return DateTime(y, m, d);
  }

  bool get isSelectedDateToday {
    final selected = getSelectedDateAsDateTime();
    if (selected == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return selected.isAtSameMomentAs(today);
  }

  // 2PM rule and 8PM rule apply ONLY for today.
  bool isSlotEnabledForCurrentSelection(String slotValue) {
    if (!isSelectedDateToday) return true; // future dates: always enabled

    final now = DateTime.now();
    final cutoff2pm = todayAt(14, 0);
    final cutoff8pm = todayAt(20, 0);

    if (slotValue == slot10to2Value) {
      return now.isBefore(cutoff2pm); // after 2 PM disable 10–2
    }
    if (slotValue == slot5to8Value) {
      return now.isBefore(cutoff8pm); // after 8 PM disable 5–8
    }
    return true;
  }

  bool applyTimeRulesInternal() {
    bool changed = false;

    final now = DateTime.now();
    final cutoff8pm = todayAt(20, 0);

    // After 8 PM remove ONLY "today"
    if (now.isAfter(cutoff8pm) || now.isAtSameMomentAs(cutoff8pm)) {
      final today = DateTime(now.year, now.month, now.day);
      final mm = today.month.toString().padLeft(2, '0');
      final dd = today.day.toString().padLeft(2, '0');
      final todayFull = "${today.year}-$mm-$dd";

      if (dateOptions.isNotEmpty && dateOptions.first['full'] == todayFull) {
        dateOptions.removeAt(0);
        changed = true;
      }
    }

    // If current selectedDate is not in list anymore, auto-pick first available
    final exists = selectedDate != null &&
        dateOptions.any((d) => d['full'] == selectedDate);

    if (!exists) {
      selectedDate = dateOptions.isNotEmpty ? dateOptions.first['full'] : null;
      selectedTimeSlot = null;
      changed = true;
    }

    // If chosen slot becomes invalid (only possible for today), clear it.
    if (selectedTimeSlot != null &&
        !isSlotEnabledForCurrentSelection(selectedTimeSlot!)) {
      selectedTimeSlot = null;
      changed = true;
    }

    return changed;
  }

  void maybeReapplyRules() {
    final changed = applyTimeRulesInternal();
    if (changed && mounted) setState(() {});
  }

  void generateDateOptions() {
    dateOptions.clear();
    final now = DateTime.now();
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

    for (int i = 0; i <= 7; i++) {
      final date = now.add(Duration(days: i));

      final mm = date.month.toString().padLeft(2, '0');
      final dd = date.day.toString().padLeft(2, '0');
      final full = "${date.year}-$mm-$dd";

      dateOptions.add({
        "day": days[(date.weekday - 1) % 7],
        "date": date.day.toString(),
        "full": full,
      });
    }

    selectedDate = dateOptions.isNotEmpty ? dateOptions.first['full'] : null;
    selectedTimeSlot = null;

    applyTimeRulesInternal();
  }

  Future<void> loadUserAddress() async {
    try {
      final user = await api.getCurrentUser(widget.token);
      if (!mounted) return;

      setState(() {
        userAddress =
            user['address'] ?? widget.userAddress ?? "No address provided";
        userPincode = user['pincode'] ?? "641001";
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        userAddress = widget.userAddress ?? "No address provided";
      });
    }
  }

  void showAddressDialog() {
    addressController.text =
        (userAddress == null || userAddress == "No address provided")
            ? ""
            : userAddress!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Edit Address",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          content: SingleChildScrollView(
            child: TextField(
              controller: addressController,
              maxLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Enter your complete address",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      const BorderSide(color: Color(0xFF2196F3), width: 2),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
            ),
            Material(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () async {
                  final newAddress = addressController.text.trim();
                  final currentContext = context;

                  try {
                    await api.updateUser(
                      token: widget.token,
                      address: newAddress,
                    );
                    if (!mounted) return;

                    setState(() {
                      userAddress = newAddress;
                    });

                    Navigator.of(currentContext).pop();
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      const SnackBar(
                          content: Text("Address updated successfully")),
                    );
                  } catch (e) {
                    if (!mounted) return;

                    Navigator.of(currentContext).pop();
                    ScaffoldMessenger.of(currentContext).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Text(
                    "Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // CAMERA FIX: copy camera file from cache to documents dir stable path.
  Future<void> pickPhoto(ImageSource source) async {
    try {
      final XFile? photo = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1600,
      );
      if (photo == null) return;

      File file = File(photo.path);

      if (source == ImageSource.camera) {
        final dir = await getApplicationDocumentsDirectory();
        final ext =
            p.extension(photo.path).isNotEmpty ? p.extension(photo.path) : ".jpg";
        final newPath = p.join(
          dir.path,
          "pickup_${DateTime.now().millisecondsSinceEpoch}$ext",
        );
        file = await file.copy(newPath);
      }

      if (!mounted) return;
      setState(() {
        pickupPhoto = photo;
        pickupPhotoFile = file;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to pick image: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void removePhoto() {
    setState(() {
      pickupPhoto = null;
      pickupPhotoFile = null;
    });
  }

  void showPhotoSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Upload Photo",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_camera,
                      color: Color(0xFF2196F3)),
                  title: const Text("Camera"),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await pickPhoto(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library,
                      color: Color(0xFF2196F3)),
                  title: const Text("Gallery"),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await pickPhoto(ImageSource.gallery);
                  },
                ),
                if (pickupPhotoFile != null)
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text("Remove photo"),
                    onTap: () {
                      Navigator.pop(ctx);
                      removePhoto();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 110),
              child: Column(
                children: [
                  buildAppBar(),
                  buildInfoBanner(),
                  buildManpowerSection(),
                  buildDateSelection(),
                  buildTimeSelection(),
                  buildEstimatedWeight(),
                  buildAddressSection(),
                  buildCategoriesSection(),
                  buildPhotoSection(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: buildBottomButton(),
          ),
        ],
      ),
    );
  }

  Widget buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PickupsPage(
                    token: widget.token,
                    userAddress: userAddress,
                    username: widget.username,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.arrow_back,
                  color: Color(0xFF111827), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            "Schedule Pickup",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2196F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.shield, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sell your scrap hassle free",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "We do not charge any money in our app",
                  style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildManpowerSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.group,
                      color: Color(0xFF2196F3), size: 18),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "Size of Scrap",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "How many people are required to carry your scrap?",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildManpowerOption(
                  manpowerLessThanFourLabel,
                  Icons.person,
                  manpowerLessThanFourValue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildManpowerOption(
                  manpowerMoreThanFourLabel,
                  Icons.groups,
                  manpowerMoreThanFourValue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildManpowerOption(String label, IconData icon, String value) {
    final isSelected = selectedManpower == value;
    return GestureDetector(
      onTap: () => setState(() => selectedManpower = value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF2196F3)
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF2196F3)
                  : const Color(0xFF9CA3AF),
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF2196F3)
                    : const Color(0xFF111827),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateSelection() {
    String getFormattedDate() {
      final selected = getSelectedDateAsDateTime();
      if (selected == null) return "";

      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec"
      ];
      const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];

      return "${days[(selected.weekday - 1) % 7]}, ${selected.day} ${months[selected.month - 1]} ${selected.year}";
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Date",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: dateOptions.map((dateOption) {
                final isSelected = selectedDate == dateOption['full'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = dateOption['full'];
                      selectedTimeSlot = null;
                    });
                    maybeReapplyRules();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2196F3)
                          : Colors.white,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dateOption['day'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateOption['date'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF111827),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    color: Color(0xFF2196F3), size: 18),
                const SizedBox(width: 10),
                Text(
                  getFormattedDate(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeSelection() {
    final slot10Enabled = isSlotEnabledForCurrentSelection(slot10to2Value);
    final slot5Enabled = isSlotEnabledForCurrentSelection(slot5to8Value);

    debugPrint(
      "TimeSection: selectedDate=$selectedDate isToday=$isSelectedDateToday slot10=$slot10Enabled slot5=$slot5Enabled",
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Time",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: buildTimeSlotButton(
                  label: slot10to2Label,
                  value: slot10to2Value,
                  enabled: slot10Enabled,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: buildTimeSlotButton(
                  label: slot5to8Label,
                  value: slot5to8Value,
                  enabled: slot5Enabled,
                ),
              ),
            ],
          ),
          if (isSelectedDateToday && (!slot10Enabled || !slot5Enabled)) ...[
            const SizedBox(height: 10),
            Text(
              "Some slots are unavailable for today based on current time.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget buildTimeSlotButton({
    required String label,
    required String value,
    required bool enabled,
  }) {
    final isSelected = selectedTimeSlot == value;

    final bgColor = !enabled
        ? const Color(0xFFF3F4F6)
        : isSelected
            ? const Color(0xFF2196F3)
            : Colors.white;

    final borderColor = !enabled
        ? const Color(0xFFE5E7EB)
        : isSelected
            ? const Color(0xFF2196F3)
            : const Color(0xFFE5E7EB);

    final textColor = !enabled
        ? const Color(0xFF9CA3AF)
        : isSelected
            ? Colors.white
            : const Color(0xFF111827);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled
            ? () {
                debugPrint(
                  "Tapped slot=$value enabled=$enabled selectedDate=$selectedDate isToday=$isSelectedDateToday",
                );
                setState(() {
                  selectedTimeSlot = value;
                });
              }
            : () {
                debugPrint(
                  "Tapped DISABLED slot=$value selectedDate=$selectedDate isToday=$isSelectedDateToday",
                );
              },
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEstimatedWeight() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Estimated Weight",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weightOptions.map((weight) {
              final isSelected = selectedWeight == weight;
              return GestureDetector(
                onTap: () => setState(() => selectedWeight = weight),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2196F3) : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2196F3)
                          : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    weight,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF111827),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildAddressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Address",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              GestureDetector(
                onTap: showAddressDialog,
                child: const Text(
                  "Change",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2196F3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              userAddress ?? "No address provided",
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF111827),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: showAddressDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2196F3),
                side: const BorderSide(color: Color(0xFF2196F3), width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                "Add Address Details",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoriesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Categories",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "What type of scrap do you have?",
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: categories.map((category) {
              final isSelected = selectedCategories.contains(category);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedCategories.remove(category);
                    } else {
                      selectedCategories.add(category);
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2196F3)
                          : const Color(0xFFE5E7EB),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        getCategoryIcon(category),
                        color: isSelected
                            ? const Color(0xFF2196F3)
                            : const Color(0xFF9CA3AF),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? const Color(0xFF2196F3)
                              : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildPhotoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upload Photo",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Add a photo of the scrap (optional but recommended).",
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: showPhotoSourceSheet,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_a_photo,
                        color: Color(0xFF2196F3)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      pickupPhotoFile != null
                          ? "Photo selected"
                          : "Tap to upload photo",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                ],
              ),
            ),
          ),
          if (pickupPhotoFile != null) ...[
            const SizedBox(height: 12),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    pickupPhotoFile!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: InkWell(
                    onTap: removePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case "Paper":
        return Icons.description;
      case "Metals":
        return Icons.construction;
      case "Big Appliances":
        return Icons.kitchen;
      case "E-Waste":
        return Icons.devices;
      case "Cartons & Plastics":
        return Icons.shopping_bag;
      case "Others":
        return Icons.more_horiz;
      default:
        return Icons.category;
    }
  }

  bool get isFormComplete =>
      selectedManpower != null &&
      selectedDate != null &&
      selectedTimeSlot != null &&
      selectedWeight != null &&
      selectedCategories.isNotEmpty;

  String getFormattedDateForAPI() {
    return selectedDate ?? "";
  }

  // ✅ UPDATED: Photo optional but always multipart
  Future<void> completePickup() async {
    if (!isFormComplete) return;

    setState(() => isSubmitting = true);

    try {
      final formattedDate = getFormattedDateForAPI();

      final typedAddress = addressController.text.trim();
      final finalAddress =
          typedAddress.isNotEmpty ? typedAddress : (userAddress ?? '').trim();

      if (finalAddress.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please add your address")),
        );
        return;
      }

      // ✅ ALWAYS multipart (photo optional)
      await api.createPickupWithPhoto(
        token: widget.token,
        manpower: selectedManpower!,
        date: formattedDate,
        timeSlot: selectedTimeSlot!,
        weight: selectedWeight!,
        address: finalAddress,
        categories: selectedCategories,
        photoFile: pickupPhotoFile, // ✅ nullable
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pickup scheduled successfully!"),
          backgroundColor: Color(0xFF4CAF50),
          duration: Duration(seconds: 2),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PickupsPage(
            token: widget.token,
            userAddress: userAddress,
            username: widget.username,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Widget buildBottomButton() {
    final isDisabled = !isFormComplete || isSubmitting;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isDisabled ? null : completePickup,
            style: ElevatedButton.styleFrom(
              backgroundColor: isDisabled
                  ? const Color(0xFFC7C7C7)
                  : const Color(0xFF1F2937),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFC7C7C7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isSubmitting ? "SUBMITTING..." : "COMPLETE PICKUP",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
