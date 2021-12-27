// import 'dart:async';

// import 'package:task_machine/task_machine.dart';

// void main() async {
//   TaskManager taskManager = TaskManager();
//   taskManager.tasksStream.listen((tasks) {
//     print(tasks);
//   });
//   taskManager.add(GetUserInfoTask());
//   taskManager.add(WatchChatMessagesTask());
// }

// class UserInfo {
//   final ID id;
//   UserInfo({required this.id});
// }

// typedef ID = String;

// // short living tasks
// class GetUserInfoTask extends Task<ID, UserInfo> {
//   @override
//   Future<void> execute(ID userId) async {
//     // from the data access layer service
//     // UserDAO.getUserInfo(String id)
//     await Future.delayed(const Duration(seconds: 1));
//     final info = UserInfo(id: userId);
//     complete(data: info);
//   }
// }

// class ChatMessage {}

// // long living task
// class WatchChatMessagesTask extends Task<ID, List<ChatMessage>> {
//   StreamSubscription? _subscription;

//   @override
//   Future<void> execute(ID chatId) async {
//     final chatMessageStream = Stream.value([ChatMessage()]);
//     // cancel previous subscription
//     _subscription?.cancel();
//     _subscription = chatMessageStream.listen((messages) {
//       onData(messages);
//     });
//   }
// }
