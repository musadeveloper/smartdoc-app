# SmartDoc Medical Diagnosis App

## Overview
The **SmartDoc Medical Diagnosis App** is a cutting-edge healthcare solution designed to deliver **instant, accurate, and reliable diagnoses** for various skin diseases. Leveraging **AI-driven image classification** and seamless integration of advanced technologies, the app empowers users to upload or capture medical images and receive detailed analysis, recommendations, and severity assessments.

---

## Features
- **AI-Powered Diagnosis**: Provides instant results using advanced AI models like EfficientNetV2.
- **Medical Image Analysis**: Upload or capture medical images for quick and secure diagnosis.
- **ChatGPT Integration**: Offers explanations, recommendations, and severity assessments (Low/Moderate/Severe).
- **Secure and Scalable**: Built with Firebase Authentication and Google Firestore for robust security.
- **Cross-Platform Support**: Developed in Flutter for seamless Android and iOS compatibility.

---

## App Architecture

### Mobile App
- **UI Design**: Created with **Figma** for a modern and intuitive interface.
- **Development Tools**:
  - **Flutter**: Cross-platform development.
  - **TensorFlow Lite**: On-device AI processing for fast, reliable results.
- **Database**: **Google Firestore** for secure and scalable data storage.
- **Authentication**: **Firebase Authentication** for user login and security.

### AI & Model
- **Dataset**: **DermNet Dataset** with 23,000 images of different skin diseases.
- **Model Architecture**: **EfficientNetV2** for faster training and better parameter efficiency.
- **Programming Language**: **Python** for model training and implementation.
- **Training Details**:
  - Epochs: 20
  - Optimized for validation accuracy.
  - Converted to **TensorFlow Lite (TFLite)** for mobile deployment.

### API Integration
- **ChatGPT**:
  - Model: `"gpt-3.5-turbo"`.
  - Returns disease definitions, recommendations, and severity ratings.

### Data Analytics
- **Firebase Analytics**: Monitors app events, user interactions, and database reads/writes.
- **Azure Analytics**: Provides insights into app and website performance.

### DevOps & Hosting
- **Git**: Source control for the Flutter app code.
- **GitHub Actions**: Automates APK builds and pushes to Azure Blob Storage.
- **Azure Blob Storage**: Stores APKs securely.
- **Website**: Built with **Angular** for app hosting and APK download.

---

## Installation Guide

### Prerequisites
- Install [Flutter](https://flutter.dev/docs/get-started/install).
- Install [Python](https://www.python.org/downloads/) for model-related work.
- Set up a Firebase project for authentication and database.

### Steps
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/musadeveloper/smartdoc-app.git
   cd smartdoc-app
