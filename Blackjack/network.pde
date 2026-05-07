//import processing.net.*;

/*
Server server;
Client client;
boolean isHost = false;
boolean isConnected = false;
*/


// ═══════════════════════════════════════════════════════════════════════════════
//  Networking.pde  –  Blackjack multiplayer via processing.net
//
//  Architecture:
//    • Host  – runs ALL game logic (bots, dealer, round management).
//              Serializes full game state and broadcasts it every frame.
//    • Client – thin renderer.  Sends only player input (actions / bets).
//              Applies received state to its local game object for drawing.
//
//  INTEGRATION CHECKLIST  (changes needed in your existing files):
//    draw()       – add  pollNetwork();  at the very top of the function body.
//    draw()       – wrap bot / dealer logic in:  if (isHost || !isConnected) { … }
//    draw()       – replace every  game.doHumanAction(…)   with  netHumanAction(…)
//    draw()       – replace every  playerMakeBet()          with  netMakeBet(player.currentBet)
//    draw()       – gate button visibility with isMyTurn() / isMyBetTurn() where noted below.
//    drawStart()  – replace the commented-out hostGame() / joinGame() stubs with:
//                     hostGame(int(portInput));
//                     joinGame(ipInput, int(joinInput));
//
//  NOTE ON SEPARATORS:
//    All separator characters were chosen to be safe Java regex literals so that
//    Processing's split(str, String) works correctly.  Player names are sanitised
//    before serialisation to prevent injection.
// ═══════════════════════════════════════════════════════════════════════════════

import processing.net.*;

Server  server;
Client  client;
boolean isHost         = false;
boolean isConnected    = false;
int     myPlayerIndex  = 0;          // which player slot this machine owns
boolean clientInitialized = false;   // has the client set up its game object yet?

// Connected clients tracked by the host
ArrayList<Client>        connectedClients = new ArrayList<Client>();
HashMap<Client, Integer> clientPlayerMap  = new HashMap<Client, Integer>();

// ─── Serialisation separators (none are Java regex special characters) ────────
//     Hierarchy: S1 > S2 > S3 > S4 > S5 > S6 > S7
final String S1 = "#";   // top-level state fields
final String S2 = "&";   // between player blocks
final String S3 = ";";   // fields within a player block
final String S4 = "%";   // between hands within a player
final String S5 = "@";   // fields within a hand
final String S6 = ",";   // between cards in a hand
final String S7 = "!";   // rank vs. suit within a card token

// ─── Message-type tokens ──────────────────────────────────────────────────────
final String T_JOIN      = "JOIN";    // C→S  join request
final String T_PLAYER_ID = "PID";     // S→C  slot assignment
final String T_STATE     = "STATE";   // S→C  full game state broadcast
final String T_ACTION    = "ACT";     // C→S  in-round player action
final String T_BET       = "BET";     // C→S  bet confirmation
final String T_CHAT      = "CHAT";    // both directions
final String T_REJECT    = "REJECT";  // S→C  connection refused

// CONNECTION STUFF
// Call from the Host button handler in drawStart()
void hostGame(int port) {
  if (port < 1024 || port > 65535) {
    println("Port must be 1024–65535.");
    return;
  }
  try {
    server = new Server(this, port);
    isHost = true;
    isConnected  = true;
    myPlayerIndex = 0;
    println("Hosting on port " + port);
    gameInit(); // creates game, adds human player at index 0
    started = true;
  } catch (Exception e) {
    println("Failed to host: " + e.getMessage());
  }
}

// Call from the Join button handler in drawStart()
void joinGame(String ip, int port) {
  if (ip.length() == 0 || port < 1024 || port > 65535) {
    println("Enter a valid IP and port.");
    return;
  }
  try {
    client = new Client(this, ip, port);
    if (client != null && client.active()) {
      isHost = false;
      isConnected = true;
      // Sanitise name before sending to avoid illegal characters. Think about S constants
      String safeName = sanitize("Player");  // swap "Player" for a name field later
      sendToServer(T_JOIN + S1 + safeName);
      println("Connected to " + ip + ":" + port);
    } 
    else {
      println("Connection refused.");
      client = null;
    }
  } 
  catch (Exception e) {
    println("Failed to join: " + e.getMessage());
  }
}

