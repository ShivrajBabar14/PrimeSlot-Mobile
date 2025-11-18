# TODO: Fix Appointment List to Re-fetch on Date Change

- [ ] Add `didUpdateWidget` method in `_AppointmentListState` to detect `selectedDate` changes
- [ ] In `didUpdateWidget`, check if `oldWidget.selectedDate != widget.selectedDate` and call `_fetchMeetings()` if changed
