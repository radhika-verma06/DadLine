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
