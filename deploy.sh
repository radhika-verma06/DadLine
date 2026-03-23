#!/bin/bash
set -e
B=~/papa-app

echo "📁 Creating folders..."
mkdir -p $B/src/screens $B/src/components $B/src/db $B/public

echo "📦 Installing packages..."
cd $B && npm install dexie dexie-react-hooks 2>&1 | tail -3

echo "📝 Writing all source files..."

# ── index.html ────────────────────────────────────────────────────────────────
cat > $B/index.html << 'X'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover" />
    <meta name="theme-color" content="#060E16" />
    <meta name="apple-mobile-web-app-capable" content="yes" />
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
    <meta name="apple-mobile-web-app-title" content="Papa" />
    <link rel="manifest" href="/manifest.json" />
    <title>Papa ✦</title>
  </head>
  <body><div id="root"></div><script type="module" src="/src/main.jsx"></script></body>
</html>
X

# ── manifest ──────────────────────────────────────────────────────────────────
cat > $B/public/manifest.json << 'X'
{"name":"Papa — Your Companion","short_name":"Papa","start_url":"/","display":"standalone","background_color":"#060E16","theme_color":"#060E16","orientation":"portrait","icons":[{"src":"/icon.png","sizes":"512x512","type":"image/png","purpose":"any maskable"}]}
X

# ── vite.config.js ────────────────────────────────────────────────────────────
cat > $B/vite.config.js << 'X'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({ plugins: [react()] })
X

# ── main.jsx ──────────────────────────────────────────────────────────────────
cat > $B/src/main.jsx << 'X'
import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'
createRoot(document.getElementById('root')).render(<StrictMode><App /></StrictMode>)
X

# ── index.css ─────────────────────────────────────────────────────────────────
cat > $B/src/index.css << 'X'
@import url('https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&display=swap');
:root{--gold:#C8962A;--gold-light:#F0C866;--midnight:#060E16;--navy:#0D1B2A;--text-1:#EEE8D5;--text-2:#C8C0B0;--text-3:#8A8070;--success:#4CAF82;--warning:#E8855A;--info:#6496E8}
*,*::before,*::after{box-sizing:border-box;-webkit-tap-highlight-color:transparent;margin:0;padding:0}
html{height:100%;overflow:hidden}
body{height:100%;overflow:hidden;background:var(--midnight);color:var(--text-1);font-family:'DM Sans',-apple-system,sans-serif;-webkit-font-smoothing:antialiased;overscroll-behavior:none}
#root{height:100%;display:flex;flex-direction:column}
.scroll-y{overflow-y:auto;-webkit-overflow-scrolling:touch;overscroll-behavior-y:contain}
::-webkit-scrollbar{display:none}
@keyframes breathe{0%,100%{transform:scaleY(1) scaleX(1)}50%{transform:scaleY(1.013) scaleX(0.999)}}
.breathe{animation:breathe 4.5s ease-in-out infinite;transform-origin:bottom center}
@keyframes ring-pulse{0%,100%{opacity:.35;transform:scale(1)}50%{opacity:.8;transform:scale(1.05)}}
.ring-pulse{animation:ring-pulse 4s ease-in-out infinite}
.ring-pulse-2{animation:ring-pulse 4s ease-in-out infinite;animation-delay:.55s}
@keyframes page-in{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:translateY(0)}}
.page-in{animation:page-in .3s cubic-bezier(.22,1,.36,1)}
@keyframes pop{0%{transform:scale(.92);opacity:0}70%{transform:scale(1.04)}100%{transform:scale(1);opacity:1}}
.pop{animation:pop .35s cubic-bezier(.34,1.56,.64,1)}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-5px)}}
.float{animation:float 5s ease-in-out infinite}
@keyframes slide-up{from{transform:translateY(100%);opacity:0}to{transform:translateY(0);opacity:1}}
.slide-up{animation:slide-up .32s cubic-bezier(.22,1,.36,1)}
X

echo "  ✓ base files"

# ── db/db.js ──────────────────────────────────────────────────────────────────
cat > $B/src/db/db.js << 'X'
import Dexie from 'dexie'
export const db = new Dexie('PapaAppDB')
db.version(1).stores({
  tasks:'++id,title,dueDate,priority,category,isCompleted,completedAt,reminder,notes,createdAt',
  notes:'++id,title,body,colour,createdAt,updatedAt',
  routine:'++id,title,timeSlot,time,isCompleted,completedDate',
  progress:'++id,date,tasksCompleted,tasksTotal',
  settings:'key',
})
db.on('ready',async()=>{
  const c=await db.routine.count()
  if(c===0)await db.routine.bulkAdd([
    {title:'Morning walk',timeSlot:'morning',time:'07:00',isCompleted:false,completedDate:null},
    {title:'Breakfast + Meds',timeSlot:'morning',time:'08:00',isCompleted:false,completedDate:null},
    {title:'Read newspaper',timeSlot:'afternoon',time:'14:00',isCompleted:false,completedDate:null},
    {title:'Rest / Nap',timeSlot:'afternoon',time:'15:00',isCompleted:false,completedDate:null},
    {title:'Family call',timeSlot:'evening',time:'19:00',isCompleted:false,completedDate:null},
    {title:'Bedtime routine',timeSlot:'evening',time:'21:30',isCompleted:false,completedDate:null},
  ])
})
export const todayStr=()=>new Date().toISOString().split('T')[0]
export async function getStreak(){
  const records=await db.progress.orderBy('date').reverse().limit(60).toArray()
  if(!records.length)return 0
  let streak=0,check=new Date();check.setHours(0,0,0,0)
  for(const r of records){const d=new Date(r.date);d.setHours(0,0,0,0);if(d.getTime()===check.getTime()&&r.tasksCompleted>0){streak++;check.setDate(check.getDate()-1)}else break}
  return streak
}
export async function getSetting(key,fallback=null){const row=await db.settings.get(key);return row?row.value:fallback}
export async function setSetting(key,value){await db.settings.put({key,value})}
X

echo "  ✓ db"

# ── TabBar ────────────────────────────────────────────────────────────────────
cat > $B/src/components/TabBar.jsx << 'X'
const TABS=[{id:'home',label:'Home',icon:'🏠'},{id:'tasks',label:'Tasks',icon:'✅'},{id:'routine',label:'Routine',icon:'🌅'},{id:'notes',label:'Notes',icon:'📝'},{id:'progress',label:'Progress',icon:'📊'}]
export default function TabBar({active,onChange}){
  return(
    <nav style={{flexShrink:0,background:'rgba(6,14,22,0.97)',borderTop:'1px solid rgba(200,150,42,0.15)',paddingBottom:'env(safe-area-inset-bottom,12px)',display:'flex',justifyContent:'space-around',alignItems:'center',paddingTop:8}}>
      {TABS.map(t=>(
        <button key={t.id} onClick={()=>onChange(t.id)} style={{flex:1,background:'none',border:'none',cursor:'pointer',display:'flex',flexDirection:'column',alignItems:'center',gap:2,padding:'4px 0',WebkitTapHighlightColor:'transparent'}}>
          <span style={{fontSize:20,opacity:active===t.id?1:0.38}}>{t.icon}</span>
          <span style={{fontSize:9.5,fontWeight:600,fontFamily:'inherit',color:active===t.id?'#C8962A':'rgba(200,150,42,0.38)',transition:'color .2s'}}>{t.label}</span>
        </button>
      ))}
    </nav>
  )
}
X

echo "  ✓ TabBar"

# ── PapaAvatar ────────────────────────────────────────────────────────────────
cat > $B/src/components/PapaAvatar.jsx << 'X'
import { useEffect, useRef, useState } from 'react'

