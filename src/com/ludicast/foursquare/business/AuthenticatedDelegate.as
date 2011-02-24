package com.ludicast.foursquare.business
{
	import com.adobe.serialization.json.JSON;
	import com.ludicast.foursquare.events.FoursquareResultEvent;
	import com.ludicast.foursquare.models.*;
	import com.org.benrimbey.factory.VOInstantiator;
	
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.HeaderEvent;
	import mx.rpc.events.ResultEvent;
	
	public class AuthenticatedDelegate {
				
		private var accessKey:String
		
		private static const API_URL:String = "https://api.foursquare.com/v2/"
		
		public function AuthenticatedDelegate(accessKey:String) {
			this.accessKey = accessKey;
		}
		
		protected function getAuthInfo():String {
			return "?oauth_token=" + accessKey;
 		}
		
		private function randomizer():String {
			return "&randomizer=" + Math.random() * 8000;
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
				success(new FoursquareResultEvent(
					instantiate(categories, Category)
				));
			});			
		}
		
		private function load(endpoint:String, parseFunc:Function):void {
			var url:URLRequest = new URLRequest( API_URL + endpoint + getAuthInfo());
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseFunc);
			loader.load(url);
		}
		
		
		private function jsonResponse(event:Event):* {
			return JSON.decode(event.target.data, false).response;
		}
		
		public function getVenueInfo(venueId:String, success:Function):void {
			load("venues/" + venueId, function(event:Event):void {
				var venueObj:* = jsonResponse(event).venue;
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
				success(new FoursquareResultEvent(venue));
			});
		}	
	}
}