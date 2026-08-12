# Task Studio 🚀

A modern, full-featured Task & Productivity Management Flutter application built with Material 3, clean reactive architecture, and rich animations.

---

## ✨ Features

- 📋 **Task Management & Organization**
  - Create, edit, duplicate, delete, and pin tasks to the top.
  - Interactive checklists with subtasks and live progress tracking.
  - Multi-category support (Work, Personal, Development, Design, Study, Health & Fitness, Finance).
  - Priority levels (Urgent, High, Medium, Low) with distinct visual tags and icons.
  - Due dates, time pickers, and overdue warnings.
  - Tags (`#UI/UX`, `#Accessibility`, etc.) and time estimates.

- 🗓️ **Calendar & Agenda View**
  - Interactive horizontal day strip with task indicators.
  - Date-specific agenda view to keep track of daily deadlines.
  - Quick-schedule tasks directly for selected dates.

- 📊 **Productivity Analytics & Dashboard**
  - Overall completion rate metric.
  - 7-day completion velocity bar chart.
  - Category progress distribution bars.
  - Pending tasks breakdown by priority level.
  - Active productivity streak tracking.

- 🎨 **Appearance & Customization**
  - Dark, Light, and System theme support.
  - Curated color accent themes (Indigo Pulse, Emerald Mint, Royal Violet, Rose Sunset, Amber Glow, Ocean Cyan).
  - Responsive navigation: Bottom Navigation Bar on mobile, Adaptive Navigation Rail on tablets and desktop/web.

- 🔍 **Search, Filter & Sorting**
  - Real-time search by title, description, and tags.
  - Segmented filters for All, Today, Upcoming, and Completed tasks.
  - Advanced filtering sheet for categories, priorities, and custom sort order (Due Date, Priority, Created Date, Alphabetical).

- ⚡ **Gestures & Micro-interactions**
  - Swipe right on task cards to toggle completion.
  - Swipe left on task cards to delete.
  - Bouncy animated circular checkboxes with accessibility semantics.

---

## 🏗️ Project Structure

```
examples/task_manager/
├── lib/
│   ├── controllers/
│   │   ├── task_controller.dart     # State management, CRUD, filtering & analytics
│   │   └── theme_controller.dart    # Theme mode & palette seed controller
│   ├── models/
│   │   ├── priority.dart            # TaskPriority enum & styling
│   │   ├── subtask.dart             # SubTask model
│   │   ├── task.dart                # Core Task model
│   │   ├── task_category.dart       # TaskCategory definitions & gradients
│   │   └── task_filter.dart         # Filter & Sort models
│   ├── theme/
│   │   └── app_theme.dart           # Light & Dark Material 3 theme configurations
│   ├── views/
│   │   ├── analytics_view.dart      # Productivity metrics & velocity chart
│   │   ├── calendar_view.dart       # Horizontal date strip & schedule view
│   │   ├── categories_view.dart     # Category hub & project cards
│   │   └── tasks_view.dart          # Main task list, search, and category pills
│   ├── widgets/
│   │   ├── add_edit_task_sheet.dart # Add / Edit task modal bottom sheet
│   │   ├── category_chip.dart       # Category selection chip
│   │   ├── custom_checkbox.dart     # Animated checkbox with semantics
│   │   ├── filter_drawer.dart       # Advanced filter & sort bottom sheet
│   │   ├── priority_badge.dart      # Priority indicator tag
│   │   ├── settings_sheet.dart      # Theme & data management modal
│   │   ├── stats_card.dart          # Quick stats overview banner
│   │   ├── task_card.dart           # Swipeable interactive task card
│   │   └── task_details_sheet.dart  # Task inspection & subtask checklist sheet
│   └── main.dart                    # Application entry point & responsive shell
└── test/
    ├── task_controller_test.dart    # Unit tests for controller logic
    └── widget_test.dart             # Widget tests for app navigation
```

---

## 🚀 Getting Started

### Run the App
```bash
cd examples/task_manager
flutter run
```

### Run Tests
```bash
flutter test
```

### Run Linter
```bash
dart analyze --fatal-infos
```
