# Скрипты YDB для AsiaShop

## Таблица заказов `order`

Файл `create-order-table.yql` создаёт таблицу заказов с полями, аналогичными Firebase:

| Поле         | Тип       | Описание                          |
|-------------|-----------|-----------------------------------|
| id          | Utf8      | UUID заказа (PRIMARY KEY)         |
| user_name   | Utf8      | Имя клиента                       |
| number_phone| Utf8      | Номер телефона                    |
| status      | Utf8      | Статус (Новый, Готовиться, …)     |
| total       | Double    | Сумма заказа                      |
| created_at  | Timestamp | Время создания                    |
| ready_by    | Timestamp | К какому времени приготовить (опц.) |
| positions   | Json      | Массив позиций (id, count, cost, product) |

### Как выполнить

1. Открой [Yandex Cloud Console](https://console.yandex.cloud) → YDB → твоя база (asiashopydb).
2. Вкладка **«Запросы»** / **Query** — вставь содержимое `create-order-table.yql` и выполни.
3. Либо через [ydb CLI](https://ydb.tech/docs/en/reference/ydb-cli/):  
   `ydb -e <endpoint> -d <database> yql -f create-order-table.yql`

После создания таблицы задеплой Cloud Function `orders-api` и задай переменные окружения (YDB_*, TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID).

---

## Упрощённая таблица `orders` (только 4 поля)

Файл `create-order-table-simple.yql` создаёт таблицу только с полями: **id**, **user_name**, **user_phone_number**, **total**.

1. В консоли YDB удали старую таблицу `orders` (если есть): выбери таблицу → **Удалить таблицу**.
2. В **Запросы** выполни содержимое `create-order-table-simple.yql`.
3. Задеплой обновлённую функцию `orders-api` (она пишет только эти 4 поля).
