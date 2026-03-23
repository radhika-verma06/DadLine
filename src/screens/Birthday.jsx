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
    const COLORS = ['#F0C866','#C8962A','#E8B84B','#4CAF82','#E8855A','#6496E8','#C090D8','#FF6B9D','#FFD700','#FF4500','#00CED1','#FF69B4','#FFA500','#ADFF2F']
    parts.current = []
    for (let i = 0; i < 220; i++) {
      const angle = Math.random() * Math.PI * 2
      const speed = 4 + Math.random() * 18
      parts.current.push({
        x: canvas.width / 2, y: canvas.height * 0.38,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed - 10,
        color: COLORS[Math.floor(Math.random() * COLORS.length)],
        shape: ['circle','rect','triangle','star'][Math.floor(Math.random()*4)],
        size: 5 + Math.random() * 11,
        rotation: Math.random() * 360,
        rotSpeed: (Math.random() - 0.5) * 10,
        alpha: 1,
        decay: 0.009 + Math.random() * 0.007,
        gravity: 0.18 + Math.random() * 0.14,
      })
    }
    const draw = () => {
      ctx.clearRect(0, 0, canvas.width, canvas.height)
      parts.current = parts.current.filter(p => p.alpha > 0.01)
      parts.current.forEach(p => {
        p.x += p.vx; p.y += p.vy; p.vy += p.gravity
        p.vx *= 0.992; p.rotation += p.rotSpeed; p.alpha -= p.decay
        ctx.save()
        ctx.globalAlpha = Math.max(0, p.alpha)
        ctx.translate(p.x, p.y)
        ctx.rotate(p.rotation * Math.PI / 180)
        ctx.fillStyle = p.color
        if (p.shape === 'circle') {
          ctx.beginPath(); ctx.arc(0, 0, p.size/2, 0, Math.PI*2); ctx.fill()
        } else if (p.shape === 'rect') {
          ctx.fillRect(-p.size/2, -p.size/4, p.size, p.size/2)
        } else if (p.shape === 'triangle') {
          ctx.beginPath(); ctx.moveTo(0,-p.size/2); ctx.lineTo(p.size/2,p.size/2); ctx.lineTo(-p.size/2,p.size/2); ctx.closePath(); ctx.fill()
        } else {
          ctx.beginPath()
          for (let j = 0; j < 5; j++) {
            const a = j * 4 * Math.PI / 5 - Math.PI / 2
            const b = a + 2 * Math.PI / 5
            ctx.lineTo(Math.cos(a)*p.size/2, Math.sin(a)*p.size/2)
            ctx.lineTo(Math.cos(b)*p.size/4, Math.sin(b)*p.size/4)
          }
          ctx.closePath(); ctx.fill()
        }
        ctx.restore()
      })
      animRef.current = requestAnimationFrame(draw)
    }
    draw()
    return () => { cancelAnimationFrame(animRef.current); parts.current = [] }
  }, [active])

  return canvasRef
}

const WISHES = [
  "Wishing you a day as magnificent as you are, Paji. Every moment of today is yours.",
  "May this birthday bring you all the warmth, joy and laughter you bring to everyone around you.",
  "You are the kind of person who makes the world more beautiful. Happy Birthday, Paji!",
  "On your special day, I hope you feel as deeply loved as you truly are.",
  "May every wish you make today come true. So many more beautiful years ahead!",
  "The best gift I ever received was having you in my life. Happy Birthday from the heart.",
  "You make every ordinary day extraordinary. Today we celebrate YOU, Paji!",
  "May this year be your most joyful, healthiest and most beautiful one yet. Love always!",
]

const RAIN = ['🎂','🎉','🎈','⭐','✨','🌟','💛','🎁','🥳','🎊','💐','🍰','🎆','🎇','🪅','🎀','🫶','💝']

function EmojiRain() {
  const items = useState(() =>
    Array.from({length:30}, (_, i) => ({
      id: i,
      e:   RAIN[i % RAIN.length],
      l:   Math.random() * 95,
      del: Math.random() * 4.5,
      dur: 3.5 + Math.random() * 3.5,
      sz:  16 + Math.random() * 24,
    }))
  )[0]
  return (
    <div style={{position:'absolute',inset:0,overflow:'hidden',pointerEvents:'none',zIndex:2}}>
      <style>{`@keyframes bdfall{0%{transform:translateY(-60px) rotate(0deg);opacity:1}90%{opacity:.7}100%{transform:translateY(108vh) rotate(380deg);opacity:0}}`}</style>
      {items.map(it => (
        <div key={it.id} style={{position:'absolute',left:`${it.l}%`,top:-60,fontSize:it.sz,animation:`bdfall ${it.dur}s ${it.del}s linear infinite`}}>{it.e}</div>
      ))}
    </div>
  )
}

