/**
 * HTTP-функция каталога: сеты из таблицы `sets`, питательность из таблицы `nutritions` (join по product_id).
 * Переменные окружения: YDB_ENDPOINT, YDB_DATABASE, YDB_METADATA_CREDENTIALS=1
 *
 * В ответе nutrition использует ключи под Swift (Nutrition.swift): proteins, carbs, quantity и т.д.
 * Колонка YDB `protein` мапится в JSON как `proteins`.
 */

const TABLE_SET = '`sets`';
const TABLE_NUTRITION = '`nutritions`';

function noop() {}
const logger = {
  debug: noop,
  trace: noop,
  info: noop,
  warn: noop,
  error: noop,
};

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
  if (driver) return driver;
  const sdk = getYdbSdk();
  if (!sdk) return null;
  try {
    let endpoint = (process.env.YDB_ENDPOINT || '').trim();
    const database = (process.env.YDB_DATABASE || '').trim();
    if (!endpoint || !database) {
      console.error('YDB: YDB_ENDPOINT или YDB_DATABASE не заданы');
      return null;
    }
    console.log('YDB: endpoint=', endpoint, 'database=', database);
    if (!endpoint.startsWith('grpcs://') && !endpoint.startsWith('https://')) {
      endpoint = 'grpcs://' + endpoint;
    }
    const authService = new sdk.MetadataAuthService();
    driver = new sdk.Driver({
      endpoint,
      database,
      authService,
      logger: typeof sdk.getDefaultLogger === 'function' ? sdk.getDefaultLogger() : logger,
    });
    const ok = await driver.ready(10000);
    if (!ok) {
      driver = null;
      console.error('YDB: driver.ready() истёк по таймауту');
      return null;
    }
    console.log('YDB: driver.ready() ok');
    return driver;
  } catch (e) {
    driver = null;
    console.error('YDB getDriver error:', e && e.message ? e.message : String(e), e && e.stack);
    return null;
  }
}

function runQuery(query) {
  return driver.tableClient.withSessionRetry(
    (session) => session.executeQuery(query),
    5000,
    3
  );
}

function rowsFromResult(result, logLabel) {
  if (!result || !result.resultSets || !result.resultSets.length) {
    if (logLabel) console.log('YDB: ' + logLabel + ' — нет resultSets');
    return [];
  }
  const rawRows = result.resultSets[0].rows || [];
  if (logLabel) console.log('YDB: ' + logLabel + ' — сырых строк:', rawRows.length);
  const sdk = getYdbSdk();
  if (!sdk || !sdk.TypedData) return [];
  const rows = sdk.TypedData.createNativeObjects(result.resultSets[0]);
  return Array.isArray(rows) ? rows : [];
}

function rowToSetRow(r) {
  const id = r.id ?? r.Id ?? '';
  const title = r.title ?? r.Title ?? '';
  const imageURL = r.imageURL ?? r.image_url ?? '';
  const description = r.description ?? r.Description ?? '';
  const price = Number(r.price ?? r.Price ?? 0);
  const composition = r.composition ?? r.Composition ?? null;
  return {
    id: String(id),
    title: String(title),
    imageURL: String(imageURL),
    description: String(description),
    price,
    composition: composition != null ? String(composition) : null,
  };
}

/** Строка из YDB; для клиента белки — поле proteins (как в iOS). */
function rowToNutrition(r) {
  const productId = r.product_id ?? r.productId ?? r.set_id ?? r.setId ?? '';
  const callories = r.callories ?? r.Callories ?? null;
  const caloriesPer100g = r.caloriesPer100g ?? r.CaloriesPer100g ?? callories ?? null;
  const fats = r.fats ?? r.Fats ?? null;
  const proteinsCol = r.proteins ?? r.Proteins ?? r.protein ?? r.Protein ?? null;
  const carbs = r.carbs ?? r.Carbs ?? null;
  const weight = r.weight ?? r.Weight ?? null;
  const quantity = r.quantity ?? r.Quantity ?? null;
  return {
    product_id: String(productId),
    caloriesPer100g: caloriesPer100g != null ? String(caloriesPer100g) : null,
    callories: callories != null ? String(callories) : null,
    fats: fats != null ? String(fats) : null,
    proteins: proteinsCol != null ? String(proteinsCol) : null,
    carbs: carbs != null ? String(carbs) : null,
    weight: weight != null ? String(weight) : null,
    quantity: quantity != null ? String(quantity) : null,
  };
}

