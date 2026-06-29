# JKWORLDS Location Search API Documentation

This document describes the API endpoints available for searching locations and retrieving location details (e.g., coordinates, address info). These endpoints are typically used to populate address fields for pickup and dropoff locations when creating or updating bookings.

---

## Authentication

Unlike the bookings endpoints, the location endpoints **do not require authentication**. They are publicly accessible to allow guest users or users in the onboarding/pre-booking phase to search for locations.

---

## Data Models and Location Types

### Location Schema

Every location result returned by the API adheres to the following JSON structure:

| Field | Type | Description |
| :--- | :--- | :--- |
| `id` | string | Unique identifier for the location (specific to the active provider, e.g., OpenStreetMap Place ID or Google Place ID). |
| `name` | string | A short, human-readable name for the place (e.g., `"Dubai Mall"`). |
| `type` | string | Resolved location type value (see below). |
| `type_label` | string | Human-readable label representing the location type. |
| `address` | string | Full formatted address string. |
| `city` | string | City or locality name. |
| `country` | string | Country name. |
| `country_code` | string | Two-letter ISO country code (uppercase, e.g., `"AE"`). |
| `latitude` | float or null | Latitude coordinate in decimal degrees. |
| `longitude` | float or null | Longitude coordinate in decimal degrees. |

### Location Types

To help client applications render appropriate icons (e.g., a plane icon for airports, hotel icon for lodging), the API resolves the provider's classification into one of these standard types:

| Type (`type`) | Type Label (`type_label`) | Description / Common Keywords |
| :--- | :--- | :--- |
| `airport` | Airport | Airports, airfields, aerodromes (e.g., DXB International Airport) |
| `city` | City | Cities, towns, regions, provinces |
| `hotel` | Hotel | Hotels, resorts, motels, guest houses |
| `train_station` | Train Station | Train stations, subways, metro stations, railways |
| `landmark` | Landmark | Tourist attractions, museums, stadiums, monuments |
| `address` | Address | Residential streets, routes, postal codes, specific buildings |
| `other` | Place | Default fallback for any other uncategorized place type |

---

## Endpoint Reference

### 1. Search Locations
Search for places or addresses matching a search query string.

* **URL:** `/api/location/search`
* **Method:** `GET`
* **Headers:**
  * `Accept: application/json`

#### Query Parameters
| Parameter | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `q` | string | Yes | The search query term. Minimum: 1 character, Maximum: 200 characters. | `Dubai Mall` |
| `limit` | integer | Optional | Max number of results to return. Minimum: 1, Maximum: 20 (default depends on provider, usually `12`). | `5` |

#### Response Format (200 OK)
```json
{
  "status": true,
  "message": "Locations fetched successfully.",
  "data": {
    "provider": "nominatim",
    "results": [
      {
        "id": "184083313",
        "name": "The Dubai Mall",
        "type": "landmark",
        "type_label": "Landmark",
        "address": "The Dubai Mall, Financial Center Road, Downtown Dubai, Dubai, 113444, United Arab Emirates",
        "city": "Dubai",
        "country": "United Arab Emirates",
        "country_code": "AE",
        "latitude": 25.1973406,
        "longitude": 55.2796101
      },
      {
        "id": "285633890",
        "name": "Dubai Mall Metro Station",
        "type": "train_station",
        "type_label": "Train Station",
        "address": "Burj Khalifa / Dubai Mall, Sheikh Zayed Road, Al Wasl, Dubai, 113444, United Arab Emirates",
        "city": "Dubai",
        "country": "United Arab Emirates",
        "country_code": "AE",
        "latitude": 25.2014603,
        "longitude": 55.2689582
      }
    ]
  }
}
```

#### Validation Error (422 Unprocessable Content)
If the query parameter `q` is missing or validation fails:
```json
{
  "status": false,
  "message": "Validation failed",
  "data": {
    "q": [
      "The q field is required."
    ]
  }
}
```

---

### 2. Get Location Details
Retrieve full location metadata (including exact latitude/longitude coordinates) for a specific location ID.

* **URL:** `/api/location/details`
* **Method:** `GET`
* **Headers:**
  * `Accept: application/json`

