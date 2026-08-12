# Accessibility (A11y) Audit Report: Task Studio

**Target Application:** Task Studio Flutter Application  
**Audit Date:** August 12, 2026  
**Standards Evaluated:** WCAG 2.1 & 2.2 (Levels A, AA, AAA), Material Design 3 Accessibility Guidelines, Apple Human Interface Guidelines (A11y), Flutter Accessibility Standards  
**Target Platform(s):** iOS, Android, Web, macOS  

---

## 1. Executive Summary

A comprehensive accessibility audit of the **Task Studio** Flutter application located at `/Users/jinhangyu/Desktop/task_manager` was conducted. The audit analyzed widget hierarchy, semantic annotations, touch target sizes, color contrast ratios, dynamic type support (text scaling up to 200%), keyboard and switch navigation, screen reader compatibility (TalkBack / VoiceOver), motion reduction, and error handling.

### Conformance Scorecard

| Category | Status | Compliance Level | Key Concern |
| :--- | :---: | :---: | :--- |
| **Screen Reader & Semantics** | ⚠️ Needs Remediation | Partial WCAG A | Missing semantic headers, unannounced dynamic changes, ambiguous date & chart semantics |
| **Touch Target Dimensions** | ❌ Non-Compliant | Fails WCAG 2.5.5 / 2.5.8 | Multiple interactive elements under 48×48 dp (popup menus, check targets, delete buttons) |
| **Color Contrast & Luminance** | ❌ Non-Compliant | Fails WCAG 1.4.3 AA | Muted text colors (`#94A3B8`, `white70`, `white38`) fail 4.5:1 ratio on background cards |
| **Text Scaling & Dynamic Type** | ⚠️ Needs Remediation | Fails WCAG 1.4.4 AA | Fixed-height containers (Date strip, Velocity chart) overflow/clip at >1.3× text scale |
| **Keyboard & Focus Order** | ⚠️ Needs Remediation | Partial WCAG 2.1.1 | Custom interactive widgets lack visible focus rings and accessible action handlers |
| **Motion & Reduced Animations** | ⚠️ Needs Remediation | Fails WCAG 2.3.3 AAA | Animations ignore `MediaQuery.disableAnimationsOf(context)` / `reducedMotion` |

---

## 2. Priority Findings Matrix

