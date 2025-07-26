import '../model/message.dart';
import '../model/ai_model.dart';

class ChatPresenter {
  final AIModel _ai = AIModel();
  final List<Message> messages = [];

  Future<void> sendMessage(String userText) async {
    messages.add(Message(text: userText, isUser: true));
    final reply = await _ai.sendMessageToTherapistBot(userText);
    messages.add(Message(text: reply, isUser: false));
  }

  void reset() {
    messages.clear();
    // optionally call backend reset endpoint here
  }
}
