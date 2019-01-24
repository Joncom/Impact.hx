package impact;

interface Loadable
{
    public var path ( default, null ) : String;
    public function load ( ?callback : String -> Bool -> Void ) : Void;
}
