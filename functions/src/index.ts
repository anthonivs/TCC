import * as admin from "firebase-admin";
// eslint-disable-next-line import/no-unresolved
import {https} from "firebase-functions/v2";
// eslint-disable-next-line import/no-unresolved
import {onSchedule} from "firebase-functions/v2/scheduler";
// eslint-disable-next-line import/no-unresolved
import {logger} from "firebase-functions";

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
      const response = await admin.messaging().sendEachForMulticast(message);
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

/**
 * ⏰ Função agendada — Envia lembretes para eventos em 1 dia ou 3 horas
 */
export const checkUpcomingEvents = onSchedule(
  {schedule: "every 60 minutes", timeZone: "America/Sao_Paulo"},
  async () => {
    const now = new Date();
    const oneDayLater = new Date(now.getTime() + 24 * 60 * 60 * 1000);
    const threeHoursLater = new Date(now.getTime() + 3 * 60 * 60 * 1000);

    const eventsSnap = await admin.firestore().collection("events").get();
    const usersSnap = await admin.firestore().collection("users").get();

    for (const doc of eventsSnap.docs) {
      const event = doc.data();
      const eventTime = event.date.toDate?.() || event.date;
      const confirmedUserIds: string[] = event.confirmedUserIds ?? [];

      let title = "";
      let shouldNotify = false;

      const diffMs = (target: Date) => Math.abs(eventTime.getTime() - target.getTime());

      if (diffMs(oneDayLater) <= 15 * 60 * 1000) {
        title = "📅 Lembrete: Evento em 1 dia";
        shouldNotify = true;
      } else if (diffMs(threeHoursLater) <= 15 * 60 * 1000) {
        title = "⏰ Faltam 3 horas para o evento!";
        shouldNotify = true;
      }

      if (shouldNotify && confirmedUserIds.length > 0) {
        const tokens: string[] = [];

        for (const userId of confirmedUserIds) {
          const user = usersSnap.docs.find((u) => u.id === userId)?.data();
          if (user?.fcmToken) tokens.push(user.fcmToken);
        }

        if (tokens.length > 0) {
          await admin.messaging().sendEachForMulticast({
            tokens,
            notification: {
              title,
              body: `Evento: ${event.description} às ${event.time} em ${event.location}`,
            },
          });

          logger.info(`🔔 Lembrete enviado para '${event.description}' (${title})`);
        }
      }
    }
  }
);
