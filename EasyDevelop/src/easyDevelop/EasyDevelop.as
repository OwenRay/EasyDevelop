package easyDevelop
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.DisplacementMapFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.utils.Timer;
	
	import flashx.textLayout.elements.OverflowPolicy;

	public class EasyDevelop
	{
		private static var stage:Stage = stage;
		
		private static var iHave:Array = new Array();
		private static var s:Sprite = new Sprite();
		
		private static var grab:Point;
		private static var selecting:Boolean = false;
		private static var selectDot:Sprite = new Sprite();
		private static var drawOverlay:Sprite = new Sprite();
		private static var currentlySelected:DisplayObject;
		
		private static var param:TextField = new TextField();
		private static var value:TextField = new TextField();
		
		
		private static var fields:Sprite = new Sprite();
		private static var title:TextField = new TextField();
		private static var childs:Sprite = new Sprite();
		
		public static function init(setStage:Stage):void
		{
			
			stage = setStage;
			
			var depth:int;
			
			stage.addEventListener(Event.RESIZE, refresh);
			s.addEventListener(MouseEvent.MOUSE_DOWN, dragScreen);
			s.filters = new Array(new DropShadowFilter(0, 45, 0, .4));
			s.x = (s.y = 20)-5;
			stage.addChild(s);
			
			title = new TextField();
			title.defaultTextFormat = new TextFormat('courier', 11, 0xFFFFFF);
			title.autoSize = TextFieldAutoSize.LEFT;
			title.text = "Nothing selected";
			title.mouseEnabled = false;
			title.y = -17;
			s.addChild(title);
			
			var button:DevelopButton = new DevelopButton("Drag me");
			button.addEventListener(MouseEvent.MOUSE_DOWN, startSelector);
			button.y = 5;
			s.addChild(button);
			
			//select dot
			selectDot.graphics.beginFill(0xFF0000);
			selectDot.graphics.drawRect(0, 0, 3, 3);
			selectDot.mouseEnabled = false;
			
			//add input stuff
			var tfm:TextFormat = new TextFormat('courier', 12);
			var paramL:TextField = new TextField();
			paramL.defaultTextFormat = tfm;
			paramL.autoSize = TextFieldAutoSize.LEFT;
			paramL.text = "Parameter";
			fields.addChild(paramL);
			param = new TextField();
			param.type = TextFieldType.INPUT;
			param.multiline = false;
			param.width = 90;
			param.background = true;
			param.backgroundColor = 0xDDDDDD;
			param.defaultTextFormat = tfm;
			param.height = 15;
			param.y = 15
			param.borderColor = 0xFF0000;
			param.border = false;
			param.addEventListener(KeyboardEvent.KEY_UP, onParamChange);
			fields.addChild(param);
			var valueL:TextField = new TextField();
			valueL.defaultTextFormat = tfm;
			valueL.autoSize = TextFieldAutoSize.LEFT;
			valueL.y = 35;
			valueL.text = "Value";
			fields.addChild(valueL);
			value = new TextField();
			value.borderColor = 0xFF0000;
			value.border = false;
			value.type = TextFieldType.INPUT;
			value.multiline = false;
			value.width = 90;
			value.background = true;
			value.backgroundColor = 0xDDDDDD;
			value.defaultTextFormat = tfm;
			value.height = 15;
			value.y = 50;
			value.addEventListener(KeyboardEvent.KEY_UP, onValChange);
			fields.addChild(value);
			
			var toParent:DevelopButton = new DevelopButton("To Parent");
			toParent.y = 70;
			toParent.x = 0;
			toParent.addEventListener(MouseEvent.CLICK, function():void{setSelected(currentlySelected.parent); onParamChange()});
			fields.addChild(toParent);
			
			//childs.y = -25;
			
			
			var childL:TextField = new TextField();
			childL.defaultTextFormat = tfm;
			childL.autoSize = TextFieldAutoSize.LEFT;
			childL.x = 95;
			childL.y = -20;
			childL.text = "Children";
			fields.addChild(childL);
			
			childs.x = 95;
			fields.addChild(childs);
			
			fields.y = 25;
			
			drawOverlay.mouseEnabled = false;
			
			refresh();
			
			var t:Timer = new Timer(1000);
			t.addEventListener(TimerEvent.TIMER, pool);
			t.start();
		}
		
		private static function pool(e:Event):void
		{
			stage.setChildIndex(s, stage.numChildren-1);
		}
		
		private static function onParamChange(e:KeyboardEvent = null):void
		{
			try{
				if(currentlySelected[param.text]!==undefined)
					value.text = currentlySelected[param.text];
				param.border = false;
				value.border = false;
			}catch(err:Error){
				param.border = true;
			}
		}
		
		private static function onValChange(e:KeyboardEvent):void
		{
			var add:int = 0;
			if(e.keyCode==38)
				add = 1;
			else if(e.keyCode==40)
				add = -1;
			add*=(e.shiftKey?10:1);
			if(add)
				if(!isNaN(Number(value.text)))
					value.text = ''+(int(value.text)+add);
			
			try{
				currentlySelected[param.text] = value.text;
				value.border = false;
			}catch(err:Error){
				value.border = true;
			}
		}
		
		private static function startSelector(e:MouseEvent):void
		{
			setListeners(stage);
			Mouse.hide();
			stage.addChild(selectDot);
			stage.addChild(drawOverlay);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveSelector);
			stage.addEventListener(MouseEvent.MOUSE_UP, stopSelector);
			selecting = true;
			moveSelector();
		}
		
		private static function moveSelector(e:MouseEvent = null):void
		{
			selectDot.x = stage.mouseX-1;
			selectDot.y = stage.mouseY-1;
		}
		
		private static function stopSelector(e:MouseEvent):void
		{
			selecting = false;
			drawOverlay.graphics.clear();
			stage.removeChild(drawOverlay);
			Mouse.show();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveSelector);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopSelector);
			stage.removeChild(selectDot);
		}
		
		private static function dragScreen(e:MouseEvent):void
		{
			refresh();
			if(s.mouseY<0){
				grab = new Point(s.mouseX, s.mouseY);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onDrag);
				stage.addEventListener(MouseEvent.MOUSE_UP, stopDragging);
			}
		}
		
		private static function onDrag(e:MouseEvent):void
		{
			s.x = stage.mouseX-grab.x;
			s.y = stage.mouseY-grab.y;
		}
		
		private static function stopDragging(e:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDrag);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragging);
		}
		
		private static function setListeners(d:DisplayObjectContainer):void
		{
			for(var c:int = 0; c<d.numChildren; c++)
			{
				var child:DisplayObject = d.getChildAt(c);
				var go:Boolean = true;
				for(var key:String in iHave)
				{
					if(iHave[key]==child){
						go = false;
						break;
					}
				}
				if(go&&child){
					child.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
					child.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
					iHave.push(child);
				}
				
				if(child is DisplayObjectContainer)
					setListeners(DisplayObjectContainer(child));
			}
		}
		
		private static function mouseUp(e:MouseEvent):void
		{
			if(!selecting) return void;
				
			setSelected(DisplayObject(e.target));
			selecting = false;
		}
		
		private static function setSelected(d:DisplayObject):void
		{
			if(!d) return;
			
			currentlySelected = d;
			
			title.text = "";
			//show the path in title
			var p:DisplayObject = d;
			do{
				var type:String = flash.utils.getQualifiedClassName(p).split("::")[1];
				title.htmlText = (p==d?'<font color="#FF0000">':'')+
							" > "+type+
							(type!='Stage'?'['+p.name+']':'')+
							(p==d?'</font>':'')+title.htmlText;
			}while((p=p.parent)!=null);
			s.addChild(fields);
			
			//show all the children
			while(childs.numChildren>0) childs.removeChildAt(0);
			var pos:Point = new Point();
			if(currentlySelected is DisplayObjectContainer){
				var doc:DisplayObjectContainer = d as DisplayObjectContainer;
				for(var c:int = 0; c<doc.numChildren; c++){
					var d:DisplayObject = doc.getChildAt(c);
					var b:DevelopButton = new DevelopButton(
												c+':'+
												flash.utils.getQualifiedClassName(d).split("::")[1]+
												"["+d.name+"]"
										  , -1);
					b.addEventListener(MouseEvent.CLICK, childClicked);
					b.name = ""+c; 
					b.x = pos.x;
					b.y = pos.y;
					childs.addChild(b);
					
					pos.x+=b.width+5;
					if(pos.x>s.width-135-95){
						pos.x = 0;
						pos.y +=20;
					}
				}
			}
			
			refresh();
			onParamChange();
		}
		
		private static function childClicked(e:MouseEvent):void
		{
			setSelected((currentlySelected as DisplayObjectContainer).getChildAt(int(e.target.name)));
		}
		
		private static function mouseMove(e:MouseEvent):void
		{
			if(!selecting) return void;
				
			var d:DisplayObject = DisplayObject(e.target);
			var p:Point = d.localToGlobal(new Point(0, 0));
			drawOverlay.graphics.clear();
			drawOverlay.graphics.lineStyle(1, 0xFF0000);
			drawOverlay.graphics.drawRect(p.x, p.y, d.width, d.height);
		}
		
		public static function refresh(e:Event = null):void
		{
			stage.setChildIndex(s, stage.numChildren-1);
			s.graphics.clear();
			
			s.graphics.beginFill(0xBBBBBB);
			s.graphics.drawRect(-5, 0, s.width+10, s.height-10);
			s.graphics.beginFill(0x444444);
			s.graphics.drawRect(-5, -20, s.width, 20);
			
			setListeners(stage);
		}
	}
}
