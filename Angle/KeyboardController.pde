
import org.gamecontrolplus.*;
import net.java.games.input.*;

class KeyboardController {

  ControlIO controllIO;
  ControlDevice keyboard;
  ControlButton spaceBtn, leftArrow, rightArrow, upArrow, downArrow;

  KeyboardController(PApplet applet) {
    controllIO = ControlIO.getInstance(applet);
    keyboard = controllIO.getDevice("Keyboard");
    spaceBtn = keyboard.getButton("Space");   
    leftArrow = keyboard.getButton("Left");   
    rightArrow = keyboard.getButton("Right");
  }
  
  boolean isLeft() {
    return leftArrow.pressed();
  }

  boolean isRight() {
    return rightArrow.pressed();
  }

  boolean isSpace() {
    return spaceBtn.pressed();
  }
}
