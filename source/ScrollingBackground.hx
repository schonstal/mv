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

class ScrollingBackground extends FlxSpriteGroup
{
  public var direction:Float = 1;
  var inverted:Bool; 
  var scrollSpeed:Float;

  var activeSprite:FlxSprite;
  var bufferSprite:FlxSprite;

  public function new(image:String, invert:Bool=false, speed:Float=200) {
    super();

    inverted = invert;
    scrollSpeed = speed;

    activeSprite = new FlxSprite(0, 0);
    activeSprite.loadGraphic(image);
    add(activeSprite);

    if(inverted) {
      bufferSprite = new FlxSprite(activeSprite.width, activeSprite.y);
    } else {
      bufferSprite = new FlxSprite(activeSprite.x, -activeSprite.height);
    }
    bufferSprite.loadGraphic(image);
    add(bufferSprite);
  }

  public override function update(elapsed:Float):Void {
    swapSprites();
    updateSpritePositions();

    super.update(elapsed);

    if(inverted) {
      activeSprite.velocity.x = scrollSpeed * direction;
    } else {
      activeSprite.velocity.y = scrollSpeed * direction;
    }

    swapSprites();
    updateSpritePositions();
  }

  function updateSpritePositions():Void {
    if(inverted) {
      bufferSprite.x = activeSprite.x + (activeSprite.width * direction * -1);
    } else {
      bufferSprite.y = activeSprite.y + (activeSprite.height * direction * -1);
    }
  }

  function shouldSwapSprites():Bool {
    if(inverted) {
      return direction > 0 ? activeSprite.x > FlxG.width : activeSprite.x < -activeSprite.width;
    } else {
      return direction > 0 ? activeSprite.y > FlxG.height : activeSprite.y < -activeSprite.height;
    }
  }

  function swapSprites():Void {
    if(!shouldSwapSprites()) return;

    var sprite:FlxSprite = activeSprite;
    activeSprite = bufferSprite;
    bufferSprite = sprite;
  }
}
