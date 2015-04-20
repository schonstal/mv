package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flash.geom.Point;
import flixel.system.FlxSound;
import flixel.FlxCamera.FlxCameraShakeDirection;
import flixel.input.gamepad.XboxButtonID;
import flash.display.BlendMode;
import flixel.math.FlxPoint;

class Checkpoint extends FlxSprite
{
  public var room:String = "start";
  public var inverted:Bool = false;

  public function new(X:Float=0, Y:Float=0, room:String) {
    super(X, Y);
    this.room = room;

    loadGraphic("assets/images/checkpoint.png", true, 20, 80);
    height = 40;
    offset.y = 40;
    y += 40;

    animation.add("off", [0]);
    animation.add("activate", [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], 15, false);
    animation.add("on", [15, 16, 17, 18, 19, 20, 21, 22], 5, true);
    animation.finishCallback = finishAnimation;

    if(activated()) {
      animation.play("on");
    } else {
      animation.play("off");
    }
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);
  }

  public function activated():Bool {
    if(Reg.checkpoint == null) return false;
    return room == Reg.checkpoint.room;
  }

  public function activate():Void {
    if(activated()) return;

    animation.play("activate");
    Reg.checkpoint = this;
  }

  private function finishAnimation(anim:String):Void {
    if(anim == "activate") {
      animation.play("on");
    }
  }
}
