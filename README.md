# WasteWorth ♻️

## Recyclable Waste Management Mobile Application

WasteWorth is a Flutter + Django based recyclable waste management platform designed to simplify waste pickup scheduling, recycling awareness, and sustainable waste handling through a mobile application and backend management system.

The platform connects users, drivers, and administrators through an integrated system for managing waste collection requests, pickup tracking, recycling product information, billing, and reports.

Drivers can independently accept pickup requests in real time. Once a driver accepts a pickup request, it is automatically removed from the availability list for other drivers, preventing duplicate pickup assignments and ensuring efficient request handling.

Drivers can also generate billing records for completed pickups, with transaction details visible to both users and administrators.

The backend implements JWT-based authentication for secure API communication between the Flutter frontend and Django backend.

---

# 🚀 Features

- User authentication and account management
- JWT-based secure authentication
- Waste pickup scheduling system
- Real-time driver pickup acceptance workflow
- Duplicate pickup prevention system
- Driver dashboard and management
- Pickup tracking and status updates
- Billing and transaction generation
- Recycling product information and rates
- Admin panel and database monitoring
- Reporting system for drivers to flag issues or problematic interactions
- Media upload support for pickup verification
- Flutter mobile frontend integrated with Django REST backend

---

# 🛠️ Technologies Used

## Frontend
- Flutter
- Dart

## Backend
- Python
- Django
- Django REST Framework

## Database
- PostgreSQL

## Development Tools
- Android Studio
- VS Code

## Libraries & Packages
- JWT Authentication
- python-dotenv
- Pillow

---

# 📂 Project Structure

```plaintext
wasteworth_app/
│
├── backend/               # Django backend
├── lib/                   # Flutter frontend source code
├── assets/                # Images and videos
├── android/               # Android configuration
├── ios/                   # iOS configuration
├── web/                   # Web support
├── windows/               # Windows support
├── linux/                 # Linux support
└── macos/                 # macOS support
````

---

# ⚙️ Setup Instructions

## Backend Setup

```bash
cd backend

python -m venv venv

venv\Scripts\activate

pip install -r requirements.txt

python manage.py runserver
```

---

## Frontend Setup

```bash
flutter pub get

flutter run
```

---

# 🔐 Security

Sensitive files and local environment configurations are excluded using `.gitignore`.

Examples:

* `.env`
* `venv/`
* uploaded media
* cache files

The application also uses JWT authentication for protected API routes and secure user access.

---

# 👩‍💻 Developer

Arshya Bhagat

Developed as a sustainability-focused academic and practical application integrating Flutter mobile development with Django backend technologies.

---

# 🌱 Vision

Using technology to encourage responsible waste management, recycling awareness, and sustainable environmental practices while improving operational efficiency in recyclable waste collection systems.