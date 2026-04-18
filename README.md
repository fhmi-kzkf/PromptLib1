# PROMPTLIB // THE_INDUSTRIAL_ARCHIVIST

[ PROMPT_MANAGEMENT_SYSTEM / v1.0.0 ]

PromptLib is a high-performance, Neo-Brutalist prompt management vault designed for AI power users. Built with a "Terminal Aesthetic," it provides a robust infrastructure for refining, classifying, and archiving prompt payloads.

![Status: Operational](https://img.shields.io/badge/STATUS-OPERATIONAL-FFD700?style=for-the-badge&logoScale=1.2)
![Stack: CI4 + Flutter](https://img.shields.io/badge/STACK-CI4_%2F_FLUTTER-4ECDC4?style=for-the-badge)

---

## ⚡ CORE_SYSTEM_FEATURES

- **BENTO_DASHBOARD**: A staggered grid interface for rapid visual scanning of prompt records.
- **AI_REFINEMENT_ENGINE**: Integrated Gemini-2.5-Flash processing for payload optimization.
- **THE_VAULT**: Secure archival system for preserving high-value prompt history.
- **INDUSTRIAL_UI**: High-contrast, Neo-Brutalist design system (0px borders, hard shadows).

## 🛠 TECH_SPECIFICATIONS

### BACKEND (THE_CORE)
- **Framework**: CodeIgniter 4 (PHP 8.2+)
- **Database**: MySQL / MariaDB
- **API**: RESTful JSON endpoints with Auth integration.

### FRONTEND (THE_TERMINAL)
- **Framework**: Flutter (Web/Mobile)
- **Theme**: Custom Brutalist Design System
- **State**: Future-based asynchronous data mapping.

---

## 🚀 DEPLOYMENT_SEQUENCE

### 1. BACKEND_INITIALIZATION
```bash
cd backend
composer install
cp .env.example .env # Configure your DB credentials
php spark migrate
php spark serve --port 8080
```

### 2. FRONTEND_INITIALIZATION
```bash
cd frontend
flutter pub get
flutter run -d chrome
```

---

## 📂 DIRECTORY_MAPPING

```text
/PROJECT_ROOT
├── /backend     # CI4 Core Engine & API
├── /frontend    # Flutter UI & Design System
├── create_db.php # Utility for DB setup
└── .gitignore   # Security manifest
```

## 🔒 SECURITY_MANIFEST
This repository uses a strict `.gitignore` to prevent sensitive environmental variables ( `.env` ) and local database fragments from being pushed to public remotes.

---

> [!IMPORTANT]
> Ensure your `CORS` settings in CodeIgniter are configured to allow requests from your Flutter development port (usually `localhost:5000`+).

---

