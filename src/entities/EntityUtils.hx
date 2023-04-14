package entities;

using StringTools;

class EntityUtils {
    public static function dateToIso8601(date:Date):String {
        return DateTools.format(date, "%Y-%m-%dT%H:%M:%SZ");
    }

    public static function iso8601ToDate(dateString:String):Date {
        dateString = dateString.replace("Z", "");
        dateString = dateString.replace("T", " ");
        return Date.fromString(dateString);
    }
}