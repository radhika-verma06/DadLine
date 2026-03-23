#!/bin/bash
set -e
B=~/papa-app

echo "🎂 Installing birthday feature..."
mkdir -p $B/src/screens

# ── Birthday.jsx ──────────────────────────────────────────────────────────────
cat > $B/src/screens/Birthday.jsx << 'JSXEOF'
import { useEffect, useRef, useState } from 'react'
import PapaAvatar from '../components/PapaAvatar'

function useConfetti(active) {
  const canvasRef = useRef(null)
  const animRef   = useRef(null)
  const parts     = useRef([])

  useEffect(() => {
    if (!active) return
    const canvas = canvasRef.current
    if (!canvas) return
    const ctx = canvas.getContext('2d')
    canvas.width  = window.innerWidth
    canvas.height = window.innerHeight
    const COLORS = ['#F0C866','#C8962A','#E8B84B','#4CAF82','#E8855A','#6496E8','#C090D8','#FF6B9D','#FFD700','#FF4500','#00CED1','#FF69B4']
    const SHAPES = ['circle','rect','triangle','star']
    parts.current = []
    for (let i = 0; i < 200; i++) {
      const angle = Math.random() * Math.PI * 2
      const speed = 5 + Math.random() * 16
      parts.current.push({
        x: canvas.width/2, y: canvas.height*0.4,
        vx: Math.cos(angle)*speed, vy: Math.sin(angle)*speed - 8,
        color: COLORS[Math.floor(Math.random()*COLORS.length)],
        shape: SHAPES[Math.floor(Math.random()*SHAPES.length)],
        size: 5 + Math.random()*10,
        rotation: Math.random()*360, rotSpeed: (Math.random()-0.5)*9,
        alpha: 1, decay: 0.01+Math.random()*0.008, gravity: 0.2+Math.random()*0.15,
      })
    }
    function draw() {
      ctx.clearRect(0,0,canvas.width,canvas.height)
      parts.current = parts.current.filter(p=>p.alpha>0.01)
      parts.current.forEach(p=>{
        p.x+=p.vx; p.y+=p.vy; p.vy+=p.gravity; p.vx*=0.99
        p.rotation+=p.rotSpeed; p.alpha-=p.decay
        ctx.save()
        ctx.globalAlpha=Math.max(0,p.alpha)
        ctx.translate(p.x,p.y)
        ctx.rotate(p.rotation*Math.PI/180)
        ctx.fillStyle=p.color
        if(p.shape==='circle'){ctx.beginPath();ctx.arc(0,0,p.size/2,0,Math.PI*2);ctx.fill()}
        else if(p.shape==='rect'){ctx.fillRect(-p.size/2,-p.size/4,p.size,p.size/2)}
        else if(p.shape==='triangle'){ctx.beginPath();ctx.moveTo(0,-p.size/2);ctx.lineTo(p.size/2,p.size/2);ctx.lineTo(-p.size/2,p.size/2);ctx.closePath();ctx.fill()}
        else {
          ctx.beginPath()
          for(let j=0;j<5;j++){
            const a=j*4*Math.PI/5-Math.PI/2
            const b=a+2*Math.PI/5
            ctx.lineTo(Math.cos(a)*p.size/2,Math.sin(a)*p.size/2)
            ctx.lineTo(Math.cos(b)*p.size/4,Math.sin(b)*p.size/4)
          }
          ctx.closePath();ctx.fill()
        }
        ctx.restore()
      })
      animRef.current=requestAnimationFrame(draw)
    }
    draw()
    return()=>{cancelAnimationFrame(animRef.current);parts.current=[]}
  },[active])
  return canvasRef
}

const WISHES = [
  "Wishing you a day as magnificent as you are, Paji! Every moment of today is yours.",
  "May this birthday bring you the warmth, joy, and laughter you bring to everyone around you.",
  "You are the kind of person who makes the world more beautiful. Happy Birthday, Paji!",
  "On your special day, I hope you feel as loved as you truly are. Celebrating you always!",
  "May every candle you blow out bring a wish come true. So many more ahead, Paji!",
  "The best gift I ever received was having you in my life. Happy Birthday from the heart.",
  "You make every ordinary day extraordinary. Today we celebrate YOU, Paji!",
  "May this year be your most joyful, healthiest, and most beautiful one yet. Love you!",
]

