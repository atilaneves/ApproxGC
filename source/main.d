// ApproxGC — A cleanup program for Approx
//
// Copyright © 2017  Russel Winder <russel@winder.org.uk>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import std.algorithm: filter, joiner, map, sort;
import std.array: array, byPair, split;
import std.conv: to;
import std.file: dirEntries, remove, FileException, SpanMode;
version(unittest) {
	import std.format: format;
}
import std.path: baseName, chainPath, dirName, stripExtension;
import std.range: zip;
import std.regex: matchAll, matchFirst, regex;
import std.stdio: writefln, writeln;
import std.string: indexOf, lastIndexOf;
import std.typecons: Tuple, tuple;

auto groupsOfFilesAt(string path) {
	auto files = dirEntries(path, SpanMode.shallow)
	 .filter!(a => a.isFile)
	 .map!(a => a.baseName)
	 .map!(a => tuple(a.split('_')[0], a))
	 .array;
	string[][string] groups;
	foreach (Tuple!(string, string) f; files) {
		groups[f[0]] ~= [f[1]];
	}
	return groups;
}

bool epochlessLessThan(string a, string b) {
	auto a_i = a.lastIndexOf('-');
	auto aUpstreamVersionString = a_i > 0 ? a[0..a_i] : a;
	auto aDebianRevisionString = a_i > 0 ? a[a_i..$] : "0";
	auto b_i = b.lastIndexOf('-');
	auto bUpstreamVersionString = b_i > 0 ? b[0..b_i] : b;
	auto bDebianRevisionString = b_i > 0 ? b[b_i..$] : "0";
	// For now assume pure dotted numeric.
	// TODO Make this better.
	auto numericPattern = regex(r"[0-9]+");
	auto aUpstreamVersionMatches = matchAll(aUpstreamVersionString, numericPattern);
	auto bUpstreamVersionMatches = matchAll(bUpstreamVersionString, numericPattern);
	foreach (item; zip(aUpstreamVersionMatches, bUpstreamVersionMatches)) {
		auto aValue = to!int(item[0].hit);
		auto bValue = to!int(item[1].hit);
		if (aValue != bValue) {
			return aValue < bValue;
		}
	}
	auto aDebianRevisionMatches = matchAll(aDebianRevisionString, numericPattern);
	auto bDebianRevisionMatches = matchAll(bDebianRevisionString, numericPattern);
	foreach (item; zip(aDebianRevisionMatches, bDebianRevisionMatches)) {
		auto aValue = to!int(item[0].hit);
		auto bValue = to!int(item[1].hit);
		if (aValue != bValue) {
			return aValue < bValue;
		}
	}
	return false;
}

// Implement the official Debian package number sorting policy. See:
// https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-Version
bool debianPackageNumberLessThan(string a, string b) {
	// Assume a _ separates the package name and the package number, and that all packages have an extension,
	// expected to be .deb.
	auto aVersionString = a[a.indexOf('_')+1 .. $].stripExtension();
	auto bVersionString = b[b.indexOf('_')+1 .. $].stripExtension();
	// Process the epoch.
	auto epochRegex = regex(r"([0-9])+:");
	auto aEpochCapture = matchFirst(aVersionString, epochRegex);
	auto bEpochCapture = matchFirst(bVersionString, epochRegex);
	if (!aEpochCapture.empty) {
		auto aEpoch = to!int(aEpochCapture[1]);
		if (!bEpochCapture.empty) {
			auto bEpoch = to!int(bEpochCapture[1]);
			if (aEpoch != bEpoch) {
				return aEpoch < bEpoch;
			}
			else {
				return epochlessLessThan(aVersionString[aVersionString.indexOf(':')+1 .. $], bVersionString[bVersionString.indexOf(':')+1 .. $]);
			}
		}
		else { throw new Exception("One name has an epoch the other doesn't."); }
	}
	else {
		if  (!bEpochCapture.empty) { throw new Exception("One name has an epoch the other doesn't."); }
	}
	// Epochs if present were equal, so process the rest of the version number.
	return epochlessLessThan(aVersionString, bVersionString);
}

auto createDeleteList(string[][string] groups) {
	return groups.byPair()
	 .map!((Tuple!(string, string[]) a) => a[1].sort!debianPackageNumberLessThan()[0..$-1])
	 .array
	 .joiner;
}

int performGC(string path) {
	try {
		auto data = groupsOfFilesAt(path);
		auto deleteList = createDeleteList(data);
		foreach (name; deleteList) {
			chainPath(path, name).remove();
		}
		return 0;
	}
	catch (FileException fe) {
		writeln("Could not open: " ~ path);
		return 1;
	}
}


version(unittest) {

	unittest {

		foreach(Tuple!(string, string) item; [
																					// Check epochs
																					tuple("a_0:0.txt", "a_1:0.txt"),
																					tuple("a_0:0.txt", "a_0:1.txt"),
																					// Check general numbers.
																					tuple("a_0.txt", "a_1.txt"),
																					tuple("a_0.0.txt", "a_0.1.txt"),
																					tuple("a_0.0.0.txt", "a_0.0.1.txt"),
																					tuple("a_0.0.1.txt", "a_0.1.0.txt"),
																					tuple("a_0.1.0txt", "a_1.0.0.txt"),
																					tuple("a_0.0.9.txt", "a_0.0.10.txt"),
																					// Check debian revisions.
																					tuple("a_0-1.txt", "a_0-2.txt"),
																					tuple("a_0.0-1.txt", "a_0.0-2.txt"),
																					tuple("a_0.0.0-1.txt", "a_0.0.0-2.txt"),
																					tuple("a_0-9.txt", "a_0-10.txt"),
																					]) {
			assert(debianPackageNumberLessThan(item[0], item[1]), format("[%s, %s]", item[0], item[1]));
		}

	}
}
else {

	int main(string[] args) {
		performGC("/var/cache/approx");
		return 0;
	}

}
