# Customer ↔ driver location, distance, aur live tracking — poori story (design notes)

Yeh document **implement karne se pehle** samajhne ke liye hai: customer **gaari (vehicle) select** karta hai, **driver** customer ki **location / offer** dekh kar **accept** karta hai, map par **kya dikhega**, **distance** kaise niklegi, **live tracking** ka flow **kis layer** par chalega, aur **Firebase / Firestore** mein data **kahan** rahega. Code snippets zaroori nahi — sirf **flow aur faislay**.

---

## 1. Tumhari requirement ko alag hisson mein baanto

Teen alag “scenes” hain jo mix na hon to behtar samajh aati hai:

| Scene | Maqsad | Kis ko dikhta hai |
|--------|--------|-------------------|
| **A — Discovery** | Customer dekh sake **aas paas kaun driver online** hai (optional product) | Customer map |
| **B — Booking** | Customer **vehicle + pickup + drop + price** bheje; **open request** ban jaye | Driver list + Firestore `bookings` |
| **C — Active trip** | Jab driver **accept** kar chuka ho, **live** position aur status | Dono — tracking screen, `bookings` doc |

Tumhari baat zyada tar **B + C** se match karti hai: driver **customer ki location** dekh kar **offer accept** kare. **A** alag feature hai (“nearby drivers pool”) — uska design `driver_presence` jaisi cheez se hota hai; **B/C** pehle se `bookings` + tracking se handle ho rahe hain.

---

## 2. Packages (maps + location) — kis package se kya hoga

Project mein pehle se yeh stack use ho raha hai / use hoga:

| Zaroorat | Package / tech | Kaam |
|----------|----------------|------|
| **Map UI** (tiles, markers, camera) | **Google Maps Flutter** (`google_maps_flutter`) + **Google Maps SDK** (Android/iOS API keys) | Customer dashboard, book ride, live tracking — **markers** pickup/drop/driver ke liye |
| **Device GPS** (lat/lng) | **Geolocator** | User ki **current location**, aur driver ki **live** position stream jab trip active ho ya jab driver “online” ho |
| **Optional: OSM** | `flutter_map` + tile URL | Abhi proposal / repo default **Google** hai; OSM sirf **tile provider** badalta hai — **distance / Firestore logic same** rehta hai |

**Important:** Map package **sirf dikhata** hai. **Asli sach** Firestore (ya backend) par hota hai: **numbers** `lat` / `lng` / `address text`.

---

## 3. Customer flow: gaari select → request → driver accept

### 3.1 Customer side

1. Customer **vehicle type** select karta hai (Loader / Van / Truck — jo UI mein hai).
2. **Pickup** aur **drop** abhi zyada tar **text address** hain; ideal proposal ke mutabiq **Google Maps se point pick** karna — tab **pickupLat, pickupLng, dropLat, dropLng** `bookings` doc mein save ho sakte hain.
3. Customer **price / items** bhejta hai → app **ek naya `bookings` document** banata hai: `status: pending`, `customerId`, `vehicleType`, `pickupLocation`, `dropLocation`, `price`, `items`, `createdAt`, waghera.

### 3.2 Customer location driver ko “dikhana”

Do tareeqay (product choose kare):

- **Tariqa 1 — Sirf text:** Driver **Ride Requests** list mein **pickup address** string padhta hai. Map par **pin nahi** jab tak tum **lat/lng save na karo**.
- **Tariqa 2 — Map par pin (behtar):** Jab booking create ho, customer ke **current GPS** (Geolocator) ya map picker se **pickup coordinates** Firestore mein save karo. Driver app **usi booking** ko khol kar map par **ek marker** dikhaye — yeh **customer pickup** hai, “customer ki location” is sense mein.

**Accept** ke baad `driverId` set hota hai; tab se **trip tracking** `bookings` doc par chalti hai.

---

## 4. Driver flow: offer accept karna

1. Driver **Ride Requests** screen par **query** karta hai: `status` in (`pending`, `searching`) — tumhare repo jaisa.
2. Har card par **pickup/drop text** (+ agar coordinates hon to map).
3. **Accept** dabane par Firestore **update:** `status → accepted`, `driverId → driver ka uid`.
4. Customer side **`watchBooking`** (stream) se UI update — **fake timer nahi**.

Yahan **distance calculate karne ki zaroorat accept karne ke liye zaroori nahi** — driver dekh kar accept karta hai. Distance **fare estimate** ya **ETA** ke liye alag use hoti hai.

---

## 5. Distance: “from location” se destination tak kaise?

**Formula:** Zameen par do points ke darmiyan **straight-line** distance **Haversine** se (lat/lng se kilometers). **Road distance** alag cheez hai — uske liye **Google Directions API** (ya OSRM) — extra API key / billing / network.

**Kab use karo:**

- **Fare estimation (proposal):** `Distance × rate/km × vehicle factor` — yahan **road distance** ya **straight-line** product decision; MVP par aksar **Haversine × correction factor** ya sirf **Directions API** agar budget ho.
- **UI “kitna door”:** list mein **approx km** dikhane ke liye Haversine kaafi.
- **Live ETA “8 min”:** tab **Directions** + traffic API ya rough speed assumption — abhi app mein **fake ETA hata diya** gaya tha; real ETA = **alag integration**.

