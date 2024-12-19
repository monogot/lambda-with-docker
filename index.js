const { execFileSync } = require('child_process');
const fs = require('fs').promises;

exports.handler = async (event) => {
  const message = '[bold: on]This is bold text.[bold: off]';

  const filePath = `hello.stm`;
  await fs.writeFile(filePath, message);

  const data = await fs.readFile(filePath, { encoding: 'utf8', flag: 'r' });
  console.log(data);

  const parameters = [
    'decode',
    'application/vnd.star.starprnt',
    'hello.stm',
    'outputdata.bin',
  ];

  const res = await execFileSync('/opt/cputil-linux-x64/cputil', parameters);
  console.log(res);

  const response = {
    statusCode: 200,
    body: JSON.stringify('Hello from Lambda!'),
  };
  return response;
};
