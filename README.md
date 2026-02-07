# AsiaShop

<img width="430" height="920" alt="Simulator Screenshot - iPhone 17 Pro - 2025-12-01 at 15 51 03" src="https://github.com/user-attachments/assets/4288a7a0-2ae0-44b4-9b2f-a91e54ad0094" />

## Уведомления в Telegram при новом заказе

При создании заказа в Firestore Cloud Function отправляет сообщение в Telegram.

### Что уже сделано

- В `firebase.json` подключена папка `functions`.
- В `functions/index.js` добавлена функция `sendOrderToTelegram`: при появлении документа в коллекции `orders` формируется сообщение и отправляется в бот.

### Что нужно сделать

1. **Создать бота в Telegram**
   - Напишите [@BotFather](https://t.me/BotFather), команда `/newbot`.
   - Сохраните выданный **токен** (например, `123456789:ABCdefGHI...`).

2. **Узнать chat_id**
   - Напишите вашему боту любое сообщение (например, «Привет»).
   - Откройте в браузере (подставьте свой токен):
     ```
     https://api.telegram.org/bot<ВАШ_ТОКЕН>/getUpdates
     ```
   - В ответе найдите `"chat":{"id": 123456789}` — это ваш **chat_id**. Для группы id будет отрицательным (например, `-1001234567890`).

3. **Задать конфиг Firebase**
   В корне проекта выполните:
   ```bash
   firebase functions:config:set telegram.bot_token="ВАШ_ТОКЕН" telegram.chat_id="ВАШ_CHAT_ID"
   ```
   Пример:
   ```bash
   firebase functions:config:set telegram.bot_token="123456789:ABCdef..." telegram.chat_id="-1001234567890"
   ```

4. **Задеплоить функции**
   ```bash
   firebase deploy --only functions
   ```

После этого каждый новый заказ в приложении будет приводить к появлению сообщения в выбранном чате Telegram.
