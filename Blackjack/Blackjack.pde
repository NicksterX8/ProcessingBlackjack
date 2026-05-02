// main file

// Most of the basic blackjack functions implemented: hit, stand, double, split
// Basic bot decision making in
// Need to test everything more though
// Important things that need to be implemented (game logic wise):
//  - Dealer drawing cards after the first two when the players finish
//  - Shuffling deck when cards get low, right now game will crash after like 10 rounds

Game game = new Game();
CountDracula count = new CountDracula();
int numBots = 3;
IntList bets = new IntList();

void setup() {
 //size(1440,1080); //to test scaling.
 fullScreen();
 int fontSize = int(width/96);
 f = createFont("Yu Gothic Bold", fontSize); 
 textFont(f);
 pixelDensity(1);
 cardW = int(width*0.027);
 cardH = int(height*0.067);
 loadCards();

}

void draw() {
  background(255);
  if(!started) {
    drawStartInteract();
    return;
  }
  drawTable();
  


  
  
  Hand activeHand = getActiveHand();
  if(game.currentRound.active){ 
     //Double button
    if(activeHand != null && activeHand.isDoubleable()) {
      if(mouseX >= (int(width*0.35)-int(width*0.035625)) && mouseX <= (int(width*0.35)+int(width*0.035625))
       && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
       BTN_DOUBLE = BTN_HOVER;
      if(mousePressed && !wasPressed) {
        game.doHumanAction(PlayerActionType.DOUBLE);
        println("Clicked Double!");
        wasPressed = true;
      }
      if(!mousePressed) wasPressed = false;
    }else BTN_DOUBLE = #F2975F; } else BTN_DOUBLE = #404040;
  
  //Stand button
  if(mouseX >= (int(width*0.45)-int(width*0.035625)) && mouseX <= (int(width*0.45)+int(width*0.035625))
     && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
    BTN_STAND = BTN_HOVER;
    if(mousePressed && !wasPressed) {
      game.doHumanAction(PlayerActionType.STAND);
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
      game.doHumanAction(PlayerActionType.HIT);
      println("Clicked Hit!");
      wasPressed = true;
    }
    if(!mousePressed) wasPressed = false;
  }else BTN_HIT = #39F070;
  
  //Split button
  if(activeHand != null && activeHand.isSplittable()) {
    if(mouseX >= (int(width*0.65)-int(width*0.035625)) && mouseX <= (int(width*0.65)+int(width*0.035625))
       && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
      BTN_SPLIT = BTN_HOVER;
      if(mousePressed && !wasPressed) {
        game.doHumanAction(PlayerActionType.SPLIT);
        println("Clicked Split!");
        wasPressed = true;
      }
      if(!mousePressed) wasPressed = false;
    }else BTN_SPLIT = #1A5EA8;
    }else BTN_SPLIT = #404040;
  }
   
   if (game.frameNumber - game.lastActionFrame > 15) {
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

void gameInit(){
  String playerName = "Bob";
  game.startGame();
  game.addHumanPlayer(playerName);
  for (int i = 0; i < numBots; i++) {
    game.addBotPlayer();
  }
  for (int i = 0; i < numBots + 1; i++) {
   bets.append(20); // change to amount decided by players
  }    
  game.startRound(bets);
  currPlayer = game.players.get(0);
}

void drawStartInteract(){
  // Start button
  if (mouseX > width*0.425 && mouseX < width*0.575 && mouseY > height*0.416 && mouseY < height*0.484) {
    BTN_START = BTN_HOVER;
    if (mousePressed && !wasPressed) {
      started = true;
      println("Game Started!");
      gameInit();
      wasPressed = true;
    }
  } 
  else { BTN_START = #39F070; }

  // Host button
  if (mouseX > (width/2 - width*0.13) && mouseX < (width/2 + width*0.02) && mouseY > height*0.516 && mouseY < height*0.584) {
    BTN_HOST = BTN_HOVER;
    if (mousePressed && !wasPressed) {
      if (portInput.length() == 0) {
        println("Please enter a port number.");
      } 
      else {
        //hostGame();
      }
      wasPressed = true;
    }
  } else { BTN_HOST = #F2975F; }

  // Host port box
  if (mouseX > (width/2 + width*0.03) && mouseX < (width/2 + width*0.13) &&
      mouseY > height*0.516 && mouseY < height*0.584) {
    if (mousePressed) {
      portBoxActive = true;
      joinBoxActive = false;
      ipBoxActive = false;
    }
  }

  // Join button
  if (mouseX > (width/2 - width*0.20) && mouseX < (width/2 - width*0.05) &&
      mouseY > height*0.616 && mouseY < height*0.684) {
    BTN_JOIN = BTN_HOVER;
    if (mousePressed && !wasPressed) {
      if (joinInput.length() == 0 || ipInput.length() == 0) {
        println("Please enter IP and port.");
      } else {
        //joinGame();
      }
      wasPressed = true;
    }
  } else { BTN_JOIN = #1A5EA8; }

  // IP box
  if (mouseX > (width/2 - width*0.04) && mouseX < (width/2 + width*0.09) &&
      mouseY > height*0.616 && mouseY < height*0.684) {
    if (mousePressed) {
      ipBoxActive = true;
      joinBoxActive = false;
      portBoxActive = false;
    }
  }

  // Join port box
  if (mouseX > (width/2 + width*0.10) && mouseX < (width/2 + width*0.20) &&
      mouseY > height*0.616 && mouseY < height*0.684) {
    if (mousePressed) {
      joinBoxActive = true;
      portBoxActive = false;
      ipBoxActive = false;
    }
  }

  if (!mousePressed) wasPressed = false;

  drawStart();
  return;
}

void drawBoard() {
  text("Round " + game.roundNumber, width/2, 20);
  text("True Count: " + count.getTrueCount(game.currentRound.deck), int(width*0.945), int(height*0.045));
  //player name and number of chips
  textAlign(LEFT, CENTER);
  int lineHeight = int(height * 0.03);
  int playerBlockHeight = int(height * 0.08);

  for (int i = 0; i < game.players.size(); i++) {
    textAlign(LEFT, CENTER);
    Player player = game.players.get(i);
    int blockY = int(height * 0.046) + i * playerBlockHeight;
    
      if (player == currPlayer) {
        text("Player " + player.name + " - It's your turn!", int(width*0.045), blockY);
      } else {
        text("Player " + player.name, int(width*0.045), blockY);
      }
        //text("Chips: " + player.chips, int(width*0.045), blockY + lineHeight);
      
     drawChip(int(width*0.045) + 35, blockY + lineHeight, 35, #B83232 , player.chips);
     //text("Chips: " + player.chips, int(width*0.045), int(height*0.068)+ i*int((height*0.055)));
     
     //draw cards if they have any
     if (player.currentHands.size() > 0) {
       if(game.players.size() == 1) {
         if(i == 0) drawPlayerHand(i, int(width/2.005), int(height* 0.8), cardW, cardH);
       }
       if(game.players.size() == 2) {
         if(i == 0) drawPlayerHand(i, int(width*0.4), int(height*0.75), cardW, cardH);
         if(i == 1) drawPlayerHand(i, int(width*0.6), int(height*0.75), cardW, cardH);
       }
       if(game.players.size() == 3) {
        if(i == 0)drawPlayerHand(i, int(width*0.3), int(height* 0.75), cardW, cardH);
        if(i == 1) drawPlayerHand(i, int(width/2.005), int(height* 0.8), cardW, cardH);
        if(i == 2) drawPlayerHand(i, int(width*0.65), int(height* 0.75), cardW, cardH);
       }
       if(game.players.size() == 4) {
        if (i == 0) drawPlayerHand(i, int(width*0.15), int(height*0.69), cardW, cardH);
        if (i == 1) drawPlayerHand(i, int(width*0.38), int(height*0.80), cardW, cardH);
        if (i == 2) drawPlayerHand(i, int(width*0.58), int(height*0.80), cardW, cardH);
        if (i == 3) drawPlayerHand(i, int(width*0.74), int(height*0.69), cardW, cardH);
         
       }
      
     }
   }
   drawDeckPile(int(width*0.7), int(height*0.27), cardW, cardH);
   if(!game.currentRound.active) currPlayer = game.players.get(0);
}

void keyPressed() {
  //host port button
  if (portBoxActive) {
    
    if (key == BACKSPACE && portInput.length() > 0)
      portInput = portInput.substring(0, portInput.length() - 1);
    
      else if (key >= '0' && key <= '9' && portInput.length() < 5)
      portInput += key;
    }

  if(ipBoxActive){
      if (key == BACKSPACE && ipInput.length() > 0)
      ipInput = ipInput.substring(0, ipInput.length() - 1);
    
      else if ((key >= '0' && key <= '9' || key == '.') && ipInput.length() < 15)
      ipInput += key;
  }
  
  //join port button
  if (joinBoxActive) {
    if (key == BACKSPACE && joinInput.length() > 0)
      joinInput = joinInput.substring(0, joinInput.length() - 1);
    
      else if (key >= '0' && key <= '9' && joinInput.length() < 5)
      joinInput += key;
  }
  

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
