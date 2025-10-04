import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../Notifiers/habits_state.dart';
import '../models/habit.dart';

class NewHabitPage extends ConsumerStatefulWidget {
  final Habit? habitToEdit; // Add this parameter for editing

  const NewHabitPage({super.key, this.habitToEdit});

  @override
  ConsumerState<NewHabitPage> createState() => _NewHabitPageState();
}

class _NewHabitPageState extends ConsumerState<NewHabitPage> {
  final TextEditingController _habitController = TextEditingController();
  final TextEditingController _subnoteController = TextEditingController();
  String _frequency = "Daily";
  Set<int> _selectedDays = {1, 2, 3, 4, 5, 6, 7}; // Default to all days
  int _selectedIndex = 1;
  int _selectedIcon = -1;
  TimeOfDay _reminderTime = TimeOfDay(hour: 9, minute: 0);
  bool _reminderEnabled = false;
  final _uuid = Uuid();

  final List<String> habitIcons = [
    '💪', // fitness_center
    '📚', // book
    '🧘', // spa/meditation
    '💧', // water_drop
    '😴', // bedtime/sleep
  ];

  final List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    // If editing, populate fields with existing data
    if (widget.habitToEdit != null) {
      _populateFieldsForEditing();
    }
  }

  void _populateFieldsForEditing() {
    final habit = widget.habitToEdit!;
    _habitController.text = habit.name;
    _subnoteController.text = habit.subtype ?? '';
    // Set frequency and selected days
    if (habit.frequency.type == 'daily') {
      _frequency = 'Daily';
      _selectedDays = Set.from(habit.frequency.days);
    } else if (habit.frequency.type == 'weekly') {
      _frequency = 'Weekly';
      _selectedDays = Set.from(habit.frequency.days);
    } else if (habit.frequency.type == 'monthly') {
      _frequency = 'Monthly';
      _selectedDays = Set.from(habit.frequency.days);
    } else if (habit.frequency.type == 'custom') {
      _frequency = 'Custom';
      _selectedDays = Set.from(habit.frequency.days);
    }

    // Set selected icon
    _selectedIcon = habitIcons.indexOf(habit.icon);
    if (_selectedIcon == -1) _selectedIcon = 0; //

    // Set reminder
    if (habit.reminderTime != null) {
      final timeParts = habit.reminderTime!.split(':');
      _reminderTime = TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      );
      _reminderEnabled = true;
    }
  }

  bool get isEditing => widget.habitToEdit != null;

  void _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF1380EC),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked;
        _reminderEnabled = true;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _updateFrequency(String newFrequency) {
    setState(() {
      _frequency = newFrequency;
      // Set default selected days based on frequency
      switch (newFrequency) {
        case "Daily":
          _selectedDays = {1, 2, 3, 4, 5, 6, 7};
          break;
        case "Weekly":
          _selectedDays = {1}; // Default to Monday
          break;
        case "Monthly":
          _selectedDays = {1}; // Default to 1st of month
          break;
        case "Custom":
          _selectedDays = {}; // Let user select
          break;
      }
    });
  }

  HabitFrequency _getFrequencyObject() {
    switch (_frequency) {
      case "Daily":
        return HabitFrequency(
          type: 'daily',
          days: _selectedDays.toList(),
        );
      case "Weekly":
        return HabitFrequency(
          type: 'weekly',
          days: _selectedDays.toList(),
        );
      case "Monthly":
        return HabitFrequency(
          type: 'monthly',
          days: _selectedDays.toList(),
        );
      case "Custom":
        return HabitFrequency(
          type: 'custom',
          days: _selectedDays.toList(),
        );
      default:
        return HabitFrequency(
          type: 'daily',
          days: [1, 2, 3, 4, 5, 6, 7],
        );
    }
  }

  Widget _buildDaySelector() {
    if (_frequency == "Monthly") {
      return Container(); // You can implement month day selector here if needed
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Text("Select Days",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8,
            children: List.generate(7, (index) {
              final dayNumber = index + 1;
              final isSelected = _selectedDays.contains(dayNumber);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_frequency == "Custom") {
                      if (isSelected) {
                        _selectedDays.remove(dayNumber);
                      } else {
                        _selectedDays.add(dayNumber);
                      }
                    } else if (_frequency == "Weekly") {
                      _selectedDays = {dayNumber};
                    } else if (_frequency == "Daily") {
                      if (isSelected) {
                        _selectedDays.remove(dayNumber);
                      } else {
                        _selectedDays.add(dayNumber);
                      }
                    }
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? const Color(0xFF1380EC) : Colors.grey.shade200,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF1380EC) : Colors.grey.shade300,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      dayNames[index],
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _saveHabit() {
    // Validation
    if (_habitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a habit name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedIcon == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an icon'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one day'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Format reminder time as "HH:mm"
    String? reminderTimeString;
    if (_reminderEnabled) {
      reminderTimeString = '${_reminderTime.hour.toString().padLeft(2, '0')}:${_reminderTime.minute.toString().padLeft(2, '0')}';
    }

    // Create habit object
    final habit = Habit(
      id: isEditing ? widget.habitToEdit!.id : _uuid.v4(), // Use existing ID if editing
      name: _habitController.text.trim(),
      icon: habitIcons[_selectedIcon],
      frequency: _getFrequencyObject(),
      reminderTime: reminderTimeString,
      subtype: _subnoteController.text.trim(),
      createdAt: isEditing ? widget.habitToEdit!.createdAt : DateTime.now(), // Keep original creation date
    );

    // Add or update habit using Riverpod
    if (isEditing) {
      ref.read(habitsProvider.notifier).updateHabit(habit);
    } else {
      ref.read(habitsProvider.notifier).addHabit(habit);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Habit "${habit.name}" ${isEditing ? 'updated' : 'added'} successfully!'),
        backgroundColor: const Color(0xFF1380EC),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Navigate back
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEditing ? "Edit Habit" : "New Habit",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Habit Name
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _habitController,
                decoration: InputDecoration(
                  hintText: "Habit name",
                  filled: true,
                  fillColor: const Color(0xFFF0F2F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),

            // Subnote
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: TextField(
                controller: _subnoteController,
                decoration: InputDecoration(
                  hintText: "Add details (e.g., 8 hours per day)",
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
            ),

            // Frequency
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Frequency",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: ["Daily", "Weekly", "Monthly", "Custom"].map((f) {
                  final isSelected = _frequency == f;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _updateFrequency(f),
                      child: Container(
                        height: 44,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF1380EC) : const Color(0xFFDBE0E6),
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: Text(f,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontSize: 13,
                            )),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Day Selector (only show for Daily, Weekly, and Custom)
            if (_frequency != "Monthly") _buildDaySelector(),

            // Reminder Time Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text("Reminder",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2F4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.notifications_outlined,
                    color: _reminderEnabled ? const Color(0xFF1380EC) : Colors.grey,
                  ),
                  title: Text(
                    _reminderEnabled
                        ? "Remind me at ${_formatTime(_reminderTime)}"
                        : "Set reminder time",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _reminderEnabled ? Colors.black : Colors.grey[600],
                    ),
                  ),
                  trailing: Switch(
                    value: _reminderEnabled,
                    onChanged: (value) {
                      if (value) {
                        _showTimePicker();
                      } else {
                        setState(() {
                          _reminderEnabled = false;
                        });
                      }
                    },
                    activeColor: const Color(0xFF1380EC),
                  ),
                  onTap: _reminderEnabled ? _showTimePicker : null,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Icons
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text("Icon",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                itemCount: habitIcons.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final isSelected = _selectedIcon == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = index),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: const Color(0xFF1380EC), width: 3)
                            : Border.all(color: Colors.grey.shade300, width: 1),
                        color: isSelected ? const Color(0xFF1380EC).withOpacity(0.1) : Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          habitIcons[index],
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Save Button (changes text based on mode)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1380EC),
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _saveHabit,
                child: Text(
                    isEditing ? "Update Changes" : "Add Habit",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: "Today"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Habits"),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: "Progress"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Color(0xFF617589),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
