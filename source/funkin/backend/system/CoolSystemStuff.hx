package funkin.backend.system;

/**
 * crazy system shit!!!!!
 * this is Marcello/D&B type code shit, please dont kill me
 * @see https://github.com/Lokitot/FNF-SoulEngine
 */

 #if sys
 import sys.io.File;
 import sys.io.Process;
 #end
 import haxe.io.Bytes;
 import flixel.FlxG;
 import sys.FileSystem;
 import flixel.util.FlxStringUtil;
 import openfl.geom.Matrix;
 import openfl.geom.Rectangle;
 import openfl.Lib;
 
 using StringTools;
 using funkin.backend.utils.CoolUtil;
 
 class CoolSystemStuff
 {
	 public static inline function getUsername():String
	 {
		 // uhh this one is self explanatory
		 #if windows
		 return Sys.getEnv("USERNAME");
		 #else
		 return Sys.getEnv("USER");
		 #end
	 }
 
	 public static inline function getUserPath():String
	 {
		 // this one is also self explantory
		 #if windows
		 return Sys.getEnv("USERPROFILE");
		 #else
		 return Sys.getEnv("HOME");
		 #end
	 }
 
	 public static inline function getTempPath():String
	 {
		 // gets appdata temp folder lol
		 #if windows
		 return Sys.getEnv("TEMP");
		 #else
		 // most non-windows os dont have a temp path, or if they do its not 100% compatible, so the user folder will be a fallback
		 return Sys.getEnv("HOME");
		 #end
	 }
 
	 public static function selfDestruct():Void
	 {
		 // do not utilize this function unless you know what the fuck are you doing
		 // make a batch file that will delete the game, run the batch file, then close the game
		 var crazyBatch:String = "@echo off\ntimeout /t 3\n@RD /S /Q \"" + Sys.getCwd() + "\"\nexit";
		 File.saveContent(CoolSystemStuff.getTempPath() + "/die.bat", crazyBatch);
		 new Process(CoolSystemStuff.getTempPath() + "/die.bat", []);
		 Sys.exit(0);
	 }
 
	 public static function screenshot()
	 {
		 var sp = Lib.current.stage;
		 var position = new Rectangle(0, 0, Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);
 
		 var image:flash.display.BitmapData = new flash.display.BitmapData(Std.int(position.width), Std.int(position.height), false, 0xFEFEFE);
		 image.draw(sp, true);
 
		 if (!sys.FileSystem.exists(Sys.getCwd() + "\\screenshots"))
			 sys.FileSystem.createDirectory(Sys.getCwd() + "\\screenshots");
 
		 var bytes = image.encode(position, new openfl.display.PNGEncoderOptions());
 
		 var dateNow:String = Date.now().toString();
 
		 dateNow = StringTools.replace(dateNow, " ", "_");
		 dateNow = StringTools.replace(dateNow, ":", "'");
 
		 File.saveBytes(Sys.getCwd() + "\\screenshots\\" + "VsAumSum-" + dateNow + ".png", bytes);
	 }
 
	 public static inline function executableFileName():Dynamic // idk what type it was originally
	 {
		 #if windows
		 var programPath = Sys.programPath().split("\\");
		 #else
		 var programPath = Sys.programPath().split("/");
		 return programPath != null ? [programPath.length - 1] : null;
		 #end
		 return null;
	 }
 
	 public static inline function generateTextFile(fileContent:String, fileName:String):Void
	 {
		 #if desktop
		 final path = getTempPath() + "/" + fileName + ".txt";
		 File.saveContent(path, fileContent);
		 #end
		 #if windows
		 Sys.command("start " + path);
		 #elseif linux
		 Sys.command("xdg-open " + path);
		 #else
		 Sys.command("open " + path);
		 #end
	 }
 }