const RAIN_EMOJIS = ['🎂','🎉','🎈','⭐','✨','🌟','💛','🎁','🥳','🎊','💐','🍰','🎆','🎇','🪅','🎀']

function EmojiRain() {
  const items = useState(()=>Array.from({length:28},(_,i)=>({
    id:i, e:RAIN_EMOJIS[i%RAIN_EMOJIS.length],
    l:Math.random()*95, del:Math.random()*4,
    dur:3.5+Math.random()*3, sz:18+Math.random()*22,
  })))[0]
  return (
    <div style={{position:'absolute',inset:0,overflow:'hidden',pointerEvents:'none',zIndex:2}}>
      <style>{`@keyframes bdfall{0%{transform:translateY(-50px) rotate(0deg);opacity:1}85%{opacity:.8}100%{transform:translateY(105vh) rotate(400deg);opacity:0}}`}</style>
      {items.map(it=>(
        <div key={it.id} style={{position:'absolute',left:`${it.l}%`,top:-50,fontSize:it.sz,animation:`bdfall ${it.dur}s ${it.del}s linear infinite`}}>{it.e}</div>
      ))}
    </div>
  )
}

function Firework({x,y,color}){
  return(
    <div style={{position:'absolute',left:x,top:y,width:0,height:0,zIndex:3,pointerEvents:'none'}}>
      {Array.from({length:12},(_,i)=>{
        const a=(i/12)*360
        return <div key={i} style={{position:'absolute',width:3,height:3,borderRadius:'50%',background:color,animation:`fw 0.8s ease-out forwards`,transform:`rotate(${a}deg) translateY(-30px)`,opacity:0}}/>
      })}
      <style>{`@keyframes fw{0%{opacity:1;transform:rotate(var(--a)) translateY(0)}100%{opacity:0;transform:rotate(var(--a)) translateY(-60px)}}`}</style>
    </div>
  )
}

