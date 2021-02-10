/*
*/
import sprites.utils.*;
import sprites.maths.*;
import sprites.*;

// The dimensions of the monster grid.
int monsterCols = 4;
int monsterRows = 4  ;                                         
    
long mmCounter = 0;
int mmStep = 1; 

int missileSpeed = 800;
double upRadians = 4.71238898; // 1.5 PI

// Lower difficulty values introduce a more 
// random falling monster descent. 
int difficulty = 110;
double fmRightAngle = 0.3490; // 20 degrees
double fmLeftAngle = 2.79253; // 160 degrees
double fmSpeed = 100;

boolean gameOver = false;
int score = 0;
int points[] = { 5, 10, 15, 20, 25, 30, 35, 40 };


// Colors of the background
color[] backG = { color(0, 0, 0), color(64, 40, 74), color(115, 67, 74), color(179, 67, 37), color(197, 96, 41), color(216, 125, 45), color(225, 162, 60), color(247, 222, 85) };
int currentColor = -1;


// Life Variables
int level = 0;
int lives = 3;
int deadFrame = -100;


// Powerup Variables
int powerFrame = -100;
int currPowerUp = 0;
int prevPowerUp = 0;
int multishot = 0;
boolean hasPower = false;
int powerDivider = 250;

double rotDiff;

Sprite ship, missile, missile2, missile3, missile4, fallingMonster, explosion, gameOverSprite;
Sprite monsters[] = new Sprite[monsterCols * monsterRows];

KeyboardController kbController;
SoundPlayer soundPlayer;
StopWatch stopWatch = new StopWatch();



void setup() 
{
  kbController = new KeyboardController(this);
  soundPlayer = new SoundPlayer(this);  

  // register the function (pre) that will be called
  // by Processing before the draw() function.
  registerMethod("pre", this);

  size(700, 500);
  buildSprites();
  resetMonsters();

  // Ship Explosion Sprite
  explosion = new Sprite(this, "explosion_strip16.png", 17, 1, 90);
  explosion.setScale(1);

  // Game Over Sprite
  gameOverSprite = new Sprite(this, "gameOver.png", 100);
  gameOverSprite.setDead(true);
}

void buildSprites()
{
  // The Ship
  ship = buildShip();
  missile = buildMissile();
  missile2 = buildMissile();
  missile3 = buildMissile();

  // The Grid Monsters 
  buildMonsterGrid();
}

Sprite buildMissile()
{
  // The Missile
  Sprite sprite  = new Sprite(this, "laserBoltTrans.png", 10);
  sprite.setScale(.8);
  sprite.setDead(true); // Initially hide the missile
  return sprite;
}


Sprite buildShip()
{
  Sprite ship = new Sprite(this, "NewShip.png", 50);
  ship.setXY(width/2, height - 30);
  ship.setVelXY(0.0f, 0);
  ship.setScale(.09);
  ship.setRot(0);
  // Domain keeps the moving sprite withing specific screen area 
  ship.setDomain(0, height-ship.getHeight(), width, height, Sprite.HALT);

  return ship;
}

// Populate the monsters grid 
void buildMonsterGrid() 
{
  for (int idx = 0; idx < monsters.length; idx++ ) {
    monsters[idx] = buildMonster();
  }
}


void fireMissile() 
{
  if (hasPower)
  {
    if (!ship.isDead()) {

      if (missile.isDead() || missile2.isDead() || missile3.isDead())
      {

        missile.setPos(ship.getPos());
        missile2.setPos(ship.getPos());
        missile3.setPos(ship.getPos());

        missile2.setX(missile.getX() - 24);
        missile3.setX(missile.getX() + 24);

        missile2.setY(missile.getY() + 10);
        missile3.setY(missile.getY() + 10);

        missile.setSpeed(missileSpeed, upRadians);
        missile2.setSpeed(missileSpeed, upRadians);
        missile3.setSpeed(missileSpeed, upRadians);

        missile.setDead(false);
        missile2.setDead(false);
        missile3.setDead(false);

        soundPlayer.playShoot();
        multishot -= 3;
      }
    }
  } else if (missile.isDead() && !ship.isDead()) {
    missile.setPos(ship.getPos());
    missile.setSpeed(missileSpeed, upRadians);
    missile.setDead(false);
    soundPlayer.playShoot();
  }
}


