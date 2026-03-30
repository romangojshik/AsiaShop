/**
 * HTTP-функция приёма заказов: POST с JSON → запись в YDB таблицу `orders` и `order_positions` → уведомление в Telegram.
 * Переменные окружения: YDB_ENDPOINT, YDB_DATABASE, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID
 * Для Yandex Cloud: задай YDB_METADATA_CREDENTIALS=1 для авторизации через метаданные ВМ.
 * При 500 в ответе возвращается поле error с причиной (для диагностики).
 *
 * JSON: readyBy / ready_by — ISO-строка (момент в UTC, суффикс Z) или число (мс). Для YDB нужна колонка ready_by.
 * ORDER_DISPLAY_TIMEZONE (опц., по умолчанию Europe/Minsk) — зона для строки «Заказ должен быть готов к» в Telegram.
 */

const TABLE_ORDER = '`orders`';
const TABLE_ORDER_POSITIONS = '`order_positions`';

function noop() {}
const logger = { debug: noop, trace: noop, info: noop, warn: noop, error: noop };

let driver = null;
let ydbSdk = null;

function getYdbSdk() {
  if (ydbSdk) return ydbSdk;
  try {
    ydbSdk = require('ydb-sdk');
    return ydbSdk;
  } catch (e) {
    console.error('YDB: require("ydb-sdk") failed:', e && e.message ? e.message : String(e));
    return null;
  }
}

async function getDriver() {
  if (driver) return { driver, error: null };
  const sdk = getYdbSdk();
  if (!sdk) return { driver: null, error: 'YDB SDK не загружен (require ydb-sdk)' };
  try {
    let endpoint = (process.env.YDB_ENDPOINT || '').trim();
    const database = (process.env.YDB_DATABASE || '').trim();
    if (!endpoint || !database) {
      return { driver: null, error: 'YDB_ENDPOINT и YDB_DATABASE обязательны в настройках функции' };
    }
    if (!endpoint.startsWith('grpcs://') && !endpoint.startsWith('https://')) {
      endpoint = 'grpcs://' + endpoint;
    }
    const authService = typeof sdk.getCredentialsFromEnv === 'function'
      ? sdk.getCredentialsFromEnv(logger)
      : new sdk.MetadataAuthService();
    driver = new sdk.Driver({
      endpoint,
      database,
      authService,
      logger: typeof sdk.getDefaultLogger === 'function' ? sdk.getDefaultLogger() : logger,
    });
    const ok = await driver.ready(10000);
    if (!ok) {
      driver = null;
      return { driver: null, error: 'YDB: driver.ready() таймаут 10s. Проверьте YDB_ENDPOINT, YDB_DATABASE и права сервисного аккаунта (ydb.editor)' };
    }
    return { driver, error: null };
  } catch (e) {
    driver = null;
    const msg = (e && e.message) || String(e);
    console.error('YDB getDriver error:', msg, e && e.stack);
    return { driver: null, error: 'YDB getDriver: ' + msg };
  }
}

function runQueryWithParams(query, params) {
  return driver.tableClient.withSessionRetry(
    (session) => session.executeQuery(query, params),
    5000,
    3
  );
}

/** ISO-строка для хранения или null. Принимает readyBy / ready_by, число мс или произвольную строку. */
function normalizeReadyBy(body) {
  if (!body || typeof body !== 'object') return null;
  const raw = body.readyBy ?? body.ready_by ?? null;
  if (raw == null || raw === '') return null;
  if (typeof raw === 'number' && Number.isFinite(raw)) {
    const d = new Date(raw);
    return Number.isNaN(d.getTime()) ? null : d.toISOString();
  }
  if (typeof raw === 'string') {
    const s = raw.trim();
    if (!s) return null;
    const t = Date.parse(s);
    if (!Number.isNaN(t)) return new Date(t).toISOString();
    return s;
  }
  return null;
}

