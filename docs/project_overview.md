1. Project Overview
A Premium Car Rental Mobile Application for the Nigerian market, built with Flutter (iOS + Android). The app serves both local Nigerian renters and international travelers, offering a seamless, high-end booking experience with robust backend support.


2. Tech Stack
Mobile

Framework: Flutter (Dart) — single codebase for Android & iOS
State Management: Getx
Navigation: GetX Navigation
Networking: Dio with interceptors
Local Storage: Shared Pref
Architecture: GetX

3. Payments

Gateways: Paystack, Flutterwave (Nigerian-first), Stripe, PayPal
Pricing Models: Daily / Weekly / Monthly rates

4. Design System

Target Platform: iOS (Human Interface Guidelines), Android (Material Design)
UI Style: Modern, premium, clutter-free
Accessibility: Dynamic type support, contrast ratios

3. Core Mobile App Features
3.1 Authentication & Onboarding

 Secure email/password registration & login
 Social login — Google, Apple, Facebook (OAuth2)
 International traveler-friendly onboarding flow
 KYC verification — Driver's license upload, National ID, Passport
 ID document OCR + manual review fallback
 Biometric login (Face ID / Fingerprint) post-authentication

3.2 Vehicle Discovery & Search

 Advanced search with filters:

Vehicle type (Sedan, SUV, Luxury, Van, etc.)
Price range (NGN / USD / GBP)
Availability dates
Self-drive vs. Chauffeur option
Transmission, seats, features


 Real-time availability calendar
 Vehicle detail pages (photo gallery, specs, reviews, pricing breakdown)
 Featured / Promoted vehicles section
 Saved/Wishlisted vehicles

3.3 Booking Engine

 Instant booking (confirm immediately)
 Request-to-book (host approval required)
 Daily, weekly, and monthly pricing models
 Self-drive rental flow
 Chauffeur/driver rental flow
 Airport pickup & drop-off booking
 Pickup location selection
 Booking summary with full price breakdown (rental + fees + deposit)
 Security deposit / payment hold management

3.4 Payments

 Multi-currency support: NGN, USD, GBP, EUR
 Integrated gateways: Paystack, Flutterwave, Stripe, PayPal
 Saved payment methods (card tokenization)
 Invoice / receipt generation
 Refund management workflow
 Security deposit authorization & auto-release

3.5 Customer Profile & Dashboard

 Profile management (photo, contact info, preferences)
 Booking history (upcoming, active, past, cancelled)
 Saved payment methods
 Uploaded KYC documents & verification status
 Loyalty/points balance & rewards history
 Referral code & program tracking
 Promo codes & discounts wallet

3.6 In-Trip Features

 Active booking tracker
 Damage reporting / incident submission (photo upload + description)
 Emergency contact / roadside assistance quick-dial
 Return confirmation flow

3.7 Notifications & Communication

 In-app chat / customer support (using api integration in message screen load in every 5 seconds) use push notification when get a message.
 Notification preferences management (Turn off or on any notification)

3.8 Reviews & Ratings

 Post-trip vehicle reviews & star ratings
 Driver/chauffeur ratings
 Points accumulation system (per booking, review, referral)
 Review display on vehicle & driver profiles

3.9 Loyalty, Referrals & Promotions

 Points accumulation & redemption system
 Referral program (unique referral codes, reward tracking)
 Promo codes (single-use, multi-use, expiry-based)
 Discount management (seasonal, fleet-specific, user-tier)


 Language should be Engilsh, Yorùbá, Hausa, Igbo