// Arrange Monsters into a grid
void resetMonsters() 
{
  changeDifficulty();
  monsterRows++;

  for (int idx = 0; idx < monsters.length; idx++ ) {
    Sprite monster = monsters[idx];
    monster.setSpeed(0, 0);

    double mwidth = monster.getWidth() + 20;
    double totalWidth = mwidth * monsterCols;
    double start = (width - totalWidth)/2 - 25;
    double mheight = monster.getHeight();
    int xpos = (int)((((idx % monsterCols)*mwidth)+start));
    int ypos = (int)(((int)(idx / monsterCols)*mheight)+70);
    monster.setXY(xpos, ypos);

    monster.setDead(false);
    
    monster.setRot(0);
  }
}

// Build individual monster
Sprite buildMonster() 
{
  Sprite monster = new Sprite(this, "BadShipTrans.png", 30);
  monster.setScale(.4);
  monster.setDead(false);

  return monster;
}

// Executed before draw() is called 
public void pre() 
{    
  checkKeys();
  processCollisions();
  moveMonsters();

  // If missile flies off screen
  if (!missile.isDead() && ! missile.isOnScreem()) {
    stopMissile();
  }

  if (pickNonDeadMonster() == null && !gameOver) {
    resetMonsters();
  }

  // if falling monster is off screen
  if (fallingMonster == null || !fallingMonster.isOnScreem()) {
    replaceFallingMonster();
  }


  S4P.updateSprites(stopWatch.getElapsedTime());
} 

void replaceFallingMonster() 
{
  if (fallingMonster != null) {
    fallingMonster.setDead(true);
    fallingMonster = null;
  }

  // select new falling monster 
  fallingMonster = pickNonDeadMonster();
  if (fallingMonster == null) {
    return;
  }
  
  fallingMonster.setSpeed(fmSpeed, fmRightAngle);

  
  // Domain keeps the moving sprite within specific screen area 
  fallingMonster.setDomain(0, 0, width, height+100, Sprite.REBOUND);
  
  fallingMonster.setRot(fallingMonster.getDirection());
}




Sprite pickNonDeadMonster() 
{
  for (int idx = 0; idx < monsters.length; idx++) {
    Sprite monster = monsters[idx];
    if (!monster.isDead()) {
      return monster;
    }
  }
  return null;
}

void drawText() 
{
  if (!gameOver)
  {
    // Score
    textAlign(LEFT);
    textSize(32);
    String msg = " Score: " + score;
    text(msg, 10, 30);

    // Level Number
    textAlign(RIGHT);
    textSize(32);
    msg = " Level: " + level;
    text(msg, width-10, 30);

    //Lives
    textAlign(CENTER);
    textSize(32);
    msg = " Lives: " + lives;
    text(msg, width/2, 30);

    //Quickfire
    if (hasPower)
    {
      textAlign(LEFT);
      textSize(32);
      msg = " Multishot: " + multishot;
      text(msg, 10, 65);
    } else 
    {
      textAlign(LEFT);
      textSize(20);
      msg = " Next powerup at " + powerDivider;
      text(msg, 13, 55);
    }


    //Power up received
    if (frameCount < powerFrame + 80)
    {
      textAlign(CENTER);
      textSize(22);
      msg = " You have received the multishot powerup!";
      text(msg, width/2, 7*height/10 + 20);
    }
  }
}

void stopMissile() 
{
  missile.setSpeed(0, upRadians);
  missile.setDead(true);
}


void checkKeys() 
{
  if (focused) {
    if (kbController.isLeft()) {
      ship.setX(ship.getX()-10);
    }
    if (kbController.isRight()) {
      ship.setX(ship.getX()+10);
    }

    if (kbController.isSpace()) {
      fireMissile();
    }
  }
}

void moveMonsters() 
{  
  // Move Grid Monsters
  mmCounter++;
  if ((mmCounter % 100) == 0) mmStep *= -1;

  for (int idx = 0; idx < monsters.length; idx++ ) {
    Sprite monster = monsters[idx];
    if (!monster.isDead()&& monster != fallingMonster) {
      monster.setXY(monster.getX()+mmStep, monster.getY());
    }
  }

  // Move Falling Monster
  if (fallingMonster != null) {
    if (int(random(difficulty)) == 1) {
      // Change FM Speed
      fallingMonster.setSpeed(fallingMonster.getSpeed() 
        + random(-40, 40));
      // Reverse FM direction.
      if (fallingMonster.getDirection() == fmRightAngle) {
        rotDiff = random(10 * (2 * PI) / 360, 40 * (2 * PI) / 360);
        fallingMonster.setDirection(rotDiff);
        rotDiff -= PI / 2;
      } else{
        rotDiff = random(140 * (2 * PI) / 360, 170 * (2 * PI) / 360);
        fallingMonster.setDirection(rotDiff);
        rotDiff -= PI/ 2;
        
      }
    }
  }
}

