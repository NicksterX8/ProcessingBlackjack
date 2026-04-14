
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
  
  void addBotPlayer() {
    // auto generate a unique name?
    Integer id = players.size();
    String name = "bot" + id.toString();
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
  
  boolean doHumanAction(PlayerActionType action) {
    Player activePlayer = currentRound.players.get(currentRound.turn);
    // TESTING: Removed to allow us to control bots
    //if (!activePlayer.human) {
    //  print("It is not your turn.\n");
    //  return false;
    //}
    
    PlayerActionResult result = currentRound.playerAction(action);
    
    lastActionFrame = frameNumber;
    
    return result.success;
  }
  
  // decide what the bot should do (hit/stand/split/double). This needs to be fleshed out way more (change depending on dealer's hand),
  // but this is just a very simple way of deciding for now.
  PlayerActionType botDecideAction(Hand hand, Card dealerCard) {
    // splitting logic
    // always split with a pair of aces or 8s
    if (hand.isSplittable() && (hand.cards.get(0).rank == "8" || hand.cards.get(0).rank == "A")) {
      return PlayerActionType.SPLIT;
    }
    else if (hand.hardValue() >= 18) {
      // always stand with a hard 18
      return PlayerActionType.STAND;
    } else {
      return PlayerActionType.HIT;
    }
  }
  
  boolean doBotAction() {
     Player activePlayer = currentRound.players.get(currentRound.turn);
     
    if (activePlayer.human) {
      print("It is not any bot's turn.\n");
      return false;
    }
    
    Hand hand = activePlayer.currentHands.get(currentRound.handNumber);
    Card dealerCard = currentRound.dealerHand.cards.get(0); // players can only see the dealer's first card
    
    PlayerActionType action = botDecideAction(hand, dealerCard);
    
    PlayerActionResult result = currentRound.playerAction(action);
    
    return result.success;
  }
}
