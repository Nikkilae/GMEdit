package gmx;
import gmx.SfGmx;
import js.lib.RegExp;
import parsers.GmlReader;
using tools.NativeString;

/**
 * ...
 * @author YellowAfterlife
 */
class GmxAction {
	static var impl = new GmxActionImpl();
	public static var errorText:String;
	public static function getCode(action:SfGmx):String {
		var code = impl.getCode(action);
		errorText = impl.errorText;
		return code;
	}
	public static function makeCodeBlock(code:String):SfGmx {
		return impl.makeCodeBlock(code);
	}
}
