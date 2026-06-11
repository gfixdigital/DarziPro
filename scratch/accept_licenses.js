const { spawn } = require('child_process');

console.log('Starting flutter doctor --android-licenses...');

const child = spawn('C:\\src\\flutter\\bin\\flutter.bat', ['doctor', '--android-licenses'], {
  shell: true
});

child.stdout.on('data', (data) => {
  const output = data.toString();
  process.stdout.write(output);
  
  if (output.includes('?') || output.includes('(y/N)') || output.includes('[y/N]')) {
    console.log('\n[Script] Sending "y"...');
    child.stdin.write('y\r\n');
  }
});

child.stderr.on('data', (data) => {
  process.stderr.write(data.toString());
});

child.on('close', (code) => {
  console.log(`\n[Script] Process exited with code ${code}`);
});
