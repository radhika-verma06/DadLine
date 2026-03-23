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

  const dot = (i) => (
    <div key={i} style={{
      width: step === i ? 22 : 8, height: 5,
      background: step === i ? '#C8962A' : 'rgba(200,150,42,0.3)',
      borderRadius: 3, transition: 'all .3s',
    }}/>
  )

  const Btn = ({ label, action, disabled = false }) => (
    <button onClick={action} disabled={disabled} style={{
      background: disabled ? 'rgba(255,255,255,0.07)' : 'linear-gradient(135deg,#C8962A,#E8B84B)',
      color: disabled ? 'rgba(200,184,160,0.35)' : '#060E16',
      fontWeight: 700, borderRadius: 14, border: 'none',
      cursor: disabled ? 'not-allowed' : 'pointer',
      fontSize: 16, width: '100%', padding: '15px',
      fontFamily: 'inherit', marginTop: 24, transition: 'all .2s',
    }}>{label}</button>
  )

  /* ── step 0: meet your companion ── */
  if (step === 0) return (
    <div style={{position:'fixed',inset:0,zIndex:998,background:'#0D1B2A',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',padding:'32px 24px'}}>
      <div style={{display:'flex',gap:6,marginBottom:32}}>{[0,1,2,3].map(dot)}</div>
      <div style={{fontFamily:'Georgia,serif',fontSize:26,fontWeight:700,color:'#F0C866',textAlign:'center',marginBottom:8,lineHeight:1.3}}>Meet your<br/>companion</div>
      <div style={{fontSize:13,color:'rgba(200,184,140,0.65)',textAlign:'center',marginBottom:28,lineHeight:1.65}}>I will be here every day to help you<br/>stay organised and motivated.</div>
      <div className="float"><PapaAvatar state="happy" size={120} showRings={true}/></div>
      <div style={{marginTop:18,background:'rgba(200,150,42,0.1)',border:'1px solid rgba(200,150,42,0.28)',borderRadius:14,borderTopLeftRadius:4,padding:'11px 16px',fontSize:13,color:'#E8D8B0',lineHeight:1.6,textAlign:'center',maxWidth:260}}>
        "I am so happy to be your companion!"
      </div>
      <Btn label="Continue →" action={() => setStep(1)} />
    </div>
  )

  /* ── step 1: what to call you ── */
  if (step === 1) return (
    <div style={{position:'fixed',inset:0,zIndex:998,background:'#0D1B2A',display:'flex',flexDirection:'column',padding:'env(safe-area-inset-top,44px) 24px 32px'}}>
      <div style={{display:'flex',gap:6,marginBottom:28,justifyContent:'center'}}>{[0,1,2,3].map(dot)}</div>
      <div style={{fontFamily:'Georgia,serif',fontSize:24,fontWeight:700,color:'#F0C866',textAlign:'center',marginBottom:8}}>What shall I<br/>call you?</div>
      <div style={{fontSize:13,color:'rgba(200,184,140,0.65)',textAlign:'center',marginBottom:28}}>I will greet you by name every morning.</div>
      <div style={{fontSize:10,fontWeight:600,letterSpacing:'.08em',textTransform:'uppercase',color:'rgba(200,150,42,0.65)',marginBottom:8}}>Your name</div>
      <input
        style={{background:'rgba(255,255,255,0.08)',border:'2px solid rgba(200,150,42,0.45)',borderRadius:14,padding:'14px 16px',fontSize:18,color:'#EEE8D5',fontFamily:'inherit',outline:'none',marginBottom:24}}
        placeholder="Enter your name..."
        value={name}
        onChange={e => setName(e.target.value)}
        autoFocus
      />
      <div style={{display:'flex',alignItems:'center',gap:12,background:'rgba(200,150,42,0.09)',border:'1px solid rgba(200,150,42,0.22)',borderRadius:14,padding:'12px 14px'}}>
        <PapaAvatar state="calm" size={48} showRings={false}/>
        <div style={{fontSize:12,color:'#E8D8B0',lineHeight:1.55}}>"I am looking forward to working with you!"</div>
      </div>
      <Btn label="Continue →" action={() => setStep(2)} />
    </div>
  )

  /* ── step 2: you are all set ── */
  if (step === 2) return (
    <div style={{position:'fixed',inset:0,zIndex:998,background:'#0D1B2A',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',padding:'32px 24px'}}>
      <div style={{display:'flex',gap:6,marginBottom:28}}>{[0,1,2,3].map(dot)}</div>
      <div style={{fontFamily:'Georgia,serif',fontSize:24,fontWeight:700,color:'#F0C866',textAlign:'center',marginBottom:8}}>You are all set,<br/>{name || 'Papa'}! ✦</div>
      <div style={{fontSize:13,color:'rgba(200,184,140,0.65)',textAlign:'center',marginBottom:32}}>Your companion is ready and waiting.</div>
      <div className="float"><PapaAvatar state="happy" size={140} showRings={true}/></div>
      <div style={{marginTop:24,background:'rgba(76,175,130,0.1)',border:'1px solid rgba(76,175,130,0.25)',borderRadius:14,padding:'12px 16px',fontSize:13,color:'#A8DFC0',lineHeight:1.6,textAlign:'center'}}>
        "Welcome! Let us make every day wonderful together."
      </div>
      <Btn label="Next →" action={finish} />
    </div>
  )
}
