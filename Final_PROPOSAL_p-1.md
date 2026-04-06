# LuggEase — Smart Luggage Shifting & Transport App

> **Source:** Converted from `Final PROPOSAL p -1.docx` for easy reading in the repo. Use this when planning or implementing features.

---

## Particulars of the students

| Sr. # | Roll No   | Registration#   | Name          | Email                 |
| ----- | --------- | --------------- | ------------- | --------------------- |
| 1     | T22-120269 | 2022-GCUF-074477 | LAIBA MEHMOOD | laibmehmood14@gmail.com |
| 2     | T22-120267 | 2022-GCUF-074476 | RUKHMA ZAFAR  | asadbadsha9968@gmail.com |
| 3     | T22-120270 | 2022-GCUF-074478 | ALEENA AYAZ   | alinaayaz8890@gmail.com |

---

## Supervisor detail

| Field        | Value                |
| ------------ | -------------------- |
| Name         | Zeeshan Ali          |
| Designation  | Project supervisor   |
| Email        | Zeshansahi4u@gmail.com |
| Department   | IT Department        |

---

## Introduction

Shifting luggage or household items from one location to another is a common yet often complex and time-consuming task. Individuals frequently encounter challenges such as locating trustworthy drivers, ensuring fair and transparent pricing, and guaranteeing the safe handling and timely delivery of their belongings.

**LuggEase** is a comprehensive mobile application developed to address these challenges by streamlining the entire luggage relocation process. The platform connects customers with nearby verified drivers, provides real-time tracking for enhanced transparency, facilitates fair pricing through a bidding and negotiation mechanism, and supports secure digital payment options. By integrating these features into a single user-friendly solution, LuggEase significantly improves efficiency, reliability, and convenience in luggage and household item transportation.

---

## Problem statement

Shifting luggage or household items is often a stressful and time-consuming process due to the absence of reliable drivers, transparent pricing, effective communication, and real-time tracking. Currently, no unified platform exists that connects customers with verified drivers while offering features such as live tracking, price negotiation, and secure digital payments.

LuggEase addresses these challenges through a smart, user-friendly mobile application that enables customers to connect with trusted drivers, participate in a fair bidding process, track their deliveries in real time, and complete transactions safely online — making the entire shifting experience seamless, efficient, and dependable.

---

## Objectives

1. To provide customers with a reliable and user-friendly mobile platform for booking verified drivers for luggage shifting.
2. To ensure transparent and fair pricing through an integrated bidding and bargaining mechanism.
3. To offer real-time vehicle tracking to enhance safety, visibility, and timely delivery of luggage.
4. To facilitate secure online and cash payment methods with automated digital receipts.
5. To improve communication between customers and drivers using an in-app real-time chat system.
6. To verify drivers through a structured authentication process ensuring safety and service quality.
7. To enable drivers to receive consistent and verified job opportunities through the platform.
8. To support administrators in effectively managing users, verifying drivers, and monitoring system activities.
9. To create a scalable and efficient system that can easily expand to additional vehicles, services, and cities.
10. To provide a reliable feedback and rating mechanism for continuous improvement of service quality.

---

## Scope of the project

The scope of LuggEase encompasses the development of an intelligent mobile application designed to seamlessly connect customers with nearby verified drivers for luggage and household item shifting. The system features secure user authentication, real-time booking and live tracking, an integrated bidding and negotiation mechanism, digital payment capabilities, and a structured feedback and rating module.

This platform aims to deliver safe, transparent, and highly convenient transportation services for customers while empowering local drivers with a reliable digital channel to grow their business, receive fair job opportunities, and manage their rides efficiently.

---

## Proposed solution

LuggEase offers an intelligent and dependable mobile platform that seamlessly connects customers with nearby verified drivers through real-time location tracking. The application integrates key features such as bidding and negotiation for fair pricing, in-app messaging for effective communication, and secure payment options including online and cash transactions. The system ensures complete transparency, convenience, and safety throughout the entire luggage-shifting process — from initial booking to final delivery.

---

## Functional requirements

1. **User registration & authentication** — Customers and drivers can securely register and log in using email or phone number through Firebase Authentication. Safe password reset.
2. **Driver verification** — Drivers upload CNIC, driving license, and vehicle documents for administrative approval.
3. **Profile management** — Customers and drivers can update personal information, contact details, and profile pictures.
4. **Booking system** — Customers book rides by selecting pickup and drop-off via Google Maps; vehicle type: Loader, Van, or Truck.
5. **Real-time ride tracking** — Live tracking of driver location and trip status: Requested → Accepted → On the Way → Completed.
6. **Bidding & bargaining** — In-app chat for fare negotiation or bidding before confirming a booking.
7. **Payment system** — Google In-App Purchases or Cash on Delivery; automatic receipts.
8. **Smart notifications** — Push notifications for booking status, driver arrival, delivery.
9. **Feedback & rating** — Customers rate drivers, review, and submit complaints to admin.
10. **Admin dashboard & controls** — Driver verification, user management, ride history, payment tracking, feedback management.

