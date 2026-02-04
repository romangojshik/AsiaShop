## Использование `// MARK:` в Swift

### Зачем нужно

`// MARK:` — это специальный комментарий, который Xcode понимает и использует для:

- **Группировки кода** в списке символов (Outline / Jump Bar)
- **Быстрой навигации** по большим файлам
- **Визуального разделения** логических блоков в коде

### Базовый синтаксис

```swift
// MARK: - Public properties
// MARK: - Private properties
// MARK: - Init
// MARK: - Lifecycle
// MARK: - Public methods
// MARK: - Private methods
```

Правила:
- Всегда начинается с `// MARK:`
- После можно ставить `-` для визуального разделения (принято в стиле Apple)
- Далее — произвольный заголовок секции

### Пример структуры файла

```swift
class BasketViewModel: ObservableObject {

    // MARK: - Public properties

    @Published var positions: [Position] = []

    // MARK: - Private properties

    private let databaseService: DatabaseServiceProtocol

    // MARK: - Init

    init(databaseService: DatabaseServiceProtocol) {
        self.databaseService = databaseService
    }

    // MARK: - Public methods

    func addPosition(_ position: Position) { ... }
    func increaseCount(positionId: String) { ... }

    // MARK: - Private methods

    private func recalculateCost() { ... }
}
```

### Рекомендованный стиль для проекта

- Использовать **русские или английские** заголовки — главное, чтобы было понятно и единообразно.
- Основные секции:
  - `// MARK: - Public properties`
  - `// MARK: - Private properties`
  - `// MARK: - Init`
  - `// MARK: - Lifecycle` (для `View`/`ViewController`)
  - `// MARK: - Public methods`
  - `// MARK: - Private methods`

### Подсказка

В Xcode можно быстро перейти к секции:
- Щёлкнуть по списку символов сверху файла (Jump Bar) и выбрать нужный `MARK`
- Или использовать `⌃6` (Control + 6), чтобы открыть список символов и фильтровать по `MARK`.

