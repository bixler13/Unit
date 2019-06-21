using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;

var vertSpacing = 60;
var digitalBig = null;
var digitalSmall = null;
var digitalMed = null;
var digitalMicro = null;
var icons = null;
var textColor = Graphics.COLOR_LT_GRAY;
var backgroundColor = Graphics.COLOR_BLACK;
var lineColor = Graphics.COLOR_DK_GRAY;


class UnitView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        digitalBig = WatchUi.loadResource(Rez.Fonts.digitalBig);
        digitalSmall = WatchUi.loadResource(Rez.Fonts.digitalSmall);
        digitalMed = WatchUi.loadResource(Rez.Fonts.digitalMed);
        digitalMicro = WatchUi.loadResource(Rez.Fonts.digitalMicro);
        icons = WatchUi.loadResource(Rez.Fonts.icons);
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
    	dc.clearClip;
    	dc.setColor(backgroundColor,backgroundColor);
    	dc.clear();
    	
    	//draw lines
    	dc.setColor(lineColor,Graphics.COLOR_TRANSPARENT);
    	dc.setPenWidth(8);
    	dc.drawLine(0,dc.getHeight()-80,dc.getWidth(),dc.getHeight()-80);
		dc.drawLine(0,vertSpacing,dc.getWidth(),vertSpacing);
		dc.drawLine(180,vertSpacing,180,dc.getHeight()-80);
		dc.fillCircle(50,dc.getHeight()-vertSpacing,45);
		
		
		//draw clock
      	var clockTime = System.getClockTime();
     	var hour = clockTime.hour;
      	//drawAM/PM
      	var ampmString;
      	dc.setColor(Graphics.COLOR_YELLOW,Graphics.COLOR_TRANSPARENT);
      	if (hour > 12){
      		ampmString = "PM";
      		dc.drawText(15,120,digitalMicro,ampmString,Graphics.TEXT_JUSTIFY_CENTER);
      	}
      	else{
      		ampmString = "AM";
      		dc.drawText(15,120,digitalMicro,ampmString,Graphics.TEXT_JUSTIFY_CENTER);
      	}
      	
      	if (!System.getDeviceSettings().is24Hour){
      		if (hour > 12) {
      			hour = hour - 12;
      		}
      	}
      	var timeString = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);
      	dc.setColor(textColor,Graphics.COLOR_TRANSPARENT);
      	dc.drawText(97,57,digitalBig,timeString,Graphics.TEXT_JUSTIFY_CENTER);
      	//draw seconds
      	drawSeconds(dc);
      	
      	
      	//draw date
      	var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
		var dateString = Lang.format("$1$-$2$", [today.month, today.day]);
		var dayString = Lang.format("$1$", [today.day_of_week]);
		dc.setColor(textColor,Graphics.COLOR_TRANSPARENT);
      	dc.drawText(dc.getWidth()/2,20,digitalSmall,dateString,Graphics.TEXT_JUSTIFY_CENTER);
      	dc.drawText(dc.getWidth()/2,7,digitalMicro,dayString,Graphics.TEXT_JUSTIFY_CENTER);
      	
      	//draw battery
      	var battery = System.getSystemStats().battery;
     	var batteryAngle = ((battery/100) * 265) - 95;
      	//draw battery arc
		dc.setColor(backgroundColor,Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(50,dc.getHeight()-vertSpacing,38);
		dc.setColor(Graphics.COLOR_GREEN,Graphics.COLOR_TRANSPARENT);
		dc.drawArc(50,dc.getHeight()-vertSpacing,34,1,batteryAngle,-95);
		dc.setColor(backgroundColor,Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(50,dc.getHeight()-vertSpacing,34);
		
		//draw battery number
		if (battery < 20){
      	dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);
      	}
      	else{
      	dc.setColor(textColor,Graphics.COLOR_TRANSPARENT);				   
		}
      	dc.drawText(52,160,digitalSmall,battery.format("%d")+"%",Graphics.TEXT_JUSTIFY_CENTER);
      	
      	//draw steps
      	var info = ActivityMonitor.getInfo();
		var steps = info.steps;
		var stepGoal = info.stepGoal;
		var stepIcon = "C";
      	dc.setColor(textColor,Graphics.COLOR_TRANSPARENT);
      	dc.drawText(183,162,digitalSmall,steps,Graphics.TEXT_JUSTIFY_RIGHT);
      	dc.setColor(Graphics.COLOR_DK_GRAY,Graphics.COLOR_TRANSPARENT);
      	dc.drawText(200,190,digitalMicro,stepGoal,Graphics.TEXT_JUSTIFY_RIGHT);
      	dc.setColor(Graphics.COLOR_BLUE,Graphics.COLOR_TRANSPARENT);
      	dc.drawText(195,167,icons,stepIcon,Graphics.TEXT_JUSTIFY_CENTER);
      	
      	//draw calories
      	var calories = info.calories;
      	var calorieIcon = "B";
		dc.setColor(textColor,Graphics.COLOR_TRANSPARENT);
      	dc.drawText(155,200,digitalSmall,calories,Graphics.TEXT_JUSTIFY_RIGHT);
      	dc.setColor(Graphics.COLOR_RED,Graphics.COLOR_TRANSPARENT);
      	dc.drawText(165,207,icons,calorieIcon,Graphics.TEXT_JUSTIFY_CENTER);
      	
		//draw bt indicator
		var isBTConnected= System.getDeviceSettings().phoneConnected;
		if(isBTConnected == true){
			var btString = "A";
			dc.setColor(Graphics.COLOR_DK_BLUE,Graphics.COLOR_TRANSPARENT);
			dc.drawText(153,127,icons,btString,Graphics.TEXT_JUSTIFY_CENTER);
		}
		else{
		}
		
		//draw notification indicator
		var notificationCount= System.getDeviceSettings().notificationCount;
		var notificationCountString = Lang.format("$1$", [notificationCount]);
		if(notificationCount > 0){
			var ntString = "D";
			dc.setColor(textColor,Graphics.COLOR_TRANSPARENT);
			dc.drawText(105,129,digitalMicro,notificationCountString,Graphics.TEXT_JUSTIFY_RIGHT);
			dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);
			dc.drawText(122,128,icons,ntString,Graphics.TEXT_JUSTIFY_CENTER);
		}
		else{
		}
    }
    
    function onPartialUpdate(dc) {
    dc.setClip(200,70,30,80);
    dc.setColor(backgroundColor,backgroundColor);
    dc.clear();
    drawSeconds(dc);
    dc.clearClip();
    }
    
    function drawSeconds(dc){
    var clockTime2 = System.getClockTime();
    var second = Lang.format("$1$", [clockTime2.sec.format("%02d")]);
    var second1 = second.substring(0,1);
    var second2 = second.substring(1,2);
     dc.setColor(textColor,Graphics.COLOR_TRANSPARENT);
     dc.drawText(210,63,digitalMed,second1,Graphics.TEXT_JUSTIFY_CENTER);
     dc.drawText(210,105,digitalMed,second2,Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep(dc) {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }
	
}
