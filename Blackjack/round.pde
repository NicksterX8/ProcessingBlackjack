enum PlayerActionType {
   HIT, STAND, DOUBLE, SPLIT
}

class PlayerActionResult {
  boolean success = false;
}

enum HandResultType {
   LOSE, WIN, BLACKJACK, PUSH
}

// a round of blackjack
// a game is made up of some number of rounds
// contains information related to one round
class Round {
    Deck deck;
    int numDecks;
    int turn = 0; // the index of which players turn it currently is
    // index of which of the current player's hands is up
    // should always be 0 except for when playing on split hands (then the first split hand would be 1, the second 2, and so on)
    int handNumber = 0; 
    
    ArrayList<Player> players;
    Hand dealerHand = new Hand(0);
    boolean active = false; // round is currently going. Set to true when round begins and false when the last player finishes their hand
    int revolutions = 0; // number of revolutions around the table have passed
    
    Round(ArrayList<Player> _players, int numberOfDecks) {
      numDecks = numberOfDecks;
      deck = createShuffledDeck(numDecks);
      players = _players;
    }
    
    Player activePlayer() {
       return players.get(turn); 
    }
    
    void startRound(IntList bets) {
      active = true;
      revolutions = 0;
      dealerHand = new Hand(0);
      turn = 0;
      // clear last rounds data from players
      for (int i = 0; i < players.size(); i++) {
         Player p = players.get(i);
         p.activeHands = 1;
         p.currentHands.clear();
         // Need to change this 20 to a bet decided by the players
         if (bets.get(i) > p.chips) {
           print("Error: " + p.name + " trying to bet more chips than they have.\n");
           bets.set(i, p.chips);
         }
         p.currentHands.add(new Hand(bets.get(i)));
         p.chips -= bets.get(i);
      }
    }
    
    HandResultType calculateHandResult(Hand hand) {
      int value = hand.value();
      int dealerValue = dealerHand.value();
      if (hand.isBust()) {
        return HandResultType.LOSE;
      } else if (hand.isBlackjack()) {
        // blackjack pays 3:2
        return HandResultType.BLACKJACK;
      } else if (value > dealerValue) {
        // normal win
        return HandResultType.WIN;
      } else if (value == dealerValue) {
        // push
        return HandResultType.PUSH;
      }
      return HandResultType.LOSE;
    }
    
    void endRound() {
       if (active) {
          print("Error: cannot end active round.\n");
          return;
       }
       
       // Dealer drawing cards after the first two not implemented yet
       
       // calculate chip gain/loss
       for (Player player : players) {
          for (Hand hand : player.currentHands) {
            HandResultType result = calculateHandResult(hand);
            int chipsGained = 0;
             switch (result) {
               case BLACKJACK:
                 chipsGained = (3 * hand.betChips) / 2;
                 break;
               case WIN:
                 chipsGained = 2 * hand.betChips;
                 break;
               case PUSH:
                 chipsGained = hand.betChips;
                 break;
               case LOSE:
                 chipsGained = 0;
                 break;
             }
            
            player.chips += chipsGained;
          }
       }
       
       
    }
    
    void nextHand() {
      Player currentPlayer = players.get(turn);
      if (++handNumber < currentPlayer.currentHands.size() && currentPlayer.currentHands.get(handNumber).active) {
        // go to next hand of player instead of next player
        print("Hand #" + handNumber + "\n");
        return;
      } else {
        handNumber = 0;
      }
      
      boolean anyPlayerActive = false;
      for (Player p : players) {
       if (p.active()) {
         anyPlayerActive = true;
         break;
       }
      }
      if (!anyPlayerActive) {
        active = false; // round over
        return; 
      }
      // increment turn number until an active player is found. We made sure there is atleast one
      do {
       turn = (turn + 1) % players.size(); // increment turn number, wrapping back to 0 
      } while (!players.get(turn).active());
      currentPlayer = players.get(turn);
      currPlayer = currentPlayer;
      print(currentPlayer.name + "'s turn.\n");
      while (!currentPlayer.currentHands.get(handNumber).active) {
         handNumber++;
         assert(handNumber < currentPlayer.currentHands.size());
      }
      print("Hand #" + handNumber + "\n");
    }
    
    // draw one card from the deck. Deck must not be empty
    // At some point we will need to check whenever a card is drawn if it is time to reshuffle the deck
    Card drawCard() {
      return deck.pop();
    }
    
