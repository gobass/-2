import { initializeApp } from "firebase/app";

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "your-api-key-here",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "your-app-id"
};

// Initialize Firebase
if (firebaseConfig.apiKey && firebaseConfig.apiKey !== "your-api-key-here") {
  const app = initializeApp(firebaseConfig);
} else {
  console.error("Firebase configuration is missing or not properly set.");
}
