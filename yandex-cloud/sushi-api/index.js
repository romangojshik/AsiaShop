/**
 * HTTP-функция каталога суши: читает таблицу `sushi` в YDB,
 * питательность из таблицы `nutritions` (join по product_id).
 * Переменные окружения: YDB_ENDPOINT, YDB_DATABASE, YDB_METADATA_CREDENTIALS=1
 */

const TABLE_SUSHI = '`sushi`';
const TABLE_NUTRITION = 'nutritions';

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
    // Для отладки "Database not found": сверь с путём в консоли YDB (без слэша в конце)
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

function rowToSushiNutrition(r) {
  const productId = r.product_id ?? r.productId ?? '';
  const callories = r.callories ?? r.Callories ?? null;
  const fats = r.fats ?? r.Fats ?? null;
  const protein = r.protein ?? r.Protein ?? null;
  const weight = r.weight ?? r.Weight ?? null;
  return {
    product_id: String(productId),
    callories: callories != null ? String(callories) : null,
    fats: fats != null ? String(fats) : null,
    protein: protein != null ? String(protein) : null,
    weight: weight != null ? String(weight) : null,
  };
}

function rowToSushiRow(r) {
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
    nutrition: null, // заполняется в loadSushiFromYdb
  };
}

async function loadSushiFromYdb() {
  const d = await getDriver();
  if (!d) {
    console.error('YDB: getDriver() вернул null (sushi)');
    return null;
  }
  try {
    const [sushiResult, nutritionResult] = await Promise.all([
      runQuery(`SELECT id, title, imageURL, description, price, composition FROM ${TABLE_SUSHI}`),
      runQuery(`SELECT product_id, callories, fats, protein, weight FROM ${TABLE_NUTRITION}`),
    ]);
    const sushiRows = rowsFromResult(sushiResult, 'sushi').map(rowToSushiRow);
    const nutritionRows = rowsFromResult(nutritionResult, 'nutrition').map(rowToSushiNutrition).filter((n) => n.product_id);
    console.log('YDB: sushi rows=', sushiRows.length, 'nutrition rows=', nutritionRows.length);

    const nutritionByProductId = {};
    for (const n of nutritionRows) {
      nutritionByProductId[n.product_id] = {
        callories: n.callories,
        fats: n.fats,
        protein: n.protein,
        weight: n.weight,
      };
    }
    const emptyNutrition = { callories: null, fats: null, protein: null, weight: null };
    const sushi = sushiRows.map((s) => ({
      ...s,
      nutrition: nutritionByProductId[s.id] || emptyNutrition,
    }));

    return sushi;
  } catch (e) {
    console.error('YDB loadSushiFromYdb error:', e && e.message ? e.message : String(e), e && e.stack);
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

    let sushi = await loadSushiFromYdb();
    if (sushi === null) sushi = [];

    console.log('YDB: возвращаем sushi.length =', sushi.length);

    return {
      statusCode: 200,
      body: JSON.stringify({ sushi }),
      headers,
    };
  } catch (e) {
    console.error('handler error:', e && e.message ? e.message : String(e), e && e.stack);
    return {
      statusCode: 200,
      body: JSON.stringify({ sushi: [], _error: 'Sushi catalog temporarily unavailable' }),
      headers,
    };
  }
};
