// Depends on processing's sound library to play music

// Important things that need to be implemented (game logic wise):
//  - Shuffling deck when cards get low, right now game will crash after like 10 rounds

import processing.sound.*;

Game game = new Game();
CountDracula count = new CountDracula();
int numBots = 0;
int players = 0;
boolean SEECOUNT = true;
int roundNumber = 1;
boolean ending = false;
int selectedBotIndex = -1; 
boolean botButtonPressed = false; // Flag to prevent multi-clicks

SoundFile bgMusic;

import java.io.File;

void loadMusic() {
   
  File f = new File(dataPath("background.mp3")); 
   try {
     if (f.exists()) {
       bgMusic = new SoundFile(this, "background.mp3");
     } else {
        print("No background music file found. If music is desired, put background.mp3 in the data folder.");  
     }
   } catch (Exception e) {
     print("Failed to load background music. If music is desired, put background.mp3 in the data folder"); 
   }
   if (bgMusic != null) {
     bgMusic.loop();
   }
}

void setup() {
 //size(1440,1080); //to test scaling.
 fullScreen();
 fontSize = int(width/96);
 f = createFont("Yu Gothic Bold", fontSize); 
 f2 = createFont("Yu Gothic Bold", int(width/170)); 
 textFont(f);
 pixelDensity(1);
 cardW = int(width*0.031);
 cardH = int(height*0.075);
 loadCards();
 loadMusic();
}

final int GAME_SPEED = 45; // number of frames between actions like drawing cards. lower is faster 
int timeRoundEnded = -10000;
boolean takingBets = true;
int playerBetTurn = 0;
boolean firstRound = true;
boolean counterPlaced = false;
Player counter = null;

void startRound() {

  IntList bets = new IntList();
  //places the count Dracula in a bot
  if(firstRound && game.players.size() > 2){
    counterPlaced = false;
    while(!counterPlaced){
        int randomPlayer = int(random(0, game.players.size()));
        if (!game.players.get(randomPlayer).human) {
          game.players.get(randomPlayer).knowsCount = true;
          counterPlaced = true;
          counter = game.players.get(randomPlayer);
          print("Count Dracula has been placed in a bot" + game.players.get(randomPlayer).name + "\n");
        }
    }

  }
  
  if(game.currentRound.deck.cards.size() < game.currentRound.deck.ogSize * 0.25) {
     print("Shuffling new deck.\n");
     game.currentRound.deck = createShuffledDeck(2); // create new deck with 6 duplicates of each card
     count.resetCount();
  }

  for (int i = 0; i < game.currentRound.players.size(); i++) {
    Player player = game.currentRound.players.get(i);
     bets.append(player.currentBet);
  }    
  game.startRound(bets);
  
  takingBets = false;
  playerBetTurn = 0;
  for (Player player : game.players) {
    player.currentBet = 0;
  }

  if(firstRound) {
    firstRound = false;
  }
}

void endRound() {
   game.currentRound.active = false;
   timeRoundEnded = game.frameNumber; 
   game.endRound();
   print("The round is over");

  if(roundNumber >= 10){
    ending = true;
    calculateWin();
    print("game ended");
   }
  roundNumber++;
}

void playerMakeBet() {
    game.currentRound.turn += 1;
    if (game.currentRound.turn >= game.currentRound.players.size()) {
      game.currentRound.turn = 0;
      startRound();
    }
    playerBetTurn = game.currentRound.turn;
}

Player winner = null;
void calculateWin(){

  int highestChipCount = 0;
  for(int i = 0; i < game.players.size(); i++){
    if(game.players.get(i).chips > highestChipCount){
      winner = game.players.get(i);
      highestChipCount = game.players.get(i).chips;
    }
  }  
  
}