/** Человекочитаемая дата для Telegram (ru-RU) в часовом поясе точки (кухня), не UTC-рантайма функции. */
function formatReadyByForTelegram(isoOrString) {
  if (isoOrString == null || isoOrString === '') return null;
  const t = Date.parse(isoOrString);
  if (!Number.isNaN(t)) {
    const d = new Date(t);
    const tz = (process.env.ORDER_DISPLAY_TIMEZONE || 'Europe/Minsk').trim() || 'Europe/Minsk';
    const opts = {
      timeZone: tz,
      day: 'numeric',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    };
    try {
      return d.toLocaleString('ru-RU', opts);
    } catch (e) {
      console.error('ORDER_DISPLAY_TIMEZONE некорректна, fallback UTC:', tz, e && e.message);
      return d.toLocaleString('ru-RU', { ...opts, timeZone: 'UTC' });
    }
  }
  return String(isoOrString);
}

/** Поля заказа; принимает userName / numberPhone с клиента; ready_by — ISO или текст. */
function normalizeOrder(body) {
  if (!body || typeof body !== 'object') return null;
  const id = body.id != null ? String(body.id).trim() : '';
  const user_name = String(body.user_name ?? body.userName ?? '').trim();
  const user_phone_number = String(body.user_phone_number ?? body.numberPhone ?? '').trim();
  const total = Number(body.total);
  const extras = body.extras != null ? String(body.extras).trim() : '';
  const ready_by = normalizeReadyBy(body);

  return {
    id: id || null,
    user_name: user_name || null,
    user_phone_number: user_phone_number || null,
    total: Number.isNaN(total) ? 0 : total,
    extras: extras || null,
    ready_by,
  };
}

/** Нормализация позиций: ожидает body.positions как массив объектов. */
function normalizePositions(body) {
  const raw = body && Array.isArray(body.positions) ? body.positions : [];
  return raw
    .filter((p) => p && typeof p === 'object')
    .map((p) => ({
      product_id: p.product_id != null ? String(p.product_id).trim() : '',
      title: p.title != null ? String(p.title).trim() : '',
      count: Number(p.count) || 0,
      cost: Number(p.cost) || 0,
    }))
    .filter((p) => p.product_id && p.title && p.count > 0);
}

/** Возвращает { ok: true } или { ok: false, error: string } — текст ошибки отдаём в 500 для диагностики. */
async function insertOrder(order) {
  if (!driver) {
    const { driver: d, error: err } = await getDriver();
    driver = d;
    if (err) return { ok: false, error: err };
  }

  const sdk = getYdbSdk();
  if (!sdk || !sdk.TypedValues) {
    return { ok: false, error: 'YDB: TypedValues недоступны' };
  }

  const { id, user_name, user_phone_number, total, extras, ready_by } = order;
  if (!id || !user_name || !user_phone_number) {
    return { ok: false, error: 'YDB: id, user_name, user_phone_number обязательны' };
  }

  const { TypedValues } = sdk;
  const query = `
    DECLARE $id AS Utf8;
    DECLARE $user_name AS Utf8;
    DECLARE $user_phone_number AS Utf8;
    DECLARE $total AS Double;
    DECLARE $extras AS Utf8;
    DECLARE $ready_by AS Utf8;
    INSERT INTO ${TABLE_ORDER} (id, user_name, user_phone_number, total, extras, ready_by)
    VALUES ($id, $user_name, $user_phone_number, $total, $extras, $ready_by);
  `;
  const params = {
    $id: TypedValues.utf8(id),
    $user_name: TypedValues.utf8(user_name),
    $user_phone_number: TypedValues.utf8(user_phone_number),
    $total: TypedValues.double(total),
    $extras: TypedValues.utf8(extras || ''),
    $ready_by: TypedValues.utf8(ready_by || ''),
  };

  try {
    await runQueryWithParams(query, params);
    return { ok: true };
  } catch (e) {
    const msg = (e && e.message) || String(e);
    console.error('YDB insertOrder error:', msg, e && e.stack);
    return { ok: false, error: 'YDB INSERT: ' + msg };
  }
}

