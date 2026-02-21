# AsiaShop — уведомления в Telegram через Yandex Cloud (Этап 1)

Функция для **Yandex Cloud Functions**: по расписанию читает новые заказы из Firestore и отправляет их в Telegram. Данные и приложение пока остаются во Firebase.

## Что нужно

1. Аккаунт [Yandex Cloud](https://console.cloud.yandex.ru), каталог (folder).
2. Ключ сервисного аккаунта Firebase (JSON) — [Firebase Console → Project settings → Service accounts → Generate new private key](https://console.firebase.google.com/project/_/settings/serviceaccounts/adminsdk).
3. Токен Telegram-бота и `chat_id`.

## Переменные окружения функции

| Переменная | Описание |
|------------|----------|
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Строка с JSON ключа Firebase (весь файл ключа в одну строку). |
| `TELEGRAM_BOT_TOKEN` | Токен бота (например, `123456789:ABCdef...`). |
| `TELEGRAM_CHAT_ID` | ID чата или группы (например, `-1001234567890`). |

В Lockbox или в настройках функции значение `FIREBASE_SERVICE_ACCOUNT_JSON` задаётся как одна строка: содержимое файла `*-firebase-adminsdk-*.json`, можно минифицировать (без переносов).

## Деплой через Yandex Cloud Console

1. [Cloud Functions](https://console.cloud.yandex.ru/folders/<FOLDER_ID>/functions) → Создать функцию.
2. Среда выполнения: **Node.js** (18 или 20).
3. Способ загрузки: **ZIP** или репозиторий.
   - В корне ZIP: `index.js`, папка `node_modules` (выполни в папке `yandex-cloud`: `npm install`, затем упакуй `index.js` и `node_modules`).
4. Точка входа: `index.handler`.
5. Переменные окружения: добавить `FIREBASE_SERVICE_ACCOUNT_JSON`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID` (или привязать секрет из Lockbox).
6. Создать **триггер** типа «Таймер» (расписание), например `rate(5 minutes)` или cron `*/5 * * * ? *` (каждые 5 минут).

## Деплой через CLI (yc)

```bash
cd yandex-cloud
npm install
zip -r function.zip index.js node_modules
yc serverless function create --name=asiashop-telegram --runtime=nodejs18
yc serverless function version create \
  --function-name=asiashop-telegram \
  --runtime=nodejs18 \
  --entrypoint=index.handler \
  --source-path=function.zip \
  --environment FIREBASE_SERVICE_ACCOUNT_JSON="$(cat /path/to/firebase-key.json | jq -c .)" \
  --environment TELEGRAM_BOT_TOKEN="YOUR_TOKEN" \
  --environment TELEGRAM_CHAT_ID="YOUR_CHAT_ID"
```

Триггер по расписанию создаётся отдельно в консоли или через `yc serverless trigger create timer ...`.

## Firestore

- Коллекция: `orders`.
- Нужно поле `createdAt` (тип Timestamp). Функция запрашивает заказы за последние 10 минут.

В Firebase Console в правилах Firestore разреши чтение коллекции `orders` для сервисного аккаунта (по ключу из `FIREBASE_SERVICE_ACCOUNT_JSON` доступ идёт от имени этого аккаунта).

## Заказы в YDB + Telegram (orders-api)

Отдельная HTTP-функция **orders-api** принимает POST с заказом, пишет в таблицу YDB `order` и шлёт уведомление в Telegram.

1. Создай таблицу в YDB: см. [ydb-scripts/README.md](ydb-scripts/README.md) и выполни `create-order-table.yql`.
2. Деплой функции: папка [orders-api](orders-api), переменные окружения: `YDB_ENDPOINT`, `YDB_DATABASE`, `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`. Токен и chat_id **не** храни в коде — только в настройках функции.
3. Создай HTTP-триггер или привяжи функцию к API Gateway и скопируй URL.
4. В приложении задай URL API заказов, чтобы заказы шли в YDB и в Telegram:
   - В коде: `YandexOrderService.shared.ordersAPIURL = "https://твой-url-заказов"` (например в `AsiaShopApp` или `AppDelegate` при старте).
   - Если `ordersAPIURL` пустой, заказы по-прежнему отправляются в Firebase.

Подробности: [orders-api/README.md](orders-api/README.md).

## Дальше

После проверки Этапа 1 см. [MIGRATION_YANDEX.md](../MIGRATION_YANDEX.md) — перенос данных и API в Yandex (Этапы 2–6).
