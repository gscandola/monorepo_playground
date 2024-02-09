/*
Input:
[{"name":"pkg-a","version":"0.0.2-pre.3"},{"name":"pkg-b","version":"0.1.0-pre.1"}]

Output: ["pkg-a","pkg-b"]
*/

const jsonString = process.argv[2];
const data = JSON.parse(jsonString);

const packages = data.map((item) => item.name);

console.log(JSON.stringify(packages))
