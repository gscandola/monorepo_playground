/*
Input:
[{"name":"pkg-a","version":"0.0.2-pre.3"}]

Output: "pre-release" or "release"
*/

const jsonString = process.argv[2];
const data = JSON.parse(jsonString);

const type = data.some(item => item.version.match(/-pre\./)) ? 'pre-release' : 'release';

console.log(JSON.stringify(type))
