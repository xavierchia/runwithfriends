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
// exports.deleteOldRuns = functions.pubsub.schedule('0 3 * * *').onRun(async (context) => {
//     console.log("Running the delete function every 2 hours!")
//     // Get the current Unix hour in seconds
//     let currentUnixTime = new Date()
//     currentUnixTime.setMinutes(0, 0, 0)
//     currentUnixTime = currentUnixTime.getTime() / 1000
//     const twelveHoursAgo = currentUnixTime - 60 * 60 * 12

//     const runsSnapshot = await firestore.collection('runs').where('startTimeUnix', '<', twelveHoursAgo).get();

//     const deletePromises = [];
//     runsSnapshot.forEach((doc) => {
//         deletePromises.push(doc.ref.delete());
//     });

//     return Promise.all(deletePromises);
// });

exports.myScheduledFunction = functions.pubsub.schedule('* 3 * * *').onRun(async (context) => {
    console.log('Running the create function every 3 hours!');

    const currentDate = new Date();
    const currentDay = currentDate.getUTCDay();
    const daysToSubtract = currentDay === 0 ? 6 : currentDay - 1;
    const startOfWeek = new Date(currentDate);
    startOfWeek.setUTCDate(currentDate.getUTCDate() - daysToSubtract);
    startOfWeek.setUTCHours(0, 0, 0, 0);
    const startOfWeekEpochTime = startOfWeek.getTime() / 1000;
    const thisWeekID = startOfWeekEpochTime.toString()

    const daysToAdd = currentDay === 0 ? 1 : 8 - currentDay;
    const startOfNextWeek = new Date(currentDate);
    startOfNextWeek.setUTCDate(currentDate.getUTCDate() + daysToAdd);
    startOfNextWeek.setUTCHours(0, 0, 0, 0);
    const startOfNextWeekEpochTime = startOfNextWeek.getTime() / 1000;
    const nextWeekID = startOfNextWeekEpochTime.toString()

    // Promises array
    const promisesArray = [];

    // Fetch all runs  
    const collectionSnapshot = await firestore.collection('your_collection').get();

    // Create runs for this week if they don't exist
    const thisWeekDoc = collectionSnapshot.docs.find(doc => doc.id === thisWeekID);
    if (thisWeekDoc == undefined) {
        // Create a run for every half hour for this weke
        const thisWeek = Array.from({ length: 336 }, (_, i) => ({
            startTimeUnix: startOfWeekEpochTime + i * 30 * 60,
            endTimeUnix: startOfWeekEpochTime + (i + 1) * 30 * 60,
        }));

        promisesArray.push(firestore.collection('runs').doc(thisWeekID).set({ runs: thisWeek }));
    }

    // Create runs for next week if they don't exist
    const nextWeekDoc = collectionSnapshot.docs.find(doc => doc.id === nextWeekID);
    if (nextWeekDoc == undefined) {
        // Create a run for every half hour for next week
        const nextWeek = Array.from({ length: 336 }, (_, i) => ({
            startTimeUnix: startOfNextWeekEpochTime + i * 30 * 60,
            endTimeUnix: startOfNextWeekEpochTime + (i + 1) * 30 * 60,
        }));

        promisesArray.push(firestore.collection('runs').doc(nextWeekID).set({ runs: nextWeek }));
    }

    // Wait for all new runs to be created
    return Promise.all(promisesArray);
});