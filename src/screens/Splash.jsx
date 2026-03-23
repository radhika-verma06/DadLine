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
