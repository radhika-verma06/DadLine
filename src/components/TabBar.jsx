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
