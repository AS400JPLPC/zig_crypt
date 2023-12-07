const std = @import("std");

const utf = @import("std").unicode;

const allocx = std.heap.page_allocator;

/// Iterator support iteration string
pub const iteratStr = struct {
	var strbuf:[] const u8 = undefined;

	//var arenastr = std.heap.ArenaAllocator.init(std.heap.page_allocator);
	//defer arena.deinit();
	const allocstr = std.heap.page_allocator;

	/// Errors that may occur when using String
	pub const ErrNbrch = error{
	InvalideAllocBuffer,
	};
	


	pub const StringIterator = struct {
	buf: []u8 ,
	index: usize ,


	fn allocBuffer ( size :usize) ErrNbrch![]u8 {
		var buf = allocstr.alloc(u8, size) catch {
			return ErrNbrch.InvalideAllocBuffer;
		};
		return buf;
	}

	/// Deallocates the internal buffer
	pub fn deinit(self: *StringIterator) void {
		if (self.buf.len > 0)	allocstr.free(self.buf);
	}

	pub fn next(it: *StringIterator) ?[]const u8 {
		var optional_buf: ?[]u8	= allocBuffer(strbuf.len) catch return null;
	
		it.buf= optional_buf orelse "";
		var idx : usize = 0;

		while (true) {
			if (idx >= strbuf.len) break;
			it.buf[idx] = strbuf[idx];
			idx += 1;
		}

		if (it.index == it.buf.len) return null;
		idx = it.index;
		it.index += getUTF8Size(it.buf[idx]);
		return it.buf[idx..it.index];
	}

	pub fn preview(it: *StringIterator) ?[]const u8 {
		var optional_buf: ?[]u8	= allocBuffer(strbuf.len) catch return null;

		it.buf= optional_buf orelse "";
		var idx : usize = 0;
		while (true) {
			if (idx >= strbuf.len) break;
			it.buf[idx] = strbuf[idx];
			idx += 1;
		}

		if (it.index == 0) return null;
		idx = it.buf.len;
		it.index -= getUTF8Size(it.buf[idx]);
		return it.buf[idx..it.index];
	}
};

	/// iterator String
	pub fn iterator(str:[] const u8) StringIterator {
		strbuf = str;
		return StringIterator{
			.buf = undefined,
			.index = 0,
		};
	}

	/// Returns the UTF-8 character's size
	fn getUTF8Size(char: u8) u3 {
		return std.unicode.utf8ByteSequenceLength(char) 
		catch |err| { @panic(@errorName(err));};
	}
};



pub fn encrypt( src: []const u8, it: [10]  u21) std.ArrayList([] const u8) {
	const allocator = std.heap.page_allocator;
	var dst = std.ArrayList([] const u8).init(allocator);
	var r : [] const u8 = undefined ;
	var i :u21 = 0;
	var z :u64 = 0;
	var crt: [] const u8 = undefined;
	var iter = iteratStr.iterator(src);
	defer iter.deinit();

		while (iter.next()) |ch| {
			var x =utf.utf8Decode(ch) catch unreachable;
			if ( x <= 32) {
				if( x == 10 ) r = std.fmt.allocPrint(allocator,"{s}", .{"1"}) catch unreachable
				else  r = std.fmt.allocPrint(allocator,"{s}", .{"2"}) catch unreachable;
			}
			else {
				var crp= std.fmt.allocPrint(allocator,"{d}", .{x}) catch unreachable;
				z= 0;
				while( z < crp.len) : (z += 1) {
						switch(crp[z]) {
						48 => { crt =std.fmt.allocPrint(allocator,"{u}", .{it[0]}) catch unreachable;
								i =	utf.utf8Decode(crt) catch unreachable;
						},
						49 => { crt =std.fmt.allocPrint(allocator,"{u}", .{it[1]}) catch unreachable;
								i =	utf.utf8Decode(crt) catch unreachable;
						},
						50 => { crt =std.fmt.allocPrint(allocator,"{u}", .{it[2]}) catch unreachable;
								i =	utf.utf8Decode(crt) catch unreachable;
						},
						51 => { crt =std.fmt.allocPrint(allocator,"{u}", .{it[3]}) catch unreachable;
								i =	utf.utf8Decode(crt) catch unreachable;
						},
						52 => { crt =std.fmt.allocPrint(allocator,"{u}", .{it[4]}) catch unreachable;
								i =	utf.utf8Decode(crt) catch unreachable;
						},
						53 => { crt =std.fmt.allocPrint(allocator,"{u}", .{it[5]}) catch unreachable;
								i =	utf.utf8Decode(crt) catch unreachable;
						},
						54 => { crt =std.fmt.allocPrint(allocator,"{u}", .{it[6]}) catch unreachable;
								i =	utf.utf8Decode(crt) catch unreachable;
						},
						55 => { crt =std.fmt.allocPrint(allocator,"{u}", .{it[7]}) catch unreachable;
								i =	utf.utf8Decode(crt) catch unreachable;
						},
						56 => { crt =std.fmt.allocPrint(allocator,"{u}", .{it[8]}) catch unreachable;
								i =	utf.utf8Decode(crt) catch unreachable;
						},
						57 => { crt =std.fmt.allocPrint(allocator,"{u}", .{it[9]}) catch unreachable;
								i =	utf.utf8Decode(crt) catch unreachable;
						},
			
						else => {}
						}
					crt =std.fmt.allocPrint(allocator,"{u}", .{i}) catch unreachable;
					if( z == 0 ) r = std.fmt.allocPrint(allocator,"{s}", .{crt}) catch unreachable
					else  r = std.fmt.allocPrint(allocator,"{s}{s}", .{r,crt}) catch unreachable;
				}
			}
			dst.append(r) catch unreachable;
		}
	
	return dst ;
}



