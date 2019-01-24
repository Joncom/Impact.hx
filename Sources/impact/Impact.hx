package impact;

class Impact
{
	public static function merge ( original : Dynamic, extended : Dynamic ) {
		var keys = Reflect.fields( extended );
		for( key in keys ) {
			#if cpp
				var missingField = true;
				var classRef = Type.getClass( original );
				// `original` is a class instance?
				if( classRef != null ) {
					var found = false;
					for( field in Type.getInstanceFields( classRef ) ) {
						if( field == key ) {
							missingField = false;
							break;
						}
					}
				}
				/*
				// Then `original` must be an anonymous structure.
				else {
					if( Reflect.hasField( original, key ) ) {
						missingField = false;
					}
				}
				*/
				if( missingField ) {
					var message = "Impact.merge: On cpp target, you must define the following field before merging a value into it: " + ( classRef != null ? Type.getClassName( classRef ) + "." : "" ) + key;
					trace( message ); // Trace first because it's a pain in the butt hunting for errors in Android logcat
					throw message;
				}
			#end
			Reflect.setProperty( original, key, Reflect.field( extended, key ) );
		}
		return original;
	}

	public static function ksort ( obj ) {
		if( obj == null || !Reflect.isObject(obj) ) {
			return [];
		}

		var keys = [], values = [];
		var fields = Reflect.fields(obj);
		for (field in fields) {
			keys.push(field);
		}

		keys.sort(function(a, b):Int {
			if (a < b) return -1;
			else if (a > b) return 1;
			return 0;
		});
		for( i in 0...keys.length ) {
			values.push( Reflect.field(obj, keys[i]) );
		}

		return values;
	}
}
