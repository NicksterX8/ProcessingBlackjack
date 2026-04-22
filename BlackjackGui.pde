// BlackJack GUI; a brute force method for scaling but it is a functioning prototype for use to link the logical aspect to.
// only aspexts that need to be included in draw is "drawTable();" and the button controllers. Button controllers are
// temporarily set to just output to the terminal. The dealer object is just a temporary placeholder until a better idea
// for it has been made so it does not scale at this time.
// need to add card creation functions and handling.
//Draw a green felt table
color FELT        = #1B6B38;
color FELT_DARK   = #145530;
color BTN_HIT     = #39F070;
color BTN_STAND   = #B83232;
color BTN_DOUBLE  = #F2975F;
color BTN_SPLIT   = #1A5EA8;
color BTN_HOVER   = #FFFFFF30;

PFont f;


int currPlayer = 1;
int currBet = 1;
int playerChips = 500;

boolean wasPressed = false; //boolean flag for button logic in draw()



void setup() {
  pixelDensity(1);
  
  //size(1280,720); //commented out but is used to test the scaling.
  fullScreen();
  int fontSize = int(width/96);
  f = createFont("Yu Gothic Bold", fontSize);
  textFont(f);
  //println(PFont.list());
}

void draw() {
  drawTable();
  //Double button
  if(mouseX >= (int(width*0.35)-int(width*0.035625)) && mouseX <= (int(width*0.35)+int(width*0.035625))
     && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
    BTN_DOUBLE = BTN_HOVER;
    if(mousePressed && !wasPressed) {
      println("Clicked Double!");
      wasPressed = true;
    }
    if(!mousePressed) wasPressed = false;
  }else BTN_DOUBLE = #F2975F;
  //Stand button
  if(mouseX >= (int(width*0.45)-int(width*0.035625)) && mouseX <= (int(width*0.45)+int(width*0.035625))
     && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
    BTN_STAND = BTN_HOVER;
    if(mousePressed && !wasPressed) {
      println("Clicked Stand!");
      wasPressed = true;
    }
    if(!mousePressed) wasPressed = false;
  }else BTN_STAND = #B83232;
  //Hit button
  if(mouseX >= (int(width*0.55)-int(width*0.035625)) && mouseX <= (int(width*0.55)+int(width*0.035625))
     && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
    BTN_HIT = BTN_HOVER;
    if(mousePressed && !wasPressed) {
      println("Clicked Hit!");
      wasPressed = true;
    }
    if(!mousePressed) wasPressed = false;
  }else BTN_HIT = #39F070;
  //Hit button
  if(mouseX >= (int(width*0.65)-int(width*0.035625)) && mouseX <= (int(width*0.65)+int(width*0.035625))
     && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
    BTN_SPLIT = BTN_HOVER;
    if(mousePressed && !wasPressed) {
      println("Clicked Split!");
      wasPressed = true;
    }
    if(!mousePressed) wasPressed = false;
  }else BTN_SPLIT = #1A5EA8;
}

void drawTable() {
  background(FELT_DARK);
  noStroke();
  fill(FELT);
  ellipse(width/2, height/2,int(width * 0.9),int(height * 0.8));
  //inner ring
  noFill();
  strokeWeight(2);
  stroke(#2E8B57, 80);
  ellipse(width/2, height/2,int(width * 0.850),int(height * 0.72));
  noStroke();
  drawButtons();
  drawBoard();
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
  text("Current Bet: " + currBet, int(width*0.25), int(height*0.95));
  
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

void drawBoard() {
  //temporary circle indicating dealer
  fill(#EDE860);
  circle(int(width/2), int(height*0.12), 100);
  fill(0);
  text("Dealer", int(width/2), int(height*0.12));
  text("Deck", int(width*0.7), int(height*0.27));
  
  //temporary lay out of the cards
  noFill();
  //Deck placeholder
  rect(int(width*0.7), int(height*0.27), int(width*0.15), int(height*0.15), int(width*0.0078125));
  //dealers hand placeholder
  rect(int(width*0.54), int(height*0.3), int(width*0.07), int(height*0.2), int(width*0.0078125));
  rect(int(width*0.46), int(height*0.3), int(width*0.07), int(height*0.2), int(width*0.0078125));
  //players hand placeholder
  rect(int(width*0.55), int(height*0.71), int(width*0.09), int(height*0.265), int(width*0.0078125));
  rect(int(width*0.45), int(height*0.71), int(width*0.09), int(height*0.265), int(width*0.0078125));
  
  //player name and number of chips
  textAlign(LEFT, CENTER);
  text("Player " + currPlayer, int(width*0.045), int(height*0.046));
  text("Chips: " + playerChips, int(width*0.045), int(height*0.068));
}
