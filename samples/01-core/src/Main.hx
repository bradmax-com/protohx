package ;
import test.Foo;
import protohx.Message;
import haxe.io.BytesOutput;
import google.protobuf.compiler.CodeGeneratorRequest;
import test.IntTestMessage;
import test.complexmessage.Point;
import test.complexmessage.MsgType;
import protohx.Protohx;
import test.ComplexMessage;
import haxe.io.Bytes;
import haxe.Int64;
using haxe.Int64;

class Main {
    public function new() {
    }

    public static function main():Void {
#if js
        haxe.unit.TestRunner.print = function ( v : Dynamic ){
            untyped __js__("console.log(v);");
        }
#end
        var r = new haxe.unit.TestRunner();
        r.add(new TestComplex());
        r.add(new TestInt());
        r.add(new TestInt64());
        r.add(new TestLargeData());
        r.add(new TestFloat());
        r.run();
    }
}

class TestLargeData extends haxe.unit.TestCase {
    public function getBytes():Bytes {
        #if openfl
        return openfl.Assets.getBytes("assets/plugin_proto_input");
        #elseif (java||cpp)
            return sys.io.File.getBytes("plugin_proto_input");
        #else
        return haxe.Resource.getBytes("plugin_proto_input");
        #end
    }
    public function testPlugin() {
//        try {
        var bytes = getBytes();
        var m = new CodeGeneratorRequest();
        assertTrue(bytes != null);
        m.mergeFrom(bytes);
        var b = new BytesOutput();
        m.writeTo(b);
        var copyBytes = b.getBytes();
        assertEquals(bytes.length, copyBytes.length);
        for (i in 0...bytes.length) {
            assertEquals(bytes.get(i), copyBytes.get(i));
        }
//        } catch (e:Dynamic) {untyped __java__("((java.lang.Throwable)e).printStackTrace()");}
    }


#if !(cpp || java || cs)  //TODO
    public function testPluginUnknowns() {
//        try {
        var bytes = getBytes();
        var m = new Message();
        assertTrue(bytes != null);
        m.mergeFrom(bytes);
        var b = new BytesOutput();
        m.writeTo(b);
        var copyBytes = b.getBytes();
        assertEquals(bytes.length, copyBytes.length);
        for (i in 0...bytes.length) {
            assertEquals(bytes.get(i), copyBytes.get(i));
        }
//        } catch (e:Dynamic) {untyped __java__("((java.lang.Throwable)e).printStackTrace()");}
    }
#end
}


class TestBase extends haxe.unit.TestCase {

    public function copyMsg<T>(obj:T):T {
        var b = new BytesOutput();
        untyped obj.writeTo(b);
        var copy = Type.createInstance(Type.getClass(obj), []);
        untyped copy.mergeFrom(b.getBytes());
        return copy;
    }
}

class TestInt extends TestBase {

    public function testInt() {
        function forInt(value:PT_Int) {
            var obj = new IntTestMessage();
            obj.i32 = value;
            var copy = copyMsg(obj);
            assertEquals(obj.i32, value);
            assertEquals(obj.i32, copy.i32);
        }
        forInt(0x0f);
        forInt(0xf0);
        forInt(0xff);
        forInt(0xffff);
        forInt(0xffffff);
        forInt(-0xff);
        forInt(-0xffff);
        forInt(-0xffffff);
        forInt(0xffffffff);
        forInt(0xefffffff);
        forInt(-1);
        forInt(0);
        for (i in 0...32) {
            forInt(1 << i);
        }
    }

    public function testUInt() {
        function forInt(value:PT_UInt) {
            var obj = new IntTestMessage();
            obj.ui32 = value;
            var copy = copyMsg(obj);
            assertEquals(obj.ui32, value);
            assertEquals(obj.ui32, copy.ui32);
        }
        forInt(0x0f);
        forInt(0xf0);
        forInt(0xff);
        forInt(0xffff);
        forInt(0xffffff);
        forInt(0xffffffff);
        forInt(0xefffffff);
        forInt(0);
        for (i in 0...32) {
            forInt(1 << i);
        }
    }

    public function testSInt() {
        function forInt(value:PT_Int) {
            var obj = new IntTestMessage();
            obj.si32 = value;
            var copy = copyMsg(obj);
            assertEquals(obj.si32, value);
            assertEquals(obj.si32, copy.si32);
        }
        forInt(0xff);
        forInt(0xffff);
        forInt(0xffffff);
        forInt(-0xff);
        forInt(-0xffff);
        forInt(-0xffffff);
        forInt(0xffffffff);
        forInt(0xefffffff);
        forInt(-1);
        forInt(0);
        for (i in 0...32) {
            forInt(1 << i);
        }
    }

