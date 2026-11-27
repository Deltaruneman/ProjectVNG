// Local verification only: passively measure browser output; never resume or unmute it.
(() => {
 const Original = window.AudioContext || window.webkitAudioContext;
 if (!Original) return;
 const contexts = [];
 const originalConnect = AudioNode.prototype.connect;
 AudioNode.prototype.connect = function(target, ...args) {
   const record = contexts.find(r => target === r.context.destination);
   return originalConnect.call(this, record ? record.analyser : target, ...args);
 };
 class ObservedAudioContext extends Original {
   constructor(...args) {
     super(...args);
     const analyser = this.createAnalyser();
     analyser.fftSize = 2048;
     originalConnect.call(analyser,this.destination);
     contexts.push({context:this,analyser,peak:0});
   }
 }
 window.AudioContext = ObservedAudioContext;
 if (window.webkitAudioContext) window.webkitAudioContext = ObservedAudioContext;
 document.addEventListener('pointerdown',()=>contexts.forEach(r=>r.peak=0));
 setInterval(() => {
   for (const r of contexts) {
     const samples=new Float32Array(r.analyser.fftSize);
     r.analyser.getFloatTimeDomainData(samples);
     let peak=0;
     for(const s of samples) peak=Math.max(peak,Math.abs(s));
     r.peak=Math.max(r.peak,peak);
   }
   let display=document.getElementById('audio-test-output');
   if(!display && document.body){display=document.createElement('pre'); display.id='audio-test-output'; display.style='position:fixed;top:0;right:0;color:#fff;background:#000b;z-index:99999;pointer-events:none;font:12px monospace';document.body.appendChild(display);}
   if(display) display.textContent=contexts.map(r=>'AudioContext: '+r.context.state+' | output peak: '+r.peak.toFixed(5)).join('\n');
 },100);
})();
