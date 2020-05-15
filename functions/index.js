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
// When post is created, add to timeline of each follower of post owner
exports.onCreatePost = functions.firestore
    .document('/posts/{userId}/userPosts/{postId}')
    .onCreate(async (snapshot, context) => {
        const postCreated = snapshot.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        //  1. get all the followers of user that create post
        const userFollowersRef = admin.firestore.collection('followers').
            doc(userId).
            collection('userFollowers');

        const querySnapshot = await userFollowersRef.get();

        //  2. add new post to all followers timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin.
                firestore()
                .collection('timeline').
                doc(followerId)
                .collection("timelinePosts").
                doc(postId)
                .set(postCreated);
        });
    })

exports.onUpdatePost = functions.firestore.
    document('/posts/{userId}/userPosts/{postId}')
    .onUpdate(async (change, context) => {
        const postUpdated = change.after.data();
        const userId = context.params.userId;
        const postId = context.params.postId;

        //  1. get all the followers of user that create post
        const userFollowersRef = admin.firestore.collection('followers').
            doc(userId).
            collection('userFollowers');

        const querySnapshot = await userFollowersRef.get();

        // 2. Update each post in users timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin.
                firestore()
                .collection('timeline').
                doc(followerId)
                .collection("timelinePosts").
                doc(postId)
                .get().then(
                    doc => {
                        if (doc.exists) {
                            doc.ref.update(postUpdated);
                        }
                    }
                );
        });
    })

exports.onDeletePost = functions.firestore.
    document('/posts/{userId}/userPosts/{postId}')
    .onDelete(async (snapshot, context) => {
        const userId = context.params.userId;
        const postId = context.params.postId;

        //  1. get all the followers of user that create post
        const userFollowersRef = admin.firestore.collection('followers').
            doc(userId).
            collection('userFollowers');

        const querySnapshot = await userFollowersRef.get();

        // 2. Delete each post in users timeline
        querySnapshot.forEach(doc => {
            const followerId = doc.id;

            admin.
                firestore()
                .collection('timeline').
                doc(followerId)
                .collection("timelinePosts").
                doc(postId)
                .get().then(
                    doc => {
                        if (doc.exists) {
                            doc.ref.delete();
                        }
                    }
                );
        });

    })