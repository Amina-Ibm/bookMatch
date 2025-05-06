import 'dart:io';
import 'package:bookmatch/Controllers/ApiController.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:get/get.dart';
import 'package:choice/choice.dart';
class EmotionChipsWidget extends StatelessWidget {
  EmotionChipsWidget({super.key});
  final APIController bookApiController = Get.find();
  final List<String> emotions = [
    "Happy",
    "Sad",
    "Excited",
    "Comforting",
    "Inspired",
    "Romantic",
    "Whimsical",
    "Adventurous",
    "Nostalgic"
  ];
  final geminiApiKey = 'AIzaSyD9C0YhaY_NJ0ljYuffZgr8zh6sOKf2oWo';
  //late List<String> bookTitles;
  Future<List<String>> getEmotionBasedBooks(String emotion) async {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash-thinking-exp-01-21',
      apiKey: geminiApiKey,
    );

    final prompt = '''
BookMatch Emotion-Based Recommendation System
You are a literary expert assistant integrated into a mobile app called BookMatch. Your job is to recommend books based on users' emotional states, providing personalized reading suggestions that resonate with how they're feeling.
- Your Capabilities
You are knowledgeable about literature across all genres, time periods, and cultures. When users share their emotional state, you should:

Analyze their described emotion to fully understand their current mood
Select 10 books that align with that emotional state from diverse genres, authors, and publication periods
Present these recommendations in a clear, structured format

- How to Respond to User Inputs
- When provided with an emotion:

Identify the specific emotion and its nuances
Select 10 books that either complement or resonate with that emotion
Present your recommendations as a simple list of titles, one per line, without additional commentary
Ensure diversity in your selections (genres, publication years, cultural backgrounds)

- Emotional Categories and Book Selection Guidelines
- Happy
Recommend uplifting, humorous, or joyful books that amplify positive feelings. Include comedies, heartwarming stories, and tales of triumph.
Example selections: "The House in the Cerulean Sea" by TJ Klune, "Good Omens" by Neil Gaiman & Terry Pratchett
- Sad
Recommend books that acknowledge and validate feelings of grief or melancholy. Include poignant stories, moving literary fiction, and thoughtful explorations of loss.
Example selections: "A Little Life" by Hanya Yanagihara, "Never Let Me Go" by Kazuo Ishiguro
- Excited
Recommend fast-paced, thrilling books that maintain high energy. Include adventure stories, mysteries with unexpected twists, and action-packed narratives.
Example selections: "Six of Crows" by Leigh Bardugo, "The Martian" by Andy Weir
- Nostalgic
Recommend books that evoke a sense of the past or reminiscence. Include classics, historical fiction, and stories centered on memory.
Example selections: "The Catcher in the Rye" by J.D. Salinger, "To Kill a Mockingbird" by Harper Lee
- Romantic
Recommend books focused on love, connection, and relationships. Include diverse romance stories across different time periods and relationship types.
Example selections: "Pride and Prejudice" by Jane Austen, "Red, White & Royal Blue" by Casey McQuiston
- Adventurous
Recommend books about exploration, discovery, and boundary-pushing experiences. Include quests, journeys, and tales of exploration.
Example selections: "The Hobbit" by J.R.R. Tolkien, "The Alchemist" by Paulo Coelho
- Comforting
Recommend gentle, soothing books that provide emotional safety. Include cozy mysteries, gentle fiction, and stories with kind-hearted characters.
Example selections: "The No. 1 Ladies' Detective Agency" by Alexander McCall Smith, "Little Women" by Louisa May Alcott
- Inspired
Recommend motivational or thought-provoking books that encourage growth. Include memoirs of extraordinary lives, philosophical works, and stories of personal transformation.
Example selections: "Atomic Habits" by James Clear, "Man's Search for Meaning" by Viktor E. Frankl
- Whimsical
Recommend books with elements of magic, wonder, and playful imagination. Include fantasy, magical realism, and surreal stories.
Example selections: "The Night Circus" by Erin Morgenstern, "Alice's Adventures in Wonderland" by Lewis Carroll
- Output Format
Provide exactly 10 book titles, each on a separate line, without author names or additional commentary:
Book Title 1
Book Title 2
Book Title 3
Book Title 4
Book Title 5
Book Title 6
Book Title 7
Book Title 8
Book Title 9
Book Title 10
- Important Guidelines

Always recommend exactly 10 books
Include a diverse selection of publication years (classic to contemporary)
Include diversity in authors' backgrounds and perspectives
Ensure recommendations align precisely with the specified emotion
Never include explanations, author names, or commentary in your output
Focus solely on providing title recommendations that can be processed programmatically
Avoid repetition of the same authors or extremely similar books
Now, recommend 10 books for someone feeling $emotion.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final String aiResponse = response.text ?? '';
    print(aiResponse);
    return aiResponse.split('\n').where((book) => book.isNotEmpty).toList();
  }
  Future<void> onEmotionSelected(String emotion) async {
    bookApiController.isSearchLoading.value = true;
    try {
      final bookList = await getEmotionBasedBooks(emotion);
      print('Emotion-based books for $emotion: $bookList');

      // Use the default searchedBooks list (pass null as targetList)
      await bookApiController.searchBooksByAIRecommendations(
          bookList,
          targetList: null,  // Use default searchedBooks
          clearBeforeAdd: true
      );
    } catch (e) {
      print('Error getting emotion-based books: $e');
    } finally {
      bookApiController.isSearchLoading.value = false;
    }
  }
  String? selectedEmotion;

  void setSelectedEmotion(String? value) {
    onEmotionSelected(value!);
  }
  @override
  Widget build(BuildContext context) {
    return Choice<String>.inline(
      clearable: true,
      value: ChoiceSingle.value(selectedEmotion),
      onChanged: ChoiceSingle.onChanged(setSelectedEmotion),
      itemCount: emotions.length,
      itemBuilder: (state, i) {
        return ChoiceChip(
          selected: state.selected(emotions[i]),
          onSelected: state.onSelected(emotions[i]),
          label: Text(emotions[i]),
        );
      },
      listBuilder: ChoiceList.createScrollable(
        spacing: 10,
        padding: const EdgeInsets.symmetric(
          horizontal: 1,
          vertical: 20,
        ),

      ),
    );


  }
}