void draw() {

  background(255);
  if(!started) {
    drawStartInteract();
    if (showFaqPage) drawInfo();
    return;
  }

  if(ending){
    drawEnd();
    return;

  }
  
  drawTable(takingBets);
  
  
  if(firstRound){
      // Add Bot button interaction (Matched to 0.957w, 0.16h center)
    if (mouseX >= (int(width * 0.957) - int(width * 0.035)) && mouseX <= (int(width * 0.957) + int(width * 0.035))
        && mouseY >= (int(height * 0.16) - int(height * 0.02)) && mouseY <= (int(height * 0.16) + int(height * 0.02))) {
      
      BTN_ADDBOT = BTN_HOVER;
      
      if (mousePressed && !wasPressed) {
        if(game.players.size() >= 4) {
          println("Cannot add more bots. Maximum of 4 total players.");
          return;
        }
        numBots++;
        game.addBotPlayer();
        println("Bot added successfully.");
        
        wasPressed = true;
      }
      if (!mousePressed) wasPressed = false;
      
    } else {
      BTN_ADDBOT = #2C3E50; // Default Blue color
    }

  // Remove Bot button interaction (0.957w, 0.22h center)
  if (mouseX >= (int(width * 0.957) - int(width * 0.035)) && mouseX <= (int(width * 0.957) + int(width * 0.035))
       && mouseY >= (int(height * 0.22) - int(height * 0.02)) && mouseY <= (int(height * 0.22) + int(height * 0.02))) {
    
    BTN_REMOVEBOT = BTN_HOVER;
    
    if (mousePressed && !wasPressed) {
      // Logic to remove the last bot added
      if (game.players.size() > 1) { // Ensure at least one player remains
        for (int i = game.players.size() - 1; i >= 0; i--) {
          if (!game.players.get(i).human) {
            game.players.remove(i);
            println("Bot removed.");
            numBots--;
            break; 
          }
        }
      }
      
      wasPressed = true;
    }
    if (!mousePressed) wasPressed = false;
    
  } else {
    BTN_REMOVEBOT = #2C3E50; // Red color for removal
  }



  }  
  Hand activeHand = getActiveHand();
  Player activePlayer = game.currentRound.activePlayer();
  if (game.currentRound.active) {
    //info button
    infoButtonInteract();
     //Double button
    if (activeHand != null && activeHand.isDoubleable()) {
      if(mouseX >= (int(width*0.35)-int(width*0.035625)) && mouseX <= (int(width*0.35)+int(width*0.035625))
           && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ) {
           BTN_DOUBLE = BTN_HOVER;
         if (mousePressed && !wasPressed) {
            game.doHumanAction(PlayerActionType.DOUBLE);
            println("Clicked Double!");
            wasPressed = true;
         }
         if (!mousePressed) wasPressed = false;
       } else { 
         BTN_DOUBLE = #F2975F;
       }
    } 
    else BTN_DOUBLE = #404040;
  
  //Stand button
  if(mouseX >= (int(width*0.45)-int(width*0.035625)) && mouseX <= (int(width*0.45)+int(width*0.035625))
     && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
    BTN_STAND = BTN_HOVER;
    if(mousePressed && !wasPressed) {
        game.doHumanAction(PlayerActionType.STAND);
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
        wasPressed = true;
      }
      if(!mousePressed) wasPressed = false;
  } else BTN_HIT = #39F070;
  
  //Split button
    if(activeHand != null && activeHand.isSplittable()) {
      if(mouseX >= (int(width*0.65)-int(width*0.035625)) && mouseX <= (int(width*0.65)+int(width*0.035625))
         && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
        BTN_SPLIT = BTN_HOVER;
        if(mousePressed && !wasPressed) {
          game.doHumanAction(PlayerActionType.SPLIT);
          wasPressed = true;
        }
        if(!mousePressed) wasPressed = false;
      }else BTN_SPLIT = #1A5EA8;
    } else BTN_SPLIT = #404040;
  } else { // round not active
    if (takingBets) {
      Player player = activePlayer;
      
      // decrease bet button
      if(mouseX >= (int(width*0.45)-int(width*0.035625)) && mouseX <= (int(width*0.45)+int(width*0.035625))
           && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
        BTN_STAND = BTN_HOVER;
        if(mousePressed && !wasPressed) {
            player.currentBet -= 10;
            if (player.currentBet < 0) player.currentBet = 0;
            wasPressed = true;
        }
        if(!mousePressed) wasPressed = false;
      } else BTN_STAND = #B83232;
      // increase bet button
      if(mouseX >= (int(width*0.55)-int(width*0.035625)) && mouseX <= (int(width*0.55)+int(width*0.035625))
         && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
        BTN_HIT = BTN_HOVER;
        if(mousePressed && !wasPressed) {
            player.currentBet += 10;
            if (player.currentBet > player.chips) {
               player.currentBet = player.chips; 
            }
            wasPressed = true;
        }
        if(!mousePressed) wasPressed = false;
      } else BTN_HIT = #39F070;
      
      // confirm bet button
      if (player.currentBet > 0) {
        if(mouseX >= (int(width*0.65)-int(width*0.035625)) && mouseX <= (int(width*0.65)+int(width*0.035625))
           && mouseY >=(int(height*0.95)-int(height*0.034)) && mouseY <= (int(height*0.95)+int(height*0.034)) ){
          BTN_SPLIT = BTN_HOVER;
          if(mousePressed && !wasPressed) {
              playerMakeBet();
          }
          if (!mousePressed) wasPressed = false;
        } else BTN_SPLIT = #1A5EA8;
      }


      if (playerChosen && game.players.size() > 2) {
        int i = 0;
        for (int pIdx = 0; pIdx < game.players.size(); pIdx++) {
          Player p = game.players.get(pIdx);
          if (!p.human && i < 3) {
            float x = width / 2, y = (height * 0.45) + (i * (height * 0.07));
            float bw = width * 0.15, bh = height * 0.05;

            if (mouseX >= x-bw/2 && mouseX <= x+bw/2 && mouseY >= y-bh/2 && mouseY <= y+bh/2) {
              if (mousePressed && !wasPressed) {
                selectedBotIndex = pIdx; 
                wasPressed = true;
                println("Choice: " + p.name);
              }
            }
            if (!mousePressed) wasPressed = false;
            i++;
          }
        }
      }



      
    }
  }
  
    // Round ending sequence
    // when dealer finishes turn
    // 2 seconds: "round over" text is shown
    // 2 seconds: "Starting next round" text is shown
    // next round starts
   
   if (game.frameNumber - game.lastActionFrame > GAME_SPEED) {
     if (game.currentRound.active) {
       boolean allPlayersInactive = true;
       for (Player player : game.currentRound.players) {
         if (player.active()) {
            allPlayersInactive = false; 
         }
       }
       
       if (!takingBets && game.currentRound.revolutions < 2) {
         // been enough time from last card dealt, deal one
          game.currentRound.dealStartingCard();
       }
       // check if it's time for the dealer to do his turn
       else if (allPlayersInactive && game.currentRound.dealerHand.active) {
          print("Dealer taking turn.\n");
          boolean dealerTurnOver = game.currentRound.doDealerTurn();
          if (dealerTurnOver) {
             endRound();
          }
       }
       else if (!game.currentRound.activePlayer().human) {
          game.doBotAction();
       }
       game.lastActionFrame = game.frameNumber;  
     }
   }
   
  if (activePlayer != null && !activePlayer.human && takingBets) {
    float tc = count.getTrueCount(game.currentRound.deck);
    float aggression = activePlayer.botAggression;
    int botBet;

    if (activePlayer.knowsCount && tc > 1) {
      float fraction = constrain(tc, 0, 10) / 20.0; // 0 to 0.5
      botBet = int(activePlayer.chips * fraction * aggression);
    } else {
      botBet = int(activePlayer.chips * random(0.05, 0.2) * aggression);
    }

    botBet = (botBet / 10) * 10;
    botBet = constrain(botBet, 10, activePlayer.chips / 2);
    activePlayer.currentBet = botBet;
    playerMakeBet();
  }
 
   if (takingBets && !showFaqPage) {
     textSize(30);
     textAlign(CENTER);
     if(firstRound){
        text("Place your bets! (You can add and remove bots with the buttons on the top right)\nMake SURE all players join before beginning!", width/2, 100);
     } else {
        text("Place your bets for the next round!", width/2, 100);
     }
   }
   
   if (game.frameNumber - timeRoundEnded < 120) {
      textSize(36);
      textAlign(CENTER);
      text("Round over.", width/2, height * 0.2);
   }
   else if (!game.currentRound.active && game.frameNumber - timeRoundEnded >= 260 && takingBets == false) {
      takingBets = true;
      ArrayList<Player> newPlayers = new ArrayList<Player>();
      for (int i = 0; i < game.players.size(); i++) {
        Player player = game.players.get(i);
        if (player.chips > 0) {
          newPlayers.add(player);
        }
      }
      game.currentRound.changePlayers(newPlayers);
   }
   else if (game.frameNumber - timeRoundEnded >= 140 && game.frameNumber - timeRoundEnded < 260) {
      textSize(36);
      textAlign(CENTER);
      text("Starting new round...", width/2, height * 0.4);
   }
   
   //-------SALIM-------
   infoButtonInteract();
  //info page
  if (showFaqPage) {
    drawInfo();
  }
  //-------SALIM-------
   
   //-------SALIM-------
   //info button (overlays game table)
   drawInfoButton();
   //-------SALIM-------
   
   game.frameNumber++;
}




