# JKWORLDS App Data API Documentation

This document describes the API endpoint available for retrieving global application bootstrap and configuration data (e.g., active currencies, FAQs, static pages). This endpoint is typically called during app initialization (splash screen or onboarding) to cache global configurations.

---

## Authentication

The App Data endpoint **does not require authentication**. It is publicly accessible to allow guest and unauthenticated clients to fetch basic system configuration details.

---

## Endpoint Reference

### 1. Get Application Configuration Data
Retrieve a list of active currencies, FAQs, and static/custom pages.

* **URL:** `/api/app-data`
* **Method:** `GET`
* **Headers:**
  * `Accept: application/json`

#### Query Parameters
This endpoint does not accept any query parameters.

#### Response Format (200 OK)
Returns a unified container of application configurations grouped by type.

```json
{
  "status": true,
  "message": "App data fetched successfully.",
  "data": {
    "currencies": [
      {
        "id": 1,
        "name": "United Arab Emirates Dirham",
        "code": "AED",
        "symbol": "د.إ",
        "symbol_position": "left",
        "exchange_rate": 3.67,
        "is_default": true
      },
      {
        "id": 2,
        "name": "US Dollar",
        "code": "USD",
        "symbol": "$",
        "symbol_position": "left",
        "exchange_rate": 1,
        "is_default": false
      }
    ],
    "faqs": [
      {
        "id": 1,
        "question": "What is the minimum age to rent a car?",
        "answer": "The minimum age to rent a self-drive car is 21 years. For luxury vehicle categories, the driver must be at least 25 years old.",
        "order": 1
      },
      {
        "id": 2,
        "question": "Are fuel costs included in the rental price?",
        "answer": "Fuel is not included in the standard self-drive rentals. The car will be provided with a full tank of fuel and should be returned with a full tank. For chauffeur-driven trips, fuel is fully covered.",
        "order": 2
      }
    ],
    "pages": [
      {
        "id": 1,
        "key": "about",
        "title": "About Us",
        "slug": "about-us",
        "content": "JKWORLDS is a premium mobility and transport services platform providing car rentals, professional chauffeur services, and luxury airport transfers.",
        "order": 1
      },
      {
        "id": 2,
        "key": "terms",
        "title": "Terms and Conditions",
        "slug": "terms-and-conditions",
        "content": "By using the JKWORLDS platform, you agree to our rental policies, damage rules, and driver assignment conditions.",
        "order": 2
      },
      {
        "id": 3,
        "key": "privacy",
        "title": "Privacy Policy",
        "slug": "privacy-policy",
        "content": "We respect your privacy and protect your personal information in accordance with regional regulations.",
        "order": 3
      }
    ],
    "sliders": [
      {
        "id": 1,
        "image": "https://api.jkworlds.com/storage/sliders/slide1.png",
        "order": 1
      },
      {
        "id": 2,
        "image": "https://api.jkworlds.com/storage/sliders/slide2.png",
        "order": 2
      }
    ],
    "contact_us": {
      "email": "support@jkworlds.com",
      "phone": "+971501234567"
    }
  }
}
```

---

## Response Schema Details

### Currencies

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | integer | Unique identifier for the currency database record. |
| `name` | string | Full name of the currency. |
| `code` | string | 3-letter ISO 4217 currency code (uppercase). |
| `symbol` | string | Visual symbol representing the currency (e.g., `$`, `AED`). |
| `symbol_position` | string | Indicates whether the symbol should be rendered to the `left` or `right` of the numeric value. |
| `exchange_rate` | float | Exchange rate relative to the system base currency. |
| `is_default` | boolean | Indicates if this is the system's default currency. |

### FAQs

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | integer | Unique identifier for the FAQ database record. |
| `question` | string | Frequently asked question text. |
| `answer` | string | Plain-text answer (HTML tags automatically stripped by the backend). |
| `order` | integer | Sorting priority for UI presentation (lower values display first). |

### Pages

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | integer | Unique identifier for the static page record. |
| `key` | string | A unique programmatic key mapped from the slug for quick frontend identification (e.g., `'about-us'` maps to `'about'`, `'terms-and-conditions'` maps to `'terms'`, etc.). |
| `title` | string | Title of the static custom page. |
| `slug` | string | URL-friendly slug representing the page path. |
| `content` | string | Plain-text body of the page (HTML tags automatically stripped by the backend). |
| `order` | integer | Sorting order identifier for footer/menu navigation links. |

### Sliders

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | integer | Unique identifier for the slider record. |
| `image` | string | Absolute URL to the slider banner image asset. |
| `order` | integer | Sorting order/position indicator for the carousel presentation. |

### Contact Us

| Field | Type | Description |
| :--- | :--- | :--- |
| `email` | string | Support email address configured in settings. |
| `phone` | string | Contact phone number configured in settings. |

