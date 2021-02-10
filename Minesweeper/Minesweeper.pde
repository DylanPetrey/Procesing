int squareSize = 40; //<>// //<>//
int horr = 30;
int vert = 15;
int mines = 100;
int flags;
int startTime;
PFont numFont;
PFont titleFont;
box grid[][];
frontBox board[][];

public class box {
  public float x;
  public float y;
  public int numMines;
  public color type = #BDBDBD;
  public boolean isMine = false;

  void drawBox() {
    float boxX = x * squareSize + 20;
    float boxY = y * squareSize + 100;
    fill(type);
    strokeWeight(2);
    stroke(#7B7B7B);
    rectMode(CORNER);
    rect(boxX, boxY, squareSize, squareSize);
    if (!isMine && numMines != 0) {
      fill(0);
      strokeWeight(0);
      textAlign(CENTER, CENTER);
      textFont(numFont);
      text(str(numMines), boxX + squareSize/2, boxY + squareSize/2 - 5);
    }
  }
}

public class frontBox {
  public float x;
  public float y;
  public boolean isHidden = true;

  void drawBox() {
    float boxX = x * squareSize + 20;
    float boxY = y * squareSize + 100;
    fill(#BDBDBD);
    strokeWeight(2);
    stroke(#7B7B7B);
    rectMode(CORNER);
    rect(boxX, boxY, squareSize, squareSize);
  }
}

void setup() {
  startTime = millis();
  frameRate(30);
  size(1240, 720);
  background(#C0C0C0);
  grid = new box[vert][horr];
  board = new frontBox[vert][horr];
  numFont = createFont("MarkaziText-Regular.ttf", 30);
  titleFont = createFont("MarkaziText-Regular.ttf", 50);
  flags = mines;

  populateGrid();
  drawGrid();
  drawOverlay();
}

void draw() {
  drawTop();
  drawOverlay();
  hideBoxes();
}

void hideBoxes() {
  int boxX, boxY;
  if (mousePressed && (mouseButton == LEFT)) {
    boxX = getXBox(mouseX);
    boxY = getYBox(mouseY);
    board[boxY][boxX].isHidden = true;
  } else if (mousePressed && (mouseButton == RIGHT)) {
    println("RIGHT CLICK");
  }
}

int getXBox(int x) {
  int result = (x - 40) / squareSize;
  if (result > horr-1)
    return horr-1;
  else if ( result < 0)
    return 0;
  else {
    return result;
  }
}

int getYBox(int y) {
  int result = (y - 40) / squareSize;
  if (result > vert-1)
    return vert-1;
  else {
    return result;
  }
}

void drawOverlay() {
  //Calls Draw Function in frontBox class
  for (int x = 0; x < horr; x++) {
    for (int y = 0; y < vert; y++) {
      if (!board[y][x].isHidden)
        board[y][x].drawBox();
    }
  }
}

void drawGrid() {
  //Calls Draw Function in box class
  for (int x = 0; x < horr; x++) {
    for (int y = 0; y < vert; y++) {
      grid[y][x].drawBox();
    }
  }
}

void drawTop() {
  int timePassed = (millis()-startTime) / 1000;
  fill(#C0C0C0);
  noStroke();
  rect(-20, 0, 1300, 80);
  fill(0);
  textAlign(TOP, RIGHT);
  textFont(titleFont);
  text("Time: " + str(timePassed), 20, 50);
  text("Flags: " + str(flags), width-200, 50);
}
void populateGrid() {
  //Create boxes and assign x coordinates
  for (int x = 0; x < horr; x++) {
    for (int y = 0; y < vert; y++) {
      grid[y][x] = new box();
      board[y][x] = new frontBox();
      grid[y][x].x = x;
      board[y][x].x = x;
      grid[y][x].y = y;
      board[y][x].y = y;
    }
  }
  //Place Mines
  int minesPlaced = 0;
  do {
    // Coordinates of box
    int xRand = (int)random(0, horr);
    int yRand = (int)random(0, vert);
    //Checks if there is already a mine
    if (grid[yRand][xRand].isMine == false) {
      grid[yRand][xRand].isMine = true;
      grid[yRand][xRand].type = color(255, 0, 0);
      // Increments number of mines
      minesPlaced++;
    }
  } while (minesPlaced < mines);

  //Check for mines
  for (int x = 0; x < horr; x++) {
    for (int y = 0; y < vert; y++) {
      grid[y][x].numMines = countMines(x, y);
    }
  }
}


int countMines(int x, int y) {
  int count = 0;  //Num mines

  //Everything in the middle
  if (x < horr-1 && y < vert -1 && x > 0 && y > 0) {
    for (int k = -1; k <= 1; k++)
      for (int j = -1; j <= 1; j++)
        if (grid[y+j][x+k].isMine)
          count++;
  }
  // Top Left Corner
  else if (x == 0 && y == 0) {
    for (int k = 0; k <= 1; k++)// X
      for (int j = 0; j <= 1; j++)// Y
        if (grid[y+j][x+k].isMine)
          count++;
  }
  // Top Right Corner
  else if (x == horr-1 && y == 0) {
    for (int k = -1; k <= 0; k++)// X
      for (int j = 0; j <= 1; j++)// Y
        if (grid[y+j][x+k].isMine)
          count++;
  }
  // Top
  else if (y == 0) {
    for (int k = -1; k <= 1; k++)// X
      for (int j = 0; j <= 1; j++)// Y
        if (grid[y+j][x+k].isMine)
          count++;
  }

  // Bottom Left Corner
  else if (x == 0 && y == vert-1) {
    for (int k = 0; k <= 1; k++)// X
      for (int j = -1; j <= 0; j++)// Y
        if (grid[y+j][x+k].isMine)
          count++;
  }
  // Left
  else if (x == 0) {
    for (int k = 0; k <= 1; k++)// X
      for (int j = -1; j <= 1; j++)// Y
        if (grid[y+j][x+k].isMine)
          count++;
  }
  // Bottom Right Corner
  else if (x == horr-1 && y == vert-1) {
    for (int k = -1; k <= 0; k++)// X
      for (int j = -1; j <= 0; j++)// Y
        if (grid[y+j][x+k].isMine)
          count++;
  }
  // Right
  else if (x == horr-1) {
    for (int k = -1; k <= 0; k++)// X
      for (int j = -1; j <= 1; j++)// Y
        if (grid[y+j][x+k].isMine)
          count++;
  }
  // Bottom
  else if (y == vert-1) {
    for (int k = -1; k <= 1; k++)// X
      for (int j = -1; j <= 0; j++)// Y
        if (grid[y+j][x+k].isMine)
          count++;
  }

  return count;
}
