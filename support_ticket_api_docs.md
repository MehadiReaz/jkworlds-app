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

| Method | Endpoint | Description | Auth Required |
|:---|:---|:---|:---|
| **GET** | `/api/support-tickets` | Retrieves all tickets belonging to the authenticated user along with polling hints and unread count totals. | Yes |
| **POST** | `/api/support-tickets` | Creates a new support ticket with an initial message. | Yes |
| **GET** | `/api/support-tickets/unread-summary` | Retrieves a summary mapping of unread message counts for all active tickets. | Yes |
| **POST** | `/api/support-tickets/sync` | Batch checks multiple tickets to see if new messages have arrived since a given message ID threshold. | Yes |
| **GET** | `/api/support-tickets/{ticket}` | Fetches details for a single specific support ticket. | Yes |
| **GET** | `/api/support-tickets/{ticket}/messages` | Retrieves messages for a ticket (supports light checking, older/newer cursors, and limits). | Yes |
| **POST** | `/api/support-tickets/{ticket}/messages` | Appends a new user message to the ticket, optionally uploading a file attachment. | Yes |
| **POST** | `/api/support-tickets/{ticket}/read` | Marks a ticket as read for the user up to a specified message ID. | Yes |

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
    "polling": {
      "inbox_interval_seconds": 12,
      "chat_light_interval_seconds": 3,
      "chat_idle_interval_seconds": 20,
      "messages_page_size": 20
    }
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
| `priority` | `string` | Yes | Case-insensitive ticket priority level. | Must be: `Low`, `Medium`, `High`. |

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

#### **Example Response**
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

### C. Get Unread Summary
`GET /api/support-tickets/unread-summary`

Returns a quick summary mapping containing the sum total of unread support messages and specific per-ticket counts.

#### **Example Request**
```http
GET /api/support-tickets/unread-summary HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Accept: application/json
```

#### **Example Response**
```json
{
  "status": true,
  "message": "Unread summary fetched successfully.",
  "data": {
    "total_unread": 3,
    "tickets": {
      "12": {
        "unread": 2,
        "subject": "Unable to verify driving license",
        "last_message_id": 145
      },
      "15": {
        "unread": 1,
        "subject": "GPS Addon query",
        "last_message_id": 150
      }
    },
    "polling": {
      "inbox_interval_seconds": 12,
      "chat_light_interval_seconds": 3,
      "chat_idle_interval_seconds": 20,
      "messages_page_size": 20
    }
  }
}
```

---

### D. Sync Tickets Cursor
`POST /api/support-tickets/sync`

Allows a batch client poll to verify if new incoming messages exist for specific tickets beyond their last-cached message IDs.

#### **Request Body Parameters**

| Parameter | Type | Required | Description | Format |
| :--- | :--- | :--- | :--- | :--- |
| `tickets` | `array` | Yes | Map of ticket IDs to their last read message ID. | `{"<ticket_id>": <last_message_id>}` |

#### **Example Request**
```http
POST /api/support-tickets/sync HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Content-Type: application/json
Accept: application/json

{
  "tickets": {
    "12": 143,
    "15": 150
  }
}
```

#### **Example Response**
```json
{
  "status": true,
  "message": "Support ticket sync fetched successfully.",
  "data": {
    "has_new": {
      "12": true,
      "15": false
    },
    "total_unread": 2,
    "tickets": {
      "12": {
        "unread": 2,
        "subject": "Unable to verify driving license",
        "last_message_id": 145
      }
    },
    "polling": {
      "inbox_interval_seconds": 12,
      "chat_light_interval_seconds": 3,
      "chat_idle_interval_seconds": 20,
      "messages_page_size": 20
    }
  }
}
```

---

### E. Get Ticket Details
`GET /api/support-tickets/{ticket}`

Fetches single resource metadata for a specific ticket.

#### **URI Parameters**

| Parameter | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `ticket` | `integer` | Yes | The ID of the support ticket (must be numeric). | `12` |

#### **Example Response**
```json
{
  "status": true,
  "message": "Support ticket fetched successfully.",
  "data": {
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
}
```

---

### F. Get Ticket Messages
`GET /api/support-tickets/{ticket}/messages`

