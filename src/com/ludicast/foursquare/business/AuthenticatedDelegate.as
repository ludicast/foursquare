package com.ludicast.foursquare.business
{
	import com.adobe.serialization.json.JSON;
	import com.ludicast.foursquare.models.*;
	import com.org.benrimbey.factory.VOInstantiator;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	public class AuthenticatedDelegate {
				
		private var accessKey:String
		
		private static const API_URL:String = "https://api.foursquare.com/v2/"
		
		public function AuthenticatedDelegate(accessKey:String) {
			this.accessKey = accessKey;
		}
		
		protected function authorize(url:String):String {
			trace ("authing");
			var joinToken:String = "?";
			if (url.indexOf("?") != -1) {
				trace ("got  t tt token");
				joinToken = "&";
			}
			
			
			return url + joinToken + "oauth_token=" + accessKey;
 		}
		
		private function instantiate(array:Array, objClass:Class):Array {
			var result:Array = [];
			for each (var obj:* in array) {
				result.push( VOInstantiator.mapToFlexObjects(obj, objClass));	
			}
			return result;
		}
		
		public function getCategories(success:Function):void {
			load("venues/categories", function(event:Event):void {
				var categories:Array = jsonResponse(event).categories;
				sendResult(success,instantiate(categories, Category));
			});			
		}
		
		private function load(endpoint:String, parseFunc:Function):void {
			trace("loading");
			var url:URLRequest = new URLRequest(authorize(API_URL + endpoint));
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseFunc);
			loader.load(url);
		}
		
		private function sendResult(success:Function, result:*):void {
			success(new ResultEvent(ResultEvent.RESULT,false,true,result));			
		}
		
		
		private function jsonResponse(event:Event):* {
			return JSON.decode(event.target.data, false).response;
		}
		
		public function getVenues(lat:Number, lng:Number, success:Function):void {
			load("venues/search?ll=" + lat + "," + lng, function(event:Event):void {
				var venues:Array = [];
				var groups:Array = jsonResponse(event).groups;
				for each (var group:* in groups) {
					for each (var venue:* in group.items) {
						venues.push(
							VOInstantiator.mapToFlexObjects(venue, Venue)						
						);
					}
				}
				sendResult(success,venues);
			});		
		}
		
		public function getVenueInfo(venueId:String, success:Function):void {
			load("venues/" + venueId, function(event:Event):void {
				var venueObj:* = jsonResponse(event).venue;
				var venue:Venue = buildVenue(venueObj); 
				sendResult(success,venue);
			});
		}	
		
		private function buildVenue(venueObj:*):Venue {
			var venue:Venue = VOInstantiator.mapToFlexObjects(venueObj, Venue) as Venue;
			venue.currentCheckins = new Vector.<Checkin>();
			for (var i:Number = 0; i < venueObj.hereNow.groups.length; i++) {
				var tmpCheckins:Array = venueObj.hereNow.groups[i].items;
				for each (var checkin:* in tmpCheckins) {
					venue.currentCheckins.push(
						VOInstantiator.mapToFlexObjects(checkin, Checkin)
					);
				}
			}
			return venue;
		}
	}
}