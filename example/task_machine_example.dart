import 'dart:async';

import 'package:task_machine/task_machine.dart';

void main() async {
  TaskManager taskManager = TaskManager();
  taskManager.tasksStream.listen((tasks) {
    print(tasks);
  });
  taskManager.start(GetUserInfoTask(userId: 'user-id'));
  taskManager.start(WatchChatMessagesTask(chatId: 'chat-id'));
}

class UserInfo {}

typedef ID = String;

// short living tasks
class GetUserInfoTask extends Task<ID, UserInfo> {
  GetUserInfoTask({required String userId}) : super(input: userId);

  @override
  Future<void> execute() async {
    // from the data access layer service
    // UserDAO.getUserInfo(String id)
    await Future.delayed(const Duration(seconds: 1));
    final info = UserInfo();
    complete(info);
  }
}

class ChatMessage {}

// long living task
class WatchChatMessagesTask extends Task<ID, List<ChatMessage>> {
  StreamSubscription? _subscription;
  WatchChatMessagesTask({required String chatId}) : super(input: chatId);

  @override
  Future<void> execute() async {
    final chatMessageStream = Stream.value([ChatMessage()]);
    // cancel previous subscription
    _subscription?.cancel();
    _subscription = chatMessageStream.listen((messages) {
      onData(messages);
    });
  }
}
