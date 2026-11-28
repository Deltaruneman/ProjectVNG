// Runs only a disposable Godot copy; the server is loopback-only.
import {spawn} from 'node:child_process';
const [engine,project,label='suspend']=process.argv.slice(2);
if(!engine||!project||!project.includes('Temp'))throw Error('Supply engine and disposable Temp project');
let client,server,done=false;
const args=['--path',project,'--script','res://tests/scene_loading_suspend_check.gd'];
server=spawn(engine,['--headless',...args,'--log-file',project+'/'+label+'-server.log','--','--suspend-server'],{windowsHide:true});
let serverText='';server.stdout.on('data',chunk=>{const text=chunk.toString();serverText+=text;if(text.includes('NATIVE_'))process.stdout.write(text);if(serverText.includes('SUSPEND_SERVER_READY')&&!client){client=spawn(engine,['--rendering-method','gl_compatibility','--remote-debug','tcp://127.0.0.1:6179',...args,'--log-file',project+'/'+label+'-client.log',...(label.includes('before')?['--','--load-start-only']:[])],{windowsHide:true});client.stdout.on('data',c=>{const text=c.toString();if(/PASS |FAIL |RESULT/.test(text))process.stdout.write(text);});client.stderr.on('data',c=>{if(/Pause state|SCRIPT ERROR|Parse Error/.test(c.toString()))process.stdout.write(c);});client.on('exit',code=>{done=true;clearTimeout(timeout);server.kill();console.log('SUSPEND_CLIENT_EXIT',code);process.exitCode=code??1;});}});
server.stderr.on('data',c=>{if(/SCRIPT ERROR|Parse Error/.test(c.toString()))process.stdout.write(c);});
server.on('exit',code=>{if(!client&&!done){clearTimeout(timeout);process.exitCode=code||1;console.log('Server exited before client',code);}});
const timeout=setTimeout(()=>{server.kill();client?.kill();console.log('Suspend harness timed out');process.exitCode=2;},85000);
