/**
 * Yandex Cloud Function: по расписанию читает новые заказы из Firestore
 * и отправляет уведомления в Telegram.
 *
 * Этап 1 миграции: данные остаются во Firebase, уведомления идут из Yandex.
 *
 * Переменные окружения (задать в настройках функции или через Lockbox):
 * - FIREBASE_SERVICE_ACCOUNT_JSON — JSON ключа сервисного аккаунта Firebase (строка)
 * - TELEGRAM_BOT_TOKEN — токен бота Telegram
 * - TELEGRAM_CHAT_ID — chat_id чата/группы
 */

const admin = require("firebase-admin");

let firestore = null;

function getFirestore() {
  if (firestore) return firestore;
  const raw = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
  if (!raw) throw new Error("FIREBASE_SERVICE_ACCOUNT_JSON is not set");
  const key = typeof raw === "string" ? JSON.parse(raw) : raw;
  if (!admin.apps.length) {
    admin.initializeApp({ credential: admin.credential.cert(key) });
  }
  firestore = admin.firestore();
  return firestore;
}

function formatDate(timestamp) {
  if (!timestamp || !timestamp.toDate) return "—";
  const d = timestamp.toDate();
  return d.toLocaleString("ru-RU", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
}

function buildOrderMessage(data) {
  const userName = data.userName || "—";
  const numberPhone = data.numberPhone || "—";
  const total = data.total != null ? Number(data.total).toFixed(2) : "0";
  const status = data.status || "Новый";
  const createdAt = formatDate(data.createdAt);
  const readyBy = data.readyBy ? formatDate(data.readyBy) : "—";

  const lines = [
    "🛒 Новый заказ",
    "",
    `👤 Имя: ${userName}`,
    `📞 Телефон: ${numberPhone}`,
    `💰 Сумма: ${total} руб`,
    `📅 Создан: ${createdAt}`,
    `⏰ К готовности: ${readyBy}`,
    `📋 Статус: ${status}`,
    "",
    "Позиции:",
  ];

  const positions = data.positions || [];
  positions.forEach((pos, i) => {
    const title = (pos.product && pos.product.title) || "—";
    const count = pos.count != null ? pos.count : 0;
    const cost = pos.cost != null ? Number(pos.cost).toFixed(2) : "0";
    lines.push(`${i + 1}. ${title} × ${count} — ${cost} руб`);
  });
  if (positions.length === 0) lines.push("—");

  return lines.join("\n");
}

async function sendTelegram(botToken, chatId, text) {
  const url = `https://api.telegram.org/bot${botToken}/sendMessage`;
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({
      chat_id: chatId,
      text,
      disable_web_page_preview: true,
    }),
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Telegram API ${res.status}: ${body}`);
  }
  const json = await res.json();
  if (!json.ok) throw new Error(`Telegram: ${JSON.stringify(json)}`);
}

/**
 * Обработчик вызова функции (триггер по расписанию).
 * В Yandex Cloud передаётся event и context.
 */
exports.handler = async function (event, context) {
  const botToken = process.env.TELEGRAM_BOT_TOKEN;
  const chatId = process.env.TELEGRAM_CHAT_ID;
  if (!botToken || !chatId) {
    console.error("TELEGRAM_BOT_TOKEN or TELEGRAM_CHAT_ID not set");
    return { statusCode: 500, body: "Missing Telegram config" };
  }

  const db = getFirestore();
  const since = new Date(Date.now() - 10 * 60 * 1000); // последние 10 минут
  const snapshot = await db
    .collection("orders")
    .where("createdAt", ">=", admin.firestore.Timestamp.fromDate(since))
    .get();

  let sent = 0;
  for (const doc of snapshot.docs) {
    const data = doc.data();
    const message = buildOrderMessage(data);
    await sendTelegram(botToken, chatId, message);
    sent += 1;
  }

  console.log(`Sent ${sent} order(s) to Telegram`);
  return { statusCode: 200, body: JSON.stringify({ sent }) };
};
