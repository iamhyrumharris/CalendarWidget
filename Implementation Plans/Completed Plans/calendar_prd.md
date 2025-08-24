# Journal Calendar Component - Product Requirements Document

## Overview
A visual calendar component for a journal app that displays photos as thumbnails on calendar days, optimized for browsing and viewing journal entries across multiple years.

## Core Functionality

### Calendar Structure
- **Layout**: Continuous vertical scroll showing one month per section
- **Month Headers**: Each month displays "Month Year" (e.g., "August 2025") in standard text size
- **Week Headers**: "Sun Mon Tue Wed Thu Fri Sat" fixed at the top of the screen, always visible
- **Week Start**: Weeks begin on Sunday

### Scrolling & Navigation
- **Primary Navigation**: Smooth vertical scrolling through months
- **Year Range**: Dynamic loading starting with current year ±10 years
- **Initial Position**: Calendar opens to current month
- **Date Picker**: "Jump to Date" button in app bar for accessing distant years
- **Quick Return**: "Today" button in date picker modal for easy return to current date
- **Performance Target**: Smooth 60fps scrolling on iPhone 11/XR and equivalent Android devices

### Day Cell Design
- **Size**: Square cells with minimal gaps between them
- **Background**: 
  - Days with photos: Photo thumbnail as background
  - Days without photos: Darker solid color background
- **Day Number**: 
  - Position: Center of the cell
  - Style: Overlaid white text, no background badge
- **Current Day Indicator**: Visible border around today's date
- **Interaction**: Static/non-interactive for now

### Image Handling
- **Thumbnail Source**: First photo added to that day
- **Aspect Ratio**: Images cropped to fit square day cells
- **Loading State**: Static placeholder while images load
- **Storage**: App stores full-resolution images, generates thumbnails for calendar display
- **Performance**: Thumbnails optimized for smooth scrolling

## Technical Specifications

### Dynamic Loading Strategy
- **Initial Load**: Current month ± 3 months
- **Expansion**: Load additional months as user approaches boundaries
- **Memory Management**: Unload distant months to maintain performance
- **Cache Strategy**: Keep thumbnails cached, unload full month components when off-screen

### Visual Design
- **Theme Support**: Both light and dark themes based on device setting or user preference
- **Spacing**: Minimal gaps between day cells for maximum visibility
- **Layout**: 
  - App bar at top
  - Fixed week headers below app bar
  - Scrollable calendar content
  - Bottom navigation (outside calendar scope)

### Platform Support
- **Orientation**: Portrait only
- **Responsive**: Adapts to different screen sizes within portrait orientation

## User Experience Flow

### Normal Usage
1. App opens to current month
2. User scrolls up/down to browse adjacent months
3. Photos appear as thumbnails on relevant days
4. Day numbers clearly visible on all cells
5. Current day visually distinct with border

### Historical Entry Access
1. User taps "Jump to Date" in app bar
2. Date picker modal opens with month/year selection
3. "Today" button available for quick return
4. Selection closes modal and jumps calendar to chosen date
5. Dynamic loading provides smooth experience around new date

## Performance Requirements

### Scrolling Performance
- **Frame Rate**: Consistent 60fps during scroll
- **Responsiveness**: Immediate response to touch input
- **Memory Usage**: Efficient memory management for multi-year browsing

### Image Performance
- **Thumbnail Generation**: Optimized for calendar cell size
- **Loading**: Smooth experience while images load
- **Caching**: Intelligent caching to minimize re-downloads

## Future Considerations

### Phase 2 Potential Features
- Day cell interaction/tapping
- Multiple photo indicators for days with multiple entries
- Landscape orientation support
- Extended date range handling
- Search functionality integration

## Success Metrics
- Smooth 60fps scrolling performance across target devices
- Fast thumbnail loading and display
- Intuitive navigation between distant dates
- Clear visual hierarchy and day identification

## Out of Scope
- Day cell interactions/tapping functionality
- Entry creation or editing
- Multi-photo display indicators
- Calendar export functionality
- Sharing features