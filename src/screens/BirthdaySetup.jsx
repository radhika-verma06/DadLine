import { useState } from 'react'
import { setSetting } from '../db/db'
import PapaAvatar from '../components/PapaAvatar'

const MONTHS = ['January','February','March','April','May','June','July','August','September','October','November','December']

export default function BirthdaySetup({ name = 'Papa', onDone }) {
  const [day,   setDay]   = useState('')
  const [month, setMonth] = useState('')

  async function save() {
    if (day && month) {
      await setSetting('dobDay',   parseInt(day))
      await setSetting('dobMonth', parseInt(month))
    }
    onDone()
  }

  const sel = {
    background: 'rgba(255,255,255,0.07)',
    border: '1px solid rgba(200,150,42,0.32)',
    borderRadius: 13, padding: '13px 14px',
    fontSize: 16, color: '#EEE8D5',
    width: '100%', fontFamily: 'inherit',
    outline: 'none', appearance: 'none',
    WebkitAppearance: 'none', cursor: 'pointer',
  }

  const ready = day && month

  return (
    <div style={{
      position: 'fixed', inset: 0, zIndex: 998,
      background: '#0D1B2A',
      display: 'flex', flexDirection: 'column',
      padding: 'env(safe-area-inset-top,44px) 24px 32px',
    }}>
      {/* Step dots — step 4 of 4 */}
      <div style={{ display:'flex', gap:6, marginBottom:28, justifyContent:'center' }}>
        {[0,1,2,3].map(i => (
          <div key={i} style={{
            width: i === 3 ? 22 : 8, height: 5,
            background: i === 3 ? '#C8962A' : 'rgba(200,150,42,0.4)',
            borderRadius: 3,
          }}/>
        ))}
      </div>

      <div style={{ fontFamily:'Georgia,serif', fontSize:24, fontWeight:700, color:'#F0C866', textAlign:'center', marginBottom:6, lineHeight:1.3 }}>
        When is your<br/>birthday, {name}?
      </div>
      <div style={{ fontSize:13, color:'rgba(200,184,140,0.65)', textAlign:'center', marginBottom:24, lineHeight:1.65 }}>
        I will celebrate with you every year<br/>and wish you on your special day!
      </div>

      <div style={{ display:'flex', justifyContent:'center', marginBottom:22 }}>
        <PapaAvatar state="happy" size={100} showRings={true} />
      </div>

      {/* Month */}
      <div style={{ marginBottom:14 }}>
        <div style={{ fontSize:10, fontWeight:600, letterSpacing:'.08em', textTransform:'uppercase', color:'rgba(200,150,42,0.65)', marginBottom:8 }}>Month</div>
        <div style={{ position:'relative' }}>
          <select style={sel} value={month} onChange={e => setMonth(e.target.value)}>
            <option value="">Select month...</option>
            {MONTHS.map((m, i) => <option key={i} value={i+1}>{m}</option>)}
          </select>
          <span style={{ position:'absolute', right:14, top:'50%', transform:'translateY(-50%)', color:'rgba(200,150,42,0.6)', pointerEvents:'none' }}>▾</span>
        </div>
      </div>

      {/* Day */}
      <div style={{ marginBottom:28 }}>
        <div style={{ fontSize:10, fontWeight:600, letterSpacing:'.08em', textTransform:'uppercase', color:'rgba(200,150,42,0.65)', marginBottom:8 }}>Day</div>
        <div style={{ position:'relative' }}>
          <select style={sel} value={day} onChange={e => setDay(e.target.value)}>
            <option value="">Select day...</option>
            {Array.from({length:31}, (_, i) => <option key={i} value={i+1}>{i+1}</option>)}
          </select>
          <span style={{ position:'absolute', right:14, top:'50%', transform:'translateY(-50%)', color:'rgba(200,150,42,0.6)', pointerEvents:'none' }}>▾</span>
        </div>
      </div>

      {/* Preview */}
      {ready && (
        <div style={{ background:'rgba(200,150,42,0.1)', border:'1px solid rgba(200,150,42,0.28)', borderRadius:14, padding:'11px 14px', marginBottom:16, display:'flex', alignItems:'center', gap:10 }}>
          <span style={{ fontSize:22 }}>🎂</span>
          <div style={{ fontSize:13, color:'#E8D8B0' }}>
            I will celebrate your birthday every<br/>
            <strong style={{ color:'#F0C866' }}>{MONTHS[parseInt(month)-1]} {day}</strong> with a special surprise!
          </div>
        </div>
      )}

      <div style={{ marginTop:'auto', display:'flex', flexDirection:'column', gap:10 }}>
        <button onClick={save} style={{
          background: ready ? 'linear-gradient(135deg,#C8962A,#E8B84B)' : 'rgba(255,255,255,0.07)',
          color: ready ? '#060E16' : 'rgba(200,184,160,0.35)',
          fontWeight: 700, borderRadius: 14, border: 'none',
          cursor: ready ? 'pointer' : 'not-allowed',
          fontSize: 16, width: '100%', padding: '15px', fontFamily: 'inherit',
          transition: 'all .2s',
        }}>
          {ready ? `Save Birthday 🎂` : 'Select month and day first'}
        </button>
        <button onClick={onDone} style={{ background:'none', border:'none', cursor:'pointer', fontSize:13, color:'rgba(200,150,42,0.4)', fontFamily:'inherit', padding:8 }}>
          Skip for now
        </button>
      </div>
    </div>
  )
}
