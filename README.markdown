# AS3 library for foursquare

This library was written for [Hail To The Mayor](http://hailtothemayor.com) during the foursquare hackathon, but has since been built out as a more generic Foursquare library.

## Requirements

First of all it seems that this library only works with AIR apps, and SWFs that are hosted via https.

Secondly, I use a library from Ben Rimbey to cast foursquare's JSON results into Actionscript objects (e.g. `Venue`).  This library was enhanced so it can receive nested objects (such as tips for a venue).  An association tree can then be automatically pulled out of the JSON objects.

In enhancing it I use a class introduced in Flash 10, the `Vector`, to provide a "typed collection" for introspection purposes.   So it requires Flash 10 :).

Finally, you need to generate from foursquare an oauth key.  There are several ways to do this, you'll have to pick what works best for you..

## The Goal

I'm trying to take the "fat model, skinny controller" philosophy and apply it to this library.  What I mean by that is I would like the classes to have intelligent enough associations that everything gets pulled in as needed.  Adding a new foursquare endpoint should only require:

* description of the endpoint
* pulling out the main object from the JSON
* determining what class should be instantiated

As an example, this is how a tree of categories is pulled down and wrapped up
    public function getCategories(success:Function, failure:Function = null):void {
        load("venues/categories", function(event:Event):void {
            var categories:Array = jsonResponse(event).categories;
            sendResult(success,instantiate(categories, Category));
        }, failure);
    }

This uses introspection to pull in the entire tree of categories, sub-categories and sub-sub-categories.  This in possible because the `Category` object for venues is listed as:

    public class Category {
        public var name:String;
        public var categories:Vector.<Category> = new Vector.<Category>();
        ...
    }

The `Vector.<Category>` type is what lets introspection work its magic.  As long as the JSON object has an array of the same name, its elements are used to build instances of the appropriate class.

In order to use this code, you need to do nothing more than call getCategories with a callback function:

    getCategories(function(event:ResultEvent):void {
        this.categories = event.result as Array;
    });
    
Each `Category` object in the array has its inner vector of subcategories automagically populated as well.  Note that you can pass in a failure callback as well.  If you don't do this, the default failure will fire, which is just a popup indicating your error.

The benefits of this approach carry over to all models.  Since the `Venue` class also has a vector of `Category` objects, these get autopopulated too.

## Todo

Some of the things that should be worked on:

* There are some things in the foursquare api making introspection less than smooth.  In the `hereNow` field of a `venue`, for example, the checkin information is a little tricky to draw out.  Therefore we do this manually rather than let associations help us autopopulate the fields.  Some strategy should be established to smooth this out a bit.
* Right now I'm only throwing in the endpoints I use, but if you have your own feel free to add them.
* Similarly the models only have the fields set that I use.  Please add any others that are useful to you, but don't remove any because they could be used for someone else's endpoint! 
* If you have any testing strategy to add, please do.  As of now I'm planning to build an AIR app that does live integration testing with the endpoints.
* There needs to be a smoother way to add oauth keys to the app, for both AIR and browser-based Flash applications, maybe a separate project or two is required to handle this.

## License

This code is released under the MIT license.  Do whatever you want with it.