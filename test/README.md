cle# ChatWave Testing Guide

This directory contains comprehensive tests for the ChatWave application, covering unit tests, widget tests, and integration tests.

## Test Structure

### Bloc Tests
- **`blocs/message_bloc_test.dart`** - Tests for MessageBloc functionality
  - Message fetching, sending, and receiving
  - Message search functionality
  - Message reactions
  - Message forwarding
- **`blocs/chat_bloc_test.dart`** - Tests for ChatBloc functionality
  - Chat list management
  - Chat operations (create, update, delete)
  - Message handling within chats

### Widget Tests
- **`widgets/chat_search_bar_test.dart`** - Tests for ChatSearchBar component
  - Search input functionality
  - Search button interactions
  - Navigation between search results
- **`widgets/message_bubble_test.dart`** - Tests for MessageBubble component
  - Different message type rendering
  - Reaction display
  - Long-press interactions
  - Group chat sender names

### Integration Tests
- **`integration/chat_flow_test.dart`** - End-to-end chat flow tests
  - Complete message sending workflow
  - Search functionality integration
  - Reaction and forwarding features
  - Chat options and call features

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Files
```bash
# Run only bloc tests
flutter test test/blocs/

# Run only widget tests
flutter test test/widgets/

# Run only integration tests
flutter test test/integration/

# Run a specific test file
flutter test test/blocs/message_bloc_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
```

### Run Tests in Watch Mode
```bash
flutter test --watch
```

## Test Dependencies

The following packages are required for testing:
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.24.0
  bloc_test: ^9.1.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

## Test Coverage

### Current Coverage
- ✅ **MessageBloc**: Core message operations, search, reactions, forwarding
- ✅ **ChatBloc**: Chat list management and operations
- ✅ **ChatSearchBar**: Search functionality and UI interactions
- ✅ **MessageBubble**: Message display and interaction features
- ✅ **Chat Flow**: End-to-end user workflows

### Areas for Future Testing
- **Repository Layer**: API integration and data persistence
- **Service Layer**: Mock data service and external integrations
- **Navigation**: Screen transitions and routing
- **State Persistence**: App state management across sessions
- **Performance**: Memory usage and rendering performance

## Writing New Tests

### For New Blocs
1. Create test file in `test/blocs/`
2. Test all events and state transitions
3. Mock dependencies using `mockito`
4. Verify state emissions and side effects

### For New Widgets
1. Create test file in `test/widgets/`
2. Test rendering with different data
3. Test user interactions (tap, long-press, etc.)
4. Test edge cases and error states

### For New Features
1. Create integration test in `test/integration/`
2. Test complete user workflows
3. Test feature interactions
4. Test error handling and edge cases

## Best Practices

1. **Test Naming**: Use descriptive test names that explain the expected behavior
2. **Arrange-Act-Assert**: Structure tests with clear setup, action, and verification
3. **Mocking**: Mock external dependencies to isolate unit tests
4. **Edge Cases**: Test error conditions, empty states, and boundary conditions
5. **Performance**: Keep tests fast and avoid unnecessary delays
6. **Maintenance**: Update tests when changing functionality

## Troubleshooting

### Common Issues
- **Import Errors**: Ensure test files import the correct dependencies
- **Mock Issues**: Verify mock setup and expectations
- **State Issues**: Check Bloc state management in tests
- **Widget Issues**: Ensure proper widget tree setup in tests

### Debugging Tests
```bash
# Run tests with verbose output
flutter test --verbose

# Run tests with debugger
flutter test --start-paused

# Run specific test with debug output
flutter test test/blocs/message_bloc_test.dart --verbose
```
