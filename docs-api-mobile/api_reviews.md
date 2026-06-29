# Vehicle Reviews and Ratings API Documentation

This document describes the API endpoints available for submitting and listing vehicle reviews and ratings. These reviews are submitted by customers who have rented vehicles, and their ratings directly affect the overall score displayed on the vehicle listings.

---

## Authentication & Headers

All endpoints under the `/api/ratings` group require Sanctum token authentication.

| Header | Value | Required | Description |
| :--- | :--- | :--- | :--- |
| `Authorization` | `Bearer <token>` | Yes | Sanctum personal access token. |
| `Accept` | `application/json` | Yes | API response formatting constraint. |

---

## Endpoints Overview

| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| **GET** | `/api/ratings` | Retrieves the list of user's reviews and eligible bookings that can be rated. | Yes |
| **POST** | `/api/ratings` | Submits a new review and rating for a booking. | Yes |

---

## Detailed API Reference

### 1. Get Reviews & Rating Options
`GET /api/ratings`

Retrieves a lists of:
- Bookings eligible to be reviewed (along with a boolean flag indicating if they have already been reviewed).
- All reviews submitted by the authenticated user.

#### **Example Request**
```http
GET /api/ratings HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Accept: application/json
```

#### **Success Response (200 OK)**
```json
{
  "status": true,
  "message": "Ratings fetched successfully.",
  "data": {
    "bookings": [
      {
        "id": 104,
        "booking_code": "JKW-2026-0004",
        "vehicle_id": 12,
        "vehicle_title": "Lamborghini Urus 2024",
        "pickup_datetime": "2026-07-01T10:00:00+04:00",
        "is_reviewed": true
      }
    ],
    "reviews": [
      {
        "id": 8,
        "booking_id": 104,
        "booking_code": "JKW-2026-0004",
        "vehicle_id": 12,
        "vehicle_title": "Lamborghini Urus 2024",
        "rating": 5,
        "comment": "Excellent ride! Car was extremely clean and customer service was prompt.",
        "status": "approved",
        "status_label": "Approved",
        "created_at": "2026-06-17T14:20:00Z"
      }
    ]
  }
}
```

---

### 2. Submit Review
`POST /api/ratings`

Submits a rating and comment for a specific completed booking.

#### **Request Body Parameters**

| Parameter | Type | Required | Description | Constraints / Examples |
| :--- | :--- | :--- | :--- | :--- |
| `booking_id` | integer | Yes | The ID of the booking to rate. | Must belong to the authenticated user's account. |
| `rating` | integer | Yes | Numeric rating score. | Must be between `1` and `5` (inclusive). |
| `comment` | string | No | Optional review text/feedback. | Max 2000 characters. |

#### **Example Request**
```http
POST /api/ratings HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Content-Type: application/json
Accept: application/json

{
  "booking_id": 104,
  "rating": 5,
  "comment": "Superb vehicle condition. Highly recommended!"
}
```

#### **Success Response (201 Created)**
```json
{
  "status": true,
  "message": "Review submitted successfully. Thank you for your feedback! Admin will review and approve it soon.",
  "data": {
    "id": 9,
    "booking_id": 104,
    "booking_code": "JKW-2026-0004",
    "vehicle_id": 12,
    "vehicle_title": "Lamborghini Urus 2024",
    "rating": 5,
    "comment": "Superb vehicle condition. Highly recommended!",
    "status": "pending",
    "status_label": "Pending Approval",
    "created_at": "2026-06-28T13:51:00Z"
  }
}
```

---

## Models State Mappings

### Review Status (`status` / `status_label`)

| Status Value | Label (`status_label`) | Description |
| :---: | :--- | :--- |
| `pending` | Pending Approval | Review has been submitted and is awaiting admin approval before showing on public vehicle details. |
| `approved` | Approved | Review is publicly visible on the vehicle listings and details page. |
| `rejected` | Rejected | Review has been hidden/rejected by administrators. |