function emptyNutrition() {
  return {
    caloriesPer100g: null,
    callories: null,
    fats: null,
    proteins: null,
    carbs: null,
    weight: null,
    quantity: null,
  };
}

async function loadNutritionRows() {
  const queries = [
    `SELECT product_id, caloriesPer100g, callories, fats, proteins, carbs, weight, quantity FROM ${TABLE_NUTRITION}`,
    `SELECT product_id, caloriesPer100g, callories, fats, protein, weight, quantity FROM ${TABLE_NUTRITION}`,
    `SELECT product_id, callories, fats, proteins, carbs, weight, quantity FROM ${TABLE_NUTRITION}`,
    `SELECT set_id AS product_id, caloriesPer100g, callories, fats, protein, weight, quantity FROM ${TABLE_NUTRITION}`,
    `SELECT set_id AS product_id, callories, fats, protein, weight, quantity FROM ${TABLE_NUTRITION}`,
  ];
  let lastErr = null;
  for (const q of queries) {
    try {
      const nutritionResult = await runQuery(q);
      return rowsFromResult(nutritionResult, 'nutrition').map(rowToNutrition);
    } catch (e) {
      lastErr = e;
    }
  }
  console.error(
    'YDB: все варианты запроса nutritions не удались:',
    lastErr && lastErr.message ? lastErr.message : String(lastErr)
  );
  return [];
}

async function loadSetsFromYdb() {
  const d = await getDriver();
  if (!d) {
    console.error('YDB: getDriver() вернул null');
    return null;
  }
  try {
    const setsResult = await runQuery(
      `SELECT id, title, imageURL, description, price, composition FROM ${TABLE_SET}`
    );
    const setRows = rowsFromResult(setsResult, 'set').map(rowToSetRow);

    let nutritionRows = [];
    try {
      nutritionRows = await loadNutritionRows();
    } catch (nutErr) {
      console.error(
        'YDB: loadNutritionRows не удался (сеты всё равно отдаём):',
        nutErr && nutErr.message ? nutErr.message : String(nutErr)
      );
    }

    console.log('YDB: set rows=', setRows.length, 'nutrition rows=', nutritionRows.length);
    const nutritionByProductId = {};
    for (const n of nutritionRows) {
      nutritionByProductId[n.product_id] = {
        caloriesPer100g: n.caloriesPer100g,
        callories: n.callories,
        fats: n.fats,
        proteins: n.proteins,
        carbs: n.carbs,
        weight: n.weight,
        quantity: n.quantity,
      };
    }
    const sets = setRows.map((s) => ({
      ...s,
      nutrition: nutritionByProductId[s.id] || emptyNutrition(),
    }));
    return sets;
  } catch (e) {
    console.error('YDB loadSetsFromYdb error:', e && e.message ? e.message : String(e), e && e.stack);
    return null;
  }
}

module.exports.handler = async function (event, context) {
  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
  };
  try {
    const method = event.httpMethod || event.requestContext?.http?.method || 'GET';
    if (method !== 'GET') {
      return {
        statusCode: 405,
        body: JSON.stringify({ error: 'Method not allowed' }),
        headers,
      };
    }

    let sets = await loadSetsFromYdb();
    if (sets === null) {
      console.error('YDB: loadSetsFromYdb() вернул null');
      sets = [];
    }
    console.log('YDB: возвращаем sets.length=', sets.length);

    return {
      statusCode: 200,
      body: JSON.stringify({ sets }),
      headers,
    };
  } catch (e) {
    console.error('handler error:', e && e.message ? e.message : String(e), e && e.stack);
    return {
      statusCode: 200,
      body: JSON.stringify({ sets: [], _error: 'Catalog temporarily unavailable' }),
      headers,
    };
  }
};