// -------------------------------------------------------------------------------------------------
//  LOW-LEVEL SEND HELPERS


//send message to all clients
void broadcastToClients(String msg) {
  if (server == null) return;
  for (Client c : connectedClients) {
    if (c != null && c.active()) c.write(msg + "\n");
  }
}

//send to one client
void sendToClient(Client c, String msg) {
  if (c != null && c.active()) c.write(msg + "\n");
}

//client to server
void sendToServer(String msg) {
  if (client != null && client.active()) client.write(msg + "\n");
}

//--------------------------------------------------------------------------------------------------
//  PER-FRAME POLL  TODO: add  pollNetwork();  at the top of draw()


void pollNetwork() {
  if (!isConnected) return;
  if (isHost) {
    pollServer();
    // Broadcast full state to every client after processing their input
    broadcastToClients(T_STATE + S1 + serializeState());
  } else {
    pollClient();
  }
}

// ----------------------------------------------------------------------------------------------------
//  SERVER-SIDE POLLING


void pollServer() {
  // Accept any new inbound connections
  Client incoming = server.available();
  if (incoming != null) {
    connectedClients.add(incoming);
    println("[Net] Client connected. Total: " + connectedClients.size());
  }

  // Drain messages from every connected client
  for (int i = connectedClients.size() - 1; i >= 0; i--) {
    Client c = connectedClients.get(i);
    if (c == null || !c.active()) {
      onClientDisconnect(c, i);
      continue;
    }
    String raw;
    // readStringUntil returns null when the delimiter hasn't arrived yet
    while ((raw = c.readStringUntil('\n')) != null) {
      raw = raw.trim();
      if (raw.length() > 0) handleServerMessage(c, raw);
    }
  }
}

void handleServerMessage(Client c, String raw) {
  String[] parts = split(raw, S1);
  if (parts.length == 0) return;
  String type = parts[0];

  // ── JOIN ──────────────────────────────────────────────────────
  if (type.equals(T_JOIN)) {

    //checks the if name exists
    String name = (parts.length > 1) ? parts[1] : "Player";

    //table is full
    if (game.players.size() >= 4) {
      sendToClient(c, T_REJECT + S1 + "Table is full (max 4 players).");
      return;
    }
    if (started && game.currentRound != null && game.currentRound.active) {
      sendToClient(c, T_REJECT + S1 + "A round is already in progress.");
      return;
    }

    int idx = game.players.size();
    game.addHumanPlayer(name);
    clientPlayerMap.put(c, idx);
    sendToClient(c, T_PLAYER_ID + S1 + idx);
    println("[Net] '" + name + "' joined as player " + idx);
  }

  // ── ACTION (hit / stand / double / split) ─────────────────────
  else if (type.equals(T_ACTION)) {
    if (!clientPlayerMap.containsKey(c)) return;
    int idx = clientPlayerMap.get(c);
    // Only accept if it is genuinely that player's turn
    if (game.currentRound == null || game.currentRound.turn != idx) return;

    PlayerActionType act = parseAction(parts.length > 1 ? parts[1] : "");
    if (act != null) game.doHumanAction(act);
  }

  // ── BET ───────────────────────────────────────────────────────
  else if (type.equals(T_BET)) {
    if (!clientPlayerMap.containsKey(c)) return;
    int idx = clientPlayerMap.get(c);
    if (playerBetTurn != idx) return;   // not their bet turn

    int amount = int(parts.length > 1 ? parts[1] : "0");
    Player p   = game.currentRound.players.get(idx);
    p.currentBet = constrain(amount, 0, p.chips);
    playerMakeBet();
  }

  // ── CHAT ──────────────────────────────────────────────────────
  else if (type.equals(T_CHAT)) {
    String msg    = (parts.length > 1) ? parts[1] : "";
    Integer idx   = clientPlayerMap.get(c);
    String sender = (idx != null && idx < game.players.size())
                    ? game.players.get(idx).name : "???";
    broadcastToClients(T_CHAT + S1 + sender + ": " + msg);
    println("[Chat] " + sender + ": " + msg);
  }
}

