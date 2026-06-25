# Support Tickets API Documentation

This document outlines the API endpoints, request validation rules, parameters, responses, and implementation behaviors for the support ticket message system in **JKWORLDS**.

---

## 1. Authentication & Headers

All endpoints under the `/api/support-tickets` group require Sanctum token authentication. 

| Header | Value | Required | Description |
| :--- | :--- | :--- | :--- |
| `Authorization` | `Bearer <token>` | Yes | Sanctum personal access token. |
| `Accept` | `application/json` | Yes | API response formatting constraint. |

---

## 2. Endpoints Overview

The Support Tickets API is designed using 4 core endpoints. Ticket updates, cursoring, scrolling, and status transitions are driven by request parameters on the ticket resource detail endpoint.

| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| **GET** | `/api/support-tickets` | Retrieves all tickets belonging to the authenticated user along with total unread counts and polling frequency recommendations. | Yes |
| **POST** | `/api/support-tickets` | Creates a new support ticket with an initial message. | Yes |
| **GET** | `/api/support-tickets/{ticket}` | Fetches ticket details, messages list, cursor navigation (older/newer), light-weight polling checks, and read marking. | Yes |
| **POST** | `/api/support-tickets/{ticket}/messages` | Appends a new user message to the ticket, optionally uploading a file attachment. | Yes |

---

## 3. Detailed API Reference

### A. List Support Tickets
`GET /api/support-tickets`

Retrieves a list of all support tickets created by the authenticated user, sorted by latest.

#### **Example Request**
```http
GET /api/support-tickets HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Accept: application/json
```

#### **Example Response**
```json
{
  "status": true,
  "message": "Support tickets fetched successfully.",
  "data": {
    "tickets": [
      {
        "id": 12,
        "subject": "Unable to verify driving license",
        "priority": "High",
        "status": 1,
        "status_label": "open",
        "can_send_message": true,
        "unread_count": 2,
        "last_message_id": 145,
        "date": "2026-06-24",
        "created_at": "2026-06-24T05:30:17.000000Z",
        "updated_at": "2026-06-24T06:12:45.000000Z"
      }
    ],
    "total_unread": 2,
    "poll_seconds": 12
  }
}
```

---

### B. Create Support Ticket
`POST /api/support-tickets`

Registers a new support ticket under the user's account and logs their initial question/message.

#### **Request Body Parameters**

| Parameter | Type | Required | Description | Constraints / Examples |
| :--- | :--- | :--- | :--- | :--- |
| `subject` | `string` | Yes | Subject of the support request. | Max 255 chars. |
| `message` | `string` | Yes | Initial message detail describing the issue. | Max 5000 chars. |
| `priority` | `string` | Yes | Case-insensitive ticket priority level. | Must be: `High`, `Medium`, `Low`, `high`, `medium`, `low`. |

#### **Example Request**
```http
POST /api/support-tickets HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Content-Type: application/json
Accept: application/json

{
  "subject": "Double charged on Booking #1209",
  "message": "Hello, my card was charged twice for the RAV4 booking. Please check.",
  "priority": "High"
}
```

#### **Example Response (201 Created)**
```json
{
  "status": true,
  "message": "Support ticket created successfully.",
  "data": {
    "id": 13,
    "subject": "Double charged on Booking #1209",
    "priority": "High",
    "status": 1,
    "status_label": "open",
    "can_send_message": true,
    "unread_count": 0,
    "last_message_id": 146,
    "date": "2026-06-24",
    "created_at": "2026-06-24T06:29:25.000000Z",
    "updated_at": "2026-06-24T06:29:25.000000Z"
  }
}
```

---

### C. Get Ticket Details / Messages / Poll / Mark Read
`GET /api/support-tickets/{ticket}`

Fetches single resource metadata for a specific ticket. This endpoint serves multiple query modes: standard message fetching, scrolling/pagination, light-weight polling for new content, and marking messages as read.

#### **URI Parameters**

| Parameter | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `ticket` | `integer` | Yes | The ID of the support ticket (must be numeric). | `12` |

#### **Query Parameters**

| Parameter | Type | Default | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `light` | `boolean` | `false` | If set to `true` (or `1`), performs a quick check returning only whether new messages exist since `after_id` without returning the message payload. | `1` |
| `after_id` | `integer` | `0` | Returns only messages with an ID greater than this value (newer messages cursor / polling threshold). | `145` |
| `before_id` | `integer` | `0` | Returns only messages with an ID smaller than this value (older messages cursor for scroll-up pagination). | `135` |
| `limit` | `integer` | `20` | Maximum messages to return. Minimum is `1`, max cap is `50`. | `30` |
| `mark_read` | `boolean` | `false` | If set to `true` (or `1`), marks all messages as read for the user up to `last_id`. | `1` |
| `last_id` | `integer` | `0` | Specified message ID threshold when marking read. If omitted or `0` while `mark_read` is enabled, marks all messages as read up to the latest fetched message's ID. | `145` |