**Data chahiye:** dono taraf **lat/lng**. Agar sirf **string address** hai to pehle **geocoding** (Google Geocoding ya Places) se coordinates nikalne padenge — woh bhi **API** step hai.

---

## 6. Live tracking ka poora scene (kis tareeqe se manage karna hai)

### 6.1 Single source of truth: `bookings/{bookingId}`

Active trip ke doran **yehi doc** “contract” hai:

- **Status:** `accepted` → `onTheWay` → `arrived` → … → `completed` / `cancelled`
- **Driver live position (trip ke doran):** `driverLat`, `driverLng`, `locationUpdatedAt` — driver app **Geolocator stream** se **throttle / distanceFilter** ke sath **update** kare (jaise ab live tracking screen par hai).
- **Customer** same doc par **`snapshots()`** sun kar map marker move karta hai — **koi local fake movement nahi**.

### 6.2 Kon kab kya likhta hai

| Kaun | Kya likhta hai |
|------|----------------|
| Customer | Naya booking create, cancel metadata, (optional) pickup coords |
| Driver | Accept → `driverId` + status; trip mein **GPS** → `driverLat`/`driverLng`; status buttons se **onTheWay** / **arrived**; delivery proof ke baad **completed** |
| Rules | Sirf **assigned driver** ko booking par GPS fields change karne do (tumhare rules jaisa guard) |

### 6.3 Screens ka role

- **Book ride / customer:** waiting + assigned driver info + optional chhota map agar coords hon.
- **Live tracking:** dono roles map dekh sakte hain; **driver** ko **status buttons** + **GPS publish**; **customer** ko **read-only** marker + chat/call.
- **Discovery map (aas paas drivers):** alag collection **`driver_presence`** — **trip se pehle** “kaun online hai”; yeh **booking** se alag flow hai taake **PII** (`drivers` full profile) sab customers ko na khule.

---

## 7. Firebase / Firestore — data kahan kya rakho (summary)

| Collection / doc | Role |
|------------------|------|
| **`bookings/{id}`** | Poori ride lifecycle: customer/driver ids, status, pickup/drop (text + optional lat/lng), **trip GPS** `driverLat`/`driverLng`, cancel fields, delivery proof URL, etc. |
| **`drivers/{uid}`** | Profile: naam, phone, vehicle — **read restricted** (own doc) taake privacy rahe |
| **`driver_presence/{uid}`** (agar “nearby online drivers” feature ho) | Sirf **public-safe** fields: online flag, lat/lng, updatedAt, maybe vehicle type — **customers read** kar saken |
| **`customers/{uid}`** | Customer profile — own read/write |
| **Realtime updates** | Firestore **`snapshots()`** streams — **extra Firebase Realtime DB zaroori nahi** is flow ke liye |

**Security:** Har nayi public-readable cheez par socho: kya **email/CNIC** leak ho sakta hai? Agar haan to **alag chhota doc** behtar hai.

---

## 8. Implementation steps (high level, koi code block nahi)

1. **Booking model + create:** Pickup/drop ke liye **optional `pickupLat`/`pickupLng`/`dropLat`/`dropLng`** add karo agar map par customer pickup/drop dikhani ho; book karte waqt Geolocator ya map picker se bharo.
2. **Driver requests UI:** Card par map widget jisme **pickup marker** ho agar coords hon; warna sirf text.
3. **Accept / status / GPS:** Pehle se jo **live tracking + BookingService** flow hai usko maintain karo; rules deploy karo taake GPS spoof na ho.
4. **Distance (optional phase):** Fare screen par Haversine do saved points ke beech; baad mein Directions API agar “road km” chahiye.
5. **Nearby online drivers (optional alag phase):** `driver_presence` + rules + driver dashboard **online** toggle + customer dashboard markers — is document ke **Section 1 Scene A** ke mutabiq.
6. **Testing:** Do devices — book → accept → driver move → customer map update; cancel par audit fields; offline driver par presence doc hide/stale.

---

## 9. Seedhi baat — tumhari line ka jawab

- **“Customer jo gaari select karega”** → `bookings` mein **`vehicleType`** + baqi booking fields.
- **“Driver customer location dekh kar accept”** → **pickup** `bookings` se: **text** abhi; **map pin** jab **`pickupLat`/`pickupLng`** save karo.
- **“Map par kis package se”** → **`google_maps_flutter`** (markers + camera); position **`Geolocator`** / Firestore se.
- **“Distance kaise”** → do **lat/lng** par **Haversine** (simple); road distance = **Directions API** (alag step).
- **“Live tracking manage”** → **ek Firestore booking doc**, driver **writes GPS**, customer **streams**; status **driver buttons** se; **no dummy timers**.

---

## 10. Is file aur baaki docs ka rishta

- **[Final_PROPOSAL_p-1.md](../Final_PROPOSAL_p-1.md)** — FR-4, FR-5, “nearby drivers”, real-time tracking — upar wala flow unhi se align hai.
- **[REMAINING_WORK.md](../REMAINING_WORK.md)** — kya ho chuka, kya baqi — is story ke hisaab se pickup coordinates / fare distance / `driver_presence` wale items wahan track karo.
- **Cursor plan `driver_online_presence_map`** — Scene **A** (pool map) implement karta hai; yeh **.md** poori **A+B+C** picture deta hai taake implement karte waqt confuse na ho.

---

*Document version: initial story for location + tracking + Firestore. Code snippets intentionally omitted.*