pub fn cryptTextLen( src: std.ArrayList([]const u8) , sep: [] const u8)  u64 {

	var result : u64 = 0;

	for (src.items) |p| {
		var iter = iteratStr.iterator(p);
		while (iter.next()) |ch| {
	
			if ( std.mem.eql(u8,ch,sep)) continue ;
			result +=1;
		}
		iter.deinit();
	}
	return result;
}


pub fn decryptctrl( src: []const u8 ,it: [10]  u21 , sep: [] const u8)  u64 {
	var n : u64 = 0 ;
	var v : u64 = 0 ;
	var r : u21  = 0 ;
	var z : usize = 0;
	var crt : [] const u8 = undefined ;
	var dst : []const u8= undefined ;
	var result : u64 = 0;

	const allocator = std.heap.page_allocator;

	var iter = iteratStr.iterator(src);
	defer iter.deinit();
	while (iter.next()) |ch| {
		
		if ( std.mem.eql(u8,"1",ch))  break ;


		if ( std.mem.eql(u8,ch,sep)) {
				r = @truncate(n); 
				// std.debug.print("{d}|",.{r});
				crt =std.fmt.allocPrint(allocator,"{u}", .{r}) catch unreachable;
				if( z == 0  ) dst =std.fmt.allocPrint(allocator,"{s}", .{crt}) catch unreachable
				else dst =std.fmt.allocPrint(allocator,"{s}{s}", .{dst,crt}) catch unreachable;
				n = 0 ;
				z = 1 ;
		}
		else  {
					r= 0;
					while(true) : ( r += 1) {
						crt =std.fmt.allocPrint(allocator,"{u}", .{it[r]}) catch unreachable;
						if ( std.mem.eql(u8,ch,crt)) { v = r ; break ; } 
					}
					if( n == 0 ) n = v
					else { n = n * 10 ; n += v; }
		}
	}
	
	result = std.fmt.parseInt(u64,dst[0.. dst.len] ,10 ) catch unreachable ;
	return result;
}



pub fn decryptTextLen( src: []const u8 , sep: [] const u8)  u64 {
	var k : usize = 0;
	var result : u64 = 0;


	var iter = iteratStr.iterator(src);
	defer iter.deinit();
	while (iter.next()) |ch| {
		
		if (k == 0) {
			if ( std.mem.eql(u8,"1",ch)) { k = 1 ; _= iter.next(); }
			continue ;
		}


		if ( std.mem.eql(u8,ch,sep)) continue ;
		result +=1;
	}
	return result;
}

pub fn cryptRead(path: [] const u8 , name : [] const u8) ! [] const u8 {
	const allocator = std.heap.page_allocator;

	const cDIR = std.fs.cwd().openDir(path,.{})
	catch |err| {@panic(try std.fmt.allocPrint(allocator,"err Open.{s} {any}\n", .{path,err}));};

	var file = cDIR.openFile(name, .{}) catch |err| {
			@panic(try std.fmt.allocPrint(allocator,"err Open {s}.{any}\n", .{name, err}));};

	const file_size = try file.getEndPos();
	var buffer : [] u8= allocator.alloc(u8, file_size) catch unreachable ;

	_= try file.read(buffer[0..buffer.len]);
	file.close();
	return buffer ;
}