export default function Birthday({ name='Papa', onClose }) {
  const [wish]      = useState(()=>WISHES[Math.floor(Math.random()*WISHES.length)])
  const [showText,  setShowText]  = useState(false)
  const [glowBig,   setGlowBig]   = useState(false)
  const [burst,     setBurst]      = useState(false)
  const canvasRef   = useConfetti(burst)

  useEffect(()=>{
    setBurst(true)
    const t1=setTimeout(()=>setShowText(true),500)
    const t2=setTimeout(()=>setGlowBig(true),900)
    return()=>{clearTimeout(t1);clearTimeout(t2)}
  },[])

  const GLOW_COLS=['#F0C866','#E8855A','#6496E8','#4CAF82','#C090D8']

  return (
    <div style={{position:'fixed',inset:0,zIndex:500,background:'linear-gradient(160deg,#060E16 0%,#0A1628 45%,#060816 100%)',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',overflow:'hidden'}}>

      {/* confetti canvas */}
      <canvas ref={canvasRef} style={{position:'absolute',inset:0,zIndex:1,pointerEvents:'none'}}/>

      {/* emoji rain */}
      <EmojiRain/>

      {/* pulse rings */}
      <div style={{position:'absolute',inset:0,display:'flex',alignItems:'center',justifyContent:'center',zIndex:0,pointerEvents:'none'}}>
        {[260,340,420,500,580].map((s,i)=>(
          <div key={i} style={{position:'absolute',width:s,height:s,borderRadius:'50%',border:`1px solid rgba(200,150,42,${0.25-i*0.04})`,animation:`ring-pulse ${2.8+i*0.5}s ease-in-out ${i*0.25}s infinite`}}/>
        ))}
        {glowBig&&<div style={{position:'absolute',width:280,height:280,borderRadius:'50%',background:'radial-gradient(circle,rgba(200,150,42,0.22) 0%,transparent 70%)',animation:'ring-pulse 2s ease-in-out infinite'}}/>}
      </div>

      {/* CONTENT */}
      <div style={{position:'relative',zIndex:10,display:'flex',flexDirection:'column',alignItems:'center',padding:'0 24px',textAlign:'center',gap:0}}>

        {/* 🎂 top badge */}
        <div style={{opacity:showText?1:0,transition:'opacity .5s ease',marginBottom:16,background:'linear-gradient(135deg,rgba(232,133,90,0.25),rgba(200,150,42,0.2))',border:'1px solid rgba(200,150,42,0.45)',borderRadius:30,padding:'7px 20px',fontSize:13,fontWeight:700,color:'#F0C866',letterSpacing:'.06em'}}>
          🎂 YOUR SPECIAL DAY 🎂
        </div>

        {/* Avatar with bounce */}
        <div style={{animation:showText?'avatarPop .7s cubic-bezier(0.34,1.56,0.64,1)':'none',marginBottom:18}}>
          <PapaAvatar state="happy" size={148} showRings={true}/>
        </div>

        {/* Main heading */}
        <div style={{opacity:showText?1:0,transform:showText?'translateY(0)':'translateY(20px)',transition:'all .6s cubic-bezier(.22,1,.36,1)',marginBottom:10}}>
          <div style={{fontSize:36,fontWeight:700,color:'#F0C866',lineHeight:1.2,fontFamily:'Georgia,serif'}}>Happy Birthday</div>
          <div style={{fontSize:42,fontWeight:700,color:'#E8B84B',lineHeight:1.1,fontFamily:'Georgia,serif',marginBottom:6}}>{name}!</div>
        </div>

        {/* Paji callout */}
        <div style={{opacity:showText?1:0,transform:showText?'translateY(0)':'translateY(14px)',transition:'all .6s cubic-bezier(.22,1,.36,1) .15s',marginBottom:14}}>
          <div style={{background:'linear-gradient(135deg,rgba(200,150,42,0.22),rgba(232,184,75,0.1))',border:'1.5px solid rgba(200,150,42,0.5)',borderRadius:24,padding:'12px 28px',fontSize:20,fontWeight:700,color:'#F0C866',boxShadow:'0 0 28px rgba(200,150,42,0.22)'}}>
            🥳 Happy Birthday Paji! 🥳
          </div>
        </div>

        {/* Wish */}
        <div style={{opacity:showText?1:0,transform:showText?'translateY(0)':'translateY(10px)',transition:'all .6s cubic-bezier(.22,1,.36,1) .28s',marginBottom:26,maxWidth:320}}>
          <div style={{background:'rgba(255,255,255,0.06)',border:'1px solid rgba(200,150,42,0.2)',borderRadius:18,padding:'14px 18px',fontSize:14,color:'#E8D8B0',lineHeight:1.75,fontStyle:'italic'}}>
            "{wish}"
          </div>
        </div>

        {/* CTA */}
        <button onClick={onClose} style={{opacity:showText?1:0,transition:'opacity .4s ease .5s',background:'linear-gradient(135deg,#C8962A,#E8B84B)',color:'#060E16',fontWeight:700,fontSize:17,borderRadius:16,border:'none',cursor:'pointer',padding:'16px 52px',fontFamily:'inherit',boxShadow:'0 0 36px rgba(200,150,42,0.45)',letterSpacing:'.01em'}}>
          Thank you! 🎂 ✦
        </button>
      </div>

      <style>{`
        @keyframes avatarPop {
          0%  {transform:scale(0.3) rotate(-8deg);opacity:0}
          55% {transform:scale(1.15) rotate(3deg);opacity:1}
          75% {transform:scale(0.94) rotate(-1deg)}
          100%{transform:scale(1) rotate(0deg);opacity:1}
        }
      `}</style>
    </div>
  )
}
JSXEOF
echo "  ✓ Birthday.jsx"

# ── BirthdaySetup.jsx (DOB collection during onboarding) ──────────────────────
cat > $B/src/screens/BirthdaySetup.jsx << 'JSXEOF'
import { useState } from 'react'
import { setSetting } from '../db/db'
import PapaAvatar from '../components/PapaAvatar'

export default function BirthdaySetup({ name, onDone }) {
  const [day,   setDay]   = useState('')
  const [month, setMonth] = useState('')
  const MONTHS=['January','February','March','April','May','June','July','August','September','October','November','December']

  async function save() {
    if (day && month) {
      await setSetting('dobDay',   parseInt(day))
      await setSetting('dobMonth', parseInt(month))
    }
    onDone()
  }

  const sel = {
    background:'rgba(255,255,255,0.07)', border:'1px solid rgba(200,150,42,0.32)',
    borderRadius:13, padding:'13px 14px', fontSize:16, color:'#EEE8D5',
    width:'100%', fontFamily:'inherit', outline:'none', appearance:'none',
    WebkitAppearance:'none', cursor:'pointer',
  }

  return (
    <div style={{position:'fixed',inset:0,zIndex:998,background:'#0D1B2A',display:'flex',flexDirection:'column',padding:'env(safe-area-inset-top,44px) 24px 32px'}}>
      <div style={{display:'flex',gap:6,marginBottom:28,justifyContent:'center'}}>
        {[0,1,2,3].map(i=><div key={i} style={{width:i===3?22:8,height:5,background:i===3?'#C8962A':'rgba(200,150,42,0.28)',borderRadius:3}}/>)}
      </div>

      <div style={{fontFamily:'Georgia,serif',fontSize:24,fontWeight:700,color:'#F0C866',textAlign:'center',marginBottom:6}}>When is your<br/>birthday, {name}?</div>
      <div style={{fontSize:13,color:'rgba(200,184,140,0.65)',textAlign:'center',marginBottom:28,lineHeight:1.65}}>I will celebrate with you every year<br/>and wish you on your special day!</div>

      <div style={{display:'flex',justifyContent:'center',marginBottom:24}}>
        <PapaAvatar state="happy" size={100} showRings={true}/>
      </div>

      <div style={{marginBottom:14}}>
        <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.65)',marginBottom:8}}>Month</div>
        <div style={{position:'relative'}}>
          <select style={sel} value={month} onChange={e=>setMonth(e.target.value)}>
            <option value="">Select month...</option>
            {MONTHS.map((m,i)=><option key={i} value={i+1}>{m}</option>)}
          </select>
          <span style={{position:'absolute',right:14,top:'50%',transform:'translateY(-50%)',color:'rgba(200,150,42,0.6)',pointerEvents:'none',fontSize:14}}>▾</span>
        </div>
      </div>

      <div style={{marginBottom:28}}>
        <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.65)',marginBottom:8}}>Day</div>
        <div style={{position:'relative'}}>
          <select style={sel} value={day} onChange={e=>setDay(e.target.value)}>
            <option value="">Select day...</option>
            {Array.from({length:31},(_,i)=><option key={i} value={i+1}>{i+1}</option>)}
          </select>
          <span style={{position:'absolute',right:14,top:'50%',transform:'translateY(-50%)',color:'rgba(200,150,42,0.6)',pointerEvents:'none',fontSize:14}}>▾</span>
        </div>
      </div>

      <div style={{marginTop:'auto',display:'flex',flexDirection:'column',gap:10}}>
        <button onClick={save} disabled={!day||!month} style={{background:day&&month?'linear-gradient(135deg,#C8962A,#E8B84B)':'rgba(255,255,255,0.08)',color:day&&month?'#060E16':'rgba(200,184,160,0.35)',fontWeight:700,borderRadius:14,border:'none',cursor:day&&month?'pointer':'not-allowed',fontSize:16,width:'100%',padding:'15px',fontFamily:'inherit',transition:'all .2s'}}>
          {day&&month?'Save Birthday 🎂':'Select your birthday'}
        </button>
        <button onClick={onDone} style={{background:'none',border:'none',cursor:'pointer',fontSize:13,color:'rgba(200,150,42,0.45)',fontFamily:'inherit',padding:'8px'}}>Skip for now</button>
      </div>
    </div>
  )
}
JSXEOF
echo "  ✓ BirthdaySetup.jsx"

