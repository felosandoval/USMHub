const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const fs = require('fs');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const subsystems = JSON.parse(fs.readFileSync('subsystems.json', 'utf8'));

subsystems.subsystems.forEach(async (subsystem) => {
  await db.collection('subsystems').doc(subsystem.id.toString()).set(subsystem);
});

console.log('Data successfully written to Firestore');
