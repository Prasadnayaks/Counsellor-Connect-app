import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'appointment.dart';
import 'appointment_provider.dart';
import '../providers/counselor_provider.dart';
import '../models/user_model.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCounselorId;
  String? _selectedCounselorName;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load counselors
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CounselorProvider>(context, listen: false).refreshCounselors();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _notesController.dispose();
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
        title: const Text('Appointments'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAppointmentDialog(context);
        },
        child: const Icon(Icons.add),
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
                      Text('With: ${appointment.counselorName}'),
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
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditAppointmentDialog(context, appointment);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, appointment);
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

  Future<void> _showAddAppointmentDialog(BuildContext context) async {
    _titleController.clear();
    _notesController.clear();
    _selectedCounselorId = null;
    _selectedCounselorName = null;
    _selectedTime = TimeOfDay.now();

    final counselorProvider = Provider.of<CounselorProvider>(context, listen: false);
    await counselorProvider.refreshCounselors();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Schedule Appointment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Date: ${DateFormat('MMMM d, yyyy').format(_selectedDay)}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedTime = pickedTime;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _selectedTime.format(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Select Counselor:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Consumer<CounselorProvider>(
                    builder: (context, counselorProvider, child) {
                      final counselors = counselorProvider.onlineCounselors;

                      if (counselors.isEmpty) {
                        return const Text(
                          'No counselors available at the moment',
                          style: TextStyle(
                            color: Colors.red,
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      }

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCounselorId,
                            hint: const Text('  Select a counselor'),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: counselors.map((counselor) {
                              return DropdownMenuItem<String>(
                                value: counselor['userId'] as String,
                                child: Text(counselor['name'] as String),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCounselorId = value;
                                _selectedCounselorName = counselors
                                    .firstWhere((c) => c['userId'] == value)['name'] as String;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a title'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  if (_selectedCounselorId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a counselor'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create appointment date time
                  final now = DateTime.now();
                  final appointmentDateTime = DateTime(
                    _selectedDay.year,
                    _selectedDay.month,
                    _selectedDay.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  // Check if appointment is in the past
                  if (appointmentDateTime.isBefore(now)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot schedule appointments in the past'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Add appointment
                  Provider.of<AppointmentProvider>(context, listen: false).addAppointment(

                    title: _titleController.text,
                    dateTime: appointmentDateTime,
                    counselorId: _selectedCounselorId!, // Non-null assertion is safe here due to validation above
                    counselorName: _selectedCounselorName!, // Non-null assertion is safe here due to validation above
                    notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment scheduled successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Schedule'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showEditAppointmentDialog(BuildContext context, Appointment appointment) async {
    _titleController.text = appointment.title;
    _notesController.text = appointment.notes ?? '';
    _selectedCounselorId = appointment.counselorId;
    _selectedCounselorName = appointment.counselorName;
    _selectedDay = appointment.dateTime;
    _selectedTime = TimeOfDay(
      hour: appointment.dateTime.hour,
      minute: appointment.dateTime.minute,
    );

    final counselorProvider = Provider.of<CounselorProvider>(context, listen: false);
    await counselorProvider.refreshCounselors();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Appointment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDay,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2025, 12, 31),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDay = pickedDate;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('MMMM d, yyyy').format(_selectedDay),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (pickedTime != null) {
                        setState(() {
                          _selectedTime = pickedTime;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(
                        _selectedTime.format(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Counselor:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Consumer<CounselorProvider>(
                    builder: (context, counselorProvider, child) {
                      final counselors = counselorProvider.onlineCounselors;

                      // Add the current counselor if not in the list
                      bool containsCurrentCounselor = counselors.any(
                              (c) => c['userId'] == appointment.counselorId
                      );

                      if (!containsCurrentCounselor) {
                        counselors.add({
                          'userId': appointment.counselorId,
                          'name': appointment.counselorName,
                          'isOnline': false,
                        });
                      }

                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedCounselorId,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            items: counselors.map((counselor) {
                              return DropdownMenuItem<String>(
                                value: counselor['userId'] as String,
                                child: Text(counselor['name'] as String),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCounselorId = value;
                                _selectedCounselorName = counselors
                                    .firstWhere((c) => c['userId'] == value)['name'] as String;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a title'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Create appointment date time
                  final appointmentDateTime = DateTime(
                    _selectedDay.year,
                    _selectedDay.month,
                    _selectedDay.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  // Check if appointment is in the past
                  if (appointmentDateTime.isBefore(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cannot schedule appointments in the past'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Update appointment
                  Provider.of<AppointmentProvider>(context, listen: false).updateAppointment(
                    id: appointment.id,
                    title: _titleController.text,
                    dateTime: appointmentDateTime,
                    counselorId: _selectedCounselorId!,
                    counselorName: _selectedCounselorName!,
                    notes: _notesController.text.isNotEmpty ? _notesController.text : null,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Appointment updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Appointment appointment) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Appointment'),
        content: const Text('Are you sure you want to delete this appointment?'),
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
                  .deleteAppointment(appointment.id);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            }, child: null,
          ),
        ],
      ),
    );
  }
}