/** Вставка позиций заказа в таблицу order_positions (с полями order_id, product_id, title, count, cost). */
async function insertOrderPositions(orderId, positions) {
  if (!driver) {
    const { driver: d, error: err } = await getDriver();
    driver = d;
    if (err) return { ok: false, error: err };
  }

  const sdk = getYdbSdk();
  if (!sdk || !sdk.TypedValues) {
    return { ok: false, error: 'YDB: TypedValues недоступны' };
  }

  const { TypedValues } = sdk;

  const query = `
    DECLARE $order_id AS Utf8;
    DECLARE $product_id AS Utf8;
    DECLARE $title AS Utf8;
    DECLARE $count AS Int32;
    DECLARE $cost AS Double;

    INSERT INTO ${TABLE_ORDER_POSITIONS} (order_id, product_id, title, count, cost)
    VALUES ($order_id, $product_id, $title, $count, $cost);
  `;

  try {
    for (const pos of positions) {
      const params = {
        $order_id: TypedValues.utf8(orderId),
        $product_id: TypedValues.utf8(pos.product_id),
        $title: TypedValues.utf8(pos.title),
        $count: TypedValues.int32(pos.count),
        $cost: TypedValues.double(pos.cost || 0),
      };
      await runQueryWithParams(query, params);
    }
    return { ok: true };
  } catch (e) {
    const msg = (e && e.message) || String(e);
    console.error('YDB insertOrderPositions error:', msg, e && e.stack);
    return { ok: false, error: 'YDB INSERT order_positions: ' + msg };
  }
}

function buildOrderMessage(order, positions) {
  const user_name = order.user_name ?? '—';
  const user_phone_number = order.user_phone_number ?? '—';
  const total = order.total != null ? Number(order.total).toFixed(2) : '0';
  const extrasText = order.extras && String(order.extras).trim()
    ? String(order.extras).trim()
    : null;
  const readyLabel = formatReadyByForTelegram(order.ready_by);

  const lines = [
    '🛒 Новый заказ по номеру телефона',
    '',
    `👤 Имя: ${user_name}`,
    `📞 Телефон: ${user_phone_number}`,
  ];
  if (readyLabel) {
    lines.push(`🕒 Заказ должен быть готов к: ${readyLabel}`);
  }
  lines.push(`💰 Сумма: ${total} руб`);

  // 🍣 Заказ
  let baseSum = 0;
  if (Array.isArray(positions) && positions.length > 0) {
    lines.push('', '🍣 Заказ:');
    for (const p of positions) {
      const title = p.title || 'Товар';
      const count = p.count != null ? Number(p.count) : 0;
      const cost = p.cost != null ? Number(p.cost) : 0;
      baseSum += cost;
      lines.push(`${title} ${count} шт = ${cost.toFixed(2)} руб`);
    }
  }

  // 📝 Дополнительно с расчётом
  if (extrasText) {
    const freeItems = [];
    const paidItems = [];
    let paidCount = 0;

    const extraLines = extrasText
      .split('\n')
      .map((l) => l.trim())
      .filter(Boolean);

    for (const line of extraLines) {
      const match = line.match(/^(.+?):\s*(\d+)\s*шт/i);
      const name = match ? match[1].trim() : line;
      const count = match ? Number(match[2]) : 0;

      if (name.toLowerCase().startsWith('палоч')) {
        freeItems.push(`${name}: ${count} шт`);
      } else {
        paidItems.push(`${name}: ${count} шт`);
        paidCount += count;
      }
    }

    const pricePerUnit = 2;
    const extrasSum = paidCount * pricePerUnit;
    const finalTotal = Number(total);

    lines.push('', '📝 Дополнительно:');

    if (freeItems.length > 0) {
      lines.push('Бесплатно 🙂:');
      lines.push(...freeItems);
      lines.push('');
    }

    if (paidItems.length > 0) {
      lines.push(`Все по ${pricePerUnit} руб 🙁:`);
      lines.push(...paidItems);
      lines.push('');
      if (paidCount > 0) {
        lines.push(`${paidCount} шт × ${pricePerUnit} руб = ${extrasSum.toFixed(2)} руб`);
      }
    }

    if (baseSum > 0) {
      lines.push('');
      lines.push(`Итого: ${baseSum.toFixed(2)} руб + ${extrasSum.toFixed(2)} руб = ${finalTotal.toFixed(2)} руб`);
    }
  }

  return lines.join('\n');
}

