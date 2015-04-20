package;

import openfl.Assets;
import haxe.io.Path;
import haxe.xml.Parser;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;

/**
 * Modified from Samuel Batista's example source
 */
class Room extends TiledMap
{
  // For each "Tile Layer" in the map, you must define a "tileset"
  // property which contains the name of a tile sheet image 
  // used to draw tiles in that layer (without file extension).
  // The image file must be located in the directory specified bellow.
  private inline static var c_PATH_LEVEL_TILESHEETS = "assets/images/tiles/";

  // Do we reload objects?
  public var dirty:Bool = true;
  
  // Array of tilemaps used for collision
  public var foregroundTiles:FlxGroup;
  public var backgroundTiles:FlxGroup;
  public var foregroundSpikes:FlxGroup;
  public var backgroundSpikes:FlxGroup;

  public var foregroundTilemap:FlxTilemap;
  public var backgroundTilemap:FlxTilemap;

  public var foregroundCheckpoints:FlxGroup;
  public var backgroundCheckpoints:FlxGroup;

  private var collidableTileLayers:Array<FlxTilemap>;

  var roomName:String;

  public function new(roomName:String) {
    this.roomName = roomName;
    var tiles = "assets/tilemaps/" + roomName + ".tmx";

    super(tiles);
    
    foregroundTiles = new FlxGroup();
    backgroundTiles = new FlxGroup();

    foregroundSpikes = new FlxGroup();
    backgroundSpikes = new FlxGroup();

    foregroundCheckpoints = new FlxGroup();
    backgroundCheckpoints = new FlxGroup();
    
    // Load Tile Maps
    for (tileLayer in layers) {
      var tileSheetName:String = tileLayer.properties.get("tileset");
      
      if (tileSheetName == null) {
        if(tileLayer.name == "Tile Layer 1") {
          tileSheetName = "1";
        } else if (tileLayer.name == "Tile Layer 2") {
          tileSheetName = "2";
        } else {
          throw "'tileset' property not defined for the '" + tileLayer.name +
                "' layer. Please add the property to the layer.";
        }
      }
        
      var tileSet:TiledTileSet = null;
      for (ts in tilesets) {
        if (ts.name == tileSheetName) {
          tileSet = ts;
          break;
        }
      }
      
      if (tileSet == null) {
        throw "Tileset '" + tileSheetName +
              " not found. Did you mispell the 'tilesheet' property in " +
              tileLayer.name + "' layer?";
      }
        
      var imagePath       = new Path(tileSet.imageSource);
      var processedPath   = c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
      
      var tilemap:FlxTilemap = new FlxTilemap();
      tilemap.loadMapFromArray(tileLayer.tileArray,
                               width,
                               height,
                               processedPath,
                               tileSet.tileWidth,
                               tileSet.tileHeight,
                               FlxTilemapAutoTiling.OFF,
                               1, 1, 1);
      
      if (tileLayer.properties.contains("nocollide")) {
        backgroundTiles.add(tilemap);
      } else {
        if (collidableTileLayers == null) {
          collidableTileLayers = new Array<FlxTilemap>();
        }
        
        if(tileLayer.name == "Tile Layer 1") {
          tilemap.cameras = Reg.foregroundCameras;
          foregroundTiles.add(tilemap);
          foregroundTilemap = tilemap;
        } else if(tileLayer.name == "Tile Layer 2") {
          tilemap.cameras = Reg.backgroundCameras;
          backgroundTiles.add(tilemap);
          backgroundTilemap = tilemap;
        }
        collidableTileLayers.push(tilemap);
      }
    }
  } // new()
  
  public function loadObjects(state:PlayState) {
    if (!dirty) return;

    for (group in objectGroups) {
      for (o in group.objects) {
        loadObject(o, group, state);
      }
    }
    dirty = false;
  }
  
  private function loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState) {
    var x:Int = o.x;
    var y:Int = o.y;
    
    // objects in tiled are aligned bottom-left (top-left in flixel)
    if (o.gid != -1) {
      y -= g.map.getGidOwner(o.gid).tileHeight;
    }
    
    switch (o.type.toLowerCase()) {
      case "spikes":
        if (g.name == "Object Layer 1") {
          var spike = new SpikeGroup(x, y, o.width, o.height, o.custom.get("orientation"), true);
          spike.cameras = Reg.foregroundCameras;
          foregroundSpikes.add(spike);
        } else if (g.name == "Object Layer 2") {
          var spike = new SpikeGroup(x, y, o.width, o.height, o.custom.get("orientation"), false);
          spike.cameras = Reg.backgroundCameras;
          backgroundSpikes.add(spike);
        }
      case "checkpoint":
        if (g.name == "Object Layer 1") {
          var checkpoint = new Checkpoint(x, y, roomName);
          checkpoint.inverted = false;
          checkpoint.cameras = Reg.foregroundCameras;
          foregroundCheckpoints.add(checkpoint);
        } else if (g.name == "Object Layer 2") {
          var checkpoint = new Checkpoint(x, y, roomName);
          checkpoint.inverted = true;
          checkpoint.cameras = Reg.backgroundCameras;
          backgroundCheckpoints.add(checkpoint);
        }
    }
  }
  
  public function collideWithLevel(obj:FlxObject,
                                   ?notifyCallback:FlxObject->FlxObject->Void,
                                   ?processCallback:FlxObject->FlxObject->Bool):Bool {
    if (collidableTileLayers != null) {
      for (map in collidableTileLayers) {
        // IMPORTANT: Always collide the map with objects, not the other way around. 
        //        This prevents odd collision errors (collision separation code off by 1 px).
        return FlxG.overlap(map,
                            obj,
                            notifyCallback,
                            processCallback != null ? processCallback : FlxObject.separate);
      }
    }
    return false;
  }
}
