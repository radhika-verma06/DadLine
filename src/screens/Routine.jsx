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
