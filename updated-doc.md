**JKWorlds Mobile API - App Developer Guide**

**Base URL:** `{{base_url}}/api`  
**Generated:** 2026-06-25

### Purpose
This guide explains the mobile booking API flow from vehicle details to checkout, booking initiation, and payment confirmation. It is organized for mobile app developers so they can implement the flow step by step.

### What the app needs to do

| What the app needs to do                          | Recommended API                          |
|---------------------------------------------------|------------------------------------------|
| Show vehicle details and selected service pricing | GET /v2/vehicles/{vehicle}               |
| Preview airport transfer distance and fare        | POST /airport-transfer/distance          |
| Display final pricing breakdown and payment methods | POST /checkout                         |
| Create pending payment and get gateway SDK data   | POST /bookings                           |
| Confirm booking after SDK payment succeeds        | POST /payments/{gateway}/success         |
| Cancel abandoned payment                          | POST /payments/{gateway}/cancel          |

---

### Integration Overview
The app follows a simple **payment-first booking flow**. The booking record is created only after the payment success endpoint verifies the gateway payment on the server.

#### Flow Steps

| Step | App action                              | Endpoint                          | Result |
|------|-----------------------------------------|-----------------------------------|--------|
| 1    | Load vehicle and service-type pricing   | GET /v2/vehicles/{vehicle}        | Vehicle details, protection plans, add-ons, selected pricing |
| 2    | Airport transfer only: preview distance/fare | POST /airport-transfer/distance | Distance, billable km, estimated fare |
| 3    | Show checkout breakdown                 | POST /checkout                    | Full pricing, discount, deposit, payable total, payment methods |
| 4    | Start payment                           | POST /bookings                    | Pending payment reference and gateway SDK data |
| 5    | Confirm payment                         | POST /payments/{gateway}/success  | Server verifies payment and creates booking |
| 6    | Cancel if abandoned                     | POST /payments/{gateway}/cancel   | Payment marked cancelled; no booking created |

**Important for app payment**  
Use `payable_total.amount` from checkout (or amount from booking initiation) as the amount charged by the in-app gateway SDK. Keep the reference and send it back to success/cancel.

### Common Headers

| Header                        | Required | Notes |
|-------------------------------|----------|-------|
| Accept: application/json      | Yes      | Use for every endpoint to receive JSON responses. |
| Content-Type: application/json| Yes for JSON POST | Do not send this for multipart/form-data file uploads. |
| Currency: USD                 | No       | Converts all returned amounts to the selected currency. |
| Authorization: Bearer {token} | No       | Optional authenticated user flow. |
| Service-Type: self_drive      | No       | Used by GET /vehicles/{id}; can also be sent as service_type query param. |

### Payment Rules

| Gateway     | Supported currencies                  |
|-------------|---------------------------------------|
| stripe      | USD, EUR, GBP, AED, BDT               |
| paypal      | USD, EUR, GBP                         |
| flutterwave | NGN, USD, EUR, GBP, AED, BDT          |

### Service Types

| Service type     | Pricing                        | Driver          | Drop-off required | License upload |
|------------------|--------------------------------|-----------------|-------------------|----------------|
| self_drive       | Daily / weekly / monthly       | Customer drives | No                | Yes            |
| chauffeur        | Daily rate + add-on support    | Included        | Yes               | No             |
| airport_transfer | distance_km x per_km_rate      | Included        | Yes               | No             |

---

### Standard Response Format
**Success:**
```json
{
  "status": true,
  "message": "Success message",
  "data": {}
}
```

**Validation Error:**
```json
{
  "message": "The given data was invalid.",
  "errors": {}
}
```

---

### 1. Get Vehicle Details
**GET** `/v2/vehicles/{vehicle}`

**Workflow**  
Returns vehicle details with pricing for the requested service type.  
If `service_type` is `airport_transfer` and coordinates are provided, the response can also include an estimated airport transfer fare.

**Query Parameters**
- `pickup_latitude`, `pickup_longitude`, `dropoff_latitude`, `dropoff_longitude` (for airport transfer estimate)
- `service_type`

**Main Response Fields**
- `id`, `title`
- `service_type`, `service_type_label`
- `pricing`
- `protection_plans`
- `rental_addons`
- `service_pricing.applicable`

