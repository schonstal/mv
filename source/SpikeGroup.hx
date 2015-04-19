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
      spikeSprite.animation.add("spin", [0,1,2,3,4,5,6,7,8,9], 15, true);
      spikeSprite.animation.play("spin", false, invertAnimation, i % 9);
      switch(orientation) {
        case "up":
          spikeSprite.x = X + (i * 10);
          spikeSprite.y = Y + height - 10;
        case "down":
          spikeSprite.x = X + (i * 10);
          spikeSprite.y = Y;
        case "left":
          spikeSprite.x = X + width - 10;
          spikeSprite.y = Y + (i * 10);
        case "right":
          spikeSprite.x = X;
          spikeSprite.y = Y + (i * 10);
      }
      //spikeSprite.cameras = cameras;
      add(spikeSprite);
    }
  }
}
