# Damage Reports API Documentation

This document describes the API endpoints available for submitting and listing vehicle damage reports. These endpoints are used by customers to report any condition issues or damage on vehicles before, during, or after their bookings.

---

## Authentication & Headers

All endpoints under the `/api/damage-reports` group require Sanctum token authentication.

| Header | Value | Required | Description |
| :--- | :--- | :--- | :--- |
| `Authorization` | `Bearer <token>` | Yes | Sanctum personal access token. |
| `Accept` | `application/json` | Yes | API response formatting constraint. |

---

## Endpoints Overview

| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| **GET** | `/api/damage-reports` | Retrieves stats, eligible bookings list, and the user's paginated damage reports history. | Yes |
| **POST** | `/api/damage-reports` | Submits a new vehicle damage report (with optional image uploads). | Yes |
| **GET** | `/api/damage-reports/{id}` | Retrieves full detail of a specific damage report. | Yes |

---

## Detailed API Reference

### 1. List Damage Reports & Stats
`GET /api/damage-reports`

Retrieves a dashboard snapshot including:
- General stats of submitted and resolved damage reports.
- Eligible bookings from the user's account that can have reports submitted against them.
- A paginated list of all damage reports submitted by the user.

#### **Example Request**
```http
GET /api/damage-reports?per_page=5 HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Accept: application/json
```

#### **Success Response (200 OK)**
```json
{
  "status": true,
  "message": "Damage reports fetched successfully.",
  "data": {
    "stats": {
      "total": 3,
      "pending": 1,
      "resolved": 2
    },
    "bookings": [
      {
        "id": 104,
        "booking_code": "JKW-2026-0004",
        "vehicle_id": 12,
        "vehicle_title": "Lamborghini Urus 2024",
        "pickup_datetime": "2026-07-01T10:00:00+04:00"
      }
    ],
    "reports": {
      "data": [
        {
          "id": 5,
          "report_number": "00005",
          "booking_id": 104,
          "booking_code": "JKW-2026-0004",
          "vehicle_id": 12,
          "vehicle_title": "Lamborghini Urus 2024",
          "vehicle_plate_number": "DXB-A-9999",
          "title": "Scratch on driver door",
          "description": "Found a 3-inch scratch on the lower part of the driver door during checkout.",
          "severity": "minor",
          "status": "submitted",
          "status_label": "Pending",
          "images": [
            "https://api.jkworlds.com/storage/uploads/customer/reports/xyz123abc.png"
          ],
          "admin_note": null,
          "reported_at": "2026-06-28T13:45:00+06:00",
          "reviewed_at": null,
          "created_at": "2026-06-28T13:45:00+06:00"
        }
      ],
      "links": {
        "first": "https://api.jkworlds.com/api/damage-reports?page=1",
        "last": "https://api.jkworlds.com/api/damage-reports?page=1",
        "prev": null,
        "next": null
      },
      "meta": {
        "current_page": 1,
        "from": 1,
        "last_page": 1,
        "path": "https://api.jkworlds.com/api/damage-reports",
        "per_page": 5,
        "to": 1,
        "total": 1
      }
    }
  }
}
```

---

### 2. Submit Damage Report
`POST /api/damage-reports`

Creates a new condition/damage report linked to a specific booking. Supports uploading multiple photos.

#### **Request Body Parameters (Multipart Form-Data)**

| Parameter | Type | Required | Description | Constraints / Examples |
| :--- | :--- | :--- | :--- | :--- |
| `booking_id` | integer | Yes | The ID of the booking to report damage against. | Must belong to the authenticated user. |
| `title` | string | Yes | Brief summary of the damage. | Max 255 characters. |
| `description` | string | No | Detailed explanation of the issue. | Max 2000 characters. |
| `severity` | string | Yes | Severity level of the damage. | Must be: `minor`, `moderate`, or `severe`. |
| `images` | array | No | Uploaded image files. | Key should be `images[]`. Max image size: `5MB` (`5120 KB`) per file. Allowed extensions: `jpg`, `jpeg`, `png`, `webp`. |

#### **Example Request**
```http
POST /api/damage-reports HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
Accept: application/json

------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="booking_id"

104
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="title"

Rear dent
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="severity"

moderate
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="description"

Small dent on the rear bumper.
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="images[]"; filename="dent.png"
Content-Type: image/png

[Binary Data]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

#### **Success Response (201 Created)**
```json
{
  "status": true,
  "message": "Damage report submitted successfully. Our team will review it soon.",
  "data": {
    "id": 6,
    "report_number": "00006",
    "booking_id": 104,
    "booking_code": "JKW-2026-0004",
    "vehicle_id": 12,
    "vehicle_title": "Lamborghini Urus 2024",
    "vehicle_plate_number": "DXB-A-9999",
    "title": "Rear dent",
    "description": "Small dent on the rear bumper.",
    "severity": "moderate",
    "status": "submitted",
    "status_label": "Pending",
    "images": [
      "https://api.jkworlds.com/storage/uploads/customer/reports/abc789xyz.png"
    ],
    "admin_note": null,
    "reported_at": "2026-06-28T13:46:00+06:00",
    "reviewed_at": null,
    "created_at": "2026-06-28T13:46:00+06:00"
  }
}
```

---

### 3. Get Damage Report Details
`GET /api/damage-reports/{id}`

Retrieves complete information about a specific damage report.

#### **URI Parameters**

| Parameter | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `id` | integer | Yes | The ID of the damage report. | `5` |

#### **Example Request**
```http
GET /api/damage-reports/5 HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Accept: application/json
```

#### **Success Response (200 OK)**
```json
{
  "status": true,
  "message": "Damage report fetched successfully.",
  "data": {
    "id": 5,
    "report_number": "00005",
    "booking_id": 104,
    "booking_code": "JKW-2026-0004",
    "vehicle_id": 12,
    "vehicle_title": "Lamborghini Urus 2024",
    "vehicle_plate_number": "DXB-A-9999",
    "title": "Scratch on driver door",
    "description": "Found a 3-inch scratch on the lower part of the driver door during checkout.",
    "severity": "minor",
    "status": "submitted",
    "status_label": "Pending",
    "images": [
      "https://api.jkworlds.com/storage/uploads/customer/reports/xyz123abc.png"
    ],
    "admin_note": null,
    "reported_at": "2026-06-28T13:45:00+06:00",
    "reviewed_at": null,
    "created_at": "2026-06-28T13:45:00+06:00"
  }
}
```

#### **Error Response (404 Not Found)**
If the report ID does not exist or does not belong to the user:
```json
{
  "status": false,
  "message": "Damage report not found.",
  "data": null
}
```

---

## Models State Mappings

### Damage Report Status (`status` / `status_label`)

| Status Value | Label (`status_label`) | Description |
| :---: | :--- | :--- |
| `submitted` | Pending | Report has been sent and is in the queue for staff review. |
| `reviewed` | Under Review | Staff has reviewed the report details but hasn't resolved it yet. |
| `resolved` | Resolved | The damage report case has been closed/resolved. |
| `rejected` | Rejected | The report has been rejected by administrators. |