void gameInit(){
  String playerName = "You";
  game.startGame();
  game.addHumanPlayer(playerName);
  for (int i = 0; i < numBots; i++) {
    game.addBotPlayer();
  }
  
  if (game.players.size() > 4) {
     print("ERROR: Game can only support up to 4 players"); 
  }
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
        started = true; 
        wasPressed = true;
        println("Hosting game on port: " + portInput);
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
      } 
      else {
        //joinGame();
        // --- CLIENT START LOGIC ---
        println("Connecting to: " + ipInput + ":" + joinInput);
        // We do NOT call gameInit() here; the host will send us the game state
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

  //-------SALIM-------
  if (!mousePressed) wasPressed = false;

  drawStart();

  //info button (overlays start screen)
  drawInfoButton();
  infoButtonInteract();
//-------SALIM-------

  return;
}

String getHandResultString(Hand hand) {
   HandResultType handResult = game.currentRound.calculateHandResult(hand);
   switch (handResult) {
      case BUST: return "Bust";
      case LOSE: return "Loss";
      case WIN: return "Win";
      case BLACKJACK: return "Blackjack";
      case PUSH: return "Push";
   } 
   return "";
}

void drawBoard() {
  textSize(20);
  textAlign(CENTER, TOP);
  text("Round " + game.roundNumber, width/2, 50);
  textAlign(RIGHT, TOP);
  if(SEECOUNT) {
    text("True Count: " + count.getTrueCount(game.currentRound.deck), int(width-(width * 0.00961538461)), int(width*0.02604166666));
  }
  //player name and number of chips
  textAlign(LEFT, CENTER);
  int lineHeight = int(height * 0.03);
  int playerBlockHeight = int(height * 0.08);
  
  ArrayList<Player> players = game.currentRound.players;
  
  for (int i = 0; i < players.size(); i++) {
    textAlign(LEFT, CENTER);
    Player player = game.currentRound.players.get(i);
    int blockY = int(height * 0.046) + i * playerBlockHeight;
    
      textSize(16);
      fill(0);
      
      if (player == game.currentRound.activePlayer()) {
        text(player.name + " - It's your turn!", int(width*0.045), blockY);
      } else {
        text(player.name, int(width*0.045), blockY);
      }
        //text("Chips: " + player.chips, int(width*0.045), blockY + lineHeight);
      
     drawChip(int(width*0.045) + 35, blockY + lineHeight, 35, #B83232 , player.chips, 1.0);
     //text("Chips: " + player.chips, int(width*0.045), int(height*0.068)+ i*int((height*0.055)));
     
     //draw cards if they have any
     if (player.currentHands.size() > 0) {
       if(players.size() == 1) {
         if(i == 0) drawPlayerHand(i, int(width/2.005), int(height* 0.8), cardW, cardH);
       }
       if(players.size() == 2) {
         if(i == 0) drawPlayerHand(i, int(width*0.4), int(height*0.75), cardW, cardH);
         if(i == 1) drawPlayerHand(i, int(width*0.6), int(height*0.75), cardW, cardH);
       }
       if(players.size() == 3) {
        if(i == 0)drawPlayerHand(i, int(width*0.3), int(height* 0.75), cardW, cardH);
        if(i == 1) drawPlayerHand(i, int(width/2.005), int(height* 0.8), cardW, cardH);
        if(i == 2) drawPlayerHand(i, int(width*0.65), int(height* 0.75), cardW, cardH);
       }
       if(players.size() == 4) {
        if (i == 0) drawPlayerHand(i, int(width*0.15), int(height*0.69), cardW, cardH);
        if (i == 1) drawPlayerHand(i, int(width*0.38), int(height*0.80), cardW, cardH);
        if (i == 2) drawPlayerHand(i, int(width*0.58), int(height*0.80), cardW, cardH);
        if (i == 3) drawPlayerHand(i, int(width*0.74), int(height*0.69), cardW, cardH);
         
       }
      
     }
   }
   drawDeckPile(int(width*0.7), int(height*0.27), cardW, cardH);
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
    }
}
