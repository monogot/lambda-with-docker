const { execFileSync } = require('child_process');
const fs = require('fs').promises;

exports.handler = async (event) => {
  const message = '[bold: on]This is bold text.[bold: off]';

  // Use /tmp directory for writing files
  const filePath = `/tmp/hello.stm`;
  await fs.writeFile(filePath, message);

  const data = await fs.readFile(filePath, { encoding: 'utf8', flag: 'r' });
  console.log(data);

  const parameters = [
    'decode',
    'application/vnd.star.starprnt',
    '/tmp/hello.stm',
    '/tmp/outputdata.bin',
  ];

  // const parameters = [
  //   'supportedinputs',
  // ]
  console.log("Hello world")

  const res = await execFileSync('./cputil-linux-x64/cputil', parameters);
  console.log(res);

  const response = {
    statusCode: 200,
    body: JSON.stringify('Hello from Lambda!'),
  };
  return response;
};
