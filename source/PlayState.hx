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

    if(Reg.checkpoint == null) {
      Reg.checkpoint = new Checkpoint(180, 220, "start");
    }

    player = new Player(Reg.checkpoint.x + 4, Reg.checkpoint.y - 4);
    player.init();
    Reg.player = player;
    add(player);

    respawnSprite = new RespawnSprite();
    respawnSprite.spawn();
    add(respawnSprite);

    switchRoom(Reg.checkpoint.room);
    Reg.inverted = Reg.checkpoint.inverted;

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

    touchSpikes();
    touchCheckpoints();
    checkExits();
    touchWalls();

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
    FlxG.collide(Reg.inverted ? Reg.activeRoom.backgroundTiles : Reg.activeRoom.foregroundTiles,
                player,
                function(tile:FlxObject, player:Player):Void { player.hitTile(tile); });
  }

  private function touchSpikes():Void {
    FlxG.overlap(Reg.inverted ? Reg.activeRoom.backgroundSpikes : Reg.activeRoom.foregroundSpikes, player, die);
  }

  private function touchCheckpoints():Void {
    FlxG.overlap(Reg.inverted ? Reg.activeRoom.backgroundCheckpoints : Reg.activeRoom.foregroundCheckpoints,
                 player,
                 function(checkpoint:Checkpoint, player:Player):Void {
                   checkpoint.activate();
                 });
  }

  private function die(killer:FlxObject, player:Player):Void {
    if(player.dead) return;
    FlxG.camera.shake(0.005, 0.125);
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
      switchRoom(Reg.activeRoom.properties.get("west"));
    } else if(player.x + player.width > FlxG.width) {
      player.x = 0;
      switchRoom(Reg.activeRoom.properties.get("east"));
    } else if (player.y < 0) {
      player.y = FlxG.height - player.height;
      switchRoom(Reg.activeRoom.properties.get("north"));
    } else if (player.y + player.height > FlxG.height) {
      player.y = 0;
      switchRoom(Reg.activeRoom.properties.get("south"));
    }
  }

  public function switchRoom(roomName:String):Void {
    var room:Room = Reflect.field(rooms, roomName);
    if (room == null) {
      room = new Room(roomName);//"assets/tilemaps/" + roomName + ".tmx");
      Reflect.setField(rooms, roomName, room);
    }
    if (Reg.activeRoom != null) {
      remove(Reg.activeRoom.foregroundTiles);
      remove(Reg.activeRoom.backgroundTiles);
      remove(Reg.activeRoom.foregroundSpikes);
      remove(Reg.activeRoom.backgroundSpikes);
      remove(Reg.activeRoom.foregroundCheckpoints);
      remove(Reg.activeRoom.backgroundCheckpoints);
    }
    remove(player);
    remove(respawnSprite);

    Reg.activeRoom = room;
    Reg.activeRoom.loadObjects(this);
    Reg.activeRoom.refresh();
    add(Reg.activeRoom.backgroundTiles);
    add(player);
    add(respawnSprite);
    add(Reg.activeRoom.backgroundSpikes);
    add(Reg.activeRoom.foregroundSpikes);
    add(Reg.activeRoom.foregroundTiles);
    add(Reg.activeRoom.backgroundCheckpoints);
    add(Reg.activeRoom.foregroundCheckpoints);
  }
}
