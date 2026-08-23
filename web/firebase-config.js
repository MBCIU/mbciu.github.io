const firebaseConfig = {
  apiKey: "AIzaSyBQ0RJeM0tMZ0ro0EjdOfmBgCb1DZS87_c",
  authDomain: "mbciu-auth.firebaseapp.com",
  projectId: "mbciu-auth",
  storageBucket: "mbciu-auth.firebasestorage.app",
  messagingSenderId: "406163757457",
  appId: "1:406163757457:web:5317052f0c417c1e14a230"
};

firebase.initializeApp(firebaseConfig);

const db = firebase.firestore();

const TOOL_IDS = Object.freeze([
  "gettingstarted", "spartan", "seg", "qsm", "dwi", "rsfMRI", "tfMRI", "MRS", "ASL"
]);

function normaliseEmail(email) {
  return String(email || "").trim().toLowerCase();
}

async function getCurrentProfile(user) {
  if (!user) return null;
  const snapshot = await db.collection("users").doc(user.uid).get();
  return snapshot.exists ? snapshot.data() : null;
}

async function userIsAdmin(user) {
  if (!user || !user.emailVerified) return false;
  const snapshot = await db.collection("admins").doc(user.uid).get();
  return snapshot.exists && snapshot.data().active === true &&
    normaliseEmail(snapshot.data().email) === normaliseEmail(user.email);
}

async function requireApprovedUser(user) {
  if (!user || !user.emailVerified) return false;
  const profile = await getCurrentProfile(user);
  return Boolean(profile && profile.approved === true &&
    normaliseEmail(profile.email) === normaliseEmail(user.email));
}