Fetches chronological messages inside the ticket. Supports pagination/cursors and light polling queries.

#### **Query Parameters**

| Parameter | Type | Default | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `light` | `boolean` | `false` | If set to `true`, returns a quick check of whether new messages exist without downloading the message list. | `true` |
| `after_id` | `integer` | `0` | Returns only messages with an ID greater than this value (newer messages cursor). | `140` |
| `before_id` | `integer` | `0` | Returns only messages with an ID smaller than this value (older messages cursor). | `135` |
| `limit` | `integer` | `20` | Maximum messages to return. Max cap is `50`. | `30` |

#### **Example Request (Standard Fetch)**
```http
GET /api/support-tickets/12/messages?limit=2 HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Accept: application/json
```

#### **Example Response (Standard Fetch)**
```json
{
  "status": true,
  "message": "Messages fetched successfully.",
  "data": {
    "messages": [
      {
        "id": 144,
        "message": "Please attach a clear photo of the back of your license.",
        "file": null,
        "from_admin": true,
        "sender_name": "Support Team",
        "sender_avatar": "https://api.jkworlds.com/storage/profiles/admin-1.jpg",
        "created_at": "24 Jun, 2026 06:10 AM",
        "created_at_iso": "2026-06-24T06:10:00.000000Z",
        "is_mine": false
      },
      {
        "id": 145,
        "message": "Here is the photo.",
        "file": "https://api.jkworlds.com/uploads/60a2b3c4d5e6.png",
        "from_admin": false,
        "sender_name": "Jane Smith",
        "sender_avatar": "https://api.jkworlds.com/storage/profiles/user-4.jpg",
        "created_at": "24 Jun, 2026 06:12 AM",
        "created_at_iso": "2026-06-24T06:12:45.000000Z",
        "is_mine": true
      }
    ],
    "first_id": 144,
    "last_id": 145,
    "has_more_older": true,
    "ticket_status": 1,
    "status_label": "open",
    "can_send_message": true
  }
}
```

#### **Example Request (Light Polling Check)**
```http
GET /api/support-tickets/12/messages?light=1&after_id=145 HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Accept: application/json
```

#### **Example Response (Light Polling Check)**
```json
{
  "status": true,
  "message": "Message check fetched successfully.",
  "data": {
    "has_new": false,
    "ticket_status": 1,
    "can_send_message": true
  }
}
```

---

### G. Send Ticket Message
`POST /api/support-tickets/{ticket}/messages`

Appends a message to the ticket timeline. Supports multipart file uploads.

#### **Request Body Parameters (Multipart Form-Data)**

| Parameter | Type | Required | Description | Constraints |
| :--- | :--- | :--- | :--- | :--- |
| `message` | `string` | Yes | The textual content of the message. | Max 5000 chars. |
| `file` | `file` | No | Optional attached image. | Allowed: `jpeg`, `png`, `jpg`, `gif`, `webp`. Max `2MB`. |

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

#### **Example Response**
```json
{
  "status": true,
  "message": "Message sent successfully.",
  "data": {
    "id": 145,
    "message": "Here is the photo.",
    "file": "https://api.jkworlds.com/uploads/60a2b3c4d5e6.png",
    "from_admin": false,
    "sender_name": "Jane Smith",
    "sender_avatar": "https://api.jkworlds.com/storage/profiles/user-4.jpg",
    "created_at": "24 Jun, 2026 06:12 AM",
    "created_at_iso": "2026-06-24T06:12:45.000000Z",
    "is_mine": true
  }
}
```

---

### H. Mark Ticket As Read
`POST /api/support-tickets/{ticket}/read`

Updates the user's read cursor/index status for a given ticket.

#### **Request Body Parameters**

| Parameter | Type | Required | Description | Default |
| :--- | :--- | :--- | :--- | :--- |
| `last_id` | `integer` | No | Target message ID to mark up to. | Optional; if not provided or 0, marks all messages as read up to the current maximum message ID. |

#### **Example Request**
```http
POST /api/support-tickets/12/read HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Content-Type: application/json
Accept: application/json

{
  "last_id": 145
}
```

#### **Example Response**
```json
{
  "status": true,
  "message": "Ticket marked as read.",
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
    }
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
