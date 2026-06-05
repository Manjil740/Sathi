# Saathi App (Prototype)

Saathi is a Flutter prototype for a silent, proximity-based emergency response network. It focuses on one-tap distress, fast responder assignment, and an offline-first demo flow.

## What this prototype includes
- One-tap distress activation with a cancel countdown
- Silent power-trigger simulation (3-5 rapid presses)
- Responder role assignment (Approach, Call 100, Document)
- Live chat and map-style coordination screens
- Emergency contact management
- Mocked Firebase, notification, and Bluetooth mesh hooks for demo purposes

## Run
1. Install Flutter dependencies: `flutter pub get`
2. Provide a Google Maps API key if you want the real map widget to render.
3. Launch on an Android device or emulator: `flutter run`

## Demo flow
1. Log in with a phone number (demo OTP).
2. Tap the red distress button or the silent power trigger.
3. View the active emergency screen.
4. Open the responder alert view and tap "I'm coming" to receive a role.
5. Chat in the emergency room and end the emergency from the victim side.
