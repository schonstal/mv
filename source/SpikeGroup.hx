package;

import openfl.Assets;
import haxe.io.Path;
import haxe.xml.Parser;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.math.FlxRandom;
import flixel.FlxCamera;

class SpikeGroup extends FlxSpriteGroup
{
  public function new(X:Float, Y:Float, width:Float, height:Float, orientation:String, invertAnimation:Bool = false) {
    super();

    var count:Int = 0;
    if(orientation == "up" || orientation == "down") {
      count = Std.int(width/10);
    } else {
      count = Std.int(height/10);
    }

    var spikeSprite:FlxSprite;
    for(i in 0...count) {
      spikeSprite = new FlxSprite();
      spikeSprite.loadGraphic("assets/images/spikes.png", true, 10, 10);
      if(orientation == "up" || orientation == "down") {
        spikeSprite.animation.add("spin", [0,1,2,3,4,5,6,7,8,9], 15, true);
        spikeSprite.animation.play("spin", false, invertAnimation, (invertAnimation ? i % 9 : 9 - (i % 9)));
      } else {
        spikeSprite.animation.add("spin", [10,11,12,13,14,15,16,17,18,19], 15, true);
        spikeSprite.animation.play("spin", false, invertAnimation, (!invertAnimation ? i % 9 : 9 - (i % 9)));
      }
      switch(orientation) {
        case "up":
          spikeSprite.width = 4;
          spikeSprite.offset.x = 3;
          spikeSprite.height = 7;
          spikeSprite.offset.y = 3;
          spikeSprite.x = X + (i * 10);
          spikeSprite.y = Y + height - 10 + spikeSprite.offset.y;
          spikeSprite.setFacingFlip(FlxObject.UP, false, false);
          spikeSprite.facing = FlxObject.UP;
        case "down":
          spikeSprite.width = 4;
          spikeSprite.offset.x = 3;
          spikeSprite.height = 7;
          spikeSprite.x = X + (i * 10);
          spikeSprite.y = Y;
          spikeSprite.setFacingFlip(FlxObject.DOWN, false, true);
          spikeSprite.facing = FlxObject.DOWN;
        case "left":
          spikeSprite.width = 7;
          spikeSprite.offset.x = 3;
          spikeSprite.height = 4;
          spikeSprite.offset.y = 3;
          spikeSprite.x = X + width - 10 + spikeSprite.offset.x;
          spikeSprite.y = Y + (i * 10) + spikeSprite.offset.y;
          spikeSprite.setFacingFlip(FlxObject.LEFT, true, false);
          spikeSprite.facing = FlxObject.LEFT;
        case "right":
          spikeSprite.width = 7;
          spikeSprite.height = 4;
          spikeSprite.offset.y = 3;
          spikeSprite.x = X;
          spikeSprite.y = Y + (i * 10) + spikeSprite.offset.y;
          spikeSprite.setFacingFlip(FlxObject.RIGHT, false, false);
          spikeSprite.facing = FlxObject.RIGHT;
      }
      //spikeSprite.cameras = cameras;
      add(spikeSprite);
    }
  }
}
