# AsiaShop Catalog API (Cloud Function)

HTTP-функция возвращает каталог сетов из **YDB**.

## Переменные окружения в Cloud Function

| Переменная | Описание |
|------------|----------|
| `YDB_ENDPOINT` | Endpoint YDB, например `grpcs://ydb.serverless.yandexcloud.net:2135` |
| `YDB_DATABASE` | Путь к БД, например `/ru-central1/b1g.../etn` (из консоли YDB) |
| `YDB_METADATA_CREDENTIALS` | `1` — использовать метаданные (обязательно для Cloud Function) |

## Таблицы в YDB

Используются две таблицы (БД `asiashopydb`):

**Таблица `set`:**  
`id`, `title`, `imageURL`, `description`, `price`, `composition`

**Таблица `nutrition`:**  
`set_id`, `callories`, `fats`, `protein`, `weight`

Данные объединяются по `set.id = nutrition.set_id`. В ответе у каждого сета есть объект `nutrition` с полями из таблицы `nutrition` (или `null`-поля, если записи для этого сета нет).

## Ответ API

```json
{
  "sets": [
    {
      "id": "1",
      "title": "Асами",
      "imageURL": "asami",
      "description": "...",
      "price": 99.9,
      "composition": "...",
      "nutrition": {
        "callories": "1200ккал",
        "weight": "930г",
        "protein": null,
        "fats": null
      }
    }
  ]
}
```

## Ошибка "Database not found" (код 5)

YDB не находит базу по пути из `YDB_DATABASE`. Нужно подставить **точный** путь из консоли:

1. Открой **Yandex Cloud Console** → **YDB** (или **Yandex Database**).
2. Выбери свою базу (например, `asiashopydb`).
3. На странице базы найди поле **«Путь к базе»** / **«Database path»** — это строка вида  
   `/ru-central1/b1gxxxxxxxxxxxxxxxxxx/etnxxxxxxxxxxxxxxxxxx`  
   (два идентификатора: каталог и база).
4. Скопируй путь **целиком**, без пробелов и **без слэша в конце**.
5. В **Cloud Functions** → твоя функция → **Редактировать** → **Переменные окружения** задай  
   `YDB_DATABASE` = этот путь (только значение, без кавычек).
6. Сохрани и заново вызови каталог. В логах функции будет строка `YDB: database path= ...` — она должна совпадать с путём из консоли YDB.

Функция и база должны быть в одном облаке и каталоге (или у сервисного аккаунта функции есть доступ к каталогу с YDB).

## Деплой

1. В настройках функции указать переменные окружения (см. таблицу выше).
2. Сервисному аккаунту функции выдать роль на чтение из YDB (например, `ydb.editor` или `ydb.viewer` на нужную БД).
3. Собрать ZIP (код + `node_modules` или только код, если зависимости ставятся при деплое) и загрузить в Cloud Function.
