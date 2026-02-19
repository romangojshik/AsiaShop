/**
 * Упрощённая HTTP-функция: отдаёт каталог сетов статически.
 * Так мы быстро подключим приложение, а чтение из YDB добавим позже.
 */

module.exports.handler = async function (event, context) {
  const method = event.httpMethod || event.requestContext?.http?.method || 'GET';
  if (method !== 'GET') {
    return {
      statusCode: 405,
      body: JSON.stringify({ error: 'Method not allowed' }),
      headers: { 'Content-Type': 'application/json' },
    };
  }

  // Здесь можно руками добавить все ваши сеты.
  const sets = [
    {
      id: '1',
      title: 'Асами',
      imageURL: 'asami',
      description:
        'Сочный лосось, кремовый сыр, хрустящие огурец и снежный краб. Идеальный баланс в каждом кусочке. Попробуй яркое настроение!',
      price: 99.9,
      composition: 'Лосось, сыр, огурец, снежный краб, тобико.',
      nutrition: {
        callories: '1200ккал',
        fats: null,
        protein: null,
        weight: '930г',
      },
    },
  ];

  return {
    statusCode: 200,
    body: JSON.stringify({ sets }),
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  };
};