    // deal one of the two starting cards all players get
    boolean dealStartingCard() {
      if (revolutions >= 2) {
        print("Error: starting cards already dealt!");
        return false;
      }
      Card card = drawCard();
      
      int dealersTurn = players.size();
      if (turn == dealersTurn) {
        dealerHand.cards.add(card);
        count.getRunningCount(card);
        print("The dealer drew a " + card.rank + " of " + SuitNames[card.suit] + "s.\n");
        if (dealerHand.isBlackjack()) {
           // round over, dealer beats anyone who does not have blackjack
           active = false;
        }
        
        turn = 0;
        revolutions++;
        if (revolutions == 2) {
          print("Initial cards dealt.\n");
          print(players.get(turn).name + "'s turn.\n");
        }
      } else {
        Player currentPlayer = players.get(turn);
        Hand hand = currentPlayer.currentHands.get(0);
        if (hand.cards.size() >= 2) {
           print("Error: hand already has cards dealt!\n");
           return false;
        }
        hand.cards.add(card);
        count.getRunningCount(card);
        print(currentPlayer.name + " was dealt a " + card.rank + " of " + SuitNames[card.suit] + "s.\n");
        
        // We need to check if incase someone was dealt blackjack, and mark their hand as over/not active
        if (hand.isBlackjack()) {
          hand.active = false;
          currentPlayer.activeHands = 0; // player should never have multiple hands yet
        }
        
        turn += 1;
      }

      return true;
    }
    
    // return: success: true, failure: false
    boolean hit() {
      Player player = players.get(turn);
      Hand hand = player.currentHands.get(handNumber);
      if (!player.active()) {
         print("Error: inactive player!\n");
         return false;
      }
      if (!hand.isHittable()) {
         print("Error: cannot hit on this hand.\n");
         return false;
      }
      Card card = deck.pop();
      print("Drew " + card.rank + " of " + SuitNames[card.suit] + "s.\n");
      hand.cards.add(card);
      count.getRunningCount(card);
      print("New hand value: " + hand.value() + "\n");
      if (hand.isBust()) {
         print("Bust!\n");
         hand.active = false;
         player.activeHands--;
      }
      else if (hand.is21()) {
         print("21!\n");
         player.activeHands--;
      }
      return true;
    }
    
    PlayerActionResult playerAction(PlayerActionType actionType) {
      PlayerActionResult result = new PlayerActionResult();
      if (!active) {
         print("Error: round not active yet!\n");
         return result;
      }
      if (revolutions < 2) {
         print("Error: cards not finished being dealt!\n");
         return result;
      }
      Player player = players.get(turn);
      if (!player.active()) {
         print("Error: inactive player!\n");
         return result;
      }
      
      Hand hand = player.currentHands.get(handNumber);

      switch (actionType) {
        case HIT: {
          print(player.name + " hits.\n");
          if (!hit()) {
            break;
          }
          nextHand();
          result.success = true;
          break; 
        }
        case STAND: {
          print(player.name + " stands.\n");
          if (!hand.isStandable()) {
            print("Error: not allowed to stand for this hand\n");
            break; 
          }
          hand.active = false;
          player.activeHands--;
          nextHand();
          
          result.success = true;
          break;
        }
        case DOUBLE: {
          print(player.name + " doubles.\n");
          if (!hand.isDoubleable()) {
             print("Error: hand is not doubleable\n");
             break;
          }
          
          // need to make sure player has enough chips to bet on the second hand (splitting doubles your bet)
          if (player.chips < hand.betChips) {
             result.success = false;
             break;
          }
          
          hand.betChips *= 2;
          if (!hit()) {
            break;
          }
          
          nextHand();
           
          result.success = true;
          break;
        }
        case SPLIT: {
         print(player.name + " splits.\n");
         if (!hand.isSplittable()) {
            print("Error: hand is not splittable\n"); 
            break;
         }
         
         // need to make sure player has enough chips to bet on the second hand (splitting doubles your bet)
         if (player.chips < hand.betChips) {
             result.success = false;
             break;
         }
         
         Card splitCard = hand.cards.remove(hand.cards.size()-1);
         Hand newHand = new Hand(hand.betChips);
         newHand.justSplit = true;
         player.chips -= hand.betChips; // take chips out of player's bank
         
         newHand.cards.add(splitCard);
         player.addHand(newHand);
         
         // turn stays the same for splits because if a player splits they get to go again immediately
         
         result.success = true;
         break;
        }
      }
      return result;
    }
}
