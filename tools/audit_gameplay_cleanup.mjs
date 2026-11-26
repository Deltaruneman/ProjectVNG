// Non-destructive dependency inventory for the retained gameplay roots.
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import cp from 'node:child_process';
const root = process.cwd();
const protectedDirs = new Set(['.git','.godot','.agents','.codex','.aws','.specify','.vscode','docs','specs']);
const files = [];
function walk(dir, prefix='') {
  for (const item of fs.readdirSync(dir,{withFileTypes:true})) {
    if (!prefix && protectedDirs.has(item.name)) continue;
    const rel=prefix+item.name;
    if(item.isSymbolicLink()) continue;
    if(item.isDirectory()) walk(path.join(dir,item.name),rel+'/');
    else files.push(rel);
  }
}
walk(root);
const available=new Set(files), canonical=new Map(files.map(f=>[f.toLowerCase(),f]));
const textExtensions=new Set(['.gd','.tscn','.tres','.meshlib','.gdshader','.gdshaderinc','.cfg','.godot','.dtl','.dch','.json','.gltf','.import','.uid','.mjs','.js']);
const resourceExtensions=new Set(['.gd','.tscn','.tres','.meshlib','.gdshader','.gdshaderinc','.png','.jpg','.jpeg','.webp','.svg','.ttf','.otf','.ogg','.wav','.mp3','.json','.gltf','.glb','.bin','.dtl','.dch','.cfg']);
const cache=new Map(), uidMap=new Map(), classes=new Map();
const ignoredPrefixes=files.filter(f=>f.endsWith('/.gdignore')).map(f=>f.slice(0,-9));
function read(f) { if(!cache.has(f))cache.set(f,fs.readFileSync(path.join(root,f),'utf8'));return cache.get(f); }
for(const f of files) {
  if(f.endsWith('.uid')) { const uid=read(f).trim();if(uid.startsWith('uid://'))uidMap.set(uid,f.slice(0,-4)); }
  else if(f.endsWith('.import')) { const uid=read(f).match(/^uid="(uid:\/\/[^"\r\n]+)"/m)?.[1];if(uid)uidMap.set(uid,f.slice(0,-7)); }
  else if(/\.(tscn|tres|meshlib)$/.test(f)) {
    const fd=fs.openSync(path.join(root,f),'r'),buf=Buffer.alloc(512);fs.readSync(fd,buf,0,512,0);fs.closeSync(fd);
    const uid=buf.toString('utf8').match(/^\[gd_(?:scene|resource)[^\r\n]*uid="(uid:\/\/[^"\r\n]+)"/)?.[1];if(uid)uidMap.set(uid,f);
  }
  if(f.endsWith('.gd')&&!ignoredPrefixes.some(prefix=>f.startsWith(prefix))) { const name=read(f).match(/^class_name\s+(\w+)/m)?.[1];if(name){if(!classes.has(name))classes.set(name,[]);classes.get(name).push(f);} }
}
const binaryPath='docs/validation/gameplay-cleanup-2026-11-26/binary-dependencies.json';
const binaryDeps=fs.existsSync(binaryPath)?JSON.parse(fs.readFileSync(binaryPath,'utf8')):{};
const keep=new Map(), edges=[], missing=[], dynamic=[], caseFallbacks=[];
const queue=[];
function add(f,reason,from='ROOT') {
  f=path.posix.normalize(f.replaceAll('\\','/'));
  if(f.startsWith('../')||path.posix.isAbsolute(f))return;
  if(!available.has(f)) { const corrected=canonical.get(f.toLowerCase());if(corrected){caseFallbacks.push({from,path:f,actual:corrected});f=corrected;}else{missing.push({from,path:f,reason});return;} }
  edges.push({from,to:f,reason});
  if(!keep.has(f)){keep.set(f,reason+' <- '+from);queue.push(f);}
}
function addReference(value,from,reason) {
  if(value.startsWith('uid://')) {const target=uidMap.get(value);if(from.startsWith('tests/')&&target&&/^levels\/level_1\/basement_b[12]\.tscn$/.test(target))return;if(target)add(target,reason,from);else missing.push({from,uid:value,reason});return;}
  if(!value.startsWith('res://'))return;
  value=value.replace(/\\+$/,'');
  let rel=value.slice(6);
  if(!rel.endsWith('/')&&fs.existsSync(path.join(root,rel))&&fs.statSync(path.join(root,rel)).isDirectory())rel+='/';
  if(rel.endsWith('/')&&available.has(rel.slice(0,-1))){add(rel.slice(0,-1),reason,from);return;}
  if(from.startsWith('tests/')&&rel.startsWith('levels/level_1/')&&rel.endsWith('.tscn')&&!['basement_full','basement_b3','garden','castle'].some(name=>rel==='levels/level_1/'+name+'.tscn'))return;
  if(from==='addons/dialogic/Editor/Common/update_manager.gd'&&rel==='addons/')return;
  if(from.startsWith('tests/')&&(rel.endsWith('/')||rel.includes('%'))){
    rel=rel.slice(0,rel.lastIndexOf('/')+1);
    if(rel==='levels/level_1/')for(const scene of ['basement_full','basement_b3','garden','castle'])add('levels/level_1/'+scene+'.tscn','current map test matrix',from);
    else for(const file of files.filter(file=>file.startsWith(rel)&&keep.has(file)))add(file,'test dynamic dependency already used by gameplay',from);
    return;
  }
  if(rel.includes('%')||rel.includes('{')||rel.includes('*'))rel=rel.slice(0,Math.min(...['%','{','*'].map(c=>rel.indexOf(c)).filter(n=>n>=0)));
  if(available.has(rel)){add(rel,reason,from);return;}
  const prefix=rel.endsWith('/')?rel:rel.slice(0,rel.lastIndexOf('/')+1);
  if((rel.endsWith('/')||value.includes('%')||value.includes('{')||value.includes('*'))&&prefix){
    const matched=files.filter(f=>f.startsWith(prefix)&&resourceExtensions.has(path.extname(f).toLowerCase())&&!/\.tmp$/i.test(f));
    dynamic.push({from,prefix,count:matched.length});for(const f of matched)add(f,'dynamic-directory:'+prefix,from);return;
  }
  add(rel,reason,from);
}
const roots=['levels/level_1/basement_full.tscn','levels/level_1/basement_b3.tscn','levels/level_1/garden.tscn','levels/level_1/castle.tscn','project.godot','export_presets.cfg','icon.svg'];
for(const f of roots)add(f,'gameplay/config root');
for(const f of files.filter(f=>f.endsWith('/.gdignore')))add(f,'preserve existing Godot import boundary');
for(const f of ['assets/meshes/basement_library.tscn','assets/meshes/forest_library.tscn','tools/build_basement_library.gd','tools/build_forest_library.gd','tools/export_elemental_orbs.mjs'])if(available.has(f))add(f,'authoring source for retained gameplay resources');
// The installed project skill explicitly uses this VFX authoring library.
for(const f of files.filter(f=>f.startsWith('assets/vendor/pixelfx-main/')))add(f,'existing project pixelfx authoring library');
// Dialogic loads subsystems and editor resources by convention rather than static paths.
for(const f of files.filter(f=>f.startsWith('addons/dialogic/')))add(f,'active Dialogic plugin/autoload');
// Retain regression coverage that exercises retained shared gameplay, never mark tests
// disposable merely because they are not reachable from the shipped main scene.
const retainedTests=['basement_full_check','basement_walk_test','darkfairy_arena','skeleton_test','arcane_enemies_test','basement_integration_check','basement_checkpoint_check','basement_story_loot_check','basement_b3_check','elemental_orb_test','exp_progression_check','fixed_action_camera_check','secret_room_walls_check','wall_occlusion_check','torch_resource_check','presentation_audio_check','world_interactions_check','garden_combat_potions_check','garden_poison_potion_check','inventory_check','low_throw_check','parry_test','quick_item_hud_check','settings_menu_check','skill_tree_menu_check','topdown_weapon_depth_check','weapon_combo_check','weapon_presentation_check','world_vfx_anchor_check'];
for(const fixture of ['crab/crab','crab/barrel','mushroom/mushroom','starfish/starfish','skeleton/skeleton_warrior','skeleton/skeleton_mage','pelican/pelican']){const f='scenes/enemies/'+fixture+'.tscn';if(available.has(f))add(f,'existing parry/combat fixture dependency');}
for(const stem of retainedTests)for(const f of files.filter(f=>f.startsWith('tests/'+stem+'.')))add(f,'related gameplay regression');
for(let index=0;index<queue.length;index++) {
  const f=queue[index];
  for(const suffix of ['.uid','.import'])if(available.has(f+suffix))add(f+suffix,'resource identity/import sidecar',f);
  for(const dep of binaryDeps[f]||[]){if(dep.resolved)addReference(dep.resolved,f,'Godot binary dependency');else addReference(dep.raw.split('::')[0],f,'Godot binary dependency UID');}
  const ext=path.extname(f).toLowerCase();
  if(ext==='.glb'){const buf=fs.readFileSync(path.join(root,f));if(buf.length>20&&buf.toString('ascii',0,4)==='glTF'){try{const data=JSON.parse(buf.toString('utf8',20,20+buf.readUInt32LE(12)).replace(/\0+$/,''));for(const item of [...(data.buffers||[]),...(data.images||[])])if(item.uri&&!item.uri.startsWith('data:'))add(path.posix.join(path.posix.dirname(f),decodeURIComponent(item.uri)),'relative GLB resource',f);}catch(error){missing.push({from:f,reason:'GLB JSON: '+error.message});}}}
  if(!textExtensions.has(ext))continue;
  let text=read(f);
  // Source import metadata points into .godot; the tracked cache is preserved separately.
  if(ext==='.import'||ext==='.uid')continue;
  if(f==='scripts/autoload/game_manager.gd')text=text.replace(/const LEGACY_BASEMENT_CHECKPOINTS := \{[\s\S]*?\n\}/,'');
  for(const line of text.split(/\r?\n/)) {
    if(ext==='.gd'&&line.trim().startsWith('#'))continue;
    const pathOnExt=line.includes('[ext_resource')&&line.match(/path="(res:\/\/[^"\r\n]+)"/)?.[1];
    if(pathOnExt){addReference(pathOnExt,f,'resource reference');continue;}
    for(const match of line.matchAll(/["'](\*?(?:res|uid):\/\/[^"'\r\n]+)["']/g))addReference(match[1].replace(/^\*/,''),f,'literal resource/load path');
  }
  if(ext==='.gd') {
    for(const [name,targets] of classes)if(new RegExp('\\b'+name+'\\b').test(text))for(const target of targets)add(target,'global GDScript class '+name,f);
  }
  if(ext==='.gltf') {
    try{const gltf=JSON.parse(text);for(const item of [...(gltf.buffers||[]),...(gltf.images||[])])if(item.uri&&!item.uri.startsWith('data:'))add(path.posix.join(path.posix.dirname(f),decodeURIComponent(item.uri)),'relative glTF resource',f);}catch(error){missing.push({from:f,reason:'glTF parse: '+error.message});}
  }
  if(ext==='.gdshader'||ext==='.gdshaderinc')for(const match of text.matchAll(/#include\s+"([^"\r\n]+)"/g))if(!match[1].startsWith('res://'))add(path.posix.join(path.posix.dirname(f),match[1]),'relative shader include',f);
}
// Package attribution remains associated with any retained assets.
for(const f of files)if(/(?:^|\/)(?:license[^/]*|copying[^/]*|copyright[^/]*|credits[^/]*|attribution[^/]*|readme[^/]*)$/i.test(f)) {
  const parent=path.posix.dirname(f)+'/';if([...keep.keys()].some(k=>k.startsWith(parent)))add(f,'attribution for retained package');
}
const dirty=cp.execFileSync('git',['status','--porcelain=v1','--untracked-files=all','-z'],{cwd:root,maxBuffer:16*1024*1024}).toString().split('\0').filter(Boolean).map(s=>s.slice(3).replaceAll('\\','/'));
const tracked=new Set(cp.execFileSync('git',['ls-files','-z'],{cwd:root,maxBuffer:16*1024*1024}).toString().split('\0').filter(Boolean));
function category(f) {
 if(/(?:^|\/)__MACOSX(?:\/|$)|(?:^|\/)\._|\.tmp$/i.test(f))return 'editor temporary/platform duplicate';
 if(f.startsWith('levels/'))return 'unreached scene or map helper';
 if(f.startsWith('tests/'))return 'historical/demo regression candidate: manual review';
 if(f.startsWith('tools/'))return 'authoring utility candidate: manual review';
 if(f.startsWith('assets/'))return 'unreached art/audio/vendor resource';
 if(f.startsWith('addons/'))return 'inactive/unreached addon';
 if(/^(scenes|scripts|ui)\//.test(f))return 'unreached gameplay/component candidate';
 return 'project metadata: preserve/manual review';
}
const candidates=files.filter(f=>!keep.has(f)&&f!=='tools/audit_gameplay_cleanup.mjs').map(f=>({path:f,bytes:fs.statSync(path.join(root,f)).size,tracked:tracked.has(f),dirty:dirty.includes(f),reason:category(f)}));
const byCategory={};for(const item of candidates){const value=byCategory[item.reason]??={files:0,bytes:0,dirty:0};value.files++;value.bytes+=item.bytes;if(item.dirty)value.dirty++;}
const report={created:'2026-11-26',mode:'AUDIT ONLY; no files deleted',roots,inventoryFiles:files.length,retainedFiles:keep.size,candidateFiles:candidates.length,byCategory,dynamic,missing,caseFallbacks,retained:[...keep].map(([path,reason])=>({path,reason})),candidates};
const out='docs/validation/gameplay-cleanup-2026-11-26';fs.mkdirSync(out,{recursive:true});fs.writeFileSync(out+'/dependency-audit.json',JSON.stringify(report,null,2)+'\n');fs.writeFileSync(out+'/retained-paths.txt',[...keep.keys()].sort().join('\n')+'\n');fs.writeFileSync(out+'/candidate-paths.txt',candidates.map(x=>x.path).sort().join('\n')+'\n');
console.log(JSON.stringify({inventoryFiles:files.length,retainedFiles:keep.size,candidateFiles:candidates.length,byCategory,dynamic,missing:missing.slice(0,30),missingCount:missing.length,caseFallbackCount:caseFallbacks.length},null,2));
