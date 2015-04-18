package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxObject;
import flash.geom.Point;
import flixel.system.FlxSound;

class Player extends FlxSprite
{
  public static var WALL_LEFT:Int = 1 << 1;
  public static var WALL_RIGHT:Int = 1 << 2;
  public static var WALL_UP:Int = 1 << 3;
  public static var WALL:Int = WALL_LEFT|WALL_RIGHT|WALL_UP;

  public static var RUN_SPEED:Float = 500;

  private var _speed:Point;
  private var _gravity:Float = 1000; 
  private var _terminalVelocity:Float = 500;

  private var _jumpPressed:Bool = false;
  private var _grounded:Bool = false;
  private var _jumping:Bool = false;
  private var _landing:Bool = false;
  private var _justLanded:Bool = false;

  private var _groundedTimer:Float = 0;
  private var _groundedThreshold:Float = 0.075;
  
  private var collisionFlags:Int = 0;

  private var jumpTimer:Float = 0;
  private var jumpThreshold:Float = 0.1;

  public var dead:Bool = false;

  public var lockedToFlags:Int = 0;

  public var jumpAmount:Float = 400;

  private var deadTimer:Float = 0;
  private var deadThreshold:Float = 0.4;

  private var elapsed:Float = 0;

  var jumpSound:FlxSound;

  public function new(X:Float=0,Y:Float=0) {
    super(X,Y);
    //loadGraphic("assets/images/player.png", true, 32, 32);
    makeGraphic(18,18,0xffff00ff);
    animation.add("idle", [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2], 15, true);
    animation.add("run", [6, 7, 8, 9, 10, 11], 15, true);
    animation.add("run from landing", [10, 11, 6, 7, 8, 9], 15, true);
    animation.add("jump start", [12], 15, true);
    animation.add("jump peak", [13], 15, true);
    animation.add("jump fall", [14], 15, true);
    animation.add("jump land", [9], 15, false);
    animation.add("die", [18]);
    animation.play("idle");

    //width = 12;
    //height = 20;

    //offset.y = 12;
    //offset.x = 10;

    _speed = new Point();
    _speed.y = 380;
    _speed.x = 2000;

    acceleration.y = _gravity;

    maxVelocity.x = RUN_SPEED;

    jumpSound = FlxG.sound.load("assets/sounds/jump.wav");
    setFacingFlip(FlxObject.LEFT, true, false);
    setFacingFlip(FlxObject.RIGHT, false, false);
  }

  public function init():Void {
    _jumpPressed = false;
    _grounded = false;
    _jumping = false;
    _landing = false;
    _justLanded = false;

    _groundedTimer = 0;
    collisionFlags = 0;

    jumpTimer = 0;

    lockedToFlags = 0;

    velocity.x = velocity.y = 0;
    acceleration.x = 0;
    acceleration.y = _gravity;
    exists = true;

    facing = FlxObject.RIGHT;
  }

  public function playRunAnim():Void {
    if(!_jumping && !_landing) {
      if(_justLanded) animation.play("run from landing");
      else animation.play("run");
    }
  }

  private function jumpPressed():Bool {
    //Check for jump input, allow for early timing
    jumpTimer += elapsed;
    if(justPressed("jump")) {
      _jumpPressed = true;
      jumpTimer = 0;
    }
    if(jumpTimer > jumpThreshold) {
      _jumpPressed = false;
    }

    return _jumpPressed;
  }

  private function tryJumping():Void {
    if(jumpPressed() && _grounded) {
      _grounded = false;
      jumpSound.play();
      animation.play("jump start");
      _jumping = true;
      velocity.y = -_speed.y;
      _jumpPressed = false;
    }

    if(velocity.y < -1) {
      if(pressed("jump") && velocity.y > -25) {
        animation.play("jump peak");
      }
    } else if (velocity.y > 1) {
      if(velocity.y > 100) {
        animation.play("jump fall");
      }
    }

    if(!pressed("jump") && velocity.y < 0)
      acceleration.y = _gravity * 3;
    else
      acceleration.y = _gravity;
  }

  private function checkGround():Void {
    if(collidesWith(WALL_UP)) {
      if(!_grounded) {
        animation.play("jump land");
        _landing = true;
        _justLanded = true;
      }
      _grounded = true;
      _jumping = false;
      _groundedTimer = 0;
    } else {
      _groundedTimer += elapsed;
      if(_groundedTimer >= _groundedThreshold) {
        _grounded = false;
      }
    }

    if(_landing && animation.finished) {
      _landing = false;
    }
  }

  private function handleMovement():Void {
    if(FlxG.keys.pressed.A || FlxG.keys.pressed.LEFT) {
      acceleration.x = -_speed.x * (velocity.x > 0 ? 4 : 1);
      facing = FlxObject.LEFT;
      playRunAnim();
    } else if(FlxG.keys.pressed.D || FlxG.keys.pressed.RIGHT) {
      acceleration.x = _speed.x * (velocity.x < 0 ? 4 : 1);
      facing = FlxObject.RIGHT;
      playRunAnim();
    } else if (Math.abs(velocity.x) < 50) {
      if(!_jumping && !_landing) animation.play("idle");
      velocity.x = 0;
      acceleration.x = 0;
      _justLanded = false;
    } else {
      _justLanded = false;
      var drag:Float = 1;
      if (velocity.x > 0) {
        acceleration.x = -_speed.x * drag;
      } else if (velocity.x < 0) {
        acceleration.x = _speed.x * drag;
      }
    }
  }

  private function terminalVelocity():Void {
    if(velocity.y > _terminalVelocity) velocity.y = _terminalVelocity;
  }

  override public function update(elapsed:Float):Void {
    this.elapsed = elapsed;
    if(!dead) {
      checkGround();
      handleMovement();
      tryJumping();
      terminalVelocity();
    }
    super.update(elapsed);
  }

  public function hitTile(tile:FlxObject):Void {
    if((touching & FlxObject.FLOOR) > 0) {
      setCollidesWith(Player.WALL_UP);
    }
  }

  public function resetFlags():Void {
    collisionFlags = 0;
  }

  public function die():Void {
    animation.play("die");
    deadTimer = 0;
    dead = true;
    acceleration.y = acceleration.x = velocity.x = velocity.y = 0;
  }

  public function setCollidesWith(bits:Int):Void {
    collisionFlags |= bits;
  }

  public function collidesWith(bits:Int):Bool {
    return (collisionFlags & bits) > 0;
  }

  private function justPressed(action:String):Bool {
    switch(action) {
      case "jump":
        return FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP;
    }
    return false;
  }

  private function pressed(action:String):Bool {
    switch(action) {
      case "jump":
        return FlxG.keys.pressed.W || FlxG.keys.pressed.UP;
    }
    return false;
  }
}
