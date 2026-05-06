// BlackJack GUI functions 


color FELT        = #1B6B38;
color FELT_DARK   = #145530;
color BTN_START = #39F070;
color BTN_HOST = #F2975F;
color BTN_HIT     = #39F070;
color BTN_STAND   = #B83232;
color BTN_DOUBLE  = #F2975F;
color BTN_SPLIT   = #1A5EA8;
color BTN_JOIN   = #1A5EA8;
color BTN_HOVER   = #b9b9b9;

PFont f;

int currBet = 1;
int playerChips = 500;
boolean started = false;

boolean wasPressed = false; //boolean flag for button logic in draw()

PImage cardBack;
HashMap<String, PImage> cardImages = new HashMap<String, PImage>();
boolean cardsLoaded = false;
String portInput = "";
String joinInput = "";
boolean portBoxActive = false;
boolean joinBoxActive = false;
String ipInput = "";
boolean ipBoxActive = false;
float rainbowHue = 0;
int fontSize;
boolean showFaqPage = false;

//list of suits, matches the folder names under cards/
String[] SUITS = {"hearts", "diamonds", "clubs", "spades"};
//list of ranks, matches the png file names
String[] RANKS = {"ace","2","3","4","5","6","7","8","9","10","jack","queen","king"};

int cardW, cardH;

