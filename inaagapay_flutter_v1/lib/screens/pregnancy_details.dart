import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/secondary_header.dart';
import '../widgets/records_display_card.dart';
import '../services/api_service.dart';

class PregnancyDetailsPage extends StatefulWidget {
  const PregnancyDetailsPage({super.key});

  @override
  State<PregnancyDetailsPage> createState() => _PregnancyDetailsPageState();
}

class _PregnancyDetailsPageState extends State<PregnancyDetailsPage> {
  bool _isLoading = true;
  List<dynamic> _pregnancyHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchPregnancyHistory();
  }

  Future<void> _fetchPregnancyHistory() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check your ApiService structure - adjust based on actual implementation
      // If ApiService.get() is static, use: ApiService.get()
      // If it's an instance method, use: ApiService().get()
      // If you have a different method name, adjust accordingly
      
      // Try this first:
      // final response = await ApiService.get('pregnancy_history.php');
      
      // Or if get() is an instance method:
      // final apiService = ApiService();
      // final response = await apiService.get('pregnancy_history.php');
      
      // For now, let's try a generic approach:
      dynamic response;
      try {
        // Try static method first
        response = await ApiService.get('pregnancy_history.php');
      } catch (e) {
        // Try instance method
        final apiService = ApiService();
        response = await ApiService.get('pregnancy_history.php');
      }

      // Check response structure
      if (response != null && response['success'] == true) {
        setState(() {
          _pregnancyHistory = response['history'] is List ? response['history'] : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        // Handle error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to load pregnancy history'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Not recorded';
    
    try {
      final date = DateTime.parse(dateString);
      return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  String _getOutcomeText(String? outcome) {
    if (outcome == null) return 'Not recorded';
    
    final outcomes = {
      'live_birth': 'Live Birth',
      'stillbirth': 'Stillbirth',
      'miscarriage': 'Miscarriage',
      'abortion': 'Abortion',
      'ectopic': 'Ectopic Pregnancy'
    };
    
    return outcomes[outcome] ?? _titleCase(outcome.replaceAll('_', ' '));
  }

  String _getMethodFromOutcome(String? outcome) {
    if (outcome == null) return 'Not recorded';
    
    return outcome == 'live_birth' ? 'Normal Delivery' : 'N/A';
  }

  String _titleCase(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: SecondaryHeader(
          title: 'Pregnancy History',
          onBack: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchPregnancyHistory,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _pregnancyHistory.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 100),
                          Icon(
                            Icons.pregnant_woman_rounded,
                            size: 80,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No pregnancy history found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        for (int i = 0; i < _pregnancyHistory.length; i++)
                          Column(
                            children: [
                              PregnancyCard(
                                pregnancyNumber: i + 1,
                                pregnancyData: _pregnancyHistory[i],
                                formatDate: _formatDate,
                                getOutcomeText: _getOutcomeText,
                                getMethodFromOutcome: _getMethodFromOutcome,
                                titleCase: _titleCase,
                              ),
                              if (i < _pregnancyHistory.length - 1)
                                const SizedBox(height: 20),
                            ],
                          ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                            PREGNANCY DETAILS CARD                           */
/* -------------------------------------------------------------------------- */

class PregnancyCard extends StatelessWidget {
  final int pregnancyNumber;
  final Map<String, dynamic> pregnancyData;
  final String Function(String?) formatDate;
  final String Function(String?) getOutcomeText;
  final String Function(String?) getMethodFromOutcome;
  final String Function(String) titleCase;

  const PregnancyCard({
    required this.pregnancyNumber,
    required this.pregnancyData,
    required this.formatDate,
    required this.getOutcomeText,
    required this.getMethodFromOutcome,
    required this.titleCase,
  });

  @override
  Widget build(BuildContext context) {
    // Extract delivery information if available
    final deliveryPlace = pregnancyData['place_of_delivery'] ?? 'Not recorded';
    final deliveryMethod = pregnancyData['method_display'] ?? 
                          pregnancyData['delivery_method'] ?? 
                          getMethodFromOutcome(pregnancyData['outcome']);
    final deliveryDate = pregnancyData['delivery_date'] ?? 
                        pregnancyData['outcome_date'] ?? 
                        pregnancyData['expected_date_of_delivery'];

    return RecordsDisplayCard(
      title: 'Pregnancy #$pregnancyNumber Details',
      headerIcon: Icons.info_outline_rounded,
      items: [
        // 📅 LAST MENSTRUAL PERIOD
        if (pregnancyData['last_menstrual_period'] != null) ...[
          const RecordItem(
            leadingIcon: Icons.calendar_today_rounded,
            label: 'Last Menstrual Period',
            value: '',
          ),
          RecordItem(
            leadingIcon: Icons.event_rounded,
            label: 'Date',
            value: formatDate(pregnancyData['last_menstrual_period']),
          ),
        ],

        // 📅 EXPECTED DELIVERY DATE
        if (pregnancyData['expected_date_of_delivery'] != null) ...[
          const RecordItem(
            leadingIcon: Icons.event_note_rounded,
            label: 'Expected Delivery Date',
            value: '',
          ),
          RecordItem(
            leadingIcon: Icons.assignment_turned_in_rounded,
            label: 'Date',
            value: formatDate(pregnancyData['expected_date_of_delivery']),
          ),
        ],

        // 📍 DELIVERY PLACE
        if (deliveryPlace != 'Not recorded') ...[
          const RecordItem(
            leadingIcon: Icons.location_on_rounded,
            label: 'Delivery Place',
            value: '',
          ),
          RecordItem(
            leadingIcon: Icons.local_hospital_rounded,
            label: 'Institution',
            value: deliveryPlace,
          ),
        ],

        // 📅 DELIVERY DATE
        if (deliveryDate != null) ...[
          const RecordItem(
            leadingIcon: Icons.calendar_month_rounded,
            label: 'Delivery Date',
            value: '',
          ),
          RecordItem(
            leadingIcon: Icons.date_range_rounded,
            label: 'Date',
            value: formatDate(deliveryDate),
          ),
        ],

        // 🏥 METHOD OF DELIVERY
        const RecordItem(
          leadingIcon: Icons.medical_services_rounded,
          label: 'Method of Delivery',
          value: '',
        ),
        RecordItem(
          leadingIcon: Icons.delivery_dining_rounded,
          label: 'Method',
          value: deliveryMethod,
        ),

        // ✅ OUTCOME
        const RecordItem(
          leadingIcon: Icons.fact_check_rounded,
          label: 'Outcome',
          value: '',
        ),
        RecordItem(
          leadingIcon: Icons.child_care_rounded,
          label: 'Result',
          value: getOutcomeText(pregnancyData['outcome']),
        ),

        // 📏 GESTATIONAL AGE
        if (pregnancyData['gestational_age_at_end'] != null) ...[
          const RecordItem(
            leadingIcon: Icons.timeline_rounded,
            label: 'Gestational Age at End',
            value: '',
          ),
          RecordItem(
            leadingIcon: Icons.timeline_rounded,
            label: 'Weeks',
            value: '${pregnancyData['gestational_age_at_end']} weeks',
          ),
        ],

        // 📊 STATUS
        if (pregnancyData['status'] != null) ...[
          const RecordItem(
            leadingIcon: Icons.info_rounded,
            label: 'Status',
            value: '',
          ),
          RecordItem(
            leadingIcon: Icons.circle_rounded,
            label: 'Status',
            value: titleCase(pregnancyData['status']),
          ),
        ],
      ],
    );
  }
}