# API Documentation

Base URL: `https://<your-domain>/api`

All request/response bodies are JSON unless otherwise noted. Endpoints under **Authenticated Endpoints** require a Bearer token obtained from `/login` or `/register`.

> **Note on response shape:** The exact JSON envelope is produced by an `ApiResponse` helper not shown in the provided code. Examples below assume the common Laravel pattern of `{ "success": bool, "message": string, "data": ... }`. Confirm the real shape against `App\Helpers\ApiResponse` and adjust if it differs.

---

## Table of Contents

1. [Authentication](#authentication)
   - [Register](#1-register)
   - [Login](#2-login)
   - [Logout](#3-logout)
   - [Get Current User](#4-get-current-user-me)
   - [Refresh Token](#5-refresh-token)
   - [Forgot Password](#6-forgot-password)
   - [Verify OTP](#7-verify-otp)
   - [Reset Password](#8-reset-password)
2. [Profile](#profile)
   - [Update Profile](#1-update-profile)
   - [Update Password](#2-update-password)
3. [Vehicles](#vehicles)
   - [List Vehicles by Category](#1-list-vehicles-by-category)
4. [Error Format](#error-format)

---

## Authentication

Base path: `/api`

### 1. Register

Create a new user account and receive an auth token immediately.

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `/register` |
| **Auth required** | No |

**Request Body**

| Field | Type | Rules |
|---|---|---|
| `name` | string | required, max 255 |
| `email` | string | required, valid email, max 255, must be unique |
| `password` | string | required, min 8 characters |
| `password_confirmation` | string | required, must match `password` |

```json
{
  "name": "Jane Doe",
  "email": "jane@example.com",
  "password": "Secret123",
  "password_confirmation": "Secret123"
}
```

**Success Response — `201 Created`**

```json
{
  "success": true,
  "message": "User registered successfully.",
  "data": {
    "token": "1|abcdef123456...",
    "user": {
      "id": 1,
      "name": "Jane Doe",
      "email": "jane@example.com",
      "user_code": 1001,
      "username": "jane-doe-482"
    }
  }
}
```

**Notes**

- `user_code` auto-increments starting at `1001`.
- `username` is auto-generated as a slug of `name` plus a random 3-digit suffix.
- The account is created with `email_verified_at` set immediately (no email verification step) and `status: active`.
- A Sanctum token is issued on registration — no separate login call needed right after signup.

---

### 2. Login

Authenticate with email and password. Any existing tokens for the user are revoked first (single active session per login).

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `/login` |
| **Auth required** | No |

**Request Body**

| Field | Type | Rules |
|---|---|---|
| `email` | string | required, valid email |
| `password` | string | required |

```json
{
  "email": "jane@example.com",
  "password": "Secret123"
}
```

**Success Response — `200 OK`**

```json
{
  "success": true,
  "message": "Login successful.",
  "data": {
    "token": "2|xyz987...",
    "user": { "...": "UserResource fields" }
  }
}
```

**Error Response — `401 Unauthorized`**

```json
{
  "success": false,
  "message": "The provided credentials are incorrect."
}
```

**Notes**

- Logging in invalidates all previous tokens for that user (`$user->tokens()->delete()` before issuing a new one), so a user can only be logged in from one place/device at a time.

---

### 3. Logout

Revoke all tokens for the currently authenticated user.

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `/logout` |
| **Auth required** | Yes (Bearer token) |

**Headers**

```
Authorization: Bearer {token}
```

**Success Response — `200 OK`**

```json
{
  "success": true,
  "message": "Logged out successfully.",
  "data": null
}
```

---

### 4. Get Current User (`/me`)

Returns the authenticated user's profile.

| | |
|---|---|
| **Method** | `GET` |
| **URL** | `/me` |
| **Auth required** | Yes (Bearer token) |

> Note: there is also a `GET /user` route defined inline in `routes/api.php` that returns the same data via `UserResource`. Both exist in the current routes file — consider consolidating to avoid duplication.

**Success Response — `200 OK`**

```json
{
  "success": true,
  "message": "Profile fetched successfully.",
  "data": { "...": "UserResource fields" }
}
```

---

### 5. Refresh Token

Revokes the current token(s) and issues a new one.

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `/refresh-token` |
| **Auth required** | Yes (Bearer token) |

**Success Response — `200 OK`**

```json
{
  "success": true,
  "message": "Token refreshed successfully.",
  "data": {
    "token": "3|newtoken..."
  }
}
```

**Notes**

- The old token is deleted, so the client must immediately swap to the new token for subsequent requests.

---

### 6. Forgot Password

Sends a 6-digit OTP to the user's email to begin password reset.

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `/forgot-password` |
| **Auth required** | No |

**Request Body**

| Field | Type | Rules |
|---|---|---|
| `email` | string | required, valid email |

```json
{ "email": "jane@example.com" }
```

**Success Response — `200 OK`**

```json
{
  "success": true,
  "message": "Password reset OTP sent to your email.",
  "data": null
}
```

**Validation Error — email not found**

```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": {
    "email": ["The selected email is invalid."]
  }
}
```

**Notes**

- Email lookup is case-insensitive (compares lowercased email).
- OTP is a random 6-digit number, stored in the `password_resets` table keyed by lowercased email, valid for **10 minutes**.
- **Local/dev environment behavior:** when `APP_ENV=local`, the OTP is included directly in the response under `data.otp`, and the message changes to indicate this. **This must never reach a production environment** — double check `APP_ENV` is not `local` in staging/prod before relying on this.
- If sending the email fails and the environment is not local, the endpoint returns a `500` error. In local, the failure is silently ignored (since the OTP is already returned in the response).

---

### 7. Verify OTP

Checks whether a submitted OTP is valid for the given email, and marks it as "verified" if so.

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `/verify-otp` |
| **Auth required** | No |

**Request Body**

| Field | Type | Rules |
|---|---|---|
| `email` | string | required, valid email |
| `otp` | string | required, exactly 6 characters |

```json
{ "email": "jane@example.com", "otp": "482913" }
```

**Success Response — `200 OK`**

```json
{
  "success": true,
  "message": "OTP verified successfully.",
  "data": { "verified": true }
}
```

**Invalid/Expired Response — `200 OK`**

```json
{
  "success": true,
  "message": "Invalid or expired OTP.",
  "data": { "verified": false }
}
```

**Notes**

- A valid OTP is one matching the email, matching the stored token, and created within the last 10 minutes.
- On success, the stored token is rewritten as `verified:{otp}` — this flags the reset session as verified so `reset-password` can be called afterward without resubmitting the OTP.
- This endpoint always returns HTTP `200`, even for an invalid OTP — check the `data.verified` boolean rather than the status code.

---

### 8. Reset Password

Sets a new password. Requires that the email has either a still-valid OTP or a previously-verified OTP session (from step 7) within the last 10 minutes.

| | |
|---|---|
| **Method** | `POST` |
| **URL** | `/reset-password` |
| **Auth required** | No |

**Request Body**

| Field | Type | Rules |
|---|---|---|
| `email` | string | required, valid email |
| `otp` | string | optional, exactly 6 characters if provided |
| `password` | string | required, min 8 characters |

```json
{
  "email": "jane@example.com",
  "otp": "482913",
  "password": "NewSecret456"
}
```

**Success Response — `200 OK`**

```json
{
  "success": true,
  "message": "Password reset successfully.",
  "data": null
}
```

**Error Response — invalid/expired OTP**

```json
{
  "success": false,
  "message": "Invalid or expired OTP. Please verify OTP before resetting password.",
  "errors": { "verified": false }
}
```

**Notes**

- You can call this either:
  - **with `otp`** — directly, matching either the raw OTP or its `verified:` form, or
  - **without `otp`** — only works if `/verify-otp` was already called successfully within the last 10 minutes.
- On success, all `password_resets` rows for that email are deleted (the reset session is consumed and can't be reused).

---

## Profile

Base path: `/api` — **all endpoints below require authentication.**

```
Authorization: Bearer {token}
```

### 1. Update Profile

Partially updates the authenticated user's profile fields, including an optional profile image upload.

| | |
|---|---|
| **Method** | `PUT` |
| **URL** | `/profile` |
| **Auth required** | Yes |
| **Content-Type** | `multipart/form-data` (required if uploading `image`; otherwise `application/json` also works) |

**Request Body** — all fields are optional (`sometimes`/`nullable`); only send what you want to change.

| Field | Type | Rules |
|---|---|---|
| `name` | string | max 255 |
| `email` | string | valid email, max 255, unique (excluding current user) |
| `phone` | string | max 20 |
| `country_code` | string | max 8 |
| `address` | string | max 255 |
| `city` | string | max 80 |
| `country` | string | max 80 — stored uppercased |
| `date_of_birth` | date | — |
| `license_number` | string | max 80 |
| `license_expiry` | date | — |
| `preferred_language` | string | max 8 |
| `preferred_country` | string | max 2 — stored uppercased |
| `preferred_currency` | string | max 8 — stored uppercased |
| `preferred_timezone` | string | max 80 |
| `preferred_service` | string | max 40 |
| `location_latitude` | numeric | — |
| `location_longitude` | numeric | — |
| `image` | file | image, mimes: jpeg/png/jpg/gif/webp, **max 2048 KB (2 MB)** |

**Example (`multipart/form-data`)**

```
PUT /api/profile
Authorization: Bearer {token}
Content-Type: multipart/form-data

name=Jane Doe
city=Dhaka
country=bd
preferred_currency=usd
image=@profile.jpg
```

**Success Response — `200 OK`**

```json
{
  "success": true,
  "message": "Profile updated successfully.",
  "data": { "...": "UserResource fields, refreshed" }
}
```

**Validation Error — `422` (typical Laravel shape)**

```json
{
  "message": "The image must not be larger than 2 MB (2048 KB).",
  "errors": {
    "image": ["The profile image must not be larger than 2 MB (2048 KB)."]
  }
}
```

**Notes**

- `country`, `preferred_country`, and `preferred_currency` are normalized to **uppercase** server-side — send them in any case.
- If a new `image` is uploaded and the user already had one, the old file is deleted from `public/uploads/users/` before the new one is stored.
- Stored image filename pattern: `{slugified-original-name}-{uniqid}.{extension}` inside `uploads/users/`.
- This is a partial update — omitted fields are left unchanged.

---

### 2. Update Password

Changes the authenticated user's password, requiring the current password for confirmation.

| | |
|---|---|
| **Method** | `PUT` |
| **URL** | `/password` |
| **Auth required** | Yes |

**Request Body**

| Field | Type | Rules |
|---|---|---|
| `current_password` | string | required |
| `password` | string | required, min 8 |
| `password_confirmation` | string | required, must match `password` |

```json
{
  "current_password": "OldPass123",
  "password": "NewPass456",
  "password_confirmation": "NewPass456"
}
```

**Success Response — `200 OK`**

```json
{
  "success": true,
  "message": "Password updated successfully.",
  "data": null
}
```

**Error Response — wrong current password**

```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": {
    "current_password": ["The current password is incorrect."]
  }
}
```

---

## Vehicles

### 1. List Vehicles by Category

Returns a paginated list of active vehicles within a given category, with optional filters.

| | |
|---|---|
| **Method** | `GET` |
| **URL** | `/categories/{category}/vehicles` |
| **Auth required** | No |

**Path Parameters**

| Param | Type | Description |
|---|---|---|
| `category` | integer | Category ID (route-model-bound to `Category`) |

**Query Parameters**

| Param | Type | Description |
|---|---|---|
| `per_page` | integer | Results per page. Default `12`. |
| *(other filters)* | — | Additional filters are built by `VehicleListingService::filtersFromRequest()` — not shown in the provided code, so the full filter set (e.g. price range, seats, transmission) isn't documented here. Confirm against that service. |

> **Note:** the `category` filter key is explicitly stripped from the filters array since the category is already applied via the route, so passing a `category` query param has no effect here.

**Example Request**

```
GET /api/categories/4/vehicles?per_page=20
```

**Success Response — `200 OK`** (paginated)

```json
{
  "success": true,
  "message": "Vehicles fetched successfully.",
  "data": {
    "items": [
      { "...": "VehicleResource fields" }
    ],
    "pagination": {
      "current_page": 1,
      "per_page": 20,
      "total": 57,
      "last_page": 3
    }
  }
}
```

> The exact pagination envelope depends on `ApiResponse::paginated()`, which isn't included in the provided files — confirm field names against that helper.

**Error Response — category not found or inactive — `404`**

```json
{
  "success": false,
  "message": "Category not found."
}
```

**Notes**

- Returns `404` not just when the category ID doesn't exist, but also when the category exists but has `status` disabled — both cases look identical to the client.

---

## Error Format

Based on the patterns used across these controllers, expect roughly:

| Scenario | HTTP Status | Shape |
|---|---|---|
| Validation failure (Laravel default) | `422` | `{ "message": "...", "errors": { "field": ["msg"] } }` |
| Validation failure (via `ApiResponse::validation()`) | likely `422` or `200` (varies by call site — `verifyOtp` returns `200` even when invalid) | `{ "success": false, "message": "...", "errors": {...} }` |
| Unauthorized / bad credentials | `401` | `{ "success": false, "message": "..." }` |
| Not found | `404` | `{ "success": false, "message": "..." }` |
| Server error | `500` | `{ "success": false, "message": "...", "error": "..." }` |

> Since `App\Helpers\ApiResponse` wasn't included in the provided files, treat the exact field names (`success`, `data`, `errors`, etc.) above as a best-guess based on conventional usage in the controllers. Pull up that helper class to confirm the literal response contract before building a client against it.

---

## Open Questions / Things to Verify Against Your Codebase

- Exact JSON shape of `ApiResponse::success()`, `::error()`, `::validation()`, `::unauthorized()`, `::notFound()`, `::paginated()`.
- Full field list returned by `UserResource` and `VehicleResource`.
- Full filter set supported by `VehicleListingService::filtersFromRequest()` for the vehicle listing endpoint.
- Whether `GET /me` and `GET /user` are intentionally both present, or if one should be removed.