import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/admin_service.dart';

class CreateEventScreen extends StatefulWidget {
  final Map<String, dynamic>? eventData;

  const CreateEventScreen({
    Key? key,
    this.eventData,
  }) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  static const Color primaryBlue = Color(0xFF2563EB);
  static const Color darkNavy = Color(0xFF1a1a2e);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color greenSuccess = Color(0xFF22c55e);

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _venueController;
  late TextEditingController _priceController;
  late TextEditingController _totalSeatsController;
  late TextEditingController _imageUrlController;

  String _selectedCategory = 'Workshops';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedStatus = 'Upcoming';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Workshops',
    'Hackathons',
    'Cultural',
    'Sports',
    'Seminar',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final event = widget.eventData;

    _titleController = TextEditingController(text: event?['title'] ?? '');
    _descriptionController = TextEditingController(text: event?['description'] ?? '');
    _venueController = TextEditingController(text: event?['venue'] ?? '');
    _priceController = TextEditingController(text: event?['price']?.toString() ?? '');
    _totalSeatsController = TextEditingController(text: event?['total_seats']?.toString() ?? '');
    _imageUrlController = TextEditingController(text: event?['image_url'] ?? '');

    _selectedCategory = event?['category'] ?? 'Workshops';
    _selectedStatus = event?['status'] ?? 'Upcoming';

    if (event != null && event['date'] != null) {
      try {
        final dt = DateTime.parse(event['date']);
        _selectedDate = dt;
        _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _venueController.dispose();
    _priceController.dispose();
    _totalSeatsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkNavy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: darkNavy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Combine date and time
    final eventDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final isEdit = widget.eventData != null;
    final success = isEdit
        ? await AdminService.updateEvent(
            eventId: (widget.eventData?['id'] ?? '').toString(),
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            date: eventDateTime,
            venue: _venueController.text.trim(),
            price: num.tryParse(_priceController.text) ?? 0,
            totalSeats: int.tryParse(_totalSeatsController.text) ?? 0,
            imageUrl: _imageUrlController.text.trim(),
            status: _selectedStatus,
          )
        : await AdminService.createEvent(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            date: eventDateTime,
            venue: _venueController.text.trim(),
            price: num.tryParse(_priceController.text) ?? 0,
            totalSeats: int.tryParse(_totalSeatsController.text) ?? 0,
            imageUrl: _imageUrlController.text.trim(),
            status: _selectedStatus,
          );

    if (mounted) {
      setState(() => _isSubmitting = false);

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Event updated successfully!'
                  : 'Event created successfully!',
            ),
            backgroundColor: greenSuccess,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        final errorText =
            AdminService.lastErrorMessage ?? 'Unknown database error';
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(width: 10),
                Text(isEdit ? 'Could Not Update Event' : 'Could Not Create Event'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The event could not be saved in the events table.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  errorText,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.eventData != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
        ),
        title: Text(
          isEdit ? 'Edit Event' : 'Create Event',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                // TODO: Delete functionality
              },
              color: Colors.white,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    _buildLabel('Event Title *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: _inputDecoration('Enter event title', Icons.event),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Description field
                    _buildLabel('Description *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _inputDecoration('Describe the event', Icons.description).copyWith(
                        alignLabelWithHint: true,
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Category dropdown
                    _buildLabel('Category *'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFAFAFA),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCategory,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: primaryBlue),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(
                              value: cat,
                              child: Text(cat, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Date & Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Date *'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectDate,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFFFAFAFA),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: primaryBlue, size: 18),
                                      const SizedBox(width: 10),
                                      Text(
                                        DateFormat('MMM dd, yyyy').format(_selectedDate),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Time *'),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: _selectTime,
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color(0xFFFAFAFA),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, color: primaryBlue, size: 18),
                                      const SizedBox(width: 10),
                                      Text(
                                        _selectedTime.format(context),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Venue field
                    _buildLabel('Venue *'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _venueController,
                      decoration: _inputDecoration('Enter venue location', Icons.location_on),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Venue is required'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    // Price & Total Seats
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Price (Ã¢â€šÂ¹)'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _priceController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('0 for free', Icons.currency_rupee),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return null;
                                  if (num.tryParse(v) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel('Total Seats *'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _totalSeatsController,
                                keyboardType: TextInputType.number,
                                decoration: _inputDecoration('Enter capacity', Icons.event_seat),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Required';
                                  if (int.tryParse(v) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Image URL field
                    _buildLabel('Image URL'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _imageUrlController,
                      decoration: _inputDecoration('Paste image URL', Icons.image),
                      validator: (v) {
                        if (v == null || v.isEmpty) return null;
                        if (!v.startsWith('http')) return 'Must be a valid URL';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Status dropdown
                    _buildLabel('Event Status'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFFAFAFA),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: primaryBlue),
                          items: const [
                            DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                            DropdownMenuItem(value: 'Ongoing', child: Text('Ongoing')),
                            DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                          ],
                          onChanged: (v) => setState(() => _selectedStatus = v!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.eventData != null ? Icons.save : Icons.add_circle,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.eventData != null ? 'Save Changes' : 'Create Event',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Info card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primaryBlue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: primaryBlue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Supabase Connected',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create Event writes directly to the events table.',
                          style: TextStyle(
                            fontSize: 11,
                            color: gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: gray600,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: gray400, fontSize: 13),
      prefixIcon: Icon(icon, color: primaryBlue, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFFAFAFA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
