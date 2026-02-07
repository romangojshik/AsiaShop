/**
 * Cloud Functions: при создании заказа в Firestore отправляем уведомление в Telegram.
 *
 * Настройка:
 * 1. Создайте бота через @BotFather, получите токен.
 * 2. Узнайте chat_id (напишите боту, затем откройте https://api.telegram.org/bot<TOKEN>/getUpdates).
 * 3. Выполните в терминале:
 *    firebase functions:config:set telegram.bot_token="ВАШ_ТОКЕН" telegram.chat_id="ВАШ_CHAT_ID"
 * 4. Деплой: firebase deploy --only functions
 */

const { setGlobalOptions } = require("firebase-functions");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const functions = require("firebase-functions");
const logger = require("firebase-functions/logger");

setGlobalOptions({ maxInstances: 10 });

/**
 * Форматирует дату из Firestore Timestamp для сообщения.
 */
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

/**
 * Собирает текст сообщения о новом заказе из данных документа.
 */
function buildOrderMessage(data) {
  const userName = data.userName || "—";
  const numberPhone = data.numberPhone || "—";
  const total = data.total != null ? Number(data.total).toFixed(2) : "0";
  const status = data.status || "Новый";
  const createdAt = formatDate(data.createdAt);
  const readyBy = data.readyBy ? formatDate(data.readyBy) : "—";

  let lines = [
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

  if (positions.length === 0) {
    lines.push("—");
  }

  return lines.join("\n");
}

/**
 * Отправляет сообщение в Telegram через Bot API.
 */
async function sendTelegramMessage(botToken, chatId, text) {
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
    throw new Error(`Telegram API error ${res.status}: ${body}`);
  }

  const json = await res.json();
  if (!json.ok) {
    throw new Error(`Telegram error: ${JSON.stringify(json)}`);
  }
}

/**
 * Триггер: при создании документа в коллекции orders отправляем уведомление в Telegram.
 * Токен и chat_id задаются через: firebase functions:config:set telegram.bot_token="..." telegram.chat_id="..."
 */
exports.sendOrderToTelegram = onDocumentCreated(
  {
    document: "orders/{orderId}",
    region: "europe-west1",
  },
  async (event) => {
    const config = functions.config();
    const botToken = config.telegram && config.telegram.bot_token;
    const chatId = config.telegram && config.telegram.chat_id;

    if (!botToken || !chatId) {
      logger.warn(
        "Telegram not configured. Set telegram.bot_token and telegram.chat_id with firebase functions:config:set"
      );
      return null;
    }

    const snapshot = event.data;
    if (!snapshot || !snapshot.data) {
      logger.warn("sendOrderToTelegram: no snapshot data");
      return null;
    }

    const data = snapshot.data();
    const message = buildOrderMessage(data);

    try {
      await sendTelegramMessage(botToken, chatId, message);
      logger.info("Order notification sent to Telegram", {
        orderId: event.params.orderId,
      });
    } catch (err) {
      logger.error("Failed to send order to Telegram", {
        orderId: event.params.orderId,
        error: err.message,
      });
      throw err;
    }

    return null;
  }
);
