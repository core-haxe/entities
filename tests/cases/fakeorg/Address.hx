package cases.fakeorg;

import entities.IEntity;

class Address implements IEntity {
    @:cascade
    public var lines:Array<AddressLine>;
    public var postCode:String;

    public function format() {
        var parts = [];
        for (l in lines) {
            parts.push(l.text);
        }
        parts.push(postCode);
        return parts.join(", ");
    }
}