    public function testRepeat() {
        var obj = new IntTestMessage();
        for( x in 0...1000 ) {
            obj.rnds.push(x);
            obj.srnds.push(x);
            obj.urnds.push(x);
            obj.frnds.push(x);
        }
        for( x in 0...1000 ) {
            obj.rnds.push(-x);
            obj.srnds.push(-x);
            obj.frnds.push(-x);
        }

        var copy = copyMsg(obj);
        for (i in 0...obj.rnds.length) {
            assertEquals(obj.rnds[i], copy.rnds[i]);
        }
        for (i in 0...obj.srnds.length) {
            assertEquals(obj.srnds[i], copy.srnds[i]);
        }
        for (i in 0...obj.urnds.length) {
            assertEquals(obj.urnds[i], copy.urnds[i]);
        }
        for (i in 0...obj.frnds.length) {
            assertEquals(obj.frnds[i], copy.frnds[i]);
        }
    }
}

class TestInt64 extends TestBase {

    public function testInt64() {
        function forInt64(l:PT_Int, h:PT_Int = 0) {
            var obj = new IntTestMessage();
            obj.i64 = Protohx.newInt64(h, l);
            var copy = copyMsg(obj);
            assertTrue(copy.hasI64());
            assertEquals(obj.i64.getLow(), copy.i64.getLow());
            assertEquals(obj.i64.getHigh(), copy.i64.getHigh());
        }
        forInt64(0x0);
        forInt64(0xff);
        forInt64(0xffff);
        forInt64(0xffffff);

        forInt64(0xffffffff);
        forInt64(0xefffffff);
        forInt64(0);

        forInt64(0, 0x1);
        forInt64(0, 0xff);
        forInt64(0, 0xffff);
        forInt64(0, 0xffffff);
        forInt64(0, 0xffffffff);
        forInt64(0, 0xefffffff);
    }
}

class TestFloat extends TestBase {

    public function testFloat() {
        function forFloat(v:PT_Float) {
            var obj = new IntTestMessage();
            obj.f = v;
            obj.d = v;
            var copy = copyMsg(obj);
            assertEquals(obj.f, copy.f);
            assertEquals(obj.d, copy.d);
        }
        function forFloat2(v:PT_Float, p:PT_Float) {
            var obj = new IntTestMessage();
            obj.f = v;
            obj.d = v;
            var copy = copyMsg(obj);
            assertTrue(Math.abs(obj.f - copy.f) < p);
            assertTrue(Math.abs(obj.d - copy.d) < p);
        }
        forFloat(0x0);
        forFloat(0xff);
        forFloat(0xffff);
        forFloat(0xffffff);

        forFloat(0xffffffff);
        forFloat(0.5);

        var p = 0.000001;
        for(i in 1...101){
            forFloat2(1.0 / i, p);
        }
    }
}

class TestComplex extends TestBase {
    public function testBasic() {
        function p(x, y) {
            var pt = new Point();
            pt.x = x;
            pt.y = y;
            return pt;
        }

        var obj = new ComplexMessage();

        obj.type = MsgType.BBB;
        obj.msg = "msg1";
        obj.id = 12345;

        obj.uid = 54321;
        obj.offline = true;

        obj.attach = null;
        obj.statuses = ["123", "456"];
        obj.points = [p(1, 2), p(3, 4)];

        obj.msgOpt = "msgOpt1";

        obj.rnd = -1;

        obj.attach = Bytes.alloc(256);
        for (b in 0...256) {
            obj.attach.set(b, b);
        }
        assertEquals(obj.attach.length, 256);

        var b = new BytesOutput();
        obj.writeTo(b);
        var copy = new ComplexMessage();
        copy.mergeFrom(b.getBytes());

        assertEquals(obj.type, copy.type);
        assertEquals(obj.msg, copy.msg);
        assertEquals(obj.id, copy.id);
        assertEquals(obj.uid, copy.uid);
        assertEquals(obj.offline, copy.offline);
        assertEquals(Std.string(obj.statuses), Std.string(copy.statuses));

        assertEquals(obj.rnd, copy.rnd);
        assertEquals(copy.attach.length, 256);

        for (b in 0...256) {
            var c = copy.attach.get(b);
            assertEquals(c, b);
        }

        var foo = new Foo();
        assertEquals("1.0", foo.version);
    }

}
