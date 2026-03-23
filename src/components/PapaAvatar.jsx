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
