
// how many chips each player starts with. Can be removed when replaced with a better system
final int STARTING_CHIPS = 100; 

class Hand {
   ArrayList<Card> cards = new ArrayList<Card>();
   boolean active = true; // whether a player can still hit/double/etc. or not. When a player stands this is set to false
   int betChips;
   boolean justSplit = false;
   
   Hand(int chipsBet) {
    betChips = chipsBet; 
   }
   
   int value() {
     return getHandValue(cards);
   }
   
   // a 'hard' value like a 'hard 18' is when you don't have an ace that can go lower like 8 + king, as opposed to a soft 18 like 7 + ace
   int hardValue() {
       return getHardHandValue(cards);
   }
   
   boolean isBust() {
     return value() > 21;
   }
   
   boolean is21() {
     return value() == 21;
   }
   
   boolean isBlackjack() {
     return value() == 21 && cards.size() == 2; 
   }
   
   boolean isHittable() {
      return active && value() < 21; 
   }
   
   boolean isSplittable() {
      return active && cards.size() == 2 && cards.get(0).rank == cards.get(1).rank; 
   }
   
   boolean isDoubleable() {
      return active && cards.size() == 2 && value() < 21; // probably need other rules
   }
   
   boolean isStandable() {
      return active && cards.size() >= 2 && value() < 21; 
   }
}

class Player {
  int id;
  String name;
  boolean human;
  // number of active hands in the current round, must be <= currentHands.size()
  // Increased by one when player splits, decreased by one when hand busts/stands
  int activeHands = 0;
  int chips;
  // round information, maybe should be stored in Round
  ArrayList<Hand> currentHands = new ArrayList<Hand>(); // needs to be an array of hands incase of splits
  
  int currentBet = 0;
  
  Player(int playerID, boolean isHuman, String playerName) {
    id = playerID;
    human = isHuman;
    name = playerName;
    chips = STARTING_CHIPS;
  }
  
  boolean active() {
    return activeHands > 0;
  }
  
  void addHand(Hand newHand) {
    currentHands.add(newHand);
    if (newHand.active) activeHands++;
  }
}
