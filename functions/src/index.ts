import * as admin from "firebase-admin";
// eslint-disable-next-line import/no-unresolved
import {https} from "firebase-functions/v2";

admin.initializeApp();

/**
 * Callable function (Firebase Functions v2) — Leader-only delete user
 */
export const adminDeleteUser = https.onCall(
  {region: "us-central1"},
  async (request) => {
    const auth = request.auth;
    if (!auth) {
      throw new https.HttpsError("unauthenticated", "Usuário não autenticado.");
    }

    const requesterUid = auth.uid;
    const requesterSnap = await admin.firestore().collection("users").doc(requesterUid).get();
    if (!requesterSnap.exists || requesterSnap.data()?.role !== "Líder") {
      throw new https.HttpsError("permission-denied", "Apenas líderes podem excluir usuários.");
    }

    const targetUid = (request.data as { userId?: string }).userId;
    if (!targetUid) {
      throw new https.HttpsError("invalid-argument", "ID do usuário não informado.");
    }

    try {
      await admin.auth().deleteUser(targetUid);
      await admin.firestore().collection("users").doc(targetUid).delete();
      return {message: "Usuário deletado com sucesso."};
    } catch (error: any) {
      throw new https.HttpsError("unknown", error.message);
    }
  }
);

/**
 * Callable function — envia notificação para múltiplos tokens via FCM HTTP v1
 */
export const sendGroupNotification = https.onCall(
  {region: "us-central1"},
  async (request) => {
    const {tokens, title, body} = request.data as {
      tokens: string[],
      title: string,
      body: string
    };

    if (!Array.isArray(tokens) || tokens.length === 0) {
      throw new https.HttpsError("invalid-argument", "Lista de tokens inválida ou vazia.");
    }

    const message = {
      notification: {title, body},
      tokens,
    };

    try {
      const response = await admin.messaging().sendMulticast(message);
      console.log("Notificações enviadas:", response.successCount);
      return {
        success: true,
        sent: response.successCount,
        failed: response.failureCount,
      };
    } catch (error: any) {
      console.error("Erro ao enviar notificações:", error.message);
      throw new https.HttpsError("internal", "Erro ao enviar notificações.");
    }
  }
);