# ── useBirthday hook ──────────────────────────────────────────────────────────
cat > $B/src/hooks/useBirthday.js << 'JSEOF'
import { useEffect, useState, useCallback } from 'react'
import { getSetting, setSetting } from '../db/db'

export function useBirthday() {
  const [isBirthday,    setIsBirthday]    = useState(false)
  const [showBirthday,  setShowBirthday]  = useState(false)
  const [userName,      setUserName]      = useState('Papa')

  const check = useCallback(async () => {
    const dobDay   = await getSetting('dobDay')
    const dobMonth = await getSetting('dobMonth')
    const name     = await getSetting('userName', 'Papa')
    setUserName(name)
    if (!dobDay || !dobMonth) return

    const now   = new Date()
    const today = { day: now.getDate(), month: now.getMonth()+1 }
    const isBD  = today.day === dobDay && today.month === dobMonth

    setIsBirthday(isBD)

    if (isBD) {
      // Show birthday screen if not shown recently (within 2 hours)
      const lastShown = await getSetting('bdLastShown')
      const now2h = Date.now()
      if (!lastShown || now2h - lastShown > 2 * 60 * 60 * 1000) {
        setShowBirthday(true)
        await setSetting('bdLastShown', now2h)
      }
    }
  }, [])

  useEffect(() => { check() }, [check])

  // Schedule 2-hour check intervals
  useEffect(() => {
    if (!isBirthday) return
    const interval = setInterval(async () => {
      const lastShown = await getSetting('bdLastShown')
      const now = Date.now()
      if (!lastShown || now - lastShown > 2 * 60 * 60 * 1000) {
        setShowBirthday(true)
        await setSetting('bdLastShown', now)
      }
    }, 60 * 1000) // check every minute
    return () => clearInterval(interval)
  }, [isBirthday])

  // Request + schedule web push notifications on birthday
  useEffect(() => {
    if (!isBirthday) return
    scheduleBirthdayNotifications()
  }, [isBirthday])

  async function scheduleBirthdayNotifications() {
    if (!('Notification' in window)) return
    let perm = Notification.permission
    if (perm === 'default') perm = await Notification.requestPermission()
    if (perm !== 'granted') return

    const msgs = [
      '🎂 Happy Birthday Paji! Wishing you a wonderful day!',
      '🎉 Many many happy returns of the day, Paji!',
      '🌟 You are loved and celebrated today, Paji!',
      '🥳 Happy Birthday! Hope your day is full of joy!',
      '🎈 Sending birthday love your way, Paji!',
    ]

    // Fire immediately + every ~2 hours throughout birthday
    const hours = [0, 2, 4, 6, 8, 10, 12]
    hours.forEach((h, i) => {
      setTimeout(() => {
        if (new Date().getDate() === new Date().getDate()) { // still today
          new Notification('🎂 Papa App', {
            body: msgs[i % msgs.length],
            icon: '/icon.png',
            badge: '/icon.png',
            tag: `birthday-${h}`,
          })
        }
      }, h * 60 * 60 * 1000 + 500)
    })
  }

  const dismiss = useCallback(() => setShowBirthday(false), [])
  const trigger  = useCallback(async () => {
    await setSetting('bdLastShown', Date.now())
    setShowBirthday(true)
  }, [])

  return { isBirthday, showBirthday, userName, dismiss, trigger }
}
JSEOF
echo "  ✓ useBirthday.js"

