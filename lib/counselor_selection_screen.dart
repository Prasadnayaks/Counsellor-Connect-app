import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import 'appointment_provider.dart';
import 'package:intl/intl.dart';

class CounselorSelectionScreen extends StatefulWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final String appointmentTitle;
  final String? notes;

  const CounselorSelectionScreen({
    Key? key,
    required this.selectedDate,
    required this.selectedTime,
    required this.appointmentTitle,
    this.notes,
  }) : super(key: key);

  @override
  State<CounselorSelectionScreen> createState() => _CounselorSelectionScreenState();
}

class _CounselorSelectionScreenState extends State<CounselorSelectionScreen> {
  bool _isLoading = true;
  List<UserModel> _counselors = [];
  List<Map<String, dynamic>> _onlineCounselors = [];

  @override
  void initState() {
    super.initState();
    _loadCounselors();
  }

  Future<void> _loadCounselors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);

      // Load all counselors
      final counselors = await firebaseService.getAllCounselors();

      // Load online counselors
      final onlineCounselors = await firebaseService.getOnlineCounselors();

      setState(() {
        _counselors = counselors;
        _onlineCounselors = onlineCounselors;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading counselors: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isCounselorOnline(String counselorId) {
    return _onlineCounselors.any((counselor) => counselor['userId'] == counselorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Counselor'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _counselors.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No counselors available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _counselors.length,
        itemBuilder: (context, index) {
          final counselor = _counselors[index];
          final isOnline = _isCounselorOnline(counselor.id!);

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=${index + 20}',
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              title: Text(
                counselor.name ?? 'Unknown Counselor',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isOnline ? Icons.circle : Icons.access_time,
                        size: 14,
                        color: isOnline ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isOnline ? 'Online now' : 'Offline',
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Specializations: Anxiety, Depression, Stress Management',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _bookAppointment(counselor);
                },
                child: const Text('Select'),
              ),
            ),
          );
        },
      ),
    );
  }

  void _bookAppointment(UserModel counselor) {
    final dateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      widget.selectedTime.hour,
      widget.selectedTime.minute,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Counselor: ${counselor.name}'),
            const SizedBox(height: 8),
            Text('Date: ${DateFormat('EEEE, MMMM d, yyyy').format(widget.selectedDate)}'),
            const SizedBox(height: 4),
            Text('Time: ${widget.selectedTime.format(context)}'),
            const SizedBox(height: 8),
            Text('Title: ${widget.appointmentTitle}'),
            if (widget.notes != null && widget.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Notes: ${widget.notes}'),
            ],
          ],
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
              Provider.of<AppointmentProvider>(context, listen: false).addAppointment(
                title: widget.appointmentTitle,
                dateTime: dateTime,
                counselorId: counselor.id!,
                counselorName: counselor.name ?? 'Unknown Counselor',
                notes: widget.notes,
              );

              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment booked successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Book'),
          ),
        ],
      ),
    );
  }
}