export default function PapaAvatar({ state = 'calm', size = 180, showRings = true }) {
  const [eyeOpen, setEyeOpen] = useState(true)
  const timerRef = useRef(null)

  useEffect(() => {
    if (state !== 'calm') { setEyeOpen(true); return }
    const schedule = () => {
      timerRef.current = setTimeout(() => {
        setEyeOpen(false)
        setTimeout(() => { setEyeOpen(true); schedule() }, 210)
      }, 5000 + Math.random() * 2500)
    }
    schedule()
    return () => clearTimeout(timerRef.current)
  }, [state])

  const isHappy   = state === 'happy' || state === 'celebrating'
  const isConcern = state === 'concern'
  const eyeRY     = isHappy ? 8 : !eyeOpen ? 1.5 : 11
  const leftBrow  = isConcern ? 'M68 89 Q76 95 96 86' : isHappy ? 'M68 84 Q82 79 96 82' : 'M68 87 Q82 83 96 85'
  const rightBrow = isConcern ? 'M134 86 Q154 95 162 89' : isHappy ? 'M134 82 Q148 79 162 84' : 'M134 85 Q148 83 162 87'
  const mouthPath = isHappy   ? 'M92 143 Q104 152 115 154 Q126 152 138 143'
                  : isConcern ? 'M94 148 Q104 145 115 144 Q126 145 136 148'
                  :             'M96 147 Q106 153 115 154 Q124 153 134 147'
  const blushOp   = isHappy ? 0.7 : 0.1
  const ringC     = isHappy ? '76,175,130' : isConcern ? '232,133,90' : '200,150,42'
  const bgC1      = isHappy ? '#193218' : isConcern ? '#180E04' : '#0D1B2A'
  const bgC2      = isHappy ? '#0c1e0c' : isConcern ? '#0A0804' : '#080F18'
  const uid       = state + size

  return (
    <div style={{position:'relative',width:size,height:size,display:'flex',alignItems:'center',justifyContent:'center',flexShrink:0}}>
      {showRings && <>
        <div className="ring-pulse" style={{position:'absolute',borderRadius:'50%',border:`1px solid rgba(${ringC},0.32)`,width:size+22,height:size+22,pointerEvents:'none'}}/>
        <div className="ring-pulse-2" style={{position:'absolute',borderRadius:'50%',border:`1px solid rgba(${ringC},0.13)`,width:size+40,height:size+40,pointerEvents:'none'}}/>
      </>}
      <div style={{position:'absolute',borderRadius:'50%',width:size*0.8,height:size*0.8,background:`radial-gradient(circle,rgba(${ringC},0.18) 0%,transparent 70%)`,pointerEvents:'none'}}/>
      <div style={{width:size,height:size,borderRadius:'50%',overflow:'hidden',position:'relative',border:`2px solid rgba(${ringC},0.45)`,boxShadow:`0 0 32px rgba(${ringC},0.18)`}}>
        <svg width={size} height={size} viewBox="0 0 230 230" className={state==='calm'?'breathe':''} style={{display:'block'}}>
          <defs>
            <radialGradient id={`bg${uid}`} cx="50%" cy="35%" r="70%">
              <stop offset="0%" stopColor={bgC1}/>
              <stop offset="55%" stopColor={bgC2}/>
              <stop offset="100%" stopColor="#060E16"/>
            </radialGradient>
            <radialGradient id={`sk${uid}`} cx="44%" cy="28%" r="64%">
              <stop offset="0%" stopColor="#C07848"/>
              <stop offset="55%" stopColor="#9A5820"/>
              <stop offset="100%" stopColor="#7A3E10"/>
            </radialGradient>
            <radialGradient id={`fg${uid}`} cx="50%" cy="5%" r="85%">
              <stop offset="0%" stopColor="#C87840" stopOpacity=".45"/>
              <stop offset="100%" stopColor="#C87840" stopOpacity="0"/>
            </radialGradient>
            <radialGradient id={`bl${uid}`} cx="50%" cy="50%" r="55%">
              <stop offset="0%" stopColor="#B84020" stopOpacity=".65"/>
              <stop offset="100%" stopColor="#B84020" stopOpacity="0"/>
            </radialGradient>
            <radialGradient id={`ey${uid}`} cx="40%" cy="35%" r="60%">
              <stop offset="0%" stopColor="#2A1810"/>
              <stop offset="50%" stopColor="#1A0C06"/>
              <stop offset="100%" stopColor="#080402"/>
            </radialGradient>
          </defs>

          <rect width="230" height="230" fill={`url(#bg${uid})`}/>
          <circle cx="32" cy="42" r="2.2" fill="#F0C866" opacity=".6"><animate attributeName="opacity" values=".3;.9;.3" dur="2.3s" repeatCount="indefinite"/></circle>
          <circle cx="196" cy="54" r="1.7" fill="#F0C866" opacity=".4"><animate attributeName="opacity" values=".2;.7;.2" dur="3s" begin=".7s" repeatCount="indefinite"/></circle>
          {isHappy&&<><line x1="45" y1="56" x2="45" y2="65" stroke="#F0C866" strokeWidth="2" opacity=".85"/><line x1="40.5" y1="60.5" x2="49.5" y2="60.5" stroke="#F0C866" strokeWidth="2" opacity=".85"/><line x1="184" y1="42" x2="184" y2="49" stroke="#F0C866" strokeWidth="1.6" opacity=".65"/><line x1="180.5" y1="45.5" x2="187.5" y2="45.5" stroke="#F0C866" strokeWidth="1.6" opacity=".65"/></>}
          <ellipse cx="115" cy="222" rx="72" ry="11" fill={isHappy?'#4CAF82':isConcern?'#E8855A':'#C8962A'} fillOpacity=".07"/>
          <path d="M30 230 Q48 182 78 168 Q115 158 152 168 Q182 182 200 230 Z" fill="#161616"/>
          <line x1="108" y1="170" x2="104" y2="205" stroke="#222" strokeWidth="2" strokeLinecap="round"/>
          <line x1="122" y1="170" x2="126" y2="205" stroke="#222" strokeWidth="2" strokeLinecap="round"/>
          <path d="M62 230 Q70 190 85 176 Q115 166 145 176 Q160 190 168 230 Z" fill="#232323"/>
          <path d="M85 182 Q115 176 145 182" stroke="#2e2e2e" strokeWidth="1.2" fill="none"/>
          <path d="M82 195 Q115 188 148 195" stroke="#2e2e2e" strokeWidth="1.2" fill="none"/>
          <path d="M81 207 Q115 200 149 207" stroke="#2e2e2e" strokeWidth="1.2" fill="none"/>
          <line x1="115" y1="169" x2="115" y2="230" stroke="#3a3a3a" strokeWidth="2"/>
          <path d="M95 163 Q115 158 135 163 L133 173 Q115 169 97 173 Z" fill="#141414"/>
          <rect x="60" y="198" width="14" height="10" rx="2.5" fill="#1e1e1e" stroke="#444" strokeWidth=".8"/>
          <rect x="62" y="200" width="10" height="6" rx="1.5" fill="#1A3A5A"/>
          <path d={`M97 148 Q115 154 133 148 L136 168 Q115 174 94 168 Z`} fill={`url(#sk${uid})`}/>
          <ellipse cx="115" cy="105" rx="62" ry="64" fill={`url(#sk${uid})`}/>
          <ellipse cx="57"  cy="117" rx="14" ry="16" fill={`url(#sk${uid})`}/>
          <ellipse cx="173" cy="117" rx="14" ry="16" fill={`url(#sk${uid})`}/>
          <ellipse cx="115" cy="65"  rx="46" ry="22" fill={`url(#fg${uid})`}/>
          <ellipse cx="53"    cy="111" rx="10" ry="14" fill="#9A5820"/>
          <ellipse cx="54.5"  cy="111" rx="6.5" ry="9" fill="#7A3E10"/>
          <ellipse cx="177"   cy="111" rx="10" ry="14" fill="#9A5820"/>
          <ellipse cx="175.5" cy="111" rx="6.5" ry="9" fill="#7A3E10"/>
          <ellipse cx="177" cy="105" rx="3.5" ry="5" fill="#F0F0F0" opacity=".88"/>
          <ellipse cx="177" cy="109" rx="2.5" ry="3" fill="#E0E0E0" opacity=".8"/>
          <path d="M55 88 Q58 38 115 32 Q172 38 175 88 Q170 56 115 52 Q60 56 55 88 Z" fill="#1E1608"/>
          <path d="M55 88 Q53 76 61 64 Q68 56 76 60 Q65 68 63 86 Z" fill="#1E1608"/>
          <path d="M175 88 Q177 76 169 64 Q162 56 154 60 Q165 68 167 86 Z" fill="#1E1608"/>
          <ellipse cx="71"  cy="68" rx="11" ry="7.5" fill={`url(#sk${uid})`} fillOpacity=".55"/>
          <ellipse cx="159" cy="68" rx="11" ry="7.5" fill={`url(#sk${uid})`} fillOpacity=".55"/>
          <ellipse cx="115" cy="42" rx="38" ry="14" fill="#181408" fillOpacity=".68"/>
          <path d="M82 46 Q115 40 148 46" stroke="rgba(255,255,255,.07)" strokeWidth="2" fill="none"/>
          <path d={leftBrow}  stroke="#1E1208" strokeWidth="3.8" fill="none" strokeLinecap="round"/>
          <path d={rightBrow} stroke="#1E1208" strokeWidth="3.8" fill="none" strokeLinecap="round"/>
          {isConcern&&<><line x1="109" y1="85" x2="111" y2="93" stroke="#7A3E08" strokeWidth="1.3" opacity=".5"/><line x1="121" y1="85" x2="119" y2="93" stroke="#7A3E08" strokeWidth="1.3" opacity=".5"/></>}
          {[82,148].map((cx,i)=>(
            <g key={i}>
              <ellipse cx={cx} cy="104" rx="14" ry={eyeRY} fill={`url(#ey${uid})`}/>
              <ellipse cx={cx} cy="104" rx="9" ry={Math.max(eyeRY-3,1)} fill="#140A04"/>
              <circle cx={cx} cy="104" r="5.5" fill="#060200"/>
              <circle cx={cx+3.5} cy="100.5" r="3.8" fill="white" opacity=".93"/>
              <circle cx={cx-2} cy="106.5" r="1.6" fill="white" opacity=".35"/>
              <path d={`M${cx-13} 100 Q${cx} ${isHappy?95:97} ${cx+13} 100`} stroke="#7A3808" strokeWidth={isConcern?3:2.2} fill="none" opacity={isConcern?0.78:0.65}/>
              {isHappy&&<path d={`M${cx-12} 111 Q${cx} 114 ${cx+12} 111`} stroke="#7A3808" strokeWidth="1.3" fill="none" opacity=".5"/>}
            </g>
          ))}
          <rect x="64"  y="95" width="36" height="20" rx="4" stroke="#8A8080" strokeWidth="1.4" fill="none"/>
          <rect x="130" y="95" width="36" height="20" rx="4" stroke="#8A8080" strokeWidth="1.4" fill="none"/>
          <path d="M100 105 Q115 103 130 105" stroke="#8A8080" strokeWidth="1.4" fill="none"/>
          <line x1="64"  y1="105" x2="53"  y2="103" stroke="#8A8080" strokeWidth="1.4" strokeLinecap="round"/>
          <line x1="166" y1="105" x2="177" y2="103" stroke="#8A8080" strokeWidth="1.4" strokeLinecap="round"/>
          <path d="M109 112 Q113 120 117 112" stroke="#7A3808" strokeWidth="1.8" fill="none" opacity=".5"/>
          <ellipse cx="106" cy="124" rx="7" ry="4.5" fill="#7A3818" opacity=".32"/>
          <ellipse cx="124" cy="124" rx="7" ry="4.5" fill="#7A3818" opacity=".32"/>
          <path d="M90 134 Q98 129 108 131 Q115 132 122 131 Q132 129 140 134 Q136 140 127 141 Q120 139 115 140 Q110 139 103 141 Q94 140 90 134 Z" fill="#181008"/>
          <path d="M95 135 Q103 132 109 133" stroke="#282018" strokeWidth=".8" fill="none" opacity=".45"/>
          <path d="M121 133 Q127 132 135 135" stroke="#282018" strokeWidth=".8" fill="none" opacity=".45"/>
          <ellipse cx="60"  cy="122" rx="18" ry="12" fill={`url(#bl${uid})`} opacity={blushOp}/>
          <ellipse cx="170" cy="122" rx="18" ry="12" fill={`url(#bl${uid})`} opacity={blushOp}/>
          <path d={mouthPath} stroke="#7A3010" strokeWidth="2.4" fill="none" strokeLinecap="round"/>
          {isHappy&&<path d="M99 145 Q115 151 131 145" fill="white" opacity=".5"/>}
          {isConcern&&<>
            <path d="M94 148 Q92 151 93 153" stroke="#7A3010" strokeWidth="1.5" fill="none" opacity=".5"/>
            <path d="M136 148 Q138 151 137 153" stroke="#7A3010" strokeWidth="1.5" fill="none" opacity=".5"/>
            <rect x="130" y="14" width="84" height="50" rx="10" fill="#0E0804" stroke="#C8962A" strokeWidth="1.2" strokeOpacity=".6"/>
            <path d="M140 64 L134 78 L156 64" fill="#0E0804" stroke="#C8962A" strokeWidth="1.2" strokeOpacity=".6"/>
            <text x="172" y="34" fontFamily="sans-serif" fontSize="9.5" fill="#F0C866" textAnchor="middle" fontWeight="700">A reminder</text>
            <text x="172" y="46" fontFamily="sans-serif" fontSize="9" fill="#C8A858" textAnchor="middle">is waiting for you.</text>
            <text x="172" y="57" fontFamily="sans-serif" fontSize="8.5" fill="rgba(200,150,42,.55)" textAnchor="middle">Whenever ready</text>
          </>}
          <path d="M55 88 Q51 110 58 134" stroke="#E8A840" strokeWidth=".8" fill="none" opacity=".16"/>
        </svg>
      </div>
    </div>
  )
}
X

