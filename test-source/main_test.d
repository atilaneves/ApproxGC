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

import std.algorithm: map, sort;
import std.array: array, join;
import std.conv: to;
import std.file: dirEntries, mkdir, rmdirRecurse, tempDir, write, SpanMode;
import std.path: baseName, chainPath;
import std.process: thisProcessID, thisThreadID;

import unit_threaded;

import main: performGC;

void writeFilesProcessAndCheckResult(string[] filenames, string[] result, uint depth) {
	auto location = to!string(chainPath(tempDir(), "approx-gc_" ~ to!string(thisProcessID()) ~ "_" ~ to!string(thisThreadID())).array);
	location.mkdir();
	scope (exit) { location.rmdirRecurse(); }
	foreach (name; filenames) {
		write(chainPath(location, name).array, "blah, blah, blah");
	}
	auto startState = dirEntries(location, SpanMode.shallow).map!(a => a.baseName).array.sort();
	auto filenamesSorted = filenames.sort();
	assert(startState == filenamesSorted, startState.join(", ") ~ " == " ~ filenamesSorted.join(", "));
	performGC(location, depth);
	auto endState = dirEntries(location, SpanMode.shallow).map!(a => a.baseName).array.sort();
	auto resultSorted = result.sort();
	assert(endState == resultSorted, endState.join(", ") ~ " == " ~ resultSorted.join(", "));
}

@("check an empty dataset depth one") unittest {
	writeFilesProcessAndCheckResult([], [], 1);
}

@("check an empty dataset depth two") unittest {
	writeFilesProcessAndCheckResult([], [], 2);
}

@("check a single entry dataset depth one") unittest {
		writeFilesProcessAndCheckResult(["a_0.0.1.txt"], ["a_0.0.1.txt"], 1);
}

@("check a single entry dataset depth two") unittest {
		writeFilesProcessAndCheckResult(["a_0.0.1.txt"], ["a_0.0.1.txt"], 2);
}


@("check a two entry dataset depth one") unittest {
	writeFilesProcessAndCheckResult(["a_0.0.0.txt", "a_0.0.1.txt"], ["a_0.0.1.txt"], 1);
}

@("check a two entry dataset depth two") unittest {
		writeFilesProcessAndCheckResult(["a_0.0.0.txt", "a_0.0.1.txt"], ["a_0.0.0.txt", "a_0.0.1.txt"], 2);
}

@("check a three entry dataset depth one") unittest {
	writeFilesProcessAndCheckResult(["a_0.0.0.txt", "a_0.0.1.txt", "a_0.0.2.txt"], ["a_0.0.2.txt"], 1);
}

@("check a three entry dataset depth two") unittest {
	writeFilesProcessAndCheckResult(["a_0.0.0.txt", "a_0.0.1.txt", "a_0.0.2.txt"], ["a_0.0.1.txt", "a_0.0.2.txt"], 2);
}

@("check a simple data set needed pruning") unittest {
	writeFilesProcessAndCheckResult(
																	["a_1.0.0.txt", "a_1.0.1.txt", "a_1.1.0.txt", "b_1.0.0.txt", "b_1.0.2.txt", "b_1.2.1.txt"],
																	["a_1.1.0.txt", "b_1.2.1.txt"],
																	1,
	);
}

@("check a simple data set needed pruning depth two") unittest {
	writeFilesProcessAndCheckResult(
																	["a_1.0.0.txt", "a_1.0.1.txt", "a_1.1.0.txt", "b_1.0.0.txt", "b_1.0.2.txt", "b_1.2.1.txt"],
																	["a_1.0.1.txt", "a_1.1.0.txt", "b_1.0.2.txt", "b_1.2.1.txt"],
																	2,
																	);
}

@("check another data set needed pruning depth two") unittest {
	writeFilesProcessAndCheckResult(
																	["a_1.1.0.txt", "b_1.0.0.txt", "b_1.0.2.txt", "b_1.2.1.txt"],
																	["a_1.1.0.txt", "b_1.0.2.txt", "b_1.2.1.txt"],
																	2,
																	);
}

@("check a simple data set needed no pruning") unittest {
	writeFilesProcessAndCheckResult(
																	["a_1.1.0.txt", "b_1.2.1.txt"],
																	["a_1.1.0.txt", "b_1.2.1.txt"],
																	1,
																	);
}

@("a real example, depth 1") unittest {
	writeFilesProcessAndCheckResult(
																	["gir1.2-mutter-3.0_3.20.2-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.2-3_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	["gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	1,
																	);
}

@("a real example, depth 2") unittest {
	writeFilesProcessAndCheckResult(
																	["gir1.2-mutter-3.0_3.20.2-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.2-3_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	["gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	2,
																	);
}

@("a real example, depth 3") unittest {
	writeFilesProcessAndCheckResult(
																	["gir1.2-mutter-3.0_3.20.2-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.2-3_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	["gir1.2-mutter-3.0_3.22.3-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	3,
																	);
}

@("a real example, depth 4") unittest {
	writeFilesProcessAndCheckResult(
																	["gir1.2-mutter-3.0_3.20.2-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.2-3_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	["gir1.2-mutter-3.0_3.22.2-3_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	4,
																	);
}

@("a real example, depth 5") unittest {
	writeFilesProcessAndCheckResult(
																	["gir1.2-mutter-3.0_3.20.2-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.2-3_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	["gir1.2-mutter-3.0_3.20.2-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.2-3_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	5,
																	);
}

@("a real example, depth 6") unittest {
	writeFilesProcessAndCheckResult(
																	["gir1.2-mutter-3.0_3.20.2-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.2-3_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	["gir1.2-mutter-3.0_3.20.2-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.2-3_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-1_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.3-2_amd64.deb",
																	 "gir1.2-mutter-3.0_3.22.4-1_amd64.deb",],
																	6,
																	);
}
