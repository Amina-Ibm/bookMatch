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
Recommend 10 books for someone feeling "$emotion". Your recommendations must strictly match the selected emotion and include a mix of genres, authors, and publication years. Follow these guidelines for each emotion:

Happy – Recommend comedy, humorous, or uplifting books that evoke joy, laughter, and positive emotions. These books should have feel-good themes, witty dialogue, or heartwarming stories.
Examples: Good Omens by Neil Gaiman & Terry Pratchett, Bridget Jones's Diary by Helen Fielding, The Hitchhiker’s Guide to the Galaxy by Douglas Adams.

Sad  – Recommend angsty, emotional, or deeply moving books that resonate with feelings of grief, loss, or introspection. These can include contemporary fiction, dramatic novels, or stories that explore human emotions deeply.
Examples: A Little Life by Hanya Yanagihara, The Fault in Our Stars by John Green, Never Let Me Go by Kazuo Ishiguro.

Excited  – Recommend thrilling, adventurous, or fast-paced books that keep the reader on edge. These can be action-packed novels, mysteries, or high-stakes fantasy and sci-fi.
Examples: The Martian by Andy Weir, Six of Crows by Leigh Bardugo, Jurassic Park by Michael Crichton.

Nostalgic ️ – Recommend books that bring back memories, childhood favorites, or those set in or written before the 1980s. These could be classic literature, memoirs, or stories about reminiscing on the past.
Examples: Anne of Green Gables by L.M. Montgomery, To Kill a Mockingbird by Harper Lee, The Catcher in the Rye by J.D. Salinger.

Romantic  – Recommend romantic, passionate, or heartwarming books that evoke feelings of love, longing, and connection. These can include contemporary romance, historical love stories, or poetic prose.
Examples: Pride and Prejudice by Jane Austen, The Seven Husbands of Evelyn Hugo by Taylor Jenkins Reid, Red, White & Royal Blue by Casey McQuiston.

Adventurous  – Recommend epic quests, explorations, or survival stories that spark curiosity and a sense of wonder. These can be fantasy, sci-fi, or travel/adventure literature.
Examples: The Hobbit by J.R.R. Tolkien, The Alchemist by Paulo Coelho, Into the Wild by Jon Krakauer.

Comforting  – Recommend gentle, cozy, and heartwarming books that feel like a warm hug. These should be relaxing, slow-paced, and soothing stories with uplifting messages.
Examples: The House in the Cerulean Sea by TJ Klune, Little Women by Louisa May Alcott, The No. 1 Ladies' Detective Agency by Alexander McCall Smith.

Inspired  – Recommend motivational, self-improvement, or success-oriented books that uplift and encourage the reader to take action or see life differently.
Examples: The Power of Now by Eckhart Tolle, Atomic Habits by James Clear, Man’s Search for Meaning by Viktor E. Frankl.

Whimsical  – Recommend magical, fairy tale-like, or surreal books that have quirky, imaginative, or dreamlike elements. These stories should transport the reader into a fantastical world.
Examples: Alice’s Adventures in Wonderland by Lewis Carroll, The Night Circus by Erin Morgenstern, Howl’s Moving Castle by Diana Wynne Jones.

Provide only the book titles, one per line. Do not include any additional details or explanations.

1. Identify the emotion provided.
2. Select 10 books that align with the specified emotion, ensuring a mix of genres, authors, and publication years.
3. List the book titles, one per line, without additional details or explanations.
# Output Format
- A list of 10 book titles, each on a new line.

# Notes

- Ensure diversity in the selection of books in terms of genres, authors, and publication years.
- Focus on the emotional alignment of the books with the specified emotion.
Now, recommend 10 books for someone feeling $emotion.
''';

    final response = await model.generateContent([Content.text(prompt)]);


    final String aiResponse = response.text ?? '';
    print(aiResponse);
    return aiResponse.split('\n').where((book) => book.isNotEmpty).toList();
  }
  Future<void> onEmotionSelected(String emotion) async {
    bookApiController.isLoading.value = true;
   final  bookList = await getEmotionBasedBooks(emotion);
   bookApiController.searchBooksByAIRecommendations(bookList);
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
