# User Onboarding API & Flow Documentation

This document describes the flow, API endpoints, request validation rules, and integration guidelines for implementing onboarding in the mobile applications.

---

## 1. Onboarding Flow Overview

On the **JKWORLDS** platform, normal registration initializes the user profile with `onboarding_completed` set to `false`. 

> [!NOTE]
> Unlike the web application, the backend API does **not** enforce or block requests for un-onboarded users using middleware. Enforcing the onboarding wizard is purely client-side:
> - **If `onboarding_completed` is `true`**: Route the user directly to the main landing page/dashboard.
> - **If `onboarding_completed` is `false`**: Launch the **Onboarding Wizard** to collect localized user preferences.

---

## 2. Setting Preferences

There are **no dedicated `/api/onboarding` endpoints** on the backend API. Instead, onboarding preferences are submitted directly to the **Profile Update API**:

### Update Onboarding Preferences
* **URL:** `/api/profile`
* **Method:** `PUT`
* **Headers:**
  * `Authorization: Bearer <token>`
  * `Accept: application/json`
  * `Content-Type: application/json`

#### **Request Body Parameters**

| Parameter | Type | Required | Description | Constraints / Examples |
| :--- | :--- | :--- | :--- | :--- |
| `preferred_currency` | string | No | Preferred pricing currency. | Max 8 characters (e.g. `USD`, `EUR`, `GBP`, `NGN`). Converted to uppercase on the server. |
| `preferred_service` | string | No | Programmatic booking role. | Max 40 characters. One of: `traveler`, `business`, `chauffeur`. |
| `city` | string | No | Current city name. | Max 80 characters. |
| `country` | string | No | Preferred country name. | Max 80 characters. Converted to uppercase on the server. |
| `phone` | string | No | Mobile phone number. | Max 20 characters. |
| `country_code` | string | No | Country code extension. | Max 8 characters. |
| `date_of_birth` | date | No | User date of birth. | Format: `YYYY-MM-DD`. |

#### **Example Request**
```http
PUT /api/profile HTTP/1.1
Host: api.jkworlds.com
Authorization: Bearer 3|abc123xyz...
Content-Type: application/json
Accept: application/json

{
  "preferred_currency": "USD",
  "preferred_service": "traveler",
  "city": "New York",
  "country": "US",
  "phone": "+15550199",
  "country_code": "+1"
}
```

#### **Success Response (200 OK)**
```json
{
  "status": true,
  "message": "Profile updated successfully.",
  "data": {
    "id": 4,
    "user_code": 1004,
    "username": "jane-smith-102",
    "name": "Jane Smith",
    "email": "jane@example.com",
    "email_verified_at": "2026-05-15T08:30:00Z",
    "role": "customer",
    "status": "active",
    "image": "https://api.jkworlds.com/storage/uploads/users/jane-smith-102.png",
    "avatar": null,
    "country_code": "+1",
    "phone": "+15550199",
    "date_of_birth": null,
    "date_of_birth_formatted": null,
    "address": null,
    "city": "New York",
    "country": "US",
    "license_number": null,
    "license_expiry": null,
    "license_expiry_formatted": null,
    "onboarding_completed": false,
    "preferences": {
      "language": "en",
      "country": "US",
      "currency": "USD",
      "timezone": null,
      "service": "traveler",
      "location": {
        "latitude": null,
        "longitude": null
      }
    },
    "created_at": "2026-05-15T08:30:00Z",
    "updated_at": "2026-06-24T10:18:42Z"
  }
}
```

---

## 3. Database Schema Mapping & Backend Behaviors

When the user model is updated, the server maps preferences to the user records:
* `preferred_currency` $\rightarrow$ stored uppercase.
* `preferred_service` $\rightarrow$ stored as service persona.
* `preferred_language` $\rightarrow$ hardcoded to `'en'`. Timezone and GPS coordinates are not directly updatable via the profile validation API.
* **Guest Checkout Users**: Users created dynamically during a guest checkout booking flow automatically get their `onboarding_completed` flag set to `true`.

