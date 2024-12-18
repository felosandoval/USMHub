const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');
const fs = require('fs');
const path = require('path');

// Inicializar Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

// Obtener el nombre del archivo desde los argumentos de la línea de comandos
const args = process.argv.slice(2);
const fileName = args[0];

if (!fileName) {
  console.error('Por favor, proporciona el nombre del archivo como argumento.\nnode uploaddata.js <nombre_archivo.json>');
  process.exit(1);
}

// Leer y cargar los subsistemas desde el archivo proporcionado
const filePath = path.resolve(fileName);
const subsystems = JSON.parse(fs.readFileSync(filePath, 'utf8'));

subsystems.usm.forEach(async (subsystem) => {
  // Crear un nuevo objeto con la combinación de los campos de imagen
  const newSubsystem = {
    ...subsystem,
    image: subsystem.image_internet
  };

  delete newSubsystem.image_internet;
  delete newSubsystem.image_local;

  await db.collection('subsystems').doc(subsystem.id.toString()).set(newSubsystem);
});

console.log('Data successfully written to Firestore');
