/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// The Cloud Functions for Firebase SDK to create Cloud Functions and triggers.
const functions = require("firebase-functions");

// The Firebase Admin SDK to access Firestore.
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

initializeApp();

const firestore = getFirestore()

// Cloud Function to delete runs older than 12 hours
exports.deleteOldRuns = functions.pubsub.schedule('0 3 * * *').onRun(async (context) => {
    console.log("Running the delete function every 2 hours!")
    // Get the current Unix hour in seconds
    let currentUnixTime = new Date()
    currentUnixTime.setMinutes(0, 0, 0)
    currentUnixTime = currentUnixTime.getTime() / 1000
    const twelveHoursAgo = currentUnixTime - 60 * 60 * 12

    const runsSnapshot = await firestore.collection('runs').where('startTimeUnix', '<', twelveHoursAgo).get();

    const deletePromises = [];
    runsSnapshot.forEach((doc) => {
        deletePromises.push(doc.ref.delete());
    });

    return Promise.all(deletePromises);
});

// Your Cloud Function
exports.myScheduledFunction = functions.pubsub.schedule('* 3 * * *').onRun(async (context) => {
    // Your code to be executed at the top of every hour
    console.log('Running the create function every 3 hours!');

    // Get the current Unix hour in seconds
    let currentUnixTime = new Date()
    currentUnixTime.setMinutes(0, 0, 0)
    currentUnixTime = currentUnixTime.getTime() / 1000

    // Create a run for every half hour for the next 24 hours
    const next36Hours = Array.from({ length: 48 }, (_, i) => currentUnixTime + i * 30 * 60);

    // Fetch all runs
    const runsSnapshot = await firestore.collection('runs').get();

    // Create a local array to track existing runs
    const existingRuns = runsSnapshot.docs.map(doc => doc.data().startTimeUnix);

    // Create runs for the next 24 hours if they don't exist
    const createRunsPromises = [];
    for (const hourToCheck of next36Hours) {
        if (!existingRuns.includes(hourToCheck)) {
            // Each run ends in half an hour
            const newRun = {
                startTimeUnix: hourToCheck,
                endTimeUnix: hourToCheck + 30 * 60,
            };

            createRunsPromises.push(firestore.collection('runs').add(newRun));
        }
    }

    for (const run of existingRuns) {
        if (run < twelveHoursAgo) {
            createRunsPromises.push(fire)
        }
    }

    // Wait for all new runs to be created
    return Promise.all(createRunsPromises);
});