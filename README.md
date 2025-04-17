# 🎯 IELTSMate – Your Personalized Exam Prep Buddy

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)


# IELTSMate – Your Personalized Exam Prep Buddy

**IELTSMate** is a smart, cross-platform IELTS preparation app designed to help users practice and master the four key areas of the IELTS exam: **Listening**, **Reading**, **Writing**, and **Speaking** (coming soon). It combines AI-generated content, automated evaluation, and a sleek Flutter interface to deliver a comprehensive self-study solution for IELTS candidates.

---

## Features

### 🎧 Listening Practice
- AI-generated listening passages with background context
- Realistic audio generation using **Google Text-to-Speech (gTTS)**
- Interactive Q&A interface
- Auto-scoring and model answer feedback using Gemini API

### 📖 Reading Practice
- Academic reading passages generated by **Google Gemini API**
- Includes True/False/Not Given and One-Word Answer questions
- Automatic evaluation with scores and suggestions

### ✍️ Writing Practice
- Task 1 (Letter) and Task 2 (Essay) prompts generated dynamically
- User submissions evaluated and scored by Gemini AI
- Detailed written feedback to improve writing skills

### 🗣️ Speaking Practice *(Coming Soon)*
- Voice input and recording features
- AI evaluation of fluency, vocabulary, coherence, and grammar

### 🧾 User Management
- Email-based registration with OTP verification
- Login system with hashed passwords (SQLite backend)

---

## Tech Stack

| Component    | Technology              |
|--------------|--------------------------|
| Frontend     | Flutter (mobile + web)   |
| Backend      | Flask (Python)           |
| Database     | SQLite                   |
| AI Engine    | Google Gemini 2.0 Flash  |
| Audio        | gTTS (Google TTS)        |
| Deployment   | Ngrok (for dev), Waitress for production serving |

---

## 📁 Project Structure

ieltsmate/ │ ├── lib/ # Flutter frontend │ ├── main.dart │ ├── pages/ # Practice screens │ ├── widgets/ # Platform-specific audio player │ └── services/constants.dart # API base URL config │ ├── backend/ # Flask backend │ ├── app.py # Main backend logic │ ├── database.db # SQLite database file │ ├── static/audio/ # Auto-generated audio files │ └── .env # Environment secrets │ ├── assets/ │ └── images/ # Backgrounds and UI visuals │ └── README.md


---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- Python 3.8+ with `pip`
- Ngrok (for testing Flask backend over the internet)
- Gmail account (for sending verification emails via App Password)

---

### Backend Setup (Flask + SQLite)

1. **Navigate to the backend directory:**

```bash
cd backend/

### Install Python dependencies

pip install -r requirements.txt

### create the .env file

- GEMINI_API_KEY=your_google_gemini_api_key
- EMAIL_ADDRESS=your_email@gmail.com
- EMAIL_APP_PASSCODE=your_app_specific_password

### Run the Flask server

python app.py
# or for production:
waitress-serve --port=5000 app:app

### for local running - Expose your server using ngrok

ngrok http 5000

## Frontend Setup (Flutter)

### Install Flutter dependencies

flutter pub get
Update baseUrl in Flutter code

In lib/services/constants.dart, set your backend URL:

const String baseUrl = 'https://your-ngrok-subdomain.ngrok-free.app';
Run the app:

flutter run -d chrome         # For web
flutter run -d android        # For Android emulator or device

# Security Notes
User passwords are securely hashed using werkzeug.security

Email verification required on registration

CORS enabled for secure multi-platform access

# 📘 Sample Use Flow

1. User signs up with email and receives a verification code.
2. Selects a module (Listening / Reading / Writing).
3. Practices using AI-generated questions.
4. Submits responses for instant feedback and scores.

---

## 📌 Roadmap

- [x] AI Listening with audio generation  
- [x] Reading comprehension and scoring  
- [x] Writing task evaluation with Gemini AI  
- [ ] Speaking evaluation (recording + feedback)  
- [ ] User performance analytics  
- [ ] Admin dashboard for content moderation  

---

## 🤝 Contributing

We welcome contributions! Feel free to fork the repo, submit issues, or open pull requests.

---

## 📧 Contact

- **Developer:** Sameera Gamage  
- **Affiliation:** M3S Research Unit, University of Oulu


---

## 📝 License

This project is licensed under the **MIT License**.

> All rights and ownership of this application belong solely to **Sameera Gamage**. Unauthorized use or misrepresentation is strictly prohibited.

See the full [LICENSE](./LICENSE) file for details.
