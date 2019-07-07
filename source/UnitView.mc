using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.ActivityMonitor;
using Toybox.Activity;
using Toybox.SensorHistory;
var vertSpacing = 60;
var digitalBig = null;
var digitalSmall = null;
var digitalMed = null;
var digitalMicro = null;
var icons = null;
var textColor = Graphics.COLOR_LT_GRAY;
var dataIcon = new[3]; //dataIcon[1] datafield 1 icon number 
var dataIconColor = new[3];
var data = new[3]; //data[1] datafield 1 value, data[2], datafield 2 value...
var partialUpdatesAllowed = false; //indicator if partial updates are allowed
var clockTime;
var hour;
var altitude = 0;
var pressure = 0;
var Settings;

class UnitView extends WatchUi.WatchFace {

    function initialize() {
        WatchFace.initialize();
        partialUpdatesAllowed = ( Toybox.WatchUi.WatchFace has :onPartialUpdate ); 
		//hasHR=(ActivityMonitor has :HeartRateIterator) ? true : false; //checking device for hrm
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
    	
    	Settings = System.getDeviceSettings();
    
    	dc.clearClip;
    	dc.setColor(Graphics.COLOR_TRANSPARENT, Application.getApp().getProperty("BackgroundColor"));
    	dc.clear();
    	
    	//draw lines
    	dc.setColor(Application.getApp().getProperty("LineColor"),Graphics.COLOR_TRANSPARENT);
    	dc.setPenWidth(8);
    	dc.drawLine(0,dc.getHeight()-80,dc.getWidth(),dc.getHeight()-80);
		dc.drawLine(0,vertSpacing,dc.getWidth(),vertSpacing);
		dc.drawLine(180,vertSpacing,180,dc.getHeight()-80);
		dc.fillCircle(50,dc.getHeight()-vertSpacing,45);
		
		
		//get clock
      	clockTime = System.getClockTime();
     	hour = clockTime.hour;
     	
      	//drawAM/PM and correct for 24hr
      	var ampmString;
      	dc.setColor(Application.getApp().getProperty("AMPMColor"),Graphics.COLOR_TRANSPARENT);
      	if (!Settings.is24Hour){
	      	if (hour > 12){
	      		hour = hour - 12;
	      		ampmString = "PM";
	      		dc.drawText(15,120,digitalMicro,ampmString,Graphics.TEXT_JUSTIFY_CENTER);
	      	}
	      	else if(hour == 0){
	      		hour = 12;
	      		ampmString = "AM";
	      		dc.drawText(15,120,digitalMicro,ampmString,Graphics.TEXT_JUSTIFY_CENTER);
	      	}
	      	else{
	      		ampmString = "AM";
	      		dc.drawText(15,120,digitalMicro,ampmString,Graphics.TEXT_JUSTIFY_CENTER);
	      	}
      	}
      	
      	if (!Settings.is24Hour){

      	}
      	var timeString = Lang.format("$1$:$2$", [hour.format("%02d"), clockTime.min.format("%02d")]);
      	dc.setColor(Application.getApp().getProperty("TimeColor"),Graphics.COLOR_TRANSPARENT);
      	dc.drawText(97,57,digitalBig,timeString,Graphics.TEXT_JUSTIFY_CENTER);
      	
      	//draw seconds
      	if(partialUpdatesAllowed){
      		drawSeconds(dc);
      	}
      	
      	//draw date
      	var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
		var dateString = Lang.format("$1$-$2$", [today.month, today.day]);
		var dayString = Lang.format("$1$", [today.day_of_week]);
		dc.setColor(Application.getApp().getProperty("DateColor"),Graphics.COLOR_TRANSPARENT);
      	dc.drawText(dc.getWidth()/2,20,digitalSmall,dateString,Graphics.TEXT_JUSTIFY_CENTER);
      	dc.drawText(dc.getWidth()/2,7,digitalMicro,dayString,Graphics.TEXT_JUSTIFY_CENTER);
      	
      	//draw battery
      	var battery = System.getSystemStats().battery;
     	var batteryAngle = ((battery/100) * 265) - 95;
      	//draw battery arc
		dc.setColor(Application.getApp().getProperty("BackgroundColor"),Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(50,dc.getHeight()-vertSpacing,38);
		dc.setColor(Application.getApp().getProperty("BatteryBarColor"),Graphics.COLOR_TRANSPARENT);
		dc.drawArc(50,dc.getHeight()-vertSpacing,34,1,batteryAngle,-95);
		dc.setColor(Application.getApp().getProperty("BackgroundColor"),Graphics.COLOR_TRANSPARENT);
		dc.fillCircle(50,dc.getHeight()-vertSpacing,34);
		
		//draw battery number
		if (battery < 20){
      	dc.setColor(Application.getApp().getProperty("BatteryLowColor"),Graphics.COLOR_TRANSPARENT);
      	}
      	else{
      	dc.setColor(Application.getApp().getProperty("BatteryColor"),Graphics.COLOR_TRANSPARENT);				   
		}
      	dc.drawText(52,160,digitalSmall,battery.format("%d")+"%",Graphics.TEXT_JUSTIFY_CENTER);
      	
		//draw bt indicator
		if(Application.getApp().getProperty("DisplayBluetooth")){
		var isBTConnected= System.getDeviceSettings().phoneConnected;
			if(isBTConnected == true){
				var btString = "A";
				dc.setColor(Graphics.COLOR_DK_BLUE,Graphics.COLOR_TRANSPARENT);
				dc.drawText(153,127,icons,btString,Graphics.TEXT_JUSTIFY_CENTER);
			}
		}
		
		//draw notification indicator
		if(Application.getApp().getProperty("DisplayNotifications")){
			var notificationCount= System.getDeviceSettings().notificationCount;
			var notificationCountString = Lang.format("$1$", [notificationCount]);
			if(notificationCount > 0){
				var ntString = "D";
				dc.setColor(Application.getApp().getProperty("NotificationsColor"),Graphics.COLOR_TRANSPARENT);
				dc.drawText(105,129,digitalMicro,notificationCountString,Graphics.TEXT_JUSTIFY_RIGHT);
				dc.setColor(Graphics.COLOR_ORANGE,Graphics.COLOR_TRANSPARENT);
				dc.drawText(122,128,icons,ntString,Graphics.TEXT_JUSTIFY_CENTER);
			}
		}
		
		//get data for data fields
      	retriveData();

		
		//draw DataField 1
      	dc.setColor(Application.getApp().getProperty("DataField1Color"),Graphics.COLOR_TRANSPARENT);
      	dc.drawText(190,162,digitalSmall,data[0],Graphics.TEXT_JUSTIFY_RIGHT);
      	dc.setColor(dataIconColor[0],Graphics.COLOR_TRANSPARENT);
      	dc.drawText(202,167,icons,dataIcon[0],Graphics.TEXT_JUSTIFY_CENTER);
      	
      	//Draw DataField 2
      	dc.setColor(Application.getApp().getProperty("DataField2Color"),Graphics.COLOR_TRANSPARENT);
      	dc.drawText(153,200,digitalSmall,data[1],Graphics.TEXT_JUSTIFY_RIGHT);
      	dc.setColor(dataIconColor[1],Graphics.COLOR_TRANSPARENT);
      	dc.drawText(165,207,icons,dataIcon[1],Graphics.TEXT_JUSTIFY_CENTER);
      	
      	//Draw Datafield 3
      	dc.setColor(Application.getApp().getProperty("DataField3Color"),Graphics.COLOR_TRANSPARENT);
      	dc.drawText(200,190,digitalMicro,data[2],Graphics.TEXT_JUSTIFY_RIGHT);
      	
      	//System.println(data);
    }
    
    function onPartialUpdate(dc) {
	    dc.setClip(200,70,30,80);
	    dc.setColor(Graphics.COLOR_TRANSPARENT, Application.getApp().getProperty("BackgroundColor"));
	    dc.clear();
	    drawSeconds(dc);
	    dc.clearClip();
    }
    
    function drawSeconds(dc){
	    var clockTime2 = System.getClockTime();
	    var second = Lang.format("$1$", [clockTime2.sec.format("%02d")]);
	    var second1 = second.substring(0,1);
	    var second2 = second.substring(1,2);
	    dc.setColor(Application.getApp().getProperty("SecondsColor"),Graphics.COLOR_TRANSPARENT);
	    dc.drawText(210,63,digitalMed,second1,Graphics.TEXT_JUSTIFY_CENTER);
	    dc.drawText(210,105,digitalMed,second2,Graphics.TEXT_JUSTIFY_CENTER);
    }
    
	function retriveData(){
	    var info = ActivityMonitor.getInfo();
	    var activityInfo =  Activity.getActivityInfo();
      	var dataType = new[3]; //array size 3 that holds value for type of data to be displayed
      	
		dataType[0] = Application.getApp().getProperty("DataField1");
		dataType[1] = Application.getApp().getProperty("DataField2");
		dataType[2] = Application.getApp().getProperty("DataField3");
      	
		for(var i = 0; i < 3; i++){
			if(dataType[i] == 1){ //steps
				//data[i] = info.steps;
				data[i] = info.steps;
				dataIcon[i] = "C";
				dataIconColor[i] = Graphics.COLOR_BLUE;
			}
			else if(dataType[i] == 2){ //Stepgoal
				data[i] = info.stepGoal;
				dataIcon[i] = "C";
				dataIconColor[i] = Graphics.COLOR_BLUE;
			}
			else if(dataType[i] == 3){ //Distance
			
				if(Settings.distanceUnits==System.UNIT_STATUTE) { 
					data[i]=(info.distance/160934.0).format("%.1f")+"mi"; 
				} 
				else { 
					data[i]=(info.distance/(100000.0)).format("%.1f")+"km"; 
				} 
				dataIcon[i] = "I";
				dataIconColor[i] = Graphics.COLOR_ORANGE;
			}
			else if(dataType[i] == 4){ //Floorsclimbed
				if(ActivityMonitor.getInfo() has :floorsClimbed) { 
					data[i] = info.floorsClimbed + " floors";
				}
				else{
					 data[i] = "NA";
				}
				dataIcon[i] = "E";
				dataIconColor[i] = Graphics.COLOR_BLUE;
			}
			else if(dataType[i] == 5){ //Active Min Day
				data[i] = info.activeMinutesDay.total;
				dataIcon[i] = "G";
				dataIconColor[i] = Graphics.COLOR_ORANGE;
			}
			else if(dataType[i] == 6){ //Active Min Week
				data[i] = info.activeMinutesWeek.total;
				dataIcon[i] = "G";
				dataIconColor[i] = Graphics.COLOR_ORANGE;
			}
			else if(dataType[i] == 7){ //Calories
	        	data[i] = info.calories;
				dataIcon[i] = "B";
				dataIconColor[i] = Graphics.COLOR_RED;
			}
			else if(dataType[i] == 8){ //Heart Rate
				if (ActivityMonitor has :getHeartRateHistory) {
		  			var hrHist =  ActivityMonitor.getHeartRateHistory(1, true);
		  			data[i] = hrHist.next().heartRate;
				} else {
		  			data[i] = "NA";
				}
				dataIcon[i] = "F";
				dataIconColor[i] = Graphics.COLOR_RED;
			}
			else if(dataType[i] == 9){ //Altitude
				if(Activity.getActivityInfo() has :altitude){
					altitude = activityInfo.altitude;
						if(altitude != null){
							if(Settings.elevationUnits==System.UNIT_METRIC) {
								data[i] = altitude.format("%.0f");
							}
							else{
								altitude = altitude * 3.28084;
								data[i] = altitude.format("%.0f");
							}
						}	
				}
				else{
					data[i] = "NA";
				}
				dataIcon[i] = "K";
				dataIconColor[i] = Graphics.COLOR_GREEN;
			}
			else if(dataType[i] == 10){ //Pressure
				if(Activity.getActivityInfo() has :ambientPressure) { 
					pressure = activityInfo.ambientPressure;
					if (pressure == null){
						pressure = 0;
					}
					else{
						data[i] = pressure;
					}
				}
				else{
					data[i] = "NA";
				}
				dataIcon[i] = "L";
				dataIconColor[i] = Graphics.COLOR_BLUE;
			}
			else if(dataType[i] == 11){ //UTC Time
				var UTCOffset = clockTime.timeZoneOffset/3600;
				var UTChour = hour - UTCOffset;
				if(UTChour >= 24){
					UTChour = UTChour - 24;
				}
				
				System.println(UTChour);
				var UTCTimeString = Lang.format("$1$:$2$", [UTChour.format("%02d"), clockTime.min.format("%02d")]);
				data[i] = UTCTimeString;
				dataIcon[i] = "H";
				dataIconColor[i] = Graphics.COLOR_WHITE;
			}
			else{
				break;
			}
		} 
		return data;
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
    
    function onPowerBudgetExceeded(powerInfo) {
        partialUpdatesAllowed = false;
    }
	
}
