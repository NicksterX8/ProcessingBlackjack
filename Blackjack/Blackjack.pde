// main file

// Most of the basic blackjack functions implemented: hit, stand, double, split
// Basic bot decision making in
// Need to test everything more though
// Important things that need to be implemented (game logic wise):
//  - Dealer drawing cards after the first two when the players finish
//  - Shuffling deck when cards get low, right now game will crash after like 10 rounds

Game game = new Game();

void setup() {
 size(800, 600); 
 pixelDensity(1);
 
 int numBots = 1;
 String playerName = "Bob";
 
 
 game.addHumanPlayer(playerName);
 for (int i = 0; i < numBots; i++) {
   game.addBotPlayer();
 }
 game.startGame();
 IntList bets = new IntList();
 for (int i = 0; i < numBots + 1; i++) {
   bets.append(20); // change to amount decided by players
 }
 game.startRound(bets);
}

void draw() {
   background(255);
   
   // Temporary stuff, just to make it easier to test until we make real graphics
   fill(0);
   textAlign(CENTER);
   textSize(50);
   text("Blackjack", width/2, 50);
   textSize(20);
   text("Round " + game.roundNumber, width/2, height/2 - 50);
   text("Play with keys: h: hit, s: stand, t: split, d: double.\n'[': start round, ']': end round", width/2, height/2);
   textAlign(LEFT);
   for (int i = 0; i < game.players.size(); i++) {
     Player player = game.players.get(i);
     text(player.name + "'s chips: " + player.chips, 5, 20 + i * 25);
     int handValue = player.currentHands.get(0).value();
     text(player.name + "'s hand: " + handValue, 5, 200 + i * 25);
   }
   // Of course in a real game players should only be able to see one of the dealers cards,
   // but showing it for testing
   text("Dealer's hand: " + game.currentRound.dealerHand.value(), 5, 200 + game.players.size() * 25);
   
   if (game.frameNumber - game.lastActionFrame > 90) {
     if (game.currentRound.active) {
       if (game.currentRound.revolutions < 2) {
         // been enough time from last card dealt, deal one
          game.currentRound.dealStartingCard();
          
       } else if (!game.currentRound.activePlayer().human) {
          game.doBotAction();
       }
       game.lastActionFrame = game.frameNumber;  
     }
   }
   
   
   game.frameNumber++;
}

void keyPressed() {
    switch (key) {
       case 'h':
         game.doHumanAction(PlayerActionType.HIT);
         break;
       case 's':
         game.doHumanAction(PlayerActionType.STAND);
         break;
       case 'd':
         game.doHumanAction(PlayerActionType.DOUBLE);
         break;
       case 't':
         game.doHumanAction(PlayerActionType.SPLIT);
         break;
       // start round
       case '[': {
         IntList bets = new IntList();
         for (int i = 0; i < game.players.size(); i++) {
           bets.append(20); // change to amount decided by players
         }
         game.startRound(bets);
         break;
       }
       // end round
       case ']':
         game.currentRound.endRound();
         break;
       
    }
}
