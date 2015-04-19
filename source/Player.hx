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
  public static var WALL:Int = WALL_LEFT|WALL_RIGHT;

  public static var RUN_SPEED:Float = 425;

  private var _speed:Point;
  private var _gravity:Float = 1200; 
  private var _terminalVelocity:Float = 600;

  private var _jumpPressed:Bool = false;
  private var _grounded:Bool = false;
  private var _jumping:Bool = false;
  private var _landing:Bool = false;
  private var _justLanded:Bool = false;

  //Allow the user to push jump a little bit after they fall off a gap
  private var _groundedTimer:Float = 0;
  private var _groundedThreshold:Float = 0.075;

  //Stick to the wall
  private var _wallTimer:Float = 0;
  private var _wallThreshold:Float = 0.1;
  private var _wallJumping:Bool = false;

  //Push off the wall a little less than you can run
  private var wallJumpSpeed:Float = 375;

  //Allow the user to push jump a little bit after they fall off the wall
  private var _wallJumpTimer:Float = 0;
  private var _wallJumpThreshold:Float = 0.06;

  //When you jump off a wall, stun a bit so you get a nice curve
  private var _wallStunTimer:Float = 0;
  private var _wallStunThreshold:Float = 0.04;
  private var _wallStunned:Bool = false;
  
  private var collisionFlags:Int = 0;
  private var onWall:Int = 0;

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
    _speed.y = 400;
    _speed.x = 1500;


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

  private function jump():Void {
    jumpSound.play();
    animation.play("jump start");
    _jumping = true;
    velocity.y = -_speed.y;
    _jumpPressed = false;
  }

  private function tryJumping():Void {
    if(jumpPressed()) {
      if(_grounded) {
        _grounded = false;
        jump();
      } else if(onWall > 0) {
        jump();
        _wallJumping = true;
        velocity.x = (onWall & FlxObject.RIGHT) > 0 ? -wallJumpSpeed : wallJumpSpeed;
        _wallStunTimer = 0;
        _wallStunned = true;
      }
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

  private function checkWalls():Void {
    if(collidesWith(WALL)) {
      _wallJumpTimer = 0;
      _jumping = false;
    } else {
      _wallJumpTimer += elapsed;
      if(_wallJumpTimer >= _wallJumpThreshold) {
        onWall = 0;
      }
    }

    _wallStunTimer += elapsed;
    if(_wallStunTimer >= _wallStunThreshold) {
      _wallStunned = false;
    }
  }

  private function handleMovement():Void {
    if(!pressed("jump") && !_wallStunned) _wallJumping = false;
    if(pressed("left") && !_wallStunned) {
      acceleration.x = -_speed.x * (velocity.x > 0 ? 4 : 1);
      facing = FlxObject.LEFT;
      playRunAnim();
      _wallJumping = false;
    } else if(pressed("right") && !_wallStunned) {
      acceleration.x = _speed.x * (velocity.x < 0 ? 4 : 1);
      facing = FlxObject.RIGHT;
      playRunAnim();
      _wallJumping = false;
    } else if (Math.abs(velocity.x) < 50) {
      if(!_jumping && !_landing) animation.play("idle");
      velocity.x = 0;
      acceleration.x = 0;
      _justLanded = false;
    } else {
      _justLanded = false;
      var drag:Float = !_wallJumping ? 2 : 0;
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
      checkWalls();
      handleMovement();
      tryJumping();
      terminalVelocity();
    }
    super.update(elapsed);

    if(!dead) {
      stickToWalls();
    }
  }

  private function stickToWalls():Void {
    if(pressed("direction")) {
      _wallTimer += elapsed;
    } else {
      _wallTimer = 0;
    }

    if(_wallTimer <= _wallThreshold && !_grounded) {
      if((onWall & FlxObject.RIGHT) > 0) { x += 1; }
      if((onWall & FlxObject.LEFT) > 0) { x -= 1; }
    }
  }

  public function hitTile(tile:FlxObject):Void {
    if((touching & FlxObject.FLOOR) > 0) {
      setCollidesWith(WALL_UP);
    }
    if((touching & FlxObject.WALL) > 0) {
      setCollidesWith(WALL);
      onWall = touching & FlxObject.WALL;
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
      case "left":
        return FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A;
      case "right":
        return FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D;
      case "direction":
        return pressed("left") || pressed("right");
    }
    return false;
  }
}
