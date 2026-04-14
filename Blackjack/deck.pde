import java.util.Collections; // for shuffle

// made the ranks strings instead of chars because it works better with Dictionaries
// should ace be at the start or end?
final String[] CardRanks = {"A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"};

final String[] SuitNames = {
  "Spade", "Heart", "Club", "Diamond"
};

final int SPADE = 0;
final int HEART = 1;
final int CLUB = 2;
final int DIAMOND = 3;

class Card {
   String rank; // like in CardRank
   int suit; // 0-3

   // create a card e.g. Ace of Clubs like this: new Card("A", CLUB)
   Card(String _rank, int _suit) {
      rank = _rank;
      suit = _suit;
   }
}

// param low: if ace is worth 1 or 11
IntDict createRankValueDict(boolean aceLow) {
  IntDict dict = new IntDict();
  if (aceLow) {
     dict.set("A", 1); 
  } else {
     dict.set("A", 11);
  }
  dict.set("2", 2);
  dict.set("3", 3);
  dict.set("4", 4);
  dict.set("5", 5);
  dict.set("6", 6);
  dict.set("7", 7);
  dict.set("8", 8);
  dict.set("9", 9);
  dict.set("10", 10);
  dict.set("J", 10);
  dict.set("Q", 10);
  dict.set("K", 10);
  return dict;
}

// rank values with ace == 1
IntDict HardRankValues = createRankValueDict(true);
// rank values with ace == 11
IntDict HighRankValues = createRankValueDict(false);

// Gets the highest value a hand can be (using Aces as 11) without it going over 21
// if aces being 11 makes the hand go over 21, it treats them as 1s
int getHandValue(ArrayList<Card> hand) {
  int value = 0;
  int nAces = 0;
  for (int i = 0; i < hand.size(); i++) {
    String rank = hand.get(i).rank;
    // check if ace as 11 would make hand go bust
    if (rank == "A") nAces++;
    value += HighRankValues.get(rank);
  }
  // If hand went bust with aces as 11, try to make hand go under by turning aces into 1s
  while (value > 21 && nAces > 0) {
    // turn ace from 11 into 1
    value -= 10;
    nAces--;
  }
  return value;
}

// Gets the lowest value a hand can be (using Aces as 1)
int getHardHandValue(ArrayList<Card> hand) {
  int value = 0;
  for (int i = 0; i < hand.size(); i++) {
    String rank = hand.get(i).rank;
    value += HardRankValues.get(rank);
  }
  return value;
}

// can hold any number of cards
class Deck {
  ArrayList<Card> cards = new ArrayList<Card>();
  
  // Randomly shuffle in place all cards in the deck
  void shuffle() {
     Collections.shuffle(cards);
  } 
  
  // Deck must not be empty!
  Card pop() {
     assert(cards.size() > 0);
     return cards.remove(cards.size()-1); 
  }
  
  boolean isEmpty() {
     return cards.size() == 0; 
  }
}

// Creates a number of sorted decks starting at Ace of spades going to King of diamonds
// param numDuplicates: how many decks worth of cards to put in the deck.
Deck createSortedDeck(int numDuplicates) {
  assert(numDuplicates >= 0);
  Deck d = new Deck();
  for (int i = 0; i < numDuplicates; i++) {
    for (int suit = 0; suit < 4; suit++) {
      for (int rankNumber = 0; rankNumber < CardRanks.length; rankNumber++) {
        String rank = CardRanks[rankNumber];
        Card c = new Card(rank, suit);
        d.cards.add(c);
      }
    }
  }
  return d;
}

// param numDecksUsed: how many decks worth of cards are shuffled in. e.g. if numDeckUsed = 3, there are 3 of every card shuffled into this deck
Deck createShuffledDeck(int numDecksUsed) {
  Deck sorted = createSortedDeck(numDecksUsed);
  sorted.shuffle();
  return sorted; // now shuffled
}