---

## Non-functional requirements

1. **Performance** — Handle multiple simultaneous users/drivers; critical operations (login, booking, chat, payments) within a few seconds.
2. **Security** — Firebase security rules; robust encryption for passwords and payment data.
3. **Usability** — Intuitive, clearly labeled UI for all technical backgrounds.
4. **Reliability** — Stable operation; data integrity during network interruptions.
5. **Availability** — 24/7 access with minimal downtime.
6. **Scalability** — Support more users, vehicles, and cities without hurting performance.
7. **Maintainability** — Modular, documented code for updates and new features.
8. **Compatibility** — Android 8.0+; various screen sizes.
9. **Privacy** — Personal data confidential; no sharing without consent.
10. **Localization** — English and Urdu for Pakistani users.

---

## Major components / modules

### User & driver module

1. **Registration and authentication** — Firebase Authentication; email or phone login.
2. **Profile management** — Create/view/edit profiles; drivers upload license, CNIC, vehicle details for verification.

### Booking and ride module

1. **Booking creation** — Pickup/drop-off via Google Maps; vehicle type (Loader, Van, Truck).
2. **Ride tracking and status** — Real-time driver location; status flow Requested → Accepted → On the Way → Completed; notifications; drivers accept/reject nearby bookings.

### Bidding and bargaining module

1. **Bidding** — Customers propose fare; drivers view bids and accept or counter.
2. **Price negotiation** — Chat before booking confirmation.

### Payment module

1. **Payment options** — Google In-App Purchases and COD; secure processing.
2. **Payment confirmation** — Finalize on delivery confirmation; digital receipts; payment history.

### Notification and alert module

1. **Smart notifications** — Booking confirmations, driver arrival, trip start/end; emergencies (breakdown, delays).

### Feedback and rating module

1. **Driver review** — Rate and give feedback after delivery.
2. **Complaint reporting** — Report issues to administrators.

### Luggage module

1. **Luggage list** — Customers itemize goods; driver and customer verify list on delivery.

### History and fare estimation

- Estimated fare: **Distance × Rate/km × Vehicle type factor** (as per proposal).
- Booking and transaction history for users and drivers.

### Admin management module

1. **User and driver verification** — Approve/suspend accounts.
2. **Booking and payment oversight** — Monitor bookings, payments, feedback, system activity.

---

## Expected outcomes

A fully functional mobile app that streamlines luggage shifting by connecting customers with verified drivers, with real-time tracking, secure payments, and bidding/negotiation for fair pricing — improving convenience for customers and giving drivers a digital channel to grow their business.

---

## Tools and technologies

| Area                 | Technology                          |
| -------------------- | ----------------------------------- |
| Frontend             | Flutter                             |
| Backend              | Firebase                            |
| Storage              | Firebase Storage                    |
| Payments             | Google In-App Purchases API         |
| Maps & location      | Google Maps API, Geolocator         |
| IDE                  | Visual Studio Code                  |

---

## Gantt chart (6-month timeline)

Legend: **●** = active work in that month (from original chart blocks).

| Phase | Task | M1 | M2 | M3 | M4 | M5 | M6 |
| ----- | ---- | -- | -- | -- | -- | -- | -- |
| **1. Requirement analysis & planning** | Gather user requirements | ● | | | | | |
| | Define system specifications | ● | ● | | | | |
| | Create project roadmap & architecture | ● | ● | | | | |
| **2. UI/UX design** | Wireframing & mockups | ● | ● | | | | |
| | UI/UX design approval | | ● | | | | |
| **3. Backend development** | Database setup | ● | ● | | | | |
| | API development & integration | | ● | ● | | | |
| | Real-time tracking module | | ● | ● | | | |
| **4. Frontend development** | Mobile app (iOS & Android) | | | ● | ● | ● | |
| | Integration with backend | | | | ● | ● | |
| **5. Payment & bidding** | Payment gateway integration | | | ● | ● | | |
| | Bidding & negotiation feature | | | ● | ● | | |
| **6. Testing & QA** | Unit & integration testing | | | | ● | ● | |
| | User acceptance testing (UAT) | | | | ● | ● | |
| **7. Deployment & launch** | Beta release | | | | | ● | |
| | Final release | | | | | | ● |
| **8. Post-launch support** | Feedback & bug fixes | | | | | ● | |

---

## Approval status (examiner — original form)

- **Approved:** Yes / No / Conditionally accepted  
- **Remarks:** _(as filled by examiner)_