#### **Example Request (Standard Fetch - Info & Latest Messages)**
```http
GET /api/support-tickets/12 HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Accept: application/json
```

#### **Example Response (Standard Fetch)**
```json
{
  "status": true,
  "message": "Ticket conversation fetched successfully.",
  "data": {
    "ticket": {
      "id": 12,
      "subject": "Unable to verify driving license",
      "priority": "High",
      "status": 1,
      "status_label": "open",
      "can_send_message": true,
      "unread_count": 0,
      "last_message_id": 145,
      "date": "2026-06-24",
      "created_at": "2026-06-24T05:30:17.000000Z",
      "updated_at": "2026-06-24T06:12:45.000000Z"
    },
    "messages": [
      {
        "id": 144,
        "message": "Please attach a clear photo of the back of your license.",
        "file": null,
        "from_admin": true,
        "sender_name": "Support Team",
        "sender_avatar": "http://localhost:8000/assets/profiles/admin-1.jpg",
        "created_at": "24 Jun, 2026 06:10 AM",
        "created_at_iso": "2026-06-24T06:10:00.000000Z",
        "is_mine": false
      },
      {
        "id": 145,
        "message": "Here is the photo.",
        "file": "http://localhost:8000/uploads/60a2b3c4d5e6.png",
        "from_admin": false,
        "sender_name": "Jane Smith",
        "sender_avatar": "http://localhost:8000/assets/profiles/user-4.jpg",
        "created_at": "24 Jun, 2026 06:12 AM",
        "created_at_iso": "2026-06-24T06:12:45.000000Z",
        "is_mine": true
      }
    ],
    "first_id": 144,
    "last_id": 145,
    "has_more_older": true,
    "poll_seconds": 3
  }
}
```

#### **Example Request (Light Polling Check)**
Checking for new messages since ID 145 without loading full payloads.
```http
GET /api/support-tickets/12?light=1&after_id=145 HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Accept: application/json
```

#### **Example Response (Light Polling Check)**
```json
{
  "status": true,
  "message": "Ticket check fetched successfully.",
  "data": {
    "ticket": {
      "id": 12,
      "subject": "Unable to verify driving license",
      "priority": "High",
      "status": 1,
      "status_label": "open",
      "can_send_message": true,
      "unread_count": 2,
      "last_message_id": 147,
      "date": "2026-06-24",
      "created_at": "2026-06-24T05:30:17.000000Z",
      "updated_at": "2026-06-24T06:12:45.000000Z"
    },
    "has_new": true,
    "poll_seconds": 3
  }
}
```

#### **Example Request (Fetch & Mark Read)**
Fetches messages while simultaneously marking the ticket as read up to the latest message ID.
```http
GET /api/support-tickets/12?mark_read=1 HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Accept: application/json
```

#### **Error Response Format (404 Not Found)**
Returned if the ticket does not exist or belongs to another user.
```json
{
  "status": false,
  "message": "Support ticket not found.",
  "data": null
}
```

---

### D. Send Ticket Message
`POST /api/support-tickets/{ticket}/messages`

Appends a message to the ticket timeline. Supports optional multipart file uploads (e.g. photos/screenshots).

#### **Request Body Parameters (Multipart Form-Data)**

| Parameter | Type | Required | Description | Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `message` | `string` | Yes | The textual content of the message. | Max 5000 chars. |
| `file` | `file` | No | Optional attached image. | Allowed formats: `jpeg`, `png`, `jpg`, `gif`, `webp`. Max size: `2MB` (`2048 KB`). |

#### **Example Request**
```http
POST /api/support-tickets/12/messages HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW
Accept: application/json

------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="message"

Here is the photo.
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="license_back.png"
Content-Type: image/png

[Binary Data]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

#### **Example Response (201 Created)**
```json
{
  "status": true,
  "message": "Message sent successfully.",
  "data": {
    "id": 145,
    "message": "Here is the photo.",
    "file": "http://localhost:8000/uploads/60a2b3c4d5e6.png",
    "from_admin": false,
    "sender_name": "Jane Smith",
    "sender_avatar": "http://localhost:8000/assets/profiles/user-4.jpg",
    "created_at": "24 Jun, 2026 06:12 AM",
    "created_at_iso": "2026-06-24T06:12:45.000000Z",
    "is_mine": true
  }
}
```

---

## 4. Models State Mappings

### Ticket Status
The `status` attribute returned in responses is an integer mapped as follows:

| Integer Value | Label | Description | Can Send Message |
| :---: | :--- | :--- | :---: |
| **0** | `pending` | Ticket is logged and awaiting initial response. | Yes |
| **1** | `open` | Ticket is active and currently being discussed. | Yes |
| **2** | `rejected` | Ticket has been rejected by administrators. | Yes |
| **3** | `closed` | Ticket has been closed. Client cannot post more messages. | **No** |

### Priority Mappings
The `priority` field accepts case-insensitive strings during ticket creation, which are normalized and stored as capitalized values:
*   `Low`
*   `Medium`
*   `High`
