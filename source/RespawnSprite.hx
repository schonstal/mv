package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flash.geom.Point;
import flixel.system.FlxSound;
import flixel.FlxCamera.FlxCameraShakeDirection;
import flixel.input.gamepad.XboxButtonID;

class RespawnSprite extends FlxSprite
{
  public function new(X:Float=0,Y:Float=0) {
    super(X,Y);
    loadGraphic("assets/images/respawn.png", true, 64, 64);
    animation.add("die", [0,1,2,3,4,5,6,7,8,9,9,9,9,9,9], 30, false);
    animation.finishCallback = finishAnimation;
    offset.x = 32 - Reg.player.width/2;
    offset.y = 32 - Reg.player.height/2;
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }

  private function finishAnimation(animation:String):Void {
    visible = false;
  }

  public function spawn():Void {
    visible = true;
    x = Reg.player.x;
    y = Reg.player.y;
    animation.play("die", false, true);
  }

  public function die():Void {
    visible = true;
    x = Reg.player.x;
    y = Reg.player.y;
    animation.play("die");
  }
}
