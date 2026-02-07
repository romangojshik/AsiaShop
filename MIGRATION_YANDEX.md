# Полный переход с Firebase на Yandex Cloud

План переноса AsiaShop с [Firebase](https://console.firebase.google.com) на [Yandex Cloud](https://yandex.cloud).

---

## Что сейчас в Firebase

| Сервис | Назначение |
|--------|------------|
| **Firebase Auth** | Регистрация и вход по email/паролю |
| **Firestore** | Коллекции: `users`, `orders`, `sushi`, `sets`, `products` |
| **Cloud Functions** | Уведомления в Telegram при новом заказе (не задеплоены из‑за Blaze) |

---

## Целевая архитектура в Yandex Cloud

| Задача | Сервис Yandex Cloud |
|--------|----------------------|
| База данных | **Yandex Database (YDB)** или **Object Storage** (JSON) |
| API для приложения | **Yandex Cloud Functions** (HTTP-триггеры) |
| Аутентификация | Своя логика в функциях: регистрация/логин → выдача **JWT** |
| Уведомления в Telegram | **Yandex Cloud Functions** (триггер по расписанию) |

---

## Этапы миграции

### Этап 1. Уведомления в Telegram на Yandex (без переноса данных)

**Цель:** перестать зависеть от Firebase для отправки в Telegram; Firestore и приложение пока не трогаем.

1. Зарегистрироваться в [Yandex Cloud](https://console.cloud.yandex.ru), создать каталог (folder).
2. Включить сервисы: **Cloud Functions**, **Lockbox** (секреты).
3. Экспортировать ключ сервисного аккаунта Firebase (JSON) из [Firebase Console → Project settings → Service accounts](https://console.firebase.google.com/project/_/settings/serviceaccounts/adminsdk).
4. Создать функцию в Yandex Cloud Functions:
   - **Триггер:** по расписанию (каждые 2–5 минут).
   - **Код:** читает новые документы из Firestore (коллекция `orders`) через Firebase Admin SDK, отправляет в Telegram через Bot API.
5. В **Lockbox** положить секреты: ключ Firebase (JSON), `TELEGRAM_BOT_TOKEN`, `TELEGRAM_CHAT_ID`.
6. Задеплоить функцию.

**Результат:** уведомления идут из Yandex, приложение и данные остаются во Firebase.

---

### Этап 2. База данных и API в Yandex

**Цель:** перенести данные и отдать их приложению через HTTP API.

1. **Выбрать хранилище:**
   - **YDB** — таблицы, хорошая масштабируемость, нужна схема. [Документация](https://yandex.cloud/en/docs/ydb/).
   - **Object Storage** — JSON-файлы по «коллекциям», проще старт. [Документация](https://yandex.cloud/en/docs/storage/).

2. **Создать структуру данных** (аналог Firestore):
   - `users` — id, email, passwordHash, name, phone, address
   - `sushi` — id, title, imageURL, price, description, weight, …
   - `sets` — то же для сетов
   - `orders` — id, userName, numberPhone, status, total, createdAt, readyBy, positions (JSON)

3. **Экспорт из Firestore:** выгрузить коллекции `sushi`, `sets`, `users`, `orders` (через консоль или скрипт) и загрузить в YDB/Object Storage по выбранной схеме.

4. **Создать HTTP-функции в Yandex Cloud Functions:**
   - `GET /sushi`, `GET /sets` (или `GET /catalog` — sushi + sets)
   - `GET /profile` (по JWT)
   - `PUT /profile` (по JWT)
   - `POST /orders` (тело заказа; JWT опционально)
   - `POST /auth/register`, `POST /auth/login` (email, password → JWT)

5. Функции читают/пишут данные в YDB или Object Storage; для заказов — также сохранять в выбранное хранилище.

**Результат:** бэкенд и данные живут в Yandex, API готов для приложения.

---

### Этап 3. Аутентификация в Yandex

**Цель:** заменить Firebase Auth на свою логику с JWT.

1. В одной из функций (или отдельной) реализовать:
   - **POST /auth/register:** хэш пароля (bcrypt/argon2), сохранение пользователя в `users`, выдача JWT (id, email в payload).
   - **POST /auth/login:** проверка email/пароля, выдача JWT.
2. JWT подписывать секретом из Lockbox; срок жизни, например, 7–30 дней.
3. В остальных функциях (profile, orders) проверять заголовок `Authorization: Bearer <JWT>` и при необходимости требовать авторизацию.

**Результат:** вход и регистрация полностью на Yandex, без Firebase Auth.

---

### Этап 4. Изменения в iOS-приложении

**Цель:** приложение общается только с Yandex API, Firebase не используется.

1. **Удалить Firebase из проекта:**
   - Удалить пакеты Firebase (FirebaseAuth, FirebaseFirestore и т.д.).
   - Удалить `GoogleService-Info.plist` или перестать его использовать.

2. **Добавить слой работы с API:**
   - Базовый URL для всех запросов: адрес твоих Yandex Cloud Functions (HTTP-триггеры).
   - Сохранение JWT (Keychain/UserDefaults) после логина/регистрации.
   - Запросы через `URLSession`: GET/POST/PUT с заголовком `Authorization: Bearer <JWT>` где нужно.

3. **Заменить вызовы по сервисам:**
   - `AuthService`: вместо Firebase Auth — вызовы `POST /auth/login`, `POST /auth/register`; сохранение и подстановка JWT.
   - `DatabaseService`: вместо Firestore — вызовы `GET /sushi`, `GET /sets`, `GET /profile`, `PUT /profile`, `POST /orders`.

4. Модели данных (Order, Profile, Sushi, SushiSet и т.д.) оставить; изменить только то, как они получаются и отправляются (парсинг JSON из ответов API).

**Результат:** приложение не зависит от Firebase SDK и консоли Firebase.

---

### Этап 5. Уведомления в Telegram из Yandex БД

**Цель:** функция «новый заказ → Telegram» читает заказы уже из Yandex (YDB/Object Storage), а не из Firestore.

1. В функции по расписанию заменить чтение из Firestore на чтение из YDB или Object Storage (новые записи в `orders`).
2. Логику форматирования сообщения и вызов Telegram Bot API оставить как есть.
3. После проверки можно отключить старую функцию, которая читала из Firestore.

**Результат:** весь бэкенд и уведомления работают только в Yandex Cloud.

---

### Этап 6. Отказ от Firebase

1. Убедиться, что приложение и админка (если есть) больше не обращаются к Firebase.
2. Сделать бэкап данных из Firestore (экспорт), если ещё не сделано.
3. В [Firebase Console](https://console.firebase.google.com) удалить проект или оставить его выключенным.

**Результат:** полный переход на Yandex Cloud, от console.firebase.google.com можно отказаться.

---

## Порядок работ (кратко)

1. **Сейчас:** Этап 1 — уведомления в Telegram через Yandex Cloud Functions + чтение заказов из Firestore.
2. **Дальше:** Этап 2 — перенос данных и API в Yandex.
3. **Затем:** Этап 3 — своя авторизация с JWT.
4. **Потом:** Этап 4 — правки iOS, отказ от Firebase SDK.
5. **В конце:** Этапы 5 и 6 — Telegram только из Yandex БД, отключение Firebase.

---

## Полезные ссылки

- [Yandex Cloud Functions](https://yandex.cloud/en/services/functions) — запуск кода по HTTP и по расписанию.
- [Yandex Database (YDB)](https://yandex.cloud/en/docs/ydb/) — основная БД.
- [Lockbox](https://yandex.cloud/en/docs/lockbox/) — хранение секретов (токены, ключи).
- [Подключение к YDB из Cloud Functions](https://yandex.cloud/en/docs/functions/tutorials/connect-to-ydb) (на Python; для Node.js идея та же).

**Код для Этапа 1** уже добавлен в папку **`yandex-cloud/`** в корне проекта:
- `index.js` — обработчик функции (чтение заказов из Firestore, отправка в Telegram).
- `package.json` — зависимости (firebase-admin).
- `README.md` — инструкция по деплою в Yandex Cloud Functions.
