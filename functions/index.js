const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
exports.onCreateFollower = functions.firestore.
    document('/followers/{userId}/userFollowers/{followerId}').onCreate(async (snapshot, context) => {
        console.log('follower created', snapshot.data());
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        // 1. create followed users postsref
        const followedUserPostsRef = admin.
            firestore().
            collection('posts').
            doc(userId).
            collection('userPosts');

        // 2. create Following users timelineref
        const timelinePostsRef = admin.
            firestore().
            collection('timeline').
            doc(followerId).
            collection('timelinePosts');

        // 3. get following users posts
        const querySnapshot = await followedUserPostsRef.get();

        // 4. add each users post to following user's timeline
        querySnapshot.forEach(doc => {
            if (doc.exists) {
                const postId = doc.id
                const postData = doc.data();
                timelinePostsRef.doc(postId).set(postData);
            }

        });
    });

exports.onDeleteFollower = functions.firestore
    .document('/followers/{userId}/userFollowers/{followerId}')
    .onDelete(async (snapshot, context) => {
        console.log('follower deleted', snapshot.id);
        const userId = context.params.userId;
        const followerId = context.params.followerId;

        const timelinePostsRef = admin.
            firestore().
            collection('timeline').
            doc(followerId).
            collection('timelinePosts').where('ownerId', '==', userId);

        const querySnapshot = await timelinePostsRef.get();
        querySnapshot.forEach((doc) => {
            if (doc.exists) {
                doc.ref.delete();
            }
        });
    })