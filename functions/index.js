const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

initializeApp();

/**
 * When a hire request is created, send a push notification to the recipient.
 */
exports.onHireRequestCreated = onDocumentCreated(
  "hireRequests/{requestId}",
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const data = snapshot.data();
    const toUserId = data.toUserId;
    const fromName = data.fromName || "Someone";
    const fromCompany = data.fromCompany || "";

    const db = getFirestore();
    const userDoc = await db.collection("users").doc(toUserId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) return;

    const title = "New hire request";
    const body = fromCompany
      ? `${fromName} from ${fromCompany} wants to connect`
      : `${fromName} sent you a hire request`;

    await getMessaging().send({
      token: fcmToken,
      notification: { title, body },
      data: {
        type: "hire_request",
        requestId: event.params.requestId,
        screen: "/hire-requests",
      },
    });
  }
);