# ── Update App.jsx to include birthday flow ───────────────────────────────────
cat > $B/src/App.jsx << 'JSXEOF'
import { useState, useEffect } from 'react'
import { getSetting } from './db/db'
import TabBar       from './components/TabBar'
import Splash       from './screens/Splash'
import Onboarding   from './screens/Onboarding'
import BirthdaySetup from './screens/BirthdaySetup'
import Home         from './screens/Home'
import Tasks        from './screens/Tasks'
import Routine      from './screens/Routine'
import Notes        from './screens/Notes'
import Progress     from './screens/Progress'
import Birthday     from './screens/Birthday'
import { useBirthday } from './hooks/useBirthday'

export default function App() {
  const [phase, setPhase] = useState('splash') // splash|onboard|birthday-setup|app
  const [tab,   setTab]   = useState('home')
  const [userName, setUserName] = useState('Papa')

  const { isBirthday, showBirthday, dismiss, trigger } = useBirthday()

  useEffect(() => {
    getSetting('onboarded').then(v => {
      if (v) setPhase('app')
    })
  }, [])

  function afterSplash() {
    getSetting('onboarded').then(v => setPhase(v ? 'app' : 'onboard'))
  }

  function afterOnboard(name) {
    setUserName(name)
    setPhase('birthday-setup')
  }

  function afterBirthdaySetup() {
    setPhase('app')
  }

  const SCREENS = {
    home:     <Home     onNav={setTab} />,
    tasks:    <Tasks    />,
    routine:  <Routine  />,
    notes:    <Notes    />,
    progress: <Progress />,
  }

  return (
    <div style={{ display:'flex', flexDirection:'column', height:'100%', background:'#060E16', overflow:'hidden' }}>
      {phase === 'splash'         && <Splash        onDone={afterSplash} />}
      {phase === 'onboard'        && <Onboarding    onDone={afterOnboard} />}
      {phase === 'birthday-setup' && <BirthdaySetup name={userName} onDone={afterBirthdaySetup} />}

      {phase === 'app' && (
        <>
          <div style={{ flex:1, overflow:'hidden', position:'relative' }}>
            {SCREENS[tab]}
          </div>
          <TabBar active={tab} onChange={setTab} />

          {/* Birthday floating button when it's their birthday */}
          {isBirthday && !showBirthday && (
            <button onClick={trigger} style={{
              position:'fixed', bottom:90, right:18, zIndex:100,
              background:'linear-gradient(135deg,#C8962A,#E8B84B)',
              border:'none', borderRadius:'50%', width:56, height:56,
              fontSize:26, cursor:'pointer',
              boxShadow:'0 0 24px rgba(200,150,42,0.55)',
              animation:'ring-pulse 2s ease-in-out infinite',
            }}>🎂</button>
          )}
        </>
      )}

      {/* Birthday overlay - shows on top of everything */}
      {showBirthday && (
        <Birthday name={userName} onClose={dismiss} />
      )}
    </div>
  )
}
JSXEOF
echo "  ✓ App.jsx updated"

