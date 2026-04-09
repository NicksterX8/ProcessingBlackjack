
final char[] CardRanks = {'A', '2', '3', '4', '5', '6', '7', '8', '9', '0', 'J', 'Q', 'K'};
// '0' = 10 because we're only using one character for a card

final String[] SuitNames = {
  "Spade", "Heart", "Club", "Diamond"
};

final int SPADE = 0;
final int HEART = 1;
final int CLUB = 2;
final int DIAMOND = 3;

class Card {
   char rank; // like in CardRank
   int suit; // 0-3
}

// can 
class Deck {
  Card[] cards;
  
  void shuffle() {
     // TODO: 
  }
}

Deck createUnshuffledDeck() {
  for (int suit = 0; suit < 4; suit++) {
    for (int rank = 0; rank < 
}
