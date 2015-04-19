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

  var shimmerOverlay:FlxSprite;
  var shimmerSin:Float = 0;

  override public function create():Void {
    super.create();
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

    shimmerOverlay = new FlxSprite();
    shimmerOverlay.makeGraphic(FlxG.width, FlxG.height, 0xffffffff);
    shimmerOverlay.blend = BlendMode.OVERLAY;
    add(shimmerOverlay);

    player = new Player(80,80);
    player.init();
    add(player);

    switchRoom("pit");

  }
  
  override public function destroy():Void {
    super.destroy();
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);

    shimmerSin += elapsed;
    shimmerOverlay.alpha = 0.1 + 0.1 * Math.sin(shimmerSin);
    
    player.resetFlags();

    checkExits();
    touchWalls();

    backgroundEffect.clear();
    foregroundEffect.clear();

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
    var tiles = 
    FlxG.collide(Reg.inverted ? activeRoom.backgroundTiles : activeRoom.foregroundTiles,
                player,
                function(tile:FlxObject, player:Player):Void { player.hitTile(tile); });
  }

  private function checkExits():Void {
    FlxG.overlap(activeRoom.exits, player, function(exit:ExitObject, player:Player):Void {
      if(player.x < 0) {
        player.x = 320 - player.width;
        switchRoom(exit.roomName);
      } else if(player.x + player.width > 320) {
        player.x = 0;
        switchRoom(exit.roomName);
      }
    });
  }

  public function switchRoom(roomName:String):Void {
    var room:Room = Reflect.field(rooms, roomName);
    if (room == null) {
      room = new Room("assets/tilemaps/" + roomName + ".tmx");
      Reflect.setField(rooms, roomName, room);
    }
    if (activeRoom != null) {
      remove(activeRoom.foregroundTiles);
      remove(activeRoom.exits);
    }
    remove(player);

    activeRoom = room;
    activeRoom.loadObjects(this);
    add(activeRoom.backgroundTiles);
    add(player);
    add(activeRoom.foregroundTiles);
    add(activeRoom.exits);
  }
}
