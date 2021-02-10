
import ddf.minim.*; // Import Sound Library

class SoundPlayer {
  Minim minimplay;
  AudioSample boomPlayer, popPlayer, shootPlayer;

  SoundPlayer(Object app) {
    minimplay = new Minim(app); 
    boomPlayer = minimplay.loadSample("smb_mariodie.wav", 1024); 
    popPlayer = minimplay.loadSample("pop.wav", 1024);
    shootPlayer = minimplay.loadSample("Shoot.mp3", 1024);
  }

  void playExplosion() {
    boomPlayer.trigger();
  }

  void playPop() {
    popPlayer.trigger();
  }
  
  void playShoot() {
    shootPlayer.trigger();
  }
}