# ── Update Onboarding to pass name back ──────────────────────────────────────
cat > $B/src/screens/Onboarding.jsx << 'JSXEOF'
import { useState } from 'react'
import { setSetting } from '../db/db'
import PapaAvatar from '../components/PapaAvatar'

export default function Onboarding({ onDone }) {
  const [step, setStep] = useState(0)
  const [name, setName] = useState('')

  async function finish() {
    const n = name.trim() || 'Papa'
    await setSetting('userName', n)
    await setSetting('onboarded', true)
    onDone(n)
  }

  const dot = (i) => <div key={i} style={{width:step===i?22:8,height:5,background:step===i?'#C8962A':'rgba(200,150,42,0.28)',borderRadius:3,transition:'all .3s'}}/>

  const btnStyle = {
    background:'linear-gradient(135deg,#C8962A,#E8B84B)', color:'#060E16',
    fontWeight:700, borderRadius:14, border:'none', cursor:'pointer',
    fontSize:16, width:'100%', padding:'15px', fontFamily:'inherit', marginTop:24,
  }

  if (step === 0) return (
    <div style={{position:'fixed',inset:0,zIndex:998,background:'#0D1B2A',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',padding:'32px 24px'}}>
      <div style={{display:'flex',gap:6,marginBottom:32}}>{[0,1,2,3].map(dot)}</div>
      <div style={{fontFamily:'Georgia,serif',fontSize:26,fontWeight:700,color:'#F0C866',textAlign:'center',marginBottom:8,lineHeight:1.3}}>Meet your<br/>companion</div>
      <div style={{fontSize:13,color:'rgba(200,184,140,0.65)',textAlign:'center',marginBottom:28,lineHeight:1.65}}>I will be here every day to help you<br/>stay organised and motivated.</div>
      <div className="float"><PapaAvatar state="happy" size={120} showRings={true}/></div>
      <div style={{marginTop:18,background:'rgba(200,150,42,0.1)',border:'1px solid rgba(200,150,42,0.28)',borderRadius:14,borderTopLeftRadius:4,padding:'11px 16px',fontSize:13,color:'#E8D8B0',lineHeight:1.6,textAlign:'center',maxWidth:260}}>"I am so happy to be your companion!"</div>
      <button onClick={()=>setStep(1)} style={btnStyle}>Continue →</button>
    </div>
  )

  if (step === 1) return (
    <div style={{position:'fixed',inset:0,zIndex:998,background:'#0D1B2A',display:'flex',flexDirection:'column',padding:'env(safe-area-inset-top,44px) 24px 32px'}}>
      <div style={{display:'flex',gap:6,marginBottom:28,justifyContent:'center'}}>{[0,1,2,3].map(dot)}</div>
      <div style={{fontFamily:'Georgia,serif',fontSize:24,fontWeight:700,color:'#F0C866',textAlign:'center',marginBottom:8}}>What shall I<br/>call you?</div>
      <div style={{fontSize:13,color:'rgba(200,184,140,0.65)',textAlign:'center',marginBottom:28}}>I will greet you by name every morning.</div>
      <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.65)',marginBottom:8}}>Your name</div>
      <input style={{background:'rgba(255,255,255,0.08)',border:'2px solid rgba(200,150,42,0.45)',borderRadius:14,padding:'14px 16px',fontSize:18,color:'#EEE8D5',fontFamily:'inherit',outline:'none',marginBottom:24}} placeholder="Enter your name..." value={name} onChange={e=>setName(e.target.value)} autoFocus/>
      <div style={{display:'flex',alignItems:'center',gap:12,background:'rgba(200,150,42,0.09)',border:'1px solid rgba(200,150,42,0.22)',borderRadius:14,padding:'12px 14px'}}>
        <PapaAvatar state="calm" size={48} showRings={false}/>
        <div style={{fontSize:12,color:'#E8D8B0',lineHeight:1.55}}>"I am looking forward to working with you!"</div>
      </div>
      <button onClick={()=>setStep(2)} style={btnStyle}>Continue →</button>
    </div>
  )

  return (
    <div style={{position:'fixed',inset:0,zIndex:998,background:'#0D1B2A',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',padding:'32px 24px'}}>
      <div style={{display:'flex',gap:6,marginBottom:28}}>{[0,1,2,3].map(dot)}</div>
      <div style={{fontFamily:'Georgia,serif',fontSize:24,fontWeight:700,color:'#F0C866',textAlign:'center',marginBottom:8}}>You are all set,<br/>{name||'Papa'}! ✦</div>
      <div style={{fontSize:13,color:'rgba(200,184,140,0.65)',textAlign:'center',marginBottom:32}}>Your companion is ready and waiting.</div>
      <div className="float"><PapaAvatar state="happy" size={140} showRings={true}/></div>
      <div style={{marginTop:24,background:'rgba(76,175,130,0.1)',border:'1px solid rgba(76,175,130,0.25)',borderRadius:14,padding:'12px 16px',fontSize:13,color:'#A8DFC0',lineHeight:1.6,textAlign:'center'}}>"Welcome! Let us make every day wonderful together."</div>
      <button onClick={finish} style={btnStyle}>Next →</button>
    </div>
  )
}
JSXEOF
echo "  ✓ Onboarding.jsx updated"

mkdir -p $B/src/hooks
echo "  ✓ hooks folder created"

echo ""
echo "✅ Birthday feature fully installed!"
echo "👉 Now run: npm run dev"
