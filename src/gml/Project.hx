package gml;
import ace.AceWrap.AceAutoCompleteItem;
import electron.FileSystem;
import electron.Electron;
import haxe.Json;
import haxe.io.Path;
import js.Boot;
import js.html.DivElement;
import js.html.Element;
import js.html.MouseEvent;
import tools.Dictionary;
import gml.GmlAPI;
import ace.AceWrap;
import gmx.SfGmx;
import Main.*;
import tools.HtmlTools;
import tools.NativeString;
import gml.GmlFile;
import ui.TreeView;

/**
 * ...
 * @author YellowAfterlife
 */
class Project {
	//
	public static var current:Project = null;
	//
	public static var nameNode = document.querySelector("#project-name");
	//
	public var version:GmlVersion = GmlVersion.v1;
	public var name:String;
	public var path:String;
	public var dir:String;
	//
	public var yyObjectNames:Dictionary<String>;
	public var yyObjectGUIDs:Dictionary<yy.YyGUID>;
	//
	public function new(path:String) {
		this.path = path;
		dir = Path.directory(path);
		name = Path.withoutDirectory(path);
		if (Path.extension(path) == "yyp") version = GmlVersion.v2;
		document.title = name;
		TreeView.clear();
		reload(true);
	}
	public function close() {
		TreeView.saveOpen();
		var data:ProjectState = {
			treeviewScrollTop: TreeView.element.scrollTop,
			treeviewOpenNodes: TreeView.openPaths,
		};
		window.localStorage.setItem("project:" + path, Json.stringify(data));
		window.localStorage.setItem("@project:" + path, "" + Date.now().getTime());
	}
	public static function init() {
		//
		var ls = window.localStorage;
		var remList:Array<String> = [];
		var remTime:Float = Date.now().getTime()
			- (1000 * 60 * 60 * 24 * ui.Preferences.current.projectSessionTime);
		for (i in 0 ... ls.length) {
			var k = ls.key(i);
			if (NativeString.startsWith(k, "@project:")) {
				var t = Std.parseFloat(ls.getItem(k));
				if (Std.parseFloat(ls.getItem(k)) < remTime) {
					remList.push(k);
					remList.push(k.substring(1));
				}
			}
		}
		for (remKey in remList) ls.removeItem(remKey);
		//
		var path = window.localStorage.getItem("autoload");
		if (path != null) {
			current = new Project(path);
		} else current = null;
	}
	//
	public function reload(?first:Bool) {
		nameNode.innerText = "Loading...";
		window.setTimeout(function() {
			GmlAPI.version = version;
			var state:ProjectState = null;
			if (first) {
				try {
					var stateText = window.localStorage.getItem("project:" + path);
					state = Json.parse(stateText);
				} catch (_:Dynamic) { }
			} else TreeView.saveOpen();
			reload_1();
			TreeView.restoreOpen(state != null ? state.treeviewOpenNodes : null);
			if (state != null) TreeView.element.scrollTop = state.treeviewScrollTop;
			nameNode.innerText = "";
		}, 1);
	}
	public function reload_1() {
		switch (version) {
			case GmlVersion.v1: gmx.GmxLoader.run(this);
			case GmlVersion.v2: yy.YyLoader.run(this);
			default:
		}
	}
}
typedef ProjectState = {
	treeviewScrollTop:Int,
	treeviewOpenNodes:Array<String>,
}