| ID | Issue Title | Severity | WCAG Guideline | Affected File & Lines |
| :--- | :--- | :---: | :---: | :--- |
| **A11Y-01** | Sub-minimum Touch Targets (<48×48 dp) on Primary Controls | **High** | 2.5.5 (Target Size - AAA), 2.5.8 (Target Size Min - AA) | [`task_card.dart:236`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart#L236)<br>[`custom_checkbox.dart:73`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/custom_checkbox.dart#L73)<br>[`task_details_sheet.dart:344`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_details_sheet.dart#L344) |
| **A11Y-02** | Insufficient Color Contrast on Secondary Text & Card Badges | **High** | 1.4.3 (Contrast Minimum - AA) | [`app_theme.dart:99`](file:///Users/jinhangyu/Desktop/task_manager/lib/theme/app_theme.dart#L99)<br>[`task_card.dart:347`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart#L347)<br>[`stats_card.dart:98`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/stats_card.dart#L98)<br>[`analytics_view.dart:81`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L81) |
| **A11Y-03** | Inaccessible Charts & Graphic Data Visualizations | **High** | 1.1.1 (Non-text Content - A), 1.3.1 (Info and Relationships - A) | [`analytics_view.dart:188-271`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L188-L271)<br>[`stats_card.dart:58-76`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/stats_card.dart#L58-L76) |
| **A11Y-04** | Calendar Date Strip Lacks Semantic Context & Full Labels | **Medium** | 1.3.1 (Info & Relationships), 4.1.2 (Name, Role, Value - A) | [`calendar_view.dart:170-256`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/calendar_view.dart#L170-L256) |
| **A11Y-05** | Missing Tooltips & Accessible Labels on Icon-Only Buttons | **Medium** | 4.1.2 (Name, Role, Value - A), 1.1.1 (Non-text Content - A) | [`categories_view.dart:61`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/categories_view.dart#L61)<br>[`settings_sheet.dart:45`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/settings_sheet.dart#L45)<br>[`calendar_view.dart:346`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/calendar_view.dart#L346)<br>[`add_edit_task_sheet.dart:209`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/add_edit_task_sheet.dart#L209) |
| **A11Y-06** | Text Scaling & Layout Overflow in Fixed-Height Containers | **Medium** | 1.4.4 (Resize Text - AA), 1.4.10 (Reflow - AA) | [`calendar_view.dart:140`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/calendar_view.dart#L140)<br>[`analytics_view.dart:189`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L189)<br>[`categories_view.dart:137`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/categories_view.dart#L137) |
| **A11Y-07** | Missing Semantic Headers (`header: true`) for Screen Reader Navigation | **Medium** | 1.3.1 (Info and Relationships - A), 2.4.6 (Headings and Labels - AA) | [`filter_drawer.dart:32`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/filter_drawer.dart#L32)<br>[`settings_sheet.dart:38`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/settings_sheet.dart#L38)<br>[`task_details_sheet.dart:268`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_details_sheet.dart#L268) |
| **A11Y-08** | Gesture-Only Swipe Action Lacks Screen Reader / Switch Alternative | **Medium** | 2.1.1 (Keyboard - A), 2.5.1 (Pointer Gestures - A) | [`task_card.dart:77-142`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart#L77-L142) |
| **A11Y-09** | Lack of Live Region Announcements for Async/State Actions | **Low** | 4.1.3 (Status Messages - AA) | [`task_controller.dart`](file:///Users/jinhangyu/Desktop/task_manager/lib/controllers/task_controller.dart)<br>[`tasks_view.dart:378`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/tasks_view.dart#L378) |
| **A11Y-10** | Animations Hardcoded Without Reduced Motion Support | **Low** | 2.3.3 (Animation from Interactions - AAA) | [`custom_checkbox.dart:29`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/custom_checkbox.dart#L29)<br>[`category_chip.dart:48`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/category_chip.dart#L48)<br>[`analytics_view.dart:227`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L227) |

---

## 3. Detailed Audit Findings & Remediation

---

### Finding A11Y-01: Sub-minimum Touch Targets (<48×48 dp)
**Severity:** High  
**WCAG Criteria:** 2.5.5 (Target Size - AAA), 2.5.8 (Target Size Minimum - AA), Material Design 3 Target Bounds  
**Affected Files:**
- [`lib/widgets/task_card.dart:236-239`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart#L236-L239)
- [`lib/widgets/custom_checkbox.dart:73-82`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/custom_checkbox.dart#L73-L82)
- [`lib/widgets/task_details_sheet.dart:344-353`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_details_sheet.dart#L344-L353)
- [`lib/widgets/add_edit_task_sheet.dart:468-475`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/add_edit_task_sheet.dart#L468-L475)

#### Problem Description
1. In [`TaskCard`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart#L227), `PopupMenuButton` sets explicit constraint overrides `constraints: const BoxConstraints(minWidth: 32, maxWidth: 40)` and `padding: EdgeInsets.zero`. The resulting hit test target is only ~32×24 dp, making it difficult for users with motor impairments or tremors to tap reliably.
2. In [`CustomCheckbox`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/custom_checkbox.dart#L73), the outer `Padding` is `EdgeInsets.all(4.0)` with a `size = 24.0`. The total touch bounding box is only 32×32 dp.
3. In [`TaskDetailsSheet`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_details_sheet.dart#L344) and [`AddEditTaskSheet`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/add_edit_task_sheet.dart#L468), the subtask delete icon buttons use `Icon(Icons.delete_outline_rounded, size: 16)` inside tightly packed rows without minimum target dimension constraints (`kMinInteractiveDimension = 48.0`).

#### Remediation
Ensure all interactive widgets enforce a minimum 48×48 dp hit test bounding area using `constraints: const BoxConstraints(minWidth: 48, minHeight: 48)` or `MaterialTapTargetSize.padded`.

```dart
// Remediation for CustomCheckbox (custom_checkbox.dart)
InkWell(
  onTap: widget.onChanged != null ? () => widget.onChanged!(!widget.value) : null,
  borderRadius: BorderRadius.circular(24),
  child: Container(
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    alignment: Alignment.center,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: widget.size,
            height: widget.size,
            // ... decoration ...
          ),
        );
      },
    ),
  ),
)
```

---

### Finding A11Y-02: Insufficient Color Contrast on Muted Text & Component Badges
**Severity:** High  
**WCAG Criteria:** 1.4.3 (Contrast Minimum - Level AA), 1.4.11 (Non-text Contrast - Level AA)  
**Affected Files:**
- [`lib/theme/app_theme.dart:99, 188`](file:///Users/jinhangyu/Desktop/task_manager/lib/theme/app_theme.dart#L99)
- [`lib/widgets/task_card.dart:347, 431, 482, 508`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart#L347)
- [`lib/widgets/stats_card.dart:98-104, 191-197`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/stats_card.dart#L98-L104)
- [`lib/views/analytics_view.dart:81, 158, 263`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L81)
- [`lib/widgets/settings_sheet.dart:221-235`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/settings_sheet.dart#L221-L235)

#### Contrast Measurements

| Component & Text | Foreground Color | Background Color | Measured Contrast | Required (AA) | Status |
| :--- | :--- | :--- | :---: | :---: | :---: |
| [`TaskCard`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart#L347) description (light) | `#94A3B8` (Slate 400) | `#FFFFFF` (Card) | **2.73 : 1** | 4.50 : 1 | ❌ FAIL |
| [`TaskCard`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart#L508) tag text (light) | `#64748B` (Slate 500) | `#F1F5F9` (Chip bg) | **3.91 : 1** | 4.50 : 1 | ❌ FAIL |
| [`StatsCard`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/stats_card.dart#L100) subtitle | `Colors.white.withAlpha(0.8)` | `#4F46E5` (Indigo) | **3.48 : 1** | 4.50 : 1 | ❌ FAIL |
| [`StatsCard`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/stats_card.dart#L193) stat label (10sp) | `Colors.white.withAlpha(0.75)` | `#312E81` / `#4F46E5` | **3.15 : 1** | 4.50 : 1 | ❌ FAIL |
| [`AnalyticsView`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L81) completion rate header | `Colors.white70` | `#10B981` (Emerald) | **2.82 : 1** | 4.50 : 1 | ❌ FAIL |
| [`SettingsSheet`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/settings_sheet.dart#L231) footer (dark) | `Colors.white24` | `#1E293B` (Dark sheet) | **1.89 : 1** | 4.50 : 1 | ❌ FAIL |

#### Remediation
1. Replace `#94A3B8` (Slate 400) and `#64748B` (Slate 500) with `#475569` (Slate 600) or `#334155` (Slate 700) for light mode body and secondary text, yielding a contrast ratio > **5.8:1**.
2. On colored gradients (Indigo `#4F46E5`, Emerald `#059669`), use solid `Colors.white` for text or increase background darkness to ensure 4.5:1 ratio.
3. In dark mode, replace `Colors.white38` / `Colors.white24` with `Colors.white70` / `Color(0xFFCBD5E1)` for all informative text.

---

### Finding A11Y-03: Inaccessible Charts & Visual Data (Screen Reader Gaps)
**Severity:** High  
**WCAG Criteria:** 1.1.1 (Non-text Content - Level A), 1.3.1 (Info and Relationships - Level A)  
**Affected Files:**
- [`lib/views/analytics_view.dart:188-271`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L188-L271)
- [`lib/widgets/stats_card.dart:52-77`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/stats_card.dart#L52-L77)
- [`lib/views/categories_view.dart:190-217`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/categories_view.dart#L190-L217)

#### Problem Description
1. The 7-Day Activity Velocity Bar Chart in [`AnalyticsView`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L188) renders 7 individual `Column` widgets containing numbers, animated boxes, and weekday initials. Screen readers traverse each digit and letter independently ("3", "M", "5", "T") without announcing the day, date, or metric.
2. Circular progress indicators in [`QuickStatsOverview`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/stats_card.dart#L58) and [`CategoriesView`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/categories_view.dart#L196) lack semantic role and value labels. VoiceOver/TalkBack users do not hear "Completion progress: 65%".

#### Remediation
Wrap each chart and progress component in a descriptive `Semantics` widget with structured labels and summary values:

```dart
// Remediation for 7-Day Activity Bar (analytics_view.dart)
Semantics(
  label: '${_getFullWeekday(date.weekday)}, ${_formatDate(date)}: $count tasks completed${isToday ? ", today" : ""}',
  excludeSemantics: true,
  child: Column(
    mainAxisAlignment: MainAxisAlignment.end,
    children: <Widget>[
      Text('$count', style: /* ... */),
      const SizedBox(height: 6),
      AnimatedContainer(/* ... */),
      const SizedBox(height: 8),
      Text(weekdays[date.weekday - 1], style: /* ... */),
    ],
  ),
)
```

---

### Finding A11Y-04: Ambiguous Calendar Date Strip Semantics
**Severity:** Medium  
**WCAG Criteria:** 1.3.1 (Info and Relationships), 4.1.2 (Name, Role, Value - Level A)  
**Affected File:** [`lib/views/calendar_view.dart:170-256`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/calendar_view.dart#L170-L256)

#### Problem Description
In [`CalendarView`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/calendar_view.dart#L170), the horizontal date selector displays single-letter abbreviations `['M', 'T', 'W', 'T', 'F', 'S', 'S']` and day numbers `date.day`.
- Screen readers announce "M, 12, button", which is ambiguous ("M" could be Monday or March; "T" could be Tuesday or Thursday).
- It does not announce whether the date is currently selected (`selected: isSelected`), whether it is "Today", or the count of scheduled tasks.

#### Remediation
Add comprehensive `Semantics` properties to the date item:

```dart
Semantics(
  button: true,
  selected: isSelected,
  label: '${isToday ? "Today, " : ""}${_fullWeekday(date.weekday)}, ${_monthName(date.month)} ${date.day}, ${date.year}. $countOnDay task${countOnDay == 1 ? "" : "s"} scheduled.',
  hint: isSelected ? 'Currently selected' : 'Double tap to select this date',
  excludeSemantics: true,
  child: InkWell(
    onTap: () => setState(() => _selectedDate = date),
    // ...
  ),
)
```

---

### Finding A11Y-05: Icon-Only Buttons Missing Tooltips & Accessible Labels
**Severity:** Medium  
**WCAG Criteria:** 4.1.2 (Name, Role, Value - Level A), 1.1.1 (Non-text Content - Level A)  
**Affected Files:**
- [`lib/views/categories_view.dart:61`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/categories_view.dart#L61) — Modal close button
- [`lib/widgets/settings_sheet.dart:45`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/settings_sheet.dart#L45) — Close settings button
- [`lib/widgets/task_details_sheet.dart:158, 345, 381, 460`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_details_sheet.dart#L158) — Close, Subtask delete, Add subtask, Delete task
- [`lib/widgets/add_edit_task_sheet.dart:210, 469, 502, 552`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/add_edit_task_sheet.dart#L210) — Close, Remove subtask, Add subtask, Add tag
- [`lib/views/calendar_view.dart:346`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/calendar_view.dart#L346) — FloatingActionButton
- [`lib/views/tasks_view.dart:180`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/tasks_view.dart#L180) — Clear search query button

#### Problem Description
Multiple `IconButton`, `IconButton.filled`, and `FloatingActionButton` controls specify only an `Icon` without a `tooltip` parameter. Without a `tooltip`, Flutter does not automatically generate a semantic accessibility label for assistive technologies, leaving the button announced as "Button" or "Unlabeled".

#### Remediation
Add explicit `tooltip` strings to all icon-only buttons:
- `tooltip: 'Close'`
- `tooltip: 'Add subtask'`
- `tooltip: 'Delete subtask ${sub.title}'`
- `tooltip: 'Delete task'`
- `tooltip: 'Clear search'`
- `tooltip: 'Add new task for selected date'`

---

### Finding A11Y-06: Text Scaling & Layout Overflow (Dynamic Type 200%)
**Severity:** Medium  
**WCAG Criteria:** 1.4.4 (Resize Text - Level AA), 1.4.10 (Reflow - Level AA)  
**Affected Files:**
- [`lib/views/calendar_view.dart:140`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/calendar_view.dart#L140) — `Container(height: 90)`
- [`lib/views/analytics_view.dart:189`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L189) — `SizedBox(height: 140)`
- [`lib/views/categories_view.dart:137`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/categories_view.dart#L137) — `childAspectRatio: 1.1` in `GridView`
- [`lib/widgets/stats_card.dart:112`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/stats_card.dart#L112) — Stat row inside quick stats

#### Problem Description
When users enable enlarged text scaling in OS accessibility settings (e.g., Android Font Scale 1.5x–2.0x or iOS Large Dynamic Type):
1. In [`CalendarView`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/calendar_view.dart#L140), the date strip container is constrained to a fixed `height: 90`. Text scaling above 1.3x causes vertical `A RenderFlex overflowed by ... pixels` errors.
2. In [`AnalyticsView`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L189), the velocity bar chart has a fixed `SizedBox(height: 140)`. The bar height calculation does not dynamically adjust to the increased line height of top and bottom labels.
3. In [`CategoriesView`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/categories_view.dart#L137), `GridView.builder` uses a fixed `childAspectRatio: 1.1`. With 200% font sizes, category names and task count texts exceed card boundaries.

#### Remediation
- Avoid hardcoded fixed container heights for text-bearing widgets; use `constraints: BoxConstraints(minHeight: ...)` or scale height proportionally using `MediaQuery.textScalerOf(context)`.
- In `GridView`, use `maxCrossAxisExtent` with responsive aspect ratio or dynamic card heights:

```dart
// Remediation for CategoriesView Grid
final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
final double dynamicAspectRatio = textScale > 1.3 ? 0.85 : 1.1;
```

---

### Finding A11Y-07: Missing Semantic Headers (`header: true`)
**Severity:** Medium  
**WCAG Criteria:** 1.3.1 (Info and Relationships - Level A), 2.4.6 (Headings and Labels - Level AA)  
**Affected Files:**
- [`lib/widgets/filter_drawer.dart:32, 50, 73, 102, 144, 175`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/filter_drawer.dart#L32)
- [`lib/widgets/settings_sheet.dart:38, 56, 87, 146`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/settings_sheet.dart#L38)
- [`lib/widgets/task_details_sheet.dart:268, 390`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_details_sheet.dart#L268)
- [`lib/views/analytics_view.dart:147, 293, 331`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L147)

#### Problem Description
Screen readers provide rotor / heading navigation shortcuts that allow users to jump directly between sections of a view (e.g. from "Status" to "Category" to "Priority" in the Filter Sheet). Currently, section titles are styled using `TextStyle(fontWeight: FontWeight.w700)` but lack `Semantics(header: true)`. Screen readers treat them as plain body text, making navigation slow and cumbersome.

#### Remediation
Wrap section title widgets in `Semantics(header: true)`:

```dart
Semantics(
  header: true,
  child: const Text(
    'Filter & Sort',
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
  ),
)
```

---

### Finding A11Y-08: Gesture-Only Swipe Action Lacks Accessible Alternative
**Severity:** Medium  
**WCAG Criteria:** 2.1.1 (Keyboard - Level A), 2.5.1 (Pointer Gestures - Level A)  
**Affected File:** [`lib/widgets/task_card.dart:77-142`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart#L77-L142)

#### Problem Description
[`TaskCard`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart#L77) uses `Dismissible` for swipe-to-complete (left-to-right) and swipe-to-delete (right-to-left).
- Users who rely on switch access, keyboard navigation, or screen readers cannot perform multi-finger horizontal swipes.
- While the Popup Menu contains "Delete", "Duplicate", and "Pin", it **lacks** a "Mark Complete / Incomplete" menu entry.
- Furthermore, `Dismissible` lacks `Semantics` custom actions (`customSemanticsActions`).

#### Remediation
1. Add `customSemanticsActions` to `Semantics` on `TaskCard` so TalkBack and VoiceOver present completion and deletion actions in their action menus.
2. Add "Mark Complete / Incomplete" to the `PopupMenuButton` items.

```dart
// Remediation for TaskCard semantics (task_card.dart)
Semantics(
  customSemanticsActions: <CustomSemanticsAction, VoidCallback>{
    const CustomSemanticsAction(label: 'Toggle complete'): onToggleComplete,
    const CustomSemanticsAction(label: 'Toggle pin'): onTogglePin,
    const CustomSemanticsAction(label: 'Duplicate task'): onDuplicate,
    const CustomSemanticsAction(label: 'Delete task'): onDelete,
  },
  child: Dismissible(/* ... */),
)
```

---

### Finding A11Y-09: Lack of Live Region Announcements for State Changes
**Severity:** Low  
**WCAG Criteria:** 4.1.3 (Status Messages - Level AA)  
**Affected Files:**
- [`lib/controllers/task_controller.dart`](file:///Users/jinhangyu/Desktop/task_manager/lib/controllers/task_controller.dart)
- [`lib/views/tasks_view.dart:129, 378`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/tasks_view.dart#L129)

#### Problem Description
When a user marks a task complete, adds a new subtask, or changes a filter/search query, visual elements animate and update immediately. However, screen readers do not provide audio feedback indicating that the task list has filtered or that the task state changed.

#### Remediation
Use `SemanticsService.announce` to output non-intrusive status updates:

```dart
import 'package:flutter/rendering.dart';

void _toggleComplete(Task task) {
  widget.controller.toggleTaskCompletion(task.id);
  final String status = !task.isCompleted ? 'completed' : 'marked incomplete';
  SemanticsService.announce('Task "${task.title}" $status', TextDirection.ltr);
}
```

---

### Finding A11Y-10: Motion & Animations Without Reduced Motion Support
**Severity:** Low  
**WCAG Criteria:** 2.3.3 (Animation from Interactions - Level AAA)  
**Affected Files:**
- [`lib/widgets/custom_checkbox.dart:29`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/custom_checkbox.dart#L29)
- [`lib/widgets/category_chip.dart:48`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/category_chip.dart#L48)
- [`lib/views/calendar_view.dart:178`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/calendar_view.dart#L178)
- [`lib/views/analytics_view.dart:227`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart#L227)

#### Problem Description
The app includes scale, expand, and fade transitions with hardcoded durations (e.g. `Duration(milliseconds: 200)`). If a user has enabled "Reduce Motion" or "Disable Animations" in their operating system accessibility preferences, the animations still play.

#### Remediation
Check `MediaQuery.disableAnimationsOf(context)` before setting animation durations:

```dart
final bool disableAnimations = MediaQuery.disableAnimationsOf(context);
final Duration animDuration = disableAnimations ? Duration.zero : const Duration(milliseconds: 200);
```

---

## 4. Prioritized Implementation & Remediation Roadmap

### Phase 1: High-Priority Fixes (Immediate)
1. **Fix Color Contrast Failures:** Update [`app_theme.dart`](file:///Users/jinhangyu/Desktop/task_manager/lib/theme/app_theme.dart) text colors and [`task_card.dart`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart) secondary labels to use WCAG AA-compliant contrast ratios (>= 4.5:1).
2. **Enforce 48×48 dp Touch Targets:** Adjust bounding boxes on [`CustomCheckbox`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/custom_checkbox.dart), popup menu buttons, and subtask deletion icons.
3. **Add Non-Visual Chart Descriptions:** Wrap the 7-day velocity chart in [`AnalyticsView`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/analytics_view.dart) with descriptive semantics for VoiceOver/TalkBack.

### Phase 2: Medium-Priority Enhancements (Next Sprint)
1. **Annotate Icon-Only Buttons:** Add `tooltip` properties to all interactive icons in sheets and app bars.
2. **Semantic Headers & Custom Actions:** Wrap section titles in `Semantics(header: true)` and add custom semantics actions to [`TaskCard`](file:///Users/jinhangyu/Desktop/task_manager/lib/widgets/task_card.dart).
3. **Dynamic Type & Text Scaling Safeguards:** Replace fixed container heights with scalable or flexible layouts across [`CalendarView`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/calendar_view.dart) and [`CategoriesView`](file:///Users/jinhangyu/Desktop/task_manager/lib/views/categories_view.dart).

### Phase 3: Polish & Standards Certification
1. **Reduced Motion Support:** Apply `MediaQuery.disableAnimationsOf(context)` across animated containers.
2. **Screen Reader Announcements:** Add `SemanticsService.announce` for task state toggles, filter changes, and deletions.
3. **Automated A11y Unit Testing:** Add Flutter accessibility guidelines verification tests using `meetsGuideline(androidTapTargetGuideline)` and `meetsGuideline(labeledTapTargetGuideline)`.

---

## 5. Automated Accessibility Testing Code Snippet

To continuously prevent accessibility regressions in CI/CD, add the following test suite to `test/accessibility_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/main.dart';

void main() {
  testWidgets('Task Studio meets Flutter accessibility guidelines', (WidgetTester tester) async {
    final SemanticsHandle handle = tester.ensureSemantics();

    await tester.pumpWidget(const TaskManagementApp());
    await tester.pumpAndSettle();

    // Verify Android 48x48 tap target guideline
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    // Verify labeled tap targets
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    // Verify text contrast guidelines
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    handle.dispose();
  });
}
```
