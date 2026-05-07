
class Game {
  ArrayList<Player> players = new ArrayList<Player>();
  Round currentRound;
  int roundNumber = 0;
  int lastActionFrame = 0;
  int frameNumber = 0;
  
  Game() {}
  
  void addHumanPlayer(String name) {
    int id = players.size();
    players.add(new Player(id, true, name));
  }
  
  final String[] RandomBotNames = {"Jack", "Smith", "Jessica", "Ryan", "Sarah", "Abby", "Charlie", "Catriona", "Danielle", "Bryan", "Boomer"};
  
  void addBotPlayer() {
    Integer id = players.size();
    // randomly pick a name from a list
    int randomBotNameId = round(random(-0.49, RandomBotNames.length - 1 + 0.49));
    String name = RandomBotNames[randomBotNameId] + " Bot";
    players.add(new Player(id, false, name));
  }
  
  
  void startGame() {
    currentRound = new Round(players, 2);
  }
  
  void startRound(IntList bets) {
    roundNumber++;
    print("Starting round #" + roundNumber + ".\n");
    currentRound.startRound(bets);
    
  }
  
  void endRound() {
     game.currentRound.endRound(); 
  }
  
  boolean doHumanAction(PlayerActionType action) {
    if (currentRound.turn >= currentRound.players.size()) {
       print("It's the dealer's turn!");
       return false; 
    }
    Player activePlayer = currentRound.players.get(currentRound.turn);
    // Remove to allow controlling bots
    if (!activePlayer.human) {
      print("It is not your turn.\n");
      return false;
    }
    
    PlayerActionResult result = currentRound.playerAction(action);
    
    lastActionFrame = frameNumber;
    
    return result.success;
  }
  
  




  // decide what the bot should do (hit/stand/split/double). This needs to be fleshed out way more (change depending on dealer's hand),
  // but this is just a very simple way of deciding for now.


PlayerActionType botDecideAction(Hand hand, Card dealerCard, int chipsLeft) {
  int val = hand.value();
  Player activePlayer = currentRound.players.get(currentRound.turn);
  if (val >= 21) return PlayerActionType.STAND;

  float boldness = activePlayer.botBoldness;

  // Dealer pressure
  int dealerVal = HighRankValues.get(dealerCard.rank);
  boldness += (6 - dealerVal) * 0.5;

  if (activePlayer.knowsCount) {
    float tc = count.getTrueCount(game.currentRound.deck);
    boldness += tc * 0.8;
  }

  //this variable is what dictates choices
  float standThreshold = 15 + boldness;
  
  if (val < 18 && hand.value() != hand.hardValue()) {
      return PlayerActionType.HIT;
  }

  if (val >= standThreshold) {
    float r = random(1);
    if (r < 0.08 && hand.isSplittable() && chipsLeft >= hand.betChips)
      return PlayerActionType.SPLIT;
    if (r < 0.12 && hand.isDoubleable() && chipsLeft >= hand.betChips)
      return PlayerActionType.DOUBLE;
    return PlayerActionType.STAND;
  }

  float r = random(1);
  if (r < 0.10 && hand.isSplittable() && chipsLeft >= hand.betChips)
    return PlayerActionType.SPLIT;
  if (r < 0.15 && hand.isDoubleable() && chipsLeft >= hand.betChips)
    return PlayerActionType.DOUBLE;
  return PlayerActionType.HIT;
  }

  
  boolean doBotAction() {
     Player activePlayer = currentRound.players.get(currentRound.turn);
     
    if (activePlayer.human) {
      print("It is not any bot's turn.\n");
      return false;
    }
    
    Hand hand = activePlayer.currentHands.get(currentRound.handNumber);
    Card dealerCard = currentRound.dealerHand.cards.get(0); // players can only see the dealer's first card
    
    PlayerActionType action = botDecideAction(hand, dealerCard, activePlayer.chips);
    
    PlayerActionResult result = currentRound.playerAction(action);
    
    return result.success;
  }
}