async function sendTelegramMessage(botToken, chatId, text) {
  const url = `https://api.telegram.org/bot${botToken}/sendMessage`;
  const res = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
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

function parseBodyFromEvent(event) {
  let raw = event.body ?? event.requestBody ?? event.requestContext?.body ?? event.request_context?.body;
  if (raw === undefined || raw === null) return null;
  if (typeof raw === 'object' && !Buffer.isBuffer(raw)) {
    if (raw.body && typeof raw.body === 'string') return parseBodyFromEvent({ ...event, body: raw.body });
    return raw;
  }
  if (typeof raw === 'string') {
    if (event.isBase64Encoded) {
      try {
        raw = Buffer.from(raw, 'base64').toString('utf8');
      } catch (e) {
        console.error('Base64 decode error:', e && e.message);
        return null;
      }
    }
    try {
      return JSON.parse(raw);
    } catch (e) {
      console.error('JSON parse error:', e && e.message);
      return null;
    }
  }
  return null;
}

module.exports.handler = async function (event, context) {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };
  try {
    const method = event.httpMethod || event.requestContext?.http?.method || 'POST';
    if (method !== 'POST') {
      return {
        statusCode: 405,
        body: JSON.stringify({ error: 'Method not allowed' }),
        headers,
      };
    }

    let body = parseBodyFromEvent(event);
    if (!body && typeof event.body === 'string') {
      try {
        let raw = event.body;
        if (event.isBase64Encoded) raw = Buffer.from(raw, 'base64').toString('utf8');
        body = JSON.parse(raw);
      } catch (e) {
        return {
          statusCode: 400,
          body: JSON.stringify({ error: 'Invalid JSON body' }),
          headers,
        };
      }
    }
    if (!body || typeof body !== 'object') {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Body must be a JSON object' }),
        headers,
      };
    }

    const order = normalizeOrder(body);
    const positions = normalizePositions(body);

    if (!order || !order.id || !order.user_name || !order.user_phone_number) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: 'Required fields: id, user_name (or userName), user_phone_number (or numberPhone), total' }),
        headers,
      };
    }

    const insertResult = await insertOrder(order);
    if (!insertResult.ok) {
      return {
        statusCode: 500,
        body: JSON.stringify({ error: insertResult.error || 'Failed to save order' }),
        headers,
      };
    }

    if (positions.length > 0) {
      const posResult = await insertOrderPositions(order.id, positions);
      if (!posResult.ok) {
        console.error('Failed to save order positions:', posResult.error);
      }
    }

    let botToken = (process.env.TELEGRAM_BOT_TOKEN || '').trim();
    if (botToken.toLowerCase().startsWith('bot')) botToken = botToken.slice(3).trim();
    const chatId = (process.env.TELEGRAM_CHAT_ID || '').trim();
    if (botToken && chatId) {
      try {
        const message = buildOrderMessage(order, positions);
        await sendTelegramMessage(botToken, chatId, message);
      } catch (e) {
        console.error('Telegram send error:', e && e.message ? e.message : String(e));
        console.error('TELEGRAM_CHAT_ID из окружения:', chatId, '(проверь: для группы ID отрицательный, бот должен быть в чате)');
      }
    } else {
      console.warn('TELEGRAM_BOT_TOKEN или TELEGRAM_CHAT_ID не заданы — уведомление не отправлено. chatId=', chatId ? 'задан' : 'пусто');
    }

    return {
      statusCode: 200,
      body: JSON.stringify({ ok: true, id: order.id }),
      headers,
    };
  } catch (e) {
    console.error('handler error:', e && e.message ? e.message : String(e), e && e.stack);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: 'Internal server error' }),
      headers,
    };
  }
};
