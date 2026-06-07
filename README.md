# WasteWorth ♻️

## Recyclable Waste Management Mobile Application

WasteWorth is a Flutter and Django-based recyclable waste management platform designed to simplify waste pickup scheduling, recycling awareness, and sustainable waste handling through a mobile application and backend management system.

The platform connects users, drivers, and administrators through an integrated system for managing waste collection requests, pickup scheduling, pickup tracking, billing, reporting, and recycling product information.

Drivers can independently accept pickup requests in real time. Once a driver accepts a pickup request, it is automatically removed from the availability list for other drivers, preventing duplicate pickup assignments and improving operational efficiency.

The application also provides billing generation, transaction management, reporting functionality, user management, and pickup verification through image uploads.

Authentication is implemented using Django REST Framework Token Authentication for secure API communication between the Flutter frontend and Django backend.

---

## ✨ Features

* User registration, login, and account management
* Token-based authentication
* Waste pickup scheduling system
* Real-time driver pickup acceptance workflow
* Duplicate pickup prevention system
* Pickup tracking and status management
* Driver management and profile handling
* Billing and transaction generation
* Recycling product information and rates
* Reporting system for issue management
* Image upload support for pickup verification
* Flutter frontend integrated with Django REST Framework backend
* Role-based access for users, drivers, and administrators

---

## 🛠️ Technologies Used

### Frontend

* Flutter
* Dart

### Backend

* Python
* Django
* Django REST Framework (DRF)

### Database

* PostgreSQL

### Authentication

* DRF Token Authentication

### Development Tools

* Android Studio
* VS Code

### Libraries & Packages

* Pillow
* python-dotenv

---

## 📂 Project Structure

```plaintext
WasteWorth_App/
│
├── android/
├── ios/
├── linux/
├── macos/
├── windows/
├── web/
│
├── assets/
│
├── backend/
│   ├── core/
│   ├── media/
│   ├── pickup_photos/
│   ├── wasteworth_backend/
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
│   ├── pickups_page.dart
│   ├── schedule_pickup_page.dart
│   ├── user_page.dart
│   ├── driver_page.dart
│   └── additional Flutter screens
│
├── pubspec.yaml
├── README.md
└── wasteworth_app.iml
```

---

## 🚀 How to Run the Project

### Clone the Repository

```bash
git clone https://github.com/ArshyaBhagat/WasteWorth.git
cd WasteWorth_App
```

### Backend Setup

```bash
cd backend

python -m venv venv

venv\Scripts\activate

pip install -r requirements.txt

python manage.py migrate

python manage.py runserver
```

### Frontend Setup

```bash
flutter pub get

flutter run
```

---

## 🔐 Security

Sensitive files and local environment configurations are excluded using `.gitignore`.

Examples:

* `.env`
* `venv/`
* uploaded media files
* cache files

The application uses DRF Token Authentication to secure API access and user operations.

---

## 👩‍💻 Developer

**Arshya Bhagat**

Developed a recyclable waste management mobile application integrating Flutter frontend development with Django backend technologies. Implemented authentication, pickup scheduling workflows, driver management, billing, reporting, and database-driven functionality.

Developed as an academic project focused on sustainable waste management and full-stack application development.

---

## 🌱 Vision

To encourage responsible waste management, recycling awareness, and sustainable environmental practices through technology-driven solutions that improve the efficiency of recyclable waste collection systems.
