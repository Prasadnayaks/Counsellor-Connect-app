import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../appointment_provider.dart';
import '../appointment.dart';
import '../counselor_selection_screen.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Refresh appointments when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentProvider>(context, listen: false).refreshAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
              _buildAppointmentsList(upcomingAppointments, isUpcoming: true),

              // Past appointments tab
              _buildAppointmentsList(pastAppointments, isUpcoming: false),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBookAppointmentDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments, {required bool isUpcoming}) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUpcoming ? Icons.event_available : Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isUpcoming
                  ? 'No upcoming appointments'
                  : 'No past appointments',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            if (isUpcoming)
              Text(
                'Tap the + button to book an appointment',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
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
                Text('Counselor: ${appointment.counselorName}'),
                const SizedBox(height: 4),
                Text(
                  'Date: ${DateFormat('EEEE, MMMM d, yyyy').format(appointment.dateTime)}',
                ),
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
            trailing: isUpcoming && !appointment.isCompleted
                ? IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                _showCancelAppointmentDialog(context, appointment);
              },
            )
                : null,
          ),
        );
      },
    );
  }

  Future<void> _showCancelAppointmentDialog(BuildContext context, Appointment appointment) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Provider.of<AppointmentProvider>(context, listen: false)
                  .deleteAppointment(appointment.id);

              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment cancelled'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showBookAppointmentDialog(BuildContext context) async {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Book Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'Enter appointment title',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        selectedTime = time;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Enter any notes (optional)',
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
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a title'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Check if selected date and time is in the past
                final now = DateTime.now();
                final selectedDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                if (selectedDateTime.isBefore(now)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cannot book appointment in the past'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                Navigator.pop(context);

                // Navigate to counselor selection screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CounselorSelectionScreen(
                      selectedDate: selectedDate,
                      selectedTime: selectedTime,
                      appointmentTitle: titleController.text,
                      notes: notesController.text.isEmpty ? null : notesController.text,
                    ),
                  ),
                );
              },
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

