# Booking lifecycle + routes — manual test cases

Yeh checklist **`booking_lifecycle_and_routes`** plan ke mutabiq hai: **pending → driver list → accept → customer stream → routes**.

---

## Pehle tayari (prerequisites)

| Cheez | Detail |
|--------|--------|
| **Build** | `flutter run` — 2 devices ya 1 device + emulator (customer ek, driver ek). |
| **Accounts** | Firebase par **2 alag users**: ek **customer**, ek **driver** (dono sign-in ho saken). |
| **Firestore** | Composite index deploy ho chuka ho: `bookings` → `status` (ASC) + `createdAt` (DESC). Agar Ride Requests screen error de to Console se index link follow karo. |
| **Console** | [Firebase Console](https://console.firebase.google.com) → Firestore → `bookings` collection — docs verify karne ke liye. |

---

## Test cases (numbered)

Har case mein **Steps** follow karo, **Expected** se match karo. Pass/Fail likh lo.

### TC-01 — Nayi booking `pending` se create hoti hai

| Field | Value |
|--------|--------|
| **Precondition** | Customer logged in. |
| **Steps** | 1. Customer: **Book ride** screen kholo.<br>2. Pickup, drop, vehicle, price/items bhar kar booking submit karo. |
| **Expected (app)** | “Waiting for a driver…” jaisa waiting UI dikhe; **koi 4 second baad auto-accept nahi** hona chahiye. |
| **Expected (Firestore)** | `bookings/{bookingId}` doc mein **`status: "pending"`** ( **`searching` nahi** naye flow ke liye). |

---

### TC-02 — Driver ko request list mein dikhti hai

| Field | Value |
|--------|--------|
| **Precondition** | TC-01 ke baad booking open ho; driver logged in (alag device/session). |
| **Steps** | 1. Driver: **Ride Requests** kholo (`/ride-requests`). |
| **Expected** | Abhi create hui booking **list mein dikhe** (pickup/drop/price waghera). |
| **Note** | Agar purani docs `searching` par hon to bhi list mein aani chahiye (**`whereIn` legacy**). |

---

### TC-03 — Accept → Firestore `accepted` + `driverId`

| Field | Value |
|--------|--------|
| **Precondition** | TC-02 — booking list mein visible. |
| **Steps** | 1. Driver: us booking par **Accept** dabao. |
| **Expected (Firestore)** | Usi doc par **`status: "accepted"`** aur **`driverId`** = driver ka **uid**. |
| **Expected (app)** | Driver ko tracking screen open ho sakti hai / snackbar success. |

---

### TC-04 — Customer UI **bina fake timer** update hota hai

| Field | Value |
|--------|--------|
| **Precondition** | TC-01 customer screen par waiting ho **ya** same booking par wapas aao; TC-03 parallel/alag device par driver accept kare. |
| **Steps** | 1. Customer: book ride flow par waiting rakho **ya** stream active rakho.<br>2. Driver accept kare (TC-03). |
| **Expected** | Kuch **seconds** mein (network + Firestore latency) customer side **driver assigned** UI dikhe — **sirf tab jab Firestore accept ho**, fixed 4s delay par nahi. |
| **Expected** | Driver ka naam / vehicle **Firestore `drivers/{driverId}`** se aaye (agar profile mein hai); photo na ho to **icon**, fake pravatar URL nahi. |

---

### TC-05 — Map par fake movement nahi

| Field | Value |
|--------|--------|
| **Precondition** | Accepted booking; `driverLat`/`driverLng` abhi **set na hon** (default out-of-scope). |
| **Steps** | 1. Customer book ride / tracking screen par 30–60 sec dekho. |
| **Expected** | **Timer se marker hilta hua nahi** dikhna chahiye. Sirf Firestore coords hon to marker / camera update. |

---

### TC-06 — Customer cancel (pending / searching)

| Field | Value |
|--------|--------|
| **Precondition** | Booking `pending` (waiting UI). |
| **Steps** | 1. **Cancel request** dabao (ya back flow jahan cancel server hit karta ho). |
| **Expected (Firestore)** | Doc **`status: "cancelled"`** (ya jo app set karta ho). |
| **Expected (app)** | Wapas form / idle state; driver list se gayab ho jana chahiye (open queries ke hisaab se). |

---

### TC-07 — Stale accept (do drivers / purana card)

| Field | Value |
|--------|--------|
| **Precondition** | Ek booking pehle se **accepted** ho chuki ho. |
| **Steps** | 1. Doosre driver device par **purani list refresh** karke (agar card dikhe) Accept try karo — ya same booking dobara accept. |
| **Expected** | **SnackBar**: request available nahi / error; Firestore mein **pehle wala `driverId` overwrite na ho** ideally (client guard + rules). |

---

### TC-08 — Payment → Tracking route (dead `/track-ride` nahi)

| Field | Value |
|--------|--------|
| **Precondition** | `BookingModel` ke sath payment screen open ho (app flow jahan `extra` booking pass hoti ho). |
| **Steps** | 1. **Proceed to Pay** (ya equivalent) dabao. |
| **Expected** | **`/tracking`** route open ho (**`AppRoutes.tracking`**), screen **“No active booking”** ya map **nahi** ke `/track-ride` 404/dead route. |

---

### TC-09 — Tracking se Chat

| Field | Value |
|--------|--------|
| **Precondition** | Koi **valid `bookingId`** wali tracking screen. |
| **Steps** | 1. Tracking par **chat** icon dabao. |
| **Expected** | **`/chat-rooms`** open ho; chat ko **`bookingId`** mile; receiver name **driver profile** se ya generic **“Driver”** — empty booking id ke sath chat na khule. |

---

### TC-10 — Driver dashboard routes

| Field | Value |
|--------|--------|
| **Precondition** | Driver logged in. |
| **Steps** | 1. Quick action **Profile** → verify route.<br>2. Quick action **Chats** → verify. |
| **Expected** | Profile = **driver profile** (`/driver-profile`), customer `/profile` nahi.<br>Chats = **Ride requests** (real list), fake chat id ke bina. |

---

### TC-11 — Customer dashboard — fake “assigned driver” simulation nahi

| Field | Value |
|--------|--------|
| **Precondition** | Customer dashboard. |
| **Steps** | 1. **Confirm Ride** — sirf **Book ride** screen khulni chahiye.<br>2. 5 second wait — **map par fake drivers / auto-assign nahi** hona chahiye. |

---

### TC-12 — Legacy `searching` doc (agar manually banaya ho)

| Field | Value |
|--------|--------|
| **Precondition** | Console se kisi doc ka `status` **`searching`** set karo (test only). |
| **Steps** | 1. Driver Ride Requests refresh. |
| **Expected** | Woh doc **list mein dikhe**; accept karne par **`accepted`** ho jaye. |

---

## Driver GPS, status transitions, cancel audit (post–booking-lifecycle)

### TC-13 — Customer cancel → audit fields

| Field | Value |
|--------|--------|
| **Precondition** | Open **`pending`** request (waiting UI) ya assigned flow. |
| **Steps** | 1. Customer: **Cancel request** / cancel after assign (jo app allow karta ho). |
| **Expected (Firestore)** | Doc **`status: cancelled`** + **`cancelledBy`** = customer **uid** + **`cancelReason`** string + **`cancelledAt`** timestamp. |

---

### TC-14 — Driver status: accepted → onTheWay → arrived

| Field | Value |
|--------|--------|
| **Precondition** | Driver ne accept kiya; **tracking** screen open (same booking). |
| **Steps** | 1. **En route to pickup** dabao.<br>2. **Arrived at pickup** dabao. |
| **Expected (Firestore)** | Pehle **`onTheWay`**, phir **`arrived`**. |
| **Expected (customer)** | Doosre device par stream se status / progress bar update. |

---

### TC-15 — COMPLETE DELIVERY sirf `arrived` ke baad (driver)

| Field | Value |
|--------|--------|
| **Precondition** | TC-14 ke baad **`arrived`**. |
| **Steps** | 1. **COMPLETE DELIVERY** dabao → camera flow complete karo. |
| **Expected** | **`completed`** + `deliveryProofUrl` / `completedAt` (pehle se delivery screen). |

---

### TC-16 — Driver GPS fields

| Field | Value |
|--------|--------|
| **Precondition** | Driver tracking par hai; **`accepted`** (ya onTheWay/arrived); device **location ON**. |
| **Steps** | 1. Thoda move karo / 10–30s wait.<br>2. Console mein doc dekho. |
| **Expected (Firestore)** | **`driverLat`**, **`driverLng`**, **`locationUpdatedAt`** update hon (throttle ~8s + ~40m movement). |
| **Expected (customer)** | Tracking map par marker jab coords hon. |

---

### TC-17 — Firestore rules (GPS spoof)

| Field | Value |
|--------|--------|
| **Precondition** | Customer account + kisi **accepted** booking jiska customer ho. |
| **Steps** | 1. Console / custom client se customer uid se **`driverLat`** change try karo (security test). |
| **Expected** | **Permission denied** (sirf **`driverId`** GPS fields change kar sakta hai). **`firebase deploy --only firestore:rules`** ke baad verify karo. |

---

## Regression — `flutter analyze` / smoke

```bash
cd <project-root>
flutter analyze
flutter run
```

---

## Automated tests (optional next step)

Abhi zyada tar flow **Firebase + UI** par depend karta hai. Automated ke liye:

- **Unit**: `BookingModel.fromMap` / status enum parsing (already testable without Firebase).
- **Integration**: `integration_test/` + Firebase **test project** + `fake_cloud_firestore` (zyaada setup).

Pehle **upar wale manual TC** pass karo; phir jo flow sab se zyada break hota ho us par unit test likhna behtar ROI hai.

---

## Quick matrix (plan §6 se)

| Plan checklist item | Test case |
|---------------------|-----------|
| Customer book → `pending` | TC-01 |
| Driver list → Accept → `accepted` + `driverId` | TC-02, TC-03 |
| Customer UI stream, no fake timer | TC-04, TC-05 |
| Payment → tracking | TC-08 |
| Tracking → chat + `bookingId` | TC-09 |
| Driver profile route | TC-10 |
| Cancel audit / GPS / driver status | TC-13–TC-17 |

---

*End of manual test cases.*
