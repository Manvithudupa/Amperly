# Amperly
### Smart Reservation and Management Platform for Existing EV Chargers

**Amperly** is an Android-first hyperlocal EV charger-management, route-planning, and reservation platform built in Java. It enables drivers to find compatible chargers along a journey, reserve charging slots, check in with QR codes, communicate securely with station Hosts, and pay transparently according to verified meter readings.

Google Maps helps you find a charger. **Amperly helps you reserve, access, use, and pay for it**—with route-aware charging plans projected directly onto the car display via Android Auto.

---

## 🌟 Key Product Architecture

Amperly operates as a software management layer for existing charging infrastructure in college campuses, apartment communities, offices, parking areas, and commercial sites.

```
┌─────────────────────────────────────────────────────────────┐
│                    Android Phone Application                │
│  Consumer UI | Host Dashboard | Admin Dashboard | Settings  │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               │ Shared authenticated APIs
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                  Amperly Backend Services                   │
│ Auth | Stations | Reservations | Routes | Billing | Safety  │
└───────────────┬──────────────────────┬──────────────────────┘
                │                      │
        ┌───────▼────────┐     ┌───────▼─────────┐
        │ Supabase Cloud │     │ Room Local DB   │
        │ PostgreSQL     │     │ Cache/Offline   │
        └────────────────┘     └─────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                     Android Auto Experience                 │
│ Route | Chargers | Detours | Reservation | Safe SoC Update  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Key Features & Capabilities

### 🚗 Consumer Experience (Phone & Android Auto)
- **Vehicle Profile Management:** Store vehicle make, model, variant, battery size (kWh), connector standard (Type 2 AC, CCS2 DC, GB/T), and efficiency parameters.
- **Route Corridor Charger Planner:** Search candidate chargers along journey corridors (e.g., Mysore to Mangalore) with detour distance (+km), detour time (+mins), estimated charging time, and expected arrival SoC %.
- **Authoritative Battery SoC Correction:** Amperly estimates battery drain during driving. If the actual dashboard SoC differs, the Consumer can enter the actual percentage at any time. This value becomes **authoritative**, recalculates remaining range, removes unreachable chargers, and highlights the nearest safe compatible stop.
- **Port Reservation & QR Check-In:** Reserve specific ports for time slots, receive a booking QR code, and authorize payment in sandbox mode.
- **Level 1/2 Verified Meter Billing:** Itemized bills separating Energy Charge (`Verified kWh * Tariff`), Amperly Service Fee, and Gateway Fee based strictly on start/end meter readings.
- **Active Session Safety & SOS:** Emergency alert trigger, local emergency guidance, and time-limited live location sharing with trusted contacts.
- **Masked Host Communication:** Reservation-scoped chat threads with phone number masking and off-platform payment detection warnings.

### 🏢 Host Experience
- **Charger Registration:** Register existing chargers with location, connector types, power ratings (kW), operating hours, and tariffs.
- **Availability Management:** Open/close ports, mark maintenance blocks, and approve upcoming reservations.
- **Meter Evidence Verification:** Enter or upload starting and ending meter readings with photograph evidence simulation.
- **Earnings & Utilization Analytics:** Real-time metrics on completed sessions, energy delivered (kWh), total revenue, and station utilization rates.

### 🛡️ Administrator Experience
- **Verification Queue:** Review and approve pending station listings and Host identity documentation.
- **Billing Disputes Desk:** Review meter evidence, resolve Consumer/Host disputes, and issue refunds.
- **Host Enforcement:** Issue policy warnings, fines, station suspensions, or bans for proven misconduct.

---

## 🛠️ Technology Stack

| Layer | Technology | Purpose |
|---|---|---|
| **Language** | Native Java | Android application and Android Auto service logic |
| **IDE** | Android Studio | Development, build system, and debugging |
| **Car UI** | Android for Cars App Library (`androidx.car.app:app`) | Driver-optimized glanceable car-display screens |
| **Local Persistence** | Room Database (`androidx.room:room-runtime`) | Fast local caching and offline-first state |
| **Cloud Backend** | Supabase PostgreSQL & PostgREST API | User auth, station listings, real-time reservations, and audit logs |
| **Networking** | Retrofit 2 & OkHttp 4 | REST API communication and Supabase integration |
| **Maps & Location** | Google Play Services Location & Maps SDK | GPS tracking, route corridors, and station navigation |
| **Payments** | Sandbox Payment Manager | Authorization, capture, fee separation, and idempotency protection |
| **Testing** | JUnit 4 & AndroidX Test | Automated unit testing for engines, security, and repositories |

---

## 📂 Project Package Structure (`com.amperly.app`)

```text
com.amperly.app/
├── AmperlyApplication.java
├── MainActivity.java
│
├── core/
│   ├── common/         # AppConstants, ValidationUtils
│   ├── location/       # LocationProvider
│   ├── security/       # AuthManager, RoleGuard
│   └── ui/             # Base UI abstractions
│
├── data/
│   ├── local/          # AmperlyDatabase, PilotDataSeeder
│   │   ├── dao/        # UserDao, VehicleDao, ChargerStationDao, ReservationDao, SessionDao, DisputeDao
│   │   └── entity/     # User, Vehicle, ChargerStation, ChargerPort, Reservation, ChargingSession, MeterReading, Invoice, Dispute, SafetyEvent, BatteryUpdate, ChatMessage, Report, HostEnforcementAction, Notification, TrustedContact
│   ├── remote/         # SupabaseClient, SupabaseApi
│   └── repository/     # AuthRepository, ChargerRepository, ReservationRepository, RouteRepository, SessionRepository, UserRepository, VehicleRepository
│
├── domain/
│   ├── model/          # Clean domain models
│   └── enums/          # UserRole, ReservationStatus, ConnectorType, ChargerStatus, MeterVerificationLevel
│
├── engine/
│   ├── billing/        # BillingEngine
│   ├── routing/        # RoutePlannerEngine, TripTimeEngine
│   └── soc/            # SoCEstimatorEngine
│
├── feature/
│   ├── consumer/       # ChargerDiscoveryFragment, RoutePlannerFragment, VehicleProfileFragment, ReservationFragment, ActiveSessionFragment, SafetySOSFragment, HostChatFragment, BookingQrFragment, ReceiptFragment
│   ├── host/           # HostDashboardFragment, RegisterStationFragment
│   └── admin/          # AdminDashboardFragment
│
├── car/
│   ├── AmperlyCarAppService.java
│   ├── AmperlyCarSession.java
│   ├── CarScreenFactory.java
│   └── screen/         # RouteOverviewCarScreen, ChargerListCarScreen, ChargerDetailsCarScreen, SoCUpdateCarScreen, ReservationStatusCarScreen
│
├── payment/            # PaymentManager
└── communication/      # ChatManager
```

---

## ⚡ How to Build & Run

### Prerequisites
- Android Studio Iguana / Jellyfish or newer.
- JDK 11+.
- Android SDK Platform 35 (Android 15) or Android SDK 34+.

### Build & Run Unit Tests
To execute the automated unit test suite (`EngineUnitTest`, `RoleGuardTest`, `PaymentManagerTest`, `ChatManagerTest`):

```bash
./gradlew testDebugUnitTest
```

### Assemble Debug APK
To compile and assemble the debug application package:

```bash
./gradlew assembleDebug
```

---

## 🧪 Demonstration Pilot Data

Amperly includes pre-populated pilot datasets in `PilotDataSeeder.java` covering two initial pilot scenarios:

1. **ABC College Campus Pilot:**
   - **Station:** ABC College Campus Charger (Port 1 Type 2 AC 7.2 kW @ ₹18/kWh, Port 2 CCS2 DC 30 kW @ ₹22/kWh).
   - **Users:** Students & Staff as Consumers; College Administration as Host/Admin.
2. **GreenPark Apartment Community Pilot:**
   - **Station:** GreenPark Shared Charger (Visitor Parking, Type 2 AC 7.2 kW @ ₹16/kWh).
   - **Users:** Residents as Consumers; Apartment Association as Host.

---

## 📄 License & Attribution

Amperly is developed as an open EV management platform.
