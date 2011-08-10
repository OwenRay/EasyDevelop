package easyDevelop
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class DevelopButton extends Sprite
	{
		public function DevelopButton(txt:String, size:int = 90):void
		{
			var tf:TextField = new TextField();
			tf.defaultTextFormat = new TextFormat('courier', 12, 0xFFFFFF);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = txt;
			addChild(tf);
			buttonMode = !(mouseChildren = false);
			graphics.beginFill(0xDDDDDD);
			graphics.drawRect(-1, -1, size==-1?tf.width:size, tf.height);
			graphics.beginFill(0);
			graphics.drawRect(0, 0, size==-1?tf.width:size, tf.height);
		}
	}
}