package;

import flixel.util.FlxSave;

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
  public static var rooms:Array<String> = ["test"];
}
