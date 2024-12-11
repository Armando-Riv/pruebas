const { onDocumentCreated, onDocumentUpdated, onDocumentDeleted } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();

// Función existente: Notificar eventos (ya la tienes)
exports.notifyEvent = onDocumentCreated(
  "monitored_users/{userId}/fall_history/{eventId}",
  async (event) => {
    const snapshot = event.data; // Datos del nuevo documento
    const userId = event.params.userId; // ID del usuario monitoreado

    try {
      const monitoredUserDoc = await admin
        .firestore()
        .collection("monitored_users")
        .doc(userId)
        .get();

      const monitoredUserData = monitoredUserDoc.data();
      if (!monitoredUserData || !monitoredUserData.requestedBy) {
        console.error(`No se encontró el email del usuario monitoreado: ${userId}`);
        return null;
      }

      const userEmail = monitoredUserData.requestedBy;

      const userQuery = await admin
        .firestore()
        .collection("users")
        .where("email", "==", userEmail)
        .get();

      if (userQuery.empty) {
        console.error(`No se encontró un usuario con el email: ${userEmail}`);
        return null;
      }

      const userData = userQuery.docs[0].data();

      if (!userData.fcmToken) {
        console.error(`Token FCM no encontrado para el usuario: ${userEmail}`);
        return null;
      }

      let title, body;
      if (snapshot.data().type === "Caída") {
        title = "¡Alerta de caída detectada!";
        body = `Se detectó una caída en ${monitoredUserData.personalInformation.fullName}.`;
      } else if (snapshot.data().type === "emergencia") {
        title = "¡Emergencia activada!";
        body = `El paciente ${monitoredUserData.personalInformation.fullName} activó una alerta de emergencia.`;
      } else {
        title = "Evento detectado";
        body = `Se detectó un evento en ${monitoredUserData.personalInformation.fullName}.`;
      }

      const message = {
        notification: {
          title: title,
          body: body,
        },
        token: userData.fcmToken,
        data: {
          eventId: event.id.toString(),
          timestamp: (snapshot.data().timestamp || new Date().toISOString()).toString(),
          type: (snapshot.data().type || "desconocido").toString(),
          confirmed: (snapshot.data().confirmed ? "true" : "false").toString(),
        },
      };

      await admin.messaging().send(message);
      console.log("Notificación enviada correctamente.");
    } catch (error) {
      console.error("Error al enviar la notificación:", error);
    }

    return null;
  }
);

// Función de Auditoría: Registrar creación
exports.auditCreate = onDocumentCreated("monitored_users/{docId}", async (event) => {
  const snapshot = event.data;
  const auditEntry = {
    action: "create",
    timestamp: new Date().toISOString(),
    documentId: event.params.docId,
    data: snapshot.data(),
  };
  await admin.firestore().collection("audit_logs").add(auditEntry);
});

// Función de Auditoría: Registrar actualizaciones
exports.auditUpdate = onDocumentUpdated("monitored_users/{docId}", async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  const auditEntry = {
    action: "update",
    timestamp: new Date().toISOString(),
    documentId: event.params.docId,
    before: before,
    after: after,
  };
  await admin.firestore().collection("audit_logs").add(auditEntry);
});

// Función de Auditoría: Registrar eliminaciones
exports.auditDelete = onDocumentDeleted("monitored_users/{docId}", async (event) => {
  const snapshot = event.data;
  const auditEntry = {
    action: "delete",
    timestamp: new Date().toISOString(),
    documentId: event.params.docId,
    data: snapshot.data(),
  };
  await admin.firestore().collection("audit_logs").add(auditEntry);
});


exports.auditFallHistoryUpdates = onDocumentUpdated(
  "monitored_users/{userId}/fall_history/{eventId}",
  async (event) => {
    const beforeData = event.data.before.data();
    const afterData = event.data.after.data();
    const userId = event.params.userId;
    const eventId = event.params.eventId;

    // Crear el registro de auditoría
    const auditLog = {
      timestamp: new Date().toISOString(),
      action: "update",
      userId: userId,
      eventId: eventId,
      changes: {
        before: beforeData,
        after: afterData,
      },
    };

    // Guardar en la colección audit_logs
    await admin.firestore().collection("audit_logs").add(auditLog);
    console.log("Registro de auditoría creado:", auditLog);
  }
);