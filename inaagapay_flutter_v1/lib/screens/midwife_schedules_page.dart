import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class MidwifeSchedulesPage extends StatefulWidget {
  const MidwifeSchedulesPage({super.key});

  @override
  State<MidwifeSchedulesPage> createState() => _MidwifeSchedulesPageState();
}

class _MidwifeSchedulesPageState extends State<MidwifeSchedulesPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  late Future<List<dynamic>> _schedulesFuture;

  @override
  void initState() {
    super.initState();
    _schedulesFuture = fetchSchedulesForDate(_selectedDay);
  }

  Future<List<dynamic>> fetchSchedulesForDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);

    final response = await http.get(
      Uri.parse(
        'https://inaagapay.alwaysdata.net/api/midwife/midwife_schedules_by_date.php'
        '?date=$formattedDate',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load schedules');
    }

    final decoded = jsonDecode(response.body);
    return decoded['data'] as List<dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: const [
          Icon(Icons.notifications_none),
          SizedBox(width: 12),
          CircleAvatar(child: Icon(Icons.person)),
          SizedBox(width: 12),
        ],
      ),

      body: Column(
        children: [
          // 📅 CALENDAR
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                isSameDay(_selectedDay, day),

            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _schedulesFuture =
                    fetchSchedulesForDate(selectedDay);
              });
            },

            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.pink.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),

            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          const SizedBox(height: 12),

          // 📋 SELECTED DATE TITLE
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateFormat('EEEE, MMMM d').format(_selectedDay),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 📋 SCHEDULE LIST
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _schedulesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                }

                final schedules = snapshot.data!;

                if (schedules.isEmpty) {
                  return const Center(
                    child: Text('No schedules for this date'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final s = schedules[index];

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(s['mother_name']),
                        subtitle: const Text('Mother Checkup'),
                        trailing: Text(
                          s['status'],
                          style: const TextStyle(
                            color: Colors.pink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