// Detect collisions between sprites
void processCollisions() 
{
  // Detect collisions between Grid Monsters and Missile
  for (int idx = 0; idx < monsters.length; idx++) {
    Sprite monster = monsters[idx];
    if (!missile.isDead() && !monster.isDead() 
      && monster != fallingMonster 
      && missile.bb_collision(monster)) {
      score += points[level-1];
      monsterHit(monster);
      missile.setDead(true);
    }

    if (!missile2.isDead() && !monster.isDead() 
      && monster != fallingMonster 
      && missile2.bb_collision(monster)) {
      score += points[level-1];
      monsterHit(monster);
      missile2.setDead(true);
    }

    if (!missile3.isDead() && !monster.isDead() 
      && monster != fallingMonster 
      && missile3.bb_collision(monster)) {
      score += points[level-1];
      monsterHit(monster);
      missile3.setDead(true);
    }
  }


  // Between Falling Monster and Missile
  if (!missile.isDead() && fallingMonster != null 
    && missile.cc_collision(fallingMonster)) {
    score += points[level-1] + 5;
    monsterHit(fallingMonster); 
    missile.setDead(true);
    fallingMonster = null;
  }

  // Between Falling Monster and Missile 2
  if (!missile2.isDead() && fallingMonster != null 
    && missile2.cc_collision(fallingMonster)) {
    score += points[level-1] + 5;
    monsterHit(fallingMonster); 
    missile2.setDead(true);
    fallingMonster = null;
  }

  // Between Falling Monster and Missile
  if (!missile3.isDead() && fallingMonster != null 
    && missile3.cc_collision(fallingMonster)) {
    score += points[level-1] + 5;
    monsterHit(fallingMonster); 
    missile3.setDead(true);
    fallingMonster = null;
  }

  // Between Falling Monster and Ship
  if (fallingMonster!= null && !ship.isDead() 
    && fallingMonster.bb_collision(ship)) {
    multishot = 0;
    hasPower = false;
    explodeShip();
    monsterHit(fallingMonster);
    fallingMonster = null;
    lives--;
    if (lives <= 0)
    {
      gameOver = true;
    } else
    {
      deadFrame = frameCount;
    }
  }
}

void explodeShip() 
{
  soundPlayer.playExplosion();
  explosion.setPos(ship.getPos());
  explosion.setFrameSequence(0, 16, 0.1, 1);
  ship.setDead(true);
}


void monsterHit(Sprite monster) 
{
  soundPlayer.playPop();
  monster.setDead(true);
}

void drawGameOver() 
{
  gameOverSprite.setXY(width/2, height/2 - 20);
  gameOverSprite.setDead(false);

  // Score
  textAlign(CENTER);
  textSize(32);
  String msg = " Score: " + score;
  text(msg, width/2, height/2 + 25);

  // Level Number
  textAlign(CENTER);
  textSize(32);
  msg = " Level: " + level;
  text(msg, width/2, height/2  + 60);
}  

void changeDifficulty()
{

  level++;
  if (level > 8)
    level = 8;

  // Changes Speed
  if (fmSpeed < 600)
    fmSpeed += 62.5;

  // Changes Difficulty
  if (difficulty > 30)
    difficulty -= 10;

  // Changes Background
  currentColor++;
  if (level == 8)
    currentColor = backG.length - 1;
}

public void powerUp()
{
  currPowerUp = score / powerDivider;
  if (prevPowerUp != currPowerUp)
  {
    powerFrame = frameCount;
    powerDivider += 250;
    hasPower = true;
    prevPowerUp = currPowerUp;
    multishot = 30;
  }
  if (hasPower && multishot == 0)
  {
    hasPower = false;
  }
}


public void draw() 
{

  background(backG[currentColor]);
  S4P.drawSprites();
  if (fallingMonster != null) {
    fallingMonster.setRot(fallingMonster.getDirection() - PI / 2);
  }
  drawText();
  powerUp();
  if (deadFrame + 45 == frameCount)
  {
    ship = buildShip();
  }
  if (gameOver)
    drawGameOver();
}
