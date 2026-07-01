# Checkout Coupon / Promo Code API Documentation

This document describes the API endpoint and integration rules for applying and validating coupon codes during the checkout process.

---

## Authentication & Headers

Applying a coupon is available to both authenticated users and guests. If a Sanctum token is provided, the API will validate the coupon against the logged-in user's redemption limits.

| Header | Value | Required | Description |
| :--- | :--- | :--- | :--- |
| `Accept` | `application/json` | Yes | Forces the backend to return standard JSON responses. |
| `Authorization` | `Bearer <token>` | No | Laravel Sanctum personal access token. Optional; if provided, checks per-user coupon redemption limits. |
| `Currency` | `<ISO_CODE>` | No | Optional (default: `USD` or system default). Converted ISO code (e.g. `USD`, `EUR`, `GBP`, `AED`, `BDT`, `NGN`). Converted amounts are returned in this currency. |
| `Service-Type` | `self_drive \| chauffeur \| airport_transfer` | No | Optional (default: `self_drive`). Can also be passed in the request body. |

---

## Endpoints Overview

| Method | Endpoint | Description | Auth Required |
| :--- | :--- | :--- | :--- |
| **POST** | `/api/checkout/coupon` | Validates a promo code against the booking context and returns the discount details and new payable total. | No (Optional) |

---

## Detailed API Reference

### Apply Promo Code
`POST /api/checkout/coupon`

Validates a promo code against the active booking context (vehicle, dates, locations, extras) and calculates the discount amount in the requested currency.

#### **Request Body Parameters**

| Parameter | Type | Required | Description | Constraints / Examples |
| :--- | :--- | :--- | :--- | :--- |
| `coupon_code` | string | **Yes** | The promo code string to apply. | Max 50 characters. Case-insensitive. |
| `vehicle_id` | integer | **Yes** | The ID of the vehicle being booked. | Must be an active vehicle in the database. |
| `service_type` | string | No | The rental service mode. | `self_drive`, `chauffeur`, `airport_transfer`. |
| `pickup_date` | date | **Yes** | Pickup start date. | Format: `YYYY-MM-DD` |
| `pickup_time` | string | **Yes** | Pickup start time. | Format: `HH:mm` (24h) |
| `return_date` | date | **Yes** | Return end date. | Format: `YYYY-MM-DD`. Required unless `service_type` is `airport_transfer`. Must be after or equal to `pickup_date`. |
| `return_time` | string | No | Return end time. | Format: `HH:mm` (24h). Defaults to `23:59`. |
| `pickup_latitude` | numeric | **Yes** | Latitude of pickup location. | Between `-90` and `90`. |
| `pickup_longitude` | numeric | **Yes** | Longitude of pickup location. | Between `-180` and `180`. |
| `dropoff_latitude` | numeric | No | Latitude of drop-off location. | Required for `chauffeur` and `airport_transfer`. |
| `dropoff_longitude` | numeric | No | Longitude of drop-off location. | Required for `chauffeur` and `airport_transfer`. |
| `pickup_location_name` | string | No | Pickup location text. | Max 255 characters. |
| `pickup_address` | string | No | Pickup street address. | Max 500 characters. |
| `dropoff_location_name`| string | No | Drop-off location text. | Required for `chauffeur` and `airport_transfer`. |
| `dropoff_address` | string | No | Drop-off street address. | Max 500 characters. |
| `protection_plan_id` | integer | No | Protection plan selection. | Must belong to the vehicle. |
| `addon_ids` | array | No | Selected rental addon IDs. | Array of integers belonging to the vehicle. |
| `additional_driver` | boolean | No | Flag for additional driver. | Ignored for `chauffeur` and `airport_transfer`. |

#### **Example Request**
```http
POST /api/checkout/coupon HTTP/1.1
Host: api.jkworlds.com
Content-Type: application/json
Accept: application/json
Currency: EUR

{
  "coupon_code": "WELCOME10",
  "vehicle_id": 1,
  "service_type": "self_drive",
  "pickup_date": "2026-07-16",
  "pickup_time": "10:00",
  "return_date": "2026-07-20",
  "return_time": "10:00",
  "pickup_latitude": 9.0579,
  "pickup_longitude": 7.4951,
  "protection_plan_id": 3,
  "addon_ids": [2]
}
```

#### **Success Response (200 OK)**
```json
{
  "status": true,
  "message": "Promo code applied successfully.",
  "data": {
    "code": "WELCOME10",
    "name": "Welcome Discount",
    "discount_type": "percent",
    "discount_value": 10,
    "discount": {
      "amount": 73.42,
      "amount_formatted": "€73.42"
    },
    "total": {
      "amount": 838.30,
      "amount_formatted": "€838.30"
    },
    "payable_total": {
      "amount": 764.88,
      "amount_formatted": "€764.88"
    },
    "currency": "EUR"
  }
}
```

---

## Validation & Business Rules

Coupons are processed server-side via `App\Services\CouponService` which enforces the following constraints:

### 1. Inactive & Temporal Checks
- **Status Check**: The coupon must be marked active (`status` attribute = `1`/`true`).
- **Timing Check**: Current time must fall between `start_date` (inclusive, start of day) and `expiration_date` (inclusive, end of day). Timestamps are evaluated in the timezone configured in the system (defaults to `Asia/Dhaka`).

### 2. Redemption Limit Constraints
Redemptions are tracked against paid bookings. The system verifies limits using:
- **Global Usage Limit (`max_global_redemptions`)**: The total number of confirmed/paid bookings across all clients (web, mobile, front-desk) using the coupon code must not exceed this value.
- **Per-User Usage Limit (`max_redemptions_per_user`)**:
  - For **authenticated users**, the system checks their account ID (`user_id`) and billing email.
  - For **guests**, this check is deferred to booking creation time (`POST /api/bookings`) when the email address is submitted, verifying both the email and the code.

---

## Error Codes and Messages

If the coupon fails validation, the API returns a `422 Unprocessable Content` response.

### Coupon Errors

| Scenario | HTTP Status | Error Message |
| :--- | :---: | :--- |
| Code does not exist | `422` | `"Invalid promo code."` |
| Coupon is deactivated | `422` | `"This promo code is inactive."` |
| Coupon start date in future | `422` | `"This promo code is not active yet."` |
| Coupon expiration date passed | `422` | `"This promo code has expired."` |
| Global usage limit reached | `422` | `"This promo code has reached its usage limit."` |
| User limit reached | `422` | `"You have already used this promo code the maximum number of times."` |

#### **Example Error Response (422)**
```json
{
  "status": false,
  "message": "This promo code has expired.",
  "data": null
}
```
