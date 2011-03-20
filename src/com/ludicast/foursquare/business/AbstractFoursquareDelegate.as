package com.ludicast.foursquare.business
{
	import com.adobe.serialization.json.JSON;
	import com.ludicast.foursquare.models.Category;
	import com.ludicast.foursquare.models.Checkin;
	import com.ludicast.foursquare.models.Photo;
	import com.ludicast.foursquare.models.Tip;
	import com.ludicast.foursquare.models.Venue;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import mx.containers.Tile;
	import mx.controls.Alert;
	import mx.rpc.events.ResultEvent;
	
	import org.benrimbey.factory.VOInstantiator;

	public class AbstractFoursquareDelegate {
		protected var accessKey:String;

		
		protected function defaultFoursquareFailure(event:Event):void {
			Alert.show("Foursquare failure:" + event);
		}		
		
		
		protected function constructUrl(path:String):String {
			return null;
		}
		
		protected function load(endpoint:String, parseFunc:Function, failure:Function = null):void {
			failure ||= defaultFoursquareFailure;
			var url:URLRequest = new URLRequest(constructUrl(endpoint));
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(Event.COMPLETE, parseFunc);
			loader.addEventListener(IOErrorEvent.IO_ERROR, failure);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, failure);
			loader.load(url);
		}
		
		public function getCategories(success:Function, failure:Function = null):void {
			load("venues/categories", function(event:Event):void {
				var categories:Array = jsonResponse(event).categories;
				sendResult(success,instantiate(categories, Category));
			}, failure);			
		}

		protected function jsonResponse(event:Event):* {
			return JSON.decode(event.target.data, false).response;
		}
	
		protected function sendResult(success:Function, result:*):void {
			success(new ResultEvent(ResultEvent.RESULT,false,true,result));			
		}
		
		protected function instantiate(array:Array, objClass:Class):Array {
			var result:Array = [];
			for each (var obj:* in array) {
				result.push( VOInstantiator.mapToFlexObjects(obj, objClass));	
			}
			return result;
		}
		
		public function getVenuesForCategory(lat:Number, lng:Number, category:String, success:Function, failure:Function = null):void {
			getGenericVenues(lat, lng, "&categoryId=" + category, success, failure)
		}
		
		public function getVenues(lat:Number, lng:Number, success:Function, failure:Function = null):void {
			getGenericVenues(lat, lng, "", success, failure)
		}
		
		protected function getGenericVenues(lat:Number, lng:Number, queryString:String,success:Function, failure:Function = null):void {
			load("venues/search?ll=" + lat + "," + lng + queryString, function(event:Event):void {
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
			}, failure);		
		}
		
		public function getVenueInfo(venueId:String, success:Function, failure:Function = null):void {
			load("venues/" + venueId, function(event:Event):void {
				var venueObj:* = jsonResponse(event).venue;
				var venue:Venue = buildVenue(venueObj); 
				sendResult(success,venue);
			}, failure);
		}	
		
		protected function populateVector(arrayClass:*,obj:*, clazz:Class):* {
			var array:* = new arrayClass(); 
			for (var i:Number = 0; i < obj.groups.length; i++) {
				var items:Array = obj.groups[i].items;
				for each (var item:* in items) {
					array.push(
						VOInstantiator.mapToFlexObjects(item, clazz)
					);
				}
			}
			return array;
		}
		
		protected function buildVenue(venueObj:*):Venue {
			var venue:Venue = VOInstantiator.mapToFlexObjects(venueObj, Venue) as Venue;
			venue.currentCheckins = populateVector(Vector.<Checkin>, venueObj.hereNow, Checkin);
			venue.venueTips = populateVector(Vector.<Tip>, venueObj.tips, Tip);
			venue.venuePhotos = populateVector(Vector.<Photo>, venueObj.photos, Photo);
			return venue;
		}		
		
	}
}