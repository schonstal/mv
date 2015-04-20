package;

import flixel.util.FlxSave;
import flixel.FlxCamera;
import flixel.math.FlxPoint;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
  public static var player:Player;

  public static var level:Int = 1;
  public static var room:String = "";

  public static var foregroundCameras:Array<FlxCamera> = [];
  public static var backgroundCameras:Array<FlxCamera> = [];
  public static var inverted:Bool = false;
  public static var started:Bool = false;

  public static var checkpoint:Checkpoint;

  public static var activeRoom:Room;
}
