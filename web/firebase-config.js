// Firebase configuration for production
const firebaseConfig = {
  apiKey: "AIzaSyDozQTlWu59_bVQWQdbtqlGJOmz__H6dBA",
  authDomain: "neshmitf-dashboard.firebaseapp.com",
  projectId: "neshmitf-dashboard",
  storageBucket: "neshmitf-dashboard.firebasestorage.app",
  messagingSenderId: "784161677453",
  appId: "1:784161677453:web:882d183d80a7802ddb42c4"
};

// Initialize Firebase
const app = firebase.initializeApp(firebaseConfig);
const db = firebase.firestore(app);
const storage = firebase.storage(app);
const auth = firebase.auth(app);

// Make Firebase available globally
window.firebase = {
  app: app,
  db: db,
  storage: storage,
  auth: auth
};