echo "  ✓ PapaAvatar"

cat > $B/src/screens/Splash.jsx << 'X'
import { useEffect } from 'react'
import PapaAvatar from '../components/PapaAvatar'
export default function Splash({ onDone }) {
  useEffect(() => { const t = setTimeout(onDone, 2600); return () => clearTimeout(t) }, [onDone])
  return (
    <div onClick={onDone} style={{position:'fixed',inset:0,zIndex:999,background:'linear-gradient(170deg,#060E16 0%,#0D1B2A 45%,#060E16 100%)',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',cursor:'pointer'}}>
      {[[18,12],[78,22],[8,38],[88,65],[15,75],[65,88]].map(([l,t],i)=>(
        <div key={i} style={{position:'absolute',left:`${l}%`,top:`${t}%`,width:i%2?1.5:2,height:i%2?1.5:2,background:'#F0C866',borderRadius:'50%',opacity:.45+i*.08}}/>
      ))}
      <div style={{position:'absolute',top:'20%',left:'50%',transform:'translateX(-50%)',width:150,height:150,background:'radial-gradient(circle,rgba(200,150,42,0.16) 0%,transparent 70%)',borderRadius:'50%'}}/>
      <div className="float"><PapaAvatar state="happy" size={110} showRings={true}/></div>
      <div style={{marginTop:22,fontSize:36,fontWeight:700,color:'#F0C866',fontFamily:'Georgia,serif',letterSpacing:'-.02em'}}>Papa</div>
      <div style={{fontSize:12,color:'rgba(200,150,42,0.5)',letterSpacing:'.14em',textTransform:'uppercase',marginTop:4}}>Your Personal Companion</div>
      <div style={{marginTop:52,display:'flex',gap:7}}>
        <div style={{width:5,height:5,background:'#C8962A',borderRadius:'50%',opacity:.4}}/>
        <div style={{width:6,height:6,background:'#C8962A',borderRadius:'50%'}}/>
        <div style={{width:5,height:5,background:'#C8962A',borderRadius:'50%',opacity:.4}}/>
      </div>
    </div>
  )
}
X
echo "  ✓ Splash"


cat > $B/src/screens/Onboarding.jsx << 'X'
import { useState } from 'react'
import { setSetting } from '../db/db'
import PapaAvatar from '../components/PapaAvatar'
export default function Onboarding({ onDone }) {
  const [step, setStep] = useState(0)
  const [name, setName] = useState('')
  async function finish() { await setSetting('userName', name||'Papa'); await setSetting('onboarded', true); onDone(name||'Papa') }
  const dot = (i) => <div key={i} style={{width:step===i?22:8,height:5,background:step===i?'#C8962A':'rgba(200,150,42,0.28)',borderRadius:3,transition:'all .3s'}}/>
  const btn = (label, action) => (
    <button onClick={action} style={{background:'linear-gradient(135deg,#C8962A,#E8B84B)',color:'#060E16',fontWeight:700,borderRadius:14,border:'none',cursor:'pointer',fontSize:16,width:'100%',maxWidth:300,padding:'15px',fontFamily:'inherit',marginTop:24}}>{label}</button>
  )
  if (step===0) return (
    <div style={{position:'fixed',inset:0,zIndex:998,background:'#0D1B2A',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',padding:'32px 24px'}}>
      <div style={{display:'flex',gap:6,marginBottom:32}}>{[0,1,2].map(dot)}</div>
      <div style={{fontFamily:'Georgia,serif',fontSize:26,fontWeight:700,color:'#F0C866',textAlign:'center',marginBottom:8,lineHeight:1.3}}>Meet your<br/>companion</div>
      <div style={{fontSize:13,color:'rgba(200,184,140,0.65)',textAlign:'center',marginBottom:28,lineHeight:1.65}}>I'll be here every day to help you<br/>stay organised and motivated.</div>
      <div className="float"><PapaAvatar state="happy" size={120} showRings={true}/></div>
      <div style={{marginTop:18,background:'rgba(200,150,42,0.1)',border:'1px solid rgba(200,150,42,0.28)',borderRadius:14,borderTopLeftRadius:4,padding:'11px 16px',fontSize:13,color:'#E8D8B0',lineHeight:1.6,textAlign:'center',maxWidth:260}}>"Good morning! I am so happy to be your companion."</div>
      {btn('Continue →', ()=>setStep(1))}
    </div>
  )
  if (step===1) return (
    <div style={{position:'fixed',inset:0,zIndex:998,background:'#0D1B2A',display:'flex',flexDirection:'column',padding:'env(safe-area-inset-top,44px) 24px 32px'}}>
      <div style={{display:'flex',gap:6,marginBottom:28,justifyContent:'center'}}>{[0,1,2].map(dot)}</div>
      <div style={{fontFamily:'Georgia,serif',fontSize:24,fontWeight:700,color:'#F0C866',textAlign:'center',marginBottom:8}}>What shall I<br/>call you?</div>
      <div style={{fontSize:13,color:'rgba(200,184,140,0.65)',textAlign:'center',marginBottom:28}}>I will greet you by name every morning.</div>
      <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.65)',marginBottom:8}}>Your name</div>
      <input style={{background:'rgba(255,255,255,0.08)',border:'2px solid rgba(200,150,42,0.45)',borderRadius:14,padding:'14px 16px',fontSize:18,color:'#EEE8D5',fontFamily:'inherit',outline:'none',marginBottom:24}} placeholder="Enter your name..." value={name} onChange={e=>setName(e.target.value)} autoFocus/>
      <div style={{display:'flex',alignItems:'center',gap:12,background:'rgba(200,150,42,0.09)',border:'1px solid rgba(200,150,42,0.22)',borderRadius:14,padding:'12px 14px'}}>
        <PapaAvatar state="calm" size={48} showRings={false}/>
        <div style={{fontSize:12,color:'#E8D8B0',lineHeight:1.55}}>"I am looking forward to working with you!"</div>
      </div>
      {btn('Continue →', ()=>setStep(2))}
    </div>
  )
  return (
    <div style={{position:'fixed',inset:0,zIndex:998,background:'#0D1B2A',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',padding:'32px 24px'}}>
      <div style={{display:'flex',gap:6,marginBottom:28}}>{[0,1,2].map(dot)}</div>
      <div style={{fontFamily:'Georgia,serif',fontSize:24,fontWeight:700,color:'#F0C866',textAlign:'center',marginBottom:8}}>You are all set,<br/>{name||'Papa'}! ✦</div>
      <div style={{fontSize:13,color:'rgba(200,184,140,0.65)',textAlign:'center',marginBottom:32}}>Your companion is ready and waiting.</div>
      <div className="float"><PapaAvatar state="happy" size={140} showRings={true}/></div>
      <div style={{marginTop:24,background:'rgba(76,175,130,0.1)',border:'1px solid rgba(76,175,130,0.25)',borderRadius:14,padding:'12px 16px',fontSize:13,color:'#A8DFC0',lineHeight:1.6,textAlign:'center'}}>"Welcome! Let us make every day wonderful together."</div>
      {btn('Start Your Journey ✦', finish)}
    </div>
  )
}
X
echo "  ✓ Onboarding"


cat > $B/src/screens/Home.jsx << 'X'
import { useEffect, useState } from 'react'
import PapaAvatar from '../components/PapaAvatar'
import { db, todayStr, getStreak } from '../db/db'
import { useLiveQuery } from 'dexie-react-hooks'
function timeGreeting(){const h=new Date().getHours();if(h<12)return'Good Morning';if(h<17)return'Good Afternoon';if(h<21)return'Good Evening';return'Good Night'}
const pColor={high:'#E8855A',medium:'#C8962A',low:'#4CAF82'}
export default function Home({onNav}){
  const [streak,setStreak]=useState(0)
  const today=todayStr()
  const todayTasks=useLiveQuery(()=>db.tasks.where('dueDate').equals(today).toArray(),[])??[]
  const allTasks=useLiveQuery(()=>db.tasks.toArray(),[])??[]
  useEffect(()=>{getStreak().then(setStreak)},[todayTasks])
  const done=todayTasks.filter(t=>t.isCompleted).length
  const total=todayTasks.length
  const overdue=allTasks.filter(t=>!t.isCompleted&&t.dueDate&&t.dueDate<today)
  const avState=overdue.length>0?'concern':done>0&&done===total&&total>0?'happy':'calm'
  const msgs={calm:total>0?`You have ${total} task${total>1?'s':''} today.${streak>0?' You are on a '+streak+'-day streak!':''}`:'A calm day. Want to add something?',happy:"You completed everything today! I am so proud of you!",concern:`You have ${overdue.length} task${overdue.length>1?'s':''} waiting. Whenever you are ready.`}
  async function completeTask(task){
    await db.tasks.update(task.id,{isCompleted:true,completedAt:new Date().toISOString()})
    const existing=await db.progress.where('date').equals(today).first()
    if(existing)await db.progress.update(existing.id,{tasksCompleted:(existing.tasksCompleted||0)+1})
    else await db.progress.add({date:today,tasksCompleted:1,tasksTotal:total})
    setStreak(await getStreak())
  }
  return(
    <div className="page-in" style={{display:'flex',flexDirection:'column',height:'100%',overflow:'hidden'}}>
      <div style={{paddingTop:'env(safe-area-inset-top,44px)',flexShrink:0}}>
        <div style={{display:'flex',justifyContent:'space-between',padding:'8px 18px 0',marginBottom:10}}>
          <span style={{fontSize:12,color:'rgba(200,150,42,0.5)'}}>{new Date().toLocaleDateString('en-IN',{weekday:'short',day:'numeric',month:'short'})}</span>
          <span style={{fontSize:12,color:'rgba(200,150,42,0.5)'}}>{new Date().toLocaleTimeString('en-IN',{hour:'2-digit',minute:'2-digit'})}</span>
        </div>
      </div>
      <div className="scroll-y" style={{flex:1,padding:'0 18px 24px'}}>
        <div style={{display:'flex',alignItems:'center',gap:14,marginBottom:14}}>
          <PapaAvatar state={avState} size={62} showRings={true}/>
          <div>
            <div style={{fontSize:12,color:'rgba(200,150,42,0.6)',fontWeight:500}}>{timeGreeting()},</div>
            <div style={{fontSize:22,fontWeight:700,color:'#F0C866',lineHeight:1.1,fontFamily:'Georgia,serif'}}>Papa ✦</div>
          </div>
          <button onClick={()=>onNav('tasks')} style={{marginLeft:'auto',background:'rgba(200,150,42,0.12)',border:'1px solid rgba(200,150,42,0.28)',borderRadius:'50%',width:36,height:36,display:'flex',alignItems:'center',justifyContent:'center',cursor:'pointer',fontSize:18,color:'#F0C866',fontWeight:700}}>+</button>
        </div>
        <div style={{background:avState==='concern'?'rgba(232,133,90,0.1)':'rgba(200,150,42,0.1)',border:`1px solid ${avState==='concern'?'rgba(232,133,90,0.3)':'rgba(200,150,42,0.28)'}`,borderRadius:14,borderTopLeftRadius:4,padding:'10px 13px',fontSize:13,color:'#E8D8B0',lineHeight:1.55,marginBottom:14}}>{msgs[avState]}</div>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:8,marginBottom:16}}>
          {[{val:total,label:'Tasks',c:'#4CAF82',bg:'rgba(76,175,130,0.12)',bd:'rgba(76,175,130,0.25)'},{val:streak+'🔥',label:'Streak',c:'#F0C866',bg:'rgba(200,150,42,0.12)',bd:'rgba(200,150,42,0.28)'},{val:done+'/'+total,label:'Done',c:'#6496E8',bg:'rgba(100,150,230,0.12)',bd:'rgba(100,150,230,0.25)'}].map(s=>(
            <div key={s.label} style={{background:s.bg,border:`1px solid ${s.bd}`,borderRadius:12,padding:'10px 6px',textAlign:'center'}}>
              <div style={{fontSize:20,fontWeight:700,color:s.c}}>{s.val}</div>
              <div style={{fontSize:9,color:s.c,opacity:.7,marginTop:2}}>{s.label}</div>
            </div>
          ))}
        </div>
        <div style={{fontSize:10,fontWeight:600,letterSpacing:'.09em',textTransform:'uppercase',color:'rgba(200,150,42,0.58)',marginBottom:8}}>Today s Tasks</div>
        {todayTasks.length===0&&<div style={{textAlign:'center',padding:'28px 0',color:'rgba(200,184,160,0.4)',fontSize:14}}>No tasks for today.<br/><span style={{fontSize:12}}>Tap + to add one</span></div>}
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {todayTasks.map(task=>(
            <div key={task.id} onClick={()=>!task.isCompleted&&completeTask(task)} style={{background:task.isCompleted?'rgba(76,175,130,0.07)':'rgba(255,255,255,0.045)',border:`1.5px solid ${task.isCompleted?'rgba(76,175,130,0.22)':task.priority==='high'?'rgba(232,133,90,0.4)':'rgba(200,150,42,0.25)'}`,borderRadius:14,padding:'11px 13px',display:'flex',alignItems:'center',gap:10,opacity:task.isCompleted?0.7:1,cursor:task.isCompleted?'default':'pointer'}}>
              <div style={{width:22,height:22,borderRadius:'50%',border:`2px solid ${task.isCompleted?'#4CAF82':pColor[task.priority]||'rgba(255,255,255,0.3)'}`,background:task.isCompleted?'rgba(76,175,130,0.25)':'transparent',display:'flex',alignItems:'center',justifyContent:'center',flexShrink:0}}>
                {task.isCompleted&&<span style={{color:'#4CAF82',fontSize:11}}>✓</span>}
              </div>
              <div style={{flex:1,minWidth:0}}>
                <div style={{fontSize:13,fontWeight:600,color:task.isCompleted?'rgba(200,184,160,0.45)':'#EEE8D5',textDecoration:task.isCompleted?'line-through':'none',whiteSpace:'nowrap',overflow:'hidden',textOverflow:'ellipsis'}}>{task.title}</div>
                <div style={{fontSize:10,color:'rgba(200,150,42,0.6)',marginTop:1}}>{task.isCompleted?'Done ✓':task.category||''}</div>
              </div>
              {!task.isCompleted&&task.priority==='high'&&<div style={{background:'rgba(232,133,90,0.2)',color:'#E8855A',padding:'2px 8px',borderRadius:8,fontSize:9,fontWeight:700}}>!</div>}
            </div>
          ))}
        </div>
        {overdue.length>0&&(
          <div onClick={()=>onNav('tasks')} style={{marginTop:12,background:'rgba(232,133,90,0.08)',border:'1px solid rgba(232,133,90,0.28)',borderRadius:12,padding:'10px 13px',display:'flex',alignItems:'center',gap:10,cursor:'pointer'}}>
            <span style={{fontSize:18}}>⚠️</span>
            <div><div style={{fontSize:12,fontWeight:600,color:'#E8855A'}}>{overdue.length} overdue task{overdue.length>1?'s':''}</div><div style={{fontSize:10,color:'rgba(232,133,90,0.65)'}}>Tap to view</div></div>
          </div>
        )}
      </div>
    </div>
  )
}
X
echo "  ✓ Home"


cat > $B/src/screens/Tasks.jsx << 'X'
import { useState } from 'react'
import { useLiveQuery } from 'dexie-react-hooks'
import { db, todayStr } from '../db/db'
const PC={high:'#E8855A',medium:'#C8962A',low:'#4CAF82'}
const PBG={high:'rgba(232,133,90,0.12)',medium:'rgba(200,150,42,0.1)',low:'rgba(76,175,130,0.1)'}
const PBD={high:'rgba(232,133,90,0.35)',medium:'rgba(200,150,42,0.32)',low:'rgba(76,175,130,0.28)'}
const CATS=['Health','Personal','Home','Work','Family','Other']
function Sheet({onClose}){
  const [title,setTitle]=useState('')
  const [pri,setPri]=useState('medium')
  const [cat,setCat]=useState('Personal')
  const [due,setDue]=useState(todayStr())
  const [notes,setNotes]=useState('')
  async function save(){if(!title.trim())return;await db.tasks.add({title:title.trim(),priority:pri,category:cat,dueDate:due,notes,isCompleted:false,createdAt:new Date().toISOString(),completedAt:null,reminder:''});onClose()}
  const I={background:'rgba(255,255,255,0.07)',border:'1px solid rgba(200,150,42,0.28)',borderRadius:12,padding:'12px 14px',fontSize:15,color:'#EEE8D5',width:'100%',fontFamily:'inherit',outline:'none'}
  return(
    <div style={{position:'fixed',inset:0,zIndex:200,display:'flex',flexDirection:'column',justifyContent:'flex-end'}}>
      <div onClick={onClose} style={{position:'absolute',inset:0,background:'rgba(0,0,0,0.55)'}}/>
      <div className="slide-up" style={{position:'relative',background:'#0D1B2A',borderRadius:'20px 20px 0 0',padding:'20px 18px',paddingBottom:'env(safe-area-inset-bottom,20px)',border:'1px solid rgba(200,150,42,0.2)',borderBottom:'none',maxHeight:'85vh',overflowY:'auto'}}>
        <div style={{width:36,height:4,background:'rgba(200,150,42,0.3)',borderRadius:2,margin:'0 auto 18px'}}/>
        <div style={{fontSize:18,fontWeight:700,color:'#F0C866',fontFamily:'Georgia,serif',marginBottom:18}}>Add Task</div>
        <div style={{marginBottom:14}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>Task</div>
          <input style={I} placeholder="What needs to be done?" value={title} onChange={e=>setTitle(e.target.value)} autoFocus/>
        </div>
        <div style={{marginBottom:14}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>Priority</div>
          <div style={{display:'flex',gap:8}}>
            {['high','medium','low'].map(p=>(
              <button key={p} onClick={()=>setPri(p)} style={{flex:1,padding:'9px 0',borderRadius:20,fontSize:12,fontWeight:600,border:`${pri===p?'2px':'1px'} solid ${pri===p?PC[p]:'rgba(255,255,255,0.12)'}`,background:pri===p?PBG[p]:'transparent',color:pri===p?PC[p]:'rgba(200,184,160,0.55)',cursor:'pointer',fontFamily:'inherit',textTransform:'capitalize'}}>{p}</button>
            ))}
          </div>
        </div>
        <div style={{marginBottom:14}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>Category</div>
          <div style={{display:'flex',flexWrap:'wrap',gap:7}}>
            {CATS.map(c=>(
              <button key={c} onClick={()=>setCat(c)} style={{padding:'6px 13px',borderRadius:20,fontSize:11,fontWeight:600,border:`1px solid ${cat===c?'#C8962A':'rgba(255,255,255,0.1)'}`,background:cat===c?'rgba(200,150,42,0.15)':'transparent',color:cat===c?'#F0C866':'rgba(200,184,160,0.5)',cursor:'pointer',fontFamily:'inherit'}}>{c}</button>
            ))}
          </div>
        </div>
        <div style={{marginBottom:14}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>Due Date</div>
          <input type="date" style={{...I,colorScheme:'dark'}} value={due} onChange={e=>setDue(e.target.value)}/>
        </div>
        <div style={{marginBottom:20}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>Notes</div>
          <textarea style={{...I,resize:'none',minHeight:72}} placeholder="Any details..." value={notes} onChange={e=>setNotes(e.target.value)}/>
        </div>
        <button onClick={save} style={{background:'linear-gradient(135deg,#C8962A,#E8B84B)',color:'#060E16',fontWeight:700,borderRadius:14,border:'none',cursor:'pointer',fontSize:16,width:'100%',padding:'15px',fontFamily:'inherit'}}>Save Task</button>
      </div>
    </div>
  )
}
export default function Tasks(){
  const [filter,setFilter]=useState('all')
  const [showAdd,setShowAdd]=useState(false)
  const tasks=useLiveQuery(()=>db.tasks.orderBy('createdAt').reverse().toArray(),[])??[]
  const today=todayStr()
  const filtered=tasks.filter(t=>{
    if(filter==='today')return t.dueDate===today
    if(filter==='high')return t.priority==='high'&&!t.isCompleted
    if(filter==='done')return t.isCompleted
    if(filter==='overdue')return !t.isCompleted&&t.dueDate&&t.dueDate<today
    return true
  })
  async function toggle(task){
    const done=!task.isCompleted
    await db.tasks.update(task.id,{isCompleted:done,completedAt:done?new Date().toISOString():null})
    if(done){const e=await db.progress.where('date').equals(today).first();if(e)await db.progress.update(e.id,{tasksCompleted:(e.tasksCompleted||0)+1});else await db.progress.add({date:today,tasksCompleted:1,tasksTotal:tasks.filter(t=>t.dueDate===today).length})}
  }
  const FILTERS=[{id:'all',label:'All'},{id:'today',label:'Today'},{id:'high',label:'High !'},{id:'overdue',label:'Overdue'},{id:'done',label:'Done'}]
  return(
    <div className="page-in" style={{display:'flex',flexDirection:'column',height:'100%',overflow:'hidden'}}>
      {showAdd&&<Sheet onClose={()=>setShowAdd(false)}/>}
      <div style={{padding:'env(safe-area-inset-top,44px) 18px 0',paddingTop:'calc(env(safe-area-inset-top,44px) + 8px)',flexShrink:0}}>
        <div style={{display:'flex',alignItems:'center',marginBottom:14}}>
          <div style={{fontSize:22,fontWeight:700,color:'#F0C866',fontFamily:'Georgia,serif'}}>Tasks</div>
          <button onClick={()=>setShowAdd(true)} style={{marginLeft:'auto',background:'linear-gradient(135deg,#C8962A,#E8B84B)',width:32,height:32,borderRadius:'50%',border:'none',cursor:'pointer',fontSize:20,color:'#060E16',fontWeight:700,display:'flex',alignItems:'center',justifyContent:'center'}}>+</button>
        </div>
        <div style={{display:'flex',gap:7,overflowX:'auto',paddingBottom:12}}>
          {FILTERS.map(f=>(
            <button key={f.id} onClick={()=>setFilter(f.id)} style={{padding:'5px 13px',borderRadius:20,fontSize:10.5,fontWeight:600,background:filter===f.id?'#C8962A':'rgba(255,255,255,0.06)',color:filter===f.id?'#060E16':'rgba(200,184,160,0.55)',border:filter===f.id?'none':'1px solid rgba(255,255,255,0.1)',cursor:'pointer',whiteSpace:'nowrap',fontFamily:'inherit'}}>{f.label}</button>
          ))}
        </div>
      </div>
      <div className="scroll-y" style={{flex:1,padding:'0 18px 24px'}}>
        {filtered.length===0&&<div style={{textAlign:'center',padding:'40px 0',color:'rgba(200,184,160,0.4)',fontSize:14}}>No tasks here.<br/><span style={{fontSize:12}}>Tap + to add one</span></div>}
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {filtered.map(task=>{
            const ov=!task.isCompleted&&task.dueDate&&task.dueDate<today
            return(
              <div key={task.id} style={{background:task.isCompleted?'rgba(76,175,130,0.07)':ov?'rgba(232,133,90,0.08)':'rgba(255,255,255,0.045)',border:`1.5px solid ${task.isCompleted?'rgba(76,175,130,0.22)':ov?'rgba(232,133,90,0.38)':PBD[task.priority]||'rgba(255,255,255,0.1)'}`,borderRadius:14,padding:'11px 13px',display:'flex',alignItems:'flex-start',gap:10,opacity:task.isCompleted?0.72:1}}>
                <button onClick={()=>toggle(task)} style={{width:24,height:24,borderRadius:'50%',flexShrink:0,marginTop:1,border:`2px solid ${task.isCompleted?'#4CAF82':PC[task.priority]||'rgba(255,255,255,0.3)'}`,background:task.isCompleted?'rgba(76,175,130,0.25)':'transparent',cursor:'pointer',display:'flex',alignItems:'center',justifyContent:'center'}}>
                  {task.isCompleted&&<span style={{color:'#4CAF82',fontSize:12}}>✓</span>}
                </button>
                <div style={{flex:1,minWidth:0}}>
                  <div style={{fontSize:13,fontWeight:600,color:task.isCompleted?'rgba(200,184,160,0.45)':'#EEE8D5',textDecoration:task.isCompleted?'line-through':'none'}}>{task.title}</div>
                  <div style={{fontSize:10,color:ov?'#E8855A':'rgba(200,150,42,0.6)',marginTop:2}}>{ov?'⚠ Overdue':task.dueDate===today?'Today':task.dueDate} · {task.category}</div>
                  {task.notes?<div style={{fontSize:11,color:'rgba(200,184,160,0.4)',marginTop:3,overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}}>{task.notes}</div>:null}
                </div>
                <div style={{display:'flex',flexDirection:'column',alignItems:'flex-end',gap:5,flexShrink:0}}>
                  {!task.isCompleted&&<div style={{background:PBG[task.priority],color:PC[task.priority],padding:'2px 8px',borderRadius:8,fontSize:9,fontWeight:700,textTransform:'uppercase'}}>{task.priority}</div>}
                  <button onClick={()=>db.tasks.delete(task.id)} style={{background:'none',border:'none',cursor:'pointer',color:'rgba(200,184,160,0.28)',fontSize:14,padding:2}}>✕</button>
                </div>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )
}
X
echo "  ✓ Tasks"


cat > $B/src/screens/Routine.jsx << 'X'
import { useState } from 'react'
import { useLiveQuery } from 'dexie-react-hooks'
import { db, todayStr } from '../db/db'
const SLOTS=[{id:'morning',label:'Morning',icon:'☀',color:'#F0C866',bg:'rgba(255,200,80,0.13)',bd:'rgba(255,200,80,0.28)'},{id:'afternoon',label:'Afternoon',icon:'⛅',color:'#6496E8',bg:'rgba(100,150,230,0.11)',bd:'rgba(100,150,230,0.24)'},{id:'evening',label:'Evening',icon:'🌙',color:'#C090D8',bg:'rgba(180,100,200,0.1)',bd:'rgba(180,100,200,0.22)'}]
export default function Routine(){
  const [showAdd,setShowAdd]=useState(false)
  const [nTitle,setNTitle]=useState('')
  const [nSlot,setNSlot]=useState('morning')
  const [nTime,setNTime]=useState('08:00')
  const today=todayStr()
  const items=useLiveQuery(()=>db.routine.toArray(),[])??[]
  async function toggle(item){await db.routine.update(item.id,{isCompleted:!item.isCompleted,completedDate:!item.isCompleted?today:null})}
  async function add(){if(!nTitle.trim())return;await db.routine.add({title:nTitle.trim(),timeSlot:nSlot,time:nTime,isCompleted:false,completedDate:null});setNTitle('');setShowAdd(false)}
  const I={background:'rgba(255,255,255,0.07)',border:'1px solid rgba(200,150,42,0.28)',borderRadius:12,padding:'12px 14px',fontSize:15,color:'#EEE8D5',width:'100%',fontFamily:'inherit',outline:'none'}
  return(
    <div className="page-in" style={{display:'flex',flexDirection:'column',height:'100%',overflow:'hidden'}}>
      <div style={{padding:'env(safe-area-inset-top,44px) 18px 0',paddingTop:'calc(env(safe-area-inset-top,44px) + 8px)',flexShrink:0}}>
        <div style={{display:'flex',alignItems:'center',marginBottom:16}}>
          <div style={{fontSize:22,fontWeight:700,color:'#F0C866',fontFamily:'Georgia,serif'}}>Daily Routine</div>
          <button onClick={()=>setShowAdd(!showAdd)} style={{marginLeft:'auto',background:'linear-gradient(135deg,#C8962A,#E8B84B)',width:32,height:32,borderRadius:'50%',border:'none',cursor:'pointer',fontSize:20,color:'#060E16',fontWeight:700,display:'flex',alignItems:'center',justifyContent:'center'}}>+</button>
        </div>
      </div>
      <div className="scroll-y" style={{flex:1,padding:'0 18px 24px'}}>
        {showAdd&&(
          <div className="pop" style={{background:'rgba(255,255,255,0.05)',border:'1px solid rgba(200,150,42,0.28)',borderRadius:16,padding:16,marginBottom:16}}>
            <input style={{...I,marginBottom:10}} placeholder="Routine item name" value={nTitle} onChange={e=>setNTitle(e.target.value)} autoFocus/>
            <div style={{display:'flex',gap:8,marginBottom:10}}>
              {SLOTS.map(s=>(
                <button key={s.id} onClick={()=>setNSlot(s.id)} style={{flex:1,padding:'7px 0',borderRadius:10,fontSize:11,fontWeight:600,background:nSlot===s.id?s.bg:'transparent',border:`1px solid ${nSlot===s.id?s.bd:'rgba(255,255,255,0.1)'}`,color:nSlot===s.id?s.color:'rgba(200,184,160,0.4)',cursor:'pointer',fontFamily:'inherit'}}>{s.icon} {s.label}</button>
              ))}
            </div>
            <input type="time" style={{...I,marginBottom:10,colorScheme:'dark'}} value={nTime} onChange={e=>setNTime(e.target.value)}/>
            <button onClick={add} style={{background:'linear-gradient(135deg,#C8962A,#E8B84B)',color:'#060E16',fontWeight:700,borderRadius:12,border:'none',cursor:'pointer',fontSize:14,width:'100%',padding:'12px',fontFamily:'inherit'}}>Add</button>
          </div>
        )}
        {SLOTS.map(slot=>{
          const si=items.filter(i=>i.timeSlot===slot.id)
          return(
            <div key={slot.id} style={{background:slot.bg,border:`1px solid ${slot.bd}`,borderRadius:16,padding:13,marginBottom:12}}>
              <div style={{fontSize:10.5,fontWeight:700,color:slot.color,letterSpacing:'.1em',textTransform:'uppercase',marginBottom:9}}>{slot.icon} {slot.label}</div>
              {si.length===0&&<div style={{fontSize:12,color:'rgba(200,184,160,0.35)',textAlign:'center',padding:'10px 0'}}>No items — tap + to add</div>}
              <div style={{display:'flex',flexDirection:'column',gap:6}}>
                {si.map(item=>(
                  <div key={item.id} style={{display:'flex',alignItems:'center',gap:9,background:'rgba(255,255,255,0.065)',borderRadius:11,padding:'9px 11px'}}>
                    <button onClick={()=>toggle(item)} style={{width:20,height:20,borderRadius:'50%',border:`1.5px solid ${item.isCompleted?'#4CAF82':slot.color}`,background:item.isCompleted?'rgba(76,175,130,0.28)':'transparent',cursor:'pointer',flexShrink:0,display:'flex',alignItems:'center',justifyContent:'center'}}>
                      {item.isCompleted&&<span style={{color:'#4CAF82',fontSize:10}}>✓</span>}
                    </button>
                    <span style={{fontSize:12,flex:1,color:item.isCompleted?'rgba(200,184,160,0.42)':'#EEE8D5',textDecoration:item.isCompleted?'line-through':'none'}}>{item.title}</span>
                    <span style={{fontSize:10,color:`${slot.color}99`}}>{item.time}</span>
                    <button onClick={()=>db.routine.delete(item.id)} style={{background:'none',border:'none',cursor:'pointer',color:'rgba(200,184,160,0.25)',fontSize:13,padding:2}}>✕</button>
                  </div>
                ))}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
X
echo "  ✓ Routine"


cat > $B/src/screens/Notes.jsx << 'X'
import { useState } from 'react'
import { useLiveQuery } from 'dexie-react-hooks'
import { db } from '../db/db'
const COLS=[{id:'gold',bg:'rgba(200,150,42,0.1)',bd:'rgba(200,150,42,0.28)',text:'#F0C866'},{id:'green',bg:'rgba(76,175,130,0.08)',bd:'rgba(76,175,130,0.22)',text:'#4CAF82'},{id:'blue',bg:'rgba(100,150,230,0.08)',bd:'rgba(100,150,230,0.22)',text:'#6496E8'},{id:'purple',bg:'rgba(180,100,200,0.08)',bd:'rgba(180,100,200,0.22)',text:'#C090D8'},{id:'neutral',bg:'rgba(255,255,255,0.04)',bd:'rgba(255,255,255,0.1)',text:'#EEE8D5'}]
const EMOJIS=['💊','🛒','🌱','📞','💡','📋','❤️','🏠']
function NoteSheet({note,onClose}){
  const [title,setTitle]=useState(note?.title??'')
  const [body,setBody]=useState(note?.body??'')
  const [colour,setColour]=useState(note?.colour??'gold')
  async function save(){
    const t=title.trim()||'Untitled'
    if(note)await db.notes.update(note.id,{title:t,body:body.trim(),colour,updatedAt:new Date().toISOString()})
    else await db.notes.add({title:t,body:body.trim(),colour,createdAt:new Date().toISOString(),updatedAt:new Date().toISOString()})
    onClose()
  }
  const col=COLS.find(c=>c.id===colour)||COLS[0]
  const I={background:'rgba(255,255,255,0.07)',border:`1px solid ${col.bd}`,borderRadius:12,padding:'12px 14px',fontSize:15,color:'#EEE8D5',width:'100%',fontFamily:'inherit',outline:'none'}
  return(
    <div style={{position:'fixed',inset:0,zIndex:200,display:'flex',flexDirection:'column',justifyContent:'flex-end'}}>
      <div onClick={onClose} style={{position:'absolute',inset:0,background:'rgba(0,0,0,0.55)'}}/>
      <div className="slide-up" style={{position:'relative',background:'#0D1B2A',borderRadius:'20px 20px 0 0',padding:'20px 18px',paddingBottom:'env(safe-area-inset-bottom,20px)',border:`1px solid ${col.bd}`,borderBottom:'none',maxHeight:'90vh',overflowY:'auto'}}>
        <div style={{width:36,height:4,background:'rgba(200,150,42,0.3)',borderRadius:2,margin:'0 auto 18px'}}/>
        <div style={{display:'flex',gap:8,marginBottom:12,overflowX:'auto'}}>
          {EMOJIS.map(e=><button key={e} onClick={()=>setTitle(t=>t.startsWith(e)?t.slice(e.length).trim():e+' '+t.replace(/^\p{Emoji}+\s*/u,''))} style={{background:'rgba(255,255,255,0.06)',border:'1px solid transparent',borderRadius:8,padding:'6px 8px',fontSize:18,cursor:'pointer'}}>{e}</button>)}
        </div>
        <input style={{...I,marginBottom:10,fontSize:16,fontWeight:600}} placeholder="Title" value={title} onChange={e=>setTitle(e.target.value)} autoFocus/>
        <textarea style={{...I,resize:'none',minHeight:120,marginBottom:14}} placeholder="Write your note here..." value={body} onChange={e=>setBody(e.target.value)}/>
        <div style={{display:'flex',gap:8,marginBottom:18}}>{COLS.map(c=><button key={c.id} onClick={()=>setColour(c.id)} style={{flex:1,height:28,borderRadius:8,background:c.bg,border:`2px solid ${colour===c.id?c.text:'transparent'}`,cursor:'pointer'}}/>)}</div>
        <button onClick={save} style={{background:'linear-gradient(135deg,#C8962A,#E8B84B)',color:'#060E16',fontWeight:700,borderRadius:14,border:'none',cursor:'pointer',fontSize:16,width:'100%',padding:'14px',fontFamily:'inherit'}}>{note?'Save Changes':'Save Note'}</button>
      </div>
    </div>
  )
}
export default function Notes(){
  const [sheet,setSheet]=useState(null)
  const [search,setSearch]=useState('')
  const notes=useLiveQuery(()=>db.notes.orderBy('updatedAt').reverse().toArray(),[])??[]
  const filtered=notes.filter(n=>n.title?.toLowerCase().includes(search.toLowerCase())||n.body?.toLowerCase().includes(search.toLowerCase()))
  return(
    <div className="page-in" style={{display:'flex',flexDirection:'column',height:'100%',overflow:'hidden'}}>
      {sheet!==null&&<NoteSheet note={sheet==='new'?null:sheet} onClose={()=>setSheet(null)}/>}
      <div style={{padding:'env(safe-area-inset-top,44px) 18px 0',paddingTop:'calc(env(safe-area-inset-top,44px) + 8px)',flexShrink:0}}>
        <div style={{display:'flex',alignItems:'center',marginBottom:12}}>
          <div style={{fontSize:22,fontWeight:700,color:'#F0C866',fontFamily:'Georgia,serif'}}>Notes</div>
          <button onClick={()=>setSheet('new')} style={{marginLeft:'auto',background:'linear-gradient(135deg,#C8962A,#E8B84B)',width:32,height:32,borderRadius:'50%',border:'none',cursor:'pointer',fontSize:20,color:'#060E16',fontWeight:700,display:'flex',alignItems:'center',justifyContent:'center'}}>+</button>
        </div>
        <div style={{background:'rgba(255,255,255,0.06)',border:'1px solid rgba(255,255,255,0.1)',borderRadius:12,padding:'10px 14px',display:'flex',alignItems:'center',gap:8,marginBottom:14}}>
          <span style={{color:'rgba(200,150,42,0.5)'}}>🔍</span>
          <input style={{background:'none',border:'none',outline:'none',color:'#EEE8D5',fontSize:14,flex:1,fontFamily:'inherit'}} placeholder="Search notes..." value={search} onChange={e=>setSearch(e.target.value)}/>
        </div>
      </div>
      <div className="scroll-y" style={{flex:1,padding:'0 18px 24px',display:'flex',flexDirection:'column',gap:10}}>
        {filtered.length===0&&<div style={{textAlign:'center',padding:'40px 0',color:'rgba(200,184,160,0.4)',fontSize:14}}>{search?'No notes found.':'No notes yet.'}<br/><span style={{fontSize:12}}>Tap + to add one</span></div>}
        {filtered.map(note=>{
          const col=COLS.find(c=>c.id===note.colour)||COLS[0]
          return(
            <div key={note.id} onClick={()=>setSheet(note)} style={{background:col.bg,border:`1px solid ${col.bd}`,borderRadius:16,padding:15,position:'relative',cursor:'pointer'}}>
              <div style={{fontSize:13,fontWeight:700,color:col.text,marginBottom:5}}>{note.title||'Untitled'}</div>
              {note.body&&<div style={{fontSize:12,color:'#C8C0B0',lineHeight:1.6,display:'-webkit-box',WebkitLineClamp:3,WebkitBoxOrient:'vertical',overflow:'hidden'}}>{note.body}</div>}
              <div style={{fontSize:9.5,color:'rgba(200,184,160,0.4)',marginTop:8}}>{new Date(note.updatedAt).toLocaleDateString('en-IN',{day:'numeric',month:'short'})}</div>
              <button onClick={e=>{e.stopPropagation();db.notes.delete(note.id)}} style={{position:'absolute',top:12,right:12,background:'none',border:'none',cursor:'pointer',color:'rgba(200,184,160,0.25)',fontSize:14}}>✕</button>
            </div>
          )
        })}
      </div>
    </div>
  )
}
X
echo "  ✓ Notes"


cat > $B/src/screens/Progress.jsx << 'X'
import { useEffect, useState } from 'react'
import { useLiveQuery } from 'dexie-react-hooks'
import { db, todayStr, getStreak } from '../db/db'
import PapaAvatar from '../components/PapaAvatar'
function last7(){return Array.from({length:7},(_,i)=>{const d=new Date();d.setDate(d.getDate()-6+i);d.setHours(0,0,0,0);return d.toISOString().split('T')[0]})}
const DAYS=['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
export default function Progress(){
  const [streak,setStreak]=useState(0)
  const tasks=useLiveQuery(()=>db.tasks.toArray(),[])??[]
  const progress=useLiveQuery(()=>db.progress.toArray(),[])??[]
  useEffect(()=>{getStreak().then(setStreak)},[progress])
  const totalDone=tasks.filter(t=>t.isCompleted).length
  const totalTasks=tasks.length
  const days=last7()
  const BADGES=[{icon:'⭐',label:'First Task',earned:totalDone>=1},{icon:'🏆',label:'10 Tasks',earned:totalDone>=10},{icon:'🔥',label:'3-Day Streak',earned:streak>=3},{icon:'💎',label:'30 Tasks',earned:totalDone>=30},{icon:'🌟',label:'7-Day Streak',earned:streak>=7},{icon:'👑',label:'50 Tasks',earned:totalDone>=50}]
  return(
    <div className="page-in" style={{display:'flex',flexDirection:'column',height:'100%',overflow:'hidden'}}>
      <div style={{padding:'env(safe-area-inset-top,44px) 18px 0',paddingTop:'calc(env(safe-area-inset-top,44px) + 8px)',flexShrink:0}}>
        <div style={{fontSize:22,fontWeight:700,color:'#F0C866',fontFamily:'Georgia,serif',marginBottom:14}}>Progress</div>
      </div>
      <div className="scroll-y" style={{flex:1,padding:'0 18px 24px'}}>
        <div style={{background:'linear-gradient(135deg,rgba(200,150,42,0.16),rgba(232,184,75,0.06))',border:'1px solid rgba(200,150,42,0.38)',borderRadius:18,padding:16,marginBottom:14,display:'flex',alignItems:'center',gap:14}}>
          <PapaAvatar state={totalDone>0?'happy':'calm'} size={72} showRings={false}/>
          <div style={{flex:1}}>
            <div style={{fontSize:28,fontWeight:700,color:'#F0C866',lineHeight:1,fontFamily:'Georgia,serif'}}>{streak} Day{streak!==1?'s':''} 🔥</div>
            <div style={{fontSize:11,color:'rgba(200,150,42,0.65)',marginTop:3}}>{streak>0?'"Keep going! You are on fire!"':'"Start today to begin your streak!"'}</div>
          </div>
          <div style={{textAlign:'center'}}>
            <div style={{fontSize:22,fontWeight:700,color:'#EEE8D5'}}>{totalDone}</div>
            <div style={{fontSize:9,color:'rgba(200,184,160,0.5)'}}>Tasks done</div>
          </div>
        </div>
        <div style={{background:'rgba(255,255,255,0.04)',border:'1px solid rgba(255,255,255,0.07)',borderRadius:16,padding:14,marginBottom:14}}>
          <div style={{fontSize:10,fontWeight:600,letterSpacing:'.09em',textTransform:'uppercase',color:'rgba(200,150,42,0.55)',marginBottom:12}}>This Week</div>
          <div style={{display:'flex',alignItems:'flex-end',gap:5,height:60}}>
            {days.map(day=>{
              const rec=progress.find(p=>p.date===day)
              const done=rec?.tasksCompleted??0
              const total=rec?.tasksTotal??0
              const pct=total>0?done/total:0
              const isToday=day===todayStr()
              return(
                <div key={day} style={{flex:1,display:'flex',flexDirection:'column',alignItems:'center',gap:4}}>
                  <div style={{width:'100%',borderRadius:4,background:isToday?(done>0?'#C8962A':'rgba(200,150,42,0.35)'):done>0?'#4CAF82':'rgba(255,255,255,0.08)',height:Math.max(pct*54,6),border:isToday&&done===0?'1.5px dashed rgba(200,150,42,0.5)':'none'}}/>
                  <div style={{fontSize:8,color:isToday?'#C8962A':'rgba(200,184,160,0.38)',fontWeight:isToday?700:400}}>{DAYS[new Date(day+'T12:00:00').getDay()]}</div>
                </div>
              )
            })}
          </div>
        </div>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:10,marginBottom:14}}>
          <div style={{background:'rgba(255,255,255,0.04)',border:'1px solid rgba(255,255,255,0.07)',borderRadius:14,padding:14,textAlign:'center'}}>
            <div style={{fontSize:28,fontWeight:700,color:'#F0C866'}}>{totalDone}</div>
            <div style={{fontSize:11,color:'rgba(200,184,160,0.5)',marginTop:2}}>Tasks completed</div>
          </div>
          <div style={{background:'rgba(255,255,255,0.04)',border:'1px solid rgba(255,255,255,0.07)',borderRadius:14,padding:14,textAlign:'center'}}>
            <div style={{fontSize:28,fontWeight:700,color:'#4CAF82'}}>{totalTasks>0?Math.round(totalDone/totalTasks*100):0}%</div>
            <div style={{fontSize:11,color:'rgba(200,184,160,0.5)',marginTop:2}}>Completion rate</div>
          </div>
        </div>
        <div style={{fontSize:10,fontWeight:600,letterSpacing:'.09em',textTransform:'uppercase',color:'rgba(200,150,42,0.55)',marginBottom:10}}>Achievements</div>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8}}>
          {BADGES.map(b=>(
            <div key={b.label} style={{background:b.earned?'rgba(200,150,42,0.1)':'rgba(255,255,255,0.03)',border:`1px solid ${b.earned?'rgba(200,150,42,0.3)':'rgba(255,255,255,0.06)'}`,borderRadius:14,padding:12,textAlign:'center',opacity:b.earned?1:0.45}}>
              <div style={{fontSize:24,marginBottom:4}}>{b.icon}</div>
              <div style={{fontSize:11,fontWeight:600,color:b.earned?'#F0C866':'rgba(200,184,160,0.45)'}}>{b.label}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}
X
echo "  ✓ Progress"


cat > $B/src/App.jsx << 'X'
import { useState, useEffect } from 'react'
import { getSetting } from './db/db'
import TabBar from './components/TabBar'
import Splash from './screens/Splash'
import Onboarding from './screens/Onboarding'
import Home from './screens/Home'
import Tasks from './screens/Tasks'
import Routine from './screens/Routine'
import Notes from './screens/Notes'
import Progress from './screens/Progress'
export default function App(){
  const [phase,setPhase]=useState('splash')
  const [tab,setTab]=useState('home')
  useEffect(()=>{getSetting('onboarded').then(v=>{if(v)setPhase('app')})},[])
  function afterSplash(){getSetting('onboarded').then(v=>setPhase(v?'app':'onboard'))}
  function afterOnboard(){setPhase('app')}
  const SCREENS={home:<Home onNav={setTab}/>,tasks:<Tasks/>,routine:<Routine/>,notes:<Notes/>,progress:<Progress/>}
  return(
    <div style={{display:'flex',flexDirection:'column',height:'100%',background:'#060E16',overflow:'hidden'}}>
      {phase==='splash'&&<Splash onDone={afterSplash}/>}
      {phase==='onboard'&&<Onboarding onDone={afterOnboard}/>}
      {phase==='app'&&<>
        <div style={{flex:1,overflow:'hidden',position:'relative'}}>{SCREENS[tab]}</div>
        <TabBar active={tab} onChange={setTab}/>
      </>}
    </div>
  )
}
X
echo "  ✓ App"


echo ""
echo "✅ All files written!"
echo "👉 Now run: npm run dev"
