# WasteWorth ♻️

## Recyclable Waste Management Mobile Application

WasteWorth is a Flutter and Django-based recyclable waste management platform developed to simplify waste pickup scheduling, recycling awareness, and sustainable waste handling.

The platform connects users, drivers, and administrators through an integrated system for managing waste collection requests, pickup tracking, driver assignment, billing generation, reporting, and recycling product information.

Drivers can independently accept pickup requests in real time. Once a pickup request is accepted, it is removed from the available pickup list to prevent duplicate assignments and ensure efficient waste collection management.

The application combines a Flutter mobile frontend with a Django REST Framework backend and PostgreSQL database.

---

# ✨ Features

- User registration and login system
- Token-based authentication
- User profile management
- Driver profile and vehicle management
- Waste pickup scheduling
- Driver pickup acceptance workflow
- Available pickup management
- Pickup status tracking
- Duplicate pickup prevention
- Billing and transaction generation
- Recycling product rates management
- Driver reporting system
- Forgot password functionality
- Media upload support for pickup verification
- REST API-based communication
- Flutter mobile application integration
- PostgreSQL database management

---

# 🛠️ Technologies Used

## Frontend

- Flutter
- Dart

## Backend

- Python
- Django
- Django REST Framework (DRF)

## Database

- PostgreSQL

## Authentication

- Token Authentication

## Development Tools

- Android Studio
- VS Code

## Libraries & Packages

- djangorestframework
- psycopg2-binary
- Pillow
- python-dotenv

---

# 📂 Project Structure

```plaintext
WasteWorth_App/
│
├── android/
├── ios/
├── linux/
├── macos/
├── web/
├── windows/
│
├── assets/
│   ├── images/
│   └── videos/
│
├── backend/
│   │
│   ├── core/
│   │   ├── migrations/
│   │   ├── management/
│   │   ├── models.py
│   │   ├── serializers.py
│   │   ├── urls.py
│   │   ├── views.py
│   │   ├── views_forgot_password.py
│   │   └── admin.py
│   │
│   ├── wasteworth_backend/
│   │   ├── settings.py
│   │   ├── urls.py
│   │   ├── asgi.py
│   │   └── wsgi.py
│   │
│   ├── media/
│   ├── pickup_photos/
│   ├── manage.py
│   ├── requirements.txt
│   └── .env
│
├── lib/
│   ├── main.dart
│   ├── api_service.dart
│   ├── login_page.dart
│   ├── signup_page.dart
│   ├── home_page.dart
│   ├── welcome_page.dart
│   ├── pickups_page.dart
│   ├── schedule_pickup_page.dart
│   ├── product_rates_page.dart
│   ├── user_page.dart
│   ├── user_profile_page.dart
│   ├── driver_page.dart
│   ├── driver_pickups_page.dart
│   ├── driver_profile_page.dart
│   ├── admin_panel.dart
│   ├── account_settings_page.dart
│   ├── forgot_password_page.dart
│   ├── help_support_page.dart
│   └── additional application screens
│
├── test/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

---

# 🚀 How to Run the Project

## Clone Repository

```bash
git clone https://github.com/ArshyaBhagat/WasteWorth.git
cd WasteWorth
```

---

## Backend Setup

### Create Virtual Environment

```bash
python -m venv venv
```

### Activate Virtual Environment

```bash
venv\Scripts\activate
```

### Install Dependencies

```bash
pip install -r requirements.txt
```

### Configure Environment Variables

Create `.env` file:

```env
SECRET_KEY=your_secret_key
DB_PASSWORD=your_database_password
```

### Apply Migrations

```bash
python manage.py migrate
```

### Run Backend Server

```bash
python manage.py runserver
```

---

## Frontend Setup

Install Flutter packages:

```bash
flutter pub get
```

Run application:

```bash
flutter run
```

---

# 🔐 Security

Sensitive configuration files and local development data are excluded using `.gitignore`.

Examples:

- .env
- venv/
- uploaded media files
- cache files

The application uses Token Authentication for protected API access and authenticated user operations.

---

# 👩‍💻 Developer

**Arshya Bhagat**

Developed a full-stack recyclable waste management platform integrating Flutter mobile development with Django REST Framework backend technologies.

Responsible for backend API development, database design, authentication implementation, pickup workflow management, billing functionality, reporting modules, and Flutter frontend integration.

Developed as an academic and practical sustainability-focused project.

---

# 🌱 Vision

To encourage responsible waste management, recycling awareness, and sustainable environmental practices through technology-driven waste collection and management solutions.