#### Query Parameters
| Parameter | Type | Required | Description | Example |
| :--- | :--- | :--- | :--- | :--- |
| `id` | string | Yes | The location/place ID returned by the search endpoint. Maximum: 255 characters. | `184083313` |

#### Response Format (200 OK)
```json
{
  "status": true,
  "message": "Location details fetched successfully.",
  "data": {
    "provider": "nominatim",
    "location": {
      "id": "184083313",
      "name": "The Dubai Mall",
      "type": "landmark",
      "type_label": "Landmark",
      "address": "The Dubai Mall, Financial Center Road, Downtown Dubai, Dubai, 113444, United Arab Emirates",
      "city": "Dubai",
      "country": "United Arab Emirates",
      "country_code": "AE",
      "latitude": 25.1973406,
      "longitude": 55.2796101
    }
  }
}
```

#### Error Response Format (404 Not Found)
If the specified `id` is not found or is invalid:
```json
{
  "status": false,
  "message": "Location not found.",
  "data": null
}
```

#### Service Unavailable (503 Service Unavailable)
If the external geocoding API provider (e.g., Nominatim, Google Maps, Mapbox) is offline or fails to respond:
```json
{
  "status": false,
  "message": "Unable to fetch location details. Please try again.",
  "data": {
    "provider": "nominatim"
  }
}
```
---

### 3. Check Location Coverage
Validate that a specific coordinate (latitude/longitude) falls within an active service area coverage zone for a given service type. This is typically used by client applications to verify address feasibility before booking creation.

* **URL:** `/api/location/check-coverage`
* **Method:** `POST`
* **Headers:**
  * `Accept: application/json`
  * `Content-Type: application/json`

#### Request Body Parameters
| Parameter | Type | Required | Description | Constraints / Examples |
| :--- | :--- | :--- | :--- | :--- |
| `lat` | float | Yes | Latitude coordinate of the location. | Must be between `-90` and `90`. |
| `lng` | float | Yes | Longitude coordinate of the location. | Must be between `-180` and `180`. |
| `service_type` | string | Yes | The service type to verify coverage for. | Must be one of: `self_drive`, `chauffeur`, `airport_transfer`. |

#### Example Request
```http
POST /api/location/check-coverage HTTP/1.1
Host: api.jkworlds.com
Content-Type: application/json
Accept: application/json

{
  "lat": 25.1973406,
  "lng": 55.2796101,
  "service_type": "self_drive"
}
```

#### Response Format: Covered (200 OK)
When the location lies within an active coverage zone:
```json
{
  "status": true,
  "message": "Location is covered.",
  "data": {
    "covered": true,
    "zone": {
      "id": 5,
      "name": "Dubai Downtown Area",
      "type": "city"
    }
  }
}
```

#### Response Format: Outside Service Area (200 OK)
When the platform has active coverage restrictions configured, but the coordinate falls outside all active zones:
```json
{
  "status": true,
  "message": "Location is outside our service area.",
  "data": {
    "covered": false
  }
}
```

#### Response Format: No Zones Configured (200 OK)
If no active coverage zones have been defined by administrators for the requested service type, the API automatically permits bookings globally (returns covered: true with a null zone):
```json
{
  "status": true,
  "message": "No coverage restrictions configured.",
  "data": {
    "covered": true,
    "zone": null
  }
}
```

#### Validation Error (422 Unprocessable Content)
If any of the parameters are missing or out of bounds:
```json
{
  "status": false,
  "message": "Validation failed",
  "data": {
    "lat": [
      "The lat field must be between -90 and 90."
    ],
    "service_type": [
      "The selected service type is invalid."
    ]
  }
}
```

---

## Configuration & Active Providers
The API dynamically switches between providers depending on server-side configuration. The active provider is always returned in the response metadata wrapper (`data.provider`). 

Supported providers:
* `nominatim` (OpenStreetMap - Default)
* `google` (Google Places API)
* `mapbox` (Mapbox Search)
* `locationiq` (LocationIQ API)
* `opencage` (OpenCage Geocoder)

*Regardless of the active backend provider, the API format remains identical, ensuring clients do not have to write provider-specific parsing code.*
