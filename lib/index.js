//
//    Converts images applying the 'spiky-clouds' filter
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
const fs = require("fs");
const child_process = require("child_process");
const _cliProgress = require('cli-progress');

const VERSION = JSON.parse(fs.readFileSync("package.json")).version;
let VERBOSE = false;
const spikyClouds = (inputFile, outputFile, opts = {}) => {
  VERBOSE = "verbose" in opts && opts.verbose == true;
  delete opts.verbose;
  let optsArray = [];
  for (const opt in opts) {
    switch (opt) {
      case "alpha":
      case "seed":
      case "rotation":
      case "angles":
        optsArray.push(`-${opt}`);
        break;
      case "minLength":
      case "maxLength":
      case "minWidth":
      case "maxWidth":
        optsArray.push("-"+opt
          .replace(/([a-z])([A-Z])/g, '$1-$2')
          .toLowerCase());
        break;
    }
    if (Array.isArray(opts[opt])) {
      opts[opt] = opts[opt].join(", ");
    }
    optsArray.push(opts[opt]);
  }

  return new Promise((resolve, reject) => {
    let bar;
    if (VERBOSE) {
      console.log("Rendering...");
      bar = new _cliProgress.Bar({}, _cliProgress.Presets.shades_classic);
      bar.start(100, 0);
    }
    const process = child_process.spawn("xvfb-run",
      ["processing-java",
        "--sketch=/home/john/github/projs/spiky-clouds/lib/sketch",
        "--run",
        ...optsArray,
        inputFile,
        outputFile
      ], {
        detached: true,
      });
    process.stdout.on('data', (data) => {
      if (VERBOSE && data == parseInt(data)) {
        bar.update(parseInt(data));
      }
      if (!(
          data == parseInt(data) ||
          data.toString().includes("_JAVA_OPTIONS") ||
          data.toString().trim() == "Finished." ||
          data.toString().trim().length == 0)) {
        console.error("\n"+data.toString());
      }
      if (data.toString().includes("Exception")) {
        setTimeout(() => {
          // process.kill("SIGINT");
          // process.kill("SIGTERM");
          // process.kill("SIGKILL");
          // process.kill();
          // process.unref();
          // reject(new Error("Error Rendering"));  // I did my best
          child_process.spawn("killall", ["processing-java"]);
          throw new Error("Error Rendering");
        }, 1000);
      }
    });
    process.on('close', (code) => {
      if (VERBOSE) {
        bar.update(100);
        bar.stop();
        console.log("Done!");
      }
      resolve();
    });
  });
};

spikyClouds.VERSION = VERSION;
module.exports = spikyClouds;
