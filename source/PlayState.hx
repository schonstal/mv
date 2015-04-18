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

class PlayState extends FlxState
{
  var rooms:Dynamic = {};
  var player:Player;
  var activeRoom:Room;

  var background:ScrollingBackground;
  var invertedBackground:ScrollingBackground;

  override public function create():Void {
    super.create();
    for(fileName in Reg.rooms) {
      Reflect.setField(rooms,
                       fileName,
                       new Room("assets/tilemaps/" + fileName + ".tmx"));
    }

    background = new ScrollingBackground("assets/images/backgrounds/1.png", false, 60);
    add(background);

    player = new Player(40,0);
    player.init();
    add(player);

    switchRoom("test");
  }
  
  override public function destroy():Void {
    super.destroy();
  }

  override public function update(elapsed:Float):Void {
    super.update(elapsed);
    
    player.resetFlags();

    checkExits();
    touchWalls();
  }

  private function touchWalls():Void {
    FlxG.collide(activeRoom.foregroundTiles, player, function(tile:FlxObject, player:Player):Void {
      player.hitTile(tile);
    });
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
    if (activeRoom != null) {
      remove(activeRoom.foregroundTiles);
      remove(activeRoom.exits);
    }
    remove(player);

    activeRoom = Reflect.field(rooms, roomName);
    activeRoom.loadObjects(this);
    add(player);
    add(activeRoom.foregroundTiles);
    add(activeRoom.exits);
  }
}