**Example Response** (truncated):
```json
{
  "status": true,
  "message": "Vehicle details fetched successfully.",
  "data": {
    "id": 6,
    "title": "Mercedes E-Class",
    "service_type": "airport_transfer",
    "service_pricing": {
      "applicable": {
        "per_km_rate": { "amount": 10, "amount_formatted": "$10.00" }
      }
    }
  }
}
```

---

### 2. Airport Transfer Distance
**POST** `/airport-transfer/distance`

**Workflow**  
Calculates straight-line distance using the haversine formula.  
`vehicle_id` is optional (adds fare breakdown).

**Body Parameters**
- `pickup_latitude`, `pickup_longitude` (required)
- `dropoff_latitude`, `dropoff_longitude` (required)
- `vehicle_id` (optional)

**Main Response Fields**
- `distance` (raw_km, billable_km, etc.)
- `fare` (per_km_rate, base_fare, estimated_total)

**Example Response** (truncated):
```json
{
  "status": true,
  "message": "Distance calculated successfully.",
  "data": {
    "distance": { "raw_km": 10.8, "billable_km": 10.8 },
    "fare": { "estimated_total": { "amount": 121.64 } }
  }
}
```

---

### 3. Checkout Pricing
**POST** `/checkout`

**Workflow**  
Returns the full price breakdown only (nothing is saved).  
Charge `payable_total.amount`.

**Body Parameters** (key ones)
- `vehicle_id` (required)
- `pickup_date`, `pickup_time` (required)
- `return_date` (required for self_drive/chauffeur)
- Coordinates and location names (required for chauffeur/airport_transfer)
- `protection_plan_id`, `addon_ids[]`, `coupon_code`, etc.

**Main Response Fields**
- `currency`, `service_type`
- `base`, `addons_total`, `protection`, `fees`, `discount`, `total`, `payable_total`
- `payment_methods` (list of available gateways)

**Example Response** (truncated):
```json
{
  "status": true,
  "message": "Checkout pricing calculated successfully.",
  "data": {
    "payable_total": { "amount": 764.88 },
    "payment_methods": [{ "key": "stripe", ... }]
  }
}
```

---

### 4. Booking Initiation
**POST** `/bookings`

**Workflow**  
Creates a pending payment and returns gateway SDK data.  
For `self_drive`, `driver_license` is required (multipart/form-data).

**Body Parameters** (many overlap with checkout +)
- `full_name`, `email`, `phone`
- `payment_method` (stripe, paypal, or flutterwave)
- `driver_license` (for self_drive)

**Main Response Fields**
- `reference` (save this!)
- `status`: "pending"
- `amount`, `currency`
- `gateway` (SDK init data)

**Example Response** (truncated):
```json
{
  "status": true,
  "message": "Booking initiated. Complete the payment to confirm.",
  "data": {
    "reference": "MOB-20260625120000-AB12CD34",
    "gateway": { "type": "stripe", "client_secret": "..." }
  }
}
```

---

### 5. Payment Success
**POST** `/payments/{gateway}/success`  
(gateway = stripe | paypal | flutterwave)

**Workflow**  
Server verifies payment → creates booking. Idempotent.

**Body**
- `reference` (required)
- `transaction_id` (required for flutterwave)

**Main Response Fields**
- Booking details (`id`, `booking_code`, `status`, etc.)

**Example Response** (truncated):
```json
{
  "status": true,
  "message": "Payment confirmed and booking created successfully.",
  "data": { "id": 812, "booking_code": "BK-20260625-ABCD12", ... }
}
```

---

### 6. Payment Cancel
**POST** `/payments/{gateway}/cancel`

**Workflow**  
Marks payment as cancelled (no booking created).

**Body**
- `reference`

**Example Response** (truncated):
```json
{
  "status": true,
  "message": "Payment was cancelled. Your booking was not created.",
  "data": { "reference": "...", "status": "cancelled" }
}
```

---

### Error Codes

| HTTP Code | When |
|-----------|------|
| 422       | Validation error, unsupported currency, pricing failure, payment verification failure |
| 404       | Vehicle not found or payment reference not found |
| 200       | Success |

### Mobile Developer Checklist
- Always send `Accept: application/json`.
- Use `Currency` header consistently.
- For airport transfer, collect coordinates before checkout.
- For self_drive, upload `driver_license` using multipart/form-data.
- Save the `reference` from POST /bookings.
- Use gateway data from /bookings for in-app SDK.
- After SDK success → call `/payments/{gateway}/success`.
- On user cancel → call `/payments/{gateway}/cancel`.

---