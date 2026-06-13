https://jkworldsserviceslimited.nexcoreit4u.com/api/register

Request:
name: string
email: string
password: string
password_confirmation: string

Success Response:
{
    "status": true,
    "message": "User registered successfully.",
    "data": {
        "token": "4|cQCOpxgzLPsYOUIVXGvCha3tQnVcJtGxhKE6LkzR1a9a5022",
        "user": {
            "name": "rabin",
            "email": "rabin43@gmail.com",
            "user_code": 99343,
            "username": "rabin-964",
            "email_verified_at": "2026-06-13T12:57:01.000000Z",
            "onboarding_completed": false,
            "status": "active",
            "updated_at": "2026-06-13T12:57:01.000000Z",
            "created_at": "2026-06-13T12:57:01.000000Z",
            "id": 38
        }
    }
}

{{base_url}}/api/login

Request:
email: string
password: string

Response:
{
    "status": true,
    "message": "Login successful.",
    "data": {
        "token": "5|b8cqq00Sl25YOenjKXhggA0Ny2uRxLLYSpSH46IJc7d0578d",
        "user": {
            "id": 38,
            "user_code": "99343",
            "username": "rabin-964",
            "name": "rabin",
            "email": "rabin43@gmail.com",
            "email_verified_at": "2026-06-13T12:57:01.000000Z",
            "role": "customer",
            "image": "backend/image/default-user.png",
            "status": "active",
            "onboarding_completed": false,
            "preferred_language": null,
            "preferred_country": null,
            "preferred_currency": null,
            "preferred_timezone": null,
            "preferred_service": null,
            "location_latitude": null,
            "location_longitude": null,
            "country_code": null,
            "phone": null,
            "date_of_birth": null,
            "address": null,
            "city": null,
            "country": null,
            "license_number": null,
            "license_expiry": null,
            "created_at": "2026-06-13T12:57:01.000000Z",
            "updated_at": "2026-06-13T12:57:01.000000Z",
            "google_id": null,
            "apple_id": null
        }
    }
}

{{base_url}}/api/refresh-token

Response:
{
    "status": true,
    "message": "Token refreshed successfully.",
    "data": {
        "token": "6|SNbGHANmnlRjEw6GtIvMbe2Cvyi7OVfwQpqHMwgL8a27b888"
    }
}