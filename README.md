# ExamCert 📚🧠

**ExamCert** is a cross-platform certification exam practice app that allows users to prepare for multiple-choice tests offline and online. It consists of a **Flutter frontend** and a **Node.js backend** with a PostgreSQL database.

---

## 📦 Project Structure
ExamCert/
├── cert_exam_app/ # Flutter mobile/web frontend
├── cert-backend/ # Node.js backend API server

---

## 🚀 Features

### ✅ Frontend (Flutter):
- Offline-first quiz interface
- Multiple-choice questions with score tracking
- Local SQLite storage (for mobile)
- JSON fallback (for web)
- Question entry UI for adding new items

### ✅ Backend (Node.js + PostgreSQL):
- RESTful API for question storage & retrieval
- Dockerized PostgreSQL setup
- Scalable schema for categories, questions, and user scores

---

## 🛠️ Getting Started

### 🔹 Frontend (Flutter)

#### Install dependencies:
```bash
cd cert_exam_app
flutter pub get

---

## 🚀 Features

### ✅ Frontend (Flutter):
- Offline-first quiz interface
- Multiple-choice questions with score tracking
- Local SQLite storage (for mobile)
- JSON fallback (for web)
- Question entry UI for adding new items

### ✅ Backend (Node.js + PostgreSQL):
- RESTful API for question storage & retrieval
- Dockerized PostgreSQL setup
- Scalable schema for categories, questions, and user scores

---

## 🛠️ Getting Started

### 🔹 Frontend (Flutter)

#### Install dependencies:
```bash
cd cert_exam_app
flutter pub get


Run on Chrome:
flutter run -d chrome

Run on Android:
flutter run -d android