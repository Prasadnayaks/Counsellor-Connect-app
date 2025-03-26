import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../appointment.dart';
import '../appointment_provider.dart';

class CounselorAppointmentsScreen extends StatefulWidget {
  const CounselorAppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<CounselorAppointmentsScreen> createState() => _CounselorAppointmentsScreenState();
}

class _CounselorAppointmentsScreenState extends State<CounselorAppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Appointment> _getAppointmentsForDay(DateTime day, List<Appointment> appointments) {
    return appointments.where((appointment) {
      final appointmentDate = DateTime(
        appointment.dateTime.year,
        appointment.dateTime.month,
        appointment.dateTime.day,
      );
      final selectedDate = DateTime(day.year, day.month, day.day);
      return appointmentDate.isAtSameMomentAs(selectedDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, appointmentProvider, child) {
          if (appointmentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final upcomingAppointments = appointmentProvider.getUpcomingAppointments();
          final pastAppointments = appointmentProvider.getPastAppointments();

          return TabBarView(
            controller: _tabController,
            children: [
              // Upcoming appointments tab
              _buildAppointmentsTab(upcomingAppointments),

              // Past appointments tab
              _buildAppointmentsTab(pastAppointments),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsTab(List<Appointment> appointments) {
    final appointmentsForSelectedDay = _getAppointmentsForDay(_selectedDay, appointments);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2023, 1, 1),
          lastDay: DateTime.utc(2025, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          eventLoader: (day) {
            return _getAppointmentsForDay(day, appointments);
          },
          calendarStyle: const CalendarStyle(
            markersMaxCount: 3,
            markerDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMMM d, yyyy').format(_selectedDay),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${appointmentsForSelectedDay.length} appointments',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: appointmentsForSelectedDay.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No appointments for this day',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointmentsForSelectedDay.length,
            itemBuilder: (context, index) {
              final appointment = appointmentsForSelectedDay[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: appointment.isCompleted
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                    child: Icon(
                      appointment.isCompleted
                          ? Icons.check
                          : Icons.event,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    appointment.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Client: ${appointment.userId}'),
                      const SizedBox(height: 4),
                      Text(
                        'Time: ${DateFormat('h:mm a').format(appointment.dateTime)}',
                      ),
                      if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text('Notes: ${appointment.notes}'),
                      ],
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!appointment.isCompleted) ...[
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline),
                          onPressed: () {
                            _showCompleteAppointmentDialog(context, appointment);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showCompleteAppointmentDialog(BuildContext context, Appointment appointment) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Appointment'),
        content: const Text('Mark this appointment as completed?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<AppointmentProvider>(context, listen: false)
                  .markAppointmentAsCompleted(appointment.id);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment marked as completed'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}