// Called when a client's socket goes inactive
void onClientDisconnect(Client c, int listIndex) {
  println("[Net] Client disconnected.");
  Integer idx = clientPlayerMap.remove(c);
  if (idx != null && idx < game.players.size()) {
    // Convert the abandoned seat to a bot so the round can continue
    game.players.get(idx).human = false;
    println("[Net] Player " + idx + " (" + game.players.get(idx).name
            + ") converted to bot after disconnect.");
  }
  connectedClients.remove(listIndex);
}

// ═══════════════════════════════════════════════════════════════════════════════
//  CLIENT-SIDE POLLING
// ═══════════════════════════════════════════════════════════════════════════════

void pollClient() {
  if (client == null || !client.active()) {
    println("[Net] Lost connection to host.");
    isConnected = false;
    return;
  }
  String raw;
  while ((raw = client.readStringUntil('\n')) != null) {
    raw = raw.trim();
    if (raw.length() > 0) handleClientMessage(raw);
  }
}

void handleClientMessage(String raw) {
  String[] parts = split(raw, S1);
  if (parts.length == 0) return;
  String type = parts[0];

  // ── PID – the host is telling us which slot we own ────────────
  if (type.equals(T_PLAYER_ID)) {
    myPlayerIndex = int(parts[1]);
    started       = true;
    println("[Net] Assigned player slot " + myPlayerIndex);
  }

  // ── STATE – apply the authoritative game snapshot ─────────────
  else if (type.equals(T_STATE)) {
    if (parts.length > 1) deserializeState(parts[1]);
  }

  // ── REJECT ────────────────────────────────────────────────────
  else if (type.equals(T_REJECT)) {
    String reason = (parts.length > 1) ? parts[1] : "Connection rejected.";
    println("[Net] Rejected: " + reason);
    client.stop();
    client      = null;
    isConnected = false;
  }

  // ── CHAT ──────────────────────────────────────────────────────
  else if (type.equals(T_CHAT)) {
    if (parts.length > 1) println("[Chat] " + parts[1]);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  ACTION SENDERS  –  replace direct game.doHumanAction calls in draw() with these
// ═══════════════════════════════════════════════════════════════════════════════

// Replaces  game.doHumanAction(action)  in your draw() button handlers
void netHumanAction(PlayerActionType action) {
  if (isHost || !isConnected) {
    game.doHumanAction(action);
  } else {
    sendToServer(T_ACTION + S1 + action.name());
  }
}

// Replaces  playerMakeBet()  when the confirm-bet button is clicked
// Pass the player's locally staged bet amount
void netMakeBet(int amount) {
  if (isHost || !isConnected) {
    Player p = game.currentRound.players.get(myPlayerIndex);
    p.currentBet = constrain(amount, 0, p.chips);
    playerMakeBet();
  } else {
    sendToServer(T_BET + S1 + amount);
  }
}

// Optional – send a chat message
void netSendChat(String msg) {
  if (isHost || !isConnected) {
    String name = game.players.size() > 0 ? game.players.get(0).name : "Host";
    broadcastToClients(T_CHAT + S1 + name + ": " + msg);
    println("[Chat] " + name + ": " + msg);
  } else {
    sendToServer(T_CHAT + S1 + msg);
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  TURN GUARDS  –  use these to gate button visibility / click handling in draw()
// ═══════════════════════════════════════════════════════════════════════════════

// Returns true when it is this machine's player's turn to act
boolean isMyTurn() {
  if (!isConnected) return true;                            // solo
  if (game.currentRound == null) return false;
  return game.currentRound.turn == myPlayerIndex;
}

// Returns true when it is this machine's player's turn to bet
boolean isMyBetTurn() {
  if (!isConnected) return true;
  return playerBetTurn == myPlayerIndex;
}

// ═══════════════════════════════════════════════════════════════════════════════
//  STATE SERIALISATION  (host → clients)
//
//  Wire format (fields separated by S1 = "#"):
//    takingBets # playerBetTurn # round.active # round.turn # round.handNumber
//    # round.revolutions # roundNumber # dealerCards # dealerActive # playerBlocks
//
//  playerBlocks  – S2-joined ("&") list of player tokens
//  player token  – "name;chips;currentBet;human;hand%hand%…"
//  hand token    – "cards@betChips@active"
//  cards token   – S6-joined (",") list of "rank!suit"
// ═══════════════════════════════════════════════════════════════════════════════

String serializeState() {
  Round r = game.currentRound;
  StringBuilder sb = new StringBuilder();

  sb.append(takingBets ? "1" : "0").append(S1);
  sb.append(playerBetTurn).append(S1);
  sb.append(r.active ? "1" : "0").append(S1);
  sb.append(r.turn).append(S1);
  sb.append(r.handNumber).append(S1);
  sb.append(r.revolutions).append(S1);
  sb.append(game.roundNumber).append(S1);

  // Dealer hand
  sb.append(serializeCards(r.dealerHand.cards)).append(S1);
  sb.append(r.dealerHand.active ? "1" : "0").append(S1);

  // Players
  for (int i = 0; i < r.players.size(); i++) {
    if (i > 0) sb.append(S2);
    sb.append(serializePlayer(r.players.get(i)));
  }

  return sb.toString();
}

// ── Card-level helpers ────────────────────────────────────────────────────────

// Single card  →  "rank!suit"
String serializeCard(Card c) {
  return c.rank + S7 + c.suit;
}

// ArrayList<Card>  →  "rank!suit,rank!suit,…"  (empty string if no cards)
String serializeCards(ArrayList<Card> cards) {
  if (cards == null || cards.isEmpty()) return "";
  StringBuilder sb = new StringBuilder();
  for (int i = 0; i < cards.size(); i++) {
    if (i > 0) sb.append(S6);
    sb.append(serializeCard(cards.get(i)));
  }
  return sb.toString();
}

// ── Hand-level helper ─────────────────────────────────────────────────────────

// Hand  →  "cards@betChips@active"
String serializeHand(Hand h) {
  return serializeCards(h.cards) + S5 + h.betChips + S5 + (h.active ? "1" : "0");
}

// ── Player-level helper ───────────────────────────────────────────────────────

// Player  →  "name;chips;currentBet;human;hand%hand%…"
String serializePlayer(Player p) {
  StringBuilder sb = new StringBuilder();
  sb.append(sanitize(p.name)).append(S3);
  sb.append(p.chips         ).append(S3);
  sb.append(p.currentBet    ).append(S3);
  sb.append(p.human ? "1" : "0").append(S3);
  for (int i = 0; i < p.currentHands.size(); i++) {
    if (i > 0) sb.append(S4);
    sb.append(serializeHand(p.currentHands.get(i)));
  }
  return sb.toString();
}

// ═══════════════════════════════════════════════════════════════════════════════
//  STATE DESERIALISATION  (client side)
// ═══════════════════════════════════════════════════════════════════════════════

void deserializeState(String data) {
  // Bootstrap a bare game object on first STATE received
  if (!clientInitialized) {
    game.startGame();          // creates game.currentRound; adjust if your API differs
    clientInitialized = true;
  }

  String[] top = split(data, S1);
  // Indices: 0=takingBets 1=playerBetTurn 2=active 3=turn 4=handNumber
  //          5=revolutions 6=roundNumber 7=dealerCards 8=dealerActive 9=playerBlocks
  if (top.length < 10) return;

  takingBets        = top[0].equals("1");
  playerBetTurn     = int(top[1]);
  Round r           = game.currentRound;
  r.active          = top[2].equals("1");
  r.turn            = int(top[3]);
  r.handNumber      = int(top[4]);
  r.revolutions     = int(top[5]);
  game.roundNumber  = int(top[6]);

  // Dealer
  r.dealerHand.cards  = deserializeCards(top[7]);
  r.dealerHand.active = top[8].equals("1");

  // Players – grow / shrink the list to match the host's player count
  String[] playerBlocks = split(top[9], S2);
  while (r.players.size() < playerBlocks.length) {
    r.players.add(new Player(500, false, "?"));
  }
  while (r.players.size() > playerBlocks.length) {
    r.players.remove(r.players.size() - 1);
  }
  for (int i = 0; i < playerBlocks.length; i++) {
    deserializePlayer(r.players.get(i), playerBlocks[i]);
  }
  // Keep game.players in sync so drawBoard() etc. work normally
  game.players = r.players;
}

// ── Card-level helpers ────────────────────────────────────────────────────────

ArrayList<Card> deserializeCards(String data) {
  ArrayList<Card> cards = new ArrayList<Card>();
  if (data == null || data.length() == 0) return cards;
  String[] tokens = split(data, S6);
  for (String token : tokens) {
    String[] cf = split(token, S7);
    if (cf.length < 2) continue;
    String rank = cf[0];
    int    suit = int(cf[1]);
    cards.add(new Card(rank, suit));   // adjust constructor if yours differs
  }
  return cards;
}

// ── Hand-level helper ─────────────────────────────────────────────────────────

//transfer data to hand object
Hand deserializeHand(String data) {
  Hand h = new Hand(-1); // dummy bet, will be overwritten by deserialised value
  String[] hf = split(data, S5);
  if (hf.length < 3) return h;
  h.cards    = deserializeCards(hf[0]);
  h.betChips = int(hf[1]);
  h.active   = hf[2].equals("1");
  return h;
}

// ── Player-level helper ───────────────────────────────────────────────────────

void deserializePlayer(Player p, String data) {
  String[] pf = split(data, S3);
  if (pf.length < 4) return;
  p.name       = pf[0];
  p.chips      = int(pf[1]);
  p.currentBet = int(pf[2]);
  p.human      = pf[3].equals("1");

  p.currentHands.clear();
  if (pf.length > 4 && pf[4].length() > 0) {
    String[] handTokens = split(pf[4], S4);
    for (String ht : handTokens) {
      p.currentHands.add(deserializeHand(ht));
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  UTILITY
// ═══════════════════════════════════════════════════════════════════════════════

// Safely parse a PlayerActionType from a network string
PlayerActionType parseAction(String s) {
  try {
    return PlayerActionType.valueOf(s);
  } catch (Exception e) {
    println("[Net] Unknown action: " + s);
    return null;
  }
}

// Strip separator characters from user-supplied strings before serialising
String sanitize(String s) {
  return s.replaceAll("[#&;%@,!]", "_");
}

// Graceful shutdown – call from your exit handler or a quit button
void stopNetworking() {
  if (client != null) { client.stop(); client = null; }
  if (server != null) { server.stop(); server = null; }
  isConnected = false;
  println("[Net] Networking stopped.");
}





/*
void hostGame(int port) {
    if(port < 1024 || port > 65535) {
        print("Please enter a valid port number (1024-65535).\n");
        return;
    }
    try {
        server = new Server(this, int(portInput));
        isHost = true;
        isConnected = true;
        println("Hosting on port " + portInput);
        gameInit();
        started = true;
    } 
    catch (Exception e) {
        println("Failed to host: " + e.getMessage());
    }
}*/