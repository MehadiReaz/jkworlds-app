# Implementation Plan - API-Driven Vehicle Details UI

We will update the Vehicle Details screen (`VehicleDetailView` and `VehicleDetailController`) to dynamically incorporate detailed fields fetched from the GET `/api/vehicles/{id}` endpoint, as documented in `vehicle_api_docs.md`.

---

## Proposed Changes

### 1. Vehicle Detail Controller

#### [MODIFY] [vehicle_detail_controller.dart](file:///a:/JKWORLDS/jkworlds/lib/modules/vehicle_detail/vehicle_detail_controller.dart)
- Add a reactive integer `currentGalleryIndex` to keep track of the swiped image page.
- Implement date range validation logic `isDateSelectable(DateTime date)`:
  - Parses `unavailableDates` (`from` and `to` ranges).
  - Normalizes date values (to midnight) and returns `false` if the date falls in any unavailable range.
- Update `selectDateRange(BuildContext context)` to pass `selectableDayPredicate: isDateSelectable` to the `showDateRangePicker` call, preventing the selection of blocked/booked dates.

### 2. Vehicle Detail View

#### [MODIFY] [vehicle_detail_view.dart](file:///a:/JKWORLDS/jkworlds/lib/modules/vehicle_detail/vehicle_detail_view.dart)
- **Interactive Gallery Slider**:
  - Replace the static single image placeholder with a `PageView` stack if the `gallery` (or `images`) array has multiple entries.
  - Render an animated dot indicator track at the bottom of the image container to display the swipe progress linked to `currentGalleryIndex`.
- **Spec Details Enhancement**:
  - Add the dynamic vehicle `color` spec (e.g. `Color: Gray`) to the Plate & Mileage horizontal row.
- **Dynamic Rental Add-ons**:
  - Render the rental addons checklist dynamically from `vehicle.rentalAddons`.
  - Bind dynamic addon check states to the corresponding legacy boolean controllers (`gpsAddon`, `additionalDriverAddon`, `childSeatAddon`) using keyword checks to maintain full checkout routing compatibility.

---

## Verification Plan

### Manual Verification
- **Vehicle Detail Page**:
  - Verify that if a vehicle has a multi-image gallery, we can swipe through the images and the dot indicators update accordingly.
  - Verify that the horizontal spec row displays "Plate: [number]", "Mileage: [number] km", and "Color: [color]" side-by-side.
  - Open the date range picker and confirm that dates matching the vehicle's `unavailable_dates` are visually disabled and unselectable on the calendar.
  - Verify that checking dynamic addons updates the pricing calculations in real-time.
