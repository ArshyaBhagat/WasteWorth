# WasteWorth ♻️

## Recyclable Waste Management Mobile Application

WasteWorth is a Flutter and Django-based recyclable waste management platform designed to simplify waste pickup scheduling, recycling awareness, and sustainable waste handling through a mobile application and backend management system.

The platform connects users, drivers, and administrators through an integrated system for managing waste collection requests, pickup tracking, recycling product information, billing, reports, and user management.

Drivers can independently accept pickup requests in real time. Once a driver accepts a pickup request, it is automatically removed from the availability list for other drivers, preventing duplicate pickup assignments and ensuring efficient request handling.

Drivers can also generate billing records for completed pickups, with transaction details visible to both users and administrators.

The backend implements token-based authentication and RESTful APIs for secure communication between the Flutter frontend and Django backend.

---

# 🚀 Features

* User authentication and account management
* Token-based secure authentication
* Waste pickup scheduling system
* Real-time driver pickup acceptance workflow
* Duplicate pickup prevention system
* Driver dashboard and management
* Pickup tracking and status updates
* Billing and transaction generation
* Recycling product information and rates
* Driver details management
* Reporting system for drivers to flag issues or problematic interactions
* Media upload support for pickup verification
* RESTful API integration between Flutter and Django
* Flutter mobile frontend integrated with Django REST Framework backend

---

# 🛠️ Technologies Used

## Frontend

* Flutter
* Dart

## Backend

* Python
* Django
* Django REST Framework (DRF)

## Database

* PostgreSQL

## Authentication

* Django REST Framework Token Authentication

## Development Tools

* Android Studio
* VS Code
* Git
* GitHub

## Libraries & Packages

* Django REST Framework
* python-dotenv
* Pillow
* psycopg2-binary

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
```

---

# ⚙️ Setup Instructions

## Backend Setup

```bash
cd backend

python -m venv venv

venv\Scripts\activate

pip install -r requirements.txt

python manage.py makemigrations

python manage.py migrate

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

* .env
* venv/
* uploaded media
* cache files

The application uses token-based authentication and permission-controlled API access for secure user interactions.

---

# 👩‍💻 Developer

**Arshya Bhagat**

Developed WasteWorth as a sustainability-focused academic project integrating Flutter mobile development, Django REST Framework, PostgreSQL, and RESTful APIs.

Responsible for backend development, API design, database management, authentication implementation, and Flutter-Django integration.

---

# 🌱 Vision

Using technology to encourage responsible waste management, recycling awareness, and sustainable environmental practices while improving operational efficiency in recyclable waste collection systems.