pub fn cryptWrite(path: [] const u8 , name : [] const u8 ,
				 buf : std.ArrayList([] const u8) , sep: [] const u8,  keyctrl: [10] u21) ! void {
	
	const allocator = std.heap.page_allocator;
	
	const cDIR = std.fs.cwd().openDir(path,.{})
	catch |err| {@panic(try std.fmt.allocPrint(allocator,"err Open.{s} {any}\n", .{path,err}));};
	
	const file = cDIR.createFile(name,.{ }, ) catch unreachable ;

	var lctrl: []const u8 = std.fmt.allocPrint(allocator,"{d}\n", .{cryptTextLen(buf,sep)}) catch unreachable;
	var kctrl = encrypt(lctrl, keyctrl);
	// std.debug.print("encrypt  len {s}\n",.{lctrl});

	for (kctrl.items) |p| {
		_= file.write(std.fmt.allocPrint(allocator,"{s}{s}", .{p,sep}) catch unreachable) catch unreachable  ;
	}
	for (buf.items) |p| {
		_= file.write(std.fmt.allocPrint(allocator,"{s}{s}", .{p,sep}) catch unreachable) catch unreachable  ;
	}
	file.close();
}


pub fn decrypt( src: []const u8 ,it: [10]  u21 , sep: [] const u8) [] const u8 {
	var n : u64 = 0 ;
	var v : u64 = 0 ;
	var r : u21  = 0 ;
	var z : usize = 0;
	var k : usize = 0;
	var crt : [] const u8 = undefined ;
	var dst : [] const u8= undefined ;

	const allocator = std.heap.page_allocator;

	var iter = iteratStr.iterator(src);
	defer iter.deinit();
	while (iter.next()) |ch| {
		if (k == 0) {
			if ( std.mem.eql(u8,"1",ch)) { k = 1 ; _= iter.next(); }
			continue ;
		}
		if( std.mem.eql(u8,"1", ch) or std.mem.eql(u8,"2", ch) ){
			if( std.mem.eql(u8,"1", ch)) {
				if ( z == 0 ) dst = std.fmt.allocPrint(allocator,"{c}", .{10}) catch unreachable
				else dst = std.fmt.allocPrint(allocator,"{s}{c}", .{dst,10}) catch unreachable;
			}
			else {
				if ( z == 0  ) dst = std.fmt.allocPrint(allocator,"{s}", .{" "}) catch unreachable
				else dst = std.fmt.allocPrint(allocator,"{s}{s}", .{dst, " "}) catch unreachable;
			}
			z = 1 ;
			n = 0 ;
			_= iter.next();
		}
		else {
			if ( std.mem.eql(u8,ch,sep)) {
					r = @truncate(n);
					crt =std.fmt.allocPrint(allocator,"{u}", .{r}) catch unreachable;
					if( z == 0  ) dst =std.fmt.allocPrint(allocator,"{s}", .{crt}) catch unreachable
					else dst =std.fmt.allocPrint(allocator,"{s}{s}", .{dst,crt}) catch unreachable;
					n = 0 ;
					z = 1 ;
			}
			else  {
						r= 0;
						while(true) : ( r += 1) {
							crt =std.fmt.allocPrint(allocator,"{u}", .{it[r]}) catch unreachable;
							if ( std.mem.eql(u8,ch,crt)) { v = r ; break ; } 
						}
						if( n == 0 ) n = v
						else { n = n * 10 ; n += v; }
			}
		}
	}
	return dst ;
}



pub fn main() ! void {
	const allocator = std.heap.page_allocator;
	const separator  : [] const u8 = "와";
	const key  = [10] u21 {'壓','읍','웨','$','e','ô','g','@','i','j'};
	const ctrl = [10] u21 {'א','Ֆ','&','♂','פ','*','ח','✔','#','§'};
	var stop: bool = false ;
	var rctrl : u64 = undefined;
	// -----------------------------------------------------------------------------------
	var buffer = cryptRead("dspf","xtest") catch unreachable;
	var res: std.ArrayList([] const u8) = encrypt(buffer, key);
	// std.debug.print("encrypt\n",.{ });
	// for (res.items) |p| {
	// 	std.debug.print("{s}",.{p});
	// }
	cryptWrite("dspf","xtest.dspf", res , separator , ctrl) catch unreachable;
	allocator.free(buffer);
	res = undefined ;
	// -----------------------------------------------------------------------------------
	buffer = cryptRead("dspf","xtest.dspf") catch unreachable;
	// std.debug.print("\n buffer cryptRead crypted {s}\n ",.{buffer, });
	// -----------------------------------------------------------------------------------
	rctrl = decryptctrl(buffer, ctrl, separator);
	// std.debug.print("\n len decryptCtrl {d}\n ",.{rctrl });

	var lrep = decryptTextLen(buffer, separator);

	// std.debug.print("\n len decryptText {d}\n ",.{lrep  });
	if ( lrep != rctrl )  stop = true;
	if (stop) @panic(try std.fmt.allocPrint(allocator,"{s}\n", .{"error occurs"}));


	var rep = decrypt(buffer, key, separator);
	allocator.free(buffer);


	std.debug.print("decrypt\n",.{ });
	std.debug.print("{s}\n ",.{rep });
}
