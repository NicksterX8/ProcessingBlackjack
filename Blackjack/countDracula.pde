//This is what calculates the count
//It might better be a function of one of the other classes IDK yet
//It is called countDracula because I thought it was funny

class CountDracula {
  int runningCount = 0;
  
  //Get the running count (not true count that will be useful)
  void getRunningCount(Card c) {
    String rank = c.rank;
    // 7, 8, and 9 are considered "neutral" and don't change the running count
    if (rank == "2" || rank == "3" || rank == "4" || rank == "5" || rank == "6") {
      runningCount += 1;
    } else if (rank == "10" || rank == "J" || rank == "Q" || rank == "K" || rank == "A") {
      runningCount -= 1;
    }
  }
  
  // Calculate the true count (the useful one)
  int getTrueCount(Deck d) {
    //Find the decks remaining, not the amount of decks used, can be a decimal
    float decksRemaining = d.cards.size() / 52.0;
    float falseTrueCount = runningCount / decksRemaining;
    //True count should be an integer, round down so you don't overestimate your odds
    int trueCount = (int)Math.floor(falseTrueCount);
    return trueCount;
  }
  void resetCount() {
    runningCount = 0;
  }
      
  
  