void drawStart(){

  if(started){
    print("Game already started");
    return;
  }

  
  else{
    background(FELT_DARK);
    noStroke();
    fill(FELT);
    ellipse(width/2, height/2,int(width * 0.9),int(height * 0.8));
    noFill();
    strokeWeight(2);
    stroke(#2E8B57, 80);
    //inner ring
    ellipse(width/2, height/2,int(width * 0.850),int(height * 0.72));
    noStroke();
    drawStartButtons();    
  }

}
void drawTable(boolean takingBets) {
  background(FELT_DARK);
  noStroke();
  fill(FELT);
  ellipse(width/2, height/2,int(width * 0.9),int(height * 0.8));
  noFill();
  strokeWeight(2);
  stroke(#2E8B57, 80);
  ellipse(width/2, height/2,int(width * 0.850),int(height * 0.72));
  noStroke();
  //inner ring
  drawButtons(takingBets);
  drawDealerHand(int(width*0.487), int(height*0.3), cardW, cardH);
  drawBoard();
  
}

void drawStartButtons(){
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  
  // title
  fill(255, 255, 255);
  textSize(int(width/40));

  //rainbow title for fun
  colorMode(HSB, 360, 100, 100);
  fill(rainbowHue, 100, 100);
  text("BLACKJACK", int(width/2), int(height*0.35));
  rainbowHue += 0.6;
  if (rainbowHue >= 360) rainbowHue = 0;
  colorMode(RGB, 255);
  textSize(int(width/96));

  //START ROW
  stroke(0);
  fill(BTN_START);
  rect(int(width/2), int(height*0.45), int(width*0.15), int(height*0.068), int(width*0.0078));
  fill(0);
  text("Start", int(width/2), int(height*0.45));

  //HOST ROW (button + port box centered as group)
  // total row width = 0.15 + 0.01 gap + 0.10 = 0.26
  // left edge = width/2 - width*0.13
  int hostBtnX = int(width/2 - width*0.055); // button center
  int hostPortX = int(width/2 + width*0.08);  // port box center

  stroke(0);
  fill(BTN_HOST);
  rect(hostBtnX, int(height*0.55), int(width*0.15), int(height*0.068), int(width*0.0078));
  fill(0);
  text("Host Game", hostBtnX, int(height*0.55));

  strokeWeight(2);
  stroke(portBoxActive ? 0 : 150);
  fill(255, 255, 255, 230);
  rect(hostPortX, int(height*0.55), int(width*0.10), int(height*0.068), int(width*0.0078));
  fill(portBoxActive ? 0 : #888888);
  noStroke();
  text(portInput.length() > 0 ? portInput : "Port...", hostPortX, int(height*0.55));

  // JOIN ROW (button + ip box + port box)
  // total row width = 0.15 + 0.01 + 0.13 + 0.01 + 0.10 = 0.40
  // left edge = width/2 - width*0.20
  int joinBtnX  = int(width/2 - width*0.125); // button center
  int joinIpX   = int(width/2 + width*0.025);  // ip box center
  int joinPortX = int(width/2 + width*0.15);   // port box center

  strokeWeight(2);
  stroke(0);
  fill(BTN_JOIN);
  rect(joinBtnX, int(height*0.65), int(width*0.15), int(height*0.068), int(width*0.0078));
  fill(0);
  noStroke();
  text("Join", joinBtnX, int(height*0.65));

  strokeWeight(2);
  stroke(ipBoxActive ? 0 : 150);
  fill(255, 255, 255, 230);
  rect(joinIpX, int(height*0.65), int(width*0.13), int(height*0.068), int(width*0.0078));
  fill(ipBoxActive ? 0 : #888888);
  noStroke();
  text(ipInput.length() > 0 ? ipInput : "IP...", joinIpX, int(height*0.65));

  strokeWeight(2);
  stroke(joinBoxActive ? 0 : 150);
  fill(255, 255, 255, 230);
  rect(joinPortX, int(height*0.65), int(width*0.10), int(height*0.068), int(width*0.0078));
  fill(joinBoxActive ? 0 : #888888);
  noStroke();
  text(joinInput.length() > 0 ? joinInput : "Port...", joinPortX, int(height*0.65));

  strokeWeight(1);
  stroke(0);
}


void drawButtons(boolean takingBets) {
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  stroke(0);
  textSize(16);
  
  Player currentPlayer = game.currentRound.players.get(playerBetTurn);

  if (takingBets) {
    // show current bet amount
    drawChip(width/2, height/2, 80, #B83232, currentPlayer.currentBet, 2.0);
    
    // decrease bet button
    fill(BTN_STAND);
    rect(int(width*0.45), int(height*0.95), int(width*0.07125), int(height*0.068), int(width*0.0078));
    fill(0);
    text("-10 Chips", int(width*0.45),int(height*0.95));
    
    // increase bet button
    fill(BTN_HIT);
    rect(int(width*0.55), int(height*0.95), int(width*0.07125), int(height*0.068), int(width*0.0078));
    fill(0);
    text("+10 Chips", int(width*0.55), int(height*0.95));
    
    // confirm bet button
    fill(BTN_SPLIT);
    rect(int(width*0.65), int(height*0.95), int(width*0.07125), int(height*0.068), int(width*0.0078));
    fill(0);
    text("Confirm bet", int(width*0.65), int(height*0.95));
    return;
  }
  
  if (game.currentRound.revolutions >= 2 && currentPlayer != null && currentPlayer.human && currentPlayer.active()) {
  
    //Double Button
    fill(BTN_DOUBLE);
    rect(int(width*0.35), int(height*0.95), int(width*0.07125), int(height*0.068), int(width*0.0078));
    fill(0);
    text("Double", int(width*0.35), int(height*0.95));
  
  
    //Stand button
    fill(BTN_STAND);
    rect(int(width*0.45), int(height*0.95), int(width*0.07125), int(height*0.068), int(width*0.0078));
    fill(0);
    text("Stand", int(width*0.45),int(height*0.95));
    
    //Hit button
    fill(BTN_HIT);
    rect(int(width*0.55), int(height*0.95), int(width*0.07125), int(height*0.068), int(width*0.0078));
    fill(0);
    text("Hit", int(width*0.55), int(height*0.95));
    
    //Split button
    fill(BTN_SPLIT);
    rect(int(width*0.65), int(height*0.95), int(width*0.07125), int(height*0.068), int(width*0.0078));
    fill(0);
    text("Split", int(width*0.65), int(height*0.95));
  
  }
  
  //Dealers tag
  fill(#EDE860);
  rect(int(width/2), int(height*0.12), int(width*0.036458), int(height*0.0416666));
  fill(0);
  text("Dealer", int(width/2), int(height*0.12));
  
}

void drawPlayerHand(int playerIndex, float x, float y, float w, float h) {
  int activePlayer = game.currentRound.turn; //get the current player
  int activeHand = game.currentRound.handNumber; //get the hand currently active for that player
  
  Player player = game.currentRound.players.get(playerIndex);
  ArrayList<Hand> hands = player.currentHands;
  float handGroupOffset = w * 3.2; //space between split hands
  float offset = w * 0.35; // overlap cards slightly
  for(int i = 0; i < hands.size(); i++) {  
    Hand hand = hands.get(i);
   
    float handX = x + i * handGroupOffset;
    
    if (hand.cards.size() > 0) {
      
      fill(255, 255, 0);
      stroke(0);
      if (activePlayer == playerIndex && activeHand == i) {
         // draw a yellow border around the hand indicating it's that hand's turn
         ellipse(handX, y+h, 20, 20);
      }
    }
    
    if(game.currentRound.active) {
      drawChip(handX, y - (int(height*0.0575)), 35, #B83232, game.currentRound.players.get(playerIndex).currentHands.get(i).betChips, 1.0);//draw chips currently bet
      drawPlayerName(handX - (cardW/2), y - (int(height*0.085)), game.currentRound.players.get(playerIndex).name, 1);
    }

    ArrayList<Card> cards = game.currentRound.players.get(playerIndex).currentHands.get(i).cards;
    
    
    for (int j = 0; j < cards.size(); j++) {
      Card c = cards.get(j);
      drawCard(rankToImageName(c.rank), suitToImageName(c.suit), true, handX + j * offset, y, w, h);
    }
    
    // If round ended, show player results
    textAlign(CENTER, TOP);
    textSize(18);
    fill(0);
    
    if (!hand.active && !takingBets) {
       String handResultName = getHandResultString(hand);
       // only show hand result if round has ended or we already know for sure if they've lost or won
       if (!game.currentRound.active || handResultName == "Bust" || handResultName == "Blackjack") {
         text(handResultName, handX + w/2, y + h);
       }
    }
  }
  fill(0);
}

void drawDealerHand(float x, float y, float w, float h) {
  boolean allPlayersInactive = true;
   for (Player player : game.currentRound.players) {
     if (player.active()) {
        allPlayersInactive = false; 
     }
   }
  
  ArrayList<Card> cards = game.currentRound.dealerHand.cards;
  float offset = w * 1.1;
  for (int j = 0; j < cards.size(); j++) {
    Card c = cards.get(j);
    // second card face down while players are playing
    boolean faceUp = j != 1 || allPlayersInactive;
    drawCard(rankToImageName(c.rank), suitToImageName(c.suit), faceUp, x + j * offset, y, w, h);
  }
}

void drawDeckPile(float x, float y, float w, float h) {
  // draw a few backs slightly offset to simulate a stack
  drawCardBack(x - 4, y - 4, w, h);
  drawCardBack(x - 2, y - 2, w, h);
  drawCardBack(x,     y,     w, h);
}

String rankToImageName(String rank) { //translate from the logical code names to the file names
  switch(rank) {
    case "A": return "ace";
    case "J": return "jack";
    case "Q": return "queen";
    case "K": return "king";
    default:  return rank; // 2-10 already match
  }
}

String suitToImageName(int suit) { //translate from the logical code names to the file names
  switch(suit) {
    case SPADE:   return "spades";
    case HEART:   return "hearts";
    case CLUB:    return "clubs";
    case DIAMOND: return "diamonds";
    default:      return "";
  }
}

//loads every card pic plus the back into memory. safe to call more than once, it bails if already loaded
void loadCards() {
  if (cardsLoaded) return;
  cardBack = loadImage("cards/backs/back_blue1.png");
  for (String s : SUITS) {
    for (String r : RANKS) {
      cardImages.put(r + "_" + s, loadImage("cards/" + s + "/" + r + ".png"));
    }
  }
  cardsLoaded = true;
}

//draws a card centered at x,y with given w and h. if faceUp is false it just draws the back instead
void drawCard(String rank, String suit, boolean faceUp, float x, float y, float w, float h) {
  if (!cardsLoaded) loadCards();
  imageMode(CENTER);
  if (faceUp) {
    PImage img = cardImages.get(rank + "_" + suit);
    if (img != null) image(img, x, y, w, h);
  }else image(cardBack, x, y, w, h);
}

//just the back, useful for the deck pile or the dealers hidden card
void drawCardBack(float x, float y, float w, float h) {
  if (!cardsLoaded) loadCards();
  imageMode(CENTER);
  image(cardBack, x, y, w, h);
}

PFont f2;

void drawChip(float x, float y, float r, color chipColor, int amount, float textScale) { //draw a poker chip and the amount it represents inside it
  textFont(f2);
  
  fill(255);
  stroke(0);
  circle(x,y,r);
  
  fill(chipColor);
  
  circle(x,y,r*0.85);
  
  float dashRadius = r * 0.43;
  for (int i = 0; i < 8; i++) {
    float angle = TWO_PI / 8 * i;
    float dx = x + cos(angle) * dashRadius;
    float dy = y + sin(angle) * dashRadius;
    fill(255);
    noStroke();
    ellipse(dx, dy, r * 0.12, r * 0.12);
  }
      
   fill(chipColor);
   ellipse(x, y, r * 0.55, r * 0.55);
   
   fill(255);
   textAlign(CENTER, CENTER);
   textSize(14 * textScale);
   if(amount > 1000) {
     textSize(8*textScale);
   }
   text(amount, x, y);
   textFont(f);
   
   stroke(0);
}

Hand getActiveHand() { //function to return which hand is active


  if (!game.currentRound.active) return null;
  if (game.currentRound.turn >= game.currentRound.players.size()) return null;
  
  Player p = game.currentRound.activePlayer();
  if (p == null ||!p.active()) {
    return game.currentRound.nextHand();
  }
  if (!p.human) return null;
  if (p.currentHands.size() == 0) return null;
  Hand currentHand = p.currentHands.get(game.currentRound.handNumber);
  if (currentHand == null || !currentHand.active) {
     return game.currentRound.nextHand(); 
  }
  return currentHand;
}

void drawPlayerName(float x, float y, String name, float textScale) {
  fill(255);
  textAlign(LEFT, CENTER);
  textSize(14 * textScale);
  text(name, x, y);
  textFont(f);
}

//-------SALIM-------
//info page stuff

color BTN_INFO = #2C3E50;

//info button (top-right corner)
void drawInfoButton() {
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(int(width/110));
  stroke(0);
  fill(BTN_INFO);
  rect(int(width*0.957), int(height*0.15), int(width*0.07), int(height*0.04), int(width*0.0078));
  fill(255);
  noStroke();
  text("Info", int(width*0.957), int(height*0.15));
}

//info button click
void infoButtonInteract() {
  if (mouseX > width*0.917 && mouseX < width*0.987 && mouseY > height*0.13 && mouseY < height*0.17) {
    BTN_INFO = BTN_HOVER;
    if (mousePressed && !wasPressed) {
      showFaqPage = true;
      wasPressed = true;
    }
  }
  else { BTN_INFO = #2C3E50; }
}

//info page
void drawInfo() {
  background(FELT_DARK);
  noStroke();
  fill(FELT);
  ellipse(width/2, height/2,int(width * 0.9),int(height * 0.8));
  noFill();
  strokeWeight(2);
  stroke(#2E8B57, 80);
  //inner ring
  ellipse(width/2, height/2,int(width * 0.850),int(height * 0.72));
  noStroke();

  rectMode(CENTER);
  textAlign(CENTER, CENTER);

  //title
  fill(255, 255, 255);
  textSize(int(width/40));
  text("HOW TO PLAY", int(width/2), int(height*0.14));

  //blackjack
  textSize(int(width/72));
  text("Blackjack Basics", int(width/2), int(height*0.22));

  textAlign(LEFT, CENTER);
  textSize(int(width/96));
  int leftX = int(width*0.22);
  text("Goal: get closer to 21 than the dealer without going over.", leftX, int(height*0.27));
  text("Card values: 2-10 = face value | J/Q/K = 10 | Ace = 1 or 11", leftX, int(height*0.31));
  text("Actions: HIT, STAND, DOUBLE, SPLIT (two cards of same rank)", leftX, int(height*0.35));
  text("Beat the dealer to win | Tie = bet returned | Bust or lose = lose bet", leftX, int(height*0.39));
  text("Dealer hits below 16, stands on 16+", leftX, int(height*0.43));

  //counting
  textAlign(CENTER, CENTER);
  textSize(int(width/72));
  text("Card Counting (Hi-Lo)", int(width/2), int(height*0.51));

  textAlign(LEFT, CENTER);
  textSize(int(width/96));
  text("Cards 2-6  ->  +1", leftX, int(height*0.56));
  text("Cards 7-9  ->   0", leftX, int(height*0.60));
  text("Cards 10, J, Q, K, A  ->  -1", leftX, int(height*0.64));
  text("Running count = sum of values seen so far", leftX, int(height*0.68));
  text("True count = running count / decks remaining", leftX, int(height*0.72));
  text("High count means more high cards left -> favors the player", leftX, int(height*0.76));

  //back button
  boolean backHover = (mouseX >= (int(width/2) - int(width*0.075)) && mouseX <= (int(width/2) + int(width*0.075))
                   && mouseY >= (int(height*0.92) - int(height*0.034)) && mouseY <= (int(height*0.92) + int(height*0.034)));
  stroke(0);
  fill(backHover ? BTN_HOVER : BTN_INFO);
  rect(int(width/2), int(height*0.92), int(width*0.15), int(height*0.068), int(width*0.0078));
  fill(0);
  noStroke();
  text("Back", int(width/2), int(height*0.92));

  if (backHover && mousePressed && !wasPressed) {
    showFaqPage = false;
    wasPressed = true;
  }
  if (!mousePressed) wasPressed = false;
}
//-------SALIM-------
