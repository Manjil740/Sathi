const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();
const db = admin.firestore();

exports.findNearbyUsers = functions.firestore
  .document('emergencies/{emergencyId}')
  .onCreate(async (snap) => {
    const emergency = snap.data();
    const { lat, lng } = emergency.location;

    const nearbyUsers = await db.collection('users')
      .where('location.lat', '>=', lat - 0.0045)
      .where('location.lat', '<=', lat + 0.0045)
      .where('location.lng', '>=', lng - 0.0045)
      .where('location.lng', '<=', lng + 0.0045)
      .get();

    const tokens = nearbyUsers.docs
      .map((doc) => doc.data().fcm_token)
      .filter(Boolean);

    if (tokens.length === 0) {
      return null;
    }

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: 'Saathi in Distress',
        body: `Emergency ${emergency.danger_level}/5, 500m away`,
      },
      android: {
        priority: 'high',
      },
    });

    return null;
  });
