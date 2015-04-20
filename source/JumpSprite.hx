package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flash.geom.Point;
import flixel.system.FlxSound;
import flixel.FlxCamera.FlxCameraShakeDirection;
import flixel.input.gamepad.XboxButtonID;
import flash.display.BlendMode;

class JumpSprite extends FlxSprite
{
  public function new(X:Float=0,Y:Float=0) {
    super(X,Y);
    loadGraphic("assets/images/jump.png", true, 32, 32);
    animation.add("jump", [0,1,2,2,3,3,3,3], 30, false);
    animation.finishCallback = finishAnimation;
    offset.x = 16 - Reg.player.width/2;
    offset.y = 16 - Reg.player.height/2;
    visible = false;
    cameras = Reg.backgroundCameras.concat(Reg.foregroundCameras);
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }

  private function finishAnimation(animation:String):Void {
    visible = false;
  }

  public function jump():Void {
    visible = true;
    x = Reg.player.x;
    y = Reg.player.y;
    animation.play("jump", false);
  }
}
