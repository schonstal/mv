package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.FlxCamera;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Matrix;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flash.filters.ColorMatrixFilter;
import flixel.math.FlxPoint;
import flash.display.BitmapData;

class EffectSprite extends FlxSprite
{
  public var palette:Int;
  public var target:FlxCamera;

  var paletteSprite:FlxSprite;

  var redArray:Array<Int>;
  var greenArray:Array<Int>;
  var blueArray:Array<Int>;

  public function new(target:FlxCamera, palette:Int) {
    super(0,0);
    this.target = target;
    this.palette = palette;

    makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT, false);
    paletteSprite = new FlxSprite();
    paletteSprite.loadGraphic("assets/images/palette.png");

    redArray = new Array<Int>();
    greenArray = new Array<Int>();
    blueArray = new Array<Int>();
  }

  public function clear():Void {
    makeGraphic(FlxG.width, FlxG.height, 0, false);
  }

  override public function draw():Void {
#if flash
    pixels.copyPixels(target.buffer, target.buffer.rect, new Point());
#else
    pixels.draw(target.canvas, new Matrix(1, 0, 0, 1, 0, 0));
#end
    for(i in 0...256) {
      redArray[i] = i << 16;
      greenArray[i] = i << 8;
      blueArray[i] = i;
    }

    for(x in 0...cast(paletteSprite.width,Int)) {
      var pixel:Int = paletteSprite.pixels.getPixel(x,0);
      var palettePixel:Int = paletteSprite.pixels.getPixel(x,palette);

      redArray[(pixel & 0xff0000) >> 16] = palettePixel & 0xff0000;
      greenArray[(pixel & 0xff00) >> 8] = palettePixel & 0xff00;
      blueArray[pixel & 0xff] = palettePixel & 0xff;
    }

    pixels.paletteMap(pixels, new Rectangle(0,0,width,height), new Point(0,0), redArray, greenArray, blueArray);
    
    //resetFrameBitmapDatas();
		
    dirty = true;
    calcFrame();
    super.draw();
  }
}
