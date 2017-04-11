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

module main_test;

import std.algorithm: map, sort;
import std.array: array, join;
import std.conv: to;
import std.file: dirEntries, mkdir, rmdirRecurse, tempDir, write, SpanMode;
import std.path: baseName, chainPath;

import main: performGC;

void writeFilesProcessAndCheckResult(string[] filenames, string[] result) {
	auto location = to!string(chainPath(tempDir(), "approx-gc").array);
	location.mkdir();
	scope (exit) { location.rmdirRecurse(); }
	foreach (name; filenames) {
		write(chainPath(location, name).array, "blah, blah, blah");
	}
	auto startState = dirEntries(location, SpanMode.shallow).map!(a => a.baseName).array.sort();
	auto filenamesSorted = filenames.sort();
	assert(startState == filenamesSorted, startState.join(", ") ~ " == " ~ filenamesSorted.join(", "));
	performGC(location);
	auto endState = dirEntries(location, SpanMode.shallow).map!(a => a.baseName).array.sort();
	auto resultSorted = result.sort();
	assert(endState == resultSorted, endState.join(", ") ~ " == " ~ resultSorted.join(", "));
}


void checkASimpleDataSetNeededPruning() {
	writeFilesProcessAndCheckResult([
																	 "a_1.0.0.txt",
																	 "a_1.0.1.txt",
																	 "a_1.1.0.txt",
																	 "b_1.0.0.txt",
																	 "b_1.0.2.txt",
																	 "b_1.2.1.txt",
																	 ], [
																			 "a_1.1.0.txt",
																			 "b_1.2.1.txt",
																			 ]
																	);
}

void checkASimpleDataSetNeededNoPruning() {
	writeFilesProcessAndCheckResult([
																	 "a_1.1.0.txt",
																	 "b_1.2.1.txt",
																	 ], [
																			 "a_1.1.0.txt",
																			 "b_1.2.1.txt",
																			 ]
																	);
}

void checkAnEmptyDataset() {
	writeFilesProcessAndCheckResult([], []);
}

int main(string[] args) {

	checkASimpleDataSetNeededPruning();
	checkASimpleDataSetNeededNoPruning();
	checkAnEmptyDataset();

	return 0;
}
