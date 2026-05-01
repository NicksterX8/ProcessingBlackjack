// BlackJack GUI; a brute force method for scaling but it is a functioning prototype for use to link the logical aspect to.
// only aspexts that need to be included in draw is "drawTable();" and the button controllers. Button controllers are
// temporarily set to just output to the terminal. The dealer object is just a temporary placeholder until a better idea
// for it has been made so it does not scale at this time.
// need to add card creation functions and handling.
//Draw a green felt table


color FELT        = #1B6B38;
color FELT_DARK   = #145530;
color BTN_START = #39F070;
color BTN_ADD_FRIENDS = #F2975F;
color BTN_HIT     = #39F070;
color BTN_STAND   = #B83232;
color BTN_DOUBLE  = #F2975F;
color BTN_SPLIT   = #1A5EA8;
color BTN_HOVER   = #b9b9b9;

PFont f;


Player currPlayer;
int currBet = 1;
int playerChips = 500;
boolean started = false;

boolean wasPressed = false; //boolean flag for button logic in draw()

PImage cardBack;
HashMap<String, PImage> cardImages = new HashMap<String, PImage>();
boolean cardsLoaded = false;

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
void drawTable() {
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
  drawButtons();
  drawDealerHand(int(width*0.487), int(height*0.3), cardW, cardH);
  drawBoard();
  
}

void drawStartButtons(){
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  stroke(0);
  //start button
  fill(BTN_START);
  rect(int(width/2), int(height/2), int(width*0.17125), int(height*0.068), int(width*0.0078));
  fill(0);
  text("Start", int(width/2), int(height/2));

  //Add Friends Button
  fill(BTN_ADD_FRIENDS);
  rect(int(width/2), int(height/1.7), int(width*0.17125), int(height*0.068), int(width*0.0078));
  fill(0);
  text("Add Friends", int(width/2), int(height/1.7));
  
}
void drawButtons() {
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  stroke(0);

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
  
  //Dealers tag
  fill(#EDE860);
  rect(int(width/2), int(height*0.12), int(width*0.036458), int(height*0.0416666));
  fill(0);
  text("Dealer", int(width/2), int(height*0.12));
  
}

void drawPlayerHand(int playerIndex, float x, float y, float w, float h) {
  ArrayList<Hand> hands = game.players.get(playerIndex).currentHands;
  float handGroupOffset = w * 3.2; //space between split hands
  float offset = w * 0.6; // overlap cards slightly
  for(int i = 0; i < hands.size(); i++) {
    float handX = x + i * handGroupOffset;
    if(game.currentRound.active) {
      drawChip(handX, y - (int(height*0.0555)), 35, #B83232, game.players.get(playerIndex).currentHands.get(i).betChips);
    }
    //text(game.players.get(playerIndex).currentHands.get(i).betChips, handX, y - (int(height*0.0555)));
    ArrayList<Card> cards = game.players.get(playerIndex).currentHands.get(i).cards;
    
    
    for (int j = 0; j < cards.size(); j++) {
      Card c = cards.get(j);
      drawCard(rankToImageName(c.rank), suitToImageName(c.suit), true, handX + j * offset, y, w, h);
    }
  }
  fill(0);
}

void drawDealerHand(float x, float y, float w, float h) {
  ArrayList<Card> cards = game.currentRound.dealerHand.cards;
  float offset = w * 1.1;
  for (int j = 0; j < cards.size(); j++) {
    Card c = cards.get(j);
    // second card face down while round is active
    boolean faceUp = !(j == 1 && game.currentRound.active);
    drawCard(rankToImageName(c.rank), suitToImageName(c.suit), faceUp, x + j * offset, y, w, h);
  }
}

void drawDeckPile(float x, float y, float w, float h) {
  // draw a few backs slightly offset to simulate a stack
  drawCardBack(x - 4, y - 4, w, h);
  drawCardBack(x - 2, y - 2, w, h);
  drawCardBack(x,     y,     w, h);
}

String rankToImageName(String rank) {
  switch(rank) {
    case "A": return "ace";
    case "J": return "jack";
    case "Q": return "queen";
    case "K": return "king";
    default:  return rank; // 2-10 already match
  }
}

String suitToImageName(int suit) {
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

void drawChip(float x, float y, float r, color chipColor, int amount) {
  PFont f2;
  f2 = createFont("Yu Gothic Bold", int(width/170)); 
  textFont(f2);
  
  fill(255);
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
    stroke(1);
  }
      
   fill(chipColor);
   ellipse(x, y, r * 0.55, r * 0.55);
   
   fill(255);
   textAlign(CENTER, CENTER);
   text(amount, x, y);
   textFont(f);
   
}

Hand getActiveHand() {
  if (!game.currentRound.active) return null;
  if (game.currentRound.turn >= game.players.size()) return null;
  Player p = game.currentRound.players.get(game.currentRound.turn);
  if (!p.human) return null;
  if (p.currentHands.size() == 0) return null;
  return p.currentHands.get(game.currentRound.handNumber);
}
