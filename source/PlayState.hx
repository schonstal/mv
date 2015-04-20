package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.effects.FlxGlitchSprite;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxCamera;
import flash.display.BlendMode;

class PlayState extends FlxState
{
  var rooms:Dynamic = {};
  var player:Player;
  var activeRoom:Room;

  var background:ScrollingBackground;
  var invertedBackground:ScrollingBackground;

  var backgroundCamera:FlxCamera;
  var foregroundCamera:FlxCamera;

  var backgroundEffect:EffectSprite;
  var foregroundEffect:EffectSprite;
  var globalEffect:EffectSprite;

  var respawnSprite:RespawnSprite;

  override public function create():Void {
    super.create();
    FlxG.camera.flash(0xffffffff, 0.5);
		Reg.backgroundCameras = [new FlxCamera(0, 0, FlxG.width*2, FlxG.height*2)];
    Reg.foregroundCameras = [new FlxCamera(0, 0, FlxG.width*2, FlxG.height*2)];

    background = new ScrollingBackground("assets/images/backgrounds/1.png", false, 60);
    add(background);

    invertedBackground = new ScrollingBackground("assets/images/backgrounds/2.png", true, 60);
    add(invertedBackground);

    backgroundEffect = new EffectSprite(Reg.backgroundCameras[0], 3);
    add(backgroundEffect);

    foregroundEffect = new EffectSprite(Reg.foregroundCameras[0], 0);
    add(foregroundEffect);

    globalEffect = new EffectSprite(FlxG.camera, 2);
    add(globalEffect);

    player = new Player(FlxG.width/2,FlxG.height/4*3-20);
    player.init();
    Reg.player = player;
    add(player);

    respawnSprite = new RespawnSprite();
    respawnSprite.spawn();
    add(respawnSprite);

    switchRoom("start");

    //DEBUGGER
    FlxG.debugger.drawDebug = true;
  }
  
  override public function destroy():Void {
    super.destroy();
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    if(FlxG.keys.justPressed.SPACE) {
      respawnSprite.die();
      player.visible = false;
    }
    
    player.resetFlags();

    checkExits();
    touchWalls();
    touchSpikes();

    if(Reg.inverted) {
      backgroundEffect.target = Reg.foregroundCameras[0];
      foregroundEffect.target = Reg.backgroundCameras[0];
    } else {
      backgroundEffect.target = Reg.backgroundCameras[0];
      foregroundEffect.target = Reg.foregroundCameras[0];
    }
    globalEffect.palette = Reg.inverted ? 1 : 2;
    invertedBackground.visible = Reg.inverted;
    background.visible = !Reg.inverted;
  }

  private function touchWalls():Void {
    FlxG.collide(Reg.inverted ? activeRoom.backgroundTiles : activeRoom.foregroundTiles,
                player,
                function(tile:FlxObject, player:Player):Void { player.hitTile(tile); });
  }

  private function touchSpikes():Void {
    FlxG.overlap(Reg.inverted ? activeRoom.backgroundSpikes : activeRoom.foregroundSpikes, player, die);
  }

  private function die(killer:FlxObject, player:Player):Void {
    if(player.dead) return;
    player.die();
    respawnSprite.die();
    new FlxTimer().start(0.3, function(t:FlxTimer):Void {
      FlxG.camera.fade(0xffffffff, 0.5, false, function():Void {
        FlxG.switchState(new PlayState());
      });
    });
  }

  private function checkExits():Void {
    if(player.x < 0) {
      player.x = FlxG.width - player.width;
      switchRoom(activeRoom.properties.get("west"));
    } else if(player.x + player.width > FlxG.width) {
      player.x = 0;
      switchRoom(activeRoom.properties.get("east"));
    } else if (player.y < 0) {
      player.y = FlxG.height - player.height;
      switchRoom(activeRoom.properties.get("north"));
    } else if (player.y + player.height > FlxG.height) {
      player.y = 0;
      switchRoom(activeRoom.properties.get("south"));
    }
  }

  public function switchRoom(roomName:String):Void {
    var room:Room = Reflect.field(rooms, roomName);
    if (room == null) {
      room = new Room("assets/tilemaps/" + roomName + ".tmx");
      Reflect.setField(rooms, roomName, room);
    }
    if (activeRoom != null) {
      remove(activeRoom.foregroundTiles);
      remove(activeRoom.backgroundTiles);
      remove(activeRoom.foregroundSpikes);
      remove(activeRoom.backgroundSpikes);
    }
    remove(player);
    remove(respawnSprite);

    activeRoom = room;
    activeRoom.loadObjects(this);
    add(activeRoom.backgroundTiles);
    add(player);
    add(respawnSprite);
    add(activeRoom.backgroundSpikes);
    add(activeRoom.foregroundSpikes);
    add(activeRoom.foregroundTiles);
  }
}