export default function Birthday({ name = 'Papa', onClose }) {
  const [wish]     = useState(() => WISHES[Math.floor(Math.random() * WISHES.length)])
  const [show,     setShow]     = useState(false)
  const [glowBig,  setGlowBig]  = useState(false)
  const [burst,    setBurst]    = useState(false)
  const canvasRef  = useConfetti(burst)

  useEffect(() => {
    setBurst(true)
    const t1 = setTimeout(() => setShow(true),    450)
    const t2 = setTimeout(() => setGlowBig(true), 900)
    return () => { clearTimeout(t1); clearTimeout(t2) }
  }, [])

  return (
    <div style={{
      position:'fixed', inset:0, zIndex:500,
      background:'linear-gradient(160deg,#060E16 0%,#0A1628 45%,#060816 100%)',
      display:'flex', flexDirection:'column', alignItems:'center', justifyContent:'center',
      overflow:'hidden',
    }}>
      <canvas ref={canvasRef} style={{position:'absolute',inset:0,zIndex:1,pointerEvents:'none'}}/>
      <EmojiRain />

      {/* Pulse rings */}
      <div style={{position:'absolute',inset:0,display:'flex',alignItems:'center',justifyContent:'center',zIndex:0,pointerEvents:'none'}}>
        {[260,340,420,500,580].map((s,i) => (
          <div key={i} style={{position:'absolute',width:s,height:s,borderRadius:'50%',border:`1px solid rgba(200,150,42,${0.26-i*0.04})`,animation:`ring-pulse ${2.8+i*0.5}s ease-in-out ${i*0.25}s infinite`}}/>
        ))}
        {glowBig && (
          <div style={{position:'absolute',width:260,height:260,borderRadius:'50%',background:'radial-gradient(circle,rgba(200,150,42,0.24) 0%,transparent 70%)',animation:'ring-pulse 2s ease-in-out infinite'}}/>
        )}
      </div>

      {/* Main content */}
      <div style={{position:'relative',zIndex:10,display:'flex',flexDirection:'column',alignItems:'center',padding:'0 24px',textAlign:'center'}}>

        {/* Top badge */}
        <div style={{
          opacity: show ? 1 : 0, transition:'opacity .5s ease',
          marginBottom:16,
          background:'linear-gradient(135deg,rgba(232,133,90,0.22),rgba(200,150,42,0.18))',
          border:'1px solid rgba(200,150,42,0.45)',
          borderRadius:30, padding:'7px 20px',
          fontSize:12, fontWeight:700, color:'#F0C866', letterSpacing:'.08em',
        }}>
          🎂 &nbsp; YOUR SPECIAL DAY &nbsp; 🎂
        </div>

        {/* Avatar */}
        <div style={{
          animation: show ? 'avatarPop .75s cubic-bezier(0.34,1.56,0.64,1)' : 'none',
          marginBottom:20,
        }}>
          <PapaAvatar state="happy" size={148} showRings={true}/>
        </div>

        {/* Happy Birthday heading */}
        <div style={{
          opacity: show ? 1 : 0,
          transform: show ? 'translateY(0)' : 'translateY(22px)',
          transition:'all .65s cubic-bezier(.22,1,.36,1)',
          marginBottom:10,
        }}>
          <div style={{fontSize:14,fontWeight:600,letterSpacing:'.1em',textTransform:'uppercase',color:'rgba(200,150,42,0.6)',marginBottom:6}}>✦ Celebrating you today ✦</div>
          <div style={{fontSize:38,fontWeight:700,color:'#F0C866',lineHeight:1.2,fontFamily:'Georgia,serif'}}>Happy Birthday</div>
          <div style={{fontSize:44,fontWeight:700,color:'#E8B84B',lineHeight:1.1,fontFamily:'Georgia,serif'}}>{name}!</div>
        </div>

        {/* Paji callout */}
        <div style={{
          opacity: show ? 1 : 0,
          transform: show ? 'translateY(0)' : 'translateY(16px)',
          transition:'all .65s cubic-bezier(.22,1,.36,1) .15s',
          marginBottom:16,
        }}>
          <div style={{
            background:'linear-gradient(135deg,rgba(200,150,42,0.24),rgba(232,184,75,0.12))',
            border:'1.5px solid rgba(200,150,42,0.55)',
            borderRadius:24, padding:'13px 30px',
            fontSize:20, fontWeight:700, color:'#F0C866',
            boxShadow:'0 0 32px rgba(200,150,42,0.28)',
            letterSpacing:'.01em',
          }}>
            🥳 Happy Birthday Paji! 🥳
          </div>
        </div>

        {/* Wish */}
        <div style={{
          opacity: show ? 1 : 0,
          transform: show ? 'translateY(0)' : 'translateY(12px)',
          transition:'all .65s cubic-bezier(.22,1,.36,1) .28s',
          marginBottom:28, maxWidth:320,
        }}>
          <div style={{background:'rgba(255,255,255,0.065)',border:'1px solid rgba(200,150,42,0.2)',borderRadius:18,padding:'14px 18px',fontSize:14,color:'#E8D8B0',lineHeight:1.8,fontStyle:'italic'}}>
            "{wish}"
          </div>
        </div>

        {/* CTA */}
        <button onClick={onClose} style={{
          opacity: show ? 1 : 0,
          transition:'opacity .4s ease .5s',
          background:'linear-gradient(135deg,#C8962A,#E8B84B)',
          color:'#060E16', fontWeight:700, fontSize:17,
          borderRadius:16, border:'none', cursor:'pointer',
          padding:'16px 52px', fontFamily:'inherit',
          boxShadow:'0 0 40px rgba(200,150,42,0.5)',
          letterSpacing:'.01em',
        }}>
          Thank you! 🎂 ✦
        </button>
      </div>

      <style>{`
        @keyframes avatarPop {
          0%  { transform:scale(0.3) rotate(-8deg); opacity:0 }
          55% { transform:scale(1.15) rotate(3deg); opacity:1 }
          75% { transform:scale(0.95) rotate(-1deg) }
          100%{ transform:scale(1) rotate(0deg); opacity:1 }
        }
      `}</style>
    </div>
  